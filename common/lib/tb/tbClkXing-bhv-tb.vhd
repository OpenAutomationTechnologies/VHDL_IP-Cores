-------------------------------------------------------------------------------
--! @file tbClkXingBhv.vhd
--
--! @brief Clock crossing testbench
--
--! @details The testbench verifies the clock xing ipcore.
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

entity tbClkXing is
    generic (
        --! Stimuli file
        gStimFile : string := "stim.txt"
    );
end entity;

architecture bhv of tbClkXing is
    --! Address width of bus master
    constant cBusMasterAddrWidth    : natural := 1;
    --! Data width of bus master
    constant cBusMasterDataWidth    : natural := 32;
    --! Chipselect width
    constant cCsWidth               : natural := 1;

    --! Type for dut connection (one port)
    type tDut is record
        rst             : std_logic;
        fastClk         : std_logic;
        fastCs          : std_logic_vector(cCsWidth-1 downto 0);
        fastRnw         : std_logic;
        fastReaddata    : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        fastWrAck       : std_logic;
        fastRdAck       : std_logic;
        slowClk         : std_logic;
        slowCs          : std_logic_vector(cCsWidth-1 downto 0);
        slowRnw         : std_logic;
        slowReaddata    : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        slowWrAck       : std_logic;
        slowRdAck       : std_logic;
    end record;
    --! Type for stimuli connection
    type tStim is record
        clk         : std_logic;
        write       : std_logic;
        read        : std_logic;
        sel         : std_logic;
        address     : std_logic_vector(cBusMasterAddrWidth-1 downto 0);
        byteenable  : std_logic_vector(cBusMasterDataWidth/8-1 downto 0);
        writedata   : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        readdata    : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        ack         : std_logic;
    end record;

    --! Clock
    signal clk      : std_logic;
    --! Faster clock
    signal clkx2    : std_logic;
    --! Reset
    signal rst      : std_logic;
    --! Simulation done
    signal done     : std_logic;
    --! Simulation error
    signal error    : std_logic;

    --! DUT
    signal dut      : tDut;
    --! Stim port
    signal stim     : tStim;
begin
    assert (error /= cActivated)
    report "Bus master reports error due to assertion!"
    severity failure;

    ---------------------------------------------------------------------------
    -- Mapping
    ---------------------------------------------------------------------------
    dut.fastClk         <= clkx2;
    dut.slowClk         <= clk;
    dut.fastCs(0)       <= stim.sel;
    dut.fastRnw         <= stim.read;
    dut.slowReaddata    <= x"1234ABCD";

    stim.clk            <= clkx2;
    stim.ack            <= dut.fastRdAck or dut.fastWrAck;
    stim.readdata       <= dut.fastReaddata;

    ---------------------------------------------------------------------------
    -- Ack generators
    ---------------------------------------------------------------------------
    genAck : process(rst, clk)
    begin
        if rst = cActivated then
            dut.slowRdAck   <= cInactivated;
            dut.slowWrAck   <= cInactivated;
        elsif rising_edge(clk) then
            -- defaults to generate clock pulse
            dut.slowRdAck   <= cInactivated;
            dut.slowWrAck   <= cInactivated;

            if dut.slowCs(0) = cActivated then
                if dut.slowRnw = cActivated then
                    dut.slowRdAck <= cActivated;
                else
                    dut.slowWrAck <= cActivated;
                end if;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Instances
    ---------------------------------------------------------------------------
    --! The Dut
    theDUT : entity libcommon.clkxing
        generic map (
            gCsNum      => cCsWidth,
            gDataWidth  => cBusMasterDataWidth
        )
        port map (
            iArst           => rst,
            iFastClk        => dut.fastClk,
            iFastCs         => dut.fastCs,
            iFastRNW        => dut.fastRnw,
            oFastReaddata   => dut.fastReaddata,
            oFastWrAck      => dut.fastWrAck,
            oFastRdAck      => dut.fastRdAck,
            iSlowClk        => dut.slowClk,
            oSlowCs         => dut.slowCs,
            oSlowRNW        => dut.slowRnw,
            iSlowReaddata   => dut.slowReaddata,
            iSlowWrAck      => dut.slowWrAck,
            iSlowRdAck      => dut.slowRdAck
        );

    --! The testbench stimuli is done by the bus master.
    theSTIM : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddrWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStimFile
        )
        port map (
            iRst        => rst,
            iClk        => stim.clk,
            iEnable     => cActivated,
            iAck        => stim.ack,
            iReaddata   => stim.readdata,
            oWrite      => stim.write,
            oRead       => stim.read,
            oSelect     => stim.sel,
            oAddress    => stim.address,
            oByteenable => stim.byteenable,
            oWritedata  => stim.writedata,
            oError      => error,
            oDone       => done
        );

    theClkGen : entity libutil.clkGen
        generic map (
            gPeriod => 20 ns
        )
        port map (
            iDone => done,
            oClk => clk
        );

    theFasterClkGen : entity libutil.clkGen
        generic map (
            gPeriod => 10 ns
        )
        port map (
            iDone => done,
            oClk => clkx2
        );

    theRstGen : entity libutil.resetGen
        generic map (
            gResetTime => 100 ns
        )
        port map (
            oReset => rst,
            onReset => open
        );
end architecture;
