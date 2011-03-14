------------------------------------------------------------------------------------------------------------------------
-- Avalon Interface of OpenMAC to use with NIOSII
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
			useRxIntPacketBuf_g			:		boolean := true);
   port (   Reset_n						: in    std_logic;
			Clk50                  		: in    std_logic;
			ClkFaster					: in	std_logic;
			ClkEth						: in	std_logic;
		-- Avalon Slave Interface 
            s_chipselect                : in    std_logic;
            s_read_n					: in    std_logic;
            s_write_n					: in    std_logic;
            s_byteenable_n              : in    std_logic_vector(1 downto 0);
            s_address                   : in    std_logic_vector(11 downto 0);
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
            iBuf_readdata               : out   std_logic_vector(31 downto 0);
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
            rTx_Dat_1                   : out   std_logic_vector(1 downto 0);  -- RMII Tx Daten
            rTx_En_1                    : out   std_logic;                     -- RMII Tx_Enable
		--- MII PORTS
			phyMii0_RxClk				: in	std_logic;
			phyMii0_RxDat               : in    std_logic_vector(3 downto 0);
			phyMii0_RxDv                : in    std_logic;
			phyMii0_TxClk				: in	std_logic;
			phyMii0_TxDat               : out   std_logic_vector(3 downto 0);
			phyMii0_TxEn                : out   std_logic;
			phyMii0_TxEr                : out   std_logic;
			phyMii1_RxClk				: in	std_logic;
			phyMii1_RxDat               : in    std_logic_vector(3 downto 0);
			phyMii1_RxDv                : in    std_logic;
			phyMii1_TxClk				: in	std_logic;
			phyMii1_TxDat               : out   std_logic_vector(3 downto 0);
			phyMii1_TxEn                : out   std_logic;
			phyMii1_TxEr                : out   std_logic;
--		-- Serial Management Interface (the_Mii)	
			smi_Clk						: out	std_logic;
			smi_Di						: in	std_logic;
			smi_Do						: out	std_logic;
			smi_Doe						: out	std_logic;
			phy_nResetOut				: out	std_logic
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
-- DMA Interface  
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
	
	genRmii : if useRmii_g generate
		regPhy100Meg : process(ClkEth, Reset_n)
		--latches tx signals to phy with falling edge of 100MHz clk
		begin
			if Reset_n = '0' then
				rTx_En_0 <= '0';
				rTx_Dat_0 <= (others => '0');
				rTx_En_1 <= '0';
				rTx_Dat_1 <= (others => '0');
			elsif ClkEth = '0' and ClkEth'event then
				rTx_En_0 <= Phy0TxEn;
				rTx_Dat_0 <= Phy0TxDat;
				rTx_En_1 <= Phy1TxEn;
				rTx_Dat_1 <= Phy1TxDat;
			end if;
		end process;
		
		regPhy50Meg : process(clk50, Reset_n)
		--latches rx signals from phy with rising edge of 100MHz clk
		begin
			if Reset_n = '0' then
				Phy0RxDv <= '0';
				Phy0RxDat <= (others => '0');
				Phy1RxDv <= '0';
				Phy1RxDat <= (others => '0');
			elsif clk50 = '1' and clk50'event then
				Phy0RxDv <= rCrs_Dv_0;
				Phy0RxDat <= rRx_Dat_0;
				Phy1RxDv <= rCrs_Dv_1;
				Phy1RxDat <= rRx_Dat_1;
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
				mRxDat				=> phyMii0_RxDat,
				mRxClk				=> phyMii0_RxClk
			);
		
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
				mRxDat				=> phyMii1_RxDat,
				mRxClk				=> phyMii1_RxClk
			);
	end generate;
		
	-----------------------------------------------------------------------
	-- Avalon Slave Interface <-> openMac
	-----------------------------------------------------------------------
	s_IRQ <= (not rx_irq_n) or (not tx_irq_n);
	
	the_addressDecoder: block
		signal SelShadow : std_logic;
		signal SelIrqTable : std_logic;
	begin
		
		mac_chipselect_cont <= '1' 	when ( s_chipselect = '1' and s_address(11 downto  9) = "000" ) 		else '0'; --0000 to 03ff
		mac_chipselect_ram  <= '1' 	when ( s_chipselect = '1' and s_address(11 downto 10) = "01" ) 			else '0'; --0800 to 0fff
		SelShadow <= '1' 			when ( s_chipselect = '1' and s_address(11 downto  9) = "010" ) 		else '0'; --0800 to 0bff
		mii_chipselect <= '1' 		when ( s_chipselect = '1' and s_address(11 downto  3) = "100000000" ) 	else '0'; --1000 to 100f
		SelIrqTable <= '1' 			when ( s_chipselect = '1' and s_address(11 downto  3) = "100000001" ) 	else '0'; --1010 to 101f
	
	
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
				m_read_n => m_read_n,
				m_write_n => m_write_n,
				m_byteenable_n => m_byteenable_n,
				m_address => m_address,
				m_writedata => m_writedata,
				m_readdata => m_readdata,
				m_waitrequest => m_waitrequest,
				m_arbiterlock => m_arbiterlock,
				Mac_TxEn => MacTxEn,
				Mac_CrsDv => MacRxDv
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
				m_read_n => m_read_n,
				m_write_n => m_write_n,
				m_byteenable_n => m_byteenable_n,
				m_address => m_address,
				m_writedata => m_writedata,
				m_readdata => m_readdata,
				m_waitrequest => m_waitrequest,
				m_arbiterlock => m_arbiterlock,
				Mac_TxEn => MacTxEn,
				Mac_CrsDv => MacRxDv
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
		t_IrqToggle <= Mac_Cmp_Toggle;
		
		p_MacCmp : process ( Reset_n, Clk50 )
		begin
			if ( Reset_n = '0' ) then
				Mac_Cmp_Irq  <= '0';
				Mac_Cmp_On   <= '0';
				Mac_Tog_On   <= '0';
				Mac_Cmp_Wert <= (others => '0');
				Mac_Cmp_TogVal <= (others => '0');
				Mac_Cmp_Toggle <= '0';
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
							Mac_Cmp_TogVal <= t_writedata;
						when others =>
							-- do nothing
					end case;
				end if;

				if ( Mac_Cmp_On = '1' and Mac_Cmp_Wert( Mac_Zeit'range ) = Mac_Zeit ) then
					Mac_Cmp_Irq <= '1';
				end if;
				
				if ( Mac_Tog_On = '1' and Mac_Cmp_TogVal( Mac_Zeit'range ) = Mac_Zeit ) then
					Mac_Cmp_Toggle <= not Mac_Cmp_Toggle;
				end if;
				
				if ( t_chipselect = '1' and t_read_n = '0' ) then
					case t_address is
						when "00" => --0
							t_readdata <= Mac_Zeit(31 downto 0);
						when "01" => --4
							t_readdata <= x"000000" & "00" & Mac_Cmp_Toggle & Mac_Tog_On & "00" & Mac_Cmp_Irq & Mac_Cmp_On;
						when "10" => --8
							t_readdata <= Mac_Cmp_TogVal;
						when others =>
							t_readdata <= (others => '0');
					end case;
				end if;

			end if;
		end process p_MacCmp;
		
	end block the_cmpUnit;

end architecture struct;

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
		Mac_CrsDv : in std_logic
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
	signal Mac_TxOnP : std_logic; --pulse if tx starts
	signal Mac_TxOffP : std_logic; --pulse if tx stops
	signal Mac_CrsDvFilter : std_logic_vector(15 downto 0);
	signal Mac_CrsDvOnP : std_logic; --pulse if rx starts
	signal Mac_CrsDvOffP : std_logic; --pulse if rx stops
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
	--------------------------------------------------------------
begin
	
	--high active signals are used internal
	arst <= not arst_n;
	m_read_n <= not m_read;
	m_write_n <= not m_write;
	m_byteenable_n <= not m_byteenable;
	
	--generate latched Mac signals
	macLatchProc : process(clk, arst)
	begin
		if arst = '1' then
			Mac_TxEnL <= Mac_TxEn;
			Mac_CrsDvFilter <= (others => Mac_CrsDv);
			Mac_TxOnP <= '0';
			Mac_TxOffP <= '0';
			Mac_CrsDvOnP <= '0';
			Mac_CrsDvOffP <= '0';
		elsif clk = '1' and clk'event then
			--default
			Mac_TxOnP <= '0';
			Mac_TxOffP <= '0';
			Mac_CrsDvOnP <= '0';
			Mac_CrsDvOffP <= '0';
			
			--register
			Mac_TxEnL <= Mac_TxEn;
			
			--shift register
			Mac_CrsDvFilter <= Mac_CrsDvFilter(Mac_CrsDvFilter'left-1 downto 0) & Mac_CrsDv;
			
			--pulse generation
			if Mac_TxEnL = '0' and Mac_TxEn = '1' then
				Mac_TxOnP <= '1';
			end if;
			
			if Mac_TxEnL = '1' and Mac_TxEn = '0' then
				Mac_TxOffP <= '1';
			end if;
			
			if Mac_CrsDvFilter = x"0003" then --"0000000000000011"
				Mac_CrsDvOnP <= '1';
			end if;
			
			if Mac_CrsDvFilter = x"8000" then --"1000000000000000"
				Mac_CrsDvOffP <= '1';
			end if;
		end if;
	end process macLatchProc;
	
	--------------------------------------------------------------
	--FSM
	--------------------------------------------------------------
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
					if Mac_TxOffP = '1' then
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
					if Mac_CrsDvOffP = '1' then
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
	m_address <=		m_addrBase_tx + m_addrOffset_tx when m_read = '1' and rxOnly_g = false else
						m_addrBase_rx + m_addrOffset_rx when m_write = '1' else
						(others => '0');
	
	m_byteenable <= 	(others => '1') when m_read = '1' or m_write = '1' else
						(others => '0');
	
	Dma_Ack <= Dma_Ack_s;
	
	--arbitration lock if master writes or reads
	m_arbiterlock <= m_write or m_read;
	
	theTrHdlProc : process(clk, arst)
	begin
		if arst = '1' then
			m_read <= '0';
			m_write <= '0';
			
			TXFifo_Wr <= '0'; RXFifo_Wr <= '0';
			TXFifo_Rd <= '0'; RXFifo_Rd <= '0';
			TXFifo_Clr <= '0'; RXFifo_Clr <= '0';
			RXFifo_FirstRd <= '0';
			Dma_Ack_s <= '0';
			txFsmRst <= '0'; rxFsmRst <= '0';
			
			m_addrOffset_tx <= (others => '0'); m_addrOffset_rx <= (others => '0');
		elsif clk = '1' and clk'event then
			--default
			TXFifo_Wr <= '0'; RXFifo_Wr <= '0';
			TXFifo_Rd <= '0'; RXFifo_Rd <= '0';
			TXFifo_Clr <= '0'; RXFifo_Clr <= '0';
			Dma_Ack_s <= '0';
			txFsmRst <= '0'; rxFsmRst <= '0';
			
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
				RXFifo_Rd <= '1';
				m_addrOffset_rx <= m_addrOffset_rx + 2;
			elsif m_read = '1' and m_waitrequest = '0' and rxOnly_g = false then
				--read was successful -> write to tx fifo
				TXFifo_Wr <= '1';
				m_addrOffset_tx <= m_addrOffset_tx + 2;
			end if;
			
			--TX
			if txFsm = transfer and rxOnly_g = false then
				--fsm is in transfer state -> fill fifo to almost full
				--only start read if no write is pending
				if TXFifo_AF = '0' and m_write = '0' then
					m_read <= '1';
				elsif m_read = '1' and m_waitrequest = '0' then
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
				--only start write if no read is pending
				if RXFifo_AE = '0' and m_read = '0' then
					m_write <= '1';
				elsif m_write = '1' and m_waitrequest = '0' then
					m_write <= '0';
				end if;
				
				--fifo does not watch ahead -> read to get valid value
				if RXFifo_FirstRd = '0' and RXFifo_E = '0' then
					RXFifo_Rd <= '1';
					RXFifo_FirstRd <= '1'; --rst of RXFifo_FirstRd is done in finish state
				end if;
			elsif rxFsm = finish then
				--fsm is in finish state -> empty the fifo
				if RXFifo_E = '0' and m_read = '0' then
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
		
		m_readdata_s <= m_readdata(7 downto 0) & m_readdata(15 downto 8);
		Dma_Dout_s <= Dma_Dout(7 downto 0) & Dma_Dout(15 downto 8);
		
		genTxFifo: if rxOnly_g = false generate
			the_TxFifo : entity work.OpenMAC_DMAFifo
			port map	(	aclr     	 => arst,
							clock	 	 => clk,
							data	 	 => m_readdata_s,
							rdreq	 	 => TXFifo_Rd,
							sclr	 	 => TXFifo_Clr,
							wrreq	 	 => TXFifo_Wr,
							almost_empty => TXFifo_AE,
							almost_full	 => TXFifo_AF,
							empty		 => TXFifo_E,
							full		 => TXFifo_F,
							q			 => Dma_Din
						);
		end generate;
		
		the_RxFifo : entity work.OpenMAC_DMAFifo
		port map	(	aclr     	 => arst,
						clock	 	 => clk,
						data	 	 => Dma_Dout_s,
						rdreq	 	 => RXFifo_Rd,
						sclr	 	 => RXFifo_Clr,
						wrreq	 	 => RXFifo_Wr,
						almost_empty => RXFifo_AE,
						almost_full	 => RXFifo_AF,
						empty		 => RXFifo_E,
						full		 => RXFifo_F,
						q			 => m_writedata
					);
	end block theFifos;
	
end architecture rtl;
