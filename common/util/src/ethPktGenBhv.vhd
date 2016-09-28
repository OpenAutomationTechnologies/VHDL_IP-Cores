-------------------------------------------------------------------------------
--! @file ethPktGenBhv.vhd
--
--! @brief Model for Ethernet packet generation
--
--! @details This model generates an Ethernet packet out of a txt file.
--
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

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

--! Common library
library libcommon;
--! Use common library global package
use libcommon.global.all;

entity ethPktGen is
    generic (
        --! Data width of output port
        gDataWidth : natural := 8
    );
    port (
        --! global clock signal
        iClk : in std_logic;
        --! global reset signal
        iRst : in std_logic;
        --! trigger the transmission of a packet
        iTrigTx : in std_logic;
        --! Ethernet packet source file
        iSrcFile : in string := "ethPacket.txt";
        --! Media Interface Enable signal
        oTxEnable : out std_logic;
        --! Media Interface Data signals
        oTxData : out std_logic_vector(gDataWidth-1 downto 0);
        --! Tx done
        oTxDone : out std_logic
    );
end entity ethPktGen;

architecture bhv of ethPktGen is

    constant cByte : natural := 8;
    constant cEthPacketMax : natural := 1526;
    type tEthPktBuf is array (natural range <>) of
                                std_logic_vector(gDataWidth-1 downto 0);
    signal ethPktBuf : tEthPktBuf(0 to cEthPacketMax * cByte/gDataWidth);
    signal ethPktSize : natural;

    signal txCnt : natural;
    signal txActive : std_logic;
begin

    genEthPkt : process(iClk, iRst)
    begin
        if iRst = cActivated then
            txCnt <= 0;
            oTxData <= (others => cInactivated);
            oTxEnable <= cInactivated;
            txActive <= cInactivated;
            oTxDone <= cInactivated;
        elsif rising_edge(iClk) then
            -- activate packet generation
            if iTrigTx = cActivated and txActive = cInactivated then
                txActive <= cActivated;
            end if;

            oTxDone <= cInactivated;

            if txActive = cActivated then
                oTxData <= ethPktBuf(txCnt);
                oTxEnable <= cActivated;
                txCnt <= txCnt + 1;
                if txCnt >= ethPktSize then
                    txActive <= cInactivated;
                    oTxData <= (others => cInactivated);
                    oTxEnable <= cInactivated;
                    txCnt <= 0;
                    oTxDone <= cActivated;
                end if;
            end if;

        end if;
    end process;

    readFile : process
        file fp : text;
        --variable vLineString : string(1 to 100);
        variable vLineNum : line;
        variable vByte : std_logic_vector(cByte-1 downto 0);
        variable vCount : natural := 0;
        variable vGood : boolean;
    begin
        wait until rising_edge(txActive);
        file_open(fp, iSrcFile, READ_MODE);
        readline(fp, vLineNum);
        READ(vLineNum, vCount);
        case gDataWidth is
            when 2 =>
                ethPktSize <= vCount * 4;
            when 4 =>
                ethPktSize <= vCount * 2;
            when 8 =>
                ethPktSize <= vCount;
            when others =>
        end case;
        vCount := 0;
        while not endfile(fp) loop
            readline(fp, vLineNum);
            HREAD(vLineNum, vByte, vGood);
            if vGood then
                case gDataWidth is
                    when 2 =>
                        ethPktBuf(vCount) <= vByte(1 downto 0);
                        vCount := vCount + 1;
                        ethPktBuf(vCount) <= vByte(3 downto 2);
                        vCount := vCount + 1;
                        ethPktBuf(vCount) <= vByte(5 downto 4);
                        vCount := vCount + 1;
                        ethPktBuf(vCount) <= vByte(7 downto 6);
                        vCount := vCount + 1;
                    when 4 =>
                        ethPktBuf(vCount) <= vByte(3 downto 0);
                        vCount := vCount + 1;
                        ethPktBuf(vCount) <= vByte(7 downto 4);
                        vCount := vCount + 1;
                    when 8 =>
                        ethPktBuf(vCount) <= vByte(7 downto 0);
                        vCount := vCount + 1;
                    when others =>
                end case;
            end if;
        end loop;
        file_close(fp);
    end process;

end architecture bhv;
