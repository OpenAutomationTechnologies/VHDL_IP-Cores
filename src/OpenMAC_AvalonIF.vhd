------------------------------------------------------------------------------------------------------------------------
-- Avalon Interface of OpenMAC to use with NIOS II
--  This is the top level of openMAC. It instantiates openMAC, openHUB, openFILTER and RMII2MII converters.
-- 	Depending on the generic settings the HWACC is enabled, which has to be used in combination with the PDI!
--
-- 	  Copyright (C) 2009 B&R
--
--    Redistribution and use in source and binary forms, with or without
--    modification, are permitted provided that the following conditions
--    are met:
--
--    1. Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
--    3. Neither the name of B&R nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without prior written permission. For written
--       permission, please contact office@br-automation.com
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
--
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2009-05-20  V0.01        First version
-- 2009-06-04  V0.10        Implemented FIFO for Data-Queing form/to DMA
-- 2009-06-15  V0.11        Increased performance of FIFO
-- 2009-06-20  V0.20        New FIFO concept. (FIFO IP of Altera used)
-- 2009-06-26  V0.21        Little Bugfix of DMA -> Reset was handled wrong
-- 2009-08-07  V0.30        Converted to official version
-- 2009-08-21  V0.40		TX DMA run if fifo is not empty. Interface for Timer Cmp + IRQ
-- 2009-09-03  V0.50		RX FIFO is definitely empty when a new frame arrives (Fifo sclr is set for 1 cycle)
-- 2009-09-07  V0.60		Added openFilter and openHub. Some changes in Mii core map. Added 2nd RMii Port.
-- 2009-09-15  V0.61		Added ability to read the Mac Time over Time Cmp Slave Interface (32 bits).
-- 2009-09-18  V0.62		Deleted in Phy Mii core NodeNr port. 
-- 2010-04-01  V0.63		Added Timer triggered transmission ability
--							RXFifo Clr is done at end of RxFrame (not beginning! refer to V0.50)
--							Added "CrsDv Filter" (deletes CrsDv toggle)
-- 2010-04-26  V0.70		reduced to two Avalon Slave and one Avalon Master Interface
-- 2010-05-03  V0.71		omit Avalon Master Interface / use internal DPR
-- 2010-08-02  V0.72		Enabled Timer triggered TX functionality (just adding generic TxSyncOn)
-- 2010-08-19  V0.73		Filter for phy ports
--							100MHz Clk for RMII ports (better for timing)
-- 2010-09-07  V0.74		Bugfix: Rx packets are not stored to DPRAM (Dma_Dout/Dma_Dout_s mixed up)
-- 2010-09-13  V0.75		added selection Rmii / Mii
-- 2011-01-25  V0.76		added packet location choice (internal or external)
--							Fix: Dma_Ack signal is asserted for one clock cycle only
-- 2011-02-24  V0.77		minor changes (naming conventions Mii->SMI)
-- 2011-03-02  V0.78		redesign of external packet buffer implementation
-- 2011-03-14  V0.79		added rx packet buffer location set ability
-- 2011-03-21  V0.80		area opt.: one adder is used for write/read addr.
--							performance opt.: read (TX) overrules write (RX) command of Avalon master (e.g. auto-resp)
-- 2011-03-28  V0.81		phy activity generator (for led)
-- 2011-04-26  V0.82		minor change of activity led to 6 Hz blink frequency
--							activity led generation changed
-- 2011-04-28  V0.83		second cmp timer is optinal by generic
-- 							generic for second phy port
--							clean up to reduce Quartus II warnings
-- 2011-05-06  V0.84		bug fix: use the RX_ER signal, it has important meaning!
-- 2011-05-09  V0.90		Hardware Acceleration (HW ACC) added.
--							bug fix: latch m_readdata for TX FIFO if m_waitrequest = 0
-- 2011-06-06  V0.91		optimized TX Fifo for openMAC DMA
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity AlteraOpenMACIF is
   generic( Simulate                    : 		boolean := false;
   			iBufSize_g					: 		integer := 1024;
   			iBufSizeLOG2_g				: 		integer := 10;
			useRmii_g					: 		boolean := true;
			useIntPacketBuf_g			:		boolean := true;
			useRxIntPacketBuf_g			:		boolean := true;
			use2ndCmpTimer_g			:		boolean := true;
			use2ndPhy_g					:		boolean := true;
			useHwAcc_g					:		boolean := false;
			iTpdos_g					: 		integer := 1;
			iRpdos_g					:		integer := 3);
   port (   Reset_n						: in    std_logic;
			Clk50                  		: in    std_logic;
			ClkFaster					: in	std_logic;
			ClkEth						: in	std_logic;
		-- Avalon Slave Interface 
            s_chipselect                : in    std_logic;
            s_read_n					: in    std_logic;
            s_write_n					: in    std_logic;
            s_byteenable_n              : in    std_logic_vector(1 downto 0);
            s_address                   : in    std_logic_vector(12 downto 0); --hw acc is linked to this if!
            s_writedata                 : in    std_logic_vector(15 downto 0);
            s_readdata                  : out   std_logic_vector(15 downto 0);
            s_IRQ						: out 	std_logic;
		-- Avalon Slave Interface to cmp unit 
            t_chipselect                : in    std_logic;
            t_read_n					: in    std_logic;
            t_write_n					: in    std_logic;
            t_byteenable_n              : in    std_logic_vector(3 downto 0);
            t_address                   : in    std_logic_vector(1 downto 0);
            t_writedata                 : in    std_logic_vector(31 downto 0);
            t_readdata                  : out   std_logic_vector(31 downto 0);
            t_IRQ						: out 	std_logic;
			t_IrqToggle					: out	std_logic;
        -- Avalon Slave Interface to packet buffer dpr
			iBuf_chipselect             : in    std_logic;
            iBuf_read_n					: in    std_logic;
            iBuf_write_n				: in    std_logic;
            iBuf_byteenable             : in    std_logic_vector(3 downto 0);
            iBuf_address                : in    std_logic_vector(iBufSizeLOG2_g-3 downto 0);
            iBuf_writedata              : in    std_logic_vector(31 downto 0);
            iBuf_readdata               : out   std_logic_vector(31 downto 0) := (others => '0');
		-- Avalon Master Interface
            m_read_n					: out   std_logic;
            m_write_n					: out   std_logic;
            m_byteenable_n              : out   std_logic_vector(1 downto 0);
            m_address                   : out   std_logic_vector(29 downto 0);
            m_writedata                 : out   std_logic_vector(15 downto 0);
            m_readdata                  : in    std_logic_vector(15 downto 0);
            m_waitrequest               : in    std_logic;
            m_arbiterlock				: out   std_logic;
		-- RMII Port 0
            rRx_Dat_0                   : in    std_logic_vector(1 downto 0);  -- RMII Rx Daten
            rCrs_Dv_0                   : in    std_logic;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_0                   : out   std_logic_vector(1 downto 0);  -- RMII Tx Daten
            rTx_En_0                    : out   std_logic;                     -- RMII Tx_Enable
		-- RMII Port 1
            rRx_Dat_1                   : in    std_logic_vector(1 downto 0);  -- RMII Rx Daten
            rCrs_Dv_1                   : in    std_logic;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_1                   : out   std_logic_vector(1 downto 0) := (others => '0');  -- RMII Tx Daten
            rTx_En_1                    : out   std_logic := '0';								  -- RMII Tx_Enable
		--- MII PORTS
			phyMii0_RxClk				: in	std_logic;
			phyMii0_RxDat               : in    std_logic_vector(3 downto 0);
			phyMii0_RxDv                : in    std_logic;
			phyMii0_RxEr				: in	std_logic;
			phyMii0_TxClk				: in	std_logic;
			phyMii0_TxDat               : out   std_logic_vector(3 downto 0) := (others => '0');
			phyMii0_TxEn                : out   std_logic := '0';
			phyMii0_TxEr                : out   std_logic := '0';
			phyMii1_RxClk				: in	std_logic;
			phyMii1_RxDat               : in    std_logic_vector(3 downto 0);
			phyMii1_RxDv                : in    std_logic;
			phyMii1_RxEr				: in	std_logic;
			phyMii1_TxClk				: in	std_logic;
			phyMii1_TxDat               : out   std_logic_vector(3 downto 0) := (others => '0');
			phyMii1_TxEn                : out   std_logic := '0';
			phyMii1_TxEr                : out   std_logic := '0';
--		-- Serial Management Interface (the_Mii)	
			smi_Clk						: out	std_logic;
			smi_Di						: in	std_logic;
			smi_Do						: out	std_logic;
			smi_Doe						: out	std_logic;
			phy_nResetOut				: out	std_logic;
		-- LED
			led_activity				: out	std_logic;
		--PDI change buffer triggers
			rpdo_change_tog				: out	std_logic_vector(2 downto 0);
			tpdo_change_tog				: out	std_logic
        );
end entity AlteraOpenMACIF;

architecture struct of AlteraOpenMACIF is
	signal rst							: std_logic;
-- Avalon Slave to openMAC
	signal mac_chipselect_ram           : std_logic;
	signal mac_chipselect_cont          : std_logic;
	signal mac_write_n					: std_logic;
	signal mac_byteenable_n             : std_logic_vector(1 downto 0);
	signal mac_address                  : std_logic_vector(11 downto 0);
	signal mac_writedata                : std_logic_vector(15 downto 0);
	signal mac_readdata                 : std_logic_vector(15 downto 0);
-- Avalon Slave to HWACC
	signal hwacc_chipselect				: std_logic := '0';
	signal hwacc_write, hwacc_read		: std_logic := '0';
	signal hwacc_address				: std_logic_vector(11 downto 0) := (others => '0');
	signal hwacc_writedata				: std_logic_vector(15 downto 0) := (others => '0');
	signal hwacc_readdata				: std_logic_vector(15 downto 0) := (others => '0');
	signal hwacc_byteenable				: std_logic_vector(1 downto 0) := (others => '0');
--Avalon Master signals (to use them in hw acc)
	signal m_read_n_s						: std_logic;
	signal m_write_n_s					: std_logic;
	signal m_byteenable_n_s              	: std_logic_vector(1 downto 0);
	signal m_address_s                   	: std_logic_vector(29 downto 0);
	signal m_writedata_s                 	: std_logic_vector(15 downto 0);
	signal m_readdata_s                  	: std_logic_vector(15 downto 0);
	signal m_waitrequest_s               	: std_logic;
	signal m_arbiterlock_s				: std_logic;
-- Avalon Slave to Mii
	signal mii_chipselect               : std_logic;
	signal mii_write_n					: std_logic;
	signal mii_byteenable_n             : std_logic_vector(1 downto 0);
	signal mii_address                  : std_logic_vector(2 downto 0);
	signal mii_writedata                : std_logic_vector(15 downto 0);
	signal mii_readdata                 : std_logic_vector(15 downto 0);
-- IRQ vector
	signal tx_irq_n						: std_logic;
	signal rx_irq_n						: std_logic;
-- DMA Interface to packet buffer
   signal  Dma_Req						: std_logic;
   signal  Dma_Rw						: std_logic;
   signal  Dma_Ack                     : std_logic;
   signal  Dma_Addr                    : std_logic_vector(m_address'high downto 1);
   signal  Dma_Dout                    : std_logic_vector(15 downto 0);
   signal  Dma_Din                     : std_logic_vector(15 downto 0);
---- Timer Interface
   signal  Mac_Zeit                    : std_logic_vector(31 downto 0);
-- Mac RMii Signals to Hub
   signal  MacTxEn							: std_logic;
	signal  MacTxDat                   	: std_logic_vector(1 downto 0);
	signal  MacRxDv                   	: std_logic;
	signal  MacRxDat                   	: std_logic_vector(1 downto 0);
--- Mac signal monitor outputs (only valid if avalon master is present!)
	signal Mac_TxOnP 					:  std_logic; --pulse if tx starts
	signal Mac_TxOffP 					:  std_logic; --pulse if tx stops
	signal Mac_CrsDvOnP 				:  std_logic; --pulse if rx starts
	signal Mac_CrsDvOffP 				:  std_logic; --pulse if rx stops (with some delay)
--Hub Signals
	signal  HubTxEn							: std_logic_vector(3 downto 1);
	signal  HubTxDat0							: std_logic_vector(3 downto 1);
	signal  HubTxDat1							: std_logic_vector(3 downto 1);
	signal  HubRxDv							: std_logic_vector(3 downto 1);
	signal  HubRxDat0							: std_logic_vector(3 downto 1);
	signal  HubRxDat1							: std_logic_vector(3 downto 1);
	signal RxPortInt					: integer range 0 to 3; --0 is idle
	signal RxPort						: std_logic_vector(1 downto 0);
--Filter0 Signals
	signal Flt0TxEn							: std_logic;
	signal Flt0TxDat							: std_logic_vector(1 downto 0);
	signal Flt0RxDv							: std_logic;
	signal Flt0RxDat							: std_logic_vector(1 downto 0);
--Filter1 Signals
	signal Flt1TxEn							: std_logic;
	signal Flt1TxDat							: std_logic_vector(1 downto 0);
	signal Flt1RxDv							: std_logic;
	signal Flt1RxDat							: std_logic_vector(1 downto 0);
--Phy0 Signals
	signal Phy0TxEn							: std_logic;
	signal Phy0TxDat							: std_logic_vector(1 downto 0);
	signal Phy0RxDv							: std_logic;
	signal Phy0RxDat							: std_logic_vector(1 downto 0);
--Phy1 Signals
	signal Phy1TxEn							: std_logic;
	signal Phy1TxDat							: std_logic_vector(1 downto 0);
	signal Phy1RxDv							: std_logic;
	signal Phy1RxDat							: std_logic_vector(1 downto 0);
-- Mii Signals
	signal smi_Doei						: std_logic;
begin
	
	rst <= not Reset_n;
	
	the_Mii : entity work.OpenMAC_MII
		port map (  nRst => Reset_n,
					Clk  => Clk50,
				    --Slave IF
					Addr     => mii_address,
					Sel      => mii_chipselect,
					nBe      => mii_byteenable_n,
					nWr      => mii_write_n,
					Data_In  => mii_writedata,
					Data_Out => mii_readdata,
					--Export
					Mii_Clk   => smi_Clk,
					Mii_Di    => smi_Di,
					Mii_Do	  => smi_Do,
					Mii_Doe   => smi_Doei, -- '1' ... Input / '0' ... Output
					nResetOut => phy_nResetOut
				   );	
	smi_Doe <= not smi_Doei;

	the_Mac : entity work.OpenMAC
		generic map (	HighAdr  => Dma_Addr'HIGH,
						Simulate => Simulate,
						Timer    => TRUE,
						TxDel	 => TRUE,
						TxSyncOn => TRUE
					)
		port map	(	nRes => Reset_n,
						Clk  => Clk50,
						--Export
						rRx_Dat  => MacRxDat,
						rCrs_Dv  => MacRxDv,
						rTx_Dat  => MacTxDat,
						rTx_En   => MacTxEn,
						Mac_Zeit => Mac_Zeit,
						--ir
						nTx_Int => tx_irq_n,
						nRx_Int => rx_irq_n,
						-- Slave Interface
						S_nBe    => mac_byteenable_n,
						s_nWr    => mac_write_n,
						Sel_Ram  => mac_chipselect_ram,
						Sel_Cont => mac_chipselect_cont,
						S_Adr    => mac_address(10 downto 1),
						S_Din    => mac_writedata,
						S_Dout   => mac_readdata,
						-- Master Interface
						Dma_Req  => Dma_Req,
						Dma_Rw   => Dma_Rw,
						Dma_Ack  => Dma_Ack,
						Dma_Addr => Dma_Addr,
						Dma_Dout => Dma_Dout,
						Dma_Din  => Dma_Din,
						-- Hub
						Hub_Rx => RxPort
					);
	
	the_HwAcc : entity work.hwacc
		generic map (	
						--enable hardware acceleration at all
						useHwAcc_g					=> useHwAcc_g,
						--slave interface for configuration/status/control
						iSlaveAddrWidth_g			=> s_address'length-1,
						iSlaveDataWidth_g			=> s_writedata'length,
						--master interface
						iMasterAddrWidth_g			=> m_address'length,
						iMasterDataWidth_g			=> m_writedata'length,
						--filter numbers
						iTxFltNum_g					=> iTpdos_g,
						iRxFltNum_g					=> iRpdos_g,
						simulate_g					=> false
					)
		port map	(	
						--
						clk							=> Clk50,
						rst							=> rst,
						--slave interface for configuration/status/control
						s_address					=> hwacc_address,
						s_chipselect				=> hwacc_chipselect,
						s_write						=> hwacc_write,
						s_read						=> hwacc_read,
						s_byteenable				=> hwacc_byteenable,
						s_writedata					=> hwacc_writedata,
						s_readdata					=> hwacc_readdata,
						--master interface to Avalon bus
						bus_read_n					=> m_read_n,
						bus_write_n					=> m_write_n,
						bus_byteenable_n            => m_byteenable_n,
						bus_address                 => m_address,
						bus_writedata               => m_writedata,
						bus_readdata                => m_readdata,
						bus_waitrequest             => m_waitrequest,
						bus_arbiterlock				=> m_arbiterlock,
						--master interface to openMAC
						mac_read_n					=> m_read_n_s,
						mac_write_n					=> m_write_n_s,
						mac_byteenable_n            => m_byteenable_n_s,
						mac_address                 => m_address_s,
						mac_writedata               => m_writedata_s,
						mac_readdata                => m_readdata_s,
						mac_waitrequest             => m_waitrequest_s,
						mac_arbiterlock				=> m_arbiterlock_s,
						--openMAC TX/RX signals
						macTxOnP					=> Mac_TxOnP,
						macTxOffP					=> Mac_TxOffP,
						macRxOnP					=> Mac_CrsDvOnP,
						macRxOffP					=> Mac_CrsDvOffP,
						macTxEn						=> MacTxEn,
						macRxEn						=> MacRxDv,
						--PDI change buffer triggers
						rpdo_change_tog				=> rpdo_change_tog,
						tpdo_change_tog				=> tpdo_change_tog
					);
	
	the_ActivityLed : entity work.phyActGen
		generic map (
				iBlinkFreq_g				=> 6
		)
		port map (
				clk50						=> Clk50,
				arst						=> rst,
				TxEn						=> MacTxEn,
				CrsDv						=> MacRxDv,
				actLed						=> led_activity
		);
	genHub : if use2ndPhy_g generate
		--since two phys are needed, openHUB must be connected to filter0, filter1 and openMAC
		the_Hub : entity work.OpenHub
			generic map (	Ports => 3
			)
			port map 	(
							nRst 				=> 	Reset_n,
							Clk 				=> 	Clk50,
							RxDv 				=> 	HubRxDv,
							RxDat0 			=> 	HubRxDat0,
							RxDat1 			=> 	HubRxDat1,
							TxEn 				=> 	HubTxEn,
							TxDat0 			=> 	HubTxDat0,
							TxDat1 			=> 	HubTxDat1,
							internPort 		=> 	1,
							TransmitMask 	=> 	(others => '1'),
							ReceivePort 	=> 	RxPortInt
			);
		RxPort <= conv_std_logic_vector(RxPortInt, RxPort'length);
		HubRxDv <= Flt1RxDv & Flt0RxDv & MacTxEn;
		HubRxDat1 <= Flt1RxDat(1) & Flt0RxDat(1) & MacTxDat(1);
		HubRxDat0 <= Flt1RxDat(0) & Flt0RxDat(0) & MacTxDat(0);
		Flt1TxEn <= HubTxEn(3);
		Flt0TxEn <= HubTxEn(2);
		MacRxDv <= HubTxEn(1);
		Flt1TxDat(1) <= HubTxDat1(3);
		Flt0TxDat(1) <= HubTxDat1(2);
		MacRxDat(1) <= HubTxDat1(1);
		Flt1TxDat(0) <= HubTxDat0(3);
		Flt0TxDat(0) <= HubTxDat0(2);
		MacRxDat(0) <= HubTxDat0(1);
	end generate;
	
	gen1PhyPort : if not use2ndPhy_g generate
		--since only one phy is needed, directly connect filter0 output with openMAC
		Flt0TxEn <= MacTxEn;
		Flt0TxDat <= MacTxDat;
		MacRxDv <= Flt0RxDv;
		MacRxDat <= Flt0RxDat;
		RxPort <= (others => '0');
	end generate;
	
	the_Filter4Phy0 : entity work.OpenFILTER
		port map	(
						nRst => Reset_n,
						Clk => Clk50,
						nCheckShortFrames => '0',
						RxDvIn => Phy0RxDv,
						RxDatIn => Phy0RxDat,
						RxDvOut => Flt0RxDv,
						RxDatOut => Flt0RxDat,
						TxEnIn => Flt0TxEn,
						TxDatIn => Flt0TxDat,
						TxEnOut => Phy0TxEn,
						TxDatOut => Phy0TxDat
		);
	
	gen2ndFilter : if use2ndPhy_g generate
		the_Filter4Phy1 : entity work.OpenFILTER
			port map	(
							nRst => Reset_n,
							Clk => Clk50,
							nCheckShortFrames => '0',
							RxDvIn => Phy1RxDv,
							RxDatIn => Phy1RxDat,
							RxDvOut => Flt1RxDv,
							RxDatOut => Flt1RxDat,
							TxEnIn => Flt1TxEn,
							TxDatIn => Flt1TxDat,
							TxEnOut => Phy1TxEn,
							TxDatOut =>  Phy1TxDat
			);
	end generate;
	
	genRmii : if useRmii_g generate
		regPhy100Meg : process(ClkEth, Reset_n)
		--latches tx signals to phy with falling edge of 100MHz clk
		begin
			if Reset_n = '0' then
				rTx_En_0 <= '0';
				rTx_Dat_0 <= (others => '0');
				if use2ndPhy_g then
					rTx_En_1 <= '0';
					rTx_Dat_1 <= (others => '0');
				end if;
			elsif ClkEth = '0' and ClkEth'event then
				rTx_En_0 <= Phy0TxEn;
				rTx_Dat_0 <= Phy0TxDat;
				if use2ndPhy_g then
					rTx_En_1 <= Phy1TxEn;
					rTx_Dat_1 <= Phy1TxDat;
				end if;
			end if;
		end process;
		
		regPhy50Meg : process(clk50, Reset_n)
		--latches rx signals from phy with rising edge of 100MHz clk
		begin
			if Reset_n = '0' then
				Phy0RxDv <= '0';
				Phy0RxDat <= (others => '0');
				if use2ndPhy_g then
					Phy1RxDv <= '0';
					Phy1RxDat <= (others => '0');
				end if;
			elsif clk50 = '1' and clk50'event then
				Phy0RxDv <= rCrs_Dv_0;
				Phy0RxDat <= rRx_Dat_0;
				if use2ndPhy_g then
					Phy1RxDv <= rCrs_Dv_1;
					Phy1RxDat <= rRx_Dat_1;
				end if;
			end if;
		end process;
	end generate;
	
	geMii : if not useRmii_g generate
		
		phyMii0_TxEr <= '0';
		theRmii2MiiCnv0 : entity work.rmii2mii
			port map (
				clk50				=> clk50,
				rst					=> rst,
				--RMII (MAC)
				rTxEn				=> Phy0TxEn,
				rTxDat				=> Phy0TxDat,
				rRxDv				=> Phy0RxDv,
				rRxDat				=> Phy0RxDat,
				--MII (PHY)
				mTxEn				=> phyMii0_TxEn,
				mTxDat				=> phyMii0_TxDat,
				mTxClk				=> phyMii0_TxClk,
				mRxDv				=> phyMii0_RxDv,
				mRxEr				=> phyMii0_RxEr,
				mRxDat				=> phyMii0_RxDat,
				mRxClk				=> phyMii0_RxClk
			);
		
		gen2ndRmii2MiiCnv : if use2ndPhy_g generate
			phyMii1_TxEr <= '0';
			theRmii2MiiCnv1 : entity work.rmii2mii
				port map (
					clk50				=> clk50,
					rst					=> rst,
					--RMII (MAC)
					rTxEn				=> Phy1TxEn,
					rTxDat				=> Phy1TxDat,
					rRxDv				=> Phy1RxDv,
					rRxDat				=> Phy1RxDat,
					--MII (PHY)
					mTxEn				=> phyMii1_TxEn,
					mTxDat				=> phyMii1_TxDat,
					mTxClk				=> phyMii1_TxClk,
					mRxDv				=> phyMii1_RxDv,
					mRxEr				=> phyMii1_RxEr,
					mRxDat				=> phyMii1_RxDat,
					mRxClk				=> phyMii1_RxClk
				);
		end generate;
	end generate;
		
	-----------------------------------------------------------------------
	-- Avalon Slave Interface <-> openMac
	-----------------------------------------------------------------------
	s_IRQ <= (not rx_irq_n) or (not tx_irq_n);
	
	the_addressDecoder: block
		signal SelShadow : std_logic;
		signal SelIrqTable : std_logic;
	begin
		
		genHwAccSig : if useHwAcc_g generate
			--HW ACC
			hwacc_chipselect <= s_address(12);
			hwacc_address <= s_address(11 downto 0);
			hwacc_byteenable <= not s_byteenable_n;
			hwacc_write <= not s_write_n;
			hwacc_read <= not s_read_n;
			hwacc_writedata <= s_writedata;
		end generate;
		
		--openMAC & Co
		mac_chipselect_cont <= '1' 	when ( s_chipselect = '1' and s_address(12 downto  9) = "0000" ) 		else '0'; --0000 to 03ff
		mac_chipselect_ram  <= '1' 	when ( s_chipselect = '1' and s_address(12 downto 10) = "001" ) 		else '0'; --0800 to 0fff
		SelShadow <= '1' 			when ( s_chipselect = '1' and s_address(12 downto  9) = "0010" ) 		else '0'; --0800 to 0bff
		mii_chipselect <= '1' 		when ( s_chipselect = '1' and s_address(12 downto  3) = "0100000000" ) 	else '0'; --1000 to 100f
		SelIrqTable <= '1' 			when ( s_chipselect = '1' and s_address(12 downto  3) = "0100000001" ) 	else '0'; --1010 to 101f
	
	
		mac_byteenable_n <= s_byteenable_n(0) & s_byteenable_n(1);
		mac_write_n <= s_write_n;
		mac_address(11 downto 1) <= s_address(10 downto 1) &     s_address(0) when SelShadow = '1' else 
									s_address(10 downto 1) & not s_address(0);
		mac_writedata <= s_writedata(15 downto 8)  & s_writedata(7 downto 0) when s_byteenable_n = "00" else
						 s_writedata(7 downto 0)   & s_writedata(15 downto 8);
		
		
		mii_byteenable_n <= s_byteenable_n;
		mii_write_n <= s_write_n;
		mii_writedata <= s_writedata;
		mii_address <= s_address(2 downto 0);
		
		
		s_readdata <= 	(others => '0') when SelShadow = '1' else --when packet filters are selected
						hwacc_readdata when hwacc_chipselect = '1' else
						mac_readdata(15 downto 8) & mac_readdata(7 downto 0)  when ( ( mac_chipselect_ram = '1' or mac_chipselect_cont = '1') and s_byteenable_n = "00" ) else
						mac_readdata(7 downto 0)  & mac_readdata(15 downto 8) when ( mac_chipselect_ram = '1' or mac_chipselect_cont = '1') else
						mii_readdata when mii_chipselect = '1' else
						x"000" & "00" & (not rx_irq_n) & (not tx_irq_n) when SelIrqTable = '1' else
						(others => '0');
		
	end block the_addressDecoder;
	
	-----------------------------------------------------------------------
	-- openMAC internal packet buffer
	--------------------------------------
	--- PORT A => MAC
	--- PORT B => AVALON BUS
	-----------------------------------------------------------------------
	genPcktbfr : if useIntPacketBuf_g = true and useRxIntPacketBuf_g = true generate
		intPcktbfr: block
			signal Dma_Din_s : std_logic_vector(Dma_Din'range);
			signal Dma_Dout_s : std_logic_vector(Dma_Dout'range);
			signal readA_s, readB_s : std_logic;
			signal writeA_s, writeB_s : std_logic;
		begin
		
		Dma_Din <= Dma_Din_s(7 downto 0) & Dma_Din_s(15 downto 8);
		Dma_Dout_s <= Dma_Dout(7 downto 0) & Dma_Dout(15 downto 8);
		readA_s <= Dma_Req and Dma_Rw;
		readB_s <= not iBuf_read_n and iBuf_chipselect;
		writeA_s <= Dma_Req and not Dma_Rw;
		writeB_s <= not iBuf_write_n and iBuf_chipselect;
		
		genAck : process(Clk50, Reset_n)
		begin
			if Reset_n = '0' then
				Dma_Ack <= '0';
			elsif Clk50 = '1' and Clk50'event then
				if Dma_Req = '1' and Dma_Ack = '0' then
					Dma_Ack <= '1';
				else
					Dma_Ack <= '0';
				end if;
			end if;
		end process genAck;
		
		packetBuffer:	entity	work.OpenMAC_DPRpackets
			generic map(memSizeLOG2_g => iBufSizeLOG2_g,
						memSize_g => iBufSize_g)
			port map
			(	
				address_a => Dma_Addr(iBufSizeLOG2_g-1 downto 1),
				address_b => iBuf_address,
				byteena_a => "11",
				byteena_b => iBuf_byteenable,
				clock_a => Clk50,
				clock_b => ClkFaster,
				data_a => Dma_Dout_s,
				data_b => iBuf_writedata,
				rden_a => readA_s,
				rden_b => readB_s,
				wren_a => writeA_s,
				wren_b => writeB_s,
				q_a => Dma_Din_s,
				q_b => iBuf_readdata
			);
		end block intPcktbfr;
	end generate;
	
	-----------------------------------------------------------------------
	-- openMAC using e.g. external packet buffer
	--------------------------------------
	--- Avalon Master interface
	-----------------------------------------------------------------------
	genAvalonMaster : if useIntPacketBuf_g = false generate
		theAvalonMasterDma : entity work.openMACdmaAvalonMaster
		   generic map (
				dma_addrWidth_g => Dma_Addr'length,
				dma_dataWidth_g => Dma_Din'length,
				m_addrWidth_g => m_address'length,
				m_dataWidth_g => m_readdata'length,
				rxOnly_g => false
		   )
		   port map (
				clk => clk50,
				arst_n => Reset_n,
				Dma_Req => Dma_Req,
				Dma_Rw => Dma_Rw,
				Dma_Ack => Dma_Ack,
				Dma_Addr => Dma_Addr,
				Dma_Din => Dma_Din,
				Dma_Dout => Dma_Dout,
				m_read_n => m_read_n_s,
				m_write_n => m_write_n_s,
				m_byteenable_n => m_byteenable_n_s,
				m_address => m_address_s,
				m_writedata => m_writedata_s,
				m_readdata => m_readdata_s,
				m_waitrequest => m_waitrequest_s,
				m_arbiterlock => m_arbiterlock_s,
				Mac_TxEn => MacTxEn,
				Mac_CrsDv => MacRxDv,
				Mac_TxOnP => Mac_TxOnP,
				Mac_TxOffP => Mac_TxOffP,
				Mac_CrsDvOnP => Mac_CrsDvOnP,
				Mac_CrsDvOffP => Mac_CrsDvOffP
		   );
	end generate;
	
	-----------------------------------------------------------------------
	-- openMAC internal tx packet buffer and Avalon Master for rx buffer
	--------------------------------------
	--- PORT A => MAC
	--- PORT B => AVALON BUS
	--- Avalon Master interface
	-----------------------------------------------------------------------
	genAvalonMasterAndIntPacketBuf : if useIntPacketBuf_g = true and useRxIntPacketBuf_g = false generate
		hybPcktbfr: block
			signal Dma_Din_s : std_logic_vector(Dma_Din'range);
			signal readA_s, readB_s : std_logic;
			signal          writeB_s : std_logic;
			signal Dma_Ack_Tx, Dma_Ack_Rx : std_logic;
		begin
		
		Dma_Ack <= Dma_Ack_Tx or Dma_Ack_Rx;
		
		Dma_Din <= Dma_Din_s(7 downto 0) & Dma_Din_s(15 downto 8);
		
		readA_s <= Dma_Req and Dma_Rw;
		readB_s <= not iBuf_read_n and iBuf_chipselect;
		
		writeB_s <= not iBuf_write_n and iBuf_chipselect;
		
		genAck : process(Clk50, Reset_n)
		begin
			if Reset_n = '0' then
				Dma_Ack_Tx <= '0';
			elsif Clk50 = '1' and Clk50'event then
				if Dma_Req = '1' and Dma_Ack_Tx = '0' and Dma_Rw = '1' then
					Dma_Ack_Tx <= '1';
				else
					Dma_Ack_Tx <= '0';
				end if;
			end if;
		end process genAck;
		
		packetBuffer:	entity	work.OpenMAC_DPRpackets
			generic map(memSizeLOG2_g => iBufSizeLOG2_g,
						memSize_g => iBufSize_g)
			port map
			(	
				address_a => Dma_Addr(iBufSizeLOG2_g-1 downto 1),
				address_b => iBuf_address,
				byteena_a => "11",
				byteena_b => iBuf_byteenable,
				clock_a => Clk50,
				clock_b => ClkFaster,
				data_a => (others => '0'),
				data_b => iBuf_writedata,
				rden_a => readA_s,
				rden_b => readB_s,
				wren_a => '0',
				wren_b => writeB_s,
				q_a => Dma_Din_s,
				q_b => iBuf_readdata
			);
		
		theAvalonMasterDma : entity work.openMACdmaAvalonMaster
		   generic map (
				dma_addrWidth_g => Dma_Addr'length,
				dma_dataWidth_g => Dma_Din'length,
				m_addrWidth_g => m_address'length,
				m_dataWidth_g => m_readdata'length,
				rxOnly_g => true
		   )
		   port map (
				clk => clk50,
				arst_n => Reset_n,
				Dma_Req => Dma_Req,
				Dma_Rw => Dma_Rw,
				Dma_Ack => Dma_Ack_Rx,
				Dma_Addr => Dma_Addr,
				Dma_Din => open, --Tx data is loaded from DPRAM
				Dma_Dout => Dma_Dout,
				m_read_n => m_read_n_s,
				m_write_n => m_write_n_s,
				m_byteenable_n => m_byteenable_n_s,
				m_address => m_address_s,
				m_writedata => m_writedata_s,
				m_readdata => m_readdata_s,
				m_waitrequest => m_waitrequest_s,
				m_arbiterlock => m_arbiterlock_s,
				Mac_TxEn => MacTxEn,
				Mac_CrsDv => MacRxDv,
				Mac_TxOnP => Mac_TxOnP,
				Mac_TxOffP => Mac_TxOffP,
				Mac_CrsDvOnP => Mac_CrsDvOnP,
				Mac_CrsDvOffP => Mac_CrsDvOffP
		   );
		end block hybPcktbfr;
	end generate;
	
	-----------------------------------------------------------------------
	-- MAC-Time compare
	-- Mac Time output
	-----------------------------------------------------------------------
	the_cmpUnit : block
		signal Mac_Cmp_On : std_logic;
		signal Mac_Tog_On : std_logic;
		signal Mac_Cmp_Wert : std_logic_vector(Mac_Zeit'range);
		signal Mac_Cmp_TogVal	: std_logic_vector(Mac_Zeit'range);
		signal Mac_Cmp_Irq : std_logic;
		signal Mac_Cmp_Toggle : std_logic;
	begin
		
		t_IRQ <= Mac_Cmp_Irq;
		t_IrqToggle <= Mac_Cmp_Toggle when use2ndCmpTimer_g = TRUE else '0';
		
		p_MacCmp : process ( Reset_n, Clk50 )
		begin
			if ( Reset_n = '0' ) then
				Mac_Cmp_Irq  <= '0';
				Mac_Cmp_On   <= '0';
				Mac_Tog_On   <= '0';
				Mac_Cmp_Wert <= (others => '0');
				if use2ndCmpTimer_g = TRUE then
					Mac_Cmp_TogVal <= (others => '0');
					Mac_Cmp_Toggle <= '0';
				end if;
				t_readdata <= (others => '0');
			elsif rising_edge( Clk50 ) then
			
				if ( t_chipselect = '1' and t_write_n = '0' ) then
					case t_address is
						when "00" => --0
							Mac_Cmp_Wert <= t_writedata;
							Mac_Cmp_Irq <= '0';
						when "01" => --4
							Mac_Cmp_On <= t_writedata(0);
							Mac_Tog_On <= t_writedata(4);
						when "10" => --8
							if use2ndCmpTimer_g = TRUE then
								Mac_Cmp_TogVal <= t_writedata;
							end if;
						when others =>
							-- do nothing
					end case;
				end if;

				if ( Mac_Cmp_On = '1' and Mac_Cmp_Wert( Mac_Zeit'range ) = Mac_Zeit ) then
					Mac_Cmp_Irq <= '1';
				end if;
				
				if ( Mac_Tog_On = '1' and Mac_Cmp_TogVal( Mac_Zeit'range ) = Mac_Zeit  and use2ndCmpTimer_g = TRUE ) then
					Mac_Cmp_Toggle <= not Mac_Cmp_Toggle;
				end if;
				
				if ( t_chipselect = '1' and t_read_n = '0' ) then
					case t_address is
						when "00" => --0
							t_readdata <= Mac_Zeit(31 downto 0);
						when "01" => --4
							if use2ndCmpTimer_g = TRUE then
								t_readdata <= x"000000" & "00" & Mac_Cmp_Toggle & Mac_Tog_On & "00" & Mac_Cmp_Irq & Mac_Cmp_On;
							end if;
						when "10" => --8
							if use2ndCmpTimer_g = TRUE then
								t_readdata <= Mac_Cmp_TogVal;
							end if;
						when others =>
							t_readdata <= (others => '0');
					end case;
				end if;

			end if;
		end process p_MacCmp;
		
	end block the_cmpUnit;

end architecture struct;

-----------------------------
--openMAC DMA Avalon Master--
-----------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity openMACdmaAvalonMaster is
   generic(
		--
		--
		dma_addrWidth_g : integer := 32;
		dma_dataWidth_g : integer := 16;
		--
		m_addrWidth_g : integer := 32;
		m_dataWidth_g : integer := 16;
		--
		rxOnly_g : boolean := true
   );
   port (
		--clock and reset same as for Dma
		clk : in std_logic;
		arst_n : in std_logic;
		--Dma signals
		Dma_Req : in std_logic;
		Dma_Rw : in std_logic;
		Dma_Ack : out std_logic;
		Dma_Addr : in std_logic_vector(dma_addrWidth_g-1 downto 0);
		Dma_Din : out std_logic_vector(dma_dataWidth_g-1 downto 0);
		Dma_Dout : in std_logic_vector(dma_dataWidth_g-1 downto 0);
		--Avalon Memory Mapped Master signals
		m_read_n : out std_logic;
		m_write_n : out std_logic;
		m_byteenable_n : out std_logic_vector(m_datawidth_g/8-1 downto 0);
		m_address : out std_logic_vector(m_addrwidth_g-1 downto 0);
		m_writedata : out std_logic_vector(m_datawidth_g-1 downto 0);
		m_readdata : in std_logic_vector(m_datawidth_g-1 downto 0);
		m_waitrequest : in std_logic;
		m_arbiterlock : out std_logic;
		--Mac signals to monitor
		Mac_TxEn : in std_logic;
		Mac_CrsDv : in std_logic;
		---output mac signal monitors
		Mac_TxOnP : out std_logic; --pulse if tx starts
		Mac_TxOffP : out std_logic; --pulse if tx stops
		Mac_CrsDvOnP : out std_logic; --pulse if rx starts
		Mac_CrsDvOffP : out std_logic --pulse if rx stops
   );
end entity openMACdmaAvalonMaster;

architecture rtl of openMACdmaAvalonMaster is
	--------------------------------------------------------------
	--F S M
	type fsm_t is (idle, transfer, finish);
	signal txFsm, rxFsm : fsm_t;
	signal txFsmRst, rxFsmRst : std_logic;
	--
	signal arst : std_logic;
	--Dma
	signal Dma_Ack_s : std_logic;
	--Avalon Memory Mapped Master
	signal m_read : std_logic;
	signal m_write : std_logic;
	signal m_byteenable : std_logic_vector(m_byteenable_n'range);
	--Mac
	signal Mac_TxEnL : std_logic;
	signal Mac_TxOnP_s : std_logic; --pulse if tx starts
	signal Mac_TxOffP_s : std_logic; --pulse if tx stops
	signal Mac_CrsDvFilter : std_logic_vector(11 downto 0);
	signal Mac_CrsDvOnP_s : std_logic; --pulse if rx starts
	signal Mac_CrsDvOffP_s : std_logic; --pulse if rx stops
	--
	--address generator
	signal m_addrBase_tx : std_logic_vector(m_addrwidth_g-1 downto 0); --initial address of transfer
	signal m_addrBase_rx : std_logic_vector(m_addrwidth_g-1 downto 0); --initial address of transfer
	signal m_addrOffset_tx : std_logic_vector(m_addrwidth_g-1 downto 0); --offset address, inc during transfer
	signal m_addrOffset_rx : std_logic_vector(m_addrwidth_g-1 downto 0); --offset address, inc during transfer
	--FIFO control
	---TX
	signal  TXFifo_Clr		:  std_logic;
	signal  TXFifo_Rd		:  std_logic;
	signal  TXFifo_Wr		:  std_logic;
	signal  TXFifo_AE		:  std_logic;
	signal  TXFifo_AF		:  std_logic;
	signal  TXFifo_E		:  std_logic;
	signal  TXFifo_F		:  std_logic;
	---RX
	signal  RXFifo_Clr		:  std_logic;
	signal  RXFifo_Rd		:  std_logic;
	signal  RXFifo_Wr		:  std_logic;
	signal  RXFifo_AE		:  std_logic;
	signal  RXFifo_AF		:  std_logic;
	signal  RXFifo_E		:  std_logic;
	signal  RXFifo_F		:  std_logic;
	signal	RXFifo_FirstRd	:  std_logic;
	signal	RXFifo_FirstRd_p:  std_logic;
	--------------------------------------------------------------
begin
	
	--high active signals are used internal
	arst <= not arst_n;
	m_read_n <= not m_read;
	m_write_n <= not m_write;
	m_byteenable_n <= not m_byteenable;
	
	--generate latched Mac signals
	Mac_TxOnP <= Mac_TxOnP_s;
	Mac_TxOffP <= Mac_TxOffP_s;
	Mac_CrsDvOnP <= Mac_CrsDvOnP_s;
	Mac_CrsDvOffP <= Mac_CrsDvOffP_s;
	
	macLatchProc : process(clk, arst)
	begin
		if arst = '1' then
			Mac_TxEnL <= '0';
			Mac_CrsDvFilter <= (others => '0');
			Mac_TxOnP_s <= '0';
			Mac_TxOffP_s <= '0';
			Mac_CrsDvOnP_s <= '0';
			Mac_CrsDvOffP_s <= '0';
		elsif clk = '1' and clk'event then
			--default
			Mac_TxOnP_s <= '0';
			Mac_TxOffP_s <= '0';
			Mac_CrsDvOnP_s <= '0';
			Mac_CrsDvOffP_s <= '0';
			
			--register
			Mac_TxEnL <= Mac_TxEn;
			
			--shift register
			Mac_CrsDvFilter <= Mac_CrsDvFilter(Mac_CrsDvFilter'left-1 downto 0) & Mac_CrsDv;
			
			--pulse generation
			if Mac_TxEnL = '0' and Mac_TxEn = '1' then
				Mac_TxOnP_s <= '1';
			end if;
			
			if Mac_TxEnL = '1' and Mac_TxEn = '0' then
				Mac_TxOffP_s <= '1';
			end if;
			
			if Mac_CrsDvFilter = x"003" then
				Mac_CrsDvOnP_s <= '1';
			end if;
			
			if Mac_CrsDvFilter = x"800" then
				Mac_CrsDvOffP_s <= '1';
			end if;
		end if;
	end process macLatchProc;
	
	--------------------------------------------------------------
	--FSM
	--------------------------------------------------------------
	genTxFsm : if rxOnly_g = false generate
		txFsmProc : process(clk, arst)
		begin
			if arst = '1' then
				txFsm <= idle;
				m_addrBase_tx <= (others => '0');
			elsif clk = '1' and clk'event then
				case txFsm is
					when idle =>
					--default
						txFsm <= idle;
					--dma transfer for tx is started by assertion of Dma_Req and Dma_Rw
						if Dma_Req = '1' and Dma_Rw = '1' then
						--the first req sets the base address of the transfer
							m_addrBase_tx <= Dma_Addr & '0';
							txFsm <= transfer; --exit to transfer
						end if;
						
					when transfer =>
					--default
						txFsm <= transfer;
					--the transfer is surely over if Mac_TxEn is deasserted
						if Mac_TxOffP_s = '1' then
							txFsm <= finish;
						end if;
						
					when finish =>
					--default
						txFsm <= finish;
						if txFsmRst = '1' then
							txFsm <= idle;
						end if;
						
				end case;
			end if;
		end process txFsmProc;
	end generate;
	
	genTxFsmStub : if rxOnly_g = true generate
		--tx data is provided by other source
		txFsm <= idle;
	end generate;
		
	rxFsmProc : process(clk, arst)
	begin
		if arst = '1' then
			rxFsm <= idle;
			m_addrBase_rx <= (others => '0');
		elsif clk = '1' and clk'event then
			case rxFsm is
				when idle =>
				--default
					rxFsm <= idle;
				--dma transfer for rx is started by assertion of Dma_Req only
					if Dma_Req = '1' and Dma_Rw = '0' then
					--the first req sets the base address of the transfer
						m_addrBase_rx <= Dma_Addr & '0';
						rxFsm <= transfer; --exit to transfer
					end if;
					
				when transfer =>
				--default
					rxFsm <= transfer;
				--the transfer is surely over if Mac_CrsDv is deasserted ("1000..0")
					if Mac_CrsDvOffP_s = '1' then
						rxFsm <= finish;
					end if;
					
				when finish =>
				--default
					rxFsm <= finish;
					if rxFsmRst = '1' then
						rxFsm <= idle;
					end if;
					
			end case;
		end if;
	end process rxFsmProc;
	
	--------------------------------------------------------------
	--Transfer handling
	--------------------------------------------------------------
	theAddrCalcer : block
		signal add_base : std_logic_vector(m_addrBase_tx'range);
		signal add_offs : std_logic_vector(m_addrOffset_tx'range);
		signal add_resu : std_logic_vector(m_address'range);
	begin
		--forward base addend to the adder
		add_base <=		m_addrBase_tx when m_read = '1' and rxOnly_g = false else
						m_addrBase_rx when m_write = '1' else
						(others => '0');
		--forward offset addend to the adder
		add_offs <=		m_addrOffset_tx when m_read = '1' and rxOnly_g = false else
						m_addrOffset_rx when m_write = '1' else
						(others => '0');
		
		--adder
		add_resu <= 	add_base + add_offs;
		
		--forward result
		m_address <= 	add_resu;
		
	end block theAddrCalcer;
	
	m_byteenable <= 	(others => '1') when m_read = '1' or m_write = '1' else
						(others => '0');
	
	Dma_Ack <= Dma_Ack_s;
	
	--arbitration lock if master writes or reads
	m_arbiterlock <= m_write or m_read;
	
	--do Fifo Read concurrent => read data is available by assertion of Avalon transfer signals
	RXFifo_Rd <= 	'1' when RXFifo_FirstRd_p = '1' else --first read to get first value
					'1' when m_write = '1' and m_waitrequest = '0' else --read during transfer
					'0';
	
	theTrHdlProc : process(clk, arst)
	begin
		if arst = '1' then
			m_read <= '0';
			m_write <= '0';
			
			TXFifo_Wr <= '0'; RXFifo_Wr <= '0';
			TXFifo_Rd <= '0';
			TXFifo_Clr <= '0'; RXFifo_Clr <= '0';
			RXFifo_FirstRd <= '0'; RXFifo_FirstRd_p <= '0';
			Dma_Ack_s <= '0';
			txFsmRst <= '0'; rxFsmRst <= '0';
			
			m_addrOffset_tx <= (others => '0'); m_addrOffset_rx <= (others => '0');
		elsif clk = '1' and clk'event then
			--default
			TXFifo_Wr <= '0'; RXFifo_Wr <= '0';
			TXFifo_Rd <= '0';
			TXFifo_Clr <= '0'; RXFifo_Clr <= '0';
			Dma_Ack_s <= '0';
			txFsmRst <= '0'; rxFsmRst <= '0';
			RXFifo_FirstRd_p <= '0';
			
			--Dma control
			if Dma_Req = '1' and Dma_Rw = '1' and TXFifo_E = '0' and Dma_Ack_s = '0' and rxOnly_g = false then
				--read from TX fifo
				TXFifo_Rd <= '1';
				Dma_Ack_s <= '1';
			elsif Dma_Req = '1' and Dma_Rw = '0' and RXFifo_F = '0' and Dma_Ack_s = '0' then
				--write to RX fifo
				RXFifo_Wr <= '1';
				Dma_Ack_s <= '1';
			end if;
			
			--Avalon Master control
			if m_write = '1' and m_waitrequest = '0' then
				--write was successful -> read from rx fifo
				m_addrOffset_rx <= m_addrOffset_rx + 2;
			elsif m_read = '1' and m_waitrequest = '0' and rxOnly_g = false then
				--read was successful -> write to tx fifo
				TXFifo_Wr <= '1';
				m_addrOffset_tx <= m_addrOffset_tx + 2;
			end if;
			
			--TX
			if txFsm = transfer and rxOnly_g = false then
				--fsm is in transfer state -> fill fifo to almost full
				if TXFifo_AE = '1' and m_read = '0' and m_write = '0' then
					--fifo is almost empty -> start read
					m_read <= '1';
				elsif TXFifo_AF = '1' and m_read = '1' and m_waitrequest = '0' then
					--fifo is almost full -> stop read if waitrequest is deasserted
					m_read <= '0';
				end if;
			elsif txFsm = finish and rxOnly_g = false then
				--fsm is in finish state -> clear fifo
				TXFifo_Clr <= '1';
				--if there is a write to the fifo, dump it
				TXFifo_Wr <= '0';
				if m_read = '1' and m_waitrequest = '0' then
					m_read <= '0';
				end if;
				if TXFifo_E = '1' and m_read = '0' then
					--reset fsm only if last read was done successfully (don't fool Avalon...)
					txFsmRst <= '1';
					m_addrOffset_tx <= (others => '0');
				end if;
			end if;
			
			--RX
			if rxFsm = transfer then
				--fsm is in transfer state -> empty the fifo to almost empty
				--only start write if tx fsm is in idle
				if RXFifo_AE = '0' and txFsm = idle then
					m_write <= '1';
				elsif m_write = '1' and m_waitrequest = '0' then
					m_write <= '0';
				end if;
				
				--fifo does not watch ahead -> read to get valid value
				if RXFifo_FirstRd = '0' and RXFifo_E = '0' then
					RXFifo_FirstRd <= '1'; --rst of RXFifo_FirstRd is done in finish state
					RXFifo_FirstRd_p <= '1'; --set a pulse
				end if;
			elsif rxFsm = finish then
				--fsm is in finish state -> empty the fifo
				if RXFifo_E = '0' and txFsm = idle then
					m_write <= '1';
				elsif m_write = '1' and m_waitrequest = '0' then
					m_write <= '0';
				end if;
				if RXFifo_E = '1' and m_write = '0' then
					--reset fsm only if last write was done successfully (don't fool Avalon...)
					rxFsmRst <= '1';
					m_addrOffset_rx <= (others => '0');
					RXFifo_FirstRd <= '0';
				end if;
			end if;
			
		end if;
	end process theTrHdlProc;
	
	--------------------------------------------------------------
	--TX Fifo and RX Fifo
	--------------------------------------------------------------
	theFifos : block
		signal m_readdata_s : std_logic_vector(m_readdata'range);
		signal Dma_Dout_s : std_logic_vector(Dma_Dout'range);
	begin
		
		latchTxReadData : process(clk, arst) --take data that is provided at waitrequest = 0
		begin
			if arst = '1' then
				m_readdata_s <= (others => '0');
			elsif clk = '1' and clk'event then
				m_readdata_s <= m_readdata(7 downto 0) & m_readdata(15 downto 8);
			end if;
		end process;
		
		Dma_Dout_s <= Dma_Dout(7 downto 0) & Dma_Dout(15 downto 8);
		
		theTxFifo : block
			signal usedw : std_logic_vector(3 downto 0);
		begin
			genTxFifo: if rxOnly_g = false generate
				the_TxFifo : entity work.OpenMAC_DMAFifo
				generic map (	log2words_g	 =>	usedw'length
							)
				port map	(	aclr     	 => arst,
								clock	 	 => clk,
								data	 	 => m_readdata_s,
								rdreq	 	 => TXFifo_Rd,
								sclr	 	 => TXFifo_Clr,
								wrreq	 	 => TXFifo_Wr,
								usedw		 => usedw,
								empty		 => TXFifo_E,
								full		 => TXFifo_F,
								q			 => Dma_Din
							);
			end generate;
			
			TXFifo_AE <= '1' when usedw < conv_std_logic_vector(4, usedw'length) else '0';
			TXFifo_AF <= '1' when usedw > conv_std_logic_vector(14, usedw'length) else '0';
			
		end block theTxFifo;
		
		theRxFifo : block
			signal usedw : std_logic_vector(3 downto 0);
		begin
			the_RxFifo : entity work.OpenMAC_DMAFifo
			generic map (	log2words_g	 =>	usedw'length
						)
			port map	(	aclr     	 => arst,
							clock	 	 => clk,
							data	 	 => Dma_Dout_s,
							rdreq	 	 => RXFifo_Rd,
							sclr	 	 => RXFifo_Clr,
							wrreq	 	 => RXFifo_Wr,
							usedw		 => usedw,
							empty		 => RXFifo_E,
							full		 => RXFifo_F,
							q			 => m_writedata
						);
			
			RXFifo_AE <= '1' when usedw < conv_std_logic_vector(2, usedw'length) else '0';
			RXFifo_AF <= '1' when usedw > conv_std_logic_vector(14, usedw'length) else '0';
			
		end block theRxFifo;
	end block theFifos;
	
end architecture rtl;

--------------------------
--phy activity generator--
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

entity phyActGen is
	generic (
			iBlinkFreq_g				:		integer := 50 --in Hz
	);
	port (
			clk50						: in	std_logic;
			arst						: in	std_logic;
			TxEn						: in	std_logic;
			CrsDv						: in	std_logic;
			actLed						: out	std_logic
	);
end entity phyActGen;

architecture rtl of phyActGen is
constant 	iMaxCnt 					: integer := 50e6 / iBlinkFreq_g;
constant	iLog2MaxCnt					: integer := integer(ceil(log2(real(iMaxCnt))));

signal		cnt							: std_logic_vector(iLog2MaxCnt-1 downto 0);
signal		cnt_tc						: std_logic;
signal		actTrig						: std_logic;
signal		actEnable					: std_logic;

begin
	
	actLed <= cnt(cnt'high) when actEnable = '1' else '0';
	
	ledCntr : process(clk50, arst)
	begin
		if arst = '1' then
			actTrig <= '0';
			actEnable <= '0';
		elsif clk50 = '1' and clk50'event then
			--monoflop, of course no default value!
			if actTrig = '1' and cnt_tc = '1' then
				--counter overflow and activity within last cycle
				actEnable <= '1';
			elsif cnt_tc = '1' then
				--counter overflow but no activity
				actEnable <= '0';
			end if;
			
			--monoflop, of course no default value!
			if cnt_tc = '1' then
				--count cycle over, reset trigger
				actTrig <= '0';
			elsif TxEn = '1' or CrsDv = '1' then
				--activity within cycle
				actTrig <= '1';
			end if;
		end if;
	end process;
	
	theFreeRunCnt : process(clk50, arst)
	begin
		if arst = '1' then
			cnt <= (others => '0');
		elsif clk50 = '1' and clk50'event then
			--nice, it may count for ever!
			cnt <= cnt - 1;
		end if;
	end process;
	
	cnt_tc <= '1' when cnt = 0 else '0'; --"counter overflow"
	
end architecture rtl;

--------------------------
--HW ACC                --
--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity hwacc is
	generic (
			--enable hardware acceleration at all
			useHwAcc_g					:		boolean := false;
			--slave interface for configuration/status/control
			iSlaveAddrWidth_g			: 		integer := 12;
			iSlaveDataWidth_g			: 		integer := 16;
			--master interface
			iMasterAddrWidth_g			:		integer := 32;
			iMasterDataWidth_g			:		integer := 16;
			--filter numbers
			iTxFltNum_g					: 		integer := 1;
			iRxFltNum_g					:		integer := 3;
			simulate_g					:		boolean := false
	);
	port (
			clk							: in	std_logic;
			rst							: in 	std_logic;
			--slave interface for configuration/status/control
			s_address					: in	std_logic_vector(iSlaveAddrWidth_g-1 downto 0);
			s_chipselect				: in 	std_logic;
			s_write						: in	std_logic;
			s_read						: in	std_logic;
			s_byteenable				: in	std_logic_vector(iSlaveDataWidth_g/8-1 downto 0);
			s_writedata					: in	std_logic_vector(iSlaveDataWidth_g-1 downto 0);
			s_readdata					: out	std_logic_vector(iSlaveDataWidth_g-1 downto 0);
			--master interface to Avalon bus
            bus_read_n					: out   std_logic;
            bus_write_n					: out   std_logic;
            bus_byteenable_n            : out   std_logic_vector(iMasterDataWidth_g/8-1 downto 0);
            bus_address                 : out   std_logic_vector(iMasterAddrWidth_g-1 downto 0);
            bus_writedata               : out   std_logic_vector(iMasterDataWidth_g-1 downto 0);
            bus_readdata                : in    std_logic_vector(iMasterDataWidth_g-1 downto 0);
            bus_waitrequest             : in    std_logic;
            bus_arbiterlock				: out   std_logic;
			--master interface to openMAC
			mac_read_n					: in   	std_logic;
			mac_write_n					: in   	std_logic;
			mac_byteenable_n            : in   	std_logic_vector(iMasterDataWidth_g/8-1 downto 0);
			mac_address                 : in   	std_logic_vector(iMasterAddrWidth_g-1 downto 0);
			mac_writedata               : in   	std_logic_vector(iMasterDataWidth_g-1 downto 0);
			mac_readdata                : out  	std_logic_vector(iMasterDataWidth_g-1 downto 0);
			mac_waitrequest             : out  	std_logic;
			mac_arbiterlock				: in   	std_logic;
			--openMAC TX/RX signals
			macTxOnP					: in 	std_logic;
			macTxOffP					: in 	std_logic;
			macRxOnP					: in 	std_logic;
			macRxOffP					: in	std_logic;
			macTxEn						: in	std_logic;
			macRxEn						: in	std_logic;
			--PDI change buffer triggers
			rpdo_change_tog				: out	std_logic_vector(2 downto 0);
			tpdo_change_tog				: out	std_logic
	);
end entity hwacc;

architecture rtl of hwacc is
--signal to work with m_blablabla
signal		m_read						:		std_logic;
alias		m_read_n					:		std_logic is mac_read_n;
signal		m_write						:		std_logic;
alias		m_write_n					:		std_logic is mac_write_n;
signal		m_writedata					:		std_logic_vector(mac_writedata'range);
signal		m_readdata					:		std_logic_vector(bus_readdata'range);
alias		m_waitrequest				:		std_logic is bus_waitrequest;
--status / control register
constant	magic_c						:		std_logic_vector(15 downto 0) := x"C0FE";
---vv
alias		s_addr_range				:		std_logic_vector(5 downto 3) is s_address(2 downto 0);
constant	control_base_c				:		std_logic_vector(s_addr_range'range) := "000"; --0x0000
constant	tx0_flt_base_16c			:		std_logic_vector(15 downto 0) := x"0010"; --0x0010
alias		tx0_flt_base_c				:		std_logic_vector(s_addr_range'range) is tx0_flt_base_16c(6 downto 4);
constant	rx0_flt_base_16c			:		std_logic_vector(15 downto 0) := x"0020"; --0x0020
alias		rx0_flt_base_c				:		std_logic_vector(s_addr_range'range) is rx0_flt_base_16c(6 downto 4);
constant	rx1_flt_base_16c			:		std_logic_vector(15 downto 0) := x"0030"; --0x0030
alias		rx1_flt_base_c				:		std_logic_vector(s_addr_range'range) is rx1_flt_base_16c(6 downto 4);
constant	rx2_flt_base_16c			:		std_logic_vector(15 downto 0) := x"0040"; --0x0040
alias		rx2_flt_base_c				:		std_logic_vector(s_addr_range'range) is rx2_flt_base_16c(6 downto 4);
---^^
signal		enable						:		std_logic;
signal		eth_msg_type				:		std_logic_vector(15 downto 0);
---control register
signal 		control_reg					:		std_logic_vector(15 downto 0) := (others => '0');
alias		control_reg_en				:		std_logic is control_reg(15);

--filter
---
type filter_t is
	record
		enable							:		std_logic;
		word0							:		std_logic_vector(15 downto 0);
		word1							:		std_logic_vector(15 downto 0);
		pdo_base						:		std_logic_vector(31 downto 0);
	end record;
---
type rxFilter_t is array (iRxFltNum_g downto 1) of filter_t;
type txFilter_t is array (iTxFltNum_g downto 1) of filter_t;
---
signal txFlt_reg						:		txFilter_t;
signal rxFlt_reg						:		rxFilter_t;

---
constant	iFilter_eth_msg_offset_c	:		integer := 12; --in byte
constant	iFilter_word0_offset_c		:		integer := 14; --in byte
constant	iFilter_word1_offset_c		:		integer := 16; --in byte

--
constant	iPdosize_offset_c			:		integer := 22; --in byte
constant	iPdobase_offset_c			:		integer := 24; --in byte

begin
	
		bus_writedata <= mac_writedata;
		bus_byteenable_n <= mac_byteenable_n;
	
	--if hardware acceleration should not be used
	genNoHwAcc : if not useHwAcc_g generate
		bus_address <= mac_address;
		bus_read_n <= mac_read_n;
		bus_write_n <= mac_write_n;
		mac_waitrequest <= bus_waitrequest;
		bus_arbiterlock <= mac_arbiterlock;
		mac_readdata <= bus_readdata;
	end generate;
	
	--okay, you may accelerate!
	genHwAcc : if useHwAcc_g generate
		
		--I like high active signals...
		m_write <= not m_write_n;
		m_read <= not m_read_n;
		
		--and hw acc likes the big endian style, easy...
		m_writedata <= mac_writedata(7 downto 0) & mac_writedata(15 downto 8);
		m_readdata <= bus_readdata(7 downto 0) & bus_readdata(15 downto 8);
		
		--the following block does the hw acc
		theHwAcc : block
			--counter for frame and transfers by hw acc
			signal frame_cnt, frame_cnt_next : std_logic_vector(9 downto 0); --0 to 1024 words
			signal transfer_cnt, transfer_cnt_next, transfer_cnt_max : std_logic_vector(9 downto 0); --0 to 1024 words
			
			--filter matching
			---
			type filterMatch_t is (init, no_match, match);
			type rxFilterMatch_t is array (iRxFltNum_g downto 1) of filterMatch_t;
			type txFilterMatch_t is array (iTxFltNum_g downto 1) of filterMatch_t;
			---
			signal rxFltMatch : rxFilterMatch_t;
			signal txFltMatch : txFilterMatch_t;
			---signal represents the filter number that matches
			signal txFlt_match : std_logic_vector(1 downto 0); --0 no match
			signal rxFlt_match : std_logic_vector(1 downto 0); --0 no match
			
			--frame states, derived from frame counter
			type frameState_t is (idle, flt_eth_msg_type, flt_word0, flt_word1, pdo_size, pdo, padding);
			signal frameState : frameState_t;
			
			--decides which source/sink is selected
			type dev_t is (pktBuf, pdiBuf, padding);
			signal transferLink : dev_t;
			
			--padding after fast link transfer
			signal padding_ack : std_logic;
			
			--signal for filter capturing (TX data is taken one cyle after dma_ack!!!)
			signal cap_rx_data, cap_tx_data : std_logic;
			
			--generated addresses to pdo
			signal gen_address : std_logic_vector(bus_address'range);
			
		begin
			
			--the smart enable control
			-- if sw does enable/disable during activity, logic gets in trouble!
			-- => enable/disable is only done if crsdv or txen are ZERO!!!
			theSmartEnableControl : process(clk, rst)
			begin
				if rst = '1' then
					enable <= '0';
					if simulate_g then
						enable <= '1';
					end if;
				elsif clk = '1' and clk'event then
					if macTxEn = '0' and macRxEn = '0' then
						--no activity, so we may do!
						if control_reg_en = '1' then
							enable <= '1';
						else
							enable <= '0';
						end if;
					end if; --activity?
				end if; --clk
			end process;
			
			--the MUX logic
			---mux addresses depending on transfer link
			bus_address <= 	mac_address when transferLink = pktBuf else
							gen_address when transferLink = pdiBuf else
							(others => '0');
			
			---in case of padding zeros are written into MAC
			mac_readdata <= bus_readdata when transferLink /= padding else
							(others => '0');
			
			---kill arbiterlock if we do padding (unload avalon)
			bus_arbiterlock <= mac_arbiterlock when transferLink = pktBuf else
							mac_arbiterlock when transferLink = pdiBuf else
							'0'; --if we do padding, no bus read is done
			
			---kill bus read if we do padding (unload avalon)
			bus_read_n <= 	mac_read_n when transferLink = pktBuf else
							mac_read_n when transferLink = pdiBuf else
							'1'; --if we do padding, no bus read is done
			
			---kill bus write if we do padding (unload avalon)
			bus_write_n <= 	mac_write_n when transferLink = pktBuf else
							mac_write_n when transferLink = pdiBuf else
							'1'; --if we do padding, no bus read is done
			
			---kill wait request if we do padding (fifo is filled with zeros (tx) or emptied (rx))
			mac_waitrequest <= bus_waitrequest when transferLink = pktBuf else
							bus_waitrequest when transferLink = pdiBuf else
							'0'; --if we do padding fifo assums to have very fast bus access :)
			
			---we may generate the correct address for pdi, take base and add offset generated by transfer counter!
			theAddrAdder : block
				--inputs must be initialized, since they may not be sourced completely!
				signal ina, inb : std_logic_vector(bus_address'range) := (others => '0');
				signal addOut : std_logic_vector(bus_address'range);
			begin
				--one input is sourced by the transfer counter (it counts the words!!!)
				ina(transfer_cnt'range) <= transfer_cnt;
				
				--the second buddy is sourced by a constant (in bytes!!!)
				inb <= 		txFlt_reg(1).pdo_base(bus_address'range) when txFlt_match = "01" and iTxFltNum_g > 0 else
							--add tx filters here
							rxFlt_reg(1).pdo_base(bus_address'range) when rxFlt_match = "01" and iRxFltNum_g > 0 else
							rxFlt_reg(2).pdo_base(bus_address'range) when rxFlt_match = "10" and iRxFltNum_g > 1 else
							rxFlt_reg(3).pdo_base(bus_address'range) when rxFlt_match = "11" and iRxFltNum_g > 2 else
							--add rx filter here
							(others => '0'); --if there is no match, the source/sink is not the pdi...
				
				--let's do calculation in bytes world! 
				addOut <= (ina(ina'left-1 downto ina'right) & '0') + inb;
				
				--hm, now forward the address
				gen_address <= addOut;
			end block;
			
			transferLink <= pdibuf when frameState = pdo and enable = '1' else
							padding when frameState = padding and enable = '1' else
							pktBuf;
			
			--frame and transfer counters
			theCounters : process(clk, rst)
			begin
				if rst = '1' then
					frame_cnt <= (others => '0');
					transfer_cnt <= (others => '0');
				elsif clk = '1' and clk'event then
					if enable = '1' then
						frame_cnt <= frame_cnt_next;
						transfer_cnt <= transfer_cnt_next;
					end if;
				end if;
			end process;
			
			--capture of data / trigger of frame-/transfer-counter
			-- rx: only set if reception is active (mac_rx_en), otherwise it would fool the logic!
			-- tx: set in any case if data is present
			cap_rx_data <= '1' when m_write = '1' and m_waitrequest = '0' and macRxEn = '1' else '0';
			cap_tx_data <= '1' when m_read = '1' and m_waitrequest = '0' else '0';
			
			frame_cnt_next <= 		frame_cnt + 1 when (cap_rx_data = '1' or cap_tx_data = '1') and transferLink /= padding else
									(others => '0') when macTxOffP = '1' or macRxOffP = '1' else
									frame_cnt; --stay if no ack is done
			
			transfer_cnt_next <= 	transfer_cnt + 1 when (cap_rx_data = '1' or cap_tx_data = '1') and frameState = pdo else
									--transfer_cnt_max when frameState = pdo_size else
									(others => '0') when macTxOffP = '1' or macRxOffP = '1' or frameState = pdo_size else
									transfer_cnt; --stay if no ack or no load
			
			theSuperAdder : block --is adding 1 to the payload, to transferre word aligned
				signal inadd, sum : std_logic_vector(transfer_cnt_max'range);
				signal storeIt : std_logic;
			begin
				sum <= inadd + 1;
				
				storeIt <=	'1' when cap_tx_data = '1' and frameState = pdo_size else
							'1' when cap_rx_data = '1' and frameState = pdo_size else
							'0';
				
				inadd <= 	bus_readdata(inadd'range) when cap_tx_data = '1' and frameState = pdo_size else
							mac_writedata(inadd'range) when cap_rx_data = '1' and frameState = pdo_size else
							(others => '0');
				
				--the load value is written to a register, to hold it along the transfer
				process(clk, rst)
				begin
					if rst = '1' then
						transfer_cnt_max <= (others => '0');
					elsif clk = '1' and clk'event then
						if storeIt = '1' then
							transfer_cnt_max <= '0' & sum(sum'left downto sum'right+1);
						end if;
					end if;
				end process;
				
			end block;
			
			--the frame states
			frameState <= 	flt_eth_msg_type 	when frame_cnt = iFilter_eth_msg_offset_c / 2 else
							flt_word0 			when frame_cnt = iFilter_word0_offset_c / 2 else
							flt_word1 			when frame_cnt = iFilter_word1_offset_c / 2 else
							pdo_size 			when frame_cnt = iPdosize_offset_c / 2 else
							pdo 				when frame_cnt >= iPdobase_offset_c / 2 and transfer_cnt /= transfer_cnt_max and 
													(txFlt_match /= 0 or rxFlt_match /= 0) else
							padding				when frame_cnt >= iPdobase_offset_c / 2 and 
													(txFlt_match /= 0 or rxFlt_match /= 0) else
							idle;
			
			--the tpdo and rpdo changer
			thePdoChanger : block
				signal wasTransferLink : dev_t;
				signal rpdo_change_tog_s : std_logic_vector(rpdo_change_tog'range);
				signal tpdo_change_tog_s : std_logic;
			begin
				tpdo_change_tog <= tpdo_change_tog_s;
				rpdo_change_tog <= rpdo_change_tog_s;
				
				process(clk, rst)
				begin
					if rst = '1' then
						tpdo_change_tog_s <= '0';
						rpdo_change_tog_s <= (others => '0');
						wasTransferLink <= pktBuf;
					elsif clk = '1' and clk'event then
						wasTransferLink <= transferLink; --shift register
						
						--now, lets find out if the transfer link changed!
						if wasTransferLink /= transferLink then
							--okay, there is a change, but which one!?
							if macRxEn = '1' and rxFlt_match /= 0 then
								--rx: change buffer after pdi transfer
								if wasTransferLink = pdiBuf then
									--now, change the right rpdo!
									rpdo_change_tog_s(conv_integer(rxFlt_match)-1) <=
										not rpdo_change_tog_s(conv_integer(rxFlt_match)-1);
								else
									--get a c0fe, no buffer change required!
								end if;
							elsif macTxEn = '1' and txFlt_match /= 0 then
								--tx: change buffer before pdi transfer
								if transferLink = pdiBuf then
									--now, change the right tpdo!
									tpdo_change_tog_s <= not tpdo_change_tog_s;
								else
									--get a c0fe, no buffer change required!
								end if;
							else
								--no latch, since it is clocked...
							end if;
						end if;
						
					end if;
				end process;
			end block;
			
			--the filter logic
			process(clk, rst)
			begin
				if rst = '1' then
					for i in rxFltMatch'range loop
						rxFltMatch(i) <= init;
					end loop;
					
					for i in txFltMatch'range loop
						txFltMatch(i) <= init;
					end loop;
					
					--txFlt_match <= (others => '0');
					--rxFlt_match <= (others => '0');
				elsif clk = '1' and clk'event then
					if enable = '1' then
						--the end of tx/rx will reset matching of filters
						if macTxOffP = '1' then
							for i in txFltMatch'range loop
								txFltMatch(i) <= init;
							end loop;
							--txFlt_match <= (others => '0');
						elsif macRxOffP = '1' then
							for i in rxFltMatch'range loop
								rxFltMatch(i) <= init;
							end loop;
							--rxFlt_match <= (others => '0');
						end if;
						
						--check if ethMsgType matches
						if frameState = flt_eth_msg_type then
							if cap_tx_data = '1' then
								for i in txFltMatch'range loop
									--is filter enabled?
									if txFlt_reg(i).enable = '1' then
										--compare dma_din with pattern
										if m_readdata = eth_msg_type then
											txFltMatch(i) <= match;
										else
											txFltMatch(i) <= no_match;
										end if;
									else
										txFltMatch(i) <= no_match;
									end if;
								end loop;
							elsif cap_rx_data = '1' then
								for i in rxFltMatch'range loop
									--is filter enabled?
									if rxFlt_reg(i).enable = '1' then
										--compare dma_dout with pattern
										if m_writedata = eth_msg_type then
											rxFltMatch(i) <= match;
										else
											rxFltMatch(i) <= no_match;
										end if;
									else
										rxFltMatch(i) <= no_match;
									end if;
								end loop;
							end if;
						
						--check if word0 matches
						elsif frameState = flt_word0 then
							if cap_tx_data = '1' then
								for i in txFltMatch'range loop
									--is filter enabled?
									if txFlt_reg(i).enable = '1' then
										--compare dma_din with pattern
										if m_readdata = txFlt_reg(i).word0 and txFltMatch(i) = match then
											txFltMatch(i) <= match;
										else
											txFltMatch(i) <= no_match;
										end if;
									else
										txFltMatch(i) <= no_match;
									end if;
								end loop;
							elsif cap_rx_data = '1' then
								for i in rxFltMatch'range loop
									--is filter enabled?
									if rxFlt_reg(i).enable = '1' then
										--compare dma_dout with pattern
										if m_writedata = rxFlt_reg(i).word0 and rxFltMatch(i) = match then
											rxFltMatch(i) <= match;
										else
											rxFltMatch(i) <= no_match;
										end if;
									else
										rxFltMatch(i) <= no_match;
									end if;
								end loop;
							end if;
							
						--check if word1 matches
						elsif frameState = flt_word1 then
							if cap_tx_data = '1' then
								for i in txFltMatch'range loop
									--is filter enabled?
									if txFlt_reg(i).enable = '1' then
										--compare dma_din with pattern
										if m_readdata = txFlt_reg(i).word1 and txFltMatch(i) = match then
											txFltMatch(i) <= match;
											--txFlt_match <= conv_std_logic_vector(i, txFlt_match'length);
										else
											txFltMatch(i) <= no_match;
										end if;
									else
										txFltMatch(i) <= no_match;
									end if;
								end loop;
							elsif cap_rx_data = '1' then
								for i in rxFltMatch'range loop
									--is filter enabled?
									if rxFlt_reg(i).enable = '1' then
										--compare dma_dout with pattern
										if m_writedata = rxFlt_reg(i).word1 and rxFltMatch(i) = match then
											rxFltMatch(i) <= match;
											--rxFlt_match <= conv_std_logic_vector(i, rxFlt_match'length);
										else
											rxFltMatch(i) <= no_match;
										end if;
									else
										rxFltMatch(i) <= no_match;
									end if;
								end loop;
							end if; --capture?
							
						end if; --frameState
							
					end if; --enable
				end if; --clk
			end process;
			
			--let's set the filter match number
			process(rxFltMatch, txFltMatch)
			begin
				--caution: this is NOT a clocked process => avoid latches!!!
				
				--observe all rx filters, maybe one is matching!?
				rxFlt_match <= (others => '0');
				for i in rxFltMatch'range loop
					--we don't bother if enabled or not, it's done in process above!
					if rxFltMatch(i) = match then
						rxFlt_match <= conv_std_logic_vector(i, rxFlt_match'length);
					end if;
				end loop;
				
				--observe all tx filters, maybe one is matching!?
				txFlt_match <= (others => '0');
				for i in txFltMatch'range loop
					--we don't bother if enabled or not, it's done in process above!
					if txFltMatch(i) = match then
						txFlt_match <= conv_std_logic_vector(i, txFlt_match'length);
					end if;
				end loop;
				
			end process;
			
		end block theHwAcc;
		
		--the following block does the memory mapping between Avalon slave (Nios II PCP) and the hw acc
		theSwHwIf : block
			--
			signal sel_control_reg 	: std_logic;
			signal read_control_reg : std_logic_vector(s_readdata'range);
			---
			type txFltRead_t is array (1 downto 1) of std_logic_vector(15 downto 0);
			type rxFltRead_t is array (3 downto 1) of std_logic_vector(15 downto 0);
			----
			signal sel_txFlt		: std_logic_vector(1 downto 1);
			signal read_txFlt		: txFltRead_t;
			signal sel_rxFlt		: std_logic_vector(3 downto 1);
			signal read_rxFlt		: rxFltRead_t;
		begin
			
			--address decoder
			sel_control_reg <= s_chipselect when s_address(control_base_c'range) = control_base_c else '0';
			
			sel_txFlt(1) <= s_chipselect when s_address(tx0_flt_base_c'range) = tx0_flt_base_c else '0';
			
			sel_rxFlt(1) <= s_chipselect when s_address(rx0_flt_base_c'range) = rx0_flt_base_c else '0';
			sel_rxFlt(2) <= s_chipselect when s_address(rx1_flt_base_c'range) = rx1_flt_base_c else '0';
			sel_rxFlt(3) <= s_chipselect when s_address(rx2_flt_base_c'range) = rx2_flt_base_c else '0';
			
			--read registers
			s_readdata <= 	read_control_reg when sel_control_reg = '1' else
							read_txFlt(1) when sel_txFlt(1) = '1' and iTxFltNum_g > 0 else
							--add additional tx filters if present
							read_rxFlt(1) when sel_rxFlt(1) = '1' and iRxFltNum_g > 0 else
							read_rxFlt(2) when sel_rxFlt(2) = '1' and iRxFltNum_g > 1 else
							read_rxFlt(3) when sel_rxFlt(3) = '1' and iRxFltNum_g > 2 else
							--add additional rx filters if present
							(others => '0');
							
			
			with s_addr_range select
				read_control_reg <= 	
					magic_c				when "000",
					control_reg			when "001",
					eth_msg_type		when "010",
					(others => '0')		when others;
			
			genTxFltReg : for i in sel_txFlt'range generate
				genTxFltRegII : if iTxFltNum_g >= i generate
					with s_addr_range select
						read_txFlt(i) <= 	
							(read_txFlt(i)'left => txFlt_reg(i).enable, others => '0')
													when "000",
							txFlt_reg(i).word0		when "001",
							txFlt_reg(i).word1		when "010",
							--reserved				when "011",
							txFlt_reg(i).pdo_base(15 downto 0)
													when "100",
							txFlt_reg(i).pdo_base(31 downto 16)
													when "101",
							(others => '0')			when others;
				end generate;
			end generate;
			
			genRxFltReg : for i in sel_rxFlt'range generate
				genRxFltRegII : if iRxFltNum_g >= i generate
					with s_addr_range select
						read_rxFlt(i) <= 	
							(read_rxFlt(i)'left => rxFlt_reg(i).enable, others => '0')
													when "000",
							rxFlt_reg(i).word0		when "001",
							rxFlt_reg(i).word1		when "010",
							--reserved				when "011",
							rxFlt_reg(i).pdo_base(15 downto 0)
													when "100",
							rxFlt_reg(i).pdo_base(31 downto 16)
													when "101",
							(others => '0')			when others;
				end generate;
			end generate;
			
			--write registers
			--todo: add byteenable consideration!
			process(clk, rst)
			begin
				if rst = '1' then
					eth_msg_type <= (others => '0');
					control_reg_en <= '0';
					--
					for i in txFlt_reg'range loop
						txFlt_reg(i).enable <= '0';
						txFlt_reg(i).word0 <= (others => '0');
						txFlt_reg(i).word1 <= (others => '0');
					end loop;
					--
					for i in rxFlt_reg'range loop
						rxFlt_reg(i).enable <= '0';
						rxFlt_reg(i).word0 <= (others => '0');
						rxFlt_reg(i).word1 <= (others => '0');
					end loop;
					
					if simulate_g then
						for i in txFlt_reg'range loop
							txFlt_reg(i).enable <= '1';
						end loop;
						for i in rxFlt_reg'range loop
							rxFlt_reg(i).enable <= '1';
						end loop;
						rxFlt_reg(1).word0 <= x"1000";
						rxFlt_reg(2).word0 <= x"1000";
						--rxFlt_reg(3).word0 <= x"1000";
						--rxFlt_reg(1).word1 <= x"1000";
						rxFlt_reg(2).word1 <= x"1000";
						rxFlt_reg(3).word1 <= x"1000";
						rxFlt_reg(1).pdo_base <= x"beef0000";
						rxFlt_reg(2).pdo_base <= x"c0de0000";
						rxFlt_reg(3).pdo_base <= x"c0fe0000";
						eth_msg_type <= x"1000";
						control_reg_en <= '1';
					end if;
					
				elsif clk = '1' and clk'event then
					if s_write = '1' then
						if sel_control_reg = '1' then
							case s_addr_range is
								when "001" =>
									control_reg_en <= s_writedata(15);
								when "010" =>
									eth_msg_type <= s_writedata;
								when others =>
							end case;
						end if;
						
						for i in txFlt_reg'range loop
							if sel_txFlt(i) = '1' then
								case s_addr_range is
									when "000" =>
										txFlt_reg(i).enable <= s_writedata(15);
									when "001" =>
										txFlt_reg(i).word0 <= s_writedata;
									when "010" =>
										txFlt_reg(i).word1 <= s_writedata;
									--when "011" =>
									when "100" =>
										txFlt_reg(i).pdo_base(15 downto 0) <= s_writedata;
									when "101" =>
										txFlt_reg(i).pdo_base(31 downto 16) <= s_writedata;
									when others =>
								end case;
							end if;
						end loop;
						
						for i in rxFlt_reg'range loop
							if sel_rxFlt(i) = '1' then
								case s_addr_range is
									when "000" =>
										rxFlt_reg(i).enable <= s_writedata(15);
									when "001" =>
										rxFlt_reg(i).word0 <= s_writedata;
									when "010" =>
										rxFlt_reg(i).word1 <= s_writedata;
									--when "011" =>
									when "100" =>
										rxFlt_reg(i).pdo_base(15 downto 0) <= s_writedata;
									when "101" =>
										rxFlt_reg(i).pdo_base(31 downto 16) <= s_writedata;
									when others =>
								end case;
							end if;
						end loop;
					end if; --s_write
				end if; --clk
			end process;
			
		end block theSwHwIf;
		
	end generate;
	
end architecture rtl;
