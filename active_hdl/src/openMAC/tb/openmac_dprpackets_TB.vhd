library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity openmac_dprpackets_tb is
	-- Generic declarations of the tested unit
		generic(
		memSizeLOG2_g : integer := 15;
		memSize_g : integer := 2**15 );
end openmac_dprpackets_tb;

architecture TB_ARCHITECTURE of openmac_dprpackets_tb is
	-- Component declaration of the tested unit
	component openmac_dprpackets
		generic(
		memSizeLOG2_g : integer := 10;
		memSize_g : integer := 1024 );
	port(
		address_a : in STD_LOGIC_VECTOR(memSizeLOG2_g-2 downto 0);
		address_b : in STD_LOGIC_VECTOR(memSizeLOG2_g-3 downto 0);
		byteena_a : in STD_LOGIC_VECTOR(1 downto 0);
		byteena_b : in STD_LOGIC_VECTOR(3 downto 0);
		clock_a : in STD_LOGIC;
		clock_b : in STD_LOGIC;
		data_a : in STD_LOGIC_VECTOR(15 downto 0);
		data_b : in STD_LOGIC_VECTOR(31 downto 0);
		rden_a : in STD_LOGIC;
		rden_b : in STD_LOGIC;
		wren_a : in STD_LOGIC;
		wren_b : in STD_LOGIC;
		q_a : out STD_LOGIC_VECTOR(15 downto 0);
		q_b : out STD_LOGIC_VECTOR(31 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal address_a : STD_LOGIC_VECTOR(memSizeLOG2_g-2 downto 0);
	signal address_b : STD_LOGIC_VECTOR(memSizeLOG2_g-3 downto 0);
	signal byteena_a : STD_LOGIC_VECTOR(1 downto 0);
	signal byteena_b : STD_LOGIC_VECTOR(3 downto 0);
	signal clock_a : STD_LOGIC;
	signal clock_b : STD_LOGIC;
	signal data_a : STD_LOGIC_VECTOR(15 downto 0);
	signal data_b : STD_LOGIC_VECTOR(31 downto 0);
	signal rden_a : STD_LOGIC;
	signal rden_b : STD_LOGIC;
	signal wren_a : STD_LOGIC;
	signal wren_b : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal q_a : STD_LOGIC_VECTOR(15 downto 0);
	signal q_b : STD_LOGIC_VECTOR(31 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : openmac_dprpackets
		generic map (
			memSizeLOG2_g => memSizeLOG2_g,
			memSize_g => memSize_g
		)

		port map (
			address_a => address_a,
			address_b => address_b,
			byteena_a => byteena_a,
			byteena_b => byteena_b,
			clock_a => clock_a,
			clock_b => clock_b,
			data_a => data_a,
			data_b => data_b,
			rden_a => rden_a,
			rden_b => rden_b,
			wren_a => wren_a,
			wren_b => wren_b,
			q_a => q_a,
			q_b => q_b
		);

	-- Add your stimulus here ...
	
	process
	begin
		clock_a <= '0';
		wait for 10 ns;
		clock_a <= '1';
		wait for 10 ns;
	end process;
	
	process
	begin
		clock_b <= '0';
		wait for 5 ns;
		clock_b <= '1';
		wait for 5 ns;
	end process;
	
--	signal address_a : STD_LOGIC_VECTOR(memSizeLOG2_g-2 downto 0);
--	signal byteena_a : STD_LOGIC_VECTOR(1 downto 0);
--	signal clock_a : STD_LOGIC;
--	signal data_a : STD_LOGIC_VECTOR(15 downto 0);
--	signal rden_a : STD_LOGIC;
--	signal wren_a : STD_LOGIC;
	
	process(clock_a)
	variable i : integer := 0;
	begin
		if rising_edge(clock_a) then
			rden_a <= '1';
			wren_a <= '0';
			--address_a <= conv_std_logic_vector(16#0#, address_a'length);
			byteena_a <= (others => '1');
			data_a <= (others => '0');
			
			case i is
				when 0 to 9 =>
					address_a <= (others => '0');
					i := i + 1;
				when 10 =>
					address_a <= address_a + 1;
					i := 11;
				when 11 =>
					i := 10;
				when others =>
			end case;
		end if;
	end process;
	
--	signal address_b : STD_LOGIC_VECTOR(memSizeLOG2_g-3 downto 0);
--	signal byteena_b : STD_LOGIC_VECTOR(3 downto 0);
--	signal clock_b : STD_LOGIC;
--	signal data_b : STD_LOGIC_VECTOR(31 downto 0);
--	signal rden_b : STD_LOGIC;
--	signal wren_b : STD_LOGIC;
	process(clock_b)
	variable i, j : integer := 0;
	begin
		if clock_b = '1' and clock_b'event then
			rden_b <= '0';
			wren_b <= '0';
			address_b <= conv_std_logic_vector(16#0#, address_b'length);
			byteena_b <= (others => '0');
			data_b <= (others => '0');
			case i is
				when 1 =>
					rden_b <= '0';
					wren_b <= '1';
					address_b <= conv_std_logic_vector(j, address_b'length);
					byteena_b <= "1111";
					data_b <= conv_std_logic_vector(j, data_b'length);
					--byteena_b <= "1001";
					--data_b <= x"deadbeef";
				when 5 | 6  =>
					rden_b <= '1';
					wren_b <= '0';
					address_b <= conv_std_logic_vector(j, address_b'length);
					byteena_b <= "1111";
					data_b <= (others => '0');
				--when 10 =>
				when 2 =>
					j := j + 1;
					i := 0;
				when others =>
			end case;
			i := i + 1;
		end if;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_openmac_dprpackets of openmac_dprpackets_tb is
	for TB_ARCHITECTURE
		for UUT : openmac_dprpackets
			use entity work.openmac_dprpackets(struct);
		end for;
	end for;
end TESTBENCH_FOR_openmac_dprpackets;

