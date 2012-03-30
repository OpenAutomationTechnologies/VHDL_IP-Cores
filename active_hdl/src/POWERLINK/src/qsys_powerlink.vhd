-------------------------------------------------------------------------------
-- Entity : POWERLINK IP-Core Wrapper for Qsys
-------------------------------------------------------------------------------
--
--    (c) B&R, 2012
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
-- Version History
-------------------------------------------------------------------------------
-- 2012-03-15   V0.01   zelenkaj    First Version
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity qsys_powerlink is
  generic(
       Simulate : integer := 0;
       endian_g : string := "little";
       gNumSmi : integer range 1 to 2 := 2;
       genABuf1_g : integer := 1;
       genABuf2_g : integer := 1;
       genEvent_g : integer := 0;
       genInternalAp_g : integer := 1;
       genIoBuf_g : integer := 1;
       genLedGadget_g : integer := 0;
       genOnePdiClkDomain_g : integer := 0;
       genPdi_g : integer := 1;
       genSimpleIO_g : integer := 0;
       genSmiIO : integer := 1;
       genSpiAp_g : integer := 0;
       genTimeSync_g : integer := 0;
       gen_dma_observer_g : integer := 1;
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
       m_burstcount_const_g : integer := 1;
       m_burstcount_width_g : integer := 4;
       m_data_width_g : integer := 16;
       m_rx_burst_size_g : integer := 16;
       m_rx_fifo_size_g : integer := 16;
       m_tx_burst_size_g : integer := 16;
       m_tx_fifo_size_g : integer := 16;
       papBigEnd_g : integer := 0;
       papDataWidth_g : integer := 8;
       papLowAct_g : integer := 0;
       pioValLen_g : integer := 50;
       spiBigEnd_g : integer := 0;
       spiCPHA_g : integer := 0;
       spiCPOL_g : integer := 0;
       use2ndCmpTimer_g : integer := 1;
       use2ndPhy_g : integer := 1;
       useIntPacketBuf_g : integer := 1;
       useRmii_g : integer := 1;
       useRxIntPacketBuf_g : integer := 1
  );
  port(
       ap_chipselect : in std_logic;
       ap_read : in std_logic;
       ap_write : in std_logic;
       clk50 : in std_logic;
       clkAp : in std_logic;
       clkEth : in std_logic;
       clkPcp : in std_logic;
       m_clk : in std_logic;
       m_readdatavalid : in std_logic;
       m_waitrequest : in std_logic;
       mac_chipselect : in std_logic;
       mac_read : in std_logic;
       mac_write : in std_logic;
       mbf_chipselect : in std_logic;
       mbf_read : in std_logic;
       mbf_write : in std_logic;
       pap_cs : in std_logic;
       pap_cs_n : in std_logic;
       pap_rd : in std_logic;
       pap_rd_n : in std_logic;
       pap_wr : in std_logic;
       pap_wr_n : in std_logic;
       pcp_chipselect : in std_logic;
       pcp_read : in std_logic;
       pcp_write : in std_logic;
       phy0_RxDv : in std_logic;
       phy0_RxErr : in std_logic;
       phy0_SMIDat_I : in std_logic;
       phy0_link : in std_logic;
       phy1_RxDv : in std_logic;
       phy1_RxErr : in std_logic;
       phy1_SMIDat_I : in std_logic;
       phy1_link : in std_logic;
       phyMii0_RxClk : in std_logic;
       phyMii0_RxDv : in std_logic;
       phyMii0_RxEr : in std_logic;
       phyMii0_TxClk : in std_logic;
       phyMii1_RxClk : in std_logic;
       phyMii1_RxDv : in std_logic;
       phyMii1_RxEr : in std_logic;
       phyMii1_TxClk : in std_logic;
       phy_SMIDat_I : in std_logic;
       pkt_clk : in std_logic;
       rst : in std_logic;
       rstAp : in std_logic;
       rstPcp : in std_logic;
       smp_address : in std_logic;
       smp_read : in std_logic;
       smp_write : in std_logic;
       spi_clk : in std_logic;
       spi_mosi : in std_logic;
       spi_sel_n : in std_logic;
       tcp_chipselect : in std_logic;
       tcp_read : in std_logic;
       tcp_write : in std_logic;
       ap_address : in std_logic_vector(12 downto 0);
       ap_byteenable : in std_logic_vector(3 downto 0);
       ap_writedata : in std_logic_vector(31 downto 0);
       m_readdata : in std_logic_vector(m_data_width_g-1 downto 0);
       mac_address : in std_logic_vector(11 downto 0);
       mac_byteenable : in std_logic_vector(1 downto 0);
       mac_writedata : in std_logic_vector(15 downto 0);
       mbf_address : in std_logic_vector(ibufsizelog2_g-3 downto 0);
       mbf_byteenable : in std_logic_vector(3 downto 0);
       mbf_writedata : in std_logic_vector(31 downto 0);
       pap_addr : in std_logic_vector(15 downto 0);
       pap_be : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       pap_be_n : in std_logic_vector(papDataWidth_g/8-1 downto 0);
       pap_data_I : in std_logic_vector(papDataWidth_g-1 downto 0);
       pap_gpio_I : in std_logic_vector(1 downto 0);
       pcp_address : in std_logic_vector(12 downto 0);
       pcp_byteenable : in std_logic_vector(3 downto 0);
       pcp_writedata : in std_logic_vector(31 downto 0);
       phy0_RxDat : in std_logic_vector(1 downto 0);
       phy1_RxDat : in std_logic_vector(1 downto 0);
       phyMii0_RxDat : in std_logic_vector(3 downto 0);
       phyMii1_RxDat : in std_logic_vector(3 downto 0);
       pio_pconfig : in std_logic_vector(3 downto 0);
       pio_portInLatch : in std_logic_vector(3 downto 0);
       pio_portio_I : in std_logic_vector(31 downto 0);
       smp_byteenable : in std_logic_vector(3 downto 0);
       smp_writedata : in std_logic_vector(31 downto 0);
       tcp_address : in std_logic_vector(1 downto 0);
       tcp_byteenable : in std_logic_vector(3 downto 0);
       tcp_writedata : in std_logic_vector(31 downto 0);
       ap_asyncIrq : out std_logic;
       ap_asyncIrq_n : out std_logic;
       ap_irq : out std_logic;
       ap_irq_n : out std_logic;
       ap_syncIrq : out std_logic;
       ap_syncIrq_n : out std_logic;
       ap_waitrequest : out std_logic;
       led_error : out std_logic;
       led_status : out std_logic;
       m_read : out std_logic;
       m_write : out std_logic;
       mac_irq : out std_logic;
       mac_waitrequest : out std_logic;
       mbf_waitrequest : out std_logic;
       pap_ack : out std_logic;
       pap_ack_n : out std_logic;
       pap_data_T : out std_logic;
       pcp_waitrequest : out std_logic;
       phy0_Rst_n : out std_logic;
       phy0_SMIClk : out std_logic;
       phy0_SMIDat_O : out std_logic;
       phy0_SMIDat_T : out std_logic;
       phy0_TxEn : out std_logic;
       phy1_Rst_n : out std_logic;
       phy1_SMIClk : out std_logic;
       phy1_SMIDat_O : out std_logic;
       phy1_SMIDat_T : out std_logic;
       phy1_TxEn : out std_logic;
       phyMii0_TxEn : out std_logic;
       phyMii0_TxEr : out std_logic;
       phyMii1_TxEn : out std_logic;
       phyMii1_TxEr : out std_logic;
       phy_Rst_n : out std_logic;
       phy_SMIClk : out std_logic;
       phy_SMIDat_O : out std_logic;
       phy_SMIDat_T : out std_logic;
       pio_operational : out std_logic;
       smp_waitrequest : out std_logic;
       spi_miso : out std_logic;
       tcp_irq : out std_logic;
       tcp_waitrequest : out std_logic;
       ap_readdata : out std_logic_vector(31 downto 0);
       led_gpo : out std_logic_vector(7 downto 0);
       led_opt : out std_logic_vector(1 downto 0);
       led_phyAct : out std_logic_vector(1 downto 0);
       led_phyLink : out std_logic_vector(1 downto 0);
       m_address : out std_logic_vector(29 downto 0);
       m_burstcount : out std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_burstcounter : out std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_byteenable : out std_logic_vector(m_data_width_g/8-1 downto 0);
       m_writedata : out std_logic_vector(m_data_width_g-1 downto 0);
       mac_readdata : out std_logic_vector(15 downto 0);
       mbf_readdata : out std_logic_vector(31 downto 0);
       pap_data_O : out std_logic_vector(papDataWidth_g-1 downto 0);
       pap_gpio_O : out std_logic_vector(1 downto 0);
       pap_gpio_T : out std_logic_vector(1 downto 0);
       pcp_readdata : out std_logic_vector(31 downto 0);
       phy0_TxDat : out std_logic_vector(1 downto 0);
       phy1_TxDat : out std_logic_vector(1 downto 0);
       phyMii0_TxDat : out std_logic_vector(3 downto 0);
       phyMii1_TxDat : out std_logic_vector(3 downto 0);
       pio_portOutValid : out std_logic_vector(3 downto 0);
       pio_portio_O : out std_logic_vector(31 downto 0);
       pio_portio_T : out std_logic_vector(31 downto 0);
       smp_readdata : out std_logic_vector(31 downto 0);
       tcp_readdata : out std_logic_vector(31 downto 0);
       phy0_SMIDat : inout std_logic;
       phy1_SMIDat : inout std_logic;
       phy_SMIDat : inout std_logic;
       pap_data : inout std_logic_vector(papDataWidth_g-1 downto 0);
       pap_gpio : inout std_logic_vector(1 downto 0);
       pio_portio : inout std_logic_vector(31 downto 0)
  );
end qsys_powerlink;

architecture qsys_powerlink of qsys_powerlink is

function conv_boolean(value_p : in integer) return boolean is
    variable tmp : boolean := false;
begin
    
    if value_p = 0 then
        tmp := false;
    else
        tmp := true;
    end if;
    
    return tmp;
end conv_boolean;

component powerlink
  generic(
       Simulate : boolean := false;
       endian_g : string := "little";
       gNumSmi : integer range 1 to 2 := 2;
       genABuf1_g : boolean := true;
       genABuf2_g : boolean := true;
       genEvent_g : boolean := false;
       genInternalAp_g : boolean := true;
       genIoBuf_g : boolean := true;
       genLedGadget_g : boolean := false;
       genOnePdiClkDomain_g : boolean := false;
       genPdi_g : boolean := true;
       genSimpleIO_g : boolean := false;
       genSmiIO : boolean := true;
       genSpiAp_g : boolean := false;
       genTimeSync_g : boolean := false;
       gen_dma_observer_g : boolean := true;
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
       m_burstcount_const_g : boolean := true;
       m_burstcount_width_g : integer := 4;
       m_data_width_g : integer := 16;
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
       m_readdata : in std_logic_vector(m_data_width_g-1 downto 0) := (others => '0');
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
       pap_data_I : in std_logic_vector(papDataWidth_g-1 downto 0) := (others => '0');
       pap_gpio_I : in std_logic_vector(1 downto 0) := (others => '0');
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
       phy0_SMIDat_I : in std_logic := '1';
       phy0_link : in std_logic := '0';
       phy1_RxDat : in std_logic_vector(1 downto 0) := (others => '0');
       phy1_RxDv : in std_logic;
       phy1_RxErr : in std_logic;
       phy1_SMIDat_I : in std_logic := '1';
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
       phy_SMIDat_I : in std_logic := '1';
       pio_pconfig : in std_logic_vector(3 downto 0);
       pio_portInLatch : in std_logic_vector(3 downto 0);
       pio_portio_I : in std_logic_vector(31 downto 0) := (others => '0');
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
       ap_syncIrq : out std_logic := '0';
       ap_syncIrq_n : out std_logic := '1';
       ap_waitrequest : out std_logic;
       led_error : out std_logic := '0';
       led_gpo : out std_logic_vector(7 downto 0) := (others => '0');
       led_opt : out std_logic_vector(1 downto 0) := (others => '0');
       led_phyAct : out std_logic_vector(1 downto 0) := (others => '0');
       led_phyLink : out std_logic_vector(1 downto 0) := (others => '0');
       led_status : out std_logic := '0';
       m_address : out std_logic_vector(29 downto 0) := (others => '0');
       m_burstcount : out std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_burstcounter : out std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_byteenable : out std_logic_vector(m_data_width_g/8-1 downto 0) := (others => '0');
       m_read : out std_logic := '0';
       m_write : out std_logic := '0';
       m_writedata : out std_logic_vector(m_data_width_g-1 downto 0) := (others => '0');
       mac_irq : out std_logic := '0';
       mac_readdata : out std_logic_vector(15 downto 0) := (others => '0');
       mac_waitrequest : out std_logic;
       mbf_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       mbf_waitrequest : out std_logic;
       pap_ack : out std_logic := '0';
       pap_ack_n : out std_logic := '1';
       pap_data_O : out std_logic_vector(papDataWidth_g-1 downto 0);
       pap_data_T : out std_logic;
       pap_gpio_O : out std_logic_vector(1 downto 0);
       pap_gpio_T : out std_logic_vector(1 downto 0);
       pcp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       pcp_waitrequest : out std_logic;
       phy0_Rst_n : out std_logic := '1';
       phy0_SMIClk : out std_logic := '0';
       phy0_SMIDat_O : out std_logic;
       phy0_SMIDat_T : out std_logic;
       phy0_TxDat : out std_logic_vector(1 downto 0) := (others => '0');
       phy0_TxEn : out std_logic := '0';
       phy1_Rst_n : out std_logic := '1';
       phy1_SMIClk : out std_logic := '0';
       phy1_SMIDat_O : out std_logic;
       phy1_SMIDat_T : out std_logic;
       phy1_TxDat : out std_logic_vector(1 downto 0) := (others => '0');
       phy1_TxEn : out std_logic := '0';
       phyMii0_TxDat : out std_logic_vector(3 downto 0) := (others => '0');
       phyMii0_TxEn : out std_logic := '0';
       phyMii0_TxEr : out std_logic := '0';
       phyMii1_TxDat : out std_logic_vector(3 downto 0) := (others => '0');
       phyMii1_TxEn : out std_logic := '0';
       phyMii1_TxEr : out std_logic := '0';
       phy_Rst_n : out std_logic := '1';
       phy_SMIClk : out std_logic := '0';
       phy_SMIDat_O : out std_logic;
       phy_SMIDat_T : out std_logic;
       pio_operational : out std_logic := '0';
       pio_portOutValid : out std_logic_vector(3 downto 0) := (others => '0');
       pio_portio_O : out std_logic_vector(31 downto 0);
       pio_portio_T : out std_logic_vector(31 downto 0);
       smp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       smp_waitrequest : out std_logic;
       spi_miso : out std_logic := '0';
       tcp_irq : out std_logic := '0';
       tcp_readdata : out std_logic_vector(31 downto 0) := (others => '0');
       tcp_waitrequest : out std_logic;
       pap_data : inout std_logic_vector(papDataWidth_g-1 downto 0) := (others => '0');
       pap_gpio : inout std_logic_vector(1 downto 0) := (others => '0');
       phy0_SMIDat : inout std_logic := '1';
       phy1_SMIDat : inout std_logic := '1';
       phy_SMIDat : inout std_logic := '1';
       pio_portio : inout std_logic_vector(31 downto 0) := (others => '0')
  );
end component;

begin

----  Component instantiations  ----

theQsysPowerlink : powerlink
  generic map(
        endian_g => endian_g,
        gNumSmi => gNumSmi,
        iAsyBuf1Size_g => iAsyBuf1Size_g,
        iAsyBuf2Size_g => iAsyBuf2Size_g,
        iBufSizeLOG2_g => iBufSizeLOG2_g,
        iBufSize_g => iBufSize_g,
        iPdiRev_g => iPdiRev_g,
        iRpdo0BufSize_g => iRpdo0BufSize_g,
        iRpdo1BufSize_g => iRpdo1BufSize_g,
        iRpdo2BufSize_g => iRpdo2BufSize_g,
        iRpdos_g => iRpdos_g,
        iTpdoBufSize_g => iTpdoBufSize_g,
        iTpdos_g => iTpdos_g,
        m_burstcount_width_g => m_burstcount_width_g,
        m_data_width_g => m_data_width_g,
        m_rx_burst_size_g => m_rx_burst_size_g,
        m_rx_fifo_size_g => m_rx_fifo_size_g,
        m_tx_burst_size_g => m_tx_burst_size_g,
        m_tx_fifo_size_g => m_tx_fifo_size_g,
        papDataWidth_g => papDataWidth_g,
        pioValLen_g => pioValLen_g,
        
        Simulate => conv_boolean(Simulate),
        genABuf1_g => conv_boolean(genABuf1_g),
        genABuf2_g => conv_boolean(genABuf2_g),
        genEvent_g => conv_boolean(genEvent_g),
        genInternalAp_g => conv_boolean(genInternalAp_g),
        genIoBuf_g => conv_boolean(genIoBuf_g),
        genLedGadget_g => conv_boolean(genLedGadget_g),
        genOnePdiClkDomain_g => conv_boolean(genOnePdiClkDomain_g),
        genPdi_g => conv_boolean(genPdi_g),
        genSimpleIO_g => conv_boolean(genSimpleIO_g),
        genSmiIO => conv_boolean(genSmiIO),
        genSpiAp_g => conv_boolean(genSpiAp_g),
        genTimeSync_g => conv_boolean(genTimeSync_g),
        gen_dma_observer_g => conv_boolean(gen_dma_observer_g),
        m_burstcount_const_g => conv_boolean(m_burstcount_const_g),
        papBigEnd_g => conv_boolean(papBigEnd_g),
        papLowAct_g => conv_boolean(papLowAct_g),
        spiBigEnd_g => conv_boolean(spiBigEnd_g),
        spiCPHA_g => conv_boolean(spiCPHA_g),
        spiCPOL_g => conv_boolean(spiCPOL_g),
        use2ndCmpTimer_g => conv_boolean(use2ndCmpTimer_g),
        use2ndPhy_g => conv_boolean(use2ndPhy_g),
        useIntPacketBuf_g => conv_boolean(useIntPacketBuf_g),
        useRmii_g => conv_boolean(useRmii_g),
        useRxIntPacketBuf_g => conv_boolean(useRxIntPacketBuf_g)
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
       ap_syncIrq => ap_syncIrq,
       ap_syncIrq_n => ap_syncIrq_n,
       ap_waitrequest => ap_waitrequest,
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
       m_burstcounter => m_burstcounter( m_burstcount_width_g-1 downto 0 ),
       m_byteenable => m_byteenable( m_data_width_g/8-1 downto 0 ),
       m_clk => m_clk,
       m_read => m_read,
       m_readdata => m_readdata( m_data_width_g-1 downto 0 ),
       m_readdatavalid => m_readdatavalid,
       m_waitrequest => m_waitrequest,
       m_write => m_write,
       m_writedata => m_writedata( m_data_width_g-1 downto 0 ),
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
       pap_data_I => pap_data_I( papDataWidth_g-1 downto 0 ),
       pap_data_O => pap_data_O( papDataWidth_g-1 downto 0 ),
       pap_data_T => pap_data_T,
       pap_gpio => pap_gpio,
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
       phy0_SMIDat => phy0_SMIDat,
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
       phy1_SMIDat => phy1_SMIDat,
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
       phy_Rst_n => phy_Rst_n,
       phy_SMIClk => phy_SMIClk,
       phy_SMIDat => phy_SMIDat,
       phy_SMIDat_I => phy_SMIDat_I,
       phy_SMIDat_O => phy_SMIDat_O,
       phy_SMIDat_T => phy_SMIDat_T,
       pio_operational => pio_operational,
       pio_pconfig => pio_pconfig,
       pio_portInLatch => pio_portInLatch,
       pio_portOutValid => pio_portOutValid,
       pio_portio => pio_portio,
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
       tcp_irq => tcp_irq,
       tcp_read => tcp_read,
       tcp_readdata => tcp_readdata,
       tcp_waitrequest => tcp_waitrequest,
       tcp_write => tcp_write,
       tcp_writedata => tcp_writedata
  );


end qsys_powerlink;
