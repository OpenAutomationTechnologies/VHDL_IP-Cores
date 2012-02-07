library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

	-- Add your library and packages declaration here ...

entity openmac_dmafifo_tb is
	-- Generic declarations of the tested unit
		generic(
		fifo_data_width_g : natural := 16;
		fifo_word_size_g : natural := 16;
		fifo_word_size_log2_g : natural := 4 );
end openmac_dmafifo_tb;

architecture TB_ARCHITECTURE of openmac_dmafifo_tb is
	-- Component declaration of the tested unit
	component openmac_dmafifo
		generic(
		fifo_data_width_g : natural := 16;
		fifo_word_size_g : natural := 32;
		fifo_word_size_log2_g : natural := 5 );
	port(
		aclr : in STD_LOGIC;
		rd_clk : in STD_LOGIC;
		wr_clk : in STD_LOGIC;
		rd_req : in STD_LOGIC;
		rd_data : out STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
		rd_empty : out STD_LOGIC;
		rd_full : out STD_LOGIC;
		rd_usedw : out STD_LOGIC_VECTOR(fifo_word_size_log2_g-1 downto 0);
		wr_req : in STD_LOGIC;
		wr_data : in STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
		wr_empty : out STD_LOGIC;
		wr_full : out STD_LOGIC;
		wr_usedw : out STD_LOGIC_VECTOR(fifo_word_size_log2_g-1 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal aclr : STD_LOGIC;
	signal rd_clk : STD_LOGIC;
	signal wr_clk : STD_LOGIC;
	signal rd_req : STD_LOGIC;
	signal wr_req : STD_LOGIC;
	signal wr_data : STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal rd_data : STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
	signal rd_empty : STD_LOGIC;
	signal rd_full : STD_LOGIC;
	signal rd_usedw : STD_LOGIC_VECTOR(fifo_word_size_log2_g-1 downto 0);
	signal wr_empty : STD_LOGIC;
	signal wr_full : STD_LOGIC;
	signal wr_usedw : STD_LOGIC_VECTOR(fifo_word_size_log2_g-1 downto 0);

	-- Add your code here ...
	
begin

	-- Unit Under Test port map
	UUT : openmac_dmafifo
		generic map (
			fifo_data_width_g => fifo_data_width_g,
			fifo_word_size_g => fifo_word_size_g,
			fifo_word_size_log2_g => fifo_word_size_log2_g
		)

		port map (
			aclr => aclr,
			rd_clk => rd_clk,
			wr_clk => wr_clk,
			rd_req => rd_req,
			rd_data => rd_data,
			rd_empty => rd_empty,
			rd_full => rd_full,
			rd_usedw => rd_usedw,
			wr_req => wr_req,
			wr_data => wr_data,
			wr_empty => wr_empty,
			wr_full => wr_full,
			wr_usedw => wr_usedw
		);

	-- Add your stimulus here ...
	
	process
	begin
		wr_clk <= '0';
		wait for 5 ns;
		wr_clk <= '1';
		wait for 5 ns;
	end process;
	
	process
	begin
		rd_clk <= '0';
		wait for 10 ns;
		rd_clk <= '1';
		wait for 10 ns;
	end process;
	
	process
	begin
		aclr <= '1';
		wait for 100 ns;
		aclr <= '0';
		wait;
	end process;
	
	process(wr_clk, aclr)
	variable doit : boolean;
	begin
		if aclr = '1' then
			wr_req <= '0';
			wr_data <= (others => '0');
			doit := true;
		elsif wr_clk = '1' and wr_clk'event then
			if wr_full = '1' then
				doit := false;
			elsif wr_empty = '1' then
				doit := true;
			end if;
			
			if wr_req = '0' and doit = true then
				wr_req <= '1';
				wr_data <= wr_data + 1;
			else
				wr_req <= '0';
			end if;
		end if;
	end process;
	
	process(rd_clk, aclr)
	variable doit : boolean;
	begin
		if aclr = '1' then
			rd_req <= '0';
			doit := false;
		elsif rd_clk = '1' and rd_clk'event then
			if rd_full = '1' then
				doit := true;
			elsif rd_empty = '1' then
				doit := false;
			end if;
			
			if rd_req = '0' and doit = true then
				rd_req <= '1';
			else
				rd_req <= '0';
			end if;
		end if;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_openmac_dmafifo of openmac_dmafifo_tb is
	for TB_ARCHITECTURE
		for UUT : openmac_dmafifo
			use entity work.openmac_dmafifo(struct);
		end for;
	end for;
end TESTBENCH_FOR_openmac_dmafifo;

