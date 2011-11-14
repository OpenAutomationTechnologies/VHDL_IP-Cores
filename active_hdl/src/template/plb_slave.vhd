library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity plb_slave is

generic (
	C_SLAVE_BASEADDR : integer := 0;
	C_SLAVE_HIGHADDR : integer := 0;
	C_SLAVE_NUM_MASTERS : integer := 1;
	C_SLAVE_PLB_DWIDTH : integer := 32;
	C_SLAVE_PLB_AWIDTH : integer := 32;
	C_SLAVE_PLB_MID_WIDTH : integer := 1
);

port (
	SLAVE_Clk : in std_logic;
	SLAVE_Rst : in std_logic;
	SLAVE_addrAck : out std_logic;
	SLAVE_MErr : out std_logic_vector(C_SLAVE_NUM_MASTERS-1 downto 0);
	SLAVE_MBusy : out std_logic_vector(C_SLAVE_NUM_MASTERS-1 downto 0);
	SLAVE_rdBTerm : out std_logic;
	SLAVE_rdComp : out std_logic;
	SLAVE_rdDAck : out std_logic;
	SLAVE_rdDBus : out std_logic_vector(C_SLAVE_PLB_DWIDTH-1 downto 0);
	SLAVE_rdWdAddr : out std_logic_vector(3 downto 0);
	SLAVE_rearbitrate : out std_logic;
	SLAVE_SSize : out std_logic_vector(1 downto 0);
	SLAVE_wait : out std_logic;
	SLAVE_wrBTerm : out std_logic;
	SLAVE_wrComp : out std_logic;
	SLAVE_wrDAck : out std_logic;
	SLAVE_ABus : in std_logic_vector(C_SLAVE_PLB_AWIDTH-1 downto 0);
	SLAVE_BE : in std_logic_vector((C_SLAVE_PLB_DWIDTH/8)-1 downto 0);
	SLAVE_PAValid : in std_logic;
	SLAVE_RNW : in std_logic;
	SLAVE_abort : in std_logic;
	SLAVE_busLock : in std_logic;
	SLAVE_compress : in std_logic;
	SLAVE_guarded : in std_logic;
	SLAVE_lockErr : in std_logic;
	SLAVE_masterID : in std_logic_vector(C_SLAVE_PLB_MID_WIDTH-1 downto 0);
	SLAVE_MSize : in std_logic_vector(1 downto 0);
	SLAVE_ordered : in std_logic;
	SLAVE_pendPri : in std_logic_vector(1 downto 0);
	SLAVE_pendReq : in std_logic;
	SLAVE_reqPri : in std_logic_vector(1 downto 0);
	SLAVE_size : in std_logic_vector(3 downto 0);
	SLAVE_type : in std_logic_vector(2 downto 0);
	SLAVE_rdPrim : in std_logic;
	SLAVE_SAValid : in std_logic;
	SLAVE_wrPrim : in std_logic;
	SLAVE_wrBurst : in std_logic;
	SLAVE_wrDBus : in std_logic_vector(C_SLAVE_PLB_DWIDTH-1 downto 0);
	SLAVE_rdBurst : in std_logic
);

end plb_slave;

architecture template of plb_slave is
begin
	
end template;



