-------------------------------------------------------------------------------
--! @file spiBridgeRtl.vhd
--
--! @brief SPI to bus interface bridge
--
--! @details The SPI to bus interface bridge translates the data received at
--! SPI to master transactions.
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

entity spiBridge is
    generic (
        -- SPI slave settings
        --! SPI register size (= frame size)
        gRegisterSize   : natural := 8;
        --! SPI clock polarity (allowed values 0 and 1)
        gPolarity       : natural := 0;
        --! SPI clock phase (allowed values 0 and 1)
        gPhase          : natural := 0;
        --! Shift direction (0 = LSB first, otherwise = MSB first)
        gShiftDir       : natural := 0;
        -- Bus master settings
        --! Bus interface data width
        gBusDataWidth   : natural := 32;
        --! Bus interface address width
        gBusAddrWidth   : natural := 8;
        --! Write buffer base
        gWrBufBase      : natural := 16#00#;
        --! Write buffer size
        gWrBufSize      : natural := 128;
        --! Read buffer base
        gRdBufBase      : natural := 16#80#;
        --! Read buffer size
        gRdBufSize      : natural := 128
    );
    port (
        --! Asynchronous reset
        iArst           : in std_logic;
        --! Clock
        iClk            : in std_logic;
        -- SPI
        --! SPI clock
        iSpiClk         : in std_logic;
        --! SPI select (low-active)
        inSpiSel        : in std_logic;
        --! SPI master-out-slave-in
        iSpiMosi        : in std_logic;
        --! SPI master-in-slave-out
        oSpiMiso        : out std_logic;
        --! SPI master-in-slave-out buffer enable
        oSpiMiso_t      : out std_logic;
        -- Bus master
        --! Bus address
        oBusAddress     : out std_logic_vector(gBusAddrWidth-1 downto 0);
        --! Bus write
        oBusWrite       : out std_logic;
        --! Bus write data
        oBusWritedata   : out std_logic_vector(gBusDataWidth-1 downto 0);
        --! Bus read
        oBusRead        : out std_logic;
        --! Bus read data
        iBusReaddata    : in std_logic_vector(gBusDataWidth-1 downto 0);
        --! Bus waitrequest
        iBusWaitrequest : in std_logic
    );
end spiBridge;

architecture rtl of spiBridge is
    --! Number of first load skips
    constant cStreamSkipLoads    : natural := 3;
    --! Number of first valid skips
    constant cStreamSkipValids   : natural := 4;

    --! Load spi core
    signal load         : std_logic;
    --! Data to be loaded to spi core
    signal loadData     : std_logic_vector(gRegisterSize-1 downto 0);
    --! Valid data by spi core
    signal valid        : std_logic;
    --! Valid data provided by spi core
    signal validData    : std_logic_vector(gRegisterSize-1 downto 0);

    --! Synchronized inSpiSel
    signal nSpiSel_sync     : std_logic;
    --! Falling edge of inSpiSel
    signal spiSel_falling   : std_logic;
begin
    theProtCore : entity work.protStream
        generic map (
            gStreamDataWidth    => gRegisterSize,
            gStreamSkipLoads    => cStreamSkipLoads,
            gStreamSkipValids   => cStreamSkipValids,
            gBusDataWidth       => gBusDataWidth,
            gBusAddrWidth       => gBusAddrWidth,
            gWrBufBase          => gWrBufBase,
            gWrBufSize          => gWrBufSize,
            gRdBufBase          => gRdBufBase,
            gRdBufSize          => gRdBufSize
        )
        port map (
            iArst               => iArst,
            iClk                => iClk,
            iSrst               => spiSel_falling,
            oStreamLoad         => load,
            oStreamLoadData     => loadData,
            iStreamValid        => valid,
            iStreamValidData    => validData,
            oBusAddress         => oBusAddress,
            oBusWrite           => oBusWrite,
            oBusWritedata       => oBusWritedata,
            oBusRead            => oBusRead,
            iBusReaddata        => iBusReaddata,
            iBusWaitrequest     => iBusWaitrequest
        );

    --! Always use the asynchronous clock architecture for spi slave.
    theSpiCore : entity work.spiSlave(rtl_aclk)
        generic map (
            gRegisterSize   => gRegisterSize,
            gPolarity       => gPolarity,
            gPhase          => gPhase,
            gShiftDir       => gShiftDir
        )
        port map (
            iArst       => iArst,
            iClk        => iClk,
            iSpiClk     => iSpiClk,
            inSpiSel    => inSpiSel,
            iSpiMosi    => iSpiMosi,
            oSpiMiso    => oSpiMiso,
            oSpiMiso_t  => oSpiMiso_t,
            iLoadData   => loadData,
            iLoad       => load,
            oReadData   => validData,
            oValid      => valid
        );

    --! The synchronizer moves the spi sel into the iClk domain.
    --! The reg intialization can be inactivated, since only the falling edge
    --! is detected by theSpiSelEdgeDet.
    theSpiSelSync : entity libcommon.synchronizer
        generic map (
            gStages => 2,
            gInit   => cInactivated
        )
        port map (
            iArst   => iArst,
            iClk    => iClk,
            iAsync  => inSpiSel,
            oSync   => nSpiSel_sync
        );

    --! Detect the falling edge of the synchronized spi sel signal.
    --! The input signal is initialized to '0', however, only the falling edge
    --! is detected.
    theSpiSelEdgeDet : entity libcommon.edgedetector
        port map (
            iArst       => iArst,
            iClk        => iClk,
            iEnable     => cActivated,
            iData       => nSpiSel_sync,
            oRising     => open,
            oFalling    => spiSel_falling,
            oAny        => open
        );
end rtl;
