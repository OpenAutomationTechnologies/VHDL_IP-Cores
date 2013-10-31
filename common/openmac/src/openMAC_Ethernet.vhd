-------------------------------------------------------------------------------
--! @file openMAC_Ethernet.vhd
--
--! @brief The old openMAC toplevel - DEPRECATED
--
--! @details This is deprecated openMAC toplevel file!
-------------------------------------------------------------------------------
--
--    (c) B&R, 2013
--
--    Redistribution and use in    source and binary forms, with or without
--    modification, are permitted provided that the following conditions
--    are met:
--
--    1. Redistributions of source code must retain    the above copyright
--       notice, this list of conditions and the following disclaimer.
--
--    2. Redistributions in    binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in    the
--       documentation and/or other materials provided with the distribution.
--
--    3. Neither the name of B&R nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without   prior written permission. For written
--       permission, please contact office@br-automation.com
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. in    NO EVENT SHALL THE
--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER in    CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY out   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--! use global library
use work.global.all;
--! use openmac package
use work.openmacPkg.all;

entity openmac_ethernet is
    generic (
        -----------------------------------------------------------------------
        -- Phy configuration
        -----------------------------------------------------------------------
        useRmii_g               : boolean := true;
        genHub_g                : boolean := false;
        genSmiIO                : boolean := true;
        gNumSmi                 : integer := 2;
        -----------------------------------------------------------------------
        -- General configuration
        -----------------------------------------------------------------------
        endian_g                : string := "little";
        genPhyActLed_g          : boolean := false;
        gen_dma_observer_g      : boolean := true;
        -----------------------------------------------------------------------
        -- DMA configuration
        -----------------------------------------------------------------------
        dma_highadr_g           : integer := 31;
        m_data_width_g          : integer := 16;
        m_burstcount_const_g    : boolean := true;
        m_burstcount_width_g    : integer := 4;
        m_rx_burst_size_g       : integer := 16;
        m_tx_burst_size_g       : integer := 16;
        m_rx_fifo_size_g        : integer := 16;
        m_tx_fifo_size_g        : integer := 16;
        -----------------------------------------------------------------------
        -- Packet buffer configuration
        -----------------------------------------------------------------------
        iPktBufSize_g           : integer := 1024;
        iPktBufSizeLog2_g       : integer := 10;
        useIntPktBuf_g          : boolean := false;
        useRxIntPktBuf_g        : boolean := false;
        -----------------------------------------------------------------------
        -- MAC timer configuration
        -----------------------------------------------------------------------
        gen2ndCmpTimer_g        : boolean := false;
        genPulse2ndCmpTimer_g   : boolean := true;
        pulseWidth2ndCmpTimer_g : integer := 9;
        simulate                : boolean := false
    );
    port (
        -----------------------------------------------------------------------
        -- Clock and reset
        -----------------------------------------------------------------------
        rst             : in    std_logic;
        clk             : in    std_logic;
        clkx2           : in    std_logic;
        m_clk           : in    std_logic;
        pkt_clk         : in    std_logic;
        -----------------------------------------------------------------------
        -- MAC REG slave
        -----------------------------------------------------------------------
        s_address       : in    std_logic_vector(11 downto 0);
        s_byteenable    : in    std_logic_vector(1 downto 0);
        s_chipselect    : in    std_logic;
        s_irq           : out   std_logic;
        s_read          : in    std_logic;
        s_readdata      : out   std_logic_vector(15 downto 0);
        s_waitrequest   : out   std_logic;
        s_write         : in    std_logic;
        s_writedata     : in    std_logic_vector(15 downto 0);
        -----------------------------------------------------------------------
        -- MAC TIMER slave
        -----------------------------------------------------------------------
        t_address       : in    std_logic_vector(1 downto 0);
        t_byteenable    : in    std_logic_vector(3 downto 0); --unused!
        t_chipselect    : in    std_logic;
        t_read          : in    std_logic;
        t_readdata      : out   std_logic_vector(31 downto 0);
        t_tog           : out   std_logic;
        t_waitrequest   : out   std_logic;
        t_write         : in    std_logic;
        t_writedata     : in    std_logic_vector(31 downto 0);
        -----------------------------------------------------------------------
        -- PACKET BUFFER slave
        -----------------------------------------------------------------------
        pkt_address     : in    std_logic_vector(iPktBufSizeLog2_g-3 downto 0);
        pkt_byteenable  : in    std_logic_vector(3 downto 0);
        pkt_chipselect  : in    std_logic;
        pkt_read        : in    std_logic;
        pkt_readdata    : out   std_logic_vector(31 downto 0);
        pkt_waitrequest : out   std_logic;
        pkt_write       : in    std_logic;
        pkt_writedata   : in    std_logic_vector(31 downto 0);
        -----------------------------------------------------------------------
        -- MAC DMA master
        -----------------------------------------------------------------------
        m_address       : out   std_logic_vector(dma_highadr_g downto 0);
        m_burstcount    : out   std_logic_vector(m_burstcount_width_g-1 downto 0);
        m_burstcounter  : out   std_logic_vector(m_burstcount_width_g-1 downto 0);
        m_byteenable    : out   std_logic_vector(m_data_width_g/8-1 downto 0);
        m_read          : out   std_logic;
        m_readdata      : in    std_logic_vector(m_data_width_g-1 downto 0);
        m_readdatavalid : in    std_logic;
        m_waitrequest   : in    std_logic;
        m_write         : out   std_logic;
        m_writedata     : out   std_logic_vector(m_data_width_g-1 downto 0);
        -----------------------------------------------------------------------
        -- RMII PHY
        -----------------------------------------------------------------------
        phy0_rst_n      : out   std_logic;
        phy0_rx_dat     : in    std_logic_vector(1 downto 0);
        phy0_rx_dv      : in    std_logic;
        phy0_rx_err     : in    std_logic;
        phy0_smi_clk    : out   std_logic;
        phy0_smi_dio    : inout std_logic;
        phy0_smi_dio_I  : in    std_logic;
        phy0_smi_dio_O  : out   std_logic;
        phy0_smi_dio_T  : out   std_logic;
        phy0_tx_dat     : out   std_logic_vector(1 downto 0);
        phy0_tx_en      : out   std_logic;
        phy1_rst_n      : out   std_logic;
        phy1_rx_dat     : in    std_logic_vector(1 downto 0);
        phy1_rx_dv      : in    std_logic;
        phy1_rx_err     : in    std_logic;
        phy1_smi_clk    : out   std_logic;
        phy1_smi_dio    : inout std_logic;
        phy1_smi_dio_I  : in    std_logic;
        phy1_smi_dio_O  : out   std_logic;
        phy1_smi_dio_T  : out   std_logic;
        phy1_tx_dat     : out   std_logic_vector(1 downto 0);
        phy1_tx_en      : out   std_logic;
        -----------------------------------------------------------------------
        -- PHY MANAGEMENT
        -----------------------------------------------------------------------
        phy_rst_n       : out   std_logic;
        phy_smi_clk     : out   std_logic;
        phy_smi_dio     : inout std_logic;
        phy_smi_dio_I   : in    std_logic;
        phy_smi_dio_O   : out   std_logic;
        phy_smi_dio_T   : out   std_logic;
        -----------------------------------------------------------------------
        -- MII PHY
        -----------------------------------------------------------------------
        phyMii0_rx_clk  : in    std_logic;
        phyMii0_rx_dat  : in    std_logic_vector(3 downto 0);
        phyMii0_rx_dv   : in    std_logic;
        phyMii0_rx_err  : in    std_logic;
        phyMii0_tx_clk  : in    std_logic;
        phyMii0_tx_dat  : out   std_logic_vector(3 downto 0);
        phyMii0_tx_en   : out   std_logic;
        phyMii1_rx_clk  : in    std_logic;
        phyMii1_rx_dat  : in    std_logic_vector(3 downto 0);
        phyMii1_rx_dv   : in    std_logic;
        phyMii1_rx_err  : in    std_logic;
        phyMii1_tx_clk  : in    std_logic;
        phyMii1_tx_dat  : out   std_logic_vector(3 downto 0);
        phyMii1_tx_en   : out   std_logic;
        -----------------------------------------------------------------------
        -- INTERRUPTS
        -----------------------------------------------------------------------
        t_irq           : out   std_logic;
        mac_rx_irq      : out   std_logic;
        mac_tx_irq      : out   std_logic;
        -----------------------------------------------------------------------
        -- OTHERS
        -----------------------------------------------------------------------
        act_led         : out   std_logic
    );
end openmac_ethernet;

architecture rtl of openmac_ethernet is
    --! Function to calculate phy port count depending on hub enable.
    function calcPhyPortCount (hubEnable : boolean) return natural is
    begin
        if hubEnable = FALSE then
            return 1; --no hub, so only one port
        else
            return 2; --hub, fix to two ports
        end if;
    end function;

    --! Function to convert Rmii enable into phy port config value.
    function calcPhyPortConfig (rmiiEnable : boolean) return natural is
    begin
        if rmiiEnable = FALSE then
            return cPhyPortMii;
        else
            return cPhyPortRmii;
        end if;
    end function;

    --! Function to generate packet buffer location for Tx
    function convPacketBufferLocTx (
        enableIntPktBuf     : boolean
    ) return natural is
    begin
        -- If internal Packet buffer is disabled, Tx buffer is external.
        -- Otherwise it is locally.
        if enableIntPktBuf = FALSE then
            return cPktBufExtern;
        else
            return cPktBufLocal;
        end if;
    end function;

    --! Function to generate packet buffer location for Rx
    function convPacketBufferLocRx (
        enableIntPktBuf     : boolean;
        enableIntPktBufRx   : boolean
    ) return natural is
    begin
        -- If internal packet buffer is disabled, Rx buffer is external for sure.
        -- If internal packet buffer is enabled, Rx buffer could be external or
        -- internal depending on internal Rx buffer boolean.
        if enableIntPktBuf = FALSE then
            return cPktBufExtern;
        elsif enableIntPktBufRx = FALSE then
            return cPktBufExtern;
        else
            return cPktBufLocal;
        end if;
    end function;

    --! Function to convert second timer enable into number.
    function convTimerCount (enable2ndTimer : boolean) return natural is
    begin
        if enable2ndTimer = FALSE then
            return 1;
        else
            return 2;
        end if;
    end function;

    --! Number of phy ports
    constant cPhyPortCount  : natural := calcPhyPortCount(genHub_g);
    --! Number of SMI ports
    constant cSmiPortCount  : natural := gNumSmi;
    --! Number of timers
    constant cTimerCount    : natural := convTimerCount(gen2ndCmpTimer_g);

    --! RMII Rx paths
    signal rmiiRxPath   : tRmiiPathArray(cPhyPortCount-1 downto 0);
    --! RMII Rx errors
    signal rmiiRxError  : std_logic_vector(cPhyPortCount-1 downto 0);
    --! RMII Tx paths
    signal rmiiTxPath   : tRmiiPathArray(cPhyPortCount-1 downto 0);

    --! MII Rx paths
    signal miiRxPath    : tMiiPathArray(cPhyPortCount-1 downto 0);
    --! MII Rx errors
    signal miiRxError   : std_logic_vector(cPhyPortCount-1 downto 0);
    --! MII Rx clocks
    signal miiRxClk     : std_logic_vector(cPhyPortCount-1 downto 0);
    --! MII Tx paths
    signal miiTxPath    : tMiiPathArray(cPhyPortCount-1 downto 0);
    --! MII Tx clocks
    signal miiTxClk     : std_logic_vector(cPhyPortCount-1 downto 0);

    --! Phy reset
    signal nPhyRst      : std_logic_vector(cSmiPortCount-1 downto 0);
    --! SMI clocks
    signal smiClk       : std_logic_vector(cSmiPortCount-1 downto 0);
    --! SMI data out enable
    signal smiDoutEn    : std_logic;
    --! SMI data out
    signal smiDout      : std_logic_vector(cSmiPortCount-1 downto 0);
    --! SMI data in
    signal smiDin       : std_logic_vector(cSmiPortCount-1 downto 0);

    --! MAC Tx interrupt
    signal macTxIrq     : std_logic;
    --! MAC Rx interrupt
    signal macRxIrq     : std_logic;

    --! MAC timer output
    signal macTimer     : std_logic_vector(cTimerCount-1 downto 0);

    --! MAC REG byte address
    signal macReg_address   : std_logic_vector(s_address'left+1 downto 0);
    --! MAC TIMER byte address
    signal macTimer_address : std_logic_vector(t_address'left+2 downto 0);
    --! PACKET BUFFER byte address
    signal pktBuf_address   : std_logic_vector(pkt_address'left+2 downto 0);
begin
    --! This is the real openmac toplevel component, instantiated by this wrapper.
    THE_REALOPENMACTOP : entity work.openmacTop
        generic map (
            gPhyPortCount           => cPhyPortCount,
            gPhyPortType            => calcPhyPortConfig(useRmii_g),
            gSmiPortCount           => cSmiPortCount,
            gEndianness             => endian_g,
            gEnableActivity         => booleanToInteger(genPhyActLed_g),
            gEnableDmaObserver      => booleanToInteger(gen_dma_observer_g),
            gDmaAddrWidth           => dma_highadr_g+1,
            gDmaDataWidth           => m_data_width_g,
            gDmaBurstCountWidth     => m_burstcount_width_g,
            gDmaWriteBurstLength    => m_rx_burst_size_g,
            gDmaReadBurstLength     => m_tx_burst_size_g,
            gDmaWriteFifoLength     => m_rx_fifo_size_g,
            gDmaReadFifoLength      => m_tx_fifo_size_g,
            gPacketBufferLocTx      => convPacketBufferLocTx(useIntPktBuf_g),
            gPacketBufferLocRx      => convPacketBufferLocRx(useIntPktBuf_g, useRxIntPktBuf_g),
            gPacketBufferLog2Size   => iPktBufSizeLog2_g,
            gTimerCount             => cTimerCount,
            gTimerEnablePulseWidth  => booleanToInteger(genPulse2ndCmpTimer_g),
            gTimerPulseRegWidth     => pulseWidth2ndCmpTimer_g
        )
        port map (
            iClk                    => clk,
            iRst                    => rst,
            iDmaClk                 => m_clk,
            iDmaRst                 => rst,
            iPktBufClk              => pkt_clk,
            iPktBufRst              => rst,
            iClk2x                  => clkx2,
            iMacReg_chipselect      => s_chipselect,
            iMacReg_write           => s_write,
            iMacReg_read            => s_read,
            oMacReg_waitrequest     => s_waitrequest,
            iMacReg_byteenable      => s_byteenable,
            iMacReg_address         => macReg_address,
            iMacReg_writedata       => s_writedata,
            oMacReg_readdata        => s_readdata,
            iMacTimer_chipselect    => t_chipselect,
            iMacTimer_write         => t_write,
            iMacTimer_read          => t_read,
            oMacTimer_waitrequest   => t_waitrequest,
            iMacTimer_address       => macTimer_address,
            iMacTimer_writedata     => t_writedata,
            oMacTimer_readdata      => t_readdata,
            iPktBuf_chipselect      => pkt_chipselect,
            iPktBuf_write           => pkt_write,
            iPktBuf_read            => pkt_read,
            oPktBuf_waitrequest     => pkt_waitrequest,
            iPktBuf_byteenable      => pkt_byteenable,
            iPktBuf_address         => pktBuf_address,
            iPktBuf_writedata       => pkt_writedata,
            oPktBuf_readdata        => pkt_readdata,
            oDma_write              => m_write,
            oDma_read               => m_read,
            iDma_waitrequest        => m_waitrequest,
            iDma_readdatavalid      => m_readdatavalid,
            oDma_byteenable         => m_byteenable,
            oDma_address            => m_address,
            oDma_burstcount         => m_burstcount,
            oDma_burstcounter       => m_burstcounter,
            oDma_writedata          => m_writedata,
            iDma_readdata           => m_readdata,
            oMacTimer_interrupt     => t_irq,
            oMacTx_interrupt        => macTxIrq,
            oMacRx_interrupt        => macRxIrq,
            iRmii_Rx                => rmiiRxPath,
            iRmii_RxError           => rmiiRxError,
            oRmii_Tx                => rmiiTxPath,
            iMii_Rx                 => miiRxPath,
            iMii_RxError            => miiRxError,
            iMii_RxClk              => miiRxClk,
            oMii_Tx                 => miiTxPath,
            iMii_TxClk              => miiTxClk,
            onPhy_reset             => nPhyRst,
            oSmi_clk                => smiClk,
            oSmi_data_outEnable     => smiDoutEn,
            oSmi_data_out           => smiDout,
            iSmi_data_in            => smiDin,
            oActivity               => act_led,
            oMacTimer               => macTimer
        );

    assert (m_burstcount_const_g = true)
    report "m_burstcount_const_g is assumed to be always TRUE!"
    severity failure;

    assert (2**iPktBufSizeLog2_g = iPktBufSize_g)
    report "Packet buffer size is clipped to power 2 value!"
    severity warning;

    assert (simulate = FALSE)
    report "Simulate generic is ignored!"
    severity warning;

    ---------------------------------------------------------------------------
    -- Address conversion
    ---------------------------------------------------------------------------
    macReg_address      <= s_address & '0'; -- Convert word to byte address
    macTimer_address    <= t_address & "00"; -- Convert dword to byte address
    pktBuf_address      <= pkt_address & "00"; -- Convert dword to byte address

    ---------------------------------------------------------------------------
    -- Interrupts and timer
    ---------------------------------------------------------------------------
    s_irq       <= macRxIrq or macTxIrq;
    mac_rx_irq  <= macRxIrq;
    mac_tx_irq  <= macTxIrq;

    GEN_SECOND_TIMER : if cTimerCount > 1 generate
        t_tog <= macTimer(1);
    end generate GEN_SECOND_TIMER;

    ---------------------------------------------------------------------------
    -- SMI
    ---------------------------------------------------------------------------
    GEN_EXCLUSIVE_SMI_IOS : if genSmiIO = TRUE and cSmiPortCount = 2 generate
        -- assign out buffer
        phy0_smi_dio <= smiDout(0) when smiDoutEn = cActivated else 'Z';
        phy0_smi_clk <= smiClk(0);
        phy1_smi_dio <= smiDout(1) when smiDoutEn = cActivated else 'Z';
        phy1_smi_clk <= smiClk(1);

        -- assign input
        smiDin(0) <= phy0_smi_dio;
        smiDin(1) <= phy1_smi_dio;
    end generate GEN_EXCLUSIVE_SMI_IOS;

    GEN_SMI_IO : if genSmiIO = TRUE and cSmiPortCount = 1 generate
        -- assign out buffer
        phy_smi_dio <= smiDout(0) when smiDoutEn = cActivated else 'Z';
        phy_smi_clk <= smiClk(0);

        -- assign input
        smiDin(0) <= phy_smi_dio;
    end generate GEN_SMI_IO;

    DONT_GEN_EXCLUSIVE_IOS : if genSmiIO = FALSE and cSmiPortCount = 2 generate
        phy0_smi_dio_O <= smiDout(0);
        phy0_smi_dio_T <= not smiDoutEn; --this is wanted -> 1 = input, O = output
        phy0_smi_clk <= smiClk(0);

        smiDin(0) <= phy0_smi_dio_I;

        phy1_smi_dio_O <= smiDout(1);
        phy1_smi_dio_T <= not smiDoutEn; --this is wanted -> 1 = input, O = output
        phy1_smi_clk <= smiClk(1);

        smiDin(1) <= phy1_smi_dio_I;
    end generate DONT_GEN_EXCLUSIVE_IOS;

    DONT_GEN_IO : if genSmiIO = FALSE and cSmiPortCount = 1 generate
        phy_smi_dio_O <= smiDout(0);
        phy_smi_dio_T <= not smiDoutEn; --this is wanted -> 1 = input, O = output
        phy_smi_clk <= smiClk(0);

        smiDin(0) <= phy_smi_dio_I;
    end generate DONT_GEN_IO;

    phy0_rst_n  <= nPhyRst(0);
    phy1_rst_n  <= nPhyRst(0);
    phy_rst_n   <= nPhyRst(0); -- vector is identical

    ---------------------------------------------------------------------------
    -- RMII Phy ports
    ---------------------------------------------------------------------------
    rmiiRxPath(0).data      <= phy0_rx_dat;
    rmiiRxPath(0).enable    <= phy0_rx_dv;
    rmiiRxError(0)          <= phy0_rx_err;

    rmiiRxPath(1).data      <= phy1_rx_dat;
    rmiiRxPath(1).enable    <= phy1_rx_dv;
    rmiiRxError(1)          <= phy1_rx_err;

    phy0_tx_dat <= rmiiTxPath(0).data;
    phy0_tx_en  <= rmiiTxPath(0).enable;

    phy1_tx_dat <= rmiiTxPath(1).data;
    phy1_tx_en  <= rmiiTxPath(1).enable;

    ---------------------------------------------------------------------------
    -- MII Phy ports
    ---------------------------------------------------------------------------
    miiRxPath(0).data       <= phyMii0_rx_dat;
    miiRxPath(0).enable     <= phyMii0_rx_dv;
    miiRxError(0)           <= phyMii0_rx_err;
    miiRxClk(0)             <= phyMii0_rx_clk;
    miiTxClk(0)             <= phyMii0_tx_clk;

    miiRxPath(1).data       <= phyMii1_rx_dat;
    miiRxPath(1).enable     <= phyMii1_rx_dv;
    miiRxError(1)           <= phyMii1_rx_err;
    miiRxClk(1)             <= phyMii1_rx_clk;
    miiTxClk(1)             <= phyMii1_tx_clk;

    phyMii0_tx_dat  <= miiTxPath(0).data;
    phyMii0_tx_en   <= miiTxPath(0).enable;

    phyMii1_tx_dat  <= miiTxPath(1).data;
    phyMii1_tx_en   <= miiTxPath(1).enable;
end rtl;
