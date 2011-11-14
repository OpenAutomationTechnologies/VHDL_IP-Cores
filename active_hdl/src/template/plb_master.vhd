
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity plb_master is
	
generic (
	C_MASTER_PLB_AWIDTH : integer := 32;
	C_MASTER_PLB_DWIDTH : integer := 32
);

port (
	MASTER_Clk : in std_logic;
	MASTER_Rst : in std_logic;
	MASTER_ABus : out std_logic_vector(C_MASTER_PLB_AWIDTH-1 downto 0);
	MASTER_BE : out std_logic_vector(C_MASTER_PLB_DWIDTH/8-1 downto 0);
	MASTER_RNW : out std_logic;
	MASTER_abort : out std_logic;
	MASTER_busLock : out std_logic;
	MASTER_compress : out std_logic;
	MASTER_guarded : out std_logic;
	MASTER_lockErr : out std_logic;
	MASTER_MSize : out std_logic_vector(1 downto 0);
	MASTER_ordered : out std_logic;
	MASTER_priority : out std_logic_vector(1 downto 0);
	MASTER_rdBurst : out std_logic;
	MASTER_request : out std_logic;
	MASTER_size : out std_logic_vector(3 downto 0);
	MASTER_type : out std_logic_vector(2 downto 0);
	MASTER_wrBurst : out std_logic;
	MASTER_wrDBus : out std_logic_vector(C_MASTER_PLB_DWIDTH-1 downto 0);
	MASTER_MAddrAck : in std_logic;
	MASTER_MBusy : in std_logic;
	MASTER_MErr : in std_logic;
	MASTER_MRdBTerm : in std_logic;
	MASTER_MRdDAck : in std_logic;
	MASTER_MRdDBus : in std_logic_vector(C_MASTER_PLB_DWIDTH-1 downto 0);
	MASTER_MRdWdAddr : in std_logic_vector(3 downto 0);
	MASTER_MRearbitrate : in std_logic;
	MASTER_MWrBTerm : in std_logic;
	MASTER_MWrDAck : in std_logic;
	MASTER_MSSize : in std_logic_vector(1 downto 0)
);

end plb_master;

architecture template of plb_master is
begin
	
end template;



