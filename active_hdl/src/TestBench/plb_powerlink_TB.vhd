library ieee;
use ieee.MATH_REAL.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library proc_common_v3_00_a;
use proc_common_v3_00_a.ipif_pkg.all;
use proc_common_v3_00_a.proc_common_pkg.all;

	-- Add your library and packages declaration here ...

entity plb_powerlink_tb is
	-- Generic declarations of the tested unit
		generic(
		papDataWidth_g : integer := 16;
		C_MAC_DMA_BURST_SIZE : integer := 4;
		C_MAC_DMA_FIFO_SIZE : INTEGER := 128; --in bytes
		C_USE_RMII : boolean := false;
		C_TX_INT_PKT : boolean := true;
		C_RX_INT_PKT : boolean := false;
		C_MAC_CMP_BASEADDR : std_logic_vector := x"00020000";
		C_MAC_CMP_HIGHADDR : std_logic_vector := x"00027FFF";
		C_MAC_CMP_NUM_MASTERS : integer := 1;
		C_MAC_CMP_PLB_AWIDTH : integer := 32;
		C_MAC_CMP_PLB_DWIDTH : integer := 32;
		C_MAC_CMP_PLB_MID_WIDTH : integer := 1;
		C_MAC_CMP_PLB_P2P : integer := 0;
		C_MAC_CMP_PLB_NUM_MASTERS : integer := 1;
		C_MAC_CMP_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_CMP_PLB_SUPPORT_BURSTS : integer := 0;
		C_MAC_PKT_BASEADDR : std_logic_vector := x"00008000";
		C_MAC_PKT_HIGHADDR : std_logic_vector := x"0000FFFF";
		C_MAC_PKT_NUM_MASTERS : integer := 1;
		C_MAC_PKT_PLB_AWIDTH : integer := 32;
		C_MAC_PKT_PLB_DWIDTH : integer := 32;
		C_MAC_PKT_PLB_MID_WIDTH : integer := 1;
		C_MAC_PKT_PLB_P2P : integer := 0;
		C_MAC_PKT_PLB_NUM_MASTERS : integer := 1;
		C_MAC_PKT_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_PKT_PLB_SUPPORT_BURSTS : integer := 0;
		C_MAC_DMA_PLB_AWIDTH : integer := 32;
		C_MAC_DMA_PLB_DWIDTH : integer := 32;
		C_MAC_DMA_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_REG_BASEADDR : std_logic_vector := x"00010000";
		C_MAC_REG_HIGHADDR : std_logic_vector := x"00017FFF";
		C_MAC_REG_NUM_MASTERS : integer := 1;
		C_MAC_REG_PLB_AWIDTH : integer := 32;
		C_MAC_REG_PLB_DWIDTH : integer := 32;
		C_MAC_REG_PLB_MID_WIDTH : integer := 1;
		C_MAC_REG_PLB_P2P : integer := 0;
		C_MAC_REG_PLB_NUM_MASTERS : integer := 1;
		C_MAC_REG_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_REG_PLB_SUPPORT_BURSTS : integer := 0 );
end plb_powerlink_tb;

architecture TB_ARCHITECTURE of plb_powerlink_tb is
	-- Component declaration of the tested unit
	component plb_powerlink
		generic(
		papDataWidth_g : integer := 16;
		C_MAC_DMA_BURST_SIZE : integer := 32;
		C_MAC_DMA_FIFO_SIZE : INTEGER := 32; --in bytes
		C_USE_RMII : boolean := false;
		C_TX_INT_PKT : boolean := false;
		C_RX_INT_PKT : boolean := false;
		C_MAC_CMP_BASEADDR : std_logic_vector := "00000000000000000000000000000000";
		C_MAC_CMP_HIGHADDR : std_logic_vector := "00000000000000000000111111111111";
		C_MAC_CMP_NUM_MASTERS : integer := 1;
		C_MAC_CMP_PLB_AWIDTH : integer := 32;
		C_MAC_CMP_PLB_DWIDTH : integer := 32;
		C_MAC_CMP_PLB_MID_WIDTH : integer := 1;
		C_MAC_CMP_PLB_P2P : integer := 0;
		C_MAC_CMP_PLB_NUM_MASTERS : integer := 1;
		C_MAC_CMP_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_CMP_PLB_SUPPORT_BURSTS : integer := 0;
		C_MAC_PKT_BASEADDR : std_logic_vector := "00000000000000000000000000000000";
		C_MAC_PKT_HIGHADDR : std_logic_vector := "00000000000011111111111111111111";
		C_MAC_PKT_NUM_MASTERS : integer := 1;
		C_MAC_PKT_PLB_AWIDTH : integer := 32;
		C_MAC_PKT_PLB_DWIDTH : integer := 32;
		C_MAC_PKT_PLB_MID_WIDTH : integer := 1;
		C_MAC_PKT_PLB_P2P : integer := 0;
		C_MAC_PKT_PLB_NUM_MASTERS : integer := 1;
		C_MAC_PKT_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_PKT_PLB_SUPPORT_BURSTS : integer := 0;
		C_MAC_DMA_PLB_AWIDTH : integer := 32;
		C_MAC_DMA_PLB_DWIDTH : integer := 32;
		C_MAC_DMA_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_REG_BASEADDR : std_logic_vector := "00000000000000000000000000000000";
		C_MAC_REG_HIGHADDR : std_logic_vector := "00000000000000001111111111111111";
		C_MAC_REG_NUM_MASTERS : integer := 1;
		C_MAC_REG_PLB_AWIDTH : integer := 32;
		C_MAC_REG_PLB_DWIDTH : integer := 32;
		C_MAC_REG_PLB_MID_WIDTH : integer := 1;
		C_MAC_REG_PLB_P2P : integer := 0;
		C_MAC_REG_PLB_NUM_MASTERS : integer := 1;
		C_MAC_REG_PLB_NATIVE_DWIDTH : integer := 32;
		C_MAC_REG_PLB_SUPPORT_BURSTS : integer := 0 );
	port(
		MAC_CMP_Clk : in STD_LOGIC;
		MAC_CMP_PAValid : in STD_LOGIC;
		MAC_CMP_RNW : in STD_LOGIC;
		MAC_CMP_Rst : in STD_LOGIC;
		MAC_CMP_SAValid : in STD_LOGIC;
		MAC_CMP_abort : in STD_LOGIC;
		MAC_CMP_busLock : in STD_LOGIC;
		MAC_CMP_lockErr : in STD_LOGIC;
		MAC_CMP_rdBurst : in STD_LOGIC;
		MAC_CMP_rdPendReq : in STD_LOGIC;
		MAC_CMP_rdPrim : in STD_LOGIC;
		MAC_CMP_wrBurst : in STD_LOGIC;
		MAC_CMP_wrPendReq : in STD_LOGIC;
		MAC_CMP_wrPrim : in STD_LOGIC;
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
		clk100 : in STD_LOGIC;
		pap_cs : in STD_LOGIC;
		pap_cs_n : in STD_LOGIC;
		pap_rd : in STD_LOGIC;
		pap_rd_n : in STD_LOGIC;
		pap_wr : in STD_LOGIC;
		pap_wr_n : in STD_LOGIC;
		phy0_SMIDat_I : in std_logic;
		phy1_SMIDat_I : in std_logic;
		phy0_SMIDat_O : out std_logic;
		phy1_SMIDat_O : out std_logic;
		phy0_SMIDat_T : out std_logic;
		phy1_SMIDat_T : out std_logic;
		phy0_RxDv : in STD_LOGIC;
		phy0_RxErr : in STD_LOGIC;
		phy0_link : in STD_LOGIC;
		phy1_RxDv : in STD_LOGIC;
		phy1_RxErr : in STD_LOGIC;
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
		MAC_CMP_ABus : in STD_LOGIC_VECTOR(0 to 31);
		MAC_CMP_BE : in STD_LOGIC_VECTOR(0 to (C_MAC_CMP_PLB_DWIDTH/8)-1);
		MAC_CMP_MSize : in STD_LOGIC_VECTOR(0 to 1);
		MAC_CMP_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
		MAC_CMP_UABus : in STD_LOGIC_VECTOR(0 to 31);
		MAC_CMP_masterID : in STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_MID_WIDTH-1);
		MAC_CMP_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
		MAC_CMP_reqPri : in STD_LOGIC_VECTOR(0 to 1);
		MAC_CMP_size : in STD_LOGIC_VECTOR(0 to 3);
		MAC_CMP_type : in STD_LOGIC_VECTOR(0 to 2);
		MAC_CMP_wrDBus : in STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_DWIDTH-1);
		MAC_CMP_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
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
		MAC_REG_BE : in STD_LOGIC_VECTOR(0 to (C_MAC_REG_PLB_DWIDTH/8)-1);
		MAC_REG_MSize : in STD_LOGIC_VECTOR(0 to 1);
		MAC_REG_TAttribute : in STD_LOGIC_VECTOR(0 to 15);
		MAC_REG_UABus : in STD_LOGIC_VECTOR(0 to 31);
		MAC_REG_masterID : in STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_MID_WIDTH-1);
		MAC_REG_rdPendPri : in STD_LOGIC_VECTOR(0 to 1);
		MAC_REG_reqPri : in STD_LOGIC_VECTOR(0 to 1);
		MAC_REG_size : in STD_LOGIC_VECTOR(0 to 3);
		MAC_REG_type : in STD_LOGIC_VECTOR(0 to 2);
		MAC_REG_wrDBus : in STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_DWIDTH-1);
		MAC_REG_wrPendPri : in STD_LOGIC_VECTOR(0 to 1);
		pap_addr : in STD_LOGIC_VECTOR(15 downto 0);
		pap_be : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
		pap_be_n : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
		phy0_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
		phy1_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
		phyMii0_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
		phyMii1_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
		pio_pconfig : in STD_LOGIC_VECTOR(3 downto 0);
		pio_portInLatch : in STD_LOGIC_VECTOR(3 downto 0);
		MAC_CMP_addrAck : out STD_LOGIC;
		MAC_CMP_rdBTerm : out STD_LOGIC;
		MAC_CMP_rdComp : out STD_LOGIC;
		MAC_CMP_rdDAck : out STD_LOGIC;
		MAC_CMP_rearbitrate : out STD_LOGIC;
		MAC_CMP_wait : out STD_LOGIC;
		MAC_CMP_wrBTerm : out STD_LOGIC;
		MAC_CMP_wrComp : out STD_LOGIC;
		MAC_CMP_wrDAck : out STD_LOGIC;
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
		ap_asyncIrq : out STD_LOGIC;
		ap_asyncIrq_n : out STD_LOGIC;
		ap_irq : out STD_LOGIC;
		ap_irq_n : out STD_LOGIC;
		led_error : out STD_LOGIC;
		led_status : out STD_LOGIC;
		mac_irq : out STD_LOGIC;
		pap_ack : out STD_LOGIC;
		pap_ack_n : out STD_LOGIC;
		phy0_Rst_n : out STD_LOGIC;
		phy0_SMIClk : out STD_LOGIC;
		phy0_TxEn : out STD_LOGIC;
		phy1_Rst_n : out STD_LOGIC;
		phy1_SMIClk : out STD_LOGIC;
		phy1_TxEn : out STD_LOGIC;
		phyMii0_TxEn : out STD_LOGIC;
		phyMii0_TxEr : out STD_LOGIC;
		phyMii1_TxEn : out STD_LOGIC;
		phyMii1_TxEr : out STD_LOGIC;
		pio_operational : out STD_LOGIC;
		spi_miso : out STD_LOGIC;
		tcp_irq : out STD_LOGIC;
		MAC_CMP_MBusy : out STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
		MAC_CMP_MIRQ : out STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
		MAC_CMP_MRdErr : out STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
		MAC_CMP_MWrErr : out STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
		MAC_CMP_SSize : out STD_LOGIC_VECTOR(0 to 1);
		MAC_CMP_rdDBus : out STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_DWIDTH-1);
		MAC_CMP_rdWdAddr : out STD_LOGIC_VECTOR(0 to 3);
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
		led_gpo : out STD_LOGIC_VECTOR(7 downto 0);
		led_opt : out STD_LOGIC_VECTOR(1 downto 0);
		led_phyAct : out STD_LOGIC_VECTOR(1 downto 0);
		led_phyLink : out STD_LOGIC_VECTOR(1 downto 0);
		phy0_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
		phy1_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
		phyMii0_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
		phyMii1_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
		pio_portOutValid : out STD_LOGIC_VECTOR(3 downto 0);
		test_port : out STD_LOGIC_VECTOR(255 downto 0);
		pap_data : inout STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
		pap_gpio : inout STD_LOGIC_VECTOR(1 downto 0);
		pio_portio : inout STD_LOGIC_VECTOR(31 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal MAC_CMP_Clk : STD_LOGIC;
	signal MAC_CMP_PAValid : STD_LOGIC;
	signal MAC_CMP_RNW : STD_LOGIC;
	signal MAC_CMP_Rst : STD_LOGIC;
	signal MAC_CMP_SAValid : STD_LOGIC;
	signal MAC_CMP_abort : STD_LOGIC;
	signal MAC_CMP_busLock : STD_LOGIC;
	signal MAC_CMP_lockErr : STD_LOGIC;
	signal MAC_CMP_rdBurst : STD_LOGIC;
	signal MAC_CMP_rdPendReq : STD_LOGIC;
	signal MAC_CMP_rdPrim : STD_LOGIC;
	signal MAC_CMP_wrBurst : STD_LOGIC;
	signal MAC_CMP_wrPendReq : STD_LOGIC;
	signal MAC_CMP_wrPrim : STD_LOGIC;
	signal MAC_DMA_Clk : STD_LOGIC;
	signal MAC_DMA_MAddrAck : STD_LOGIC;
	signal MAC_DMA_MBusy : STD_LOGIC;
	signal MAC_DMA_MIRQ : STD_LOGIC;
	signal MAC_DMA_MRdBTerm : STD_LOGIC;
	signal MAC_DMA_MRdDAck : STD_LOGIC;
	signal MAC_DMA_MRdErr : STD_LOGIC;
	signal MAC_DMA_MRearbitrate : STD_LOGIC;
	signal MAC_DMA_MTimeout : STD_LOGIC;
	signal MAC_DMA_MWrBTerm : STD_LOGIC;
	signal MAC_DMA_MWrDAck : STD_LOGIC;
	signal MAC_DMA_MWrErr : STD_LOGIC;
	signal MAC_DMA_Rst : STD_LOGIC;
	signal MAC_PKT_Clk : STD_LOGIC;
	signal MAC_PKT_PAValid : STD_LOGIC;
	signal MAC_PKT_RNW : STD_LOGIC;
	signal MAC_PKT_Rst : STD_LOGIC;
	signal MAC_PKT_SAValid : STD_LOGIC;
	signal MAC_PKT_abort : STD_LOGIC;
	signal MAC_PKT_busLock : STD_LOGIC;
	signal MAC_PKT_lockErr : STD_LOGIC;
	signal MAC_PKT_rdBurst : STD_LOGIC;
	signal MAC_PKT_rdPendReq : STD_LOGIC;
	signal MAC_PKT_rdPrim : STD_LOGIC;
	signal MAC_PKT_wrBurst : STD_LOGIC;
	signal MAC_PKT_wrPendReq : STD_LOGIC;
	signal MAC_PKT_wrPrim : STD_LOGIC;
	signal MAC_REG_Clk : STD_LOGIC;
	signal MAC_REG_PAValid : STD_LOGIC;
	signal MAC_REG_RNW : STD_LOGIC;
	signal MAC_REG_Rst : STD_LOGIC;
	signal MAC_REG_SAValid : STD_LOGIC;
	signal MAC_REG_abort : STD_LOGIC;
	signal MAC_REG_busLock : STD_LOGIC;
	signal MAC_REG_lockErr : STD_LOGIC;
	signal MAC_REG_rdBurst : STD_LOGIC;
	signal MAC_REG_rdPendReq : STD_LOGIC;
	signal MAC_REG_rdPrim : STD_LOGIC;
	signal MAC_REG_wrBurst : STD_LOGIC;
	signal MAC_REG_wrPendReq : STD_LOGIC;
	signal MAC_REG_wrPrim : STD_LOGIC;
	signal clk100 : STD_LOGIC;
	signal pap_cs : STD_LOGIC;
	signal pap_cs_n : STD_LOGIC;
	signal pap_rd : STD_LOGIC;
	signal pap_rd_n : STD_LOGIC;
	signal pap_wr : STD_LOGIC;
	signal pap_wr_n : STD_LOGIC;
	signal phy0_RxDv : STD_LOGIC;
	signal phy0_RxErr : STD_LOGIC;
	signal phy0_link : STD_LOGIC;
	signal phy1_RxDv : STD_LOGIC;
	signal phy1_RxErr : STD_LOGIC;
	signal phy1_link : STD_LOGIC;
	signal phyMii0_RxClk : STD_LOGIC;
	signal phyMii0_RxDv : STD_LOGIC;
	signal phyMii0_RxEr : STD_LOGIC;
	signal phyMii0_TxClk : STD_LOGIC;
	signal phyMii1_RxClk : STD_LOGIC;
	signal phyMii1_RxDv : STD_LOGIC;
	signal phyMii1_RxEr : STD_LOGIC;
	signal phyMii1_TxClk : STD_LOGIC;
	signal spi_clk : STD_LOGIC;
	signal spi_mosi : STD_LOGIC;
	signal spi_sel_n : STD_LOGIC;
	signal MAC_CMP_ABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_CMP_BE : STD_LOGIC_VECTOR(0 to (C_MAC_CMP_PLB_DWIDTH/8)-1);
	signal MAC_CMP_MSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_CMP_TAttribute : STD_LOGIC_VECTOR(0 to 15);
	signal MAC_CMP_UABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_CMP_masterID : STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_MID_WIDTH-1);
	signal MAC_CMP_rdPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_CMP_reqPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_CMP_size : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_CMP_type : STD_LOGIC_VECTOR(0 to 2);
	signal MAC_CMP_wrDBus : STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_DWIDTH-1);
	signal MAC_CMP_wrPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_DMA_MRdDBus : STD_LOGIC_VECTOR(0 to C_MAC_DMA_PLB_DWIDTH-1);
	signal MAC_DMA_MRdWdAddr : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_DMA_MSSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_PKT_ABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_PKT_BE : STD_LOGIC_VECTOR(0 to (C_MAC_PKT_PLB_DWIDTH/8)-1);
	signal MAC_PKT_MSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_PKT_TAttribute : STD_LOGIC_VECTOR(0 to 15);
	signal MAC_PKT_UABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_PKT_masterID : STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_MID_WIDTH-1);
	signal MAC_PKT_rdPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_PKT_reqPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_PKT_size : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_PKT_type : STD_LOGIC_VECTOR(0 to 2);
	signal MAC_PKT_wrDBus : STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_DWIDTH-1);
	signal MAC_PKT_wrPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_REG_ABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_REG_BE : STD_LOGIC_VECTOR(0 to (C_MAC_REG_PLB_DWIDTH/8)-1);
	signal MAC_REG_MSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_REG_TAttribute : STD_LOGIC_VECTOR(0 to 15);
	signal MAC_REG_UABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_REG_masterID : STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_MID_WIDTH-1);
	signal MAC_REG_rdPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_REG_reqPri : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_REG_size : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_REG_type : STD_LOGIC_VECTOR(0 to 2);
	signal MAC_REG_wrDBus : STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_DWIDTH-1);
	signal MAC_REG_wrPendPri : STD_LOGIC_VECTOR(0 to 1);
	signal pap_addr : STD_LOGIC_VECTOR(15 downto 0);
	signal pap_be : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
	signal pap_be_n : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
	signal phy0_RxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy1_RxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phyMii0_RxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii1_RxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_pconfig : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_portInLatch : STD_LOGIC_VECTOR(3 downto 0);
	signal phy0_SMIDat : STD_LOGIC;
	signal phy1_SMIDat : STD_LOGIC;
	signal pap_data : STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
	signal pap_gpio : STD_LOGIC_VECTOR(1 downto 0);
	signal pio_portio : STD_LOGIC_VECTOR(31 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal MAC_CMP_addrAck : STD_LOGIC;
	signal MAC_CMP_rdBTerm : STD_LOGIC;
	signal MAC_CMP_rdComp : STD_LOGIC;
	signal MAC_CMP_rdDAck : STD_LOGIC;
	signal MAC_CMP_rearbitrate : STD_LOGIC;
	signal MAC_CMP_wait : STD_LOGIC;
	signal MAC_CMP_wrBTerm : STD_LOGIC;
	signal MAC_CMP_wrComp : STD_LOGIC;
	signal MAC_CMP_wrDAck : STD_LOGIC;
	signal MAC_DMA_RNW : STD_LOGIC;
	signal MAC_DMA_abort : STD_LOGIC;
	signal MAC_DMA_busLock : STD_LOGIC;
	signal MAC_DMA_error : STD_LOGIC;
	signal MAC_DMA_lockErr : STD_LOGIC;
	signal MAC_DMA_rdBurst : STD_LOGIC;
	signal MAC_DMA_request : STD_LOGIC;
	signal MAC_DMA_wrBurst : STD_LOGIC;
	signal MAC_PKT_addrAck : STD_LOGIC;
	signal MAC_PKT_rdBTerm : STD_LOGIC;
	signal MAC_PKT_rdComp : STD_LOGIC;
	signal MAC_PKT_rdDAck : STD_LOGIC;
	signal MAC_PKT_rearbitrate : STD_LOGIC;
	signal MAC_PKT_wait : STD_LOGIC;
	signal MAC_PKT_wrBTerm : STD_LOGIC;
	signal MAC_PKT_wrComp : STD_LOGIC;
	signal MAC_PKT_wrDAck : STD_LOGIC;
	signal MAC_REG_addrAck : STD_LOGIC;
	signal MAC_REG_rdBTerm : STD_LOGIC;
	signal MAC_REG_rdComp : STD_LOGIC;
	signal MAC_REG_rdDAck : STD_LOGIC;
	signal MAC_REG_rearbitrate : STD_LOGIC;
	signal MAC_REG_wait : STD_LOGIC;
	signal MAC_REG_wrBTerm : STD_LOGIC;
	signal MAC_REG_wrComp : STD_LOGIC;
	signal MAC_REG_wrDAck : STD_LOGIC;
	signal ap_asyncIrq : STD_LOGIC;
	signal ap_asyncIrq_n : STD_LOGIC;
	signal ap_irq : STD_LOGIC;
	signal ap_irq_n : STD_LOGIC;
	signal led_error : STD_LOGIC;
	signal led_status : STD_LOGIC;
	signal mac_irq : STD_LOGIC;
	signal pap_ack : STD_LOGIC;
	signal pap_ack_n : STD_LOGIC;
	signal phy0_Rst_n : STD_LOGIC;
	signal phy0_SMIClk : STD_LOGIC;
	signal phy0_TxEn : STD_LOGIC;
	signal phy1_Rst_n : STD_LOGIC;
	signal phy1_SMIClk : STD_LOGIC;
	signal phy1_TxEn : STD_LOGIC;
	signal phyMii0_TxEn : STD_LOGIC;
	signal phyMii0_TxEr : STD_LOGIC;
	signal phyMii1_TxEn : STD_LOGIC;
	signal phyMii1_TxEr : STD_LOGIC;
	signal pio_operational : STD_LOGIC;
	signal spi_miso : STD_LOGIC;
	signal tcp_irq : STD_LOGIC;
	signal MAC_CMP_MBusy : STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
	signal MAC_CMP_MIRQ : STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
	signal MAC_CMP_MRdErr : STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
	signal MAC_CMP_MWrErr : STD_LOGIC_VECTOR(0 to C_MAC_CMP_NUM_MASTERS-1);
	signal MAC_CMP_SSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_CMP_rdDBus : STD_LOGIC_VECTOR(0 to C_MAC_CMP_PLB_DWIDTH-1);
	signal MAC_CMP_rdWdAddr : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_DMA_ABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_DMA_BE : STD_LOGIC_VECTOR(0 to (C_MAC_DMA_PLB_DWIDTH/8)-1);
	signal MAC_DMA_MSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_DMA_TAttribute : STD_LOGIC_VECTOR(0 to 15);
	signal MAC_DMA_UABus : STD_LOGIC_VECTOR(0 to 31);
	signal MAC_DMA_priority : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_DMA_size : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_DMA_type : STD_LOGIC_VECTOR(0 to 2);
	signal MAC_DMA_wrDBus : STD_LOGIC_VECTOR(0 to C_MAC_DMA_PLB_DWIDTH-1);
	signal MAC_PKT_MBusy : STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
	signal MAC_PKT_MIRQ : STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
	signal MAC_PKT_MRdErr : STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
	signal MAC_PKT_MWrErr : STD_LOGIC_VECTOR(0 to C_MAC_PKT_NUM_MASTERS-1);
	signal MAC_PKT_SSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_PKT_rdDBus : STD_LOGIC_VECTOR(0 to C_MAC_PKT_PLB_DWIDTH-1);
	signal MAC_PKT_rdWdAddr : STD_LOGIC_VECTOR(0 to 3);
	signal MAC_REG_MBusy : STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
	signal MAC_REG_MIRQ : STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
	signal MAC_REG_MRdErr : STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
	signal MAC_REG_MWrErr : STD_LOGIC_VECTOR(0 to C_MAC_REG_NUM_MASTERS-1);
	signal MAC_REG_SSize : STD_LOGIC_VECTOR(0 to 1);
	signal MAC_REG_rdDBus : STD_LOGIC_VECTOR(0 to C_MAC_REG_PLB_DWIDTH-1);
	signal MAC_REG_rdWdAddr : STD_LOGIC_VECTOR(0 to 3);
	signal led_gpo : STD_LOGIC_VECTOR(7 downto 0);
	signal led_opt : STD_LOGIC_VECTOR(1 downto 0);
	signal led_phyAct : STD_LOGIC_VECTOR(1 downto 0);
	signal led_phyLink : STD_LOGIC_VECTOR(1 downto 0);
	signal phy0_TxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy1_TxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phyMii0_TxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii1_TxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_portOutValid : STD_LOGIC_VECTOR(3 downto 0);
	signal test_port : STD_LOGIC_VECTOR(255 downto 0);
	
	signal phy0_SMIDat_I :  std_logic;
	signal phy1_SMIDat_I :  std_logic;
	signal phy0_SMIDat_O :  std_logic;
	signal phy1_SMIDat_O :  std_logic;
	signal phy0_SMIDat_T :  std_logic;
	signal phy1_SMIDat_T :  std_logic;

	-- Add your code here ...
	signal clk50, rst : std_logic;
	
	constant testReg : string := "REG";
	constant testCmp : string := "CMP";
	constant testPkt : string := "PKT";
	constant doTest : string := testPkt;

begin

	-- Unit Under Test port map
	UUT : plb_powerlink
		generic map (
			papDataWidth_g => papDataWidth_g,
			C_MAC_DMA_BURST_SIZE => C_MAC_DMA_BURST_SIZE,
			C_MAC_DMA_FIFO_SIZE => C_MAC_DMA_FIFO_SIZE,
			C_USE_RMII => C_USE_RMII,
			C_TX_INT_PKT => C_TX_INT_PKT,
			C_RX_INT_PKT => C_RX_INT_PKT,
			C_MAC_CMP_BASEADDR => C_MAC_CMP_BASEADDR,
			C_MAC_CMP_HIGHADDR => C_MAC_CMP_HIGHADDR,
			C_MAC_CMP_NUM_MASTERS => C_MAC_CMP_NUM_MASTERS,
			C_MAC_CMP_PLB_AWIDTH => C_MAC_CMP_PLB_AWIDTH,
			C_MAC_CMP_PLB_DWIDTH => C_MAC_CMP_PLB_DWIDTH,
			C_MAC_CMP_PLB_MID_WIDTH => C_MAC_CMP_PLB_MID_WIDTH,
			C_MAC_CMP_PLB_P2P => C_MAC_CMP_PLB_P2P,
			C_MAC_CMP_PLB_NUM_MASTERS => C_MAC_CMP_PLB_NUM_MASTERS,
			C_MAC_CMP_PLB_NATIVE_DWIDTH => C_MAC_CMP_PLB_NATIVE_DWIDTH,
			C_MAC_CMP_PLB_SUPPORT_BURSTS => C_MAC_CMP_PLB_SUPPORT_BURSTS,
			C_MAC_PKT_BASEADDR => C_MAC_PKT_BASEADDR,
			C_MAC_PKT_HIGHADDR => C_MAC_PKT_HIGHADDR,
			C_MAC_PKT_NUM_MASTERS => C_MAC_PKT_NUM_MASTERS,
			C_MAC_PKT_PLB_AWIDTH => C_MAC_PKT_PLB_AWIDTH,
			C_MAC_PKT_PLB_DWIDTH => C_MAC_PKT_PLB_DWIDTH,
			C_MAC_PKT_PLB_MID_WIDTH => C_MAC_PKT_PLB_MID_WIDTH,
			C_MAC_PKT_PLB_P2P => C_MAC_PKT_PLB_P2P,
			C_MAC_PKT_PLB_NUM_MASTERS => C_MAC_PKT_PLB_NUM_MASTERS,
			C_MAC_PKT_PLB_NATIVE_DWIDTH => C_MAC_PKT_PLB_NATIVE_DWIDTH,
			C_MAC_PKT_PLB_SUPPORT_BURSTS => C_MAC_PKT_PLB_SUPPORT_BURSTS,
			C_MAC_DMA_PLB_AWIDTH => C_MAC_DMA_PLB_AWIDTH,
			C_MAC_DMA_PLB_DWIDTH => C_MAC_DMA_PLB_DWIDTH,
			C_MAC_DMA_PLB_NATIVE_DWIDTH => C_MAC_DMA_PLB_NATIVE_DWIDTH,
			C_MAC_REG_BASEADDR => C_MAC_REG_BASEADDR,
			C_MAC_REG_HIGHADDR => C_MAC_REG_HIGHADDR,
			C_MAC_REG_NUM_MASTERS => C_MAC_REG_NUM_MASTERS,
			C_MAC_REG_PLB_AWIDTH => C_MAC_REG_PLB_AWIDTH,
			C_MAC_REG_PLB_DWIDTH => C_MAC_REG_PLB_DWIDTH,
			C_MAC_REG_PLB_MID_WIDTH => C_MAC_REG_PLB_MID_WIDTH,
			C_MAC_REG_PLB_P2P => C_MAC_REG_PLB_P2P,
			C_MAC_REG_PLB_NUM_MASTERS => C_MAC_REG_PLB_NUM_MASTERS,
			C_MAC_REG_PLB_NATIVE_DWIDTH => C_MAC_REG_PLB_NATIVE_DWIDTH,
			C_MAC_REG_PLB_SUPPORT_BURSTS => C_MAC_REG_PLB_SUPPORT_BURSTS
		)

		port map (
			phy0_SMIDat_I => phy0_SMIDat_I, 
			phy1_SMIDat_I => phy1_SMIDat_I, 
			phy0_SMIDat_O => phy0_SMIDat_O, 
			phy1_SMIDat_O => phy1_SMIDat_O, 
			phy0_SMIDat_T => phy0_SMIDat_T, 
			phy1_SMIDat_T => phy1_SMIDat_T, 
			MAC_CMP_Clk => MAC_CMP_Clk,
			MAC_CMP_PAValid => MAC_CMP_PAValid,
			MAC_CMP_RNW => MAC_CMP_RNW,
			MAC_CMP_Rst => MAC_CMP_Rst,
			MAC_CMP_SAValid => MAC_CMP_SAValid,
			MAC_CMP_abort => MAC_CMP_abort,
			MAC_CMP_busLock => MAC_CMP_busLock,
			MAC_CMP_lockErr => MAC_CMP_lockErr,
			MAC_CMP_rdBurst => MAC_CMP_rdBurst,
			MAC_CMP_rdPendReq => MAC_CMP_rdPendReq,
			MAC_CMP_rdPrim => MAC_CMP_rdPrim,
			MAC_CMP_wrBurst => MAC_CMP_wrBurst,
			MAC_CMP_wrPendReq => MAC_CMP_wrPendReq,
			MAC_CMP_wrPrim => MAC_CMP_wrPrim,
			MAC_DMA_Clk => MAC_DMA_Clk,
			MAC_DMA_MAddrAck => MAC_DMA_MAddrAck,
			MAC_DMA_MBusy => MAC_DMA_MBusy,
			MAC_DMA_MIRQ => MAC_DMA_MIRQ,
			MAC_DMA_MRdBTerm => MAC_DMA_MRdBTerm,
			MAC_DMA_MRdDAck => MAC_DMA_MRdDAck,
			MAC_DMA_MRdErr => MAC_DMA_MRdErr,
			MAC_DMA_MRearbitrate => MAC_DMA_MRearbitrate,
			MAC_DMA_MTimeout => MAC_DMA_MTimeout,
			MAC_DMA_MWrBTerm => MAC_DMA_MWrBTerm,
			MAC_DMA_MWrDAck => MAC_DMA_MWrDAck,
			MAC_DMA_MWrErr => MAC_DMA_MWrErr,
			MAC_DMA_Rst => MAC_DMA_Rst,
			MAC_PKT_Clk => MAC_PKT_Clk,
			MAC_PKT_PAValid => MAC_PKT_PAValid,
			MAC_PKT_RNW => MAC_PKT_RNW,
			MAC_PKT_Rst => MAC_PKT_Rst,
			MAC_PKT_SAValid => MAC_PKT_SAValid,
			MAC_PKT_abort => MAC_PKT_abort,
			MAC_PKT_busLock => MAC_PKT_busLock,
			MAC_PKT_lockErr => MAC_PKT_lockErr,
			MAC_PKT_rdBurst => MAC_PKT_rdBurst,
			MAC_PKT_rdPendReq => MAC_PKT_rdPendReq,
			MAC_PKT_rdPrim => MAC_PKT_rdPrim,
			MAC_PKT_wrBurst => MAC_PKT_wrBurst,
			MAC_PKT_wrPendReq => MAC_PKT_wrPendReq,
			MAC_PKT_wrPrim => MAC_PKT_wrPrim,
			MAC_REG_Clk => MAC_REG_Clk,
			MAC_REG_PAValid => MAC_REG_PAValid,
			MAC_REG_RNW => MAC_REG_RNW,
			MAC_REG_Rst => MAC_REG_Rst,
			MAC_REG_SAValid => MAC_REG_SAValid,
			MAC_REG_abort => MAC_REG_abort,
			MAC_REG_busLock => MAC_REG_busLock,
			MAC_REG_lockErr => MAC_REG_lockErr,
			MAC_REG_rdBurst => MAC_REG_rdBurst,
			MAC_REG_rdPendReq => MAC_REG_rdPendReq,
			MAC_REG_rdPrim => MAC_REG_rdPrim,
			MAC_REG_wrBurst => MAC_REG_wrBurst,
			MAC_REG_wrPendReq => MAC_REG_wrPendReq,
			MAC_REG_wrPrim => MAC_REG_wrPrim,
			clk100 => clk100,
			pap_cs => pap_cs,
			pap_cs_n => pap_cs_n,
			pap_rd => pap_rd,
			pap_rd_n => pap_rd_n,
			pap_wr => pap_wr,
			pap_wr_n => pap_wr_n,
			phy0_RxDv => phy0_RxDv,
			phy0_RxErr => phy0_RxErr,
			phy0_link => phy0_link,
			phy1_RxDv => phy1_RxDv,
			phy1_RxErr => phy1_RxErr,
			phy1_link => phy1_link,
			phyMii0_RxClk => phyMii0_RxClk,
			phyMii0_RxDv => phyMii0_RxDv,
			phyMii0_RxEr => phyMii0_RxEr,
			phyMii0_TxClk => phyMii0_TxClk,
			phyMii1_RxClk => phyMii1_RxClk,
			phyMii1_RxDv => phyMii1_RxDv,
			phyMii1_RxEr => phyMii1_RxEr,
			phyMii1_TxClk => phyMii1_TxClk,
			spi_clk => spi_clk,
			spi_mosi => spi_mosi,
			spi_sel_n => spi_sel_n,
			MAC_CMP_ABus => MAC_CMP_ABus,
			MAC_CMP_BE => MAC_CMP_BE,
			MAC_CMP_MSize => MAC_CMP_MSize,
			MAC_CMP_TAttribute => MAC_CMP_TAttribute,
			MAC_CMP_UABus => MAC_CMP_UABus,
			MAC_CMP_masterID => MAC_CMP_masterID,
			MAC_CMP_rdPendPri => MAC_CMP_rdPendPri,
			MAC_CMP_reqPri => MAC_CMP_reqPri,
			MAC_CMP_size => MAC_CMP_size,
			MAC_CMP_type => MAC_CMP_type,
			MAC_CMP_wrDBus => MAC_CMP_wrDBus,
			MAC_CMP_wrPendPri => MAC_CMP_wrPendPri,
			MAC_DMA_MRdDBus => MAC_DMA_MRdDBus,
			MAC_DMA_MRdWdAddr => MAC_DMA_MRdWdAddr,
			MAC_DMA_MSSize => MAC_DMA_MSSize,
			MAC_PKT_ABus => MAC_PKT_ABus,
			MAC_PKT_BE => MAC_PKT_BE,
			MAC_PKT_MSize => MAC_PKT_MSize,
			MAC_PKT_TAttribute => MAC_PKT_TAttribute,
			MAC_PKT_UABus => MAC_PKT_UABus,
			MAC_PKT_masterID => MAC_PKT_masterID,
			MAC_PKT_rdPendPri => MAC_PKT_rdPendPri,
			MAC_PKT_reqPri => MAC_PKT_reqPri,
			MAC_PKT_size => MAC_PKT_size,
			MAC_PKT_type => MAC_PKT_type,
			MAC_PKT_wrDBus => MAC_PKT_wrDBus,
			MAC_PKT_wrPendPri => MAC_PKT_wrPendPri,
			MAC_REG_ABus => MAC_REG_ABus,
			MAC_REG_BE => MAC_REG_BE,
			MAC_REG_MSize => MAC_REG_MSize,
			MAC_REG_TAttribute => MAC_REG_TAttribute,
			MAC_REG_UABus => MAC_REG_UABus,
			MAC_REG_masterID => MAC_REG_masterID,
			MAC_REG_rdPendPri => MAC_REG_rdPendPri,
			MAC_REG_reqPri => MAC_REG_reqPri,
			MAC_REG_size => MAC_REG_size,
			MAC_REG_type => MAC_REG_type,
			MAC_REG_wrDBus => MAC_REG_wrDBus,
			MAC_REG_wrPendPri => MAC_REG_wrPendPri,
			pap_addr => pap_addr,
			pap_be => pap_be,
			pap_be_n => pap_be_n,
			phy0_RxDat => phy0_RxDat,
			phy1_RxDat => phy1_RxDat,
			phyMii0_RxDat => phyMii0_RxDat,
			phyMii1_RxDat => phyMii1_RxDat,
			pio_pconfig => pio_pconfig,
			pio_portInLatch => pio_portInLatch,
			MAC_CMP_addrAck => MAC_CMP_addrAck,
			MAC_CMP_rdBTerm => MAC_CMP_rdBTerm,
			MAC_CMP_rdComp => MAC_CMP_rdComp,
			MAC_CMP_rdDAck => MAC_CMP_rdDAck,
			MAC_CMP_rearbitrate => MAC_CMP_rearbitrate,
			MAC_CMP_wait => MAC_CMP_wait,
			MAC_CMP_wrBTerm => MAC_CMP_wrBTerm,
			MAC_CMP_wrComp => MAC_CMP_wrComp,
			MAC_CMP_wrDAck => MAC_CMP_wrDAck,
			MAC_DMA_RNW => MAC_DMA_RNW,
			MAC_DMA_abort => MAC_DMA_abort,
			MAC_DMA_busLock => MAC_DMA_busLock,
			MAC_DMA_error => MAC_DMA_error,
			MAC_DMA_lockErr => MAC_DMA_lockErr,
			MAC_DMA_rdBurst => MAC_DMA_rdBurst,
			MAC_DMA_request => MAC_DMA_request,
			MAC_DMA_wrBurst => MAC_DMA_wrBurst,
			MAC_PKT_addrAck => MAC_PKT_addrAck,
			MAC_PKT_rdBTerm => MAC_PKT_rdBTerm,
			MAC_PKT_rdComp => MAC_PKT_rdComp,
			MAC_PKT_rdDAck => MAC_PKT_rdDAck,
			MAC_PKT_rearbitrate => MAC_PKT_rearbitrate,
			MAC_PKT_wait => MAC_PKT_wait,
			MAC_PKT_wrBTerm => MAC_PKT_wrBTerm,
			MAC_PKT_wrComp => MAC_PKT_wrComp,
			MAC_PKT_wrDAck => MAC_PKT_wrDAck,
			MAC_REG_addrAck => MAC_REG_addrAck,
			MAC_REG_rdBTerm => MAC_REG_rdBTerm,
			MAC_REG_rdComp => MAC_REG_rdComp,
			MAC_REG_rdDAck => MAC_REG_rdDAck,
			MAC_REG_rearbitrate => MAC_REG_rearbitrate,
			MAC_REG_wait => MAC_REG_wait,
			MAC_REG_wrBTerm => MAC_REG_wrBTerm,
			MAC_REG_wrComp => MAC_REG_wrComp,
			MAC_REG_wrDAck => MAC_REG_wrDAck,
			ap_asyncIrq => ap_asyncIrq,
			ap_asyncIrq_n => ap_asyncIrq_n,
			ap_irq => ap_irq,
			ap_irq_n => ap_irq_n,
			led_error => led_error,
			led_status => led_status,
			mac_irq => mac_irq,
			pap_ack => pap_ack,
			pap_ack_n => pap_ack_n,
			phy0_Rst_n => phy0_Rst_n,
			phy0_SMIClk => phy0_SMIClk,
			phy0_TxEn => phy0_TxEn,
			phy1_Rst_n => phy1_Rst_n,
			phy1_SMIClk => phy1_SMIClk,
			phy1_TxEn => phy1_TxEn,
			phyMii0_TxEn => phyMii0_TxEn,
			phyMii0_TxEr => phyMii0_TxEr,
			phyMii1_TxEn => phyMii1_TxEn,
			phyMii1_TxEr => phyMii1_TxEr,
			pio_operational => pio_operational,
			spi_miso => spi_miso,
			tcp_irq => tcp_irq,
			MAC_CMP_MBusy => MAC_CMP_MBusy,
			MAC_CMP_MIRQ => MAC_CMP_MIRQ,
			MAC_CMP_MRdErr => MAC_CMP_MRdErr,
			MAC_CMP_MWrErr => MAC_CMP_MWrErr,
			MAC_CMP_SSize => MAC_CMP_SSize,
			MAC_CMP_rdDBus => MAC_CMP_rdDBus,
			MAC_CMP_rdWdAddr => MAC_CMP_rdWdAddr,
			MAC_DMA_ABus => MAC_DMA_ABus,
			MAC_DMA_BE => MAC_DMA_BE,
			MAC_DMA_MSize => MAC_DMA_MSize,
			MAC_DMA_TAttribute => MAC_DMA_TAttribute,
			MAC_DMA_UABus => MAC_DMA_UABus,
			MAC_DMA_priority => MAC_DMA_priority,
			MAC_DMA_size => MAC_DMA_size,
			MAC_DMA_type => MAC_DMA_type,
			MAC_DMA_wrDBus => MAC_DMA_wrDBus,
			MAC_PKT_MBusy => MAC_PKT_MBusy,
			MAC_PKT_MIRQ => MAC_PKT_MIRQ,
			MAC_PKT_MRdErr => MAC_PKT_MRdErr,
			MAC_PKT_MWrErr => MAC_PKT_MWrErr,
			MAC_PKT_SSize => MAC_PKT_SSize,
			MAC_PKT_rdDBus => MAC_PKT_rdDBus,
			MAC_PKT_rdWdAddr => MAC_PKT_rdWdAddr,
			MAC_REG_MBusy => MAC_REG_MBusy,
			MAC_REG_MIRQ => MAC_REG_MIRQ,
			MAC_REG_MRdErr => MAC_REG_MRdErr,
			MAC_REG_MWrErr => MAC_REG_MWrErr,
			MAC_REG_SSize => MAC_REG_SSize,
			MAC_REG_rdDBus => MAC_REG_rdDBus,
			MAC_REG_rdWdAddr => MAC_REG_rdWdAddr,
			led_gpo => led_gpo,
			led_opt => led_opt,
			led_phyAct => led_phyAct,
			led_phyLink => led_phyLink,
			phy0_TxDat => phy0_TxDat,
			phy1_TxDat => phy1_TxDat,
			phyMii0_TxDat => phyMii0_TxDat,
			phyMii1_TxDat => phyMii1_TxDat,
			pio_portOutValid => pio_portOutValid,
			test_port => test_port,
			pap_data => pap_data,
			pap_gpio => pap_gpio,
			pio_portio => pio_portio
		);

	-- Add your stimulus here ...
	process
	begin
		clk50 <= '0';
		wait for 10 ns;
		clk50 <= '1';
		wait for 10 ns;
	end process;
	
	process
	begin
		clk100 <= '0';
		wait for 5 ns;
		clk100 <= '1';
		wait for 5 ns;
	end process;
	
	process
	begin
		rst <= '1';
		wait for 100 ns;
		rst <= '0';
		wait;
	end process;

--signal MAC_DMA_Clk : STD_LOGIC;
--signal MAC_DMA_MAddrAck : STD_LOGIC;
--signal MAC_DMA_MBusy : STD_LOGIC;
--signal MAC_DMA_MIRQ : STD_LOGIC;
--signal MAC_DMA_MRdBTerm : STD_LOGIC;
--signal MAC_DMA_MRdDAck : STD_LOGIC;
--signal MAC_DMA_MRdErr : STD_LOGIC;
--signal MAC_DMA_MRearbitrate : STD_LOGIC;
--signal MAC_DMA_MTimeout : STD_LOGIC;
--signal MAC_DMA_MWrBTerm : STD_LOGIC;
--signal MAC_DMA_MWrDAck : STD_LOGIC;
--signal MAC_DMA_MWrErr : STD_LOGIC;
--signal MAC_DMA_Rst : STD_LOGIC;
--signal pap_cs : STD_LOGIC;
--signal pap_cs_n : STD_LOGIC;
--signal pap_rd : STD_LOGIC;
--signal pap_rd_n : STD_LOGIC;
--signal pap_wr : STD_LOGIC;
--signal pap_wr_n : STD_LOGIC;
--signal phy0_RxDv : STD_LOGIC;
--signal phy0_RxErr : STD_LOGIC;
--signal phy0_link : STD_LOGIC;
--signal phy1_RxDv : STD_LOGIC;
--signal phy1_RxErr : STD_LOGIC;
--signal phy1_link : STD_LOGIC;
--signal phyMii0_RxClk : STD_LOGIC;
--signal phyMii0_RxDv : STD_LOGIC;
--signal phyMii0_RxEr : STD_LOGIC;
--signal phyMii0_TxClk : STD_LOGIC;
--signal phyMii1_RxClk : STD_LOGIC;
--signal phyMii1_RxDv : STD_LOGIC;
--signal phyMii1_RxEr : STD_LOGIC;
--signal phyMii1_TxClk : STD_LOGIC;
--signal spi_clk : STD_LOGIC;
--signal spi_mosi : STD_LOGIC;
--signal spi_sel_n : STD_LOGIC;
--signal MAC_DMA_MRdDBus : STD_LOGIC_VECTOR(0 to C_MAC_DMA_PLB_DWIDTH-1);
--signal MAC_DMA_MRdWdAddr : STD_LOGIC_VECTOR(0 to 3);
--signal MAC_DMA_MSSize : STD_LOGIC_VECTOR(0 to 1);
--signal pap_addr : STD_LOGIC_VECTOR(15 downto 0);
--signal pap_be : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
--signal pap_be_n : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
--signal phy0_RxDat : STD_LOGIC_VECTOR(1 downto 0);
--signal phy1_RxDat : STD_LOGIC_VECTOR(1 downto 0);
--signal phyMii0_RxDat : STD_LOGIC_VECTOR(3 downto 0);
--signal phyMii1_RxDat : STD_LOGIC_VECTOR(3 downto 0);
--signal pio_pconfig : STD_LOGIC_VECTOR(3 downto 0);
--signal pio_portInLatch : STD_LOGIC_VECTOR(3 downto 0);
--signal phy0_SMIDat : STD_LOGIC;
--signal phy1_SMIDat : STD_LOGIC;
--signal pap_data : STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
--signal pap_gpio : STD_LOGIC_VECTOR(1 downto 0);
--signal pio_portio : STD_LOGIC_VECTOR(31 downto 0);

--MAC_DMA
	MAC_DMA_Clk <= clk50;
	MAC_DMA_Rst <= rst;

--MAC_PKT
	MAC_PKT_Clk <= clk50;
	MAC_PKT_Rst <= rst;
	
	macPktProc : process(MAC_PKT_Clk, MAC_PKT_Rst)
	variable i : integer;
	variable doInc : boolean;
	begin
		if MAC_PKT_Rst = '1' then
			i := 0; doInc := true;
			
			MAC_PKT_masterID <= (others => '0'); --(0 to C_MAC_PKT_PLB_MID_WIDTH-1);
			MAC_PKT_PAValid <= '0';
			MAC_PKT_ABus <= (others => '0'); --(0 to 31);
			MAC_PKT_size <= (others => '0'); --(0 to 3);
			MAC_PKT_type <= (others => '0'); --(0 to 2);
			MAC_PKT_BE <= (others => '0'); --(0 to (C_MAC_PKT_PLB_DWIDTH/8)-1);
			MAC_PKT_RNW <= '0';
			MAC_PKT_wrDBus <= (others => '0'); --(0 to C_MAC_PKT_PLB_DWIDTH-1);
			
			MAC_PKT_ABus <= x"00008000";
		elsif rising_edge(MAC_PKT_Clk) and doTest = testPkt then
			--default
			doInc := true;
			MAC_PKT_masterID <= (others => '0'); --(0 to C_MAC_PKT_PLB_MID_WIDTH-1);
			MAC_PKT_PAValid <= '0';
			--MAC_PKT_ABus <= (others => '0'); --(0 to 31);
			MAC_PKT_size <= (others => '0'); --(0 to 3);
			MAC_PKT_type <= (others => '0'); --(0 to 2);
			MAC_PKT_BE <= (others => '0'); --(0 to (C_MAC_PKT_PLB_DWIDTH/8)-1);
			MAC_PKT_RNW <= '0';
			--MAC_PKT_wrDBus <= (others => '0'); --(0 to C_MAC_PKT_PLB_DWIDTH-1);
			
			case i is
				--read
				when 60 to 109 =>
					doInc := false;
					if MAC_PKT_addrAck = '0' then
						--set/hold qualifiers
						MAC_PKT_masterID <= conv_std_logic_vector(1, MAC_PKT_masterID'length);
						MAC_PKT_PAValid <= '1';
						MAC_PKT_BE <= "1111";
						MAC_PKT_RNW <= '1';
					else
						--do nothing here
						MAC_PKT_ABus <= MAC_PKT_ABus + 4;
						doInc := true;
					end if;
				--write
				when 0 to 49 =>
					doInc := false;
					if MAC_PKT_addrAck = '0' then
						--set/hold qualifiers
						MAC_PKT_masterID <= conv_std_logic_vector(1, MAC_PKT_masterID'length);
						MAC_PKT_PAValid <= '1';
						MAC_PKT_BE <= "1111";
						MAC_PKT_RNW <= '0';
					else
						--do nothing here
					end if;
					if MAC_PKT_wrDack = '1' then
						MAC_PKT_wrDBus <= MAC_PKT_wrDBus + 1;
						MAC_PKT_ABus <= MAC_PKT_ABus + 4;
						doInc := true;
					end if;
				when 150 =>
					doInc := false;
					--i := 0;
				when others =>
					MAC_PKT_ABus <= x"00008000";
					doInc := true;
			end case;
			if doInc = true then
				i := i + 1;
			end if;
			
		end if;
	end process;

	--unused
	MAC_PKT_UABus <= (others => '0'); --(0 to 31);
	MAC_PKT_SAValid <= '0';
	MAC_PKT_rdPrim <= '0';
	MAC_PKT_wrPrim <= '0';
	MAC_PKT_abort <= '0';
	MAC_PKT_busLock <= '0';
	MAC_PKT_MSize <= (others => '0'); --(0 to 1);
	MAC_PKT_TAttribute <= (others => '0'); --(0 to 15);
	MAC_PKT_lockErr <= '0';
	MAC_PKT_wrBurst <= '0';
	MAC_PKT_rdBurst <= '0';
	MAC_PKT_wrPendReq <= '0';
	MAC_PKT_rdPendReq <= '0';
	MAC_PKT_rdPendPri <= (others => '0'); --(0 to 1);
	MAC_PKT_wrPendPri <= (others => '0'); --(0 to 1);
	MAC_PKT_reqPri <= (others => '0'); --(0 to 1);

--MAC_CMP
	MAC_CMP_Clk <= clk50;
	MAC_CMP_Rst <= rst;
	
	macCmpProc : process(MAC_CMP_Clk, MAC_CMP_Rst)
	variable i : integer;
	variable doInc, addrDone : boolean;
	begin
		if MAC_CMP_Rst = '1' then
			i := 0; doInc := true; addrDone := false;
			
			MAC_CMP_masterID <= (others => '0'); --(0 to C_MAC_CMP_PLB_MID_WIDTH-1);
			MAC_CMP_PAValid <= '0';
			MAC_CMP_ABus <= (others => '0'); --(0 to 31);
			MAC_CMP_size <= (others => '0'); --(0 to 3);
			MAC_CMP_type <= (others => '0'); --(0 to 2);
			MAC_CMP_BE <= (others => '0'); --(0 to (C_MAC_CMP_PLB_DWIDTH/8)-1);
			MAC_CMP_RNW <= '0';
			MAC_CMP_wrDBus <= (others => '0'); --(0 to C_MAC_CMP_PLB_DWIDTH-1);
			
			MAC_CMP_ABus <= x"00008000";
		elsif rising_edge(MAC_CMP_Clk) and doTest = testPkt then
			--default
			doInc := true;
			MAC_CMP_masterID <= (others => '0'); --(0 to C_MAC_CMP_PLB_MID_WIDTH-1);
			MAC_CMP_PAValid <= '0';
			MAC_CMP_ABus <= (others => '0'); --(0 to 31);
			MAC_CMP_size <= (others => '0'); --(0 to 3);
			MAC_CMP_type <= (others => '0'); --(0 to 2);
			MAC_CMP_BE <= (others => '0'); --(0 to (C_MAC_CMP_PLB_DWIDTH/8)-1);
			MAC_CMP_RNW <= '0';
			MAC_CMP_wrDBus <= (others => '0'); --(0 to C_MAC_CMP_PLB_DWIDTH-1);
			
			case i is
				--read
				when 3 =>
					doInc := false;
					if MAC_CMP_addrAck = '0' then
						--set/hold qualifiers
						MAC_CMP_masterID <= conv_std_logic_vector(1, MAC_CMP_masterID'length);
						MAC_CMP_PAValid <= '1';
						MAC_CMP_ABus <= x"00020000";
						MAC_CMP_BE <= "1111";
						MAC_CMP_RNW <= '1';
					else
						--do nothing here
						doInc := true;
					end if;
				--write
				when 1 =>
					doInc := false;
					if MAC_CMP_addrAck = '0' and addrDone = false then
						--set/hold qualifiers
						MAC_CMP_masterID <= conv_std_logic_vector(1, MAC_CMP_masterID'length);
						MAC_CMP_PAValid <= '1';
						MAC_CMP_ABus <= x"00020000";
						MAC_CMP_BE <= "1111";
						MAC_CMP_RNW <= '0';
					else
						--do nothing here
						addrDone := true;
					end if;
					if MAC_CMP_wrDack = '1' then
						doInc := true; addrDone := false;
					else
						MAC_CMP_wrDBus <= x"00000010";
					end if;
				--write
				when 2 =>
					doInc := false;
					if MAC_CMP_addrAck = '0' and addrDone = false then
						--set/hold qualifiers
						MAC_CMP_masterID <= conv_std_logic_vector(1, MAC_CMP_masterID'length);
						MAC_CMP_PAValid <= '1';
						MAC_CMP_ABus <= x"00020004";
						MAC_CMP_BE <= "1111";
						MAC_CMP_RNW <= '0';
					else
						--do nothing here
						addrDone := true;
					end if;
					if MAC_CMP_wrDack = '1' then
						doInc := true; addrDone := false;
					else
						MAC_CMP_wrDBus <= x"00000001";
					end if;
				when 150 =>
					doInc := false;
					--i := 0;
				when others =>
					doInc := true;
			end case;
			if doInc = true then
				i := i + 1;
			end if;
			
		end if;
	end process;

	--unused
	MAC_CMP_UABus <= (others => '0'); --(0 to 31);
	MAC_CMP_SAValid <= '0';
	MAC_CMP_rdPrim <= '0';
	MAC_CMP_wrPrim <= '0';
	MAC_CMP_abort <= '0';
	MAC_CMP_busLock <= '0';
	MAC_CMP_MSize <= (others => '0'); --(0 to 1);
	MAC_CMP_TAttribute <= (others => '0'); --(0 to 15);
	MAC_CMP_lockErr <= '0';
	MAC_CMP_wrBurst <= '0';
	MAC_CMP_rdBurst <= '0';
	MAC_CMP_wrPendReq <= '0';
	MAC_CMP_rdPendReq <= '0';
	MAC_CMP_rdPendPri <= (others => '0'); --(0 to 1);
	MAC_CMP_wrPendPri <= (others => '0'); --(0 to 1);
	MAC_CMP_reqPri <= (others => '0'); --(0 to 1);

--MAC_REG
	MAC_REG_Clk <= clk50;
	MAC_REG_Rst <= rst;

	macRegProc : process(MAC_REG_Clk, MAC_REG_Rst)
	variable i : integer;
	variable doInc : boolean;
	begin
		if MAC_REG_Rst = '1' then
			i := 0; doInc := true;
			
			MAC_REG_masterID <= (others => '0'); --(0 to C_MAC_REG_PLB_MID_WIDTH-1);
			MAC_REG_PAValid <= '0';
			MAC_REG_ABus <= (others => '0'); --(0 to 31);
			MAC_REG_size <= (others => '0'); --(0 to 3);
			MAC_REG_type <= (others => '0'); --(0 to 2);
			MAC_REG_BE <= (others => '0'); --(0 to (C_MAC_REG_PLB_DWIDTH/8)-1);
			MAC_REG_RNW <= '0';
			MAC_REG_wrDBus <= (others => '0'); --(0 to C_MAC_REG_PLB_DWIDTH-1);
		elsif rising_edge(MAC_REG_Clk) and doTest = testReg then
			--default
			doInc := true;
			MAC_REG_masterID <= (others => '0'); --(0 to C_MAC_REG_PLB_MID_WIDTH-1);
			MAC_REG_PAValid <= '0';
			MAC_REG_ABus <= (others => '0'); --(0 to 31);
			MAC_REG_size <= (others => '0'); --(0 to 3);
			MAC_REG_type <= (others => '0'); --(0 to 2);
			MAC_REG_BE <= (others => '0'); --(0 to (C_MAC_REG_PLB_DWIDTH/8)-1);
			MAC_REG_RNW <= '0';
			MAC_REG_wrDBus <= (others => '0'); --(0 to C_MAC_REG_PLB_DWIDTH-1);
			
			case i is
				--read
				when 1 =>
					if MAC_REG_addrAck = '0' then
						doInc := false;
						--set/hold qualifiers
						MAC_REG_masterID <= conv_std_logic_vector(1, MAC_REG_masterID'length);
						MAC_REG_PAValid <= '1';
						MAC_REG_ABus <= x"00011000"; --MII
						MAC_REG_BE <= "1100";
						MAC_REG_RNW <= '1';
					else
						--do nothing here
					end if;
				--write
				when 5 =>
					if MAC_REG_addrAck = '0' then
						doInc := false;
						--set/hold qualifiers
						MAC_REG_masterID <= conv_std_logic_vector(1, MAC_REG_masterID'length);
						MAC_REG_PAValid <= '1';
						MAC_REG_ABus <= x"00011004"; --MII
						MAC_REG_BE <= "1100";
						MAC_REG_RNW <= '0';
					else
						--do nothing here
					end if;
					if MAC_REG_wrDack = '0' then
						MAC_REG_wrDBus <= x"00800080";
					else
						doInc := true;
					end if;
				--write
				when 10 =>
					if MAC_REG_addrAck = '0' then
						doInc := false;
						--set/hold qualifiers
						MAC_REG_masterID <= conv_std_logic_vector(1, MAC_REG_masterID'length);
						MAC_REG_PAValid <= '1';
						MAC_REG_ABus <= x"00011000"; --MII
						MAC_REG_BE <= "0011";
						MAC_REG_RNW <= '0';
					else
						--do nothing here
					end if;
					if MAC_REG_wrDack = '0' then
						MAC_REG_wrDBus <= x"68046804";
					else
						doInc := true;
					end if;
				--write
				when 15 =>
					if MAC_REG_addrAck = '0' then
						doInc := false;
						--set/hold qualifiers
						MAC_REG_masterID <= conv_std_logic_vector(1, MAC_REG_masterID'length);
						MAC_REG_PAValid <= '1';
						MAC_REG_ABus <= x"00011000"; --MII
						MAC_REG_BE <= "1100";
						MAC_REG_RNW <= '0';
					else
						--do nothing here
					end if;
					if MAC_REG_wrDack = '0' then
						MAC_REG_wrDBus <= x"6A006A00";
					else
						doInc := true;
					end if;
				--read
				when 20 =>
					if MAC_REG_addrAck = '0' then
						doInc := false;
						--set/hold qualifiers
						MAC_REG_masterID <= conv_std_logic_vector(1, MAC_REG_masterID'length);
						MAC_REG_PAValid <= '1';
						MAC_REG_ABus <= x"00011000"; --MII
						MAC_REG_BE <= "1111";
						MAC_REG_RNW <= '1';
					else
						--do nothing here
					end if;
				when 25 =>
					doInc := false;
					--i := 0;
				when others =>
			end case;
			if doInc = true then
				i := i + 1;
			end if;
			
		end if;
	end process;

	--unused
	MAC_REG_UABus <= (others => '0'); --(0 to 31);
	MAC_REG_SAValid <= '0';
	MAC_REG_rdPrim <= '0';
	MAC_REG_wrPrim <= '0';
	MAC_REG_abort <= '0';
	MAC_REG_busLock <= '0';
	MAC_REG_MSize <= (others => '0'); --(0 to 1);
	MAC_REG_TAttribute <= (others => '0'); --(0 to 15);
	MAC_REG_lockErr <= '0';
	MAC_REG_wrBurst <= '0';
	MAC_REG_rdBurst <= '0';
	MAC_REG_wrPendReq <= '0';
	MAC_REG_rdPendReq <= '0';
	MAC_REG_rdPendPri <= (others => '0'); --(0 to 1);
	MAC_REG_wrPendPri <= (others => '0'); --(0 to 1);
	MAC_REG_reqPri <= (others => '0'); --(0 to 1);

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_plb_powerlink of plb_powerlink_tb is
	for TB_ARCHITECTURE
		for UUT : plb_powerlink
			use entity work.plb_powerlink(struct);
		end for;
	end for;
end TESTBENCH_FOR_plb_powerlink;

