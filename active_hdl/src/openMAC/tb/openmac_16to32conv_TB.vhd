library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity openmac_16to32conv_tb is
	-- Generic declarations of the tested unit
		generic(
		bus_address_width : integer := 10 );
end openmac_16to32conv_tb;

architecture TB_ARCHITECTURE of openmac_16to32conv_tb is
	-- Component declaration of the tested unit
	component openmac_16to32conv
		generic(
		bus_address_width : integer := 10 );
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		bus_select : in STD_LOGIC;
		bus_write : in STD_LOGIC;
		bus_read : in STD_LOGIC;
		bus_byteenable : in STD_LOGIC_VECTOR(3 downto 0);
		bus_writedata : in STD_LOGIC_VECTOR(31 downto 0);
		bus_readdata : out STD_LOGIC_VECTOR(31 downto 0);
		bus_address : in STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
		bus_ack_wr, bus_ack_rd : out STD_LOGIC;
		s_chipselect : out STD_LOGIC;
		s_write : out STD_LOGIC;
		s_read : out STD_LOGIC;
		s_address : out STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
		s_byteenable : out STD_LOGIC_VECTOR(1 downto 0);
		s_waitrequest : in STD_LOGIC;
		s_readdata : in STD_LOGIC_VECTOR(15 downto 0);
		s_writedata : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal bus_select : STD_LOGIC;
	signal bus_write : STD_LOGIC;
	signal bus_read : STD_LOGIC;
	signal bus_byteenable : STD_LOGIC_VECTOR(3 downto 0);
	signal bus_writedata : STD_LOGIC_VECTOR(31 downto 0);
	signal bus_address : STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
	signal s_waitrequest, s_waitrequest_s : STD_LOGIC;
	signal s_readdata : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal bus_readdata : STD_LOGIC_VECTOR(31 downto 0);
	signal bus_ack_wr, bus_ack_rd, bus_ack : STD_LOGIC;
	signal s_chipselect : STD_LOGIC;
	signal s_write : STD_LOGIC;
	signal s_read : STD_LOGIC;
	signal s_address : STD_LOGIC_VECTOR(bus_address_width-1 downto 0);
	signal s_byteenable : STD_LOGIC_VECTOR(1 downto 0);
	signal s_writedata : STD_LOGIC_VECTOR(15 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : openmac_16to32conv
		generic map (
			bus_address_width => bus_address_width
		)

		port map (
			clk => clk,
			rst => rst,
			bus_select => bus_select,
			bus_write => bus_write,
			bus_read => bus_read,
			bus_byteenable => bus_byteenable,
			bus_writedata => bus_writedata,
			bus_readdata => bus_readdata,
			bus_address => bus_address,
			bus_ack_wr => bus_ack_wr,
			bus_ack_rd => bus_ack_rd,
			s_chipselect => s_chipselect,
			s_write => s_write,
			s_read => s_read,
			s_address => s_address,
			s_byteenable => s_byteenable,
			s_waitrequest => s_waitrequest,
			s_readdata => s_readdata,
			s_writedata => s_writedata
		);

	bus_ack <= bus_ack_wr or bus_ack_rd;
--	signal clk : STD_LOGIC;
--	signal rst : STD_LOGIC;
process
begin
	clk <= '0';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
end process;

process
begin
	rst <= '1';
	wait for 100 ns;
	rst <= '0';
	wait;
end process;

bus_writedata <= x"1234abcd";
bus_write <= not bus_read;
bus_address <= conv_std_logic_vector(0, bus_address'length);
	--	signal bus_readdata : STD_LOGIC_VECTOR(31 downto 0);
	--	signal bus_ack : STD_LOGIC;
process
begin
	
	bus_select <= '0';
	bus_read <= '0';
	bus_byteenable <= "0000";
	
	wait until rst = '0';
	
	wait until clk = '1' and clk'event;
	
	loop
		wait for 1000 ns;
		
		bus_select <= '1';
		bus_read <= not bus_read;
		
		bus_byteenable <= "1111";
		
		wait until bus_ack = '1';
		wait until clk = '1' and clk'event;
		
		bus_select <= '0';
		--bus_read <= '0';
		bus_byteenable <= "0000";
	end loop;
	
end process;

s_readdata <= x"5678" when s_address(1) = '0' else x"ABCD";
s_waitrequest <= s_waitrequest_s when s_read = '1' else not s_write;

process(clk, rst)
variable i : integer;
begin
	if rst = '1' then
		s_waitrequest_s <= '1';
		i := 0;
	elsif clk = '1' and clk'event then
		s_waitrequest_s <= '1';
		if s_chipselect = '1' then
			if i = 2 then
				i := 0;
				s_waitrequest_s <= '0';
			else
				i := i + 1;
			end if;
		end if;
	end if;
end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_openmac_16to32conv of openmac_16to32conv_tb is
	for TB_ARCHITECTURE
		for UUT : openmac_16to32conv
			use entity work.openmac_16to32conv(rtl);
		end for;
	end for;
end TESTBENCH_FOR_openmac_16to32conv;

