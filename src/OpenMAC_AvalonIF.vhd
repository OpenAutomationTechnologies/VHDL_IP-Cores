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
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY AlteraOpenMACIF IS
   GENERIC( Simulate                    : 		boolean := false;
   			iBufSize_g					: 		integer := 1024;
   			iBufSizeLOG2_g				: 		integer := 10;
			useRmii_g					: 		boolean := true);
   PORT (   Reset_n						: IN    STD_LOGIC;
			Clk50                  		: IN    STD_LOGIC;
			ClkFaster					: IN	STD_LOGIC;
			ClkEth						: IN	STD_LOGIC;
		-- Avalon Slave Interface 
            s_chipselect                : IN    STD_LOGIC;
            s_read_n					: IN    STD_LOGIC;
            s_write_n					: IN    STD_LOGIC;
            s_byteenable_n              : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            s_address                   : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            s_writedata                 : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_readdata                  : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_IRQ						: OUT 	STD_LOGIC;
		-- Avalon Slave Interface to cmp unit 
            t_chipselect                : IN    STD_LOGIC;
            t_read_n					: IN    STD_LOGIC;
            t_write_n					: IN    STD_LOGIC;
            t_byteenable_n              : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            t_address                   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            t_writedata                 : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            t_readdata                  : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            t_IRQ						: OUT 	STD_LOGIC;
			t_IrqToggle					: OUT	STD_LOGIC;
        -- Avalon Slave Interface to packet buffer dpr
			iBuf_chipselect             : IN    STD_LOGIC;
            iBuf_read_n					: IN    STD_LOGIC;
            iBuf_write_n				: IN    STD_LOGIC;
            iBuf_byteenable             : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            iBuf_address                : IN    STD_LOGIC_VECTOR(iBufSizeLOG2_g-3 DOWNTO 0);
            iBuf_writedata              : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            iBuf_readdata               : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- RMII Port 0
            rRx_Dat_0                   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Rx Daten
            rCrs_Dv_0                   : IN    STD_LOGIC;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_0                   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Tx Daten
            rTx_En_0                    : OUT   STD_LOGIC;                     -- RMII Tx_Enable
		-- RMII Port 1
            rRx_Dat_1                   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Rx Daten
            rCrs_Dv_1                   : IN    STD_LOGIC;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_1                   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Tx Daten
            rTx_En_1                    : OUT   STD_LOGIC;                     -- RMII Tx_Enable
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
			mii_Clk						: OUT	STD_LOGIC;
			mii_Di						: IN	STD_LOGIC;
			mii_Do						: OUT	STD_LOGIC;
			mii_Doe						: OUT	STD_LOGIC;
			mii_nResetOut				: OUT	STD_LOGIC
        );
END ENTITY AlteraOpenMACIF;

ARCHITECTURE struct OF AlteraOpenMACIF IS
	signal rst							: std_logic;
-- Avalon Slave to openMAC
	SIGNAL mac_chipselect_ram           : STD_LOGIC;
	SIGNAL mac_chipselect_cont          : STD_LOGIC;
	SIGNAL mac_write_n					: STD_LOGIC;
	SIGNAL mac_byteenable_n             : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mac_address                  : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL mac_writedata                : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL mac_readdata                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- Avalon Slave to Mii
	SIGNAL mii_chipselect               : STD_LOGIC;
	SIGNAL mii_write_n					: STD_LOGIC;
	SIGNAL mii_byteenable_n             : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mii_address                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mii_writedata                : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL mii_readdata                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- IRQ vector
	SIGNAL tx_irq_n						: STD_LOGIC;
	SIGNAL rx_irq_n						: STD_LOGIC;
-- DMA Interface  
   SIGNAL  Dma_Req						: STD_LOGIC;
   SIGNAL  Dma_Rw						: STD_LOGIC;
   SIGNAL  Dma_Ack                     : STD_LOGIC;
   SIGNAL  Dma_Addr                    : STD_LOGIC_VECTOR(31 DOWNTO 1);
   SIGNAL  Dma_Dout                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL  Dma_Din                     : STD_LOGIC_VECTOR(15 DOWNTO 0);
---- Timer Interface
   SIGNAL  Mac_Zeit                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- Mac RMii Signals to Hub
   SIGNAL  MacTxEn							: STD_LOGIC;
	SIGNAL  MacTxDat                   	: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  MacRxDv                   	: STD_LOGIC;
	SIGNAL  MacRxDat                   	: STD_LOGIC_VECTOR(1 DOWNTO 0);
--Hub Signals
	SIGNAL  HubTxEn							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL  HubTxDat0							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL  HubTxDat1							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL  HubRxDv							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL  HubRxDat0							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL  HubRxDat1							: STD_LOGIC_VECTOR(3 DOWNTO 1);
	SIGNAL RxPortInt					: integer RANGE 0 TO 3; --0 is idle
	SIGNAL RxPort						: STD_LOGIC_VECTOR(1 downto 0);
--Filter0 Signals
	SIGNAL Flt0TxEn							: STD_LOGIC;
	SIGNAL Flt0TxDat							: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL Flt0RxDv							: STD_LOGIC;
	SIGNAL Flt0RxDat							: STD_LOGIC_VECTOR(1 downto 0);
--Filter1 Signals
	SIGNAL Flt1TxEn							: STD_LOGIC;
	SIGNAL Flt1TxDat							: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL Flt1RxDv							: STD_LOGIC;
	SIGNAL Flt1RxDat							: STD_LOGIC_VECTOR(1 downto 0);
--Phy0 Signals
	SIGNAL Phy0TxEn							: STD_LOGIC;
	SIGNAL Phy0TxDat							: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL Phy0RxDv							: STD_LOGIC;
	SIGNAL Phy0RxDat							: STD_LOGIC_VECTOR(1 downto 0);
--Phy1 Signals
	SIGNAL Phy1TxEn							: STD_LOGIC;
	SIGNAL Phy1TxDat							: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL Phy1RxDv							: STD_LOGIC;
	SIGNAL Phy1RxDat							: STD_LOGIC_VECTOR(1 downto 0);
-- Mii Signals
	SIGNAL mii_Doei						: STD_LOGIC;
BEGIN
	
	rst <= not Reset_n;
	
	the_Mii : ENTITY work.OpenMAC_MII
		PORT MAP (  nRst => Reset_n,
					Clk  => Clk50,
				    --Slave IF
					Addr     => mii_address,
					Sel      => mii_chipselect,
					nBe      => mii_byteenable_n,
					nWr      => mii_write_n,
					Data_In  => mii_writedata,
					Data_Out => mii_readdata,
					--Export
					Mii_Clk   => mii_Clk,
					Mii_Di    => mii_Di,
					Mii_Do	  => mii_Do,
					Mii_Doe   => mii_Doei, -- '1' ... Input / '0' ... Output
					nResetOut => mii_nResetOut
				   );	
	mii_Doe <= not mii_Doei;

	the_Mac : ENTITY work.OpenMAC
		GENERIC MAP (	HighAdr  => Dma_Addr'HIGH,
						Simulate => Simulate,
						Timer    => TRUE,
						TxDel	 => TRUE,
						TxSyncOn => TRUE
					)
		PORT MAP	(	nRes => Reset_n,
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
						S_Adr    => mac_address(10 DOWNTO 1),
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
	
	the_addressDecoder: BLOCK
		SIGNAL SelShadow : STD_LOGIC;
		SIGNAL SelIrqTable : STD_LOGIC;
	BEGIN
		
		mac_chipselect_cont <= '1' 	WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  9) = "000" ) 		ELSE '0'; --0000 to 03ff
		mac_chipselect_ram  <= '1' 	WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO 10) = "01" ) 			ELSE '0'; --0800 to 0fff
		SelShadow <= '1' 			WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  9) = "010" ) 		ELSE '0'; --0800 to 0bff
		mii_chipselect <= '1' 		WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  3) = "100000000" ) 	ELSE '0'; --1000 to 100f
		SelIrqTable <= '1' 			WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  3) = "100000001" ) 	ELSE '0'; --1010 to 101f
	
	
		mac_byteenable_n <= s_byteenable_n(0) & s_byteenable_n(1);
		mac_write_n <= s_write_n;
		mac_address(11 DOWNTO 1) <= s_address(10 DOWNTO 1) &     s_address(0) WHEN SelShadow = '1' ELSE 
									s_address(10 DOWNTO 1) & NOT s_address(0);
		mac_writedata <= s_writedata(15 DOWNTO 8)  & s_writedata(7 DOWNTO 0) WHEN s_byteenable_n = "00" ELSE
						 s_writedata(7 DOWNTO 0)   & s_writedata(15 DOWNTO 8);
		
		
		mii_byteenable_n <= s_byteenable_n;
		mii_write_n <= s_write_n;
		mii_writedata <= s_writedata;
		mii_address <= s_address(2 DOWNTO 0);
		
		
		s_readdata <= 	x"ADDE" WHEN SelShadow = '1' ELSE --when packet filters are selected
						mac_readdata(15 DOWNTO 8) & mac_readdata(7 DOWNTO 0)  WHEN ( ( mac_chipselect_ram = '1' OR mac_chipselect_cont = '1') AND s_byteenable_n = "00" ) ELSE
						mac_readdata(7 DOWNTO 0)  & mac_readdata(15 DOWNTO 8) WHEN ( mac_chipselect_ram = '1' OR mac_chipselect_cont = '1') ELSE
						mii_readdata WHEN mii_chipselect = '1' ELSE
						x"000" & "00" & (not rx_irq_n) & (not tx_irq_n) WHEN SelIrqTable = '1' ELSE
						(others => '0');
		
	END BLOCK the_addressDecoder;
	
	-----------------------------------------------------------------------
	-- openMAC internal packet buffer
	--------------------------------------
	--- PORT A => MAC
	--- PORT B => AVALON BUS
	-----------------------------------------------------------------------
	intPcktbfr: BLOCK
		signal Dma_Din_s : std_logic_vector(Dma_Din'range);
		signal Dma_Dout_s : std_logic_vector(Dma_Dout'range);
		signal readA_s, readB_s : std_logic;
		signal writeA_s, writeB_s : std_logic;
	BEGIN
	
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
			if Dma_Req = '1' then
				Dma_Ack <= '1';
			else
				Dma_Ack <= '0';
			end if;
		end if;
	end process genAck;
	
	packetBuffer:	ENTITY	work.OpenMAC_DPRpackets
		GENERIC MAP(memSizeLOG2_g => iBufSizeLOG2_g,
					memSize_g => iBufSize_g)
		PORT MAP
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
	END BLOCK intPcktbfr;

	-----------------------------------------------------------------------
	-- MAC-Time compare
	-- Mac Time output
	-----------------------------------------------------------------------
	the_cmpUnit : BLOCK
		SIGNAL Mac_Cmp_On : STD_LOGIC;
		SIGNAL Mac_Tog_On : STD_LOGIC;
		SIGNAL Mac_Cmp_Wert : STD_LOGIC_VECTOR(Mac_Zeit'RANGE);
		SIGNAL Mac_Cmp_TogVal	: STD_LOGIC_VECTOR(Mac_Zeit'RANGE);
		SIGNAL Mac_Cmp_Irq : STD_LOGIC;
		SIGNAL Mac_Cmp_Toggle : STD_LOGIC;
	BEGIN
		
		t_IRQ <= Mac_Cmp_Irq;
		t_IrqToggle <= Mac_Cmp_Toggle;
		
		p_MacCmp : PROCESS ( Reset_n, Clk50 )
		BEGIN
			IF ( Reset_n = '0' ) THEN
				Mac_Cmp_Irq  <= '0';
				Mac_Cmp_On   <= '0';
				Mac_Tog_On   <= '0';
				Mac_Cmp_Wert <= (OTHERS => '0');
				Mac_Cmp_TogVal <= (OTHERS => '0');
				Mac_Cmp_Toggle <= '0';
				t_readdata <= (OTHERS => '0');
			ELSIF rising_edge( Clk50 ) THEN
			
				IF ( t_chipselect = '1' AND t_write_n = '0' ) THEN
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
				END IF;

				IF ( Mac_Cmp_On = '1' and Mac_Cmp_Wert( Mac_Zeit'RANGE ) = Mac_Zeit ) THEN
					Mac_Cmp_Irq <= '1';
				END IF;
				
				IF ( Mac_Tog_On = '1' and Mac_Cmp_TogVal( Mac_Zeit'RANGE ) = Mac_Zeit ) THEN
					Mac_Cmp_Toggle <= not Mac_Cmp_Toggle;
				END IF;
				
				if ( t_chipselect = '1' and t_read_n = '0' ) then
					case t_address is
						when "00" => --0
							t_readdata <= Mac_Zeit(31 DOWNTO 0);
						when "01" => --4
							t_readdata <= x"000000" & "00" & Mac_Cmp_Toggle & Mac_Tog_On & "00" & Mac_Cmp_Irq & Mac_Cmp_On;
						when "10" => --8
							t_readdata <= Mac_Cmp_TogVal;
						when others =>
							t_readdata <= (others => '0');
					end case;
				end if;

			END IF;
		END PROCESS p_MacCmp;
		
	END BLOCK the_cmpUnit;

END ARCHITECTURE struct;
