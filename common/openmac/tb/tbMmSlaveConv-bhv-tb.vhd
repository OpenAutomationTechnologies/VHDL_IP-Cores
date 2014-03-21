-------------------------------------------------------------------------------
--! @file tbMmSlaveConv-bhv-tb.vhd
--
--! @brief Testbench for memory mapped slave converter
--
--! @details This testbench verifies the memory mapped slave converter.
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

entity tbMmSlaveConv is
    generic (
        -- Stimuli file for bus master
        gStimFile : string := "file.txt"
    );
end tbMmSlaveConv;

architecture bhv of tbMmSlaveConv is
    ---------------------------------------------------------------------------
    -- Stimuli
    --! Clock period for openMAC
    constant cPeriod_clk        : time := 20 ns;
    --! Reset time
    constant cResetTime         : time := 100 ns;
    --! Simulation done
    signal done                 : std_logic;
    --! Simulation error
    signal error                : std_logic;
    --! Global clock signal
    signal clk                  : std_logic;

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

    --! Dut master data width
    constant cDutMasterDataWidth    : natural := cBusMasterDataWidth;
    --! Dut master address width
    constant cDutMasterAddressWidth : natural := 16;
    --! Dut slave data width
    constant cDutSlaveDataWidth     : natural := 16;
    --! Dut slave address width
    constant cDutSlaveAddressWidth  : natural := 16;

    --! Single port ram
    type tStimSpram is record
        rst         : std_logic;
        clk         : std_logic;
        write       : std_logic;
        read        : std_logic;
        address     : std_logic_vector(cDutSlaveAddressWidth-1 downto 0);
        byteenable  : std_logic_vector(cDutSlaveDataWidth/cByteLength-1 downto 0);
        writedata   : std_logic_vector(cDutSlaveDataWidth-1 downto 0);
        readdata    : std_logic_vector(cDutSlaveDataWidth-1 downto 0);
        ack         : std_logic;
    end record;

    --! Dut master port type
    type tDutMasterPort is record
        sel         : std_logic;
        write       : std_logic;
        read        : std_logic;
        byteenable  : std_logic_vector(cDutMasterDataWidth/cByteLength-1 downto 0);
        writedata   : std_logic_vector(cDutMasterDataWidth-1 downto 0);
        readdata    : std_logic_vector(cDutMasterDataWidth-1 downto 0);
        address     : std_logic_vector(cDutMasterAddressWidth-1 downto 0);
        writeAck    : std_logic;
        readAck     : std_logic;
    end record;

    --! Dut slave port type
    type tDutSlavePort is record
        sel         : std_logic;
        write       : std_logic;
        read        : std_logic;
        address     : std_logic_vector(cDutSlaveAddressWidth-1 downto 0);
        byteenable  : std_logic_vector(cDutSlaveDataWidth/cByteLength-1 downto 0);
        readdata    : std_logic_vector(cDutSlaveDataWidth-1 downto 0);
        writedata   : std_logic_vector(cDutSlaveDataWidth-1 downto 0);
        ack         : std_logic;
    end record;

    --! Dut type
    type tDut is record
        rst         : std_logic;
        clk         : std_logic;
        master      : tDutMasterPort;
        slave       : tDutSlavePort;
    end record;

    --! Bus master stimuli
    signal stim_busMaster   : tStimBusMaster;
    --! Single port ram stimuli
    signal stim_spram       : tStimSpram;
    --! The convert (DUT)
    signal dut_conv         : tDut;
begin
    assert (error /= cActivated)
    report "Tester hit error state!"
    severity failure;

    done    <= stim_busMaster.done;
    error   <= stim_busMaster.error;

    ---------------------------------------------------------------------------
    --! Assign instances
    ASSIGN_INST : block
    begin
        dut_conv.rst        <= cActivated, cInactivated after cResetTime;
        stim_busMaster.rst  <= cActivated, cInactivated after cResetTime;
        stim_spram.rst      <= cActivated, cInactivated after cResetTime;

        dut_conv.clk        <= clk;
        stim_busMaster.clk  <= clk;
        stim_spram.clk      <= clk;

        stim_busMaster.enable <= cActivated;

        -- map bus master to converter
        dut_conv.master.address     <= stim_busMaster.address(dut_conv.master.address'range);
        dut_conv.master.byteenable  <= stim_busMaster.byteenable;
        dut_conv.master.read        <= stim_busMaster.read;
        dut_conv.master.write       <= stim_busMaster.write;
        dut_conv.master.sel         <= stim_busMaster.sel;
        dut_conv.master.writedata   <= stim_busMaster.writedata;
        stim_busMaster.readdata     <= dut_conv.master.readdata;
        stim_busMaster.ack          <= dut_conv.master.readAck or dut_conv.master.writeAck;

        -- map converter to spram
        dut_conv.slave.readdata     <= stim_spram.readdata;
        dut_conv.slave.ack          <= stim_spram.ack;
        stim_spram.address          <= dut_conv.slave.address;
        stim_spram.byteenable       <= dut_conv.slave.byteenable;
        stim_spram.read             <= dut_conv.slave.read;
        stim_spram.write            <= dut_conv.slave.write;
        stim_spram.writedata        <= dut_conv.slave.writedata;
    end block;

    ---------------------------------------------------------------------------
    --! The DUT
    THEDUT : entity work.mmSlaveConv
        generic map (
            gEndian             => "little",
            gMasterAddrWidth    => cDutMasterAddressWidth
        )
        port map (
            iRst                => dut_conv.rst,
            iClk                => dut_conv.clk,
            iMaster_select      => dut_conv.master.sel,
            iMaster_write       => dut_conv.master.write,
            iMaster_read        => dut_conv.master.read,
            iMaster_byteenable  => dut_conv.master.byteenable,
            iMaster_writedata   => dut_conv.master.writedata,
            oMaster_readdata    => dut_conv.master.readdata,
            iMaster_address     => dut_conv.master.address,
            oMaster_WriteAck    => dut_conv.master.writeAck,
            oMaster_ReadAck     => dut_conv.master.readAck,
            oSlave_select       => dut_conv.slave.sel,
            oSlave_write        => dut_conv.slave.write,
            oSlave_read         => dut_conv.slave.read,
            oSlave_address      => dut_conv.slave.address,
            oSlave_byteenable   => dut_conv.slave.byteenable,
            iSlave_readdata     => dut_conv.slave.readdata,
            oSlave_writedata    => dut_conv.slave.writedata,
            iSlave_ack          => dut_conv.slave.ack
        );

    ---------------------------------------------------------------------------
    --! The bus master
    THEBUSMASTER : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStimFile
        )
        port map (
            iRst        => stim_busMaster.rst,
            iClk        => stim_busMaster.clk,
            iEnable     => stim_busMaster.enable,
            iAck        => stim_busMaster.ack,
            iReaddata   => stim_busMaster.readdata,
            oWrite      => stim_busMaster.write,
            oRead       => stim_busMaster.read,
            oSelect     => stim_busMaster.sel,
            oAddress    => stim_busMaster.address,
            oByteenable => stim_busMaster.byteenable,
            oWritedata  => stim_busMaster.writedata,
            oError      => stim_busMaster.error,
            oDone       => stim_busMaster.done
        );

    ---------------------------------------------------------------------------
    --! The single port RAM
    THESPRAM : entity libutil.spRam
        generic map (
            gDataWidth  => cDutSlaveDataWidth,
            gAddrWidth  => cDutSlaveAddressWidth
        )
        port map (
            iRst        => stim_spram.rst,
            iClk        => stim_spram.clk,
            iWrite      => stim_spram.write,
            iRead       => stim_spram.read,
            iAddress    => stim_spram.address,
            iByteenable => stim_spram.byteenable,
            iWritedata  => stim_spram.writedata,
            oReaddata   => stim_spram.readdata,
            oAck        => stim_spram.ack
        );

    ---------------------------------------------------------------------------
    --! Clock generator
    THECLK : entity libutil.clkGen
    generic map (
        gPeriod => cPeriod_clk
    )
    port map (
        oClk    => clk,
        iDone   => done
    );
end bhv;
