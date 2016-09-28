-------------------------------------------------------------------------------
--! @file tbSynchronizerBhv.vhd
--
--! @brief Synchronizer testbench
--
--! @details The testbench verifies if the synchronizer operates correctly.
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
--    3. Neither the name of the copyright holders nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without prior written permission.
--
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

entity tbSynchronizer is
end tbSynchronizer;

architecture bhv of tbSynchronizer is
    constant cStages : natural := 2;

    signal clk : std_logic;
    signal rst : std_logic;
    signal done : std_logic;
    signal error : std_logic;

    signal async : std_logic;
    signal sync : std_logic;
begin
    DUT : entity libcommon.synchronizer
        generic map (
            gStages => cStages,
            gInit => cInactivated
        )
        port map (
            iArst => rst,
            iClk => clk,
            iAsync => async,
            oSync => sync
        );

    stim : process
    begin
        done <= cInactivated;
        error <= cInactivated;
        async <= cInactivated;
        wait until rst = cInactivated;
        wait until rising_edge(clk);

        wait until falling_edge(clk);
        async <= cActivated;
        for i in 0 to cStages-1 loop
            wait until falling_edge(clk);
        end loop;

        wait until falling_edge(clk);
        assert (async = sync)
        report "Input signal does not propagate to synchronizer output in time!"
        severity failure;

        wait until rising_edge(clk);

        done <= cActivated;
        wait;
    end process;

    theClkGen : entity libutil.clkGen
        generic map (
            gPeriod => 10 ns
        )
        port map (
            iDone => done,
            oClk => clk
        );

    theRstGen : entity libutil.resetGen
        generic map (
            gResetTime => 100 ns
        )
        port map (
            oReset => rst,
            onReset => open
        );
end bhv;
