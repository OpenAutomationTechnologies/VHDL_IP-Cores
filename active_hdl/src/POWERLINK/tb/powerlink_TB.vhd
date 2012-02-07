library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity powerlink_tb is
	-- Generic declarations of the tested unit
		generic(
		genOnePdiClkDomain_g : boolean := false;
		genPdi_g : boolean := true;
		genAvalonAp_g : boolean := true;
		genSimpleIO_g : boolean := false;
		genSpiAp_g : boolean := false;
		Simulate : boolean := false;
		iBufSize_g : integer := 1024;
		iBufSizeLOG2_g : integer := 10;
		useRmii_g : boolean := true;
		useIntPacketBuf_g : boolean := false;
		useRxIntPacketBuf_g : boolean := false;
		use2ndCmpTimer_g : boolean := true;
		use2ndPhy_g : boolean := true;
		useHwAcc_g : boolean := false;
		m_burstcount_width_g : integer := 5;
		m_tx_burst_size_g : integer := 16;
		m_rx_burst_size_g : integer := 1;
		m_tx_fifo_size_g : integer := 32;
		m_rx_fifo_size_g : integer := 16;
		iRpdos_g : integer := 3;
		iTpdos_g : integer := 1;
		genABuf1_g : boolean := true;
		genABuf2_g : boolean := true;
		genLedGadget_g : boolean := false;
		iTpdoBufSize_g : integer := 100;
		iRpdo0BufSize_g : integer := 100;
		iRpdo1BufSize_g : integer := 100;
		iRpdo2BufSize_g : integer := 100;
		iAsyBuf1Size_g : integer := 100;
		iAsyBuf2Size_g : integer := 100;
		iPdiRev_g : integer := 21930;
		papDataWidth_g : integer := 8;
		papLowAct_g : boolean := false;
		papBigEnd_g : boolean := false;
		spiCPOL_g : boolean := false;
		spiCPHA_g : boolean := false;
		spiBigEnd_g : boolean := false;
		pioValLen_g : integer := 50 );
end powerlink_tb;

architecture TB_ARCHITECTURE of powerlink_tb is
	-- Component declaration of the tested unit
	component powerlink
		generic(
		genOnePdiClkDomain_g : boolean := false;
		genPdi_g : boolean := true;
		genAvalonAp_g : boolean := true;
		genSimpleIO_g : boolean := false;
		genSpiAp_g : boolean := false;
		Simulate : boolean := false;
		iBufSize_g : integer := 1024;
		iBufSizeLOG2_g : integer := 10;
		useRmii_g : boolean := true;
		useIntPacketBuf_g : boolean := true;
		useRxIntPacketBuf_g : boolean := true;
		use2ndCmpTimer_g : boolean := true;
		use2ndPhy_g : boolean := true;
		useHwAcc_g : boolean := false;
		m_burstcount_width_g : integer := 4;
		m_tx_burst_size_g : integer := 16;
		m_rx_burst_size_g : integer := 16;
		m_tx_fifo_size_g : integer := 16;
		m_rx_fifo_size_g : integer := 16;
		iRpdos_g : integer := 3;
		iTpdos_g : integer := 1;
		genABuf1_g : boolean := true;
		genABuf2_g : boolean := true;
		genLedGadget_g : boolean := false;
		iTpdoBufSize_g : integer := 100;
		iRpdo0BufSize_g : integer := 100;
		iRpdo1BufSize_g : integer := 100;
		iRpdo2BufSize_g : integer := 100;
		iAsyBuf1Size_g : integer := 100;
		iAsyBuf2Size_g : integer := 100;
		iPdiRev_g : integer := 21930;
		papDataWidth_g : integer := 8;
		papLowAct_g : boolean := false;
		papBigEnd_g : boolean := false;
		spiCPOL_g : boolean := false;
		spiCPHA_g : boolean := false;
		spiBigEnd_g : boolean := false;
		pioValLen_g : integer := 50 );
	port(
		clk50 : in STD_LOGIC;
		rst : in std_logic;
		clkEth : in STD_LOGIC;
		m_clk : in STD_LOGIC;
		pkt_clk : in STD_LOGIC;
		clkPcp : in STD_LOGIC;
		clkAp : in STD_LOGIC;
		rstPcp : in STD_LOGIC;
		rstAp : in STD_LOGIC;
		mac_chipselect : in STD_LOGIC;
		mac_read : in STD_LOGIC;
		mac_write : in STD_LOGIC;
		mac_byteenable : in STD_LOGIC_VECTOR(1 downto 0);
		mac_address : in STD_LOGIC_VECTOR(11 downto 0);
		mac_writedata : in STD_LOGIC_VECTOR(15 downto 0);
		mac_readdata : out STD_LOGIC_VECTOR(15 downto 0);
		mac_waitrequest : out STD_LOGIC;
		mac_irq : out STD_LOGIC;
		tcp_chipselect : in STD_LOGIC;
		tcp_read : in STD_LOGIC;
		tcp_write : in STD_LOGIC;
		tcp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		tcp_address : in STD_LOGIC_VECTOR(1 downto 0);
		tcp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		tcp_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		tcp_waitrequest : out STD_LOGIC;
		tcp_irq : out STD_LOGIC;
		mbf_chipselect : in STD_LOGIC;
		mbf_read : in STD_LOGIC;
		mbf_write : in STD_LOGIC;
		mbf_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		mbf_address : in STD_LOGIC_VECTOR(ibufsizelog2_g-3 downto 0);
		mbf_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		mbf_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		mbf_waitrequest : out STD_LOGIC;
		m_read : out STD_LOGIC;
		m_write : out STD_LOGIC;
		m_byteenable : out STD_LOGIC_VECTOR(1 downto 0);
		m_address : out STD_LOGIC_VECTOR(29 downto 0);
		m_writedata : out STD_LOGIC_VECTOR(15 downto 0);
		m_readdata : in STD_LOGIC_VECTOR(15 downto 0);
		m_waitrequest : in STD_LOGIC;
		m_readdatavalid : in STD_LOGIC;
		m_burstcount : out STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
		pcp_chipselect : in STD_LOGIC;
		pcp_read : in STD_LOGIC;
		pcp_write : in STD_LOGIC;
		pcp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		pcp_address : in STD_LOGIC_VECTOR(12 downto 0);
		pcp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		pcp_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		ap_irq : out STD_LOGIC;
		ap_irq_n : out STD_LOGIC;
		ap_asyncIrq : out STD_LOGIC;
		ap_asyncIrq_n : out STD_LOGIC;
		ap_chipselect : in STD_LOGIC;
		ap_read : in STD_LOGIC;
		ap_write : in STD_LOGIC;
		ap_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		ap_address : in STD_LOGIC_VECTOR(12 downto 0);
		ap_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		ap_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		pap_cs : in STD_LOGIC;
		pap_rd : in STD_LOGIC;
		pap_wr : in STD_LOGIC;
		pap_be : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
		pap_cs_n : in STD_LOGIC;
		pap_rd_n : in STD_LOGIC;
		pap_wr_n : in STD_LOGIC;
		pap_be_n : in STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
		pap_addr : in STD_LOGIC_VECTOR(15 downto 0);
		pap_data : inout STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
		pap_ack : out STD_LOGIC;
		pap_ack_n : out STD_LOGIC;
		pap_gpio : inout STD_LOGIC_VECTOR(1 downto 0);
		spi_clk : in STD_LOGIC;
		spi_sel_n : in STD_LOGIC;
		spi_mosi : in STD_LOGIC;
		spi_miso : out STD_LOGIC;
		smp_address : in STD_LOGIC;
		smp_read : in STD_LOGIC;
		smp_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		smp_write : in STD_LOGIC;
		smp_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		smp_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		pio_pconfig : in STD_LOGIC_VECTOR(3 downto 0);
		pio_portInLatch : in STD_LOGIC_VECTOR(3 downto 0);
		pio_portOutValid : out STD_LOGIC_VECTOR(3 downto 0);
		pio_portio : inout STD_LOGIC_VECTOR(31 downto 0);
		pio_operational : out STD_LOGIC;
		phy0_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
		phy0_RxDv : in STD_LOGIC;
		phy0_RxErr : in STD_LOGIC;
		phy0_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
		phy0_TxEn : out STD_LOGIC;
		phy0_SMIClk : out STD_LOGIC;
		phy0_SMIDat : inout STD_LOGIC;
		phy0_Rst_n : out STD_LOGIC;
		phy0_link : in STD_LOGIC;
		phy1_RxDat : in STD_LOGIC_VECTOR(1 downto 0);
		phy1_RxDv : in STD_LOGIC;
		phy1_RxErr : in STD_LOGIC;
		phy1_TxDat : out STD_LOGIC_VECTOR(1 downto 0);
		phy1_TxEn : out STD_LOGIC;
		phy1_SMIClk : out STD_LOGIC;
		phy1_SMIDat : inout STD_LOGIC;
		phy1_Rst_n : out STD_LOGIC;
		phy1_link : in STD_LOGIC;
		phyMii0_RxClk : in STD_LOGIC;
		phyMii0_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
		phyMii0_RxDv : in STD_LOGIC;
		phyMii0_RxEr : in STD_LOGIC;
		phyMii0_TxClk : in STD_LOGIC;
		phyMii0_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
		phyMii0_TxEn : out STD_LOGIC;
		phyMii0_TxEr : out STD_LOGIC;
		phyMii1_RxClk : in STD_LOGIC;
		phyMii1_RxDat : in STD_LOGIC_VECTOR(3 downto 0);
		phyMii1_RxDv : in STD_LOGIC;
		phyMii1_RxEr : in STD_LOGIC;
		phyMii1_TxClk : in STD_LOGIC;
		phyMii1_TxDat : out STD_LOGIC_VECTOR(3 downto 0);
		phyMii1_TxEn : out STD_LOGIC;
		phyMii1_TxEr : out STD_LOGIC;
		led_error : out STD_LOGIC;
		led_status : out STD_LOGIC;
		led_phyLink : out STD_LOGIC_VECTOR(1 downto 0);
		led_phyAct : out STD_LOGIC_VECTOR(1 downto 0);
		led_opt : out STD_LOGIC_VECTOR(1 downto 0);
		led_gpo : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk50, rst : STD_LOGIC;
	signal clkEth : STD_LOGIC;
	signal m_clk : STD_LOGIC;
	signal pkt_clk : STD_LOGIC;
	signal clkPcp : STD_LOGIC;
	signal clkAp : STD_LOGIC;
	signal rstPcp : STD_LOGIC;
	signal rstAp : STD_LOGIC;
	signal mac_chipselect : STD_LOGIC;
	signal mac_read : STD_LOGIC;
	signal mac_write : STD_LOGIC;
	signal mac_byteenable : STD_LOGIC_VECTOR(1 downto 0);
	signal mac_address : STD_LOGIC_VECTOR(11 downto 0);
	signal mac_writedata : STD_LOGIC_VECTOR(15 downto 0);
	signal tcp_chipselect : STD_LOGIC;
	signal tcp_read : STD_LOGIC;
	signal tcp_write : STD_LOGIC;
	signal tcp_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal tcp_address : STD_LOGIC_VECTOR(1 downto 0);
	signal tcp_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal mbf_chipselect : STD_LOGIC;
	signal mbf_read : STD_LOGIC;
	signal mbf_write : STD_LOGIC;
	signal mbf_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal mbf_address : STD_LOGIC_VECTOR(ibufsizelog2_g-3 downto 0);
	signal mbf_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal m_readdata : STD_LOGIC_VECTOR(15 downto 0);
	signal m_waitrequest : STD_LOGIC;
	signal m_readdatavalid : STD_LOGIC;
	signal pcp_chipselect : STD_LOGIC;
	signal pcp_read : STD_LOGIC;
	signal pcp_write : STD_LOGIC;
	signal pcp_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal pcp_address : STD_LOGIC_VECTOR(12 downto 0);
	signal pcp_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal ap_chipselect : STD_LOGIC;
	signal ap_read : STD_LOGIC;
	signal ap_write : STD_LOGIC;
	signal ap_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal ap_address : STD_LOGIC_VECTOR(12 downto 0);
	signal ap_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal pap_cs : STD_LOGIC;
	signal pap_rd : STD_LOGIC;
	signal pap_wr : STD_LOGIC;
	signal pap_be : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
	signal pap_cs_n : STD_LOGIC;
	signal pap_rd_n : STD_LOGIC;
	signal pap_wr_n : STD_LOGIC;
	signal pap_be_n : STD_LOGIC_VECTOR(papDataWidth_g/8-1 downto 0);
	signal pap_addr : STD_LOGIC_VECTOR(15 downto 0);
	signal spi_clk : STD_LOGIC;
	signal spi_sel_n : STD_LOGIC;
	signal spi_mosi : STD_LOGIC;
	signal smp_address : STD_LOGIC;
	signal smp_read : STD_LOGIC;
	signal smp_write : STD_LOGIC;
	signal smp_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal smp_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_pconfig : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_portInLatch : STD_LOGIC_VECTOR(3 downto 0);
	signal phy0_RxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy0_RxDv : STD_LOGIC;
	signal phy0_RxErr : STD_LOGIC;
	signal phy0_link : STD_LOGIC;
	signal phy1_RxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy1_RxDv : STD_LOGIC;
	signal phy1_RxErr : STD_LOGIC;
	signal phy1_link : STD_LOGIC;
	signal phyMii0_RxClk : STD_LOGIC;
	signal phyMii0_RxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii0_RxDv : STD_LOGIC;
	signal phyMii0_RxEr : STD_LOGIC;
	signal phyMii0_TxClk : STD_LOGIC;
	signal phyMii1_RxClk : STD_LOGIC;
	signal phyMii1_RxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii1_RxDv : STD_LOGIC;
	signal phyMii1_RxEr : STD_LOGIC;
	signal phyMii1_TxClk : STD_LOGIC;
	signal pap_data : STD_LOGIC_VECTOR(papDataWidth_g-1 downto 0);
	signal pap_gpio : STD_LOGIC_VECTOR(1 downto 0);
	signal pio_portio : STD_LOGIC_VECTOR(31 downto 0);
	signal phy0_SMIDat : STD_LOGIC;
	signal phy1_SMIDat : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal mac_readdata : STD_LOGIC_VECTOR(15 downto 0);
	signal mac_waitrequest : STD_LOGIC;
	signal mac_irq : STD_LOGIC;
	signal tcp_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal tcp_waitrequest : STD_LOGIC;
	signal tcp_irq : STD_LOGIC;
	signal mbf_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal mbf_waitrequest : STD_LOGIC;
	signal m_read : STD_LOGIC;
	signal m_write : STD_LOGIC;
	signal m_byteenable : STD_LOGIC_VECTOR(1 downto 0);
	signal m_address : STD_LOGIC_VECTOR(29 downto 0);
	signal m_writedata : STD_LOGIC_VECTOR(15 downto 0);
	signal m_burstcount : STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
	signal pcp_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal ap_irq : STD_LOGIC;
	signal ap_irq_n : STD_LOGIC;
	signal ap_asyncIrq : STD_LOGIC;
	signal ap_asyncIrq_n : STD_LOGIC;
	signal ap_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal pap_ack : STD_LOGIC;
	signal pap_ack_n : STD_LOGIC;
	signal spi_miso : STD_LOGIC;
	signal smp_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal pio_portOutValid : STD_LOGIC_VECTOR(3 downto 0);
	signal pio_operational : STD_LOGIC;
	signal phy0_TxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy0_TxEn : STD_LOGIC;
	signal phy0_SMIClk : STD_LOGIC;
	signal phy0_Rst_n : STD_LOGIC;
	signal phy1_TxDat : STD_LOGIC_VECTOR(1 downto 0);
	signal phy1_TxEn : STD_LOGIC;
	signal phy1_SMIClk : STD_LOGIC;
	signal phy1_Rst_n : STD_LOGIC;
	signal phyMii0_TxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii0_TxEn : STD_LOGIC;
	signal phyMii0_TxEr : STD_LOGIC;
	signal phyMii1_TxDat : STD_LOGIC_VECTOR(3 downto 0);
	signal phyMii1_TxEn : STD_LOGIC;
	signal phyMii1_TxEr : STD_LOGIC;
	signal led_error : STD_LOGIC;
	signal led_status : STD_LOGIC;
	signal led_phyLink : STD_LOGIC_VECTOR(1 downto 0);
	signal led_phyAct : STD_LOGIC_VECTOR(1 downto 0);
	signal led_opt : STD_LOGIC_VECTOR(1 downto 0);
	signal led_gpo : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : powerlink
		generic map (
			genOnePdiClkDomain_g => genOnePdiClkDomain_g,
			genPdi_g => genPdi_g,
			genAvalonAp_g => genAvalonAp_g,
			genSimpleIO_g => genSimpleIO_g,
			genSpiAp_g => genSpiAp_g,
			Simulate => Simulate,
			iBufSize_g => iBufSize_g,
			iBufSizeLOG2_g => iBufSizeLOG2_g,
			useRmii_g => useRmii_g,
			useIntPacketBuf_g => useIntPacketBuf_g,
			useRxIntPacketBuf_g => useRxIntPacketBuf_g,
			use2ndCmpTimer_g => use2ndCmpTimer_g,
			use2ndPhy_g => use2ndPhy_g,
			useHwAcc_g => useHwAcc_g,
			m_burstcount_width_g => m_burstcount_width_g,
			m_tx_burst_size_g => m_tx_burst_size_g,
			m_rx_burst_size_g => m_rx_burst_size_g,
			m_tx_fifo_size_g => m_tx_fifo_size_g,
			m_rx_fifo_size_g => m_rx_fifo_size_g,
			iRpdos_g => iRpdos_g,
			iTpdos_g => iTpdos_g,
			genABuf1_g => genABuf1_g,
			genABuf2_g => genABuf2_g,
			genLedGadget_g => genLedGadget_g,
			iTpdoBufSize_g => iTpdoBufSize_g,
			iRpdo0BufSize_g => iRpdo0BufSize_g,
			iRpdo1BufSize_g => iRpdo1BufSize_g,
			iRpdo2BufSize_g => iRpdo2BufSize_g,
			iAsyBuf1Size_g => iAsyBuf1Size_g,
			iAsyBuf2Size_g => iAsyBuf2Size_g,
			iPdiRev_g => iPdiRev_g,
			papDataWidth_g => papDataWidth_g,
			papLowAct_g => papLowAct_g,
			papBigEnd_g => papBigEnd_g,
			spiCPOL_g => spiCPOL_g,
			spiCPHA_g => spiCPHA_g,
			spiBigEnd_g => spiBigEnd_g,
			pioValLen_g => pioValLen_g
		)

		port map (
			clk50 => clk50,
			rst => rst,
			clkEth => clkEth,
			m_clk => m_clk,
			pkt_clk => pkt_clk,
			clkPcp => clkPcp,
			clkAp => clkAp,
			rstPcp => rstPcp,
			rstAp => rstAp,
			mac_chipselect => mac_chipselect,
			mac_read => mac_read,
			mac_write => mac_write,
			mac_byteenable => mac_byteenable,
			mac_address => mac_address,
			mac_writedata => mac_writedata,
			mac_readdata => mac_readdata,
			mac_waitrequest => mac_waitrequest,
			mac_irq => mac_irq,
			tcp_chipselect => tcp_chipselect,
			tcp_read => tcp_read,
			tcp_write => tcp_write,
			tcp_byteenable => tcp_byteenable,
			tcp_address => tcp_address,
			tcp_writedata => tcp_writedata,
			tcp_readdata => tcp_readdata,
			tcp_waitrequest => tcp_waitrequest,
			tcp_irq => tcp_irq,
			mbf_chipselect => mbf_chipselect,
			mbf_read => mbf_read,
			mbf_write => mbf_write,
			mbf_byteenable => mbf_byteenable,
			mbf_address => mbf_address,
			mbf_writedata => mbf_writedata,
			mbf_readdata => mbf_readdata,
			mbf_waitrequest => mbf_waitrequest,
			m_read => m_read,
			m_write => m_write,
			m_byteenable => m_byteenable,
			m_address => m_address,
			m_writedata => m_writedata,
			m_readdata => m_readdata,
			m_waitrequest => m_waitrequest,
			m_readdatavalid => m_readdatavalid,
			m_burstcount => m_burstcount,
			pcp_chipselect => pcp_chipselect,
			pcp_read => pcp_read,
			pcp_write => pcp_write,
			pcp_byteenable => pcp_byteenable,
			pcp_address => pcp_address,
			pcp_writedata => pcp_writedata,
			pcp_readdata => pcp_readdata,
			ap_irq => ap_irq,
			ap_irq_n => ap_irq_n,
			ap_asyncIrq => ap_asyncIrq,
			ap_asyncIrq_n => ap_asyncIrq_n,
			ap_chipselect => ap_chipselect,
			ap_read => ap_read,
			ap_write => ap_write,
			ap_byteenable => ap_byteenable,
			ap_address => ap_address,
			ap_writedata => ap_writedata,
			ap_readdata => ap_readdata,
			pap_cs => pap_cs,
			pap_rd => pap_rd,
			pap_wr => pap_wr,
			pap_be => pap_be,
			pap_cs_n => pap_cs_n,
			pap_rd_n => pap_rd_n,
			pap_wr_n => pap_wr_n,
			pap_be_n => pap_be_n,
			pap_addr => pap_addr,
			pap_data => pap_data,
			pap_ack => pap_ack,
			pap_ack_n => pap_ack_n,
			pap_gpio => pap_gpio,
			spi_clk => spi_clk,
			spi_sel_n => spi_sel_n,
			spi_mosi => spi_mosi,
			spi_miso => spi_miso,
			smp_address => smp_address,
			smp_read => smp_read,
			smp_readdata => smp_readdata,
			smp_write => smp_write,
			smp_writedata => smp_writedata,
			smp_byteenable => smp_byteenable,
			pio_pconfig => pio_pconfig,
			pio_portInLatch => pio_portInLatch,
			pio_portOutValid => pio_portOutValid,
			pio_portio => pio_portio,
			pio_operational => pio_operational,
			phy0_RxDat => phy0_RxDat,
			phy0_RxDv => phy0_RxDv,
			phy0_RxErr => phy0_RxErr,
			phy0_TxDat => phy0_TxDat,
			phy0_TxEn => phy0_TxEn,
			phy0_SMIClk => phy0_SMIClk,
			phy0_SMIDat => phy0_SMIDat,
			phy0_Rst_n => phy0_Rst_n,
			phy0_link => phy0_link,
			phy1_RxDat => phy1_RxDat,
			phy1_RxDv => phy1_RxDv,
			phy1_RxErr => phy1_RxErr,
			phy1_TxDat => phy1_TxDat,
			phy1_TxEn => phy1_TxEn,
			phy1_SMIClk => phy1_SMIClk,
			phy1_SMIDat => phy1_SMIDat,
			phy1_Rst_n => phy1_Rst_n,
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
			led_error => led_error,
			led_status => led_status,
			led_phyLink => led_phyLink,
			led_phyAct => led_phyAct,
			led_opt => led_opt,
			led_gpo => led_gpo
		);

	-- Add your stimulus here ...

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_powerlink of powerlink_tb is
	for TB_ARCHITECTURE
		for UUT : powerlink
			use entity work.powerlink(rtl);
		end for;
	end for;
end TESTBENCH_FOR_powerlink;

