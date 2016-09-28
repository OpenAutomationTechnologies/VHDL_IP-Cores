-------------------------------------------------------------------------------
--! @file tbAtomicmodifyBhv.vhd
--
--! @brief Triple Bridge testbench
--
--! @details The testbench verifies if the triple bridge operates correctly.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Common library
library libcommon;
--! Use common library global package
use libcommon.global.all;

--! Utility library
library libutil;

entity tbAtomicmodify is
    generic (
        gStim : string := "stimFile.txt"
    );
end tbAtomicmodify;

architecture bhv of tbAtomicmodify is
    signal clk              : std_logic;
    signal rst              : std_logic;
    signal done             : std_logic;
    signal error            : std_logic := cInactivated;

    constant cMemoryAddressWidth    : natural := 5;
    constant cMemoryDataWidth       : natural := 32;
    constant cBusMasterAddressWidth : natural := cMemoryAddressWidth;
    constant cBusMasterDataWidth    : natural := 32;

    -- dut ports
    type tDut is record
        mstAddress      : std_logic_vector(cMemoryAddressWidth-1 downto 0);
        mstByteenable   : std_logic_vector(3 downto 0);
        mstRead         : std_logic;
        mstReaddata     : std_logic_vector(31 downto 0);
        mstWrite        : std_logic;
        mstWritedata    : std_logic_vector(31 downto 0);
        mstWaitrequest  : std_logic;
        mstAck          : std_logic;
        mstLock         : std_logic;
        slvAddress      : std_logic_vector(cMemoryAddressWidth-1 downto 2);
        slvByteenable   : std_logic_vector(3 downto 0);
        slvRead         : std_logic;
        slvReaddata     : std_logic_vector(31 downto 0);
        slvWrite        : std_logic;
        slvWritedata    : std_logic_vector(31 downto 0);
        slvWaitrequest  : std_logic;
    end record;

    signal dut : tDut;

    -- bus master ports
    type tBusMaster is record
        enable     : std_logic;
        ack        : std_logic;
        readdata   : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        write      : std_logic;
        read       : std_logic;
        sel        : std_logic;
        address    : std_logic_vector(cBusMasterAddressWidth-1 downto 0);
        byteenable : std_logic_vector(cBusMasterDataWidth/8-1 downto 0);
        writedata  : std_logic_vector(cBusMasterDataWidth-1 downto 0);
        error      : std_logic;
        done       : std_logic;
    end record;

    signal busMasterPort : tBusMaster;
begin
    assert (error = cInactivated)
    report "Atomic modify ipcore is faulty! That's not good :("
    severity failure;

    done <= busMasterPort.done;
    busMasterPort.enable <= cActivated;

    -- Connect dut with stimuli
    dut.slvAddress      <= busMasterPort.address(dut.slvAddress'range);
    dut.slvByteenable   <= busMasterPort.byteenable;
    dut.slvRead         <= busMasterPort.read;
    dut.slvWrite        <= busMasterPort.write;
    dut.slvWritedata    <= busMasterPort.writedata;

    busMasterPort.readdata <= dut.slvReaddata;
    busMasterPort.ack      <= not dut.slvWaitrequest;

    dut.mstWaitrequest <= not dut.mstAck;

    process(rst, dut)
    begin
        if rst = cInactivated then
            if dut.mstLock = cInactivated and dut.mstRead = cActivated then
                assert (FALSE)
                report "Atomic modify ipcore forgot to lock!"
                severity failure;
            end if;
        end if;
    end process;

    theDUT : entity work.atomicmodify
        generic map (
            gAddrWidth => cMemoryAddressWidth
        )
        port map (
            iClk                => clk,
            iRst                => rst,
            oMst_address        => dut.mstAddress,
            oMst_byteenable     => dut.mstByteenable,
            oMst_read           => dut.mstRead,
            iMst_readdata       => dut.mstReaddata,
            oMst_write          => dut.mstWrite,
            oMst_writedata      => dut.mstWritedata,
            iMst_waitrequest    => dut.mstWaitrequest,
            oMst_lock           => dut.mstLock,
            iSlv_address        => dut.slvAddress,
            iSlv_byteenable     => dut.slvByteenable,
            iSlv_read           => dut.slvRead,
            oSlv_readdata       => dut.slvReaddata,
            iSlv_write          => dut.slvWrite,
            iSlv_writedata      => dut.slvWritedata,
            oSlv_waitrequest    => dut.slvWaitrequest
        );

    theBusMaster : entity libutil.busMaster
        generic map (
            gAddrWidth      => cBusMasterAddressWidth,
            gDataWidth      => cBusMasterDataWidth,
            gStimuliFile    => gStim
        )
        port map (
            iRst        => rst,
            iClk        => clk,
            iEnable     => busMasterPort.enable,
            iAck        => busMasterPort.ack,
            iReaddata   => busMasterPort.readdata,
            oWrite      => busMasterPort.write,
            oRead       => busMasterPort.read,
            oSelect     => busMasterPort.sel,
            oAddress    => busMasterPort.address,
            oByteenable => busMasterPort.byteenable,
            oWritedata  => busMasterPort.writedata,
            oError      => busMasterPort.error,
            oDone       => busMasterPort.done
        );

    theRam : entity libutil.spRam
        generic map (
            gDataWidth  => cMemoryDataWidth,
            gAddrWidth  => cMemoryAddressWidth-2
        )
        port map (
            iRst        => rst,
            iClk        => clk,
            iWrite      => dut.mstWrite,
            iRead       => dut.mstRead,
            iAddress    => dut.mstAddress(cMemoryAddressWidth-1 downto 2),
            iByteenable => dut.mstByteenable,
            iWritedata  => dut.mstWritedata,
            oReaddata   => dut.mstReaddata,
            oAck        => dut.mstAck
        );

    theClkGen : entity libutil.clkGen
        generic map (
            gPeriod     => 10 ns
        )
        port map (
            iDone       => done,
            oClk        => clk
        );

    theRstGen : entity libutil.resetGen
        generic map (
            gResetTime  => 100 ns
        )
        port map (
            oReset      => rst,
            onReset     => open
        );
end bhv;
