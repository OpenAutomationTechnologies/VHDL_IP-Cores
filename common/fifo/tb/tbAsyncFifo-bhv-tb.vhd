-------------------------------------------------------------------------------
--! @file tbAsyncFifo-bhv-tb.vhd
--
--! @brief Testbench for asynchronous FIFO implementation
--
--! @details This testbench uses the bus master model to write and read data
--!          to and from the asynchronous FIFO.
-------------------------------------------------------------------------------
--
--    (c) B&R, 2014
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

entity tbAsyncFifo is
    generic (
        --! Stimuli file for write port
        gStimFileWrite  : string := "file.txt";
        --! Stimuli file for read port
        gStimFileRead   : string := "file.txt";
        --! Data width of write and read port
        gDataWidth      : natural := 32;
        --! Number of words stored in fifo
        gWordSize       : natural := 8;
        --! Number of synchronizer stages
        gSyncStages     : natural := 2;
        --! Select memory resource ("ON" = memory / "OFF" = registers)
        gMemRes         : string := "ON"
    );
end tbAsyncFifo;

architecture bhv of tbAsyncFifo is
    --! Write clock period
    constant cPeriod_wrClk      : time := 10 ns;
    --! Read clock period
    constant cPeriod_rdClk      : time := 20 ns;
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
    --! Bus master address zero
    constant cBusMasterAddrZero     : std_logic_vector(cBusMasterAddrWidth-1 downto 0) :=
        (others => cInactivated);

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

    --! DUT port type
    type tDutPort is record
        clk     : std_logic;
        request : std_logic;
        data    : std_logic_vector(gDataWidth-1 downto 0);
        empty   : std_logic;
        full    : std_logic;
        usedw   : std_logic_vector(logDualis(gWordSize)-1 downto 0);
    end record;

    --! DUT type
    type tDut is record
        rst     : std_logic;
        write   : tDutPort;
        read    : tDutPort;
    end record;

--! Function to assign flags to read port
    function assignFlags (
        empty       : std_logic;
        full        : std_logic;
        usedw       : std_logic_vector(logDualis(gWordSize)-1 downto 0);
        readdata    : std_logic_vector(gDataWidth-1 downto 0);
        addr        : std_logic_vector(cBusMasterAddrWidth-1 downto 0)
    ) return std_logic_vector is
        variable vAddr_tmp  : natural := 0;
        variable vRet_tmp   : std_logic_vector(cBusMasterDataWidth-1 downto 0);
    begin
        vAddr_tmp   := to_integer(unsigned(addr));
        vRet_tmp    := (others => cInactivated);

        case vAddr_tmp is
            when 1 =>
                vRet_tmp(0) := empty;
            when 2 =>
                vRet_tmp(0) := full;
            when 3 =>
                vRet_tmp(usedw'range)   := usedw;
                vRet_tmp(usedw'left+1)  := full;
            when 4 =>
                vRet_tmp := readdata(vRet_tmp'range);
            when others =>
                NULL; -- returns zeros
        end case;

        return vRet_tmp;
    end function assignFlags;

    --! Write port stimuli
    signal stim_writePort   : tStimBusMaster;
    --! Read port stimuli
    signal stim_readPort    : tStimBusMaster;

    --! DUT instance
    signal inst_dut         : tDut;
begin
    assert (gDataWidth = 32)
    report "This testbench requires 32 bit data width!"
    severity failure;

    ---------------------------------------------------------------------------
    -- Simulation control
    ---------------------------------------------------------------------------
    assert (stim_writePort.error /= cActivated)
    report "Write port tester hit error state!"
    severity failure;

    assert (stim_readPort.error /= cActivated)
    report "Read port tester hit error state!"
    severity failure;

    done    <= stim_writePort.done and stim_readPort.done;
    error   <= stim_writePort.error or stim_readPort.error;

    ---------------------------------------------------------------------------
    -- DUT and STIM mapping
    ---------------------------------------------------------------------------
    -- DUT
    inst_dut.rst            <=  stim_readPort.rst or stim_writePort.rst;
    inst_dut.read.clk       <=  stim_readPort.clk;
    inst_dut.read.request   <=  stim_readPort.read when stim_readPort.address = cBusMasterAddrZero else
                                cInactivated;
    inst_dut.write.clk      <=  stim_writePort.clk;
    inst_dut.write.request  <=  stim_writePort.write when stim_writePort.address = cBusMasterAddrZero else
                                cInactivated;
    inst_dut.write.data     <=  stim_writePort.writedata;
    -- Read port
    stim_readPort.enable    <=  cActivated;
    stim_readPort.readdata  <=  assignFlags(
        empty       => inst_dut.read.empty,
        full        => inst_dut.read.full ,
        usedw       => inst_dut.read.usedw,
        readdata    => inst_dut.read.data,
        addr        => stim_readPort.address
    );

    -- Write port
    stim_writePort.enable   <=  cActivated;
    stim_writePort.readdata <=  assignFlags(
        empty       => inst_dut.write.empty,
        full        => inst_dut.write.full ,
        usedw       => inst_dut.write.usedw,
        readdata    => (others => cInactivated),
        addr        => stim_writePort.address
    );


    ---------------------------------------------------------------------------
    --! Clock generator for write port
    THEWRCLK : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_wrClk
        )
        port map (
            oClk    => stim_writePort.clk,
            iDone   => stim_writePort.done
        );

    --! Clock generator for read port
    THERDCLK : entity libutil.clkGen
        generic map (
            gPeriod => cPeriod_rdClk
        )
        port map (
            oClk    => stim_readPort.clk,
            iDone   => stim_readPort.done
        );

    --! Generate stim_writePort.rst
    stim_writePort.rst  <=  cActivated,
                            cInactivated after cResetTime;

    --! Generate stim_readPort.rst
    stim_readPort.rst   <=  cActivated,
                            cInactivated after cResetTime;

    ---------------------------------------------------------------------------
    --! The bus master for stim_writePort.
    THEWRITEPORTMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStimFileWrite
        )
        port map (
            iRst        => stim_writePort.rst,
            iClk        => stim_writePort.clk,
            iEnable     => stim_writePort.enable,
            iAck        => stim_writePort.ack,
            iReaddata   => stim_writePort.readdata,
            oWrite      => stim_writePort.write,
            oRead       => stim_writePort.read,
            oSelect     => stim_writePort.sel,
            oAddress    => stim_writePort.address,
            oByteenable => stim_writePort.byteenable,
            oWritedata  => stim_writePort.writedata,
            oError      => stim_writePort.error,
            oDone       => stim_writePort.done
        );

    --! The bus master for stim_readPort.
    THEREADPORTMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStimFileRead
        )
        port map (
            iRst        => stim_readPort.rst,
            iClk        => stim_readPort.clk,
            iEnable     => stim_readPort.enable,
            iAck        => stim_readPort.ack,
            iReaddata   => stim_readPort.readdata,
            oWrite      => stim_readPort.write,
            oRead       => stim_readPort.read,
            oSelect     => stim_readPort.sel,
            oAddress    => stim_readPort.address,
            oByteenable => stim_readPort.byteenable,
            oWritedata  => stim_readPort.writedata,
            oError      => stim_readPort.error,
            oDone       => stim_readPort.done
        );

    --! The read port bus master needs delay when reading.
    RDACKGEN : stim_readPort.ack <= stim_readPort.write or stim_readPort.read;

    --! The write port bus master is assigned easily.
    WRACKGEN : stim_writePort.ack <= stim_writePort.write or stim_writePort.read;

    ---------------------------------------------------------------------------
    --! The DUT
    DUT : entity work.asyncFifo
        generic map (
            gDataWidth      => gDataWidth,
            gWordSize       => gWordSize,
            gSyncStages     => gSyncStages,
            gMemRes         => gMemRes
        )
        port map (
            iAclr           => inst_dut.rst,
            iWrClk          => inst_dut.write.clk,
            iWrReq          => inst_dut.write.request,
            iWrData         => inst_dut.write.data,
            oWrEmpty        => inst_dut.write.empty,
            oWrFull         => inst_dut.write.full,
            oWrUsedw        => inst_dut.write.usedw,
            iRdClk          => inst_dut.read.clk,
            iRdReq          => inst_dut.read.request,
            oRdData         => inst_dut.read.data,
            oRdEmpty        => inst_dut.read.empty,
            oRdFull         => inst_dut.read.full,
            oRdUsedw        => inst_dut.read.usedw
        );
end bhv;
