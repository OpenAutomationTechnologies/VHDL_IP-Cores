-------------------------------------------------------------------------------
--
-- Title       : plb_powerlink
-- Design      : POWERLINK
-- Author      : Unknown
-- Company     : Unknown
--
-------------------------------------------------------------------------------
--
-- File        : C:\mairt\workspace\VHDL_IP-Cores_mairt\active_hdl\compile\plb_powerlink.vhd
-- Generated   : Tue Dec  6 08:47:07 2011
-- From        : C:\mairt\workspace\VHDL_IP-Cores_mairt\active_hdl\src\plb_powerlink.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
--
-- This is the toplevel file for using the POWERLINK IP-Core
-- with Xilinx PLB V4.6.
--
-------------------------------------------------------------------------------
--
-- 2011-09-13  	V0.01	zelenkaj	First version
-- 2011-11-24 	V0.02	mairt    	added slave interface for pdi pcp and pdi ap
-- 2011-11-26 	V0.03	mairt    	added slave interface for simpleIO
-- 2011-12-02	V0.04	zelenkaj	Exchanged IOs with _I, _O and _T
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

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
       -- general
       C_GEN_PDI : boolean := false;
       C_GEN_PAR_IF : boolean := false;
       C_GEN_SPI_IF : boolean := false;
       C_GEN_PLB_BUS_IF : boolean := false;
       C_GEN_SIMPLE_IO : boolean := false;
       -- openMAC
       C_MAC_PKT_SIZE : integer := 1024;
       C_MAC_PKT_SIZE_LOG2 : integer := 10;
       C_USE_RMII : boolean := false;
       C_TX_INT_PKT : boolean := false;
       C_RX_INT_PKT : boolean := false;
       C_USE_2ND_PHY : boolean := true;
       --pdi
       C_PDI_GEN_ASYNC_BUF_0 : boolean := true;
       C_PDI_ASYNC_BUF_0 : integer := 50;
       C_PDI_GEN_ASYNC_BUF_1 : boolean := true;
       C_PDI_ASYNC_BUF_1 : integer := 50;
       C_PDI_GEN_LED : boolean := false;
       C_PDI_GEN_TIME_SYNC : boolean := true;
       C_PDI_GEN_SECOND_TIMER : boolean := false;
       --global pdi and mac
       C_NUM_RPDO : integer := 3;
       C_RPDO_0_BUF_SIZE : integer := 100;
       C_RPDO_1_BUF_SIZE : integer := 100;
       C_RPDO_2_BUF_SIZE : integer := 100;
       C_NUM_TPDO : integer := 1;
       C_TPDO_BUF_SIZE : integer := 100;
       -- pap
       C_PAP_DATA_WIDTH : integer := 16;
       C_PAP_BIG_END : boolean := false;
       C_PAP_LOW_ACT : boolean := false;
       -- spi
       C_SPI_CPOL : boolean := false;
       C_SPI_CPHA : boolean := false;
       C_SPI_BIG_END : boolean := false;
       -- simpleIO
       C_PIO_VAL_LENGTH : integer := 50;
       -- PDI AP PLB Slave
       C_PDI_AP_BASEADDR : std_logic_vector := X"00000000";
       C_PDI_AP_HIGHADDR : std_logic_vector := X"000FFFFF";
       C_PDI_AP_NUM_MASTERS : INTEGER := 1;
       C_PDI_AP_PLB_AWIDTH : INTEGER := 32;
       C_PDI_AP_PLB_DWIDTH : INTEGER := 32;
       C_PDI_AP_PLB_MID_WIDTH : INTEGER := 1;
       C_PDI_AP_PLB_P2P : INTEGER := 0;
       C_PDI_AP_PLB_NUM_MASTERS : INTEGER := 1;
       C_PDI_AP_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_PDI_AP_PLB_SUPPORT_BURSTS : INTEGER := 0;
       -- PDI AP PLB Slave
       C_SMP_PCP_BASEADDR : std_logic_vector := X"00000000";
       C_SMP_PCP_HIGHADDR : std_logic_vector := X"000FFFFF";
       C_SMP_PCP_NUM_MASTERS : INTEGER := 1;
       C_SMP_PCP_PLB_AWIDTH : INTEGER := 32;
       C_SMP_PCP_PLB_DWIDTH : INTEGER := 32;
       C_SMP_PCP_PLB_MID_WIDTH : INTEGER := 1;
       C_SMP_PCP_PLB_P2P : INTEGER := 0;
       C_SMP_PCP_PLB_NUM_MASTERS : INTEGER := 1;
       C_SMP_PCP_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_SMP_PCP_PLB_SUPPORT_BURSTS : INTEGER := 0;
       -- PDI PCP PLB Slave
       C_PDI_PCP_BASEADDR : std_logic_vector := X"00000000";
       C_PDI_PCP_HIGHADDR : std_logic_vector := X"000FFFFF";
       C_PDI_PCP_NUM_MASTERS : INTEGER := 1;
       C_PDI_PCP_PLB_AWIDTH : INTEGER := 32;
       C_PDI_PCP_PLB_DWIDTH : INTEGER := 32;
       C_PDI_PCP_PLB_MID_WIDTH : INTEGER := 1;
       C_PDI_PCP_PLB_P2P : INTEGER := 0;
       C_PDI_PCP_PLB_NUM_MASTERS : INTEGER := 1;
       C_PDI_PCP_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_PDI_PCP_PLB_SUPPORT_BURSTS : INTEGER := 0;
       -- openMAC CMP PLB Slave
       C_MAC_PKT_BASEADDR : std_logic_vector := X"00000000";
       C_MAC_PKT_HIGHADDR : std_logic_vector := X"000FFFFF";
       C_MAC_PKT_NUM_MASTERS : INTEGER := 1;
       C_MAC_PKT_PLB_AWIDTH : INTEGER := 32;
       C_MAC_PKT_PLB_DWIDTH : INTEGER := 32;
       C_MAC_PKT_PLB_MID_WIDTH : INTEGER := 1;
       C_MAC_PKT_PLB_P2P : INTEGER := 0;
       C_MAC_PKT_PLB_NUM_MASTERS : INTEGER := 1;
       C_MAC_PKT_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_MAC_PKT_PLB_SUPPORT_BURSTS : INTEGER := 0;
       -- openMAC DMA PLB Master
       C_MAC_DMA_PLB_AWIDTH : INTEGER := 32;
       C_MAC_DMA_PLB_DWIDTH : INTEGER := 32;
       C_MAC_DMA_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_MAC_DMA_BURST_SIZE : INTEGER := 8; ----in bytes
       C_MAC_DMA_FIFO_SIZE : INTEGER := 32; ----in bytes
       -- openMAC REG PLB Slave
       C_MAC_REG_BASEADDR : std_logic_vector := X"00000000";
       C_MAC_REG_HIGHADDR : std_logic_vector := X"0000FFFF";
       C_MAC_CMP_BASEADDR : std_logic_vector := X"00000000";
       C_MAC_CMP_HIGHADDR : std_logic_vector := X"0000FFFF";
       C_MAC_REG_NUM_MASTERS : INTEGER := 1;
       C_MAC_REG_PLB_AWIDTH : INTEGER := 32;
       C_MAC_REG_PLB_DWIDTH : INTEGER := 32;
       C_MAC_REG_PLB_MID_WIDTH : INTEGER := 1;
       C_MAC_REG_PLB_P2P : INTEGER := 0;
       C_MAC_REG_PLB_NUM_MASTERS : INTEGER := 1;
       C_MAC_REG_PLB_NATIVE_DWIDTH : INTEGER := 32;
       C_MAC_REG_PLB_SUPPORT_BURSTS : INTEGER := 0
  );
  port(
       MAC_DMA_Clk : in STD_LOGIC;
       MAC_DMA_MAddrAck : in STD_LOGIC;
       MAC_DMA_MBusy : in STD_LOGIC;
       MAC_DMA_MIRQ : in STD_LOGIC;
       MAC_DMA_MRdBTerm : in STD_LOGIC;
       MAC_DMA_MRdDAck : in STD_LOGIC;
       MAC_DMA_MRdErr : in STD_LOGIC;
       MAC_DMA_MRearbitrate : in STD_LOGIC;
       MAC_DMA_MTimeout : in STD_LOGIC;
       MAC_DMA_MWrBTerm : in STD_LOGIC;
       MAC_DMA_MWrDAck : in STD_LOGIC;
       MAC_DMA_MWrErr : in STD_LOGIC;
       MAC_DMA_Rst : in STD_LOGIC;
       MAC_PKT_Clk : in STD_LOGIC;
       MAC_PKT_PAValid : in STD_LOGIC;
       MAC_PKT_RNW : in STD_LOGIC;
       MAC_PKT_Rst : in STD_LOGIC;
       MAC_PKT_SAValid : in STD_LOGIC;
       MAC_PKT_abort : in STD_LOGIC;
       MAC_PKT_busLock : in STD_LOGIC;
       MAC_PKT_lockErr : in STD_LOGIC;
       MAC_PKT_rdBurst : in STD_LOGIC;
       MAC_PKT_rdPendReq : in STD_LOGIC;
       MAC_PKT_rdPrim : in STD_LOGIC;
       MAC_PKT_wrBurst : in STD_LOGIC;
       MAC_PKT_wrPendReq : in STD_LOGIC;
       MAC_PKT_wrPrim : in STD_LOGIC;
       MAC_REG_Clk : in STD_LOGIC;
       MAC_REG_PAValid : in STD_LOGIC;
       MAC_REG_RNW : in STD_LOGIC;
       MAC_REG_Rst : in STD_LOGIC;
       MAC_REG_SAValid : in STD_LOGIC;
       MAC_REG_abort : in STD_LOGIC;
       MAC_REG_busLock : in STD_LOGIC;
       MAC_REG_lockErr : in STD_LOGIC;
       MAC_REG_rdBurst : in STD_LOGIC;
       MAC_REG_rdPendReq : in STD_LOGIC;
       MAC_REG_rdPrim : in STD_LOGIC;
       MAC_REG_wrBurst : in STD_LOGIC;
       MAC_REG_wrPendReq : in STD_LOGIC;
       MAC_REG_wrPrim : in STD_LOGIC;
       PDI_AP_Clk : in STD_LOGIC;
       PDI_AP_PAValid : in STD_LOGIC;
       PDI_AP_RNW : in STD_LOGIC;
       PDI_AP_Rst : in STD_LOGIC;
       PDI_AP_SAValid : in STD_LOGIC;
       PDI_AP_abort : in STD_LOGIC;
       PDI_AP_busLock : in STD_LOGIC;
       PDI_AP_lockErr : in STD_LOGIC;
       PDI_AP_rdBurst : in STD_LOGIC;
       PDI_AP_rdPendReq : in STD_LOGIC;
       PDI_AP_rdPrim : in STD_LOGIC;
       PDI_AP_wrBurst : in STD_LOGIC;
       PDI_AP_wrPendReq : in STD_LOGIC;
       PDI_AP_wrPrim : in STD_LOGIC;
       PDI_PCP_Clk : in STD_LOGIC;
       PDI_PCP_PAValid : in STD_LOGIC;
       PDI_PCP_RNW : in STD_LOGIC;
       PDI_PCP_Rst : in STD_LOGIC;
       PDI_PCP_SAValid : in STD_LOGIC;
       PDI_PCP_abort : in STD_LOGIC;
       PDI_PCP_busLock : in STD_LOGIC;
       PDI_PCP_lockErr : in STD_LOGIC;
       PDI_PCP_rdBurst : in STD_LOGIC;
       PDI_PCP_rdPendReq : in STD_LOGIC;
       PDI_PCP_rdPrim : in STD_LOGIC;
       PDI_PCP_wrBurst : in STD_LOGIC;
       PDI_PCP_wrPendReq : in STD_LOGIC;
       PDI_PCP_wrPrim : in STD_LOGIC;
       SMP_PCP_Clk : in STD_LOGIC;
       SMP_PCP_PAValid : in STD_LOGIC;
       SMP_PCP_RNW : in STD_LOGIC;
       SMP_PCP_Rst : in STD_LOGIC;
       SMP_PCP_SAValid : in STD_LOGIC;
       SMP_PCP_abort : in STD_LOGIC;
       SMP_PCP_busLock : in STD_LOGIC;
       SMP_PCP_lockErr : in STD_LOGIC;
       SMP_PCP_rdBurst : in STD_LOGIC;
       SMP_PCP_rdPendReq : in STD_LOGIC;
       SMP_PCP_rdPrim : in STD_LOGIC;
       SMP_PCP_wrBurst : in STD_LOGIC;
       SMP_PCP_wrPendReq : in STD_LOGIC;
       SMP_PCP_wrPrim : in STD_LOGIC;
       clk100 : in STD_LOGIC;
       pap_cs : in STD_LOGIC;
       pap_cs_n : in STD_LOGIC;
       pap_rd : in STD_LOGIC;
       pap_rd_n : in STD_LOGIC;
       pap_wr : in STD_LOGIC;
       pap_wr_n : in STD_LOGIC;
       phy0_RxDv : in STD_LOGIC;
       phy0_RxErr : in STD_LOGIC;
       phy0_SMIDat_I : in STD_LOGIC;
       phy0_link : in STD_LOGIC;
       phy1_RxDv : in STD_LOGIC;
       phy1_RxErr : in STD_LOGIC;
       phy1_SMIDat_I : in STD_LOGIC;
       phy1_link : in STD_LOGIC;
       phyMii0_RxClk : in STD_LOGIC;
       phyMii0_RxDv : in STD_LOGIC;
       phyMii0_RxEr : in STD_LOGIC;
       phyMii0_TxClk : in STD_LOGIC;
       phyMii1_RxClk : in STD_LOGIC;
       phyMii1_RxDv : in STD_LOGIC;
       phyMii1_RxEr : in STD_LOGIC;
       phyMii1_TxClk : in STD_LOGIC;
       spi_clk : in STD_LOGIC;
       spi_mosi : in STD_LOGIC;
       spi_sel_n : in STD_LOGIC;
       MAC_DMA_MRdDBus : in STD_LOGIC_VECTOR(0 to C_MAC_DMA_PLB_DWIDTH-1);
       MAC_DMA_MRdWdAddr : in STD_LOGIC_VECTOR(0 to 3);
       MAC_DMA_MSSize : in STD_LOGIC_VECTOR(0 to 1);
       MAC_PKT_ABus : in STD_LOGIC_VECTOR(0 to 31);
       MAC_PKT_BE : in STD_LOGIC_VECTOR(0 to (C_MAC_PKT_PLB_DWIDTH/8)-1);
       MAC_PKT_MSize : in STD_LOGIC_VECTOR(0 to 1);
       MAC_PKT_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       MAC_PKT_UABus : in STD_LOGIC_VECTOR(0 to 31);
       MAC_PKT_masterID : in STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_MID_WIDTH-1);
       MAC_PKT_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       MAC_PKT_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       MAC_PKT_size : in STD_LOGIC_VECTOR(0 to 3);
       MAC_PKT_type : in STD_LOGIC_VECTOR(0 to 2);
       MAC_PKT_wrDBus : in STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_DWIDTH-1);
       MAC_PKT_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       MAC_REG_ABus : in STD_LOGIC_VECTOR(0 to 31);
       MAC_REG_BE : in STD_LOGIC_VECTOR(0 to (C_MAC_REG_PLB_DWIDTH / 8) - 1);
       MAC_REG_MSize : in STD_LOGIC_VECTOR(0 to 1);
       MAC_REG_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       MAC_REG_UABus : in STD_LOGIC_VECTOR(0 to 31);
       MAC_REG_masterID : in STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_MID_WIDTH - 1);
       MAC_REG_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       MAC_REG_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       MAC_REG_size : in STD_LOGIC_VECTOR(0 to 3);
       MAC_REG_type : in STD_LOGIC_VECTOR(0 to 2);
       MAC_REG_wrDBus : in STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_DWIDTH - 1);
       MAC_REG_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_AP_ABus : in STD_LOGIC_VECTOR(0 to 31);
       PDI_AP_BE : in STD_LOGIC_VECTOR(0 to (C_PDI_AP_PLB_DWIDTH/8)-1);
       PDI_AP_MSize : in STD_LOGIC_VECTOR(0 to 1);
       PDI_AP_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       PDI_AP_UABus : in STD_LOGIC_VECTOR(0 to 31);
       PDI_AP_masterID : in STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_MID_WIDTH-1);
       PDI_AP_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_AP_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_AP_size : in STD_LOGIC_VECTOR(0 to 3);
       PDI_AP_type : in STD_LOGIC_VECTOR(0 to 2);
       PDI_AP_wrDBus : in STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_DWIDTH-1);
       PDI_AP_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_PCP_ABus : in STD_LOGIC_VECTOR(0 to 31);
       PDI_PCP_BE : in STD_LOGIC_VECTOR(0 to (C_PDI_PCP_PLB_DWIDTH/8)-1);
       PDI_PCP_MSize : in STD_LOGIC_VECTOR(0 to 1);
       PDI_PCP_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       PDI_PCP_UABus : in STD_LOGIC_VECTOR(0 to 31);
       PDI_PCP_masterID : in STD_LOGIC_VECTOR(0 to C_PDI_PCP_PLB_MID_WIDTH-1);
       PDI_PCP_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_PCP_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       PDI_PCP_size : in STD_LOGIC_VECTOR(0 to 3);
       PDI_PCP_type : in STD_LOGIC_VECTOR(0 to 2);
       PDI_PCP_wrDBus : in STD_LOGIC_VECTOR(0 to C_PDI_PCP_PLB_DWIDTH-1);
       PDI_PCP_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       SMP_PCP_ABus : in STD_LOGIC_VECTOR(0 to 31);
       SMP_PCP_BE : in STD_LOGIC_VECTOR(0 to (C_SMP_PCP_PLB_DWIDTH/8)-1);
       SMP_PCP_MSize : in STD_LOGIC_VECTOR(0 to 1);
       SMP_PCP_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       SMP_PCP_UABus : in STD_LOGIC_VECTOR(0 to 31);
       SMP_PCP_masterID : in STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_MID_WIDTH-1);
       SMP_PCP_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       SMP_PCP_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       SMP_PCP_size : in STD_LOGIC_VECTOR(0 to 3);
       SMP_PCP_type : in STD_LOGIC_VECTOR(0 to 2);
       SMP_PCP_wrDBus : in STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_DWIDTH-1);
       SMP_PCP_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       pap_addr : in STD_LOGIC_VECTOR(15 downto 0);
       pap_be : in STD_LOGIC_VECTOR(C_PAP_DATA_WIDTH/8-1 downto 0);
       pap_be_n : in STD_LOGIC_VECTOR(C_PAP_DATA_WIDTH/8-1 downto 0);
       pap_data_I : in STD_LOGIC_VECTOR(C_PAP_DATA_WIDTH-1 downto 0);
       pap_gpio_I : in STD_LOGIC_VECTOR(1 downto 0);
       phy0_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
       phy1_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
       phyMii0_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
       phyMii1_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
       pio_pconfig : in STD_LOGIC_VECTOR(3 downto 0);
       pio_portInLatch : in STD_LOGIC_VECTOR(3 downto 0);
       pio_portio_I : in STD_LOGIC_VECTOR(31 downto 0);
       MAC_DMA_RNW : out STD_LOGIC;
       MAC_DMA_abort : out STD_LOGIC;
       MAC_DMA_busLock : out STD_LOGIC;
       MAC_DMA_error : out STD_LOGIC;
       MAC_DMA_lockErr : out STD_LOGIC;
       MAC_DMA_rdBurst : out STD_LOGIC;
       MAC_DMA_request : out STD_LOGIC;
       MAC_DMA_wrBurst : out STD_LOGIC;
       MAC_PKT_addrAck : out STD_LOGIC;
       MAC_PKT_rdBTerm : out STD_LOGIC;
       MAC_PKT_rdComp : out STD_LOGIC;
       MAC_PKT_rdDAck : out STD_LOGIC;
       MAC_PKT_rearbitrate : out STD_LOGIC;
       MAC_PKT_wait : out STD_LOGIC;
       MAC_PKT_wrBTerm : out STD_LOGIC;
       MAC_PKT_wrComp : out STD_LOGIC;
       MAC_PKT_wrDAck : out STD_LOGIC;
       MAC_REG_addrAck : out STD_LOGIC;
       MAC_REG_rdBTerm : out STD_LOGIC;
       MAC_REG_rdComp : out STD_LOGIC;
       MAC_REG_rdDAck : out STD_LOGIC;
       MAC_REG_rearbitrate : out STD_LOGIC;
       MAC_REG_wait : out STD_LOGIC;
       MAC_REG_wrBTerm : out STD_LOGIC;
       MAC_REG_wrComp : out STD_LOGIC;
       MAC_REG_wrDAck : out STD_LOGIC;
       PDI_AP_addrAck : out STD_LOGIC;
       PDI_AP_rdBTerm : out STD_LOGIC;
       PDI_AP_rdComp : out STD_LOGIC;
       PDI_AP_rdDAck : out STD_LOGIC;
       PDI_AP_rearbitrate : out STD_LOGIC;
       PDI_AP_wait : out STD_LOGIC;
       PDI_AP_wrBTerm : out STD_LOGIC;
       PDI_AP_wrComp : out STD_LOGIC;
       PDI_AP_wrDAck : out STD_LOGIC;
       PDI_PCP_addrAck : out STD_LOGIC;
       PDI_PCP_rdBTerm : out STD_LOGIC;
       PDI_PCP_rdComp : out STD_LOGIC;
       PDI_PCP_rdDAck : out STD_LOGIC;
       PDI_PCP_rearbitrate : out STD_LOGIC;
       PDI_PCP_wait : out STD_LOGIC;
       PDI_PCP_wrBTerm : out STD_LOGIC;
       PDI_PCP_wrComp : out STD_LOGIC;
       PDI_PCP_wrDAck : out STD_LOGIC;
       SMP_PCP_addrAck : out STD_LOGIC;
       SMP_PCP_rdBTerm : out STD_LOGIC;
       SMP_PCP_rdComp : out STD_LOGIC;
       SMP_PCP_rdDAck : out STD_LOGIC;
       SMP_PCP_rearbitrate : out STD_LOGIC;
       SMP_PCP_wait : out STD_LOGIC;
       SMP_PCP_wrBTerm : out STD_LOGIC;
       SMP_PCP_wrComp : out STD_LOGIC;
       SMP_PCP_wrDAck : out STD_LOGIC;
       ap_asyncIrq : out STD_LOGIC;
       ap_asyncIrq_n : out STD_LOGIC;
       ap_irq : out STD_LOGIC;
       ap_irq_n : out STD_LOGIC;
       led_error : out STD_LOGIC;
       led_status : out STD_LOGIC;
       mac_irq : out STD_LOGIC;
       pap_ack : out STD_LOGIC;
       pap_ack_n : out STD_LOGIC;
       pap_data_T : out STD_LOGIC;
       phy0_Rst_n : out STD_LOGIC;
       phy0_SMIClk : out STD_LOGIC;
       phy0_SMIDat_O : out STD_LOGIC;
       phy0_SMIDat_T : out STD_LOGIC;
       phy0_TxEn : out STD_LOGIC;
       phy1_Rst_n : out STD_LOGIC;
       phy1_SMIClk : out STD_LOGIC;
       phy1_SMIDat_O : out STD_LOGIC;
       phy1_SMIDat_T : out STD_LOGIC;
       phy1_TxEn : out STD_LOGIC;
       phyMii0_TxEn : out STD_LOGIC;
       phyMii0_TxEr : out STD_LOGIC;
       phyMii1_TxEn : out STD_LOGIC;
       phyMii1_TxEr : out STD_LOGIC;
       pio_operational : out STD_LOGIC;
       spi_miso : out STD_LOGIC;
       tcp_irq : out STD_LOGIC;
       MAC_DMA_ABus : out STD_LOGIC_VECTOR(0 to 31);
       MAC_DMA_BE : out STD_LOGIC_VECTOR(0 to (C_MAC_DMA_PLB_DWIDTH/8)-1);
       MAC_DMA_MSize : out STD_LOGIC_VECTOR(0 to 1);
       MAC_DMA_TAttribute : out STD_LOGIC_VECTOR(0 to 15);
       MAC_DMA_UABus : out STD_LOGIC_VECTOR(0 to 31);
       MAC_DMA_priority : out STD_LOGIC_VECTOR(0 to 1);
       MAC_DMA_size : out STD_LOGIC_VECTOR(0 to 3);
       MAC_DMA_type : out STD_LOGIC_VECTOR(0 to 2);
       MAC_DMA_wrDBus : out STD_LOGIC_VECTOR(0 to C_MAC_DMA_PLB_DWIDTH-1);
       MAC_PKT_MBusy : out STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
       MAC_PKT_MIRQ : out STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
       MAC_PKT_MRdErr : out STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
       MAC_PKT_MWrErr : out STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
       MAC_PKT_SSize : out STD_LOGIC_VECTOR(0 to 1);
       MAC_PKT_rdDBus : out STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_DWIDTH-1);
       MAC_PKT_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       MAC_REG_MBusy : out STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MIRQ : out STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MRdErr : out STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_MWrErr : out STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
       MAC_REG_SSize : out STD_LOGIC_VECTOR(0 to 1);
       MAC_REG_rdDBus : out STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_DWIDTH-1);
       MAC_REG_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       PDI_AP_MBusy : out STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_NUM_MASTERS-1);
       PDI_AP_MIRQ : out STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_NUM_MASTERS-1);
       PDI_AP_MRdErr : out STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_NUM_MASTERS-1);
       PDI_AP_MWrErr : out STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_NUM_MASTERS-1);
       PDI_AP_SSize : out STD_LOGIC_VECTOR(0 to 1);
       PDI_AP_rdDBus : out STD_LOGIC_VECTOR(0 to C_PDI_AP_PLB_DWIDTH-1);
       PDI_AP_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       PDI_PCP_MBusy : out STD_LOGIC_VECTOR(0 to C_PDI_PCP_NUM_MASTERS-1);
       PDI_PCP_MIRQ : out STD_LOGIC_VECTOR(0 to C_PDI_PCP_NUM_MASTERS-1);
       PDI_PCP_MRdErr : out STD_LOGIC_VECTOR(0 to C_PDI_PCP_NUM_MASTERS-1);
       PDI_PCP_MWrErr : out STD_LOGIC_VECTOR(0 to C_PDI_PCP_NUM_MASTERS-1);
       PDI_PCP_SSize : out STD_LOGIC_VECTOR(0 to 1);
       PDI_PCP_rdDBus : out STD_LOGIC_VECTOR(0 to C_PDI_PCP_PLB_DWIDTH-1);
       PDI_PCP_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       SMP_PCP_MBusy : out STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_NUM_MASTERS-1);
       SMP_PCP_MIRQ : out STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_NUM_MASTERS-1);
       SMP_PCP_MRdErr : out STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_NUM_MASTERS-1);
       SMP_PCP_MWrErr : out STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_NUM_MASTERS-1);
       SMP_PCP_SSize : out STD_LOGIC_VECTOR(0 to 1);
       SMP_PCP_rdDBus : out STD_LOGIC_VECTOR(0 to C_SMP_PCP_PLB_DWIDTH-1);
       SMP_PCP_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       led_gpo : out STD_LOGIC_VECTOR(7 downto 0);
       led_opt : out STD_LOGIC_VECTOR(1 downto 0);
       led_phyAct : out STD_LOGIC_VECTOR(1 downto 0);
       led_phyLink : out STD_LOGIC_VECTOR(1 downto 0);
       pap_data_O : out STD_LOGIC_VECTOR(C_PAP_DATA_WIDTH-1 downto 0);
       pap_gpio_O : out STD_LOGIC_VECTOR(1 downto 0);
       pap_gpio_T : out STD_LOGIC_VECTOR(1 downto 0);
       phy0_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
       phy1_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
       phyMii0_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
       phyMii1_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
       pio_portOutValid : out STD_LOGIC_VECTOR(3 downto 0);
       pio_portio_O : out STD_LOGIC_VECTOR(31 downto 0);
       pio_portio_T : out STD_LOGIC_VECTOR(31 downto 0);
       test_port : out STD_LOGIC_VECTOR(255 downto 0) := (others => '0')
  );
end plb_powerlink;

architecture struct of plb_powerlink is

---- Component declarations -----

component openMAC_16to32conv
  generic(
       bus_address_width : INTEGER := 10
  );
  port (
       bus_address : in STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
       bus_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       bus_read : in STD_LOGIC;
       bus_select : in STD_LOGIC;
       bus_write : in STD_LOGIC;
       bus_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       s_readdata : in STD_LOGIC_VECTOR(15 downto 0);
       s_waitrequest : in STD_LOGIC;
       bus_ack_rd : out STD_LOGIC;
       bus_ack_wr : out STD_LOGIC;
       bus_readdata : out STD_LOGIC_VECTOR(31 downto 0);
       s_address : out STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
       s_byteenable : out STD_LOGIC_VECTOR(1 downto 0);
       s_chipselect : out STD_LOGIC;
       s_read : out STD_LOGIC;
       s_write : out STD_LOGIC;
       s_writedata : out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;
component plb_master_handler
  generic(
       C_MAC_DMA_PLB_AWIDTH : INTEGER := 32;
       C_MAC_DMA_PLB_NATIVE_DWIDTH : INTEGER := 32;
       dma_highadr_g : INTEGER := 31;
       gen_rx_fifo_g : BOOLEAN := true;
       gen_tx_fifo_g : BOOLEAN := true;
       m_burstcount_width_g : INTEGER := 4
  );
  port (
       Bus2MAC_DMA_MstRd_d : in STD_LOGIC_VECTOR(C_MAC_DMA_PLB_NATIVE_DWIDTH-1 downto 0);
       Bus2MAC_DMA_MstRd_eof_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_MstRd_rem : in STD_LOGIC_VECTOR(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
       Bus2MAC_DMA_MstRd_sof_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_MstRd_src_dsc_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_MstRd_src_rdy_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_MstWr_dst_dsc_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_MstWr_dst_rdy_n : in STD_LOGIC := '1';
       Bus2MAC_DMA_Mst_CmdAck : in STD_LOGIC := '0';
       Bus2MAC_DMA_Mst_Cmd_Timeout : in STD_LOGIC := '0';
       Bus2MAC_DMA_Mst_Cmplt : in STD_LOGIC := '0';
       Bus2MAC_DMA_Mst_Error : in STD_LOGIC := '0';
       Bus2MAC_DMA_Mst_Rearbitrate : in STD_LOGIC := '0';
       MAC_DMA_CLK : in STD_LOGIC;
       MAC_DMA_Rst : in STD_LOGIC;
       m_address : in STD_LOGIC_VECTOR(dma_highadr_g downto 0);
       m_burstcount : in STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
       m_burstcounter : in STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
       m_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       m_read : in STD_LOGIC := '0';
       m_write : in STD_LOGIC := '0';
       m_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       MAC_DMA2Bus_MstRd_Req : out STD_LOGIC := '0';
       MAC_DMA2Bus_MstRd_dst_dsc_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_MstRd_dst_rdy_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_MstWr_Req : out STD_LOGIC := '0';
       MAC_DMA2Bus_MstWr_d : out STD_LOGIC_VECTOR(C_MAC_DMA_PLB_NATIVE_DWIDTH-1 downto 0);
       MAC_DMA2Bus_MstWr_eof_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_MstWr_rem : out STD_LOGIC_VECTOR(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
       MAC_DMA2Bus_MstWr_sof_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_MstWr_src_dsc_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_MstWr_src_rdy_n : out STD_LOGIC := '1';
       MAC_DMA2Bus_Mst_Addr : out STD_LOGIC_VECTOR(C_MAC_DMA_PLB_AWIDTH-1 downto 0);
       MAC_DMA2Bus_Mst_BE : out STD_LOGIC_VECTOR(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
       MAC_DMA2Bus_Mst_Length : out STD_LOGIC_VECTOR(11 downto 0);
       MAC_DMA2Bus_Mst_Lock : out STD_LOGIC := '0';
       MAC_DMA2Bus_Mst_Reset : out STD_LOGIC := '0';
       MAC_DMA2Bus_Mst_Type : out STD_LOGIC := '0';
       m_clk : out STD_LOGIC;
       m_readdata : out STD_LOGIC_VECTOR(31 downto 0);
       m_readdatavalid : out STD_LOGIC := '0';
       m_waitrequest : out STD_LOGIC := '1'
  );
end component;
component powerlink
  generic(
       Simulate : BOOLEAN := false;
       endian_g : STRING := "little";
       genABuf1_g : BOOLEAN := true;
       genABuf2_g : BOOLEAN := true;
       genEvent_g : BOOLEAN := false;
       genInternalAp_g : BOOLEAN := true;
       genIoBuf_g : BOOLEAN := true;
       genLedGadget_g : BOOLEAN := false;
       genOnePdiClkDomain_g : BOOLEAN := false;
       genPdi_g : BOOLEAN := true;
       genSimpleIO_g : BOOLEAN := false;
       genSmiIO : BOOLEAN := true;
       genSpiAp_g : BOOLEAN := false;
       genTimeSync_g : BOOLEAN := false;
       gen_dma_observer_g : BOOLEAN := true;
       iAsyBuf1Size_g : INTEGER := 100;
       iAsyBuf2Size_g : INTEGER := 100;
       iBufSizeLOG2_g : INTEGER := 10;
       iBufSize_g : INTEGER := 1024;
       iPdiRev_g : INTEGER := 21930;
       iRpdo0BufSize_g : INTEGER := 100;
       iRpdo1BufSize_g : INTEGER := 100;
       iRpdo2BufSize_g : INTEGER := 100;
       iRpdos_g : INTEGER := 3;
       iTpdoBufSize_g : INTEGER := 100;
       iTpdos_g : INTEGER := 1;
       m_burstcount_const_g : BOOLEAN := true;
       m_burstcount_width_g : INTEGER := 4;
       m_data_width_g : INTEGER := 16;
       m_rx_burst_size_g : INTEGER := 16;
       m_rx_fifo_size_g : INTEGER := 16;
       m_tx_burst_size_g : INTEGER := 16;
       m_tx_fifo_size_g : INTEGER := 16;
       papBigEnd_g : BOOLEAN := false;
       papDataWidth_g : INTEGER := 8;
       papLowAct_g : BOOLEAN := false;
       pioValLen_g : INTEGER := 50;
       spiBigEnd_g : BOOLEAN := false;
       spiCPHA_g : BOOLEAN := false;
       spiCPOL_g : BOOLEAN := false;
       use2ndCmpTimer_g : BOOLEAN := true;
       use2ndPhy_g : BOOLEAN := true;
       useHwAcc_g : BOOLEAN := false;
       useIntPacketBuf_g : BOOLEAN := true;
       useRmii_g : BOOLEAN := true;
       useRxIntPacketBuf_g : BOOLEAN := true
  );
  port (
       ap_address : in STD_LOGIC_VECTOR(12 downto 0);
       ap_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       ap_chipselect : in STD_LOGIC;
       ap_read : in STD_LOGIC;
       ap_write : in STD_LOGIC;
       ap_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       clk50 : in STD_LOGIC;
       clkAp : in STD_LOGIC;
       clkEth : in STD_LOGIC;
       clkPcp : in STD_LOGIC;
       m_clk : in STD_LOGIC;
       m_readdata : in STD_LOGIC_VECTOR(m_data_width_g-1 downto 0) := (others => '0');
       m_readdatavalid : in STD_LOGIC := '0';
       m_waitrequest : in STD_LOGIC;
       mac_address : in STD_LOGIC_VECTOR(11 downto 0);
       mac_byteenable : in STD_LOGIC_VECTOR(1 downto 0);
       mac_chipselect : in STD_LOGIC;
       mac_read : in STD_LOGIC;
       mac_write : in STD_LOGIC;
       mac_writedata : in STD_LOGIC_VECTOR(15 downto 0);
       mbf_address : in STD_LOGIC_VECTOR(ibufsizelog2_g-3 downto 0);
       mbf_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       mbf_chipselect : in STD_LOGIC;
       mbf_read : in STD_LOGIC;
       mbf_write : in STD_LOGIC;
       mbf_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       pap_addr : in STD_LOGIC_VECTOR(15 downto 0);
       pap_be : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
       pap_be_n : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
       pap_cs : in STD_LOGIC;
       pap_cs_n : in STD_LOGIC;
       pap_data_I : in STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0) := (others => '0');
       pap_gpio_I : in STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       pap_rd : in STD_LOGIC;
       pap_rd_n : in STD_LOGIC;
       pap_wr : in STD_LOGIC;
       pap_wr_n : in STD_LOGIC;
       pcp_address : in STD_LOGIC_VECTOR(12 downto 0);
       pcp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       pcp_chipselect : in STD_LOGIC;
       pcp_read : in STD_LOGIC;
       pcp_write : in STD_LOGIC;
       pcp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       phy0_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
       phy0_RxDv : in STD_LOGIC;
       phy0_RxErr : in STD_LOGIC;
       phy0_SMIDat_I : in STD_LOGIC := '1';
       phy0_link : in STD_LOGIC := '0';
       phy1_RxDat : in STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       phy1_RxDv : in STD_LOGIC;
       phy1_RxErr : in STD_LOGIC;
       phy1_SMIDat_I : in STD_LOGIC := '1';
       phy1_link : in STD_LOGIC := '0';
       phyMii0_RxClk : in STD_LOGIC;
       phyMii0_RxDat : in STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
       phyMii0_RxDv : in STD_LOGIC;
       phyMii0_RxEr : in STD_LOGIC;
       phyMii0_TxClk : in STD_LOGIC;
       phyMii1_RxClk : in STD_LOGIC;
       phyMii1_RxDat : in STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
       phyMii1_RxDv : in STD_LOGIC;
       phyMii1_RxEr : in STD_LOGIC;
       phyMii1_TxClk : in STD_LOGIC;
       pio_pconfig : in STD_LOGIC_VECTOR(3 downto 0);
       pio_portInLatch : in STD_LOGIC_VECTOR(3 downto 0);
       pio_portio_I : in STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       pkt_clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       rstAp : in STD_LOGIC;
       rstPcp : in STD_LOGIC;
       smp_address : in STD_LOGIC;
       smp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       smp_read : in STD_LOGIC;
       smp_write : in STD_LOGIC;
       smp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       spi_clk : in STD_LOGIC;
       spi_mosi : in STD_LOGIC;
       spi_sel_n : in STD_LOGIC;
       tcp_address : in STD_LOGIC_VECTOR(1 downto 0);
       tcp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
       tcp_chipselect : in STD_LOGIC;
       tcp_read : in STD_LOGIC;
       tcp_write : in STD_LOGIC;
       tcp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
       ap_asyncIrq : out STD_LOGIC := '0';
       ap_asyncIrq_n : out STD_LOGIC := '1';
       ap_irq : out STD_LOGIC := '0';
       ap_irq_n : out STD_LOGIC := '1';
       ap_readdata : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       ap_waitrequest : out STD_LOGIC;
       led_error : out STD_LOGIC := '0';
       led_gpo : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
       led_opt : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       led_phyAct : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       led_phyLink : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       led_status : out STD_LOGIC := '0';
       m_address : out STD_LOGIC_VECTOR(29 downto 0) := (others => '0');
       m_burstcount : out STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
       m_burstcounter : out STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
       m_byteenable : out STD_LOGIC_VECTOR(m_data_width_g/8-1 downto 0) := (others => '0');
       m_read : out STD_LOGIC := '0';
       m_write : out STD_LOGIC := '0';
       m_writedata : out STD_LOGIC_VECTOR(m_data_width_g-1 downto 0) := (others => '0');
       mac_irq : out STD_LOGIC := '0';
       mac_readdata : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
       mac_waitrequest : out STD_LOGIC;
       mbf_readdata : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       mbf_waitrequest : out STD_LOGIC;
       pap_ack : out STD_LOGIC := '0';
       pap_ack_n : out STD_LOGIC := '1';
       pap_data_O : out STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
       pap_data_T : out STD_LOGIC;
       pap_gpio_O : out STD_LOGIC_VECTOR(1 downto 0);
       pap_gpio_T : out STD_LOGIC_VECTOR(1 downto 0);
       pcp_readdata : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       pcp_waitrequest : out STD_LOGIC;
       phy0_Rst_n : out STD_LOGIC := '1';
       phy0_SMIClk : out STD_LOGIC := '0';
       phy0_SMIDat_O : out STD_LOGIC;
       phy0_SMIDat_T : out STD_LOGIC;
       phy0_TxDat : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       phy0_TxEn : out STD_LOGIC := '0';
       phy1_Rst_n : out STD_LOGIC := '1';
       phy1_SMIClk : out STD_LOGIC := '0';
       phy1_SMIDat_O : out STD_LOGIC;
       phy1_SMIDat_T : out STD_LOGIC;
       phy1_TxDat : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       phy1_TxEn : out STD_LOGIC := '0';
       phyMii0_TxDat : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
       phyMii0_TxEn : out STD_LOGIC := '0';
       phyMii0_TxEr : out STD_LOGIC := '0';
       phyMii1_TxDat : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
       phyMii1_TxEn : out STD_LOGIC := '0';
       phyMii1_TxEr : out STD_LOGIC := '0';
       pio_operational : out STD_LOGIC := '0';
       pio_portOutValid : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
       pio_portio_O : out STD_LOGIC_VECTOR(31 downto 0);
       pio_portio_T : out STD_LOGIC_VECTOR(31 downto 0);
       smp_readdata : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       smp_waitrequest : out STD_LOGIC;
       spi_miso : out STD_LOGIC := '0';
       tcp_irq : out STD_LOGIC := '0';
       tcp_readdata : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
       tcp_waitrequest : out STD_LOGIC;
       pap_data : inout STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0) := (others => '0');
       pap_gpio : inout STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
       phy0_SMIDat : inout STD_LOGIC := '1';
       phy1_SMIDat : inout STD_LOGIC := '1';
       pio_portio : inout STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
  );
end component;
component plbv46_master_burst
  generic(
       C_FAMILY : STRING := "virtex5";
       C_INHIBIT_CC_BLE_INCLUSION : INTEGER range 0 to 1 := 0;
       C_MPLB_AWIDTH : INTEGER range 32 to 36 := 32;
       C_MPLB_DWIDTH : INTEGER range 32 to 128 := 32;
       C_MPLB_NATIVE_DWIDTH : INTEGER range 32 to 128 := 32;
       C_MPLB_SMALLEST_SLAVE : INTEGER range 32 to 128 := 32
  );
  port (
       IP2Bus_MstRd_Req : in STD_LOGIC;
       IP2Bus_MstRd_dst_dsc_n : in STD_LOGIC;
       IP2Bus_MstRd_dst_rdy_n : in STD_LOGIC;
       IP2Bus_MstWr_Req : in STD_LOGIC;
       IP2Bus_MstWr_d : in STD_LOGIC_VECTOR(0 to C_MPLB_NATIVE_DWIDTH-1);
       IP2Bus_MstWr_eof_n : in STD_LOGIC;
       IP2Bus_MstWr_rem : in STD_LOGIC_VECTOR(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       IP2Bus_MstWr_sof_n : in STD_LOGIC;
       IP2Bus_MstWr_src_dsc_n : in STD_LOGIC;
       IP2Bus_MstWr_src_rdy_n : in STD_LOGIC;
       IP2Bus_Mst_Addr : in STD_LOGIC_VECTOR(0 to C_MPLB_AWIDTH-1);
       IP2Bus_Mst_BE : in STD_LOGIC_VECTOR(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       IP2Bus_Mst_Length : in STD_LOGIC_VECTOR(0 to 11);
       IP2Bus_Mst_Lock : in STD_LOGIC;
       IP2Bus_Mst_Reset : in STD_LOGIC;
       IP2Bus_Mst_Type : in STD_LOGIC;
       MPLB_Clk : in STD_LOGIC;
       MPLB_Rst : in STD_LOGIC;
       PLB_MAddrAck : in STD_LOGIC;
       PLB_MBusy : in STD_LOGIC;
       PLB_MIRQ : in STD_LOGIC;
       PLB_MRdBTerm : in STD_LOGIC;
       PLB_MRdDAck : in STD_LOGIC;
       PLB_MRdDBus : in STD_LOGIC_VECTOR(0 to C_MPLB_DWIDTH-1);
       PLB_MRdErr : in STD_LOGIC;
       PLB_MRdWdAddr : in STD_LOGIC_VECTOR(0 to 3);
       PLB_MRearbitrate : in STD_LOGIC;
       PLB_MSSize : in STD_LOGIC_VECTOR(0 to 1);
       PLB_MTimeout : in STD_LOGIC;
       PLB_MWrBTerm : in STD_LOGIC;
       PLB_MWrDAck : in STD_LOGIC;
       PLB_MWrErr : in STD_LOGIC;
       Bus2IP_MstRd_d : out STD_LOGIC_VECTOR(0 to C_MPLB_NATIVE_DWIDTH-1);
       Bus2IP_MstRd_eof_n : out STD_LOGIC;
       Bus2IP_MstRd_rem : out STD_LOGIC_VECTOR(0 to (C_MPLB_NATIVE_DWIDTH/8)-1);
       Bus2IP_MstRd_sof_n : out STD_LOGIC;
       Bus2IP_MstRd_src_dsc_n : out STD_LOGIC;
       Bus2IP_MstRd_src_rdy_n : out STD_LOGIC;
       Bus2IP_MstWr_dst_dsc_n : out STD_LOGIC;
       Bus2IP_MstWr_dst_rdy_n : out STD_LOGIC;
       Bus2IP_Mst_CmdAck : out STD_LOGIC;
       Bus2IP_Mst_Cmd_Timeout : out STD_LOGIC;
       Bus2IP_Mst_Cmplt : out STD_LOGIC;
       Bus2IP_Mst_Error : out STD_LOGIC;
       Bus2IP_Mst_Rearbitrate : out STD_LOGIC;
       MD_Error : out STD_LOGIC;
       M_ABus : out STD_LOGIC_VECTOR(0 to 31);
       M_BE : out STD_LOGIC_VECTOR(0 to (C_MPLB_DWIDTH/8)-1);
       M_MSize : out STD_LOGIC_VECTOR(0 to 1);
       M_RNW : out STD_LOGIC;
       M_TAttribute : out STD_LOGIC_VECTOR(0 to 15);
       M_UABus : out STD_LOGIC_VECTOR(0 to 31);
       M_abort : out STD_LOGIC;
       M_busLock : out STD_LOGIC;
       M_lockErr : out STD_LOGIC;
       M_priority : out STD_LOGIC_VECTOR(0 to 1);
       M_rdBurst : out STD_LOGIC;
       M_request : out STD_LOGIC;
       M_size : out STD_LOGIC_VECTOR(0 to 3);
       M_type : out STD_LOGIC_VECTOR(0 to 2);
       M_wrBurst : out STD_LOGIC;
       M_wrDBus : out STD_LOGIC_VECTOR(0 to C_MPLB_DWIDTH-1)
  );
end component;
component plbv46_slave_single
  generic(
       C_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE := (X"0000_0000_7000_0000",X"0000_0000_7000_00FF",X"0000_0000_7000_0100",X"0000_0000_7000_01FF");
       C_ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE := (1,8);
       C_BUS2CORE_CLK_RATIO : INTEGER range 1 to 2 := 1;
       C_FAMILY : STRING := "virtex4";
       C_INCLUDE_DPHASE_TIMER : INTEGER range 0 to 1 := 1;
       C_SIPIF_DWIDTH : INTEGER range 32 to 32 := 32;
       C_SPLB_AWIDTH : INTEGER range 32 to 32 := 32;
       C_SPLB_DWIDTH : INTEGER range 32 to 128 := 32;
       C_SPLB_MID_WIDTH : INTEGER range 1 to 4 := 2;
       C_SPLB_NUM_MASTERS : INTEGER range 1 to 16 := 8;
       C_SPLB_P2P : INTEGER range 0 to 1 := 0
  );
  port (
       IP2Bus_Data : in STD_LOGIC_VECTOR(0 to C_SIPIF_DWIDTH-1);
       IP2Bus_Error : in STD_LOGIC;
       IP2Bus_RdAck : in STD_LOGIC;
       IP2Bus_WrAck : in STD_LOGIC;
       PLB_ABus : in STD_LOGIC_VECTOR(0 to 31);
       PLB_BE : in STD_LOGIC_VECTOR(0 to (C_SPLB_DWIDTH/8)-1);
       PLB_MSize : in STD_LOGIC_VECTOR(0 to 1);
       PLB_PAValid : in STD_LOGIC;
       PLB_RNW : in STD_LOGIC;
       PLB_SAValid : in STD_LOGIC;
       PLB_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
       PLB_UABus : in STD_LOGIC_VECTOR(0 to 31);
       PLB_abort : in STD_LOGIC;
       PLB_busLock : in STD_LOGIC;
       PLB_lockErr : in STD_LOGIC;
       PLB_masterID : in STD_LOGIC_VECTOR(0 to C_SPLB_MID_WIDTH-1);
       PLB_rdBurst : in STD_LOGIC;
       PLB_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PLB_rdPendReq : in STD_LOGIC;
       PLB_rdPrim : in STD_LOGIC;
       PLB_reqPri : in STD_LOGIC_VECTOR(0 to 1);
       PLB_size : in STD_LOGIC_VECTOR(0 to 3);
       PLB_type : in STD_LOGIC_VECTOR(0 to 2);
       PLB_wrBurst : in STD_LOGIC;
       PLB_wrDBus : in STD_LOGIC_VECTOR(0 to C_SPLB_DWIDTH-1);
       PLB_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
       PLB_wrPendReq : in STD_LOGIC;
       PLB_wrPrim : in STD_LOGIC;
       SPLB_Clk : in STD_LOGIC;
       SPLB_Rst : in STD_LOGIC;
       Bus2IP_Addr : out STD_LOGIC_VECTOR(0 to C_SPLB_AWIDTH-1);
       Bus2IP_BE : out STD_LOGIC_VECTOR(0 to (C_SIPIF_DWIDTH/8)-1);
       Bus2IP_CS : out STD_LOGIC_VECTOR(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
       Bus2IP_Clk : out STD_LOGIC;
       Bus2IP_Data : out STD_LOGIC_VECTOR(0 to C_SIPIF_DWIDTH-1);
       Bus2IP_RNW : out STD_LOGIC;
       Bus2IP_RdCE : out STD_LOGIC_VECTOR(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
       Bus2IP_Reset : out STD_LOGIC;
       Bus2IP_WrCE : out STD_LOGIC_VECTOR(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
       Sl_MBusy : out STD_LOGIC_VECTOR(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MIRQ : out STD_LOGIC_VECTOR(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MRdErr : out STD_LOGIC_VECTOR(0 to C_SPLB_NUM_MASTERS-1);
       Sl_MWrErr : out STD_LOGIC_VECTOR(0 to C_SPLB_NUM_MASTERS-1);
       Sl_SSize : out STD_LOGIC_VECTOR(0 to 1);
       Sl_addrAck : out STD_LOGIC;
       Sl_rdBTerm : out STD_LOGIC;
       Sl_rdComp : out STD_LOGIC;
       Sl_rdDAck : out STD_LOGIC;
       Sl_rdDBus : out STD_LOGIC_VECTOR(0 to C_SPLB_DWIDTH-1);
       Sl_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
       Sl_rearbitrate : out STD_LOGIC;
       Sl_wait : out STD_LOGIC;
       Sl_wrBTerm : out STD_LOGIC;
       Sl_wrComp : out STD_LOGIC;
       Sl_wrDAck : out STD_LOGIC
  );
end component;

---- Architecture declarations -----
--
constant C_FAMILY : string := "spartan6";
constant C_ADDR_PAD_ZERO : std_logic_vector(31 downto 0) := (others => '0');
-- openMAC REG PLB Slave
constant C_MAC_REG_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_REG_BASEADDR;
constant C_MAC_REG_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_REG_HIGHADDR;
-- openMAC CMP PLB Slave
constant C_MAC_CMP_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_CMP_BASEADDR;
constant C_MAC_CMP_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_CMP_HIGHADDR;
-- openMAC PKT PLB Slave
constant C_MAC_PKT_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_PKT_BASEADDR;
constant C_MAC_PKT_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_MAC_PKT_HIGHADDR;
-- SimpleIO Slave
constant C_SMP_PCP_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_SMP_PCP_BASEADDR;
constant C_SMP_PCP_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_SMP_PCP_HIGHADDR;
-- PDI PCP Slave
constant C_PDI_PCP_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_PDI_PCP_BASEADDR;
constant C_PDI_PCP_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_PDI_PCP_HIGHADDR;
-- AP PCP Slave
constant C_PDI_AP_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_PDI_AP_BASEADDR;
constant C_PDI_AP_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_PDI_AP_HIGHADDR;
-- POWERLINK IP-core
constant C_MAC_PKT_EN : boolean := C_TX_INT_PKT or C_RX_INT_PKT;
constant C_MAC_PKT_RX_EN : boolean := C_RX_INT_PKT;
constant C_DMA_EN : boolean := not C_TX_INT_PKT or not C_RX_INT_PKT;
constant C_PKT_BUF_EN : boolean := C_MAC_PKT_EN;
constant C_M_BURSTCOUNT_WIDTH : integer := integer(ceil(log2(real(C_MAC_DMA_BURST_SIZE/4)))) + 1; --in dwords
constant C_M_FIFO_SIZE : integer := C_MAC_DMA_FIFO_SIZE/4; --in dwords


----     Constants     -----
constant GND_CONSTANT   : STD_LOGIC := '0';

---- Signal declarations used on the diagram ----

signal ap_chipselect : STD_LOGIC;
signal ap_read : STD_LOGIC;
signal ap_waitrequest : STD_LOGIC;
signal ap_write : STD_LOGIC;
signal Bus2MAC_CMP_Reset : STD_LOGIC;
signal Bus2MAC_DMA_MstRd_eof_n : STD_LOGIC;
signal Bus2MAC_DMA_MstRd_sof_n : STD_LOGIC;
signal Bus2MAC_DMA_MstRd_src_dsc_n : STD_LOGIC;
signal Bus2MAC_DMA_MstRd_src_rdy_n : STD_LOGIC;
signal Bus2MAC_DMA_MstWr_dst_dsc_n : STD_LOGIC;
signal Bus2MAC_DMA_MstWr_dst_rdy_n : STD_LOGIC;
signal Bus2MAC_DMA_Mst_CmdAck : STD_LOGIC;
signal Bus2MAC_DMA_Mst_Cmd_Timeout : STD_LOGIC;
signal Bus2MAC_DMA_Mst_Cmplt : STD_LOGIC;
signal Bus2MAC_DMA_Mst_Error : STD_LOGIC;
signal Bus2MAC_DMA_Mst_Rearbitrate : STD_LOGIC;
signal Bus2MAC_PKT_Clk : STD_LOGIC;
signal Bus2MAC_PKT_Reset : STD_LOGIC;
signal Bus2MAC_PKT_RNW : STD_LOGIC;
signal Bus2MAC_REG_Clk : STD_LOGIC;
signal Bus2MAC_REG_Reset : STD_LOGIC;
signal Bus2MAC_REG_RNW : STD_LOGIC;
signal Bus2MAC_REG_RNW_n : STD_LOGIC;
signal Bus2PDI_AP_Clk : STD_LOGIC;
signal Bus2PDI_AP_Reset : STD_LOGIC;
signal Bus2PDI_AP_RNW : STD_LOGIC;
signal Bus2PDI_PCP_Clk : STD_LOGIC;
signal Bus2PDI_PCP_Reset : STD_LOGIC;
signal Bus2PDI_PCP_RNW : STD_LOGIC;
signal Bus2SMP_PCP_Clk : STD_LOGIC;
signal Bus2SMP_PCP_Reset : STD_LOGIC;
signal Bus2SMP_PCP_RNW : STD_LOGIC;
signal clk50 : STD_LOGIC;
signal clkAp : STD_LOGIC;
signal clkPcp : STD_LOGIC;
signal GND : STD_LOGIC;
signal IP2Bus_Error_s : STD_LOGIC;
signal IP2Bus_RrAck_s : STD_LOGIC;
signal IP2Bus_WrAck_s : STD_LOGIC;
signal mac_chipselect : STD_LOGIC;
signal MAC_CMP2Bus_Error : STD_LOGIC;
signal MAC_CMP2Bus_RdAck : STD_LOGIC;
signal MAC_CMP2Bus_WrAck : STD_LOGIC;
signal MAC_DMA2Bus_MstRd_dst_dsc_n : STD_LOGIC;
signal MAC_DMA2Bus_MstRd_dst_rdy_n : STD_LOGIC;
signal MAC_DMA2Bus_MstRd_Req : STD_LOGIC;
signal MAC_DMA2Bus_MstWr_eof_n : STD_LOGIC;
signal MAC_DMA2Bus_MstWr_Req : STD_LOGIC;
signal MAC_DMA2Bus_MstWr_sof_n : STD_LOGIC;
signal MAC_DMA2Bus_MstWr_src_dsc_n : STD_LOGIC;
signal MAC_DMA2Bus_MstWr_src_rdy_n : STD_LOGIC;
signal MAC_DMA2Bus_Mst_Lock : STD_LOGIC;
signal MAC_DMA2Bus_Mst_Reset : STD_LOGIC;
signal MAC_DMA2Bus_Mst_Type : STD_LOGIC;
signal mac_irq_s : STD_LOGIC;
signal MAC_PKT2Bus_Error : STD_LOGIC;
signal MAC_PKT2Bus_RdAck : STD_LOGIC;
signal MAC_PKT2Bus_WrAck : STD_LOGIC;
signal mac_read : STD_LOGIC;
signal MAC_REG2Bus_Error : STD_LOGIC;
signal MAC_REG2Bus_RdAck : STD_LOGIC;
signal MAC_REG2Bus_WrAck : STD_LOGIC;
signal mac_waitrequest : STD_LOGIC;
signal mac_write : STD_LOGIC;
signal mbf_chipselect : STD_LOGIC;
signal mbf_read : STD_LOGIC;
signal mbf_waitrequest : STD_LOGIC;
signal mbf_write : STD_LOGIC;
signal m_clk : STD_LOGIC;
signal m_read : STD_LOGIC;
signal m_readdatavalid : STD_LOGIC;
signal m_waitrequest : STD_LOGIC;
signal m_write : STD_LOGIC;
signal pcp_chipselect : STD_LOGIC;
signal pcp_read : STD_LOGIC;
signal pcp_waitrequest : STD_LOGIC;
signal pcp_write : STD_LOGIC;
signal PDI_AP2Bus_Error : STD_LOGIC;
signal PDI_AP2Bus_RdAck : STD_LOGIC;
signal PDI_AP2Bus_WrAck : STD_LOGIC;
signal PDI_PCP2Bus_Error : STD_LOGIC;
signal PDI_PCP2Bus_RdAck : STD_LOGIC;
signal PDI_PCP2Bus_WrAck : STD_LOGIC;
signal pkt_clk : STD_LOGIC;
signal rst : STD_LOGIC;
signal rstAp : STD_LOGIC;
signal rstPcp : STD_LOGIC;
signal smp_address : STD_LOGIC;
signal smp_chipselect : STD_LOGIC;
signal SMP_PCP2Bus_Error : STD_LOGIC;
signal SMP_PCP2Bus_RdAck : STD_LOGIC;
signal SMP_PCP2Bus_WrAck : STD_LOGIC;
signal smp_read : STD_LOGIC;
signal smp_waitrequest : STD_LOGIC;
signal smp_write : STD_LOGIC;
signal tcp_chipselect : STD_LOGIC;
signal tcp_irq_s : STD_LOGIC;
signal tcp_read : STD_LOGIC;
signal tcp_waitrequest : STD_LOGIC;
signal tcp_write : STD_LOGIC;
signal ap_address : STD_LOGIC_VECTOR (12 downto 0);
signal ap_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal ap_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal ap_writedata : STD_LOGIC_VECTOR (31 downto 0);
signal Bus2MAC_DMA_MstRd_d : STD_LOGIC_VECTOR (0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1);
signal Bus2MAC_DMA_MstRd_rem : STD_LOGIC_VECTOR (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal Bus2MAC_PKT_Addr : STD_LOGIC_VECTOR (C_MAC_PKT_PLB_AWIDTH-1 downto 0);
signal Bus2MAC_PKT_BE : STD_LOGIC_VECTOR ((C_MAC_PKT_PLB_DWIDTH/8)-1 downto 0);
signal Bus2MAC_PKT_CS : STD_LOGIC_VECTOR (0 downto 0);
signal Bus2MAC_PKT_Data : STD_LOGIC_VECTOR (C_MAC_PKT_PLB_DWIDTH-1 downto 0);
signal Bus2MAC_REG_Addr : STD_LOGIC_VECTOR (C_MAC_REG_PLB_AWIDTH-1 downto 0);
signal Bus2MAC_REG_BE : STD_LOGIC_VECTOR ((C_MAC_REG_PLB_DWIDTH/8)-1 downto 0);
signal Bus2MAC_REG_BE_s : STD_LOGIC_VECTOR ((C_MAC_REG_PLB_DWIDTH/8)-1 downto 0);
signal Bus2MAC_REG_CS : STD_LOGIC_VECTOR (1 downto 0);
signal Bus2MAC_REG_Data : STD_LOGIC_VECTOR (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal Bus2PDI_AP_Addr : STD_LOGIC_VECTOR (C_PDI_AP_PLB_AWIDTH-1 downto 0);
signal Bus2PDI_AP_BE : STD_LOGIC_VECTOR ((C_PDI_AP_PLB_DWIDTH/8)-1 downto 0);
signal Bus2PDI_AP_CS : STD_LOGIC_VECTOR (0 downto 0);
signal Bus2PDI_AP_Data : STD_LOGIC_VECTOR (C_PDI_AP_PLB_DWIDTH-1 downto 0);
signal Bus2PDI_PCP_Addr : STD_LOGIC_VECTOR (C_PDI_PCP_PLB_AWIDTH-1 downto 0);
signal Bus2PDI_PCP_BE : STD_LOGIC_VECTOR ((C_PDI_PCP_PLB_DWIDTH/8)-1 downto 0);
signal Bus2PDI_PCP_CS : STD_LOGIC_VECTOR (0 downto 0);
signal Bus2PDI_PCP_Data : STD_LOGIC_VECTOR (C_PDI_PCP_PLB_DWIDTH-1 downto 0);
signal Bus2SMP_PCP_Addr : STD_LOGIC_VECTOR (C_SMP_PCP_PLB_AWIDTH-1 downto 0);
signal Bus2SMP_PCP_BE : STD_LOGIC_VECTOR ((C_SMP_PCP_PLB_DWIDTH/8)-1 downto 0);
signal Bus2SMP_PCP_CS : STD_LOGIC_VECTOR (0 downto 0);
signal Bus2SMP_PCP_Data : STD_LOGIC_VECTOR (C_SMP_PCP_PLB_DWIDTH-1 downto 0);
signal IP2Bus_Data_s : STD_LOGIC_VECTOR (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal mac_address : STD_LOGIC_VECTOR (C_MAC_REG_PLB_AWIDTH-1 downto 0);
signal mac_byteenable : STD_LOGIC_VECTOR (1 downto 0);
signal MAC_CMP2Bus_Data : STD_LOGIC_VECTOR (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal MAC_DMA2Bus_MstWr_d : STD_LOGIC_VECTOR (0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1);
signal MAC_DMA2Bus_MstWr_rem : STD_LOGIC_VECTOR (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal MAC_DMA2Bus_Mst_Addr : STD_LOGIC_VECTOR (0 to C_MAC_DMA_PLB_AWIDTH-1);
signal MAC_DMA2Bus_Mst_BE : STD_LOGIC_VECTOR (0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1);
signal MAC_DMA2Bus_Mst_Length : STD_LOGIC_VECTOR (0 to 11);
signal MAC_PKT2Bus_Data : STD_LOGIC_VECTOR (C_MAC_PKT_PLB_DWIDTH-1 downto 0);
signal mac_readdata : STD_LOGIC_VECTOR (15 downto 0);
signal MAC_REG2Bus_Data : STD_LOGIC_VECTOR (C_MAC_REG_PLB_DWIDTH-1 downto 0);
signal mac_writedata : STD_LOGIC_VECTOR (15 downto 0);
signal mbf_address : STD_LOGIC_VECTOR (C_MAC_PKT_SIZE_LOG2-3 downto 0);
signal mbf_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal mbf_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal mbf_writedata : STD_LOGIC_VECTOR (31 downto 0);
signal m_address : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal m_burstcount : STD_LOGIC_VECTOR (C_M_BURSTCOUNT_WIDTH-1 downto 0);
signal m_burstcounter : STD_LOGIC_VECTOR (C_M_BURSTCOUNT_WIDTH-1 downto 0);
signal m_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal m_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal m_writedata : STD_LOGIC_VECTOR (31 downto 0);
signal pcp_address : STD_LOGIC_VECTOR (12 downto 0);
signal pcp_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal pcp_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal pcp_writedata : STD_LOGIC_VECTOR (31 downto 0);
signal PDI_AP2Bus_Data : STD_LOGIC_VECTOR (C_PDI_AP_PLB_DWIDTH-1 downto 0);
signal PDI_PCP2Bus_Data : STD_LOGIC_VECTOR (C_PDI_PCP_PLB_DWIDTH-1 downto 0);
signal smp_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal SMP_PCP2Bus_Data : STD_LOGIC_VECTOR (C_SMP_PCP_PLB_DWIDTH-1 downto 0);
signal smp_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal smp_writedata : STD_LOGIC_VECTOR (31 downto 0);
signal tcp_address : STD_LOGIC_VECTOR (1 downto 0);
signal tcp_byteenable : STD_LOGIC_VECTOR (3 downto 0);
signal tcp_readdata : STD_LOGIC_VECTOR (31 downto 0);
signal tcp_writedata : STD_LOGIC_VECTOR (31 downto 0);

begin

---- User Signal Assignments ----
-- connect mac reg with mac cmp or reg output signals
with Bus2MAC_REG_CS select 
	IP2Bus_Data_s(C_MAC_REG_PLB_DWIDTH-1 downto 0) <= MAC_REG2Bus_Data(C_MAC_REG_PLB_DWIDTH-1 downto 0) when "10",
		MAC_CMP2Bus_Data(C_MAC_REG_PLB_DWIDTH-1 downto 0) 												when "01",
		(others => '0') 																				when others;
		
with Bus2MAC_REG_CS select 
	IP2Bus_WrAck_s <= MAC_REG2Bus_WrAck 				when "10",
						MAC_CMP2Bus_WrAck 					when "01",
						'0'										when others;	

with Bus2MAC_REG_CS select 
	IP2Bus_RrAck_s <= MAC_REG2Bus_RdAck 				when "10",
						MAC_CMP2Bus_RdAck 					when "01",
						'0'										when others;	

with Bus2MAC_REG_CS select 
	IP2Bus_Error_s <= MAC_REG2Bus_Error 				when "10",
						MAC_CMP2Bus_Error 					when "01",
						'0'										when others;
Bus2MAC_REG_BE_s <= Bus2MAC_REG_BE;
--ap_pcp assignments
clkAp <= Bus2PDI_AP_Clk;
ap_writedata <= Bus2PDI_AP_Data;
--	Bus2MAC_PKT_Data(7 downto 0) & Bus2MAC_PKT_Data(15 downto 8) &
--	Bus2MAC_PKT_Data(23 downto 16) & Bus2MAC_PKT_Data(31 downto 24);
ap_read <= Bus2PDI_AP_RNW;
ap_write <= not Bus2PDI_AP_RNW;
ap_chipselect <= Bus2PDI_AP_CS(0);
ap_byteenable <= Bus2PDI_AP_BE;
ap_address <= Bus2PDI_AP_Addr(12 downto 0);

PDI_AP2Bus_Data <= ap_readdata;
--	mbf_readdata(7 downto 0) & mbf_readdata(15 downto 8) &
--	mbf_readdata(23 downto 16) & mbf_readdata(31 downto 24);
PDI_AP2Bus_RdAck <= ap_chipselect and ap_read and not ap_waitrequest;
PDI_AP2Bus_WrAck <= ap_chipselect and ap_write and not ap_waitrequest;
PDI_AP2Bus_Error <= '0';
--mac_cmp assignments
---cmp_clk <= Bus2MAC_CMP_Clk;
tcp_writedata <= Bus2MAC_REG_Data;
tcp_read <= Bus2MAC_REG_RNW;
tcp_write <= not Bus2MAC_REG_RNW;
tcp_chipselect <= Bus2MAC_REG_CS(0);
tcp_byteenable <= Bus2MAC_REG_BE;
tcp_address <= Bus2MAC_REG_Addr(3 downto 2);

MAC_CMP2Bus_Data <= tcp_readdata;
MAC_CMP2Bus_RdAck <= tcp_chipselect and tcp_read and not tcp_waitrequest;
MAC_CMP2Bus_WrAck <= tcp_chipselect and tcp_write and not tcp_waitrequest;
MAC_CMP2Bus_Error <= '0';
--mac_pkt assignments
pkt_clk <= Bus2MAC_PKT_Clk;
mbf_writedata <= Bus2MAC_PKT_Data;
--	Bus2MAC_PKT_Data(7 downto 0) & Bus2MAC_PKT_Data(15 downto 8) &
--	Bus2MAC_PKT_Data(23 downto 16) & Bus2MAC_PKT_Data(31 downto 24);
mbf_read <= Bus2MAC_PKT_RNW;
mbf_write <= not Bus2MAC_PKT_RNW;
mbf_chipselect <= Bus2MAC_PKT_CS(0);
mbf_byteenable <= Bus2MAC_PKT_BE;
mbf_address <= Bus2MAC_PKT_Addr(C_MAC_PKT_SIZE_LOG2-1 downto 2);

MAC_PKT2Bus_Data <= mbf_readdata;
--	mbf_readdata(7 downto 0) & mbf_readdata(15 downto 8) &
--	mbf_readdata(23 downto 16) & mbf_readdata(31 downto 24);
MAC_PKT2Bus_RdAck <= mbf_chipselect and mbf_read and not mbf_waitrequest;
MAC_PKT2Bus_WrAck <= mbf_chipselect and mbf_write and not mbf_waitrequest;
MAC_PKT2Bus_Error <= '0';
--pdi_pcp assignments
clkPcp <= Bus2PDI_PCP_Clk;
pcp_writedata <= Bus2PDI_PCP_Data;
--	Bus2MAC_PKT_Data(7 downto 0) & Bus2MAC_PKT_Data(15 downto 8) &
--	Bus2MAC_PKT_Data(23 downto 16) & Bus2MAC_PKT_Data(31 downto 24);
pcp_read <= Bus2PDI_PCP_RNW;
pcp_write <= not Bus2PDI_PCP_RNW;
pcp_chipselect <= Bus2PDI_PCP_CS(0);
pcp_byteenable <= Bus2PDI_PCP_BE;
pcp_address <= Bus2PDI_PCP_Addr(12 downto 0);

PDI_PCP2Bus_Data <= pcp_readdata;
--	mbf_readdata(7 downto 0) & mbf_readdata(15 downto 8) &
--	mbf_readdata(23 downto 16) & mbf_readdata(31 downto 24);
PDI_PCP2Bus_RdAck <= pcp_chipselect and pcp_read and not pcp_waitrequest;
PDI_PCP2Bus_WrAck <= pcp_chipselect and pcp_write and not pcp_waitrequest;
PDI_PCP2Bus_Error <= '0';
--SMP_PCP assignments
---cmp_clk <= Bus2SMP_PCP_Clk;
smp_writedata <= Bus2SMP_PCP_Data;
smp_read <= Bus2SMP_PCP_RNW and Bus2SMP_PCP_CS(0);
smp_write <= not Bus2SMP_PCP_RNW and Bus2SMP_PCP_CS(0);
--smp_chipselect <= Bus2SMP_PCP_CS(0);
smp_byteenable <= Bus2SMP_PCP_BE;
smp_address <= Bus2SMP_PCP_Addr(2);

SMP_PCP2Bus_Data <= smp_readdata;
SMP_PCP2Bus_RdAck <= smp_chipselect and smp_read and not smp_waitrequest;
SMP_PCP2Bus_WrAck <= smp_chipselect and smp_write and not smp_waitrequest;
SMP_PCP2Bus_Error <= '0';
--test_port
test_port(255 downto 251) <= m_read & m_write & m_waitrequest & m_readdatavalid & MAC_DMA2Bus_Mst_Type;

test_port(244 downto 240) <= MAC_DMA2Bus_MstWr_Req & MAC_DMA2Bus_MstWr_sof_n & MAC_DMA2Bus_MstWr_eof_n & MAC_DMA2Bus_MstWr_src_rdy_n & Bus2MAC_DMA_MstWr_dst_rdy_n;
test_port(234 downto 230) <= MAC_DMA2Bus_MstRd_Req & Bus2MAC_DMA_MstRd_sof_n & Bus2MAC_DMA_MstRd_eof_n & Bus2MAC_DMA_MstRd_src_rdy_n & MAC_DMA2Bus_MstRd_dst_rdy_n;

test_port(142 downto 140) <= Bus2MAC_DMA_Mst_Cmplt & Bus2MAC_DMA_Mst_Error & Bus2MAC_DMA_Mst_Cmd_Timeout;

test_port(MAC_DMA2Bus_Mst_Length'length+120-1 downto 120) <= MAC_DMA2Bus_Mst_Length;

test_port(m_burstcount'length+110-1 downto 110) <= m_burstcount;
test_port(m_burstcounter'length+96-1 downto 96) <= m_burstcounter;
test_port(95 downto 64) <= m_address;
test_port(63 downto 32) <= m_writedata;
test_port(31 downto 0) <= m_readdata;

----  Component instantiations  ----

MAC_REG_16to32 : openMAC_16to32conv
  generic map (
       bus_address_width => C_MAC_REG_PLB_AWIDTH
  )
  port map(
       bus_ack_rd => MAC_REG2Bus_RdAck,
       bus_ack_wr => MAC_REG2Bus_WrAck,
       bus_address => Bus2MAC_REG_Addr( C_MAC_REG_PLB_AWIDTH-1 downto 0 ),
       bus_byteenable => Bus2MAC_REG_BE_s( (C_MAC_REG_PLB_DWIDTH/8)-1 downto 0 ),
       bus_read => Bus2MAC_REG_RNW,
       bus_readdata => MAC_REG2Bus_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       bus_select => Bus2MAC_REG_CS(1),
       bus_write => Bus2MAC_REG_RNW_n,
       bus_writedata => Bus2MAC_REG_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       clk => Bus2MAC_REG_Clk,
       rst => rst,
       s_address => mac_address( C_MAC_REG_PLB_AWIDTH-1 downto 0 ),
       s_byteenable => mac_byteenable,
       s_chipselect => mac_chipselect,
       s_read => mac_read,
       s_readdata => mac_readdata,
       s_waitrequest => mac_waitrequest,
       s_write => mac_write,
       s_writedata => mac_writedata
  );

MAC_REG_PLB_SINGLE_SLAVE : plbv46_slave_single
  generic map (
       C_ARD_ADDR_RANGE_ARRAY => (C_MAC_REG_BASE,C_MAC_REG_HIGH,C_MAC_CMP_BASE,C_MAC_CMP_HIGH),
       C_ARD_NUM_CE_ARRAY => (1, 1),
       C_BUS2CORE_CLK_RATIO => 1,
       C_FAMILY => C_FAMILY,
       C_INCLUDE_DPHASE_TIMER => 0,
       C_SIPIF_DWIDTH => C_MAC_REG_PLB_DWIDTH,
       C_SPLB_AWIDTH => C_MAC_REG_PLB_AWIDTH,
       C_SPLB_DWIDTH => C_MAC_REG_PLB_DWIDTH,
       C_SPLB_MID_WIDTH => C_MAC_REG_PLB_MID_WIDTH,
       C_SPLB_NUM_MASTERS => C_MAC_REG_PLB_NUM_MASTERS,
       C_SPLB_P2P => C_MAC_REG_PLB_P2P
  )
  port map(
       Bus2IP_Addr => Bus2MAC_REG_Addr( C_MAC_REG_PLB_AWIDTH-1 downto 0 ),
       Bus2IP_BE => Bus2MAC_REG_BE( (C_MAC_REG_PLB_DWIDTH/8)-1 downto 0 ),
       Bus2IP_CS => Bus2MAC_REG_CS( 1 downto 0 ),
       Bus2IP_Clk => Bus2MAC_REG_Clk,
       Bus2IP_Data => Bus2MAC_REG_Data( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       Bus2IP_RNW => Bus2MAC_REG_RNW,
       Bus2IP_Reset => Bus2MAC_REG_Reset,
       IP2Bus_Data => IP2Bus_Data_s( C_MAC_REG_PLB_DWIDTH-1 downto 0 ),
       IP2Bus_Error => IP2Bus_Error_s,
       IP2Bus_RdAck => IP2Bus_RrAck_s,
       IP2Bus_WrAck => IP2Bus_WrAck_s,
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
       endian_g => "big",
       genABuf1_g => C_PDI_GEN_ASYNC_BUF_0,
       genABuf2_g => C_PDI_GEN_ASYNC_BUF_1,
       genEvent_g => false,
       genInternalAp_g => C_GEN_PLB_BUS_IF,
       genIoBuf_g => false,
       genLedGadget_g => C_PDI_GEN_LED,
       genOnePdiClkDomain_g => false,
       genPdi_g => C_GEN_PDI,
       genSimpleIO_g => C_GEN_SIMPLE_IO,
       genSmiIO => false,
       genSpiAp_g => C_GEN_SPI_IF,
       genTimeSync_g => C_PDI_GEN_TIME_SYNC,
       gen_dma_observer_g => true,
       iAsyBuf1Size_g => C_PDI_ASYNC_BUF_0,
       iAsyBuf2Size_g => C_PDI_ASYNC_BUF_1,
       iBufSizeLOG2_g => C_MAC_PKT_SIZE_LOG2,
       iBufSize_g => C_MAC_PKT_SIZE,
       iPdiRev_g => 21930,
       iRpdo0BufSize_g => C_RPDO_0_BUF_SIZE,
       iRpdo1BufSize_g => C_RPDO_1_BUF_SIZE,
       iRpdo2BufSize_g => C_RPDO_2_BUF_SIZE,
       iRpdos_g => C_NUM_RPDO,
       iTpdoBufSize_g => C_TPDO_BUF_SIZE,
       iTpdos_g => C_NUM_TPDO,
       m_burstcount_const_g => true,
       m_burstcount_width_g => C_M_BURSTCOUNT_WIDTH,
       m_data_width_g => 32,
       m_rx_burst_size_g => C_MAC_DMA_BURST_SIZE/4,
       m_rx_fifo_size_g => C_M_FIFO_SIZE,
       m_tx_burst_size_g => C_MAC_DMA_BURST_SIZE/4,
       m_tx_fifo_size_g => C_M_FIFO_SIZE,
       papBigEnd_g => C_PAP_BIG_END,
       papDataWidth_g => C_PAP_DATA_WIDTH,
       papLowAct_g => C_PAP_LOW_ACT,
       pioValLen_g => C_PIO_VAL_LENGTH,
       spiBigEnd_g => C_SPI_BIG_END,
       spiCPHA_g => C_SPI_CPHA,
       spiCPOL_g => C_SPI_CPOL,
       use2ndCmpTimer_g => C_PDI_GEN_SECOND_TIMER,
       use2ndPhy_g => C_USE_2ND_PHY,
       useHwAcc_g => false,
       useIntPacketBuf_g => C_MAC_PKT_EN,
       useRmii_g => C_USE_RMII,
       useRxIntPacketBuf_g => C_MAC_PKT_RX_EN
  )
  port map(
       mac_address(0) => mac_address(0),
       mac_address(1) => mac_address(1),
       mac_address(2) => mac_address(2),
       mac_address(3) => mac_address(3),
       mac_address(4) => mac_address(4),
       mac_address(5) => mac_address(5),
       mac_address(6) => mac_address(6),
       mac_address(7) => mac_address(7),
       mac_address(8) => mac_address(8),
       mac_address(9) => mac_address(9),
       mac_address(10) => mac_address(10),
       mac_address(11) => mac_address(11),
       m_address(0) => m_address(0),
       m_address(1) => m_address(1),
       m_address(2) => m_address(2),
       m_address(3) => m_address(3),
       m_address(4) => m_address(4),
       m_address(5) => m_address(5),
       m_address(6) => m_address(6),
       m_address(7) => m_address(7),
       m_address(8) => m_address(8),
       m_address(9) => m_address(9),
       m_address(10) => m_address(10),
       m_address(11) => m_address(11),
       m_address(12) => m_address(12),
       m_address(13) => m_address(13),
       m_address(14) => m_address(14),
       m_address(15) => m_address(15),
       m_address(16) => m_address(16),
       m_address(17) => m_address(17),
       m_address(18) => m_address(18),
       m_address(19) => m_address(19),
       m_address(20) => m_address(20),
       m_address(21) => m_address(21),
       m_address(22) => m_address(22),
       m_address(23) => m_address(23),
       m_address(24) => m_address(24),
       m_address(25) => m_address(25),
       m_address(26) => m_address(26),
       m_address(27) => m_address(27),
       m_address(28) => m_address(28),
       m_address(29) => m_address(29),
       ap_address => ap_address,
       ap_asyncIrq => ap_asyncIrq,
       ap_asyncIrq_n => ap_asyncIrq_n,
       ap_byteenable => ap_byteenable,
       ap_chipselect => ap_chipselect,
       ap_irq => ap_irq,
       ap_irq_n => ap_irq_n,
       ap_read => ap_read,
       ap_readdata => ap_readdata,
       ap_waitrequest => ap_waitrequest,
       ap_write => ap_write,
       ap_writedata => ap_writedata,
       clk50 => clk50,
       clkAp => clkAp,
       clkEth => clk100,
       clkPcp => clkPcp,
       led_error => led_error,
       led_gpo => led_gpo,
       led_opt => led_opt,
       led_phyAct => led_phyAct,
       led_phyLink => led_phyLink,
       led_status => led_status,
       m_burstcount => m_burstcount( C_M_BURSTCOUNT_WIDTH-1 downto 0 ),
       m_burstcounter => m_burstcounter( C_M_BURSTCOUNT_WIDTH-1 downto 0 ),
       m_byteenable => m_byteenable( 3 downto 0 ),
       m_clk => m_clk,
       m_read => m_read,
       m_readdata => m_readdata( 31 downto 0 ),
       m_readdatavalid => m_readdatavalid,
       m_waitrequest => m_waitrequest,
       m_write => m_write,
       m_writedata => m_writedata( 31 downto 0 ),
       mac_byteenable => mac_byteenable,
       mac_chipselect => mac_chipselect,
       mac_irq => mac_irq_s,
       mac_read => mac_read,
       mac_readdata => mac_readdata,
       mac_waitrequest => mac_waitrequest,
       mac_write => mac_write,
       mac_writedata => mac_writedata,
       mbf_address => mbf_address( C_MAC_PKT_SIZE_LOG2-3 downto 0 ),
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
       pap_be => pap_be( C_PAP_DATA_WIDTH/8-1 downto 0 ),
       pap_be_n => pap_be_n( C_PAP_DATA_WIDTH/8-1 downto 0 ),
       pap_cs => pap_cs,
       pap_cs_n => pap_cs_n,
       pap_data_I => pap_data_I( C_PAP_DATA_WIDTH-1 downto 0 ),
       pap_data_O => pap_data_O( C_PAP_DATA_WIDTH-1 downto 0 ),
       pap_data_T => pap_data_T,
       pap_gpio_I => pap_gpio_I,
       pap_gpio_O => pap_gpio_O,
       pap_gpio_T => pap_gpio_T,
       pap_rd => pap_rd,
       pap_rd_n => pap_rd_n,
       pap_wr => pap_wr,
       pap_wr_n => pap_wr_n,
       pcp_address => pcp_address,
       pcp_byteenable => pcp_byteenable,
       pcp_chipselect => pcp_chipselect,
       pcp_read => pcp_read,
       pcp_readdata => pcp_readdata,
       pcp_waitrequest => pcp_waitrequest,
       pcp_write => pcp_write,
       pcp_writedata => pcp_writedata,
       phy0_Rst_n => phy0_Rst_n,
       phy0_RxDat => phy0_RxDat,
       phy0_RxDv => phy0_RxDv,
       phy0_RxErr => phy0_RxErr,
       phy0_SMIClk => phy0_SMIClk,
       phy0_SMIDat_I => phy0_SMIDat_I,
       phy0_SMIDat_O => phy0_SMIDat_O,
       phy0_SMIDat_T => phy0_SMIDat_T,
       phy0_TxDat => phy0_TxDat,
       phy0_TxEn => phy0_TxEn,
       phy0_link => phy0_link,
       phy1_Rst_n => phy1_Rst_n,
       phy1_RxDat => phy1_RxDat,
       phy1_RxDv => phy1_RxDv,
       phy1_RxErr => phy1_RxErr,
       phy1_SMIClk => phy1_SMIClk,
       phy1_SMIDat_I => phy1_SMIDat_I,
       phy1_SMIDat_O => phy1_SMIDat_O,
       phy1_SMIDat_T => phy1_SMIDat_T,
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
       pio_portio_I => pio_portio_I,
       pio_portio_O => pio_portio_O,
       pio_portio_T => pio_portio_T,
       pkt_clk => pkt_clk,
       rst => rst,
       rstAp => rstAp,
       rstPcp => rstPcp,
       smp_address => smp_address,
       smp_byteenable => smp_byteenable,
       smp_read => smp_read,
       smp_readdata => smp_readdata,
       smp_waitrequest => smp_waitrequest,
       smp_write => smp_write,
       smp_writedata => smp_writedata,
       spi_clk => spi_clk,
       spi_miso => spi_miso,
       spi_mosi => spi_mosi,
       spi_sel_n => spi_sel_n,
       tcp_address => tcp_address,
       tcp_byteenable => tcp_byteenable,
       tcp_chipselect => tcp_chipselect,
       tcp_irq => tcp_irq_s,
       tcp_read => tcp_read,
       tcp_readdata => tcp_readdata,
       tcp_waitrequest => tcp_waitrequest,
       tcp_write => tcp_write,
       tcp_writedata => tcp_writedata
  );

clk50 <= Bus2MAC_REG_Clk;

rst <= Bus2MAC_REG_Reset or Bus2MAC_CMP_Reset or MAC_DMA_RST or Bus2MAC_PKT_Reset;

Bus2MAC_REG_RNW_n <= not(Bus2MAC_REG_RNW);


---- Power , ground assignment ----

GND <= GND_CONSTANT;
MAC_REG2Bus_Error <= GND;

---- Terminal assignment ----

    -- Output\buffer terminals
	mac_irq <= mac_irq_s;
	tcp_irq <= tcp_irq_s;


----  Generate statements  ----

g0 : if C_DMA_EN = TRUE generate
begin
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
end generate g0;

g2 : if C_DMA_EN = TRUE generate
begin
  THE_PLB_MASTER_HANDLER : plb_master_handler
    generic map (
         C_MAC_DMA_PLB_AWIDTH => C_MAC_DMA_PLB_AWIDTH,
         C_MAC_DMA_PLB_NATIVE_DWIDTH => C_MAC_DMA_PLB_NATIVE_DWIDTH,
         dma_highadr_g => m_address'high,
         gen_rx_fifo_g => not C_TX_INT_PKT,
         gen_tx_fifo_g => not C_RX_INT_PKT,
         m_burstcount_width_g => C_M_BURSTCOUNT_WIDTH
    )  
    port map(
         Bus2MAC_DMA_MstRd_d => Bus2MAC_DMA_MstRd_d( 0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1 ),
         Bus2MAC_DMA_MstRd_eof_n => Bus2MAC_DMA_MstRd_eof_n,
         Bus2MAC_DMA_MstRd_rem => Bus2MAC_DMA_MstRd_rem( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
         Bus2MAC_DMA_MstRd_sof_n => Bus2MAC_DMA_MstRd_sof_n,
         Bus2MAC_DMA_MstRd_src_dsc_n => Bus2MAC_DMA_MstRd_src_dsc_n,
         Bus2MAC_DMA_MstRd_src_rdy_n => Bus2MAC_DMA_MstRd_src_rdy_n,
         Bus2MAC_DMA_MstWr_dst_dsc_n => Bus2MAC_DMA_MstWr_dst_dsc_n,
         Bus2MAC_DMA_MstWr_dst_rdy_n => Bus2MAC_DMA_MstWr_dst_rdy_n,
         Bus2MAC_DMA_Mst_CmdAck => Bus2MAC_DMA_Mst_CmdAck,
         Bus2MAC_DMA_Mst_Cmd_Timeout => Bus2MAC_DMA_Mst_Cmd_Timeout,
         Bus2MAC_DMA_Mst_Cmplt => Bus2MAC_DMA_Mst_Cmplt,
         Bus2MAC_DMA_Mst_Error => Bus2MAC_DMA_Mst_Error,
         Bus2MAC_DMA_Mst_Rearbitrate => Bus2MAC_DMA_Mst_Rearbitrate,
         MAC_DMA2Bus_MstRd_Req => MAC_DMA2Bus_MstRd_Req,
         MAC_DMA2Bus_MstRd_dst_dsc_n => MAC_DMA2Bus_MstRd_dst_dsc_n,
         MAC_DMA2Bus_MstRd_dst_rdy_n => MAC_DMA2Bus_MstRd_dst_rdy_n,
         MAC_DMA2Bus_MstWr_Req => MAC_DMA2Bus_MstWr_Req,
         MAC_DMA2Bus_MstWr_d => MAC_DMA2Bus_MstWr_d( 0 to C_MAC_DMA_PLB_NATIVE_DWIDTH-1 ),
         MAC_DMA2Bus_MstWr_eof_n => MAC_DMA2Bus_MstWr_eof_n,
         MAC_DMA2Bus_MstWr_rem => MAC_DMA2Bus_MstWr_rem( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
         MAC_DMA2Bus_MstWr_sof_n => MAC_DMA2Bus_MstWr_sof_n,
         MAC_DMA2Bus_MstWr_src_dsc_n => MAC_DMA2Bus_MstWr_src_dsc_n,
         MAC_DMA2Bus_MstWr_src_rdy_n => MAC_DMA2Bus_MstWr_src_rdy_n,
         MAC_DMA2Bus_Mst_Addr => MAC_DMA2Bus_Mst_Addr( 0 to C_MAC_DMA_PLB_AWIDTH-1 ),
         MAC_DMA2Bus_Mst_BE => MAC_DMA2Bus_Mst_BE( 0 to (C_MAC_DMA_PLB_NATIVE_DWIDTH/8)-1 ),
         MAC_DMA2Bus_Mst_Length => MAC_DMA2Bus_Mst_Length,
         MAC_DMA2Bus_Mst_Lock => MAC_DMA2Bus_Mst_Lock,
         MAC_DMA2Bus_Mst_Reset => MAC_DMA2Bus_Mst_Reset,
         MAC_DMA2Bus_Mst_Type => MAC_DMA2Bus_Mst_Type,
         MAC_DMA_CLK => MAC_DMA_CLK,
         MAC_DMA_Rst => MAC_DMA_Rst,
         m_address => m_address( 31 downto 0 ),
         m_burstcount => m_burstcount( C_M_BURSTCOUNT_WIDTH-1 downto 0 ),
         m_burstcounter => m_burstcounter( C_M_BURSTCOUNT_WIDTH-1 downto 0 ),
         m_byteenable => m_byteenable,
         m_clk => m_clk,
         m_read => m_read,
         m_readdata => m_readdata,
         m_readdatavalid => m_readdatavalid,
         m_waitrequest => m_waitrequest,
         m_write => m_write,
         m_writedata => m_writedata
    );
end generate g2;

g1 : if C_PKT_BUF_EN generate
begin
  MAC_PKT_PLB_SINGLE_SLAVE : plbv46_slave_single
    generic map (
         C_ARD_ADDR_RANGE_ARRAY => (C_MAC_PKT_BASE,C_MAC_PKT_HIGH),
         C_ARD_NUM_CE_ARRAY => (0 => 1),
         C_BUS2CORE_CLK_RATIO => 1,
         C_FAMILY => C_FAMILY,
         C_INCLUDE_DPHASE_TIMER => 0,
         C_SIPIF_DWIDTH => C_MAC_PKT_PLB_DWIDTH,
         C_SPLB_AWIDTH => C_MAC_PKT_PLB_AWIDTH,
         C_SPLB_DWIDTH => C_MAC_PKT_PLB_DWIDTH,
         C_SPLB_MID_WIDTH => C_MAC_PKT_PLB_MID_WIDTH,
         C_SPLB_NUM_MASTERS => C_MAC_PKT_PLB_NUM_MASTERS,
         C_SPLB_P2P => C_MAC_PKT_PLB_P2P
    )  
    port map(
         Bus2IP_Addr => Bus2MAC_PKT_Addr( C_MAC_PKT_PLB_AWIDTH-1 downto 0 ),
         Bus2IP_BE => Bus2MAC_PKT_BE( (C_MAC_PKT_PLB_DWIDTH/8)-1 downto 0 ),
         Bus2IP_CS => Bus2MAC_PKT_CS( 0 downto 0 ),
         Bus2IP_Clk => Bus2MAC_PKT_Clk,
         Bus2IP_Data => Bus2MAC_PKT_Data( C_MAC_PKT_PLB_DWIDTH-1 downto 0 ),
         Bus2IP_RNW => Bus2MAC_PKT_RNW,
         Bus2IP_Reset => Bus2MAC_PKT_Reset,
         IP2Bus_Data => MAC_PKT2Bus_Data( C_MAC_PKT_PLB_DWIDTH-1 downto 0 ),
         IP2Bus_Error => MAC_PKT2Bus_Error,
         IP2Bus_RdAck => MAC_PKT2Bus_RdAck,
         IP2Bus_WrAck => MAC_PKT2Bus_WrAck,
         PLB_ABus => MAC_PKT_ABus,
         PLB_BE => MAC_PKT_BE( 0 to (C_MAC_PKT_PLB_DWIDTH/8)-1 ),
         PLB_MSize => MAC_PKT_MSize,
         PLB_PAValid => MAC_PKT_PAValid,
         PLB_RNW => MAC_PKT_RNW,
         PLB_SAValid => MAC_PKT_SAValid,
         PLB_TAttribute => MAC_PKT_TAttribute,
         PLB_UABus => MAC_PKT_UABus,
         PLB_abort => MAC_PKT_abort,
         PLB_busLock => MAC_PKT_busLock,
         PLB_lockErr => MAC_PKT_lockErr,
         PLB_masterID => MAC_PKT_masterID( 0 to C_MAC_PKT_PLB_MID_WIDTH-1 ),
         PLB_rdBurst => MAC_PKT_rdBurst,
         PLB_rdPendPri => MAC_PKT_rdPendPri,
         PLB_rdPendReq => MAC_PKT_rdPendReq,
         PLB_rdPrim => MAC_PKT_rdPrim,
         PLB_reqPri => MAC_PKT_reqPri,
         PLB_size => MAC_PKT_size,
         PLB_type => MAC_PKT_type,
         PLB_wrBurst => MAC_PKT_wrBurst,
         PLB_wrDBus => MAC_PKT_wrDBus( 0 to C_MAC_PKT_PLB_DWIDTH-1 ),
         PLB_wrPendPri => MAC_PKT_wrPendPri,
         PLB_wrPendReq => MAC_PKT_wrPendReq,
         PLB_wrPrim => MAC_PKT_wrPrim,
         SPLB_Clk => MAC_PKT_Clk,
         SPLB_Rst => MAC_PKT_Rst,
         Sl_MBusy => MAC_PKT_MBusy( 0 to C_MAC_PKT_NUM_MASTERS-1 ),
         Sl_MIRQ => MAC_PKT_MIRQ( 0 to C_MAC_PKT_NUM_MASTERS-1 ),
         Sl_MRdErr => MAC_PKT_MRdErr( 0 to C_MAC_PKT_NUM_MASTERS-1 ),
         Sl_MWrErr => MAC_PKT_MWrErr( 0 to C_MAC_PKT_NUM_MASTERS-1 ),
         Sl_SSize => MAC_PKT_SSize,
         Sl_addrAck => MAC_PKT_addrAck,
         Sl_rdBTerm => MAC_PKT_rdBTerm,
         Sl_rdComp => MAC_PKT_rdComp,
         Sl_rdDAck => MAC_PKT_rdDAck,
         Sl_rdDBus => MAC_PKT_rdDBus( 0 to C_MAC_PKT_PLB_DWIDTH-1 ),
         Sl_rdWdAddr => MAC_PKT_rdWdAddr,
         Sl_rearbitrate => MAC_PKT_rearbitrate,
         Sl_wait => MAC_PKT_wait,
         Sl_wrBTerm => MAC_PKT_wrBTerm,
         Sl_wrComp => MAC_PKT_wrComp,
         Sl_wrDAck => MAC_PKT_wrDAck
    );
end generate g1;

g3 : if (C_GEN_PDI) generate
begin
  U3 : plbv46_slave_single
    generic map (
         C_ARD_ADDR_RANGE_ARRAY => (C_PDI_PCP_BASE,C_PDI_PCP_HIGH),
         C_ARD_NUM_CE_ARRAY => (0 => 1),
         C_BUS2CORE_CLK_RATIO => 1,
         C_FAMILY => C_FAMILY,
         C_INCLUDE_DPHASE_TIMER => 0,
         C_SIPIF_DWIDTH => C_PDI_PCP_PLB_DWIDTH,
         C_SPLB_AWIDTH => C_PDI_PCP_PLB_AWIDTH,
         C_SPLB_DWIDTH => C_PDI_PCP_PLB_DWIDTH,
         C_SPLB_MID_WIDTH => C_PDI_PCP_PLB_MID_WIDTH,
         C_SPLB_NUM_MASTERS => C_PDI_PCP_PLB_NUM_MASTERS,
         C_SPLB_P2P => C_PDI_PCP_PLB_P2P
    )  
    port map(
         Bus2IP_Addr => Bus2PDI_PCP_Addr( C_PDI_PCP_PLB_AWIDTH-1 downto 0 ),
         Bus2IP_BE => Bus2PDI_PCP_BE( (C_PDI_PCP_PLB_DWIDTH/8)-1 downto 0 ),
         Bus2IP_CS => Bus2PDI_PCP_CS( 0 downto 0 ),
         Bus2IP_Clk => Bus2PDI_PCP_Clk,
         Bus2IP_Data => Bus2PDI_PCP_Data( C_PDI_PCP_PLB_DWIDTH-1 downto 0 ),
         Bus2IP_RNW => Bus2PDI_PCP_RNW,
         Bus2IP_Reset => Bus2PDI_PCP_Reset,
         IP2Bus_Data => PDI_PCP2Bus_Data( C_PDI_PCP_PLB_DWIDTH-1 downto 0 ),
         IP2Bus_Error => PDI_PCP2Bus_Error,
         IP2Bus_RdAck => PDI_PCP2Bus_RdAck,
         IP2Bus_WrAck => PDI_PCP2Bus_WrAck,
         PLB_ABus => PDI_PCP_ABus,
         PLB_BE => PDI_PCP_BE( 0 to (C_PDI_PCP_PLB_DWIDTH/8)-1 ),
         PLB_MSize => PDI_PCP_MSize,
         PLB_PAValid => PDI_PCP_PAValid,
         PLB_RNW => PDI_PCP_RNW,
         PLB_SAValid => PDI_PCP_SAValid,
         PLB_TAttribute => PDI_PCP_TAttribute,
         PLB_UABus => PDI_PCP_UABus,
         PLB_abort => PDI_PCP_abort,
         PLB_busLock => PDI_PCP_busLock,
         PLB_lockErr => PDI_PCP_lockErr,
         PLB_masterID => PDI_PCP_masterID( 0 to C_PDI_PCP_PLB_MID_WIDTH-1 ),
         PLB_rdBurst => PDI_PCP_rdBurst,
         PLB_rdPendPri => PDI_PCP_rdPendPri,
         PLB_rdPendReq => PDI_PCP_rdPendReq,
         PLB_rdPrim => PDI_PCP_rdPrim,
         PLB_reqPri => PDI_PCP_reqPri,
         PLB_size => PDI_PCP_size,
         PLB_type => PDI_PCP_type,
         PLB_wrBurst => PDI_PCP_wrBurst,
         PLB_wrDBus => PDI_PCP_wrDBus( 0 to C_PDI_PCP_PLB_DWIDTH-1 ),
         PLB_wrPendPri => PDI_PCP_wrPendPri,
         PLB_wrPendReq => PDI_PCP_wrPendReq,
         PLB_wrPrim => PDI_PCP_wrPrim,
         SPLB_Clk => PDI_PCP_Clk,
         SPLB_Rst => PDI_PCP_Rst,
         Sl_MBusy => PDI_PCP_MBusy( 0 to C_PDI_PCP_NUM_MASTERS-1 ),
         Sl_MIRQ => PDI_PCP_MIRQ( 0 to C_PDI_PCP_NUM_MASTERS-1 ),
         Sl_MRdErr => PDI_PCP_MRdErr( 0 to C_PDI_PCP_NUM_MASTERS-1 ),
         Sl_MWrErr => PDI_PCP_MWrErr( 0 to C_PDI_PCP_NUM_MASTERS-1 ),
         Sl_SSize => PDI_PCP_SSize,
         Sl_addrAck => PDI_PCP_addrAck,
         Sl_rdBTerm => PDI_PCP_rdBTerm,
         Sl_rdComp => PDI_PCP_rdComp,
         Sl_rdDAck => PDI_PCP_rdDAck,
         Sl_rdDBus => PDI_PCP_rdDBus( 0 to C_PDI_PCP_PLB_DWIDTH-1 ),
         Sl_rdWdAddr => PDI_PCP_rdWdAddr,
         Sl_rearbitrate => PDI_PCP_rearbitrate,
         Sl_wait => PDI_PCP_wait,
         Sl_wrBTerm => PDI_PCP_wrBTerm,
         Sl_wrComp => PDI_PCP_wrComp,
         Sl_wrDAck => PDI_PCP_wrDAck
    );
end generate g3;

g4 : if (C_GEN_PLB_BUS_IF) generate
begin
  U4 : plbv46_slave_single
    generic map (
         C_ARD_ADDR_RANGE_ARRAY => (C_PDI_AP_BASE,C_PDI_AP_HIGH),
         C_ARD_NUM_CE_ARRAY => (0 => 1),
         C_BUS2CORE_CLK_RATIO => 1,
         C_FAMILY => C_FAMILY,
         C_INCLUDE_DPHASE_TIMER => 0,
         C_SIPIF_DWIDTH => C_PDI_AP_PLB_DWIDTH,
         C_SPLB_AWIDTH => C_PDI_AP_PLB_AWIDTH,
         C_SPLB_DWIDTH => C_PDI_AP_PLB_DWIDTH,
         C_SPLB_MID_WIDTH => C_PDI_AP_PLB_MID_WIDTH,
         C_SPLB_NUM_MASTERS => C_PDI_AP_PLB_NUM_MASTERS,
         C_SPLB_P2P => C_PDI_AP_PLB_P2P
    )  
    port map(
         Bus2IP_Addr => Bus2PDI_AP_Addr( C_PDI_AP_PLB_AWIDTH-1 downto 0 ),
         Bus2IP_BE => Bus2PDI_AP_BE( (C_PDI_AP_PLB_DWIDTH/8)-1 downto 0 ),
         Bus2IP_CS => Bus2PDI_AP_CS( 0 downto 0 ),
         Bus2IP_Clk => Bus2PDI_AP_Clk,
         Bus2IP_Data => Bus2PDI_AP_Data( C_PDI_AP_PLB_DWIDTH-1 downto 0 ),
         Bus2IP_RNW => Bus2PDI_AP_RNW,
         Bus2IP_Reset => Bus2PDI_AP_Reset,
         IP2Bus_Data => PDI_AP2Bus_Data( C_PDI_AP_PLB_DWIDTH-1 downto 0 ),
         IP2Bus_Error => PDI_AP2Bus_Error,
         IP2Bus_RdAck => PDI_AP2Bus_RdAck,
         IP2Bus_WrAck => PDI_AP2Bus_WrAck,
         PLB_ABus => PDI_AP_ABus,
         PLB_BE => PDI_AP_BE( 0 to (C_PDI_AP_PLB_DWIDTH/8)-1 ),
         PLB_MSize => PDI_AP_MSize,
         PLB_PAValid => PDI_AP_PAValid,
         PLB_RNW => PDI_AP_RNW,
         PLB_SAValid => PDI_AP_SAValid,
         PLB_TAttribute => PDI_AP_TAttribute,
         PLB_UABus => PDI_AP_UABus,
         PLB_abort => PDI_AP_abort,
         PLB_busLock => PDI_AP_busLock,
         PLB_lockErr => PDI_AP_lockErr,
         PLB_masterID => PDI_AP_masterID( 0 to C_PDI_AP_PLB_MID_WIDTH-1 ),
         PLB_rdBurst => PDI_AP_rdBurst,
         PLB_rdPendPri => PDI_AP_rdPendPri,
         PLB_rdPendReq => PDI_AP_rdPendReq,
         PLB_rdPrim => PDI_AP_rdPrim,
         PLB_reqPri => PDI_AP_reqPri,
         PLB_size => PDI_AP_size,
         PLB_type => PDI_AP_type,
         PLB_wrBurst => PDI_AP_wrBurst,
         PLB_wrDBus => PDI_AP_wrDBus( 0 to C_PDI_AP_PLB_DWIDTH-1 ),
         PLB_wrPendPri => PDI_AP_wrPendPri,
         PLB_wrPendReq => PDI_AP_wrPendReq,
         PLB_wrPrim => PDI_AP_wrPrim,
         SPLB_Clk => PDI_AP_Clk,
         SPLB_Rst => PDI_AP_Rst,
         Sl_MBusy => PDI_AP_MBusy( 0 to C_PDI_AP_PLB_NUM_MASTERS-1 ),
         Sl_MIRQ => PDI_AP_MIRQ( 0 to C_PDI_AP_PLB_NUM_MASTERS-1 ),
         Sl_MRdErr => PDI_AP_MRdErr( 0 to C_PDI_AP_PLB_NUM_MASTERS-1 ),
         Sl_MWrErr => PDI_AP_MWrErr( 0 to C_PDI_AP_PLB_NUM_MASTERS-1 ),
         Sl_SSize => PDI_AP_SSize,
         Sl_addrAck => PDI_AP_addrAck,
         Sl_rdBTerm => PDI_AP_rdBTerm,
         Sl_rdComp => PDI_AP_rdComp,
         Sl_rdDAck => PDI_AP_rdDAck,
         Sl_rdDBus => PDI_AP_rdDBus( 0 to C_PDI_AP_PLB_DWIDTH-1 ),
         Sl_rdWdAddr => PDI_AP_rdWdAddr,
         Sl_rearbitrate => PDI_AP_rearbitrate,
         Sl_wait => PDI_AP_wait,
         Sl_wrBTerm => PDI_AP_wrBTerm,
         Sl_wrComp => PDI_AP_wrComp,
         Sl_wrDAck => PDI_AP_wrDAck
    );
end generate g4;

g5 : if (C_GEN_SIMPLE_IO) generate
begin
  U5 : plbv46_slave_single
    generic map (
         C_ARD_ADDR_RANGE_ARRAY => (C_SMP_PCP_BASE,C_SMP_PCP_HIGH),
         C_ARD_NUM_CE_ARRAY => (0 => 1),
         C_BUS2CORE_CLK_RATIO => 1,
         C_FAMILY => C_FAMILY,
         C_INCLUDE_DPHASE_TIMER => 0,
         C_SIPIF_DWIDTH => C_SMP_PCP_PLB_DWIDTH,
         C_SPLB_AWIDTH => C_SMP_PCP_PLB_AWIDTH,
         C_SPLB_DWIDTH => C_SMP_PCP_PLB_DWIDTH,
         C_SPLB_MID_WIDTH => C_SMP_PCP_PLB_MID_WIDTH,
         C_SPLB_NUM_MASTERS => C_SMP_PCP_PLB_NUM_MASTERS,
         C_SPLB_P2P => C_SMP_PCP_PLB_P2P
    )  
    port map(
         Bus2IP_Addr => Bus2SMP_PCP_Addr( C_SMP_PCP_PLB_AWIDTH-1 downto 0 ),
         Bus2IP_BE => Bus2SMP_PCP_BE( (C_SMP_PCP_PLB_DWIDTH/8)-1 downto 0 ),
         Bus2IP_CS => Bus2SMP_PCP_CS( 0 downto 0 ),
         Bus2IP_Clk => Bus2SMP_PCP_Clk,
         Bus2IP_Data => Bus2SMP_PCP_Data( C_SMP_PCP_PLB_DWIDTH-1 downto 0 ),
         Bus2IP_RNW => Bus2SMP_PCP_RNW,
         Bus2IP_Reset => Bus2SMP_PCP_Reset,
         IP2Bus_Data => SMP_PCP2Bus_Data( C_SMP_PCP_PLB_DWIDTH-1 downto 0 ),
         IP2Bus_Error => SMP_PCP2Bus_Error,
         IP2Bus_RdAck => SMP_PCP2Bus_RdAck,
         IP2Bus_WrAck => SMP_PCP2Bus_WrAck,
         PLB_ABus => SMP_PCP_ABus,
         PLB_BE => SMP_PCP_BE( 0 to (C_SMP_PCP_PLB_DWIDTH/8)-1 ),
         PLB_MSize => SMP_PCP_MSize,
         PLB_PAValid => SMP_PCP_PAValid,
         PLB_RNW => SMP_PCP_RNW,
         PLB_SAValid => SMP_PCP_SAValid,
         PLB_TAttribute => SMP_PCP_TAttribute,
         PLB_UABus => SMP_PCP_UABus,
         PLB_abort => SMP_PCP_abort,
         PLB_busLock => SMP_PCP_busLock,
         PLB_lockErr => SMP_PCP_lockErr,
         PLB_masterID => SMP_PCP_masterID( 0 to C_SMP_PCP_PLB_MID_WIDTH-1 ),
         PLB_rdBurst => SMP_PCP_rdBurst,
         PLB_rdPendPri => SMP_PCP_rdPendPri,
         PLB_rdPendReq => SMP_PCP_rdPendReq,
         PLB_rdPrim => SMP_PCP_rdPrim,
         PLB_reqPri => SMP_PCP_reqPri,
         PLB_size => SMP_PCP_size,
         PLB_type => SMP_PCP_type,
         PLB_wrBurst => SMP_PCP_wrBurst,
         PLB_wrDBus => SMP_PCP_wrDBus( 0 to C_SMP_PCP_PLB_DWIDTH-1 ),
         PLB_wrPendPri => SMP_PCP_wrPendPri,
         PLB_wrPendReq => SMP_PCP_wrPendReq,
         PLB_wrPrim => SMP_PCP_wrPrim,
         SPLB_Clk => SMP_PCP_Clk,
         SPLB_Rst => SMP_PCP_Rst,
         Sl_MBusy => SMP_PCP_MBusy( 0 to C_SMP_PCP_PLB_NUM_MASTERS-1 ),
         Sl_MIRQ => SMP_PCP_MIRQ( 0 to C_SMP_PCP_PLB_NUM_MASTERS-1 ),
         Sl_MRdErr => SMP_PCP_MRdErr( 0 to C_SMP_PCP_PLB_NUM_MASTERS-1 ),
         Sl_MWrErr => SMP_PCP_MWrErr( 0 to C_SMP_PCP_PLB_NUM_MASTERS-1 ),
         Sl_SSize => SMP_PCP_SSize,
         Sl_addrAck => SMP_PCP_addrAck,
         Sl_rdBTerm => SMP_PCP_rdBTerm,
         Sl_rdComp => SMP_PCP_rdComp,
         Sl_rdDAck => SMP_PCP_rdDAck,
         Sl_rdDBus => SMP_PCP_rdDBus( 0 to C_SMP_PCP_PLB_DWIDTH-1 ),
         Sl_rdWdAddr => SMP_PCP_rdWdAddr,
         Sl_rearbitrate => SMP_PCP_rearbitrate,
         Sl_wait => SMP_PCP_wait,
         Sl_wrBTerm => SMP_PCP_wrBTerm,
         Sl_wrComp => SMP_PCP_wrComp,
         Sl_wrDAck => SMP_PCP_wrDAck
    );
end generate g5;

end struct;
