-------------------------------------------------------------------------------
--
-- Title       : plb_powerlink
-- Design      : POWERLINK
--
-------------------------------------------------------------------------------
--
-- File        : c:\my_designs\POWERLINK\compile\plb_powerlink.vhd
-- Generated   : Wed Sep 14 11:18:01 2011
-- From        : c:\my_designs\POWERLINK\src\plb_powerlink.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
--    (c) B&R, 2011
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
-------------------------------------------------------------------------------
-- Design unit header --
--
-- This is the toplevel file for using the POWERLINK IP-Core
-- with Xilinx PLB V4.6.
--
-------------------------------------------------------------------------------
--
-- 2011-09-13  	V0.01	zelenkaj    First version
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;

library plbv46_slave_single_v1_01_a;
use plbv46_slave_single_v1_01_a.plbv46_slave_single;

-- other libraries declarations
library PLBV46_MASTER_BURST_V1_01_A;
library PLBV46_SLAVE_SINGLE_V1_01_A;

entity plb_powerlink is
  generic(
       -- name : type := value
       ibufsizelog2_g : integer := 10;
       m_burstcount_width_g : integer := 3;
       papDataWidth_g : integer := 16;
       -- openMAC CMP PLB Slave
       C_MAC_CMP_BASEADDR : std_logic_vector := X"FFFFFFFF";
       C_MAC_CMP_HIGHADDR : std_logic_vector := X"000000000";
       C_MAC_CMP_NUM_MASTERS : INTEGER := 1;
       C_MAC_CMP_PLB_AWIDTH : INTEGER := 32;
       C_MAC_CMP_PLB_DWIDTH : INTEGER := 32;
       C_MAC_CMP_PLB_MID_WIDTH : INTEGER := 1;
       C_MAC_CMP_PLB_P2P : INTEGER := 0;
       -- openMAC DMA PLB Master
       C_MAC_DMA_PLB_AWIDTH : INTEGER := 32;
       C_MAC_DMA_PLB_DWIDTH : INTEGER := 32;
       C_MAC_DMA_PLB_NATIVE_DWIDTH : INTEGER := 32;
       -- openMAC REG PLB Slave
       C_MAC_REG_BASEADDR : std_logic_vector := X"FFFFFFFF";
       C_MAC_REG_HIGHADDR : std_logic_vector := X"00000000";
       C_MAC_REG_NUM_MASTERS : INTEGER := 1;
       C_MAC_REG_PLB_AWIDTH : INTEGER := 32;
       C_MAC_REG_PLB_DWIDTH : INTEGER := 32;
       C_MAC_REG_PLB_MID_WIDTH : INTEGER := 1;
       C_MAC_REG_PLB_P2P : INTEGER := 0
  );
  port(
       MAC_CMP_Clk : in std_logic;
       MAC_CMP_PAValid : in std_logic;
       MAC_CMP_RNW : in std_logic;
       MAC_CMP_Rst : in std_logic;
       MAC_CMP_SAValid : in std_logic;
       MAC_CMP_abort : in std_logic;
       MAC_CMP_busLock : in std_logic;
       MAC_CMP_lockErr : in std_logic;
       MAC_CMP_rdBurst : in std_logic;
       MAC_CMP_rdPendReq : in std_logic;
       MAC_CMP_rdPrim : in std_logic;
       MAC_CMP_wrBurst : in std_logic;
       MAC_CMP_wrPendReq : in std_logic;
       MAC_CMP_wrPrim : in std_logic;
       MAC_DMA_Clk : in std_logic;
       MAC_DMA_MAddrAck : in std_logic;
       MAC_DMA_MBusy : in std_logic;
       MAC_DMA_MIRQ : in std_logic;
       MAC_DMA_MRdBTerm : in std_logic;
       MAC_DMA_MRdDAck : in std_logic;
       MAC_DMA_MRdErr : in std_logic;
       MAC_DMA_MRearbitrate : in std_logic;
       MAC_DMA_MTimeout : in std_logic;
       MAC_DMA_MWrBTerm : in std_logic;
       MAC_DMA_MWrDAck : in std_logic;
       MAC_DMA_MWrErr : in std_logic;
       MAC_DMA_Rst : in std_logic;
       MAC_REG_Clk : in std_logic;
       MAC_REG_PAValid : in std_logic;
       MAC_REG_RNW : in std_logic;
       MAC_REG_Rst : in std_logic;
       MAC_REG_SAValid : in std_logic;
       MAC_REG_abort : in std_logic;
       MAC_REG_busLock : in std_logic;
       MAC_REG_lockErr : in std_logic;
       MAC_REG_rdBurst : in std_logic;
       MAC_REG_rdPendReq : in std_logic;
       MAC_REG_rdPrim : in std_logic;
       MAC_REG_wrBurst : in std_logic;
       MAC_REG_wrPendReq : in std_logic;
       MAC_REG_wrPrim : in std_logic;
       pap_cs : in std_logic;
       pap_cs_n : in std_logic;
       pap_rd : in std_logic;
       pap_rd_n : in std_logic;
       pap_wr : in std_logic;
       pap_wr_n : in std_logic;
       phy0_RxDv : in std_logic;
       phy0_RxErr : in std_logic;
       phy0_link : in std_logic;
       phy1_RxDv : in std_logic;
       phy1_RxErr : in std_logic;
       phy1_link : in std_logic;
       phyMii0_RxClk : in std_logic;
       phyMii0_RxDv : in std_logic;
       phyMii0_RxEr : in std_logic;
       phyMii0_TxClk : in std_logic;
       phyMii1_RxClk : in std_logic;
       phyMii1_RxDv : in std_logic;
       phyMii1_RxEr : in std_logic;
       phyMii1_TxClk : in std_logic;
       spi_clk : in std_logic;
       spi_mosi : in std_logic;
       spi_sel_n : in std_logic;
       MAC_CMP_ABus : in std_logic_vector(0 to 31);
       MAC_CMP_BE : in std_logic_vector(0 to (C_MAC_CMP_PLB_DWIDTH/8)-1);
       MAC_CMP_MSize : in std_logic_vector(0 to 1);
       MAC_CMP_TAttribute : in std_logic_vector(0 to 15);
       MAC_CMP_UABus : in std_logic_vector(0 to 31);
       MAC_CMP_masterID : in std_logic_vector(0 to C_MAC_CMP_PLB_MID_WIDTH-1);
       MAC_CMP_rdPendPri : in std_logic_vector(0 to 1);
       MAC_CMP_reqPri : in std_logic_vector(0 to 1);
       MAC_CMP_size : in std_logic_vector(0 to 3);
       MAC_CMP_type : in std_logic_vector(0 to 2);
       MAC_CMP_wrDBus : in std_logic_vector(0 to C_MAC_CMP_PLB_DWIDTH-1);
       MAC_CMP_wrPendPri : in std_logic_vector(0 to 1);
       MAC_DMA_MRdDBus : in std_logic_vector(0 to C_MAC_DMA_PLB_DWIDTH-1);
       MAC_DMA_MRdWdAddr : in std_logic_vector(0 to 3);
       MAC_DMA_MSSize : in std_logic_vector(0 to 1);
       MAC_REG_ABus : in std_logic_vector(0 to 31);
       MAC_REG_BE : in std_logic_vector(0 to (C_MAC_REG_PLB_DWIDTH / 8) - 1);
       MAC_REG_MSize : in std_logic_vector(0 to 1);
       MAC_REG_TAttribute : in std_logic_vector(0 to 15);
       MAC_REG_UABus : in std_logic_vector(0 to 31);
       MAC_REG_masterID : in std_logic_vector(0 to C_MAC_REG_PLB_MID_WIDTH - 1);
       MAC_REG_rdPendPri : in std_logic_vector(0 to 1);
       MAC_REG_reqPri : in std_logic_vector(0 to 1);
       MAC_REG_size : in std_logic_vector(0 to 3);
       MAC_REG_type : in std_logic_vector(0 to 2);
       MAC_REG_wrDBus : in std_logic_vector(0 to C_MAC_REG_PLB_DWIDTH - 1);
       MAC_REG_wrPendPri : in std_logic_vector(0 to 1);
       pap_addr : in std_logic_vector(15 downto 0);
       pap_be : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       pap_be_n : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       phy0_RxDat : in std_logic_vector(1 downto 0);
       phy1_RxDat : in std_logic_vector(1 downto 0);
       phyMii0_RxDat : in std_logic_vector(3 downto 0);
       phyMii1_RxDat : in std_logic_vector(3 downto 0);
       pio_pconfig : in std_logic_vector(3 downto 0);
       pio_portInLatch : in std_logic_vector(3 downto 0);
       MAC_CMP_addrAck : out std_logic;
       MAC_CMP_rdBTerm : out std_logic;
       MAC_CMP_rdComp : out std_logic;
       MAC_CMP_rdDAck : out std_logic;
       MAC_CMP_rearbitrate : out std_logic;
       MAC_CMP_wait : out std_logic;
       MAC_CMP_wrBTerm : out std_logic;
       MAC_CMP_wrComp : out std_logic;
       MAC_CMP_wrDAck : out std_logic;
       MAC_DMA_RNW : out std_logic;
       MAC_DMA_abort : out std_logic;
       MAC_DMA_busLock : out std_logic;
       MAC_DMA_error : out std_logic;
       MAC_DMA_lockErr : out std_logic;
       MAC_DMA_rdBurst : out std_logic;
       MAC_DMA_request : out std_logic;
       MAC_DMA_wrBurst : out std_logic;
       MAC_REG_addrAck : out std_logic;
       MAC_REG_rdBTerm : out std_logic;
       MAC_REG_rdComp : out std_logic;
       MAC_REG_rdDAck : out std_logic;
       MAC_REG_rearbitrate : out std_logic;
       MAC_REG_wait : out std_logic;
       MAC_REG_wrBTerm : out std_logic;
       MAC_REG_wrComp : out std_logic;
       MAC_REG_wrDAck : out std_logic;
       ap_asyncIrq : out std_logic;
       ap_asyncIrq_n : out std_logic;
       ap_irq : out std_logic;
       ap_irq_n : out std_logic;
       led_error : out std_logic;
       led_status : out std_logic;
       mac_irq : out std_logic;
       pap_ack : out std_logic;
       pap_ack_n : out std_logic;
       phy0_Rst_n : out std_logic;
       phy0_SMIClk : out std_logic;
       phy0_TxEn : out std_logic;
       phy1_Rst_n : out std_logic;
       phy1_SMIClk : out std_logic;
       phy1_TxEn : out std_logic;
       phyMii0_TxEn : out std_logic;
       phyMii0_TxEr : out std_logic;
       phyMii1_TxEn : out std_logic;
       phyMii1_TxEr : out std_logic;
       pio_operational : out std_logic;
       spi_miso : out std_logic;
       tcp_irq : out std_logic;
       MAC_CMP_MBusy : out std_logic_vector(0 to C_MAC_CMP_NUM_MASTERS-1);
       MAC_CMP_MIRQ : out std_logic_vector(0 to C_MAC_CMP_NUM_MASTERS-1);
       MAC_CMP_MRdErr : out std_logic_vector(0 to C_MAC_CMP_NUM_MASTERS-1);
       MAC_CMP_MWrErr : out std_logic_vector(0 to C_MAC_CMP_NUM_MASTERS-1);
       MAC_CMP_SSize : out std_logic_vector(0 to 1);
       MAC_CMP_rdDBus : out std_logic_vector(0 to C_MAC_CMP_PLB_DWIDTH-1);
       MAC_CMP_rdWdAddr : out std_logic_vector(0 to 3);
       MAC_DMA_ABus : out std_logic_vector(0 to 31);
       MAC_DMA_BE : out std_logic_vector(0 to (C_MAC_DMA_PLB_DWIDTH/8)-1);
       MAC_DMA_MSize : out std_logic_vector(0 to 1);
       MAC_DMA_TAttribute : out std_logic_vector(0 to 15);
       MAC_DMA_UABus : out std_logic_vector(0 to 31);
       MAC_DMA_priority : out std_logic_vector(0 to 1);
       MAC_DMA_size : out std_logic_vector(0 to 3);
       MAC_DMA_type : out std_logic_vector(0 to 2);
       MAC_DMA_wrDBus : out std_logic_vector(0 to C_MAC_DMA_PLB_DWIDTH-1);
       MAC_REG_MBusy : out std_logic_vector(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MIRQ : out std_logic_vector(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MRdErr : out std_logic_vector(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MWrErr : out std_logic_vector(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_SSize : out std_logic_vector(0 to 1);
       MAC_REG_rdDBus : out std_logic_vector(0 to C_MAC_REG_PLB_DWIDTH-1);
       MAC_REG_rdWdAddr : out std_logic_vector(0 to 3);
       led_gpo : out std_logic_vector(7 downto 0);
       led_opt : out std_logic_vector(1 downto 0);
       led_phyAct : out std_logic_vector(1 downto 0);
       led_phyLink : out std_logic_vector(1 downto 0);
       phy0_TxDat : out std_logic_vector(1 downto 0);
       phy1_TxDat : out std_logic_vector(1 downto 0);
       phyMii0_TxDat : out std_logic_vector(3 downto 0);
       phyMii1_TxDat : out std_logic_vector(3 downto 0);
       pio_portOutValid : out std_logic_vector(3 downto 0);
       phy0_SMIDat : inout std_logic;
       phy1_SMIDat : inout std_logic;
       pap_data : inout std_logic_vector(papDataWidth_g-1 downto 0);
       pap_gpio : inout std_logic_vector(1 downto 0);
       pio_portio : inout std_logic_vector(31 downto 0)
  );
end plb_powerlink;

architecture struct of plb_powerlink is

---- Component declarations -----

component powerlink
  generic(
       Simulate : boolean := false;
       genABuf1_g : boolean := true;
       genABuf2_g : boolean := true;
       genAvalonAp_g : boolean := true;
       genLedGadget_g : boolean := false;
       genOnePdiClkDomain_g : boolean := false;
       genPdi_g : boolean := true;
       genSimpleIO_g : boolean := false;
       genSpiAp_g : boolean := false;
       iAsyBuf1Size_g : integer := 100;
       iAsyBuf2Size_g : integer := 100;
       iBufSizeLOG2_g : integer := 10;
       iBufSize_g : integer := 1024;
       iPdiRev_g : integer := 21930;
       iRpdo0BufSize_g : integer := 100;
       iRpdo1BufSize_g : integer := 100;
       iRpdo2BufSize_g : integer := 100;
       iRpdos_g : integer := 3;
       iTpdoBufSize_g : integer := 100;
       iTpdos_g : integer := 1;
       m_burstcount_width_g : integer := 4;
       m_rx_burst_size_g : integer := 16;
       m_rx_fifo_size_g : integer := 16;
       m_tx_burst_size_g : integer := 16;
       m_tx_fifo_size_g : integer := 16;
       papBigEnd_g : boolean := false;
       papDataWidth_g : integer := 8;
       papLowAct_g : boolean := false;
       pioValLen_g : integer := 50;
       spiBigEnd_g : boolean := false;
       spiCPHA_g : boolean := false;
       spiCPOL_g : boolean := false;
       use2ndCmpTimer_g : boolean := true;
       use2ndPhy_g : boolean := true;
       useHwAcc_g : boolean := false;
       useIntPacketBuf_g : boolean := true;
       useRmii_g : boolean := true;
       useRxIntPacketBuf_g : boolean := true
  );
  port (
       ap_address : in std_logic_vector(12 downto 0);
       ap_byteenable : in std_logic_vector(3 downto 0);
       ap_chipselect : in std_logic;
       ap_read : in std_logic;
       ap_write : in std_logic;
       ap_writedata : in std_logic_vector(31 downto 0);
       clk50 : in std_logic;
       clkAp : in std_logic;
       clkEth : in std_logic;
       clkPcp : in std_logic;
       m_clk : in std_logic;
       m_readdata : in std_logic_vector(15 downto 0) := (others => '0');
       m_readdatavalid : in std_logic := '0';
       m_waitrequest : in std_logic;
       mac_address : in std_logic_vector(11 downto 0);
       mac_byteenable : in std_logic_vector(1 downto 0);
       mac_chipselect : in std_logic;
       mac_read : in std_logic;
       mac_write : in std_logic;
       mac_writedata : in std_logic_vector(15 downto 0);
       mbf_address : in std_logic_vector(ibufsizelog2_g-3 downto 0);
       mbf_byteenable : in std_logic_vector(3 downto 0);
       mbf_chipselect : in std_logic;
       mbf_read : in std_logic;
       mbf_write : in std_logic;
       mbf_writedata : in std_logic_vector(31 downto 0);
       pap_addr : in std_logic_vector(15 downto 0);
       pap_be : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       pap_be_n : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       pap_cs : in std_logic;
       pap_cs_n : in std_logic;
       pap_rd : in std_logic;
       pap_rd_n : in std_logic;
       pap_wr : in std_logic;
       pap_wr_n : in std_logic;
       pcp_address : in std_logic_vector(12 downto 0);
       pcp_byteenable : in std_logic_vector(3 downto 0);
       pcp_chipselect : in std_logic;
       pcp_read : in std_logic;
       pcp_write : in std_logic;
       pcp_writedata : in std_logic_vector(31 downto 0);
       phy0_RxDat : in std_logic_vector(1 downto 0);
       phy0_RxDv : in std_logic;
       phy0_RxErr : in std_logic;
       phy0_link : in std_logic := '0';
       phy1_RxDat : in std_logic_vector(1 downto 0) := (others => '0');
       phy1_RxDv : in std_logic;
       phy1_RxErr : in std_logic;
       phy1_link : in std_logic := '0';
       phyMii0_RxClk : in std_logic;
       phyMii0_RxDat : in std_logic_vector(3 downto 0) := (others => '0');
       phyMii0_RxDv : in std_logic;
       phyMii0_RxEr : in std_logic;
       phyMii0_TxClk : in std_logic;
       phyMii1_RxClk : in std_logic;
       phyMii1_RxDat : in std_logic_vector(3 downto 0) := (others => '0');
       phyMii1_RxDv : in std_logic;
       phyMii1_RxEr : in std_logic;
       phyMii1_TxClk : in std_logic;
       pio_pconfig : in std_logic_vector(3 downto 0);
       pio_portInLatch : in std_logic_vector(3 downto 0);
       pkt_clk : in std_logic;
       rst : in std_logic;
       rstAp : in std_logic;
       rstPcp : in std_logic;
       smp_address : in std_logic;
       smp_byteenable : in std_logic_vector(3 downto 0);
       smp_read : in std_logic;
       smp_write : in std_logic;
       smp_writedata : in std_logic_vector(31 downto 0);
       spi_clk : in std_logic;
       spi_mosi : in std_logic;
       spi_sel_n : in std_logic;
       tcp_address : in std_logic_vector(1 downto 0);
       tcp_byteenable : in std_logic_vector(3 downto 0);
       tcp_chipselect : in std_logic;
       tcp_read : in std_logic;
       tcp_write : in std_logic;
       tcp_writedata : in std_logic_vector(31 downto 0);
       ap_asyncIrq : out std_logic := '0';
       ap_asyncIrq_n : out std_logic := '1';
       ap_irq : out std_logic := '0';
       ap_irq_n : out std_logic := '1';
       ap_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       led_error : out std_logic := '0';
       led_gpo : out std_logic_vector(7 downto 0) := (others => '0');
       led_opt : out std_logic_vector(1 downto 0) := (others => '0');
       led_phyAct : out std_logic_vector(1 downto 0) := (others => '0');
       led_phyLink : out std_logic_vector(1 downto 0) := (others => '0');
       led_status : out std_logic := '0';
       m_address : out std_logic_vector(29 downto 0) := (others => '0');
       m_burstcount : out std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_byteenable : out std_logic_vector(1 downto 0) := (others => '0');
       m_read : out std_logic := '0';
       m_write : out std_logic := '0';
       m_writedata : out std_logic_vector(15 downto 0) := (others => '0');
       mac_irq : out std_logic := '0';
       mac_readdata : out std_logic_vector(15 downto 0) := (others => '0');
       mac_waitrequest : out std_logic;
       mbf_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       mbf_waitrequest : out std_logic;
       pap_ack : out std_logic := '0';
       pap_ack_n : out std_logic := '1';
       pcp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       phy0_Rst_n : out std_logic := '1';
       phy0_SMIClk : out std_logic := '0';
       phy0_TxDat : out std_logic_vector(1 downto 0) := (others => '0');
       phy0_TxEn : out std_logic := '0';
       phy1_Rst_n : out std_logic := '1';
       phy1_SMIClk : out std_logic := '0';
       phy1_TxDat : out std_logic_vector(1 downto 0) := (others => '0');
       phy1_TxEn : out std_logic := '0';
       phyMii0_TxDat : out std_logic_vector(3 downto 0) := (others => '0');
       phyMii0_TxEn : out std_logic := '0';
       phyMii0_TxEr : out std_logic := '0';
       phyMii1_TxDat : out std_logic_vector(3 downto 0) := (others => '0');
       phyMii1_TxEn : out std_logic := '0';
       phyMii1_TxEr : out std_logic := '0';
       pio_operational : out std_logic := '0';
       pio_portOutValid : out std_logic_vector(3 downto 0) := (others => '0');
       smp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       spi_miso : out std_logic := '0';
       tcp_irq : out std_logic := '0';
       tcp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       tcp_waitrequest : out std_logic;
       pap_data : inout std_logic_vector(papDataWidth_g-1 downto 0) := (others => '0');
       pap_gpio : inout std_logic_vector(1 downto 0) := (others => '0');
       phy0_SMIDat : inout std_logic := '1';
       phy1_SMIDat : inout std_logic := '1';
       pio_portio : inout std_logic_vector(31 downto 0) := (others => '0')
  );
end component;
component plbv46_master_burst
  generic(
       C_FAMILY : string := "virtex5";
       C_INHIBIT_CC_BLE_INCLUSION : integer range 0 to 1 := 0;
       C_MPLB_AWIDTH : integer range 32 to 36 := 32;
       C_MPLB_DWIDTH : integer range 32 to 128 := 32;
       C_MPLB_NATIVE_DWIDTH : integer range 32 to 128 := 32;
       C_MPLB_SMALLEST_SLAVE : integer range 32 to 128 := 32
  );
  port (
       IP2Bus_MstRd_Req : in std_logic;
       IP2Bus_MstRd_dst_dsc_n : in std_logic;
       IP2Bus_MstRd_dst_rdy_n : in std_logic;
       IP2Bus_MstWr_Req : in std_logic;
       IP2Bus_MstWr_d : in std_logic_vector(0 to C_MPLB_NATIVE_DWIDTH-1);
       IP2Bus_MstWr_eof_n : in std_logic;
       IP2Bus_MstWr_rem : in std_logic_vector(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       IP2Bus_MstWr_sof_n : in std_logic;
       IP2Bus_MstWr_src_dsc_n : in std_logic;
       IP2Bus_MstWr_src_rdy_n : in std_logic;
       IP2Bus_Mst_Addr : in std_logic_vector(0 to C_MPLB_AWIDTH-1);
       IP2Bus_Mst_BE : in std_logic_vector(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       IP2Bus_Mst_Length : in std_logic_vector(0 to 11);
       IP2Bus_Mst_Lock : in std_logic;
       IP2Bus_Mst_Reset : in std_logic;
       IP2Bus_Mst_Type : in std_logic;
       MPLB_Clk : in std_logic;
       MPLB_Rst : in std_logic;
       PLB_MAddrAck : in std_logic;
       PLB_MBusy : in std_logic;
       PLB_MIRQ : in std_logic;
       PLB_MRdBTerm : in std_logic;
       PLB_MRdDAck : in std_logic;
       PLB_MRdDBus : in std_logic_vector(0 to C_MPLB_DWIDTH-1);
       PLB_MRdErr : in std_logic;
       PLB_MRdWdAddr : in std_logic_vector(0 to 3);
       PLB_MRearbitrate : in std_logic;
       PLB_MSSize : in std_logic_vector(0 to 1);
       PLB_MTimeout : in std_logic;
       PLB_MWrBTerm : in std_logic;
       PLB_MWrDAck : in std_logic;
       PLB_MWrErr : in std_logic;
       Bus2IP_MstRd_d : out std_logic_vector(0 to C_MPLB_NATIVE_DWIDTH-1);
       Bus2IP_MstRd_eof_n : out std_logic;
       Bus2IP_MstRd_rem : out std_logic_vector(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       Bus2IP_MstRd_sof_n : out std_logic;
       Bus2IP_MstRd_src_dsc_n : out std_logic;
       Bus2IP_MstRd_src_rdy_n : out std_logic;
       Bus2IP_MstWr_dst_dsc_n : out std_logic;
       Bus2IP_MstWr_dst_rdy_n : out std_logic;
       Bus2IP_Mst_CmdAck : out std_logic;
       Bus2IP_Mst_Cmd_Timeout : out std_logic;
       Bus2IP_Mst_Cmplt : out std_logic;
       Bus2IP_Mst_Error : out std_logic;
       Bus2IP_Mst_Rearbitrate : out std_logic;
       MD_Error : out std_logic;
       M_ABus : out std_logic_vector(0 to 31);
       M_BE : out std_logic_vector(0 to (C_MPLB_DWIDTH/8)-1);
       M_MSize : out std_logic_vector(0 to 1);
       M_RNW : out std_logic;
       M_TAttribute : out std_logic_vector(0 to 15);
       M_UABus : out std_logic_vector(0 to 31);
       M_abort : out std_logic;
       M_busLock : out std_logic;
       M_lockErr : out std_logic;
       M_priority : out std_logic_vector(0 to 1);
       M_rdBurst : out std_logic;
       M_request : out std_logic;
       M_size : out std_logic_vector(0 to 3);
       M_type : out std_logic_vector(0 to 2);
       M_wrBurst : out std_logic;
       M_wrDBus : out std_logic_vector(0 to C_MPLB_DWIDTH-1)
  );
end component;
component plbv46_slave_single
  generic(
       C_ARD_ADDR_RANGE_ARRAY : slv64_array_type := (X"0000_0000_7000_0000",X"0000_0000_7000_00FF",X"0000_0000_7000_0100",X"0000_0000_7000_01FF");
       C_ARD_NUM_CE_ARRAY : integer_array_type := (1,8);
       C_BUS2CORE_CLK_RATIO : integer range 1 to 2 := 1;
       C_FAMILY : string := "virtex4";
       C_INCLUDE_DPHASE_TIMER : integer range 0 to 1 := 1;
       C_SIPIF_DWIDTH : integer range 32 to 32 := 32;
       C_SPLB_AWIDTH : integer range 32 to 32 := 32;
       C_SPLB_DWIDTH : integer range 32 to 128 := 32;
       C_SPLB_MID_WIDTH : integer range 1 to 4 := 2;
       C_SPLB_NUM_MASTERS : integer range 1 to 16 := 8;
       C_SPLB_P2P : integer range 0 to 1 := 0
  );
  port (
       IP2Bus_Data : in std_logic_vector(0 to C_SIPIF_DWIDTH-1);
       IP2Bus_Error : in std_logic;
       IP2Bus_RdAck : in std_logic;
       IP2Bus_WrAck : in std_logic;
       PLB_ABus : in std_logic_vector(0 to 31);
       PLB_BE : in std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
       PLB_MSize : in std_logic_vector(0 to 1);
       PLB_PAValid : in std_logic;
       PLB_RNW : in std_logic;
       PLB_SAValid : in std_logic;
       PLB_TAttribute : in std_logic_vector(0 to 15);
       PLB_UABus : in std_logic_vector(0 to 31);
       PLB_abort : in std_logic;
       PLB_busLock : in std_logic;
       PLB_lockErr : in std_logic;
       PLB_masterID : in std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
       PLB_rdBurst : in std_logic;
       PLB_rdPendPri : in std_logic_vector(0 to 1);
       PLB_rdPendReq : in std_logic;
       PLB_rdPrim : in std_logic;
       PLB_reqPri : in std_logic_vector(0 to 1);
       PLB_size : in std_logic_vector(0 to 3);
       PLB_type : in std_logic_vector(0 to 2);
       PLB_wrBurst : in std_logic;
       PLB_wrDBus : in std_logic_vector(0 to C_SPLB_DWIDTH-1);
       PLB_wrPendPri : in std_logic_vector(0 to 1);
       PLB_wrPendReq : in std_logic;
       PLB_wrPrim : in std_logic;
       SPLB_Clk : in std_logic;
       SPLB_Rst : in std_logic;
       Bus2IP_Addr : out std_logic_vector(0 to C_SPLB_AWIDTH-1);
       Bus2IP_BE : out std_logic_vector(0 to (C_SIPIF_DWIDTH/8)-1);
       Bus2IP_CS : out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
       Bus2IP_Clk : out std_logic;
       Bus2IP_Data : out std_logic_vector(0 to C_SIPIF_DWIDTH-1);
       Bus2IP_RNW : out std_logic;
       Bus2IP_RdCE : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
       Bus2IP_Reset : out std_logic;
       Bus2IP_WrCE : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
       Sl_MBusy : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MIRQ : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MRdErr : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MWrErr : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
       Sl_SSize : out std_logic_vector(0 to 1);
       Sl_addrAck : out std_logic;
       Sl_rdBTerm : out std_logic;
       Sl_rdComp : out std_logic;
       Sl_rdDAck : out std_logic;
       Sl_rdDBus : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
       Sl_rdWdAddr : out std_logic_vector(0 to 3);
       Sl_rearbitrate : out std_logic;
       Sl_wait : out std_logic;
       Sl_wrBTerm : out std_logic;
       Sl_wrComp : out std_logic;
       Sl_wrDAck : out std_logic
  );
end component;

---- Architecture declarations -----
--
constant C_FAMILY : string := "virtex6";
constant C_ADDR_PAD_ZERO : std_logic_vector(31 downto 0) := (others => '0');
-- openMAC REG PLB Slave
constant C_MAC_REG_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_REG_BASEADDR;
constant C_MAC_REG_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_REG_HIGHADDR;
-- openMAC CMP PLB Slave
constant C_MAC_CMP_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_CMP_BASEADDR;
constant C_MAC_CMP_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_CMP_HIGHADDR;


---- Signal declarations used on the diagram ----

signal ap_chipselect : std_logic;
signal ap_read : std_logic;
signal ap_write : std_logic;
signal Bus2CMP_REG_Clk : std_logic;
signal Bus2CMP_REG_Reset : std_logic;
signal Bus2CMP_REG_RNW : std_logic;
signal Bus2MAC_DMA_MstRd_eof_n : std_logic;
signal Bus2MAC_DMA_MstRd_sof_n : std_logic;
signal Bus2MAC_DMA_MstRd_src_dsc_n : std_logic;
signal Bus2MAC_DMA_MstRd_src_rdy_n : std_logic;
signal Bus2MAC_DMA_MstWr_dst_dsc_n : std_logic;
signal Bus2MAC_DMA_MstWr_dst_rdy_n : std_logic;
signal Bus2MAC_DMA_Mst_CmdAck : std_logic;
signal Bus2MAC_DMA_Mst_Cmd_Timeout : std_logic;
signal Bus2MAC_DMA_Mst_Cmplt : std_logic;
signal Bus2MAC_DMA_Mst_Error : std_logic;
signal Bus2MAC_DMA_Mst_Rearbitrate : std_logic;
signal Bus2MAC_REG_Clk : std_logic;
signal Bus2MAC_REG_Reset : std_logic;
signal Bus2MAC_REG_RNW : std_logic;
signal clk50 : std_logic;
signal clkAp : std_logic;
signal clkEth : std_logic;
signal clkPcp : std_logic;
signal mac_chipselect : std_logic;
signal MAC_CMP2Bus_Error : std_logic;
signal MAC_CMP2Bus_RdAck : std_logic;
signal MAC_CMP2Bus_WrAck : std_logic;
signal MAC_DMA2Bus_MstRd_dst_dsc_n : std_logic;
signal MAC_DMA2Bus_MstRd_dst_rdy_n : std_logic;
signal MAC_DMA2Bus_MstRd_Req : std_logic;
signal MAC_DMA2Bus_MstWr_eof_n : std_logic;
signal MAC_DMA2Bus_MstWr_Req : std_logic;
signal MAC_DMA2Bus_MstWr_sof_n : std_logic;
signal MAC_DMA2Bus_MstWr_src_dsc_n : std_logic;
signal MAC_DMA2Bus_MstWr_src_rdy_n : std_logic;
signal MAC_DMA2Bus_Mst_Lock : std_logic;
signal MAC_DMA2Bus_Mst_Reset : std_logic;
signal MAC_DMA2Bus_Mst_Type : std_logic;
signal mac_read : std_logic;
signal MAC_REG2Bus_Error : std_logic;
signal MAC_REG2Bus_RdAck : std_logic;
signal MAC_REG2Bus_WrAck : std_logic;
signal mac_waitrequest : std_logic;
signal mac_write : std_logic;
signal mbf_chipselect : std_logic;
signal mbf_read : std_logic;
signal mbf_waitrequest : std_logic;
signal mbf_write : std_logic;
signal m_clk : std_logic;
signal m_read : std_logic;
signal m_readdatavalid : std_logic;
signal m_waitrequest : std_logic;
signal m_write : std_logic;
signal pcp_chipselect : std_logic;
signal pcp_read : std_logic;
signal pcp_write : std_logic;
signal pkt_clk : std_logic;
signal rst : std_logic;
signal rstAp : std_logic;
signal rstPcp : std_logic;
signal smp_address : std_logic;
signal smp_read : std_logic;
signal smp_write : std_logic;
signal tcp_chipselect : std_logic;
signal tcp_read : std_logic;
signal tcp_waitrequest : std_logic;
signal tcp_write : std_logic;
signal ap_address : std_logic_vector (12 downto 0);
signal ap_byteenable : std_logic_vector (3 downto 0);
signal ap_readdata : std_logic_vector (31 downto 0);
signal ap_writedata : std_logic_vector (31 downto 0);
signal Bus2CMP_REG_Addr : std_logic_vector (C_MAC_REG_PLB_AWIDTH-1 downto 0);
signal Bus2CMP_REG_BE : std_logic_vector ((C_MAC_REG_PLB_DWIDTH/8)-1 downto 0);
signal Bus2CMP_REG_CS : std_logic_vector (0 downto 0);
signal Bus2CMP_REG_Data : std_logic_vector (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal Bus2MAC_DMA_MstRd_d : std_logic_vector (0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1);
signal Bus2MAC_DMA_MstRd_rem : std_logic_vector (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal Bus2MAC_REG_Addr : std_logic_vector (C_MAC_REG_PLB_AWIDTH-1 downto 0);
signal Bus2MAC_REG_BE : std_logic_vector ((C_MAC_REG_PLB_DWIDTH/8)-1 downto 0);
signal Bus2MAC_REG_CS : std_logic_vector (0 downto 0);
signal Bus2MAC_REG_Data : std_logic_vector (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal mac_address : std_logic_vector (11 downto 0);
signal mac_byteenable : std_logic_vector (1 downto 0);
signal MAC_CMP2Bus_Data : std_logic_vector (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal MAC_DMA2Bus_MstWr_d : std_logic_vector (0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1);
signal MAC_DMA2Bus_MstWr_rem : std_logic_vector (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal MAC_DMA2Bus_Mst_Addr : std_logic_vector (0 to C_MAC_DMA_PLB_AWIDTH-1);
signal MAC_DMA2Bus_Mst_BE : std_logic_vector (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal MAC_DMA2Bus_Mst_Length : std_logic_vector (0 to 11);
signal mac_readdata : std_logic_vector (15 downto 0);
signal MAC_REG2Bus_Data : std_logic_vector (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal mac_writedata : std_logic_vector (15 downto 0);
signal mbf_address : std_logic_vector (ibufsizelog2_g-3 downto 0);
signal mbf_byteenable : std_logic_vector (3 downto 0);
signal mbf_readdata : std_logic_vector (31 downto 0);
signal mbf_writedata : std_logic_vector (31 downto 0);
signal m_address : std_logic_vector (29 downto 0);
signal m_burstcount : std_logic_vector (m_burstcount_width_g-1 downto 0);
signal m_byteenable : std_logic_vector (1 downto 0);
signal m_readdata : std_logic_vector (15 downto 0);
signal m_writedata : std_logic_vector (15 downto 0);
signal pcp_address : std_logic_vector (12 downto 0);
signal pcp_byteenable : std_logic_vector (3 downto 0);
signal pcp_readdata : std_logic_vector (31 downto 0);
signal pcp_writedata : std_logic_vector (31 downto 0);
signal smp_byteenable : std_logic_vector (3 downto 0);
signal smp_readdata : std_logic_vector (31 downto 0);
signal smp_writedata : std_logic_vector (31 downto 0);
signal tcp_address : std_logic_vector (1 downto 0);
signal tcp_byteenable : std_logic_vector (3 downto 0);
signal tcp_readdata : std_logic_vector (31 downto 0);
signal tcp_writedata : std_logic_vector (31 downto 0);

begin

----  Component instantiations  ----

MAC_CMP_PLB_SINGLE_SLAVE : plbv46_slave_single
  generic map (
       C_ARD_ADDR_RANGE_ARRAY => (C_MAC_CMP_BASE,C_MAC_CMP_HIGH),
       C_ARD_NUM_CE_ARRAY => (0 => 1),
       C_BUS2CORE_CLK_RATIO => 1,
       C_FAMILY => C_FAMILY,
       C_INCLUDE_DPHASE_TIMER => 0,
       C_SIPIF_DWIDTH => C_MAC_CMP_PLB_DWIDTH,
       C_SPLB_AWIDTH => C_MAC_CMP_PLB_AWIDTH,
       C_SPLB_DWIDTH => C_MAC_CMP_PLB_DWIDTH,
       C_SPLB_MID_WIDTH => C_MAC_CMP_PLB_MID_WIDTH,
       C_SPLB_NUM_MASTERS => C_MAC_CMP_NUM_MASTERS,
       C_SPLB_P2P => C_MAC_REG_PLB_P2P
  )
  port map(
       Bus2IP_Addr => Bus2CMP_REG_Addr( C_MAC_REG_PLB_AWIDTH-1 downto 0 ),
       Bus2IP_BE => Bus2CMP_REG_BE( (C_MAC_REG_PLB_DWIDTH/8)-1 downto 0 ),
       Bus2IP_CS => Bus2CMP_REG_CS( 0 downto 0 ),
       Bus2IP_Clk => Bus2CMP_REG_Clk,
       Bus2IP_Data => Bus2CMP_REG_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       Bus2IP_RNW => Bus2CMP_REG_RNW,
       Bus2IP_Reset => Bus2CMP_REG_Reset,
       IP2Bus_Data => MAC_CMP2Bus_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       IP2Bus_Error => MAC_CMP2Bus_Error,
       IP2Bus_RdAck => MAC_CMP2Bus_RdAck,
       IP2Bus_WrAck => MAC_CMP2Bus_WrAck,
       PLB_ABus => MAC_CMP_ABus,
       PLB_BE => MAC_CMP_BE( 0 to (C_MAC_CMP_PLB_DWIDTH/8)-1 ),
       PLB_MSize => MAC_CMP_MSize,
       PLB_PAValid => MAC_CMP_PAValid,
       PLB_RNW => MAC_CMP_RNW,
       PLB_SAValid => MAC_CMP_SAValid,
       PLB_TAttribute => MAC_CMP_TAttribute,
       PLB_UABus => MAC_CMP_UABus,
       PLB_abort => MAC_CMP_abort,
       PLB_busLock => MAC_CMP_busLock,
       PLB_lockErr => MAC_CMP_lockErr,
       PLB_masterID => MAC_CMP_masterID( 0 to C_MAC_CMP_PLB_MID_WIDTH-1 ),
       PLB_rdBurst => MAC_CMP_rdBurst,
       PLB_rdPendPri => MAC_CMP_rdPendPri,
       PLB_rdPendReq => MAC_CMP_rdPendReq,
       PLB_rdPrim => MAC_CMP_rdPrim,
       PLB_reqPri => MAC_CMP_reqPri,
       PLB_size => MAC_CMP_size,
       PLB_type => MAC_CMP_type,
       PLB_wrBurst => MAC_CMP_wrBurst,
       PLB_wrDBus => MAC_CMP_wrDBus( 0 to C_MAC_CMP_PLB_DWIDTH-1 ),
       PLB_wrPendPri => MAC_CMP_wrPendPri,
       PLB_wrPendReq => MAC_CMP_wrPendReq,
       PLB_wrPrim => MAC_CMP_wrPrim,
       SPLB_Clk => MAC_CMP_Clk,
       SPLB_Rst => MAC_CMP_Rst,
       Sl_MBusy => MAC_CMP_MBusy( 0 to C_MAC_CMP_NUM_MASTERS-1 ),
       Sl_MIRQ => MAC_CMP_MIRQ( 0 to C_MAC_CMP_NUM_MASTERS-1 ),
       Sl_MRdErr => MAC_CMP_MRdErr( 0 to C_MAC_CMP_NUM_MASTERS-1 ),
       Sl_MWrErr => MAC_CMP_MWrErr( 0 to C_MAC_CMP_NUM_MASTERS-1 ),
       Sl_SSize => MAC_CMP_SSize,
       Sl_addrAck => MAC_CMP_addrAck,
       Sl_rdBTerm => MAC_CMP_rdBTerm,
       Sl_rdComp => MAC_CMP_rdComp,
       Sl_rdDAck => MAC_CMP_rdDAck,
       Sl_rdDBus => MAC_CMP_rdDBus( 0 to C_MAC_CMP_PLB_DWIDTH-1 ),
       Sl_rdWdAddr => MAC_CMP_rdWdAddr,
       Sl_rearbitrate => MAC_CMP_rearbitrate,
       Sl_wait => MAC_CMP_wait,
       Sl_wrBTerm => MAC_CMP_wrBTerm,
       Sl_wrComp => MAC_CMP_wrComp,
       Sl_wrDAck => MAC_CMP_wrDAck
  );

MAC_DMA_PLB_BURST_MASTER : plbv46_master_burst
  generic map (
       C_FAMILY => C_FAMILY,
       C_INHIBIT_CC_BLE_INCLUSION => 1,
       C_MPLB_AWIDTH => C_MAC_DMA_PLB_AWIDTH,
       C_MPLB_DWIDTH => C_MAC_DMA_PLB_DWIDTH,
       C_MPLB_NATIVE_DWIDTH => C_MAC_DMA_PLB_NATIVE_DWIDTH,
       C_MPLB_SMALLEST_SLAVE => 32
  )
  port map(
       Bus2IP_MstRd_d => Bus2MAC_DMA_MstRd_d( 0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1 ),
       Bus2IP_MstRd_eof_n => Bus2MAC_DMA_MstRd_eof_n,
       Bus2IP_MstRd_rem => Bus2MAC_DMA_MstRd_rem( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
       Bus2IP_MstRd_sof_n => Bus2MAC_DMA_MstRd_sof_n,
       Bus2IP_MstRd_src_dsc_n => Bus2MAC_DMA_MstRd_src_dsc_n,
       Bus2IP_MstRd_src_rdy_n => Bus2MAC_DMA_MstRd_src_rdy_n,
       Bus2IP_MstWr_dst_dsc_n => Bus2MAC_DMA_MstWr_dst_dsc_n,
       Bus2IP_MstWr_dst_rdy_n => Bus2MAC_DMA_MstWr_dst_rdy_n,
       Bus2IP_Mst_CmdAck => Bus2MAC_DMA_Mst_CmdAck,
       Bus2IP_Mst_Cmd_Timeout => Bus2MAC_DMA_Mst_Cmd_Timeout,
       Bus2IP_Mst_Cmplt => Bus2MAC_DMA_Mst_Cmplt,
       Bus2IP_Mst_Error => Bus2MAC_DMA_Mst_Error,
       Bus2IP_Mst_Rearbitrate => Bus2MAC_DMA_Mst_Rearbitrate,
       IP2Bus_MstRd_Req => MAC_DMA2Bus_MstRd_Req,
       IP2Bus_MstRd_dst_dsc_n => MAC_DMA2Bus_MstRd_dst_dsc_n,
       IP2Bus_MstRd_dst_rdy_n => MAC_DMA2Bus_MstRd_dst_rdy_n,
       IP2Bus_MstWr_Req => MAC_DMA2Bus_MstWr_Req,
       IP2Bus_MstWr_d => MAC_DMA2Bus_MstWr_d( 0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1 ),
       IP2Bus_MstWr_eof_n => MAC_DMA2Bus_MstWr_eof_n,
       IP2Bus_MstWr_rem => MAC_DMA2Bus_MstWr_rem( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
       IP2Bus_MstWr_sof_n => MAC_DMA2Bus_MstWr_sof_n,
       IP2Bus_MstWr_src_dsc_n => MAC_DMA2Bus_MstWr_src_dsc_n,
       IP2Bus_MstWr_src_rdy_n => MAC_DMA2Bus_MstWr_src_rdy_n,
       IP2Bus_Mst_Addr => MAC_DMA2Bus_Mst_Addr( 0 to C_MAC_DMA_PLB_AWIDTH-1 ),
       IP2Bus_Mst_BE => MAC_DMA2Bus_Mst_BE( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
       IP2Bus_Mst_Length => MAC_DMA2Bus_Mst_Length,
       IP2Bus_Mst_Lock => MAC_DMA2Bus_Mst_Lock,
       IP2Bus_Mst_Reset => MAC_DMA2Bus_Mst_Reset,
       IP2Bus_Mst_Type => MAC_DMA2Bus_Mst_Type,
       MD_Error => MAC_DMA_error,
       MPLB_Clk => MAC_DMA_Clk,
       MPLB_Rst => MAC_DMA_Rst,
       M_ABus => MAC_DMA_ABus,
       M_BE => MAC_DMA_BE( 0 to (C_MAC_DMA_PLB_DWIDTH/8)-1 ),
       M_MSize => MAC_DMA_MSize,
       M_RNW => MAC_DMA_RNW,
       M_TAttribute => MAC_DMA_TAttribute,
       M_UABus => MAC_DMA_UABus,
       M_abort => MAC_DMA_abort,
       M_busLock => MAC_DMA_busLock,
       M_lockErr => MAC_DMA_lockErr,
       M_priority => MAC_DMA_priority,
       M_rdBurst => MAC_DMA_rdBurst,
       M_request => MAC_DMA_request,
       M_size => MAC_DMA_size,
       M_type => MAC_DMA_type,
       M_wrBurst => MAC_DMA_wrBurst,
       M_wrDBus => MAC_DMA_wrDBus( 0 to C_MAC_DMA_PLB_DWIDTH-1 ),
       PLB_MAddrAck => MAC_DMA_MAddrAck,
       PLB_MBusy => MAC_DMA_MBusy,
       PLB_MIRQ => MAC_DMA_MIRQ,
       PLB_MRdBTerm => MAC_DMA_MRdBTerm,
       PLB_MRdDAck => MAC_DMA_MRdDAck,
       PLB_MRdDBus => MAC_DMA_MRdDBus( 0 to C_MAC_DMA_PLB_DWIDTH-1 ),
       PLB_MRdErr => MAC_DMA_MRdErr,
       PLB_MRdWdAddr => MAC_DMA_MRdWdAddr,
       PLB_MRearbitrate => MAC_DMA_MRearbitrate,
       PLB_MSSize => MAC_DMA_MSSize,
       PLB_MTimeout => MAC_DMA_MTimeout,
       PLB_MWrBTerm => MAC_DMA_MWrBTerm,
       PLB_MWrDAck => MAC_DMA_MWrDAck,
       PLB_MWrErr => MAC_DMA_MWrErr
  );

MAC_REG_PLB_SINGLE_SLAVE : plbv46_slave_single
  generic map (
       C_ARD_ADDR_RANGE_ARRAY => (C_MAC_REG_BASE,C_MAC_REG_HIGH),
       C_ARD_NUM_CE_ARRAY => (0 => 1),
       C_BUS2CORE_CLK_RATIO => 1,
       C_FAMILY => C_FAMILY,
       C_INCLUDE_DPHASE_TIMER => 0,
       C_SIPIF_DWIDTH => C_MAC_REG_PLB_DWIDTH,
       C_SPLB_AWIDTH => C_MAC_REG_PLB_AWIDTH,
       C_SPLB_DWIDTH => C_MAC_REG_PLB_DWIDTH,
       C_SPLB_MID_WIDTH => 1,
       C_SPLB_NUM_MASTERS => C_MAC_REG_NUM_MASTERS,
       C_SPLB_P2P => C_MAC_REG_PLB_P2P
  )
  port map(
       Bus2IP_Addr => Bus2MAC_REG_Addr( C_MAC_REG_PLB_AWIDTH-1 downto 0 ),
       Bus2IP_BE => Bus2MAC_REG_BE( (C_MAC_REG_PLB_DWIDTH/8)-1 downto 0 ),
       Bus2IP_CS => Bus2MAC_REG_CS( 0 downto 0 ),
       Bus2IP_Clk => Bus2MAC_REG_Clk,
       Bus2IP_Data => Bus2MAC_REG_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       Bus2IP_RNW => Bus2MAC_REG_RNW,
       Bus2IP_Reset => Bus2MAC_REG_Reset,
       IP2Bus_Data => MAC_REG2Bus_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       IP2Bus_Error => MAC_REG2Bus_Error,
       IP2Bus_RdAck => MAC_REG2Bus_RdAck,
       IP2Bus_WrAck => MAC_REG2Bus_WrAck,
       PLB_ABus => MAC_REG_ABus,
       PLB_BE => MAC_REG_BE( 0 to (C_MAC_REG_PLB_DWIDTH / 8) - 1 ),
       PLB_MSize => MAC_REG_MSize,
       PLB_PAValid => MAC_REG_PAValid,
       PLB_RNW => MAC_REG_RNW,
       PLB_SAValid => MAC_REG_SAValid,
       PLB_TAttribute => MAC_REG_TAttribute,
       PLB_UABus => MAC_REG_UABus,
       PLB_abort => MAC_REG_abort,
       PLB_busLock => MAC_REG_busLock,
       PLB_lockErr => MAC_REG_lockErr,
       PLB_masterID => MAC_REG_masterID( 0 to C_MAC_REG_PLB_MID_WIDTH - 1 ),
       PLB_rdBurst => MAC_REG_rdBurst,
       PLB_rdPendPri => MAC_REG_rdPendPri,
       PLB_rdPendReq => MAC_REG_rdPendReq,
       PLB_rdPrim => MAC_REG_rdPrim,
       PLB_reqPri => MAC_REG_reqPri,
       PLB_size => MAC_REG_size,
       PLB_type => MAC_REG_type,
       PLB_wrBurst => MAC_REG_wrBurst,
       PLB_wrDBus => MAC_REG_wrDBus( 0 to C_MAC_REG_PLB_DWIDTH - 1 ),
       PLB_wrPendPri => MAC_REG_wrPendPri,
       PLB_wrPendReq => MAC_REG_wrPendReq,
       PLB_wrPrim => MAC_REG_wrPrim,
       SPLB_Clk => MAC_REG_Clk,
       SPLB_Rst => MAC_REG_Rst,
       Sl_MBusy => MAC_REG_MBusy( 0 to C_MAC_REG_NUM_MASTERS-1 ),
       Sl_MIRQ => MAC_REG_MIRQ( 0 to C_MAC_REG_NUM_MASTERS-1 ),
       Sl_MRdErr => MAC_REG_MRdErr( 0 to C_MAC_REG_NUM_MASTERS-1 ),
       Sl_MWrErr => MAC_REG_MWrErr( 0 to C_MAC_REG_NUM_MASTERS-1 ),
       Sl_SSize => MAC_REG_SSize,
       Sl_addrAck => MAC_REG_addrAck,
       Sl_rdBTerm => MAC_REG_rdBTerm,
       Sl_rdComp => MAC_REG_rdComp,
       Sl_rdDAck => MAC_REG_rdDAck,
       Sl_rdDBus => MAC_REG_rdDBus( 0 to C_MAC_REG_PLB_DWIDTH-1 ),
       Sl_rdWdAddr => MAC_REG_rdWdAddr,
       Sl_rearbitrate => MAC_REG_rearbitrate,
       Sl_wait => MAC_REG_wait,
       Sl_wrBTerm => MAC_REG_wrBTerm,
       Sl_wrComp => MAC_REG_wrComp,
       Sl_wrDAck => MAC_REG_wrDAck
  );

THE_POWERLINK_IP_CORE : powerlink
  generic map (
       Simulate => false,
       genABuf1_g => true,
       genABuf2_g => true,
       genAvalonAp_g => true,
       genLedGadget_g => false,
       genOnePdiClkDomain_g => false,
       genPdi_g => false,
       genSimpleIO_g => false,
       genSpiAp_g => false,
       iAsyBuf1Size_g => 100,
       iAsyBuf2Size_g => 100,
       iBufSizeLOG2_g => ibufsizelog2_g,
       iBufSize_g => 2*ibufsizelog2_g,
       iPdiRev_g => 21930,
       iRpdo0BufSize_g => 100,
       iRpdo1BufSize_g => 100,
       iRpdo2BufSize_g => 100,
       iRpdos_g => 3,
       iTpdoBufSize_g => 100,
       iTpdos_g => 1,
       m_burstcount_width_g => m_burstcount_width_g,
       m_rx_burst_size_g => 16,
       m_rx_fifo_size_g => 16,
       m_tx_burst_size_g => 16,
       m_tx_fifo_size_g => 16,
       papBigEnd_g => false,
       papDataWidth_g => papDataWidth_g,
       papLowAct_g => false,
       pioValLen_g => 50,
       spiBigEnd_g => false,
       spiCPHA_g => false,
       spiCPOL_g => false,
       use2ndCmpTimer_g => false,
       use2ndPhy_g => true,
       useHwAcc_g => false,
       useIntPacketBuf_g => true,
       useRmii_g => false,
       useRxIntPacketBuf_g => true
  )
  port map(
       ap_address => ap_address,
       ap_asyncIrq => ap_asyncIrq,
       ap_asyncIrq_n => ap_asyncIrq_n,
       ap_byteenable => ap_byteenable,
       ap_chipselect => ap_chipselect,
       ap_irq => ap_irq,
       ap_irq_n => ap_irq_n,
       ap_read => ap_read,
       ap_readdata => ap_readdata,
       ap_write => ap_write,
       ap_writedata => ap_writedata,
       clk50 => clk50,
       clkAp => clkAp,
       clkEth => clkEth,
       clkPcp => clkPcp,
       led_error => led_error,
       led_gpo => led_gpo,
       led_opt => led_opt,
       led_phyAct => led_phyAct,
       led_phyLink => led_phyLink,
       led_status => led_status,
       m_address => m_address,
       m_burstcount => m_burstcount( m_burstcount_width_g-1 downto 0 ),
       m_byteenable => m_byteenable,
       m_clk => m_clk,
       m_read => m_read,
       m_readdata => m_readdata,
       m_readdatavalid => m_readdatavalid,
       m_waitrequest => m_waitrequest,
       m_write => m_write,
       m_writedata => m_writedata,
       mac_address => mac_address,
       mac_byteenable => mac_byteenable,
       mac_chipselect => mac_chipselect,
       mac_irq => mac_irq,
       mac_read => mac_read,
       mac_readdata => mac_readdata,
       mac_waitrequest => mac_waitrequest,
       mac_write => mac_write,
       mac_writedata => mac_writedata,
       mbf_address => mbf_address( ibufsizelog2_g-3 downto 0 ),
       mbf_byteenable => mbf_byteenable,
       mbf_chipselect => mbf_chipselect,
       mbf_read => mbf_read,
       mbf_readdata => mbf_readdata,
       mbf_waitrequest => mbf_waitrequest,
       mbf_write => mbf_write,
       mbf_writedata => mbf_writedata,
       pap_ack => pap_ack,
       pap_ack_n => pap_ack_n,
       pap_addr => pap_addr,
       pap_be => pap_be( papDataWidth_g/8-1 downto 0 ),
       pap_be_n => pap_be_n( papDataWidth_g/8-1 downto 0 ),
       pap_cs => pap_cs,
       pap_cs_n => pap_cs_n,
       pap_data => pap_data( papDataWidth_g-1 downto 0 ),
       pap_gpio => pap_gpio,
       pap_rd => pap_rd,
       pap_rd_n => pap_rd_n,
       pap_wr => pap_wr,
       pap_wr_n => pap_wr_n,
       pcp_address => pcp_address,
       pcp_byteenable => pcp_byteenable,
       pcp_chipselect => pcp_chipselect,
       pcp_read => pcp_read,
       pcp_readdata => pcp_readdata,
       pcp_write => pcp_write,
       pcp_writedata => pcp_writedata,
       phy0_Rst_n => phy0_Rst_n,
       phy0_RxDat => phy0_RxDat,
       phy0_RxDv => phy0_RxDv,
       phy0_RxErr => phy0_RxErr,
       phy0_SMIClk => phy0_SMIClk,
       phy0_SMIDat => phy0_SMIDat,
       phy0_TxDat => phy0_TxDat,
       phy0_TxEn => phy0_TxEn,
       phy0_link => phy0_link,
       phy1_Rst_n => phy1_Rst_n,
       phy1_RxDat => phy1_RxDat,
       phy1_RxDv => phy1_RxDv,
       phy1_RxErr => phy1_RxErr,
       phy1_SMIClk => phy1_SMIClk,
       phy1_SMIDat => phy1_SMIDat,
       phy1_TxDat => phy1_TxDat,
       phy1_TxEn => phy1_TxEn,
       phy1_link => phy1_link,
       phyMii0_RxClk => phyMii0_RxClk,
       phyMii0_RxDat => phyMii0_RxDat,
       phyMii0_RxDv => phyMii0_RxDv,
       phyMii0_RxEr => phyMii0_RxEr,
       phyMii0_TxClk => phyMii0_TxClk,
       phyMii0_TxDat => phyMii0_TxDat,
       phyMii0_TxEn => phyMii0_TxEn,
       phyMii0_TxEr => phyMii0_TxEr,
       phyMii1_RxClk => phyMii1_RxClk,
       phyMii1_RxDat => phyMii1_RxDat,
       phyMii1_RxDv => phyMii1_RxDv,
       phyMii1_RxEr => phyMii1_RxEr,
       phyMii1_TxClk => phyMii1_TxClk,
       phyMii1_TxDat => phyMii1_TxDat,
       phyMii1_TxEn => phyMii1_TxEn,
       phyMii1_TxEr => phyMii1_TxEr,
       pio_operational => pio_operational,
       pio_pconfig => pio_pconfig,
       pio_portInLatch => pio_portInLatch,
       pio_portOutValid => pio_portOutValid,
       pio_portio => pio_portio,
       pkt_clk => pkt_clk,
       rst => rst,
       rstAp => rstAp,
       rstPcp => rstPcp,
       smp_address => smp_address,
       smp_byteenable => smp_byteenable,
       smp_read => smp_read,
       smp_readdata => smp_readdata,
       smp_write => smp_write,
       smp_writedata => smp_writedata,
       spi_clk => spi_clk,
       spi_miso => spi_miso,
       spi_mosi => spi_mosi,
       spi_sel_n => spi_sel_n,
       tcp_address => tcp_address,
       tcp_byteenable => tcp_byteenable,
       tcp_chipselect => tcp_chipselect,
       tcp_irq => tcp_irq,
       tcp_read => tcp_read,
       tcp_readdata => tcp_readdata,
       tcp_waitrequest => tcp_waitrequest,
       tcp_write => tcp_write,
       tcp_writedata => tcp_writedata
  );


end struct;
