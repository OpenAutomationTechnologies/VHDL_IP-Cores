-------------------------------------------------------------------------------
--! @file registerFileRtl.vhd
--
--! @brief Register table file implementation
--
--! @details This implementation is a simple dual ported memory implemented in
--! using register resources.
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

entity registerFile is
    generic (
        gRegCount       : natural := 8
        );
    port (
        iClk        :   in std_logic;
        iRst        :   in std_logic;
        iWriteA     :   in std_logic;
        iWriteB     :   in std_logic;
        iByteenableA:   in std_logic_vector;
        iByteenableB:   in std_logic_vector;
        iAddrA      :   in std_logic_vector(LogDualis(gRegCount)-1 downto 0);
        iAddrB      :   in std_logic_vector(LogDualis(gRegCount)-1 downto 0);
        iWritedataA :   in std_logic_vector;
        oReaddataA  :   out std_logic_vector;
        iWritedataB :   in std_logic_vector;
        oReaddataB  :   out std_logic_vector
        );
end registerFile;

architecture Rtl of registerFile is
    constant cByte : natural := 8;
    type tRegSet is
    array (natural range <>) of std_logic_vector(iWritedataA'range);

    signal regFile, regFile_next : tRegSet(gRegCount-1 downto 0);

begin

    --register set
    reg : process(iClk)
    begin
        if rising_edge(iClk) then
            if iRst = cActivated then
                --clear register file
                regFile <= (others => (others => '0'));
            else
                regFile <= regFile_next;
            end if;
        end if;
    end process;

    --write data into Register File with respect to address
    --note: a overrules b
    regFileWrite : process(
        iWriteA, iWriteB, iAddrA, iAddrB,
        iByteenableA, iByteenableB,
        iWritedataA, iWritedataB, regFile)

        variable vWritedata : std_logic_vector(iWritedataA'range);
    begin
        --default
        regFile_next <= regFile;
        vWritedata := (others => cInactivated);

        if iWriteB = cActivated then
            --read out register content first
            vWritedata := regFile(to_integer(unsigned(iAddrB)));

            --then consider byteenable
            for i in iWritedataB'range loop
                if iByteenableB(i/cByte) = cActivated then
                    --if byte is enabled assign it
                    vWritedata(i) := iWritedataB(i);
                end if;
            end loop;

            --write to address the masked writedata
            regFile_next(to_integer(unsigned(iAddrB))) <= vWritedata;
        end if;

        if iWriteA = cActivated then
            --read out register content first
            vWritedata := regFile(to_integer(unsigned(iAddrA)));

            --then consider byteenable
            for i in iWritedataA'range loop
                if iByteenableA(i/cByte) = cActivated then
                    --if byte is enabled assign it
                    vWritedata(i) := iWritedataA(i);
                end if;
            end loop;

            --write to address the masked writedata
            regFile_next(to_integer(unsigned(iAddrA))) <= vWritedata;
        end if;
    end process;

    --read data from Register File with respect to iAddrRead
    regFileRead : process(iAddrA, iAddrB, regFile)
    begin
        --read from address
        oReaddataA <= regFile(to_integer(unsigned(iAddrA)));
        oReaddataB <= regFile(to_integer(unsigned(iAddrB)));
    end process;

end Rtl;
