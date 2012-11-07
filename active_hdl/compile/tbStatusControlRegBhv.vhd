-------------------------------------------------------------------------------
--! @file tbStatusControlRegBhv.vhd
--
--! @brief 
--
-------------------------------------------------------------------------------
--
--    (c) B&R, 2012
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
-- Design unit header --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
--! use host interface package for specific types
use work.hostInterfacePkg.all;

entity tbStatusControlReg is 
end tbStatusControlReg;

architecture Bhv of tbStatusControlReg is

----- Architecture header declarations -----
constant cIrqSourceCount : natural := 3;


---- Component declarations -----

component busMaster
  generic(
       gAddrWidth : integer := 32;
       gDataWidth : integer := 32;
       gStimuliFile : string := "name_TB_stim.txt"
  );
  port (
       iAck : in std_logic;
       iClk : in std_logic;
       iEnable : in std_logic;
       iReaddata : in std_logic_vector(gDataWidth-1 downto 0);
       iRst : in std_logic;
       oAddress : out std_logic_vector(gAddrWidth-1 downto 0);
       oByteenable : out std_logic_vector(gDataWidth/8-1 downto 0);
       oDone : out std_logic;
       oRead : out std_logic;
       oSelect : out std_logic;
       oWrite : out std_logic;
       oWritedata : out std_logic_vector(gDataWidth-1 downto 0)
  );
end component;
component clkgen
  generic(
       gPeriod : time := 20 ns
  );
  port (
       iDone : in std_logic;
       oClk : out std_logic
  );
end component;
component enableGen
  generic(
       gEnableDelay : time := 100 ns
  );
  port (
       iReset : in std_logic;
       oEnable : out std_logic;
       onEnable : out std_logic
  );
end component;
component statusControlReg
  generic(
       gHostBaseSet : natural := 2;
       gIrqSourceCount : natural range 1 to 15 := 3;
       gMagic : natural := 1347177216;
       gPcpBaseSet : natural := 10;
       gQueueCount : natural := 7;
       gVersionCount : natural := 0;
       gVersionMajor : natural := 255;
       gVersionMinor : natural := 255;
       gVersionRevision : natural := 255
  );
  port (
       iBaseSetData : in std_logic_vector;
       iClk : in std_logic;
       iGpin : in std_logic_vector(cWord-1 downto 0);
       iHostAddress : in std_logic_vector(10 downto 2);
       iHostByteenable : in std_logic_vector(cDword/8-1 downto 0);
       iHostRead : in std_logic;
       iHostWrite : in std_logic;
       iHostWritedata : in std_logic_vector(cDword-1 downto 0);
       iIrqPending : in std_logic_vector(gIrqSourceCount downto 0);
       iNodeId : in std_logic_vector(cByte-1 downto 0);
       iPcpAddress : in std_logic_vector(10 downto 2);
       iPcpByteenable : in std_logic_vector(cDword/8-1 downto 0);
       iPcpRead : in std_logic;
       iPcpWrite : in std_logic;
       iPcpWritedata : in std_logic_vector(cDword-1 downto 0);
       iRst : in std_logic;
       oBaseSetAddress : out std_logic_vector(LogDualis(gHostBaseSet+gPcpBaseSet)+2-1 downto 2);
       oBaseSetData : out std_logic_vector;
       oBaseSetWrite : out std_logic;
       oExtSyncConfig : out std_logic_vector(cExtSyncEdgeConfigWidth-1 downto 0);
       oExtSyncEnable : out std_logic;
       oGpout : out std_logic_vector(cWord-1 downto 0);
       oHostReaddata : out std_logic_vector(cDword-1 downto 0);
       oHostWaitrequest : out std_logic;
       oIrqAcknowledge : out std_logic_vector(gIrqSourceCount downto 0);
       oIrqMasterEnable : out std_logic;
       oIrqSet : out std_logic_vector(gIrqSourceCount downto 1);
       oIrqSourceEnable : out std_logic_vector(gIrqSourceCount downto 0);
       oPLed : out std_logic_vector(1 downto 0);
       oPcpReaddata : out std_logic_vector(cDword-1 downto 0);
       oPcpWaitrequest : out std_logic;
       oState : out std_logic_vector(cWord-1 downto 0)
  );
end component;

----     Constants     -----
constant VCC_CONSTANT   : std_logic := '1';
constant GND_CONSTANT   : std_logic := '0';

---- Signal declarations used on the diagram ----

signal clk : std_logic;
signal done : std_logic;
signal doneHost : std_logic;
signal donePcp : std_logic;
signal extSyncEnable : std_logic;
signal GND : std_logic;
signal hostRead : std_logic;
signal hostWaitrequest : std_logic;
signal hostWrite : std_logic;
signal nHostWaitrequest : std_logic;
signal nPcpWaitrequest : std_logic;
signal pcpRead : std_logic;
signal pcpWaitrequest : std_logic;
signal pcpWrite : std_logic;
signal rst : std_logic;
signal VCC : std_logic;
signal baseSetReaddata : std_logic_vector (29 downto 0);
signal baseSetWritedata : std_logic_vector (31 downto 0);
signal extSyncEdgeConfig : std_logic_vector (1 downto 0);
signal gpin : std_logic_vector (15 downto 0);
signal gpout : std_logic_vector (15 downto 0);
signal hostAddress : std_logic_vector (10 downto 0);
signal hostByteenable : std_logic_vector (3 downto 0);
signal hostReaddata : std_logic_vector (31 downto 0);
signal hostWritedata : std_logic_vector (31 downto 0);
signal irqPending : std_logic_vector (cIrqSourceCount downto 0);
signal led : std_logic_vector (1 downto 0);
signal nodeId : std_logic_vector (7 downto 0);
signal pcpAddress : std_logic_vector (10 downto 0);
signal pcpByteenable : std_logic_vector (3 downto 0);
signal pcpReaddata : std_logic_vector (31 downto 0);
signal pcpWritedata : std_logic_vector (31 downto 0);

begin

---- User Signal Assignments ----
nodeId <= x"F0";
irqPending <= x"A";
gpin <= gpout;
baseSetWritedata <= x"FC0FFEE0";

----  Component instantiations  ----

DUT : statusControlReg
  generic map (
       gHostBaseSet => 2,
       gIrqSourceCount => cIrqSourceCount,
       gMagic => 1347177216,
       gPcpBaseSet => 10,
       gQueueCount => 7,
       gVersionCount => 0,
       gVersionMajor => 255,
       gVersionMinor => 255,
       gVersionRevision => 255
  )
  port map(
       iHostAddress(2) => hostAddress(2),
       iHostAddress(3) => hostAddress(3),
       iHostAddress(4) => hostAddress(4),
       iHostAddress(5) => hostAddress(5),
       iHostAddress(6) => hostAddress(6),
       iHostAddress(7) => hostAddress(7),
       iHostAddress(8) => hostAddress(8),
       iHostAddress(9) => hostAddress(9),
       iHostAddress(10) => hostAddress(10),
       iPcpAddress(2) => pcpAddress(2),
       iPcpAddress(3) => pcpAddress(3),
       iPcpAddress(4) => pcpAddress(4),
       iPcpAddress(5) => pcpAddress(5),
       iPcpAddress(6) => pcpAddress(6),
       iPcpAddress(7) => pcpAddress(7),
       iPcpAddress(8) => pcpAddress(8),
       iPcpAddress(9) => pcpAddress(9),
       iPcpAddress(10) => pcpAddress(10),
       iBaseSetData => baseSetWritedata,
       iClk => clk,
       iGpin => gpin( 15 downto 0 ),
       iHostByteenable => hostByteenable( 3 downto 0 ),
       iHostRead => hostRead,
       iHostWrite => hostWrite,
       iHostWritedata => hostWritedata( 31 downto 0 ),
       iIrqPending => irqPending( cIrqSourceCount downto 0 ),
       iNodeId => nodeId( 7 downto 0 ),
       iPcpByteenable => pcpByteenable( 3 downto 0 ),
       iPcpRead => pcpRead,
       iPcpWrite => pcpWrite,
       iPcpWritedata => pcpWritedata( 31 downto 0 ),
       iRst => rst,
       oBaseSetData => baseSetReaddata,
       oExtSyncConfig => extSyncEdgeConfig( 1 downto 0 ),
       oExtSyncEnable => extSyncEnable,
       oGpout => gpout( 15 downto 0 ),
       oHostReaddata => hostReaddata( 31 downto 0 ),
       oHostWaitrequest => hostWaitrequest,
       oPLed => led,
       oPcpReaddata => pcpReaddata( 31 downto 0 ),
       oPcpWaitrequest => pcpWaitrequest
  );

HOST : busMaster
  generic map (
       gAddrWidth => 11,
       gDataWidth => 32,
       gStimuliFile => "HOST_INTERFACE/tb/tbStatusControlReg_Host_stim.txt"
  )
  port map(
       iAck => nHostWaitrequest,
       iClk => clk,
       iEnable => VCC,
       iReaddata => hostReaddata( 31 downto 0 ),
       iRst => rst,
       oAddress => hostAddress( 10 downto 0 ),
       oByteenable => hostByteenable( 3 downto 0 ),
       oDone => doneHost,
       oRead => hostRead,
       oWrite => hostWrite,
       oWritedata => hostWritedata( 31 downto 0 )
  );

PCP : busMaster
  generic map (
       gAddrWidth => 11,
       gDataWidth => 32,
       gStimuliFile => "HOST_INTERFACE/tb/tbStatusControlReg_Pcp_stim.txt"
  )
  port map(
       iAck => nPcpWaitrequest,
       iClk => clk,
       iEnable => VCC,
       iReaddata => pcpReaddata( 31 downto 0 ),
       iRst => rst,
       oAddress => pcpAddress( 10 downto 0 ),
       oByteenable => pcpByteenable( 3 downto 0 ),
       oDone => donePcp,
       oRead => pcpRead,
       oWrite => pcpWrite,
       oWritedata => pcpWritedata( 31 downto 0 )
  );

U1 : clkgen
  port map(
       iDone => done,
       oClk => clk
  );

U2 : enableGen
  port map(
       iReset => GND,
       onEnable => rst
  );

done <= donePcp and doneHost;

nHostWaitrequest <= not(hostWaitrequest);

nPcpWaitrequest <= not(pcpWaitrequest);


---- Power , ground assignment ----

GND <= GND_CONSTANT;
VCC <= VCC_CONSTANT;

end Bhv;
