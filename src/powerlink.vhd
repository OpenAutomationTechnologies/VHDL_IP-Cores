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
-- 2010-08-23  	V0.01	zelenkaj    First version
-- 2010-09-13	V0.02	zelenkaj	added selection Rmii / Mii
-- 2010-10-18	V0.03	zelenkaj	added selection Big/Little Endian (pdi_par)
--									use bidirectional bus (pdi_par)
-- 2010-11-23	V0.04	zelenkaj	Added 2 GPIO signals to parallel interface
--									Added Operational Flag to simple I/O interface
--									Omitted T/RPDO descriptor sections in DPR
--									Added generic to set duration of valid assertion (portio)
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink is
	generic(
	-- GENERAL GENERICS															--
		genPdi_g					:		boolean 							:= true;
		genAvalonAp_g				:		boolean 							:= true;
		genSimpleIO_g				:		boolean 							:= false;
		genSpiAp_g					:		boolean 							:= false;
	-- OPENMAC GENERICS
		Simulate                    :     	boolean 							:= false;
   		iBufSize_g					: 		integer 							:= 1024;
   		iBufSizeLOG2_g				: 		integer 							:= 10;
		useRmii_g					:		boolean								:= true; --use Rmii
	-- PDI GENERICS
		iRpdos_g					:		integer 							:= 3;
		iTpdos_g					:		integer 							:= 1;
		--PDO buffer size *3
		iTpdoBufSize_g				:		integer 							:= 100;
		iRpdo0BufSize_g				:		integer 							:= 100;
		iRpdo1BufSize_g				:		integer 							:= 100;
		iRpdo2BufSize_g				:		integer 							:= 100;
--		--PDO-objects
--		iTpdoObjNumber_g			:		integer 							:= 10;
--		iRpdoObjNumber_g			:		integer 							:= 10; --includes all PDOs!!!
		--asynchronous TX and RX buffer size
		iAsyTxBufSize_g				:		integer 							:= 1500;
		iAsyRxBufSize_g				:		integer 							:= 1500;
	-- 8/16bit PARALLEL PDI GENERICS
		papDataWidth_g				:		integer 							:= 8;
		papLowAct_g					:		boolean								:= false;
		papBigEnd_g					:		boolean								:= false;
	-- SPI GENERICS
		spiCPOL_g					:		boolean 							:= false;
		spiCPHA_g					:		boolean 							:= false;
	-- PORTIO
		pioValLen_g					:		integer								:= 50 --clock ticks of pcp_clk
	);
	port(
	-- CLOCK / RESET PORTS
		clk50 						: in 	std_logic; --RMII clk
		clkEth 						: in 	std_logic; --Tx Reg clk
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
		tcp_address                 : in    std_logic_vector(1 downto 0);
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
	    pcp_address                 : in    std_logic_vector(12 downto 0);
	    pcp_writedata               : in    std_logic_vector(31 downto 0);
	    pcp_readdata                : out   std_logic_vector(31 downto 0);
	--- AP PORTS
		ap_irq						: out	std_logic;
		ap_irq_n					: out	std_logic;
	---- AVALON
		ap_chipselect               : in    std_logic;
		ap_read						: in    std_logic;
		ap_write					: in    std_logic;
		ap_byteenable             	: in    std_logic_vector(3 downto 0);
		ap_address                  : in    std_logic_vector(12 downto 0);
		ap_writedata                : in    std_logic_vector(31 downto 0);
		ap_readdata                 : out   std_logic_vector(31 downto 0);
	---- 8/16bit parallel
		pap_cs						: in    std_logic;
		pap_rd						: in    std_logic;
		pap_wr 						: in    std_logic;
		pap_be						: in    std_logic_vector(papDataWidth_g/8-1 downto 0);
		pap_cs_n					: in    std_logic;
		pap_rd_n					: in    std_logic;
		pap_wr_n					: in    std_logic;
		pap_be_n					: in    std_logic_vector(papDataWidth_g/8-1 downto 0);
		pap_addr 					: in    std_logic_vector(15 downto 0);
		pap_data					: inout std_logic_vector(papDataWidth_g-1 downto 0);
--		pap_wrdata					: in    std_logic_vector(papDataWidth_g-1 downto 0);
--		pap_rddata					: out   std_logic_vector(papDataWidth_g-1 downto 0);
--		pap_doe						: out	std_logic;
		pap_ready					: out	std_logic;
		pap_ready_n					: out	std_logic;
		pap_gpio					: inout	std_logic_vector(1 downto 0);
	---- SPI
		spi_clk						: in	std_logic;
		spi_sel_n					: in	std_logic;
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
		pio_operational				: out	std_logic;
	-- EXTERNAL
	--- RMII PORTS
		phy0_RxDat                 	: in    std_logic_vector(1 downto 0);
		phy0_RxDv                  	: in    std_logic;
		phy0_TxDat                 	: out   std_logic_vector(1 downto 0);
		phy0_TxEn                  	: out   std_logic;
		phy0_MiiClk					: out	std_logic;
		phy0_MiiDat					: inout	std_logic 							:= '1';
		phy0_MiiRst_n				: out	std_logic 							:= '0';
		phy1_RxDat                 	: in    std_logic_vector(1 downto 0);
		phy1_RxDv                  	: in    std_logic;
		phy1_TxDat                 	: out   std_logic_vector(1 downto 0);
		phy1_TxEn                  	: out   std_logic;
		phy1_MiiClk					: out	std_logic;
		phy1_MiiDat					: inout	std_logic 							:= '1';
		phy1_MiiRst_n				: out	std_logic 							:= '0';
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
		phyMii1_TxEr                : out   std_logic
	);
end powerlink;

architecture rtl of powerlink is
	signal mii_Clk					:		std_logic							:= '0';
	signal mii_Di					:		std_logic							:= '0';
	signal mii_Do					:		std_logic							:= '0';
	signal mii_Doe					:		std_logic							:= '0';
	signal mii_nResetOut			:		std_logic							:= '0';
	signal rstPcp_n					:		std_logic							:= '0';
	signal rstAp_n					:		std_logic							:= '0';
	signal irqToggle				:		std_logic							:= '0';
	
	signal ap_chipselect_s			:		std_logic							:= '0';
	signal ap_read_s				:		std_logic							:= '0';
	signal ap_write_s				:		std_logic							:= '0';
	signal ap_byteenable_s			:		std_logic_vector(ap_byteenable'range) := (others => '0');
	signal ap_address_s				:		std_logic_vector(ap_address'range)	:= (others => '0');
	signal ap_writedata_s			:		std_logic_vector(ap_writedata'range):= (others => '0');
	signal ap_readdata_s			:		std_logic_vector(ap_readdata'range)	:= (others => '0');
	
	signal pap_cs_s					:		std_logic;
	signal pap_rd_s					:		std_logic;
	signal pap_wr_s					:		std_logic;
	signal pap_be_s					:		std_logic_vector(pap_be'range);
	signal pap_cs_ss				:		std_logic;
	signal pap_rd_ss				:		std_logic;
	signal pap_wr_ss				:		std_logic;
	signal pap_ready_s				:		std_logic;
	signal ap_irq_s					:		std_logic;
	
	signal spi_sel_s				:		std_logic;
begin
	--general signals
	rstPcp_n <= not rstPcp;
	rstAp_n <= not rstAp;
	--timer irq signal
	--tcp_irq <= IrqToggle;
	
------------------------------------------------------------------------------------------------------------------------
--PCP + AP
	genPdi : if genPdi_g and genAvalonAp_g and not genSpiAp_g generate
		theAvalonPdi : entity work.pdi
			generic map (
				iRpdos_g					=> iRpdos_g,
				iTpdos_g					=> iTpdos_g,
				--PDO buffer size *3
				iTpdoBufSize_g				=> iTpdoBufSize_g,
				iRpdo0BufSize_g				=> iRpdo0BufSize_g,
				iRpdo1BufSize_g				=> iRpdo1BufSize_g,
				iRpdo2BufSize_g				=> iRpdo2BufSize_g,
--				--PDO-objects
--				iTpdoObjNumber_g			=> iTpdoObjNumber_g,
--				iRpdoObjNumber_g			=> iRpdoObjNumber_g,
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
				pcp_irq						=> irqToggle,
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

--AP is external connected via parallel interface
	genPdiPar : if genPdi_g and not genAvalonAp_g and not genSpiAp_g generate
		
		--only 8 or 16bit data width is allowed
		ASSERT ( papDataWidth_g = 8 or papDataWidth_g = 16 )
			REPORT "External parallel port only allows 8 or 16bit data width!"
			severity failure;
		
		-------------------------------------------------------------------------------------
		--sync signals used by the fsm in pdi_par
		-- use active low or high inputs!
		theParPortSyncCs : entity work.sync
			port map (
				inData					=> pap_cs_s, --sync the parallel port cs signal
				outData					=> pap_cs_ss, --the sync cs is used to trigger fsm
				clk						=> clk50,
				rst						=> rstPcp
			);
		
--		theParPortSyncRd : entity work.sync
--			port map (
--				inData					=> pap_rd_s, --sync the parallel port rd signal
--				outData					=> pap_rd_ss, --the sync cs is used rd trigger fsm
--				clk						=> clk50,
--				rst						=> rstPcp
--			);
		pap_rd_ss <= pap_rd_s;
--		theParPortSyncWr : entity work.sync
--			port map (
--				inData					=> pap_wr_s, --sync the parallel port wr signal
--				outData					=> pap_wr_ss, --the sync cs is used wr trigger fsm
--				clk						=> clk50,
--				rst						=> rstPcp
--			);
		pap_wr_ss <= pap_wr_s;
		--
		-------------------------------------------------------------------------------------
		
		-------------------------------------------------------------------------------------
		--convert active low signals to active high - respectively assign active high signals
		theActiveLowGen : if papLowAct_g generate
			pap_wr_s <= not pap_wr_n;
			pap_rd_s <= not pap_rd_n;
			pap_cs_s <= not pap_cs_n;
			pap_be_s <= not pap_be_n;
		end generate;
		
		theActiveHighGen : if not papLowAct_g generate
			pap_wr_s <= pap_wr;
			pap_rd_s <= pap_rd;
			pap_cs_s <= pap_cs;
			pap_be_s <= pap_be;
		end generate;
		
		ap_irq <= ap_irq_s;
		ap_irq_n <= not ap_irq_s;
		
		pap_ready <= pap_ready_s;
		pap_ready_n <= not pap_ready_s;
		--
		-------------------------------------------------------------------------------------
		
		theParPort : entity work.pdi_par
			generic map (
			papDataWidth_g				=> papDataWidth_g,
			papBigEnd_g					=> papBigEnd_g
			)
			port map (
			-- 8/16bit parallel
				pap_cs						=> pap_cs_ss,
				pap_rd						=> pap_rd_ss,
				pap_wr						=> pap_wr_ss,
				pap_be						=> pap_be_s,
				pap_addr					=> pap_addr,
				pap_data					=> pap_data,
--				pap_wrdata					=> pap_wrdata,
--				pap_rddata					=> pap_rddata,
--				pap_doe						=> pap_doe,
				pap_ready					=> pap_ready_s,
				pap_gpio					=> pap_gpio,
			-- clock for AP side
				ap_reset					=> rstPcp,
				ap_clk						=> clk50,
			-- Avalon Slave Interface for AP
	            ap_chipselect				=> ap_chipselect_s,
	            ap_read						=> ap_read_s,
	            ap_write					=> ap_write_s,
	            ap_byteenable				=> ap_byteenable_s,
	            ap_address					=> ap_address_s,
	            ap_writedata				=> ap_writedata_s,
	            ap_readdata					=> ap_readdata_s
			);
		
		thePdi : entity work.pdi
			generic map (
				iRpdos_g					=> iRpdos_g,
				iTpdos_g					=> iTpdos_g,
				--PDO buffer size *3
				iTpdoBufSize_g				=> iTpdoBufSize_g,
				iRpdo0BufSize_g				=> iRpdo0BufSize_g,
				iRpdo1BufSize_g				=> iRpdo1BufSize_g,
				iRpdo2BufSize_g				=> iRpdo2BufSize_g,
--				--PDO-objects
--				iTpdoObjNumber_g			=> iTpdoObjNumber_g,
--				iRpdoObjNumber_g			=> iRpdoObjNumber_g,
				--asynchronous TX and RX buffer size
				iAsyTxBufSize_g				=> iAsyTxBufSize_g,
				iAsyRxBufSize_g				=> iAsyRxBufSize_g
			)
			port map (
				pcp_reset					=> rstPcp,
				pcp_clk                  	=> clkPcp,
				ap_reset					=> rstPcp,
				ap_clk						=> clk50,
				-- Avalon Slave Interface for PCP
				pcp_chipselect              => pcp_chipselect,
				pcp_read					=> pcp_read,
				pcp_write					=> pcp_write,
				pcp_byteenable	            => pcp_byteenable,
				pcp_address                 => pcp_address,
				pcp_writedata               => pcp_writedata,
				pcp_readdata                => pcp_readdata,
				pcp_irq						=> irqToggle,
				-- Avalon Slave Interface for AP
				ap_chipselect               => ap_chipselect_s,
				ap_read						=> ap_read_s,
				ap_write					=> ap_write_s,
				ap_byteenable             	=> ap_byteenable_s,
				ap_address                  => ap_address_s,
				ap_writedata                => ap_writedata_s,
				ap_readdata                 => ap_readdata_s,
				ap_irq						=> ap_irq_s
			);
	end generate genPdiPar;

--AP is extern connected via SPI
	genPdiSpi : if genPdi_g and genSpiAp_g generate
		
		spi_sel_s <= not spi_sel_n;
		
		thePdiSpi : entity work.pdi_spi
			generic map (
				spiSize_g					=> 8, --fixed value!
				cpol_g 						=> spiCPOL_g,
				cpha_g 						=> spiCPHA_g
			)
			port map (
				-- SPI
				spi_clk						=> spi_clk,
				spi_sel						=> spi_sel_s,
				spi_miso					=> spi_miso,
				spi_mosi					=> spi_mosi,
				-- clock for AP side
				ap_reset					=> rstPcp,
				ap_clk						=> clk50,
				-- Avalon Slave Interface for AP
				ap_chipselect               => ap_chipselect_s,
				ap_read						=> ap_read_s,
				ap_write					=> ap_write_s,
				ap_byteenable             	=> ap_byteenable_s,
				ap_address                  => ap_address_s,
				ap_writedata                => ap_writedata_s,
				ap_readdata                 => ap_readdata_s
			);
		
		thePdi : entity work.pdi
			generic map (
				iRpdos_g					=> iRpdos_g,
				iTpdos_g					=> iTpdos_g,
				--PDO buffer size *3
				iTpdoBufSize_g				=> iTpdoBufSize_g,
				iRpdo0BufSize_g				=> iRpdo0BufSize_g,
				iRpdo1BufSize_g				=> iRpdo1BufSize_g,
				iRpdo2BufSize_g				=> iRpdo2BufSize_g,
--				--PDO-objects
--				iTpdoObjNumber_g			=> iTpdoObjNumber_g,
--				iRpdoObjNumber_g			=> iRpdoObjNumber_g,
				--asynchronous TX and RX buffer size
				iAsyTxBufSize_g				=> iAsyTxBufSize_g,
				iAsyRxBufSize_g				=> iAsyRxBufSize_g
			)
			port map (
				pcp_reset					=> rstPcp,
				pcp_clk                  	=> clkPcp,
				ap_reset					=> rstPcp,
				ap_clk						=> clk50,
				-- Avalon Slave Interface for PCP
				pcp_chipselect              => pcp_chipselect,
				pcp_read					=> pcp_read,
				pcp_write					=> pcp_write,
				pcp_byteenable	            => pcp_byteenable,
				pcp_address                 => pcp_address,
				pcp_writedata               => pcp_writedata,
				pcp_readdata                => pcp_readdata,
				pcp_irq						=> irqToggle,
				-- Avalon Slave Interface for AP
				ap_chipselect               => ap_chipselect_s,
				ap_read						=> ap_read_s,
				ap_write					=> ap_write_s,
				ap_byteenable             	=> ap_byteenable_s,
				ap_address                  => ap_address_s,
				ap_writedata                => ap_writedata_s,
				ap_readdata                 => ap_readdata_s,
				ap_irq						=> ap_irq_s
			);
	end generate genPdiSpi;
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--SIMPLE I/O CN
	genSimpleIO : if genSimpleIO_g generate
		thePortIO : entity work.portio
			generic map (
				pioValLen_g			=> pioValLen_g
			)
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
				x_portio			=> pio_portio,
				x_operational		=> pio_operational
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
			iBufSizeLOG2_g			=> iBufSizeLOG2_g,
			useRmii_g				=> useRmii_g
		)
		port map (
			Reset_n					=> rstPcp_n,
			Clk50                  	=> clk50,
			ClkFaster				=> clkPcp,
			clkEth					=> clkEth,
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
			t_IRQ					=> tcp_irq,
			t_IrqToggle				=> irqToggle,
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
		--- MII PORTS
			phyMii0_RxClk			=> phyMii0_RxClk,
			phyMii0_RxDat           => phyMii0_RxDat,
			phyMii0_RxDv            => phyMii0_RxDv,
			phyMii0_TxClk			=> phyMii0_TxClk,
			phyMii0_TxDat           => phyMii0_TxDat,
			phyMii0_TxEn            => phyMii0_TxEn,
			phyMii0_TxEr            => phyMii0_TxEr,
			phyMii1_RxClk			=> phyMii1_RxClk,
			phyMii1_RxDat           => phyMii1_RxDat,
			phyMii1_RxDv            => phyMii1_RxDv,
			phyMii1_TxClk			=> phyMii1_TxClk,
			phyMii1_TxDat           => phyMii1_TxDat,
			phyMii1_TxEn            => phyMii1_TxEn,
			phyMii1_TxEr            => phyMii1_TxEr,
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
