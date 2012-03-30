-------------------------------------------------------------------------------
-- Entity : openMAC Testbench
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
library IEEE;
use IEEE.std_logic_1164.all;

library work;
use global.all;

entity tbOpenMAC is 
end tbOpenMAC;

architecture bhv of tbOpenMAC is

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
component OpenMAC
  generic(
       HighAdr : integer := 16;
       Simulate : boolean := false;
       Timer : boolean := false;
       TxDel : boolean := false;
       TxSyncOn : boolean := false
  );
  port (
       Clk : in std_logic;
       Dma_Ack : in std_logic;
       Dma_Din : in std_logic_vector(15 downto 0);
       Hub_Rx : in std_logic_vector(1 downto 0) := "00";
       Rst : in std_logic;
       S_Adr : in std_logic_vector(10 downto 1);
       S_Din : in std_logic_vector(15 downto 0);
       S_nBe : in std_logic_vector(1 downto 0);
       Sel_Cont : in std_logic := '0';
       Sel_Ram : in std_logic := '0';
       rCrs_Dv : in std_logic;
       rRx_Dat : in std_logic_vector(1 downto 0);
       s_nWr : in std_logic := '0';
       Dma_Addr : out std_logic_vector(HighAdr downto 1);
       Dma_Dout : out std_logic_vector(15 downto 0);
       Dma_Rd_Done : out std_logic;
       Dma_Req : out std_logic;
       Dma_Req_Overflow : out std_logic;
       Dma_Rw : out std_logic;
       Dma_Wr_Done : out std_logic;
       Mac_Zeit : out std_logic_vector(31 downto 0);
       S_Dout : out std_logic_vector(15 downto 0);
       nRx_Int : out std_logic;
       nTx_BegInt : out std_logic;
       nTx_Int : out std_logic;
       rTx_Dat : out std_logic_vector(1 downto 0);
       rTx_En : out std_logic
  );
end component;
component OpenMAC_MII
  port (
       Addr : in std_logic_vector(2 downto 0);
       Clk : in std_logic;
       Data_In : in std_logic_vector(15 downto 0);
       Mii_Di : in std_logic;
       Rst : in std_logic;
       Sel : in std_logic;
       nBe : in std_logic_vector(1 downto 0);
       nWr : in std_logic;
       Data_Out : out std_logic_vector(15 downto 0);
       Mii_Clk : out std_logic;
       Mii_Do : out std_logic;
       Mii_Doe : out std_logic;
       nResetOut : out std_logic
  );
end component;
component req_ack
  generic(
       ack_delay_g : integer := 1;
       zero_delay_g : boolean := false
  );
  port (
       clk : in std_logic;
       enable : in std_logic;
       rst : in std_logic;
       ack : out std_logic
  );
end component;

---- Architecture declarations -----
-- Click here to add additional declarations --
constant cAddrwidth : integer := 32;
constant cDatawidth : integer := 16;


----     Constants     -----
constant DANGLING_INPUT_CONSTANT : std_logic := 'Z';
constant GND_CONSTANT   : std_logic := '0';

---- Signal declarations used on the diagram ----

signal ack : std_logic;
signal busMasterDone : std_logic;
signal clk50 : std_logic;
signal dmaAck : std_logic;
signal dmaReq : std_logic;
signal done : std_logic := '1';
signal enable : std_logic;
signal GND : std_logic;
signal macDone : std_logic;
signal NET799 : std_logic;
signal NET808 : std_logic;
signal nPhyRst : std_logic;
signal nWrite : std_logic;
signal read : std_logic;
signal reset : std_logic;
signal sel : std_logic;
signal selCont : std_logic;
signal selRam : std_logic;
signal selSmi : std_logic;
signal smiClk : std_logic;
signal smiDin : std_logic;
signal smiDout : std_logic;
signal smiDoutEn : std_logic;
signal txEn : std_logic;
signal write : std_logic;
signal address : std_logic_vector (cAddrwidth-1 downto 0);
signal byteenable : std_logic_vector (cDatawidth/8-1 downto 0);
signal dmaAddr : std_logic_vector (cAddrwidth-1 downto 0);
signal macReaddata : std_logic_vector (cDatawidth-1 downto 0);
signal nByteenable : std_logic_vector (1 downto 0);
signal readdata : std_logic_vector (cDatawidth-1 downto 0);
signal smiReaddata : std_logic_vector (cDatawidth-1 downto 0);
signal writedata : std_logic_vector (cDatawidth-1 downto 0);

---- Declaration for Dangling input ----
signal Dangling_Input_Signal : STD_LOGIC;

begin

---- Processes ----

Process_1 :
process
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
    macDone <= cInactivated;
    wait until falling_edge(txEn);
    macDone <= cActivated;
    wait;
end process;

Process_2 :
process
-- Section above this comment may be overwritten according to
-- "Update sensitivity list automatically" option status
-- declarations
begin
    if dmaReq = cActivated and dmaAck = cInactivated then
        dmaAck <= cActivated;
    else
        dmaAck <= cInactivated;
    end if;
    wait until rising_edge(clk50);
end process;

---- User Signal Assignments ----
--generate done signal
done <= busMasterDone and macDone;
--openMAC assignments
nByteenable <= not byteenable;
nWrite <= not write;
selRam <= sel when address (13 downto 12) = "01" else cInactivated;
selCont <= sel when address(13 downto 12) = "00" else cInactivated;
selSmi <= sel when address(13 downto 12) = "10" else cInactivated;

dmaAddr(0) <= cInactivated;

readdata <= smiReaddata when selSmi = cActivated else
				macReaddata;

----  Component instantiations  ----

DUT : OpenMAC
  generic map (
       HighAdr => cAddrwidth-1,
       Simulate => false,
       Timer => true,
       TxDel => true,
       TxSyncOn => true
  )
  port map(
       Clk => clk50,
       Dma_Din(0) => Dangling_Input_Signal,
       Dma_Din(1) => Dangling_Input_Signal,
       Dma_Din(2) => Dangling_Input_Signal,
       Dma_Din(3) => Dangling_Input_Signal,
       Dma_Din(4) => Dangling_Input_Signal,
       Dma_Din(5) => Dangling_Input_Signal,
       Dma_Din(6) => Dangling_Input_Signal,
       Dma_Din(7) => Dangling_Input_Signal,
       Dma_Din(8) => Dangling_Input_Signal,
       Dma_Din(9) => Dangling_Input_Signal,
       Dma_Din(10) => Dangling_Input_Signal,
       Dma_Din(11) => Dangling_Input_Signal,
       Dma_Din(12) => Dangling_Input_Signal,
       Dma_Din(13) => Dangling_Input_Signal,
       Dma_Din(14) => Dangling_Input_Signal,
       Dma_Din(15) => Dangling_Input_Signal,
       Dma_Ack => dmaAck,
       Dma_Addr => dmaAddr( cAddrwidth-1 downto 1 ),
       Dma_Req => dmaReq,
       rRx_Dat(0) => Dangling_Input_Signal,
       rRx_Dat(1) => Dangling_Input_Signal,
       Rst => reset,
       S_Adr(1) => address(1),
       S_Adr(2) => address(2),
       S_Adr(3) => address(3),
       S_Adr(4) => address(4),
       S_Adr(5) => address(5),
       S_Adr(6) => address(6),
       S_Adr(7) => address(7),
       S_Adr(8) => address(8),
       S_Adr(9) => address(9),
       S_Adr(10) => address(10),
       S_Din => writedata( cDatawidth-1 downto 0 ),
       S_Dout => macReaddata( cDatawidth-1 downto 0 ),
       S_nBe => nByteenable,
       Sel_Cont => selCont,
       Sel_Ram => selRam,
       rCrs_Dv => Dangling_Input_Signal,
       rTx_En => txEn,
       s_nWr => nWrite
  );

DUT2 : OpenMAC_MII
  port map(
       Addr(0) => address(1),
       Addr(1) => address(2),
       Addr(2) => address(3),
       Clk => clk50,
       Data_In => writedata( cDatawidth-1 downto 0 ),
       Data_Out => smiReaddata( cDatawidth-1 downto 0 ),
       Mii_Clk => smiClk,
       Mii_Di => smiDin,
       Mii_Do => smiDout,
       Mii_Doe => smiDoutEn,
       Rst => reset,
       Sel => selSmi,
       nBe => nByteenable,
       nResetOut => nPhyRst,
       nWr => nWrite
  );

U1 : clkgen
  generic map (
       gPeriod => 20 ns
  )
  port map(
       iDone => done,
       oClk => clk50
  );

U2 : enableGen
  generic map (
       gEnableDelay => 50 ns
  )
  port map(
       iReset => GND,
       onEnable => reset
  );

U3 : enableGen
  generic map (
       gEnableDelay => 100 ns
  )
  port map(
       iReset => reset,
       oEnable => enable
  );

U4 : busMaster
  generic map (
       gAddrWidth => cAddrwidth,
       gDataWidth => cDatawidth,
       gStimuliFile => "openMAC/tb/tbOpenMAC_stim.txt"
  )
  port map(
       iAck => ack,
       iClk => clk50,
       iEnable => enable,
       iReaddata => readdata( cDatawidth-1 downto 0 ),
       iRst => reset,
       oAddress => address( cAddrwidth-1 downto 0 ),
       oByteenable => byteenable( cDatawidth/8-1 downto 0 ),
       oDone => busMasterDone,
       oRead => read,
       oSelect => sel,
       oWrite => write,
       oWritedata => writedata( cDatawidth-1 downto 0 )
  );

U5 : req_ack
  generic map (
       ack_delay_g => 1,
       zero_delay_g => true
  )
  port map(
       ack => NET799,
       clk => clk50,
       enable => write,
       rst => reset
  );

U6 : req_ack
  generic map (
       ack_delay_g => 1,
       zero_delay_g => false
  )
  port map(
       ack => NET808,
       clk => clk50,
       enable => read,
       rst => reset
  );

ack <= NET808 or NET799;


---- Power , ground assignment ----

GND <= GND_CONSTANT;

---- Dangling input signal assignment ----

Dangling_Input_Signal <= DANGLING_INPUT_CONSTANT;

end bhv;
