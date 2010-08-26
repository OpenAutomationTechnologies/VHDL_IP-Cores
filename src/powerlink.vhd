------------------------------------------------------------------------------------------------------------------------
-- POWERLINK IP-Core
--
-- 	  Copyright (C) 2010 B&R
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
-- 2010-08-23  V0.01	zelenkaj    First version
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink is
	generic(
	-- GENERAL GENERICS
		genPdi_g					:		boolean := true;
		genAvalonAp_g				:		boolean := true;
		genSimpleIO_g				:		boolean := false;
		genSpiAp_g					:		boolean := false;
	-- OPENMAC GENERICS
		Simulate                    :     	boolean := false;
   		iBufSize_g					: 		integer := 1024;
   		iBufSizeLOG2_g				: 		integer := 10;
	-- PDI GENERICS
		iRpdos_g					:		integer := 3;
		iTpdos_g					:		integer := 1;
		--PDO buffer size *3
		iTpdoBufSize_g				:		integer := 100;
		iRpdo0BufSize_g				:		integer := 100;
		iRpdo1BufSize_g				:		integer := 100;
		iRpdo2BufSize_g				:		integer := 100;
		--PDO-objects
		iTpdoObjNumber_g			:		integer := 10;
		iRpdoObjNumber_g			:		integer := 10; --includes all PDOs!!!
		--asynchronous TX and RX buffer size
		iAsyTxBufSize_g				:		integer := 1500;
		iAsyRxBufSize_g				:		integer := 1500;
	-- 8/16bit PARALLEL PDI GENERICS
		papDataWidth_g				:		integer := 8;
	-- SPI GENERICS
		spiCPOL_g					:		boolean := false;
		spiCPHA_g					:		boolean := false
	);
	port(
	-- CLOCK / RESET PORTS
		clk50 						: in 	std_logic; --RMII clk
		clk100 						: in 	std_logic; --Tx Reg clk
		clkPcp 						: in 	std_logic; --pcp clk (
		clkAp 						: in 	std_logic; --ap clk
		rstPcp 						: in 	std_logic; --rst from pcp side (ap + rmii + tx)
		rstAp 						: in 	std_logic; --rst ap
	-- OPENMAC
	--- OPENMAC PORTS
		mac_chipselect              : in    std_logic;
		mac_read_n					: in    std_logic;
		mac_write_n					: in    std_logic;
		mac_byteenable_n            : in    std_logic_vector(1 downto 0);
		mac_address                 : in    std_logic_vector(11 downto 0);
		mac_writedata               : in    std_logic_vector(15 downto 0);
		mac_readdata                : out   std_logic_vector(15 downto 0);
		mac_irq						: out 	std_logic;
	--- TIMER COMPARE PORTS
		tcp_chipselect              : in    std_logic;
		tcp_read_n					: in    std_logic;
		tcp_write_n					: in    std_logic;
		tcp_byteenable_n            : in    std_logic_vector(3 downto 0);
		tcp_address                 : in    std_logic_vector(0 downto 0);
		tcp_writedata               : in    std_logic_vector(31 downto 0);
		tcp_readdata                : out   std_logic_vector(31 downto 0);
		tcp_irq						: out 	std_logic;
	--- MAC BUFFER PORTS
		mbf_chipselect             	: in    std_logic;
		mbf_read_n					: in    std_logic;
		mbf_write_n					: in    std_logic;
		mbf_byteenable             	: in    std_logic_vector(3 downto 0);
		mbf_address                	: in    std_logic_vector(ibufsizelog2_g-3 downto 0);
		mbf_writedata              	: in    std_logic_vector(31 downto 0);
		mbf_readdata               	: out   std_logic_vector(31 downto 0);
	-- PDI
	--- PCP PORTS
	    pcp_chipselect              : in    std_logic;
	    pcp_read					: in    std_logic;
	    pcp_write					: in    std_logic;
	    pcp_byteenable	            : in    std_logic_vector(3 downto 0);
	    pcp_address                 : in    std_logic_vector(14 downto 0);
	    pcp_writedata               : in    std_logic_vector(31 downto 0);
	    pcp_readdata                : out   std_logic_vector(31 downto 0);
	--- AP PORTS
		ap_irq						: out	std_logic;
	---- AVALON
		ap_chipselect               : in    std_logic;
		ap_read						: in    std_logic;
		ap_write					: in    std_logic;
		ap_byteenable             	: in    std_logic_vector(3 downto 0);
		ap_address                  : in    std_logic_vector(14 downto 0);
		ap_writedata                : in    std_logic_vector(31 downto 0);
		ap_readdata                 : out   std_logic_vector(31 downto 0);
	---- 8/16bit parallel
		pap_cs						: in    std_logic;
		pap_rd						: in    std_logic;
		pap_wr 						: in    std_logic;
		pap_be						: in    std_logic_vector(papDataWidth_g/4-1 downto 0);
		pap_addr 					: in    std_logic_vector(15 downto 0);
		pap_wrdata					: in    std_logic_vector(papDataWidth_g-1 downto 0);
		pap_rddata					: out   std_logic_vector(papDataWidth_g-1 downto 0);
		pap_doe						: out	std_logic;
	---- SPI
		spi_clk						: in	std_logic;
		spi_sel						: in	std_logic;
		spi_mosi					: in 	std_logic;
		spi_miso					: out	std_logic;
	---- simple I/O
		smp_address    				: in    std_logic;
		smp_read       				: in    std_logic;
		smp_readdata   				: out   std_logic_vector(31 downto 0);
		smp_write      				: in    std_logic;
		smp_writedata  				: in    std_logic_vector(31 downto 0);
		smp_byteenable 				: in    std_logic_vector(3 downto 0);
		pio_pconfig    				: in    std_logic_vector(3 downto 0);
		pio_portInLatch				: in 	std_logic_vector(3 downto 0);
		pio_portOutValid 			: out 	std_logic_vector(3 downto 0);
		pio_portio     				: inout std_logic_vector(31 downto 0);
	-- EXTERNAL
	--- RMII PORTS
		phy0_RxDat                 	: in    std_logic_vector(1 downto 0);
		phy0_RxDv                  	: in    std_logic;
		phy0_TxDat                 	: out   std_logic_vector(1 downto 0);
		phy0_TxEn                  	: out   std_logic;
		phy0_MiiClk					: out	std_logic;
		phy0_MiiDat					: inout	std_logic := '1';
		phy0_MiiRst_n				: out	std_logic := '0';
		phy1_RxDat                 	: in    std_logic_vector(1 downto 0);
		phy1_RxDv                  	: in    std_logic;
		phy1_TxDat                 	: out   std_logic_vector(1 downto 0);
		phy1_TxEn                  	: out   std_logic;
		phy1_MiiClk					: out	std_logic;
		phy1_MiiDat					: inout	std_logic := '1';
		phy1_MiiRst_n				: out	std_logic := '0'
	);
end powerlink;

architecture rtl of powerlink is
	signal mii_Clk					:		std_logic;
	signal mii_Di					:		std_logic;
	signal mii_Do					:		std_logic;
	signal mii_Doe					:		std_logic;
	signal mii_nResetOut			:		std_logic;
	signal rstPcp_n					:		std_logic;
	signal rstAp_n					:		std_logic;
	signal timerIrq					:		std_logic;
begin
	--general signals
	rstPcp_n <= not rstPcp;
	rstAp_n <= not rstAp;
	--timer irq signal
	tcp_irq <= timerIrq;
	
	genPdi : if genPdi_g and genAvalonAp_g generate
		theAvalonPdi : entity work.pdi
			generic map (
				iRpdos_g					=> iRpdos_g,
				iTpdos_g					=> iTpdos_g,
				--PDO buffer size *3
				iTpdoBufSize_g				=> iTpdoBufSize_g,
				iRpdo0BufSize_g				=> iRpdo0BufSize_g,
				iRpdo1BufSize_g				=> iRpdo1BufSize_g,
				iRpdo2BufSize_g				=> iRpdo2BufSize_g,
				--PDO-objects
				iTpdoObjNumber_g			=> iTpdoObjNumber_g,
				iRpdoObjNumber_g			=> iRpdoObjNumber_g,
				--asynchronous TX and RX buffer size
				iAsyTxBufSize_g				=> iAsyTxBufSize_g,
				iAsyRxBufSize_g				=> iAsyRxBufSize_g
			)
			port map (
				pcp_reset					=> rstPcp,
				pcp_clk                  	=> clkPcp,
				ap_reset					=> rstAp,
				ap_clk						=> clkAp,
				-- Avalon Slave Interface for PCP
				pcp_chipselect              => pcp_chipselect,
				pcp_read					=> pcp_read,
				pcp_write					=> pcp_write,
				pcp_byteenable	            => pcp_byteenable,
				pcp_address                 => pcp_address,
				pcp_writedata               => pcp_writedata,
				pcp_readdata                => pcp_readdata,
				pcp_irq						=> timerIrq,
				-- Avalon Slave Interface for AP
				ap_chipselect               => ap_chipselect,
				ap_read						=> ap_read,
				ap_write					=> ap_write,
				ap_byteenable             	=> ap_byteenable,
				ap_address                  => ap_address,
				ap_writedata                => ap_writedata,
				ap_readdata                 => ap_readdata,
				ap_irq						=> ap_irq
			);
	end generate genPdi;
	
	genPdiPar : if genPdi_g and not genAvalonAp_g generate
		ASSERT FALSE
			REPORT "Parallel external Interface (8/16bit) is not yet implemented!" 
			severity failure;
	end generate genPdiPar;
	
	genPdiSpi : if genPdi_g and genSpiAp_g generate
		ASSERT FALSE
			REPORT "SPI is not yet implemented!" 
			severity failure;
	end generate genPdiSpi;
------------------------------------------------------------------------------------------------------------------------
--SIMPLE I/O CN
	genSimpleIO : if genSimpleIO_g generate
		thePortIO : entity work.portio
			port map (
				s0_address			=> smp_address,
				s0_read				=> smp_read,
				s0_readdata			=> smp_readdata,
				s0_write			=> smp_write,
				s0_writedata		=> smp_writedata,
				s0_byteenable		=> smp_byteenable,
				clk					=> clkPcp,
				reset				=> rstPcp,
				x_pconfig			=> pio_pconfig,
				x_portInLatch		=> pio_portInLatch,
				x_portOutValid		=> pio_portOutValid,
				x_portio			=> pio_portio
			);
	end generate genSimpleIO;
--
------------------------------------------------------------------------------------------------------------------------
	
------------------------------------------------------------------------------------------------------------------------
--OPENMAC (OPENHUB, OPENFILTER, PHY MANAGEMENT)
	theOpenMAC: entity work.AlteraOpenMACIF
		generic map (
			Simulate				=> Simulate,
			iBufSize_g				=> iBufSize_g,
			iBufSizeLOG2_g			=> iBufSizeLOG2_g
		)
		port map (
			Reset_n					=> rstPcp_n,
			Clk50                  	=> clk50,
			ClkFaster				=> clkPcp,
			Clk100					=> clk100,
			s_chipselect            => mac_chipselect,
			s_read_n				=> mac_read_n,
			s_write_n				=> mac_write_n,
			s_byteenable_n          => mac_byteenable_n,
			s_address               => mac_address,
			s_writedata             => mac_writedata,
			s_readdata              => mac_readdata,
			s_IRQ					=> mac_irq,
			t_chipselect            => tcp_chipselect,
			t_read_n				=> tcp_read_n,
			t_write_n				=> tcp_write_n,
			t_byteenable_n          => tcp_byteenable_n,
			t_address               => tcp_address,
			t_writedata             => tcp_writedata,
			t_readdata              => tcp_readdata,
			t_IRQ					=> timerIrq, --tcp_irq,
			iBuf_chipselect         => mbf_chipselect,
			iBuf_read_n				=> mbf_read_n,
			iBuf_write_n			=> mbf_write_n,
			iBuf_byteenable         => mbf_byteenable,
			iBuf_address            => mbf_address,
			iBuf_writedata          => mbf_writedata,
			iBuf_readdata           => mbf_readdata,
			rRx_Dat_0               => phy0_RxDat,
			rCrs_Dv_0               => phy0_RxDv,
			rTx_Dat_0               => phy0_TxDat,
			rTx_En_0                => phy0_TxEn,
			rRx_Dat_1               => phy1_RxDat,
			rCrs_Dv_1               => phy1_RxDv,
			rTx_Dat_1               => phy1_TxDat,
			rTx_En_1                => phy1_TxEn,
			mii_Clk					=> mii_Clk,
			mii_Di					=> mii_Di,
			mii_Do					=> mii_Do,
			mii_Doe					=> mii_Doe,
			mii_nResetOut			=> mii_nResetOut
		);
	--Phy SMI signals
	phy0_MiiClk <= mii_Clk;
	phy0_MiiDat <= mii_Do when mii_Doe = '1' else 'Z';
	phy0_MiiRst_n <= mii_nResetOut;
	phy1_MiiClk <= mii_Clk;
	phy1_MiiDat <= mii_Do when mii_Doe = '1' else 'Z';
	phy1_MiiRst_n <= mii_nResetOut;
	mii_Di <= phy0_MiiDat and phy1_MiiDat;
--
------------------------------------------------------------------------------------------------------------------------
		
end rtl;
