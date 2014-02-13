-------------------------------------------------------------------------------
--! @file tbOpenmacTop-bhv-tb.vhd
--
--! @brief OpenMAC toplevel file including openMAC, openHUB and openFILTER
--
--! @details This is the openMAC toplevel file including the MAC layer IP-Cores.
--!          Additional components are provided for packet buffer storage.
-------------------------------------------------------------------------------
--
--    (c) B&R, 2013
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Common library
library libcommon;
--! Use common library global package
use libcommon.global.all;

--! Utility library
library libutil;

--! Work library
library work;
--! use openmac package
use work.openmacPkg.all;

entity tbOpenmacTop is
    generic (
        -----------------------------------------------------------------------
        -- Stimuli files
        --! For MAC REG
        gStimFileMacReg         : string := "text.txt";
        --! For PKT BUF
        gStimFilePktBuf         : string := "text.txt";
        --! For MAC TIMER
        gStimFileMacTimer       : string := "text.txt";
        -----------------------------------------------------------------------
        -- Phy configuration
        --! Number of Phy ports
        gPhyPortCount           : natural := 2;
        --! Phy port interface type (Rmii or Mii)
        gPhyPortType            : natural := cPhyPortRmii;
        --! Number of SMI phy ports
        gSmiPortCount           : natural := 1;
        -----------------------------------------------------------------------
        -- General configuration
        --! Endianness ("little" or "big")
        gEndianness             : string := "little";
        --! Enable packet activity generator (e.g. connect to LED)
        gEnableActivity         : natural := cFalse;
        --! Enable DMA observer circuit
        gEnableDmaObserver      : natural := cFalse;
        -----------------------------------------------------------------------
        -- DMA configuration
        --! DMA address width (byte-addressing)
        gDmaAddrWidth           : natural := 32;
        --! DMA data width
        gDmaDataWidth           : natural := 16;
        --! DMA burst count width
        gDmaBurstCountWidth     : natural := 4;
        --! DMA write burst length (Rx packets) [words]
        gDmaWriteBurstLength    : natural := 16;
        --! DMA read burst length (Tx packets) [words]
        gDmaReadBurstLength     : natural := 16;
        --! DMA write FIFO length (Rx packets) [words]
        gDmaWriteFifoLength     : natural := 16;
        --! DMA read FIFO length (Tx packets) [words]
        gDmaReadFifoLength      : natural := 16;
        -----------------------------------------------------------------------
        -- Packet buffer configuration
        --! Packet buffer location for Tx packets
        gPacketBufferLocTx      : natural := cPktBufLocal;
        --! Packet buffer location for Rx packets
        gPacketBufferLocRx      : natural := cPktBufLocal;
        --! Packet buffer log2(size) (ignored if gPacketBufferLocTx and gPacketBufferLocRx are both set to cPktBufLocal)
        gPacketBufferLog2Size   : natural := 10;
        -----------------------------------------------------------------------
        -- MAC timer configuration
        --! Number of timers
        gTimerCount             : natural := 2;
        --! Enable timer pulse width control
        gTimerEnablePulseWidth  : natural := cFalse;
        --! Timer pulse width register width
        gTimerPulseRegWidth     : natural := 10
    );
end tbOpenmacTop;

architecture bhv of tbOpenmacTop is
    ---------------------------------------------------------------------------
    -- Stimuli
    --! Clock period for openMAC (RMII)
    constant cPeriod_clk        : time := 20 ns;
    --! Clock period for openMAC 2x
    constant cPeriod_clk2x      : time := cPeriod_clk / 2;
    --! Clock period for DMA clk
    constant cPeriod_dmaClk     : time := 10 ns;
    --! Clock period for PKT BUF clk
    constant cPeriod_pktBufClk  : time := 10 ns;
    --! Reset time
    constant cResetTime         : time := 100 ns;
    --! Simulation done
    signal done                 : std_logic;
    --! Simulation error
    signal error                : std_logic;

    --! Bus master data width
    constant cBusMasterDataWidth    : natural := 32;
    --! Bus master address width
    constant cBusMasterAddrWidth    : natural := 32;

    --! Bus master type
    type tStimBusMaster is record
        rst         : std_logic;
        clk         : std_logic;
        enable      : std_logic;
        ack         : std_logic;
        readdata    : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        write       : std_logic;
        read        : std_logic;
        sel         : std_logic;
        address     : std_logic_vector(cBusMasterAddrWidth-1 downto 0);
        byteenable  : std_logic_vector(cBusMasterDataWidth/cByteLength-1 downto 0);
        writedata   : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        error       : std_logic;
        done        : std_logic;
    end record;

    ---------------------------------------------------------------------------
    -- Stim port mapping instances
    --! MAC REG bus master instance
    signal stim_macReg      : tStimBusMaster;

    --! PACKET BUFFER bus master instance
    signal stim_pktBuf      : tStimBusMaster;

    --! MAC TIMER bus master instance
    signal stim_macTimer    : tStimBusMaster;

    ---------------------------------------------------------------------------
    -- Type for DUT port mapping
    --! Clock and reset signal type
    type tDutClkRst is record
        clk         : std_logic;
        clk2x       : std_logic;
        rst         : std_logic;
        dmaClk      : std_logic;
        dmaRst      : std_logic;
        pktBufClk   : std_logic;
        pktBufRst   : std_logic;
    end record;

    --! MAC REG type
    type tDutMacReg is record
        chipselect  : std_logic;
        write       : std_logic;
        read        : std_logic;
        waitrequest : std_logic;
        byteenable  : std_logic_vector(cMacRegDataWidth/cByteLength-1 downto 0);
        address     : std_logic_vector(cMacRegAddrWidth-1 downto 0);
        writedata   : std_logic_vector(cMacRegDataWidth-1 downto 0);
        readdata    : std_logic_vector(cMacRegDataWidth-1 downto 0);
    end record;

    --! MAC TIMER type
    type tDutMacTimer is record
        chipselect  : std_logic;
        write       : std_logic;
        read        : std_logic;
        waitrequest : std_logic;
        address     : std_logic_vector(cMacTimerAddrWidth-1 downto 0);
        writedata   : std_logic_vector(cMacTimerDataWidth-1 downto 0);
        readdata    : std_logic_vector(cMacTimerDataWidth-1 downto 0);
    end record;

    --! MAC PACKET BUFFER type
    type tDutMacPktBuf is record
        chipselect  : std_logic;
        write       : std_logic;
        read        : std_logic;
        waitrequest : std_logic;
        byteenable  : std_logic_vector(cPktBufDataWidth/cByteLength-1 downto 0);
        address     : std_logic_vector(gPacketBufferLog2Size-1 downto 0);
        writedata   : std_logic_vector(cPktBufDataWidth-1 downto 0);
        readdata    : std_logic_vector(cPktBufDataWidth-1 downto 0);
    end record;

    --! MAC DMA type
    type tDutMacDma is record
        write           : std_logic;
        read            : std_logic;
        waitrequest     : std_logic;
        readdatavalid   : std_logic;
        byteenable      : std_logic_vector(gDmaDataWidth/cByteLength-1 downto 0);
        address         : std_logic_vector(gDmaAddrWidth-1 downto 0);
        burstcount      : std_logic_vector(gDmaBurstCountWidth-1 downto 0);
        burstcounter    : std_logic_vector(gDmaBurstCountWidth-1 downto 0);
        writedata       : std_logic_vector(gDmaDataWidth-1 downto 0);
        readdata        : std_logic_vector(gDmaDataWidth-1 downto 0);
    end record;

    --! Interrupt type
    type tDutInterrupt is record
        timer   : std_logic;
        tx      : std_logic;
        rx      : std_logic;
    end record;

    --! RMII phy port type
    type tDutRmiiPhy is record
        rx      : tRmiiPathArray(gPhyPortCount-1 downto 0);
        rxError : std_logic_vector(gPhyPortCount-1 downto 0);
        tx      : tRmiiPathArray(gPhyPortCount-1 downto 0);
    end record;

    --! MII phy port type
    type tDutMiiPhy is record
        rx      : tMiiPathArray(gPhyPortCount-1 downto 0);
        rxError : std_logic_vector(gPhyPortCount-1 downto 0);
        rxClk   : std_logic_vector(gPhyPortCount-1 downto 0);
        tx      : tMiiPathArray(gPhyPortCount-1 downto 0);
        txClk   : std_logic_vector(gPhyPortCount-1 downto 0);
    end record;

    --! Phy management type
    type tDutPhyMgmt is record
        nPhyRst         : std_logic_vector(gSmiPortCount-1 downto 0);
        clk             : std_logic_vector(gSmiPortCount-1 downto 0);
        data_outEnable  : std_logic;
        data_out        : std_logic_vector(gSmiPortCount-1 downto 0);
        data_in         : std_logic_vector(gSmiPortCount-1 downto 0);
    end record;

    --! Other port type
    type tDutOther is record
        activity    : std_logic;
        timer       : std_logic_vector(gTimerCount-1 downto 0);
    end record;

    ---------------------------------------------------------------------------
    -- DUT port mapping instances
    --! Clock and reset instance
    signal dut_clkRst       : tDutClkRst;
   --! MAC REG instance
    signal dut_macReg       : tDutMacReg;
    --! MAC TIMER instance
    signal dut_macTimer     : tDutMacTimer;
    --! MAC PACKET BUFFER instance
    signal dut_macPktBuf    : tDutMacPktBuf;
    --! MAC DMA instance
    signal dut_macDma       : tDutMacDma;
    --! Interrupt instance
    signal dut_interrupt    : tDutInterrupt;
    --! RMII phy port instance
    signal dut_RmiiPhy      : tDutRmiiPhy;
    --! MII phy port instance
    signal dut_MiiPhy       : tDutMiiPhy;
    --! Phy management instance
    signal dut_PhyMgmt      : tDutPhyMgmt;
    --! Other port instance
    signal dut_other        : tDutOther;
begin
    ---------------------------------------------------------------------------
    -- Simulation control
    ---------------------------------------------------------------------------
    assert (stim_macReg.error /= cActivated)
    report "MAC REG tester hit error state!"
    severity failure;

    assert (stim_macTimer.error /= cActivated)
    report "MAC REG tester hit error state!"
    severity failure;

    assert (stim_pktBuf.error /= cActivated)
    report "PKT BUF tester hit error state!"
    severity failure;

    done    <= stim_macReg.done and stim_macTimer.done and stim_pktBuf.done;
    error   <= stim_macReg.error or stim_macTimer.error or stim_pktBuf.error;

    ---------------------------------------------------------------------------
    -- DUT and STIM mapping
    ---------------------------------------------------------------------------
    --! Assign MAC REG stimuli with DUT.
    --! Note: No bus converter is used, higher word is ignored!
    THEMACREGMAP : block
    begin
        -- bus master uses same clk and rst
        stim_macReg.rst         <= dut_clkRst.rst;
        stim_macReg.clk         <= dut_clkRst.clk;

        -- assign dut signals
        dut_macReg.address      <=  stim_macReg.address(dut_macReg.address'range);
        dut_macReg.byteenable   <=  stim_macReg.byteenable(3 downto 2) or
                                    stim_macReg.byteenable(1 downto 0);
        dut_macReg.chipselect   <=  stim_macReg.sel;
        dut_macReg.read         <=  stim_macReg.read;
        dut_macReg.write        <=  stim_macReg.write;
        dut_macReg.writedata    <=  stim_macReg.writedata(31 downto 16) or
                                    stim_macReg.writedata(15 downto 0);

        -- assign stim signals
        stim_macReg.enable      <= cActivated;
        stim_macReg.ack         <= not dut_macReg.waitrequest;
        stim_macReg.readdata    <= dut_macReg.readdata & dut_macReg.readdata;
    end block THEMACREGMAP;

    --! Assign MAC TIMER stimuli with DUT.
    THEMACTIMER : block
    begin
        -- bus master uses same clk and rst
        stim_macTimer.rst       <= dut_clkRst.rst;
        stim_macTimer.clk       <= dut_clkRst.clk;

        -- assign dut signals
        dut_macTimer.address    <= stim_macTimer.address(dut_macTimer.address'range);
        dut_macTimer.chipselect <= stim_macTimer.sel;
        dut_macTimer.read       <= stim_macTimer.read;
        dut_macTimer.write      <= stim_macTimer.write;
        dut_macTimer.writedata  <= stim_macTimer.writedata;

        -- assign stim signals
        stim_macTimer.enable    <= cActivated;
        stim_macTimer.ack       <= not dut_macTimer.waitrequest;
        stim_macTimer.readdata  <= dut_macTimer.readdata;
    end block THEMACTIMER;

    --! Assign MAC DMA stimuli with DUT.
    THEMACDMA : block
    begin
        dut_macDma.waitrequest      <= cnInactivated;
        dut_macDma.readdata         <= (others => cInactivated);
        dut_macDma.readdatavalid    <= cInactivated;
    end block THEMACDMA;

    --! Assign Phy management stuff.
    THEPHYMGMT : block
    begin
        dut_PhyMgmt.data_in <= (others => cActivated);
    end block THEPHYMGMT;

    --! Assign RMII ports.
    THERMIIPORTS : block
    begin
        GEN_RMIIPORTS : for i in gPhyPortCount-1 downto 0 generate
            dut_RmiiPhy.rx(i).enable    <= cInactivated;
            dut_RmiiPhy.rx(i).data      <= (others => cInactivated);
            dut_RmiiPhy.rxError(i)      <= cInactivated;
        end generate GEN_RMIIPORTS;
    end block THERMIIPORTS;

    --! Assign MII ports.
    THEMIIPORTS : block
    begin
        GEN_MIIPORTS : for i in gPhyPortCount-1 downto 0 generate
            dut_MiiPhy.rx(i).enable <= cInactivated;
            dut_MiiPhy.rx(i).data   <= (others => cInactivated);
            dut_MiiPhy.rxError(i)   <= cInactivated;
            dut_MiiPhy.rxClk(i)     <= cInactivated; --TODO: assign 25 MHz clock here
            dut_MiiPhy.txClk(i)     <= cInactivated; --TODO: assign 25 MHz clock here
        end generate GEN_MIIPORTS;
    end block THEMIIPORTS;

    --! Assign PKT BUF stimuli with DUT
    THEPKTBUFMAP : block
    begin
        -- bus master uses same clk and rst
        stim_pktBuf.rst         <= dut_clkRst.pktBufRst;
        stim_pktBuf.clk         <= dut_clkRst.pktBufClk;

        -- assign dut signals
        dut_macPktBuf.address       <=  stim_pktBuf.address(dut_macPktBuf.address'range);
        dut_macPktBuf.byteenable    <=  stim_pktBuf.byteenable;
        dut_macPktBuf.chipselect    <=  stim_pktBuf.sel;
        dut_macPktBuf.read          <=  stim_pktBuf.read;
        dut_macPktBuf.write         <=  stim_pktBuf.write;
        dut_macPktBuf.writedata     <=  stim_pktBuf.writedata;

        -- assign stim signals
        stim_pktBuf.enable      <= cActivated;
        stim_pktBuf.ack         <= not dut_macPktBuf.waitrequest;
        stim_pktBuf.readdata    <= dut_macPktBuf.readdata;
    end block THEPKTBUFMAP;

    ---------------------------------------------------------------------------
    --! Clock generator for dut_clkRst.clk
    THECLK : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_clk
        )
        port map (
            oClk    => dut_clkRst.clk,
            iDone   => done
        );

    --! Clock generator for dut_clkRst.clk2x
    THECLK2X : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_clk2x
        )
        port map (
            oClk    => dut_clkRst.clk2x,
            iDone   => done
        );

    --! Clock generator for dut_clkRst.dmaClk
    THEDMACLK : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_dmaClk
        )
        port map (
            oClk    => dut_clkRst.dmaClk,
            iDone   => done
        );

    --! Clock generator for dut_clkRst.pktBufClk
    THEPKTBUFCLK : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_pktBufClk
        )
        port map (
            oClk    => dut_clkRst.pktBufClk,
            iDone   => done
        );

    --! Generate dut_clkRst.rst signal
    THERST : dut_clkRst.rst                 <=  cActivated,
                                                cInactivated after cResetTime;

    --! Generate dut_clkRst.dmaRst signal
    THEDMARST : dut_clkRst.dmaRst           <=  cActivated,
                                                cInactivated after cResetTime;

    --! Generate dut_clkRst.pktBufRst signal
    THEPKTBUFRST : dut_clkRst.pktBufRst     <=  cActivated,
                                                cInactivated after cResetTime;

    ---------------------------------------------------------------------------
    --! The bus master for dut_macReg
    THEMACREGBUSMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStimFileMacReg
        )
        port map (
            iRst        => stim_macReg.rst,
            iClk        => stim_macReg.clk,
            iEnable     => stim_macReg.enable,
            iAck        => stim_macReg.ack,
            iReaddata   => stim_macReg.readdata,
            oWrite      => stim_macReg.write,
            oRead       => stim_macReg.read,
            oSelect     => stim_macReg.sel,
            oAddress    => stim_macReg.address,
            oByteenable => stim_macReg.byteenable,
            oWritedata  => stim_macReg.writedata,
            oError      => stim_macReg.error,
            oDone       => stim_macReg.done
        );

    ---------------------------------------------------------------------------
    --! The bus master for dut_pktBuf
    THEPKTBUFBUSMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cPktBufDataWidth,
            gStimuliFile    => gStimFilePktBuf
        )
        port map (
            iRst        => stim_pktBuf.rst,
            iClk        => stim_pktBuf.clk,
            iEnable     => stim_pktBuf.enable,
            iAck        => stim_pktBuf.ack,
            iReaddata   => stim_pktBuf.readdata,
            oWrite      => stim_pktBuf.write,
            oRead       => stim_pktBuf.read,
            oSelect     => stim_pktBuf.sel,
            oAddress    => stim_pktBuf.address,
            oByteenable => stim_pktBuf.byteenable,
            oWritedata  => stim_pktBuf.writedata,
            oError      => stim_pktBuf.error,
            oDone       => stim_pktBuf.done
        );

    ---------------------------------------------------------------------------
    --! The bus master for dut_macTimer
    THEMACTIMERBUSMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cMacTimerDataWidth,
            gStimuliFile    => gStimFileMacTimer
        )
        port map (
            iRst        => stim_macTimer.rst,
            iClk        => stim_macTimer.clk,
            iEnable     => stim_macTimer.enable,
            iAck        => stim_macTimer.ack,
            iReaddata   => stim_macTimer.readdata,
            oWrite      => stim_macTimer.write,
            oRead       => stim_macTimer.read,
            oSelect     => stim_macTimer.sel,
            oAddress    => stim_macTimer.address,
            oByteenable => stim_macTimer.byteenable,
            oWritedata  => stim_macTimer.writedata,
            oError      => stim_macTimer.error,
            oDone       => stim_macTimer.done
        );

    ---------------------------------------------------------------------------
    --! The DUT
    THEDUT : entity work.openmacTop
    generic map (
        gPhyPortCount           => gPhyPortCount,
        gPhyPortType            => gPhyPortType,
        gSmiPortCount           => gSmiPortCount,
        gEndianness             => gEndianness,
        gEnableActivity         => gEnableActivity,
        gEnableDmaObserver      => gEnableDmaObserver,
        gDmaAddrWidth           => gDmaAddrWidth,
        gDmaDataWidth           => gDmaDataWidth,
        gDmaBurstCountWidth     => gDmaBurstCountWidth,
        gDmaWriteBurstLength    => gDmaWriteBurstLength,
        gDmaReadBurstLength     => gDmaReadBurstLength,
        gDmaWriteFifoLength     => gDmaWriteFifoLength,
        gDmaReadFifoLength      => gDmaReadFifoLength,
        gPacketBufferLocTx      => gPacketBufferLocTx,
        gPacketBufferLocRx      => gPacketBufferLocRx,
        gPacketBufferLog2Size   => gPacketBufferLog2Size,
        gTimerCount             => gTimerCount,
        gTimerEnablePulseWidth  => gTimerEnablePulseWidth,
        gTimerPulseRegWidth     => gTimerPulseRegWidth
    )
    port map (
        iClk                    => dut_clkRst.clk,
        iRst                    => dut_clkRst.rst,
        iDmaClk                 => dut_clkRst.dmaClk,
        iDmaRst                 => dut_clkRst.dmaRst,
        iPktBufClk              => dut_clkRst.pktBufClk,
        iPktBufRst              => dut_clkRst.pktBufRst,
        iClk2x                  => dut_clkRst.clk2x,
        iMacReg_chipselect      => dut_macReg.chipselect,
        iMacReg_write           => dut_macReg.write,
        iMacReg_read            => dut_macReg.read,
        oMacReg_waitrequest     => dut_macReg.waitrequest,
        iMacReg_byteenable      => dut_macReg.byteenable,
        iMacReg_address         => dut_macReg.address,
        iMacReg_writedata       => dut_macReg.writedata,
        oMacReg_readdata        => dut_macReg.readdata,
        iMacTimer_chipselect    => dut_macTimer.chipselect,
        iMacTimer_write         => dut_macTimer.write,
        iMacTimer_read          => dut_macTimer.read,
        oMacTimer_waitrequest   => dut_macTimer.waitrequest,
        iMacTimer_address       => dut_macTimer.address,
        iMacTimer_writedata     => dut_macTimer.writedata,
        oMacTimer_readdata      => dut_macTimer.readdata,
        iPktBuf_chipselect      => dut_macPktBuf.chipselect,
        iPktBuf_write           => dut_macPktBuf.write,
        iPktBuf_read            => dut_macPktBuf.read,
        oPktBuf_waitrequest     => dut_macPktBuf.waitrequest,
        iPktBuf_byteenable      => dut_macPktBuf.byteenable,
        iPktBuf_address         => dut_macPktBuf.address,
        iPktBuf_writedata       => dut_macPktBuf.writedata,
        oPktBuf_readdata        => dut_macPktBuf.readdata,
        oDma_write              => dut_macDma.write,
        oDma_read               => dut_macDma.read,
        iDma_waitrequest        => dut_macDma.waitrequest,
        iDma_readdatavalid      => dut_macDma.readdatavalid,
        oDma_byteenable         => dut_macDma.byteenable,
        oDma_address            => dut_macDma.address,
        oDma_burstcount         => dut_macDma.burstcount,
        oDma_burstcounter       => dut_macDma.burstcounter,
        oDma_writedata          => dut_macDma.writedata,
        iDma_readdata           => dut_macDma.readdata,
        oMacTimer_interrupt     => dut_interrupt.timer,
        oMacTx_interrupt        => dut_interrupt.tx,
        oMacRx_interrupt        => dut_interrupt.rx,
        iRmii_Rx                => dut_RmiiPhy.rx,
        iRmii_RxError           => dut_RmiiPhy.rxError,
        oRmii_Tx                => dut_RmiiPhy.tx,
        iMii_Rx                 => dut_MiiPhy.rx,
        iMii_RxError            => dut_MiiPhy.rxError,
        iMii_RxClk              => dut_MiiPhy.rxClk,
        oMii_Tx                 => dut_MiiPhy.tx,
        iMii_TxClk              => dut_MiiPhy.txClk,
        onPhy_reset             => dut_PhyMgmt.nPhyRst,
        oSmi_clk                => dut_PhyMgmt.clk,
        oSmi_data_outEnable     => dut_PhyMgmt.data_outEnable,
        oSmi_data_out           => dut_PhyMgmt.data_out,
        iSmi_data_in            => dut_PhyMgmt.data_in,
        oActivity               => dut_other.activity,
        oMacTimer               => dut_other.timer
    );
end bhv;
