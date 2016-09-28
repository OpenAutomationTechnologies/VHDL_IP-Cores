-------------------------------------------------------------------------------
--! @file tbBinaryEncoderBhv.vhd
--
--! @brief Generic Binary Encoder testbench
--
--! @details The testbench verifies if the encoder operates correctly.
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

entity tbBinaryEncoder is
end tbBinaryEncoder;

architecture bhv of tbBinaryEncoder is
    signal clk : std_logic;
    signal rst : std_logic;
    signal done : std_logic;

    --! one hot code data width
    constant cOneHotWidth : natural := 10;

    --! StdLogicVec Array
    type tStimArray is array (natural range <>) of
        std_logic_vector(cOneHotWidth-1 downto 0);

    --! Stim array
    constant cStimArray : tStimArray(0 to 11) := (
        "0000000000",
        "0000000001",
        "0000000010",
        "0000000100",
        "0000001000",
        "0000010000",
        "0000100000",
        "0001000000",
        "0010000000",
        "0100000000",
        "1000000000",
        "0000000000"
    );

    --! function to convert one-hot-code to binary
    function oneHotToBinary (
        din : std_logic_vector;
        outSize : natural
    ) return std_logic_vector is
        variable vTmp : std_logic_vector(outSize-1 downto 0);
        variable vFoundOne : boolean;
    begin
        --initialize
        vTmp := (others => cInactivated);
        vFoundOne := false;
        for i in din'range loop
            if din(i) = cActivated then
                assert (vFoundOne = false)
                    report "One-hot code format error!" severity failure;
                vFoundOne := true;
                vTmp := std_logic_vector(to_unsigned(i, outSize));
            end if;
        end loop;
        return vTmp;
    end function;

    signal stim : std_logic_vector(cOneHotWidth-1 downto 0);
    signal stim_binary : std_logic_vector(logDualis(cOneHotWidth)-1 downto 0);
    signal res : std_logic_vector(logDualis(cOneHotWidth)-1 downto 0);
    signal cnt : natural;

    signal res_fail : boolean;
begin

    DUT : entity libcommon.binaryEncoder
        generic map (
            gDataWidth => cOneHotWidth
        )
        port map (
            iOneHot => stim,
            oBinary => res
        );

    stim <= cStimArray(cnt);
    stim_binary <= oneHotToBinary(stim, stim_binary'length);

    res_fail <= true when (rst = cInactivated and falling_edge(clk) and
                           res /= stim_binary) else
                false;

    assert not(res_fail)
        report "Binary encoding failed with input "
        & integer'IMAGE(to_integer(unsigned(stim_binary)))
        severity failure;

    assert done /= cActivated report "Simulation done" severity note;

    stimProc : process
    begin
        cnt <= 0;
        done <= cInactivated;
        wait until rst = cInactivated;
        wait until rising_edge(clk);

        for i in cStimArray'range loop
            cnt <= i;
            wait until rising_edge(clk);
        end loop;

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
