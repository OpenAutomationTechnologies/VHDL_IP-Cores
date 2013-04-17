-------------------------------------------------------------------------------
--! @file tbClkXingBhv.vhd
--
--! @brief Clock Crossing Bus converter Testbench
--
--! @details 
--
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

entity tbClkXing is
end entity;

architecture bhv of tbClkXing is
    signal clk50, clk100 : std_logic;
    signal rst : std_logic;
    signal fastCs : std_logic_vector(1 downto 0);
    signal fastReaddata : std_logic_vector(31 downto 0);
    signal fastWrAck, fastRdAck, fastRNW : std_logic;
    signal slowCs : std_logic_vector(1 downto 0);
    signal slowRNW : std_logic;
    signal slowReaddata : std_logic_vector(31 downto 0);
    signal slowWrAck, slowRdAck : std_logic;
begin

    process
    begin
        clk100 <= '1';
        wait for 5 ns;
        clk100 <= '0';
        wait for 5 ns;
    end process;
    
    process
    begin
        clk50 <= '1';
        wait for 10 ns;
        clk50 <= '0';
        wait for 10 ns;
    end process;
    
    process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;

    DUT : entity work.clkXing
    generic map (
        gCsNum => 2,
        gDataWidth => 32
    )
    port map (
        iArst => rst,
        iFastClk => clk100,
        iFastCs => fastCs,
        iFastRNW => fastRNW,
        oFastReaddata => fastReaddata,
        oFastWrAck => fastWrAck,
        oFastRdAck => fastRdAck,
        iSlowClk => clk50,
        oSlowCs => slowCs,
        oSlowRNW => slowRNW,
        iSlowReaddata => slowReaddata,
        iSlowWrAck => slowWrAck,
        iSlowRdAck => slowRdAck
    );
    
    fastCs <=       "00",
                    "10" after 200 ns,
                    "00" after 640 ns,
                    "01" after 690 ns,
                    "10" after 860 ns,
                    "00" after 1100 ns;
    
    fastRNW <=      '0',
                    '1' after 200 ns,
                    '0' after 640 ns;
    
    slowReaddata <= x"1234_ABCD",
                    x"6666_6666" after 560 ns;
    
    slowRdAck <=    '0',
                    '1' after 301 ns,
                    '0' after 321 ns,
                    '1' after 561 ns,
                    '0' after 581 ns;
    
    slowWrAck <=    '0',
                    '1' after 781 ns,
                    '0' after 801 ns,
                    '1' after 1021 ns,
                    '0' after 1041 ns;

end architecture;
