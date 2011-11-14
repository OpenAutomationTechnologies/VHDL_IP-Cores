library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity endian_conv_tb is
	-- Generic declarations of the tested unit
		generic(
		dwidth_g : integer := 32);
end endian_conv_tb;

architecture TB_ARCHITECTURE of endian_conv_tb is
	-- Component declaration of the tested unit
	component endian_conv
		generic(
		dwidth_g : integer := 32);
	port(
		in_data : in STD_LOGIC_VECTOR(dwidth_g-1 downto 0);
		out_data : out STD_LOGIC_VECTOR(dwidth_g-1 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal in_data : STD_LOGIC_VECTOR(dwidth_g-1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal out_data : STD_LOGIC_VECTOR(dwidth_g-1 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : endian_conv
		generic map (
			dwidth_g => dwidth_g
		)

		port map (
			in_data => in_data,
			out_data => out_data
		);

	in_data <= conv_std_logic_vector(16#1234ABCD#, in_data'length);

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_endian_conv of endian_conv_tb is
	for TB_ARCHITECTURE
		for UUT : endian_conv
			use entity work.endian_conv(rtl);
		end for;
	end for;
end TESTBENCH_FOR_endian_conv;

