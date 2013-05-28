-------------------------------------------------------------------------------
--! @file spRamBhv.vhd
--
--! @brief Single Port Ram Model
--
--! @details This RAM model is provided for simulation purpose only!
--! The RAM model writes data into a text file and reads it back.
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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

--! use global library
use work.global.all;

entity spRam is
    port (
        iClk : in std_logic;
        iWrite : in std_logic;
        iRead : in std_logic;
        iAddress : in std_logic_vector;
        iByteenable : in std_logic_vector;
        iWritedata : in std_logic_vector;
        oReaddata : out std_logic_vector;
        oAck : out std_logic
    );
end spRam;

architecture bhv of spRam is
    constant cDataWidth : natural := iWritedata'length;
    constant cAddrWidth : natural := iAddress'length;
    constant cByte : natural := 8;

    signal writeAck : std_logic := cInactivated;
    signal readAck : std_logic := cInactivated;

    type tStringArray is array (0 to 1) of string(1 to 11);
    constant cFileNamePing : string := "ramPing.txt";
    constant cFileNamePong : string := "ramPong.txt";
    constant cFileNameArray : tStringArray := (cFileNamePing, cFileNamePong);

    shared variable readIndex : natural := 0;
    shared variable writeIndex : natural := 1;

    constant cFileDataWidth : natural := 32;
    constant cFileAddrWidth : natural := 32;
    constant cFileTotalWidth : natural := cFileAddrWidth+cFileDataWidth;

    procedure switchPingPong (
        ping : inout natural;
        pong : inout natural
    ) is
        variable vTmp : natural;
    begin
        vTmp := ping;
        ping := pong;
        pong := vTmp;
    end procedure switchPingPong;

    procedure writeFile (
        addr : in std_logic_vector;
        data : in std_logic_vector
    ) is
        file fileWrite : text; -- open write_mode is cFileNameArray(writeIndex);
        file fileRead : text; -- open read_mode is cFileNameArray(readIndex);
        variable vReadStatus : FILE_OPEN_STATUS;
        variable vLine : line;
        variable vAddr : std_logic_vector(cFileAddrWidth-1 downto 0);
        variable vData : std_logic_vector(cFileDataWidth-1 downto 0);
        variable vWritePattern : std_logic_vector(cFileTotalWidth-1 downto 0);
        variable vReadPattern : std_logic_vector(cFileTotalWidth-1 downto 0);
        variable vReadAddr : std_logic_vector(vAddr'range);
        variable vFound : boolean := false;
    begin
        --open files
        file_open (
            status => vReadStatus,
            f => fileRead,
            External_Name => cFileNameArray(readIndex),
            Open_Kind => read_mode
        );
        file_open(fileWrite, cFileNameArray(writeIndex), write_mode);

        --build stream written to file
        vAddr := std_logic_vector(resize(unsigned(addr), vAddr'length));
        vData := std_logic_vector(resize(unsigned(data), vData'length));

        --Go through the whole file, read line by line and write back.
        --If address match, replace data.
        while vReadStatus = OPEN_OK and not endfile(fileRead) loop
            readline(fileRead, vLine);
            hread(vLine, vReadPattern);
            vReadAddr := vReadPattern(cFileTotalWidth-1 downto cFileTotalWidth-cFileAddrWidth);
            if vReadAddr = vAddr then
                --replace file entry with new data
                vWritePattern := vAddr & vData;
                vFound := true;
            else
                --write back
                vWritePattern := vReadPattern;
            end if;
            hwrite(vLine, vWritePattern);
            writeline(fileWrite, vLine);
            --stop reading
            --exit when endfile(fileRead);
        end loop;

        if not vFound then
            --pattern was not replaced, append it...
            vWritePattern := vAddr & vData;
            hwrite(vLine, vWritePattern);
            writeline(fileWrite, vLine);
        end if;
        switchPingPong(writeIndex, readIndex);
    end procedure writeFile;

    procedure readFile (
        addr : in std_logic_vector;
        data : out std_logic_vector
    ) is
        file ramFile : text open read_mode is cFileNameArray(readIndex);
        variable vLine : line;
        variable vAddr : std_logic_vector(cFileAddrWidth-1 downto 0);
        variable vReadPattern : std_logic_vector(cFileTotalWidth-1 downto 0);
        variable vReadAddr : std_logic_vector(vAddr'range);
        variable vReadData : std_logic_vector(cFileDataWidth-1 downto 0);
        variable vFound : boolean := false;
    begin
        --resize given address
        vAddr := std_logic_vector(resize(unsigned(addr), vAddr'length));

        --search through the file
        vFound := false;
        while vFound = false and not endfile(ramFile) loop
            vReadPattern := (others => cInactivated);
            readline(ramFile, vLine);
            hread(vLine, vReadPattern);
            vReadAddr := vReadPattern(cFileTotalWidth-1 downto cFileTotalWidth-cFileAddrWidth);
            vReadData := vReadPattern(vReadData'range);
            if vReadAddr = vAddr then
                vFound := true;
            end if;
        end loop;

        --return file value or zeros
        if vFound then
            data := std_logic_vector(resize(unsigned(vReadData), data'length));
        else
            data := (data'range => cInactivated);
        end if;
    end procedure readFile;
begin

    assert (cDataWidth <= cFileDataWidth) report
        "Memory data width is limited to 32 bit!" severity failure;

    assert (cAddrWidth <= cFileAddrWidth) report
        "Memory address width is limited to 32 bit!" severity failure;

    mem : process(iClk)
        variable vTmp : std_logic_vector(iWritedata'range);
    begin
        if rising_edge(iClk) then
            if iRead = cActivated then
                readFile(iAddress, vTmp);
            else
                vTmp := (vTmp'range => cInactivated);
            end if;
            oReaddata <= vTmp;

            if iWrite = cActivated then
                for i in iByteenable'range loop
                    if iByteenable(i) = cActivated then
                        vTmp((i+1)*cByte-1 downto i*cByte) :=
                            iWritedata((i+1)*cByte-1 downto i*cByte);
                    end if;
                end loop;
                writeFile(iAddress, vTmp);
            end if;
        end if;
    end process;

    oAck <= writeAck or readAck;

    readAckGen : process(iClk)
    begin
        if rising_edge(iClk) then
            readAck <= cInactivated;
            if ((iRead = cActivated and readAck = cInactivated) and
                iWrite = cInactivated) then
                readAck <= cActivated;
            end if;
        end if;
    end process;

    writeAck <= iWrite and not(iRead);
end bhv;
