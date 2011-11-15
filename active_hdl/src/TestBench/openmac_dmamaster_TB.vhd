library ieee;
use ieee.MATH_REAL.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity openmac_dmamaster_tb is
	-- Generic declarations of the tested unit
		generic(
		
		test_with_plb : boolean := true;
		fifo_data_width_g : integer := 32;
		
		simulate : boolean := false;
		dma_highadr_g : integer := 31;
		gen_tx_fifo_g : boolean := true;
		gen_rx_fifo_g : boolean := true;
		tx_fifo_word_size_g : integer := 32;
		rx_fifo_word_size_g : integer := 32;
		m_burstcount_width_g : integer := 4;
		m_burstcount_const_g : boolean := true;
		m_tx_burst_size_g : integer := 1;
		m_rx_burst_size_g : integer := 1 );
end openmac_dmamaster_tb;

architecture TB_ARCHITECTURE of openmac_dmamaster_tb is
	-- Component declaration of the tested unit
	component openmac_dmamaster
		generic(
		simulate : boolean := false;
		dma_highadr_g : integer := 31;
		gen_tx_fifo_g : boolean := true;
		gen_rx_fifo_g : boolean := true;
		tx_fifo_word_size_g : integer := 32;
		rx_fifo_word_size_g : integer := 32;
		fifo_data_width_g : integer := 16;
		m_burstcount_width_g : integer := 4;
		m_burstcount_const_g : boolean := true;
		m_tx_burst_size_g : integer := 16;
		m_rx_burst_size_g : integer := 16 );
	port(
		dma_clk : in STD_LOGIC;
		dma_req_rd : in STD_LOGIC;
		dma_req_wr : in STD_LOGIC;
		m_clk : in STD_LOGIC;
		m_readdatavalid : in STD_LOGIC;
		m_waitrequest : in STD_LOGIC;
		mac_rx_off : in STD_LOGIC;
		mac_rx_on : in STD_LOGIC;
		mac_tx_off : in STD_LOGIC;
		mac_tx_on : in STD_LOGIC;
		rst : in STD_LOGIC;
		dma_addr : in STD_LOGIC_VECTOR(dma_highadr_g downto 1);
		dma_dout : in STD_LOGIC_VECTOR(15 downto 0);
		m_readdata : in STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
		dma_ack_rd : out STD_LOGIC;
		dma_ack_wr : out STD_LOGIC;
		m_read : out STD_LOGIC;
		m_write : out STD_LOGIC;
		dma_din : out STD_LOGIC_VECTOR(15 downto 0);
		m_address : out STD_LOGIC_VECTOR(dma_highadr_g downto 0);
		m_burstcount : out STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
		m_burstcounter : out STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
		m_byteenable : out STD_LOGIC_VECTOR(fifo_data_width_g/8-1 downto 0);
		m_writedata : out STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal dma_clk : STD_LOGIC;
	signal dma_req_rd : STD_LOGIC;
	signal dma_req_wr : STD_LOGIC;
	signal m_clk : STD_LOGIC;
	signal m_readdatavalid : STD_LOGIC;
	signal m_waitrequest : STD_LOGIC;
	signal mac_rx_off : STD_LOGIC;
	signal mac_rx_on : STD_LOGIC;
	signal mac_tx_off : STD_LOGIC;
	signal mac_tx_on : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal dma_addr : STD_LOGIC_VECTOR(dma_highadr_g downto 1);
	signal dma_dout : STD_LOGIC_VECTOR(15 downto 0);
	signal m_readdata : STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal dma_ack_rd : STD_LOGIC;
	signal dma_ack_wr : STD_LOGIC;
	signal m_read : STD_LOGIC;
	signal m_write : STD_LOGIC;
	signal dma_din : STD_LOGIC_VECTOR(15 downto 0);
	signal m_address : STD_LOGIC_VECTOR(dma_highadr_g downto 0);
	signal m_burstcount : STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
	signal m_burstcounter : STD_LOGIC_VECTOR(m_burstcount_width_g-1 downto 0);
	signal m_byteenable : STD_LOGIC_VECTOR(fifo_data_width_g/8-1 downto 0);
	signal m_writedata : STD_LOGIC_VECTOR(fifo_data_width_g-1 downto 0);
	
	
	signal MAC_DMA_CLK : std_logic;
	signal MAC_DMA_Rst : std_logic;
	signal Bus2MAC_DMA_Mst_CmdAck : std_logic := '0';
	signal Bus2MAC_DMA_Mst_Cmplt : std_logic := '0';
	signal Bus2MAC_DMA_Mst_Error : std_logic := '0';
	signal Bus2MAC_DMA_Mst_Rearbitrate : std_logic := '0';
	signal Bus2MAC_DMA_Mst_Cmd_Timeout : std_logic := '0';
	signal Bus2MAC_DMA_MstRd_d : std_logic_vector(32-1 downto 0);
	signal Bus2MAC_DMA_MstRd_rem : std_logic_vector(32/8-1 downto 0);
	signal Bus2MAC_DMA_MstRd_sof_n : std_logic := '1';
	signal Bus2MAC_DMA_MstRd_eof_n : std_logic := '1';
	signal Bus2MAC_DMA_MstRd_src_rdy_n : std_logic := '1';
	signal Bus2MAC_DMA_MstRd_src_dsc_n : std_logic := '1';
	signal Bus2MAC_DMA_MstWr_dst_rdy_n : std_logic := '1';
	signal Bus2MAC_DMA_MstWr_dst_dsc_n : std_logic := '1';
	
	signal MAC_DMA2Bus_MstRd_Req : std_logic := '0';
	signal MAC_DMA2Bus_MstWr_Req : std_logic := '0';
	signal MAC_DMA2Bus_Mst_Type : std_logic := '0';
	signal MAC_DMA2Bus_Mst_Addr : std_logic_vector(32-1 downto 0);
	signal MAC_DMA2Bus_Mst_Length : std_logic_vector(11 downto 0);
	signal MAC_DMA2Bus_Mst_BE : std_logic_vector(32/8-1 downto 0);
	signal MAC_DMA2Bus_Mst_Lock : std_logic := '0';
	signal MAC_DMA2Bus_Mst_Reset : std_logic := '0';
	signal MAC_DMA2Bus_MstRd_dst_rdy_n : std_logic := '1';
	signal MAC_DMA2Bus_MstRd_dst_dsc_n : std_logic := '1';
	signal MAC_DMA2Bus_MstWr_d : std_logic_vector(32-1 downto 0);
	signal MAC_DMA2Bus_MstWr_rem : std_logic_vector(32/8-1 downto 0);
	signal MAC_DMA2Bus_MstWr_sof_n : std_logic := '1';
	signal MAC_DMA2Bus_MstWr_eof_n : std_logic := '1';
	signal MAC_DMA2Bus_MstWr_src_rdy_n : std_logic := '1';
	signal MAC_DMA2Bus_MstWr_src_dsc_n : std_logic := '1';

	-- Add your code here ...
	signal sim_done : boolean := false;
	signal clk100 : std_logic;

begin

	-- Unit Under Test port map
	UUT : openmac_dmamaster
		generic map (
			simulate => simulate,
			dma_highadr_g => dma_highadr_g,
			gen_tx_fifo_g => gen_tx_fifo_g,
			gen_rx_fifo_g => gen_rx_fifo_g,
			tx_fifo_word_size_g => tx_fifo_word_size_g,
			rx_fifo_word_size_g => rx_fifo_word_size_g,
			fifo_data_width_g => fifo_data_width_g,
			m_burstcount_width_g => m_burstcount_width_g,
			m_burstcount_const_g => m_burstcount_const_g,
			m_tx_burst_size_g => m_tx_burst_size_g,
			m_rx_burst_size_g => m_rx_burst_size_g
		)

		port map (
			dma_clk => dma_clk,
			dma_req_rd => dma_req_rd,
			dma_req_wr => dma_req_wr,
			m_clk => m_clk,
			m_readdatavalid => m_readdatavalid,
			m_waitrequest => m_waitrequest,
			mac_rx_off => mac_rx_off,
			mac_rx_on => mac_rx_on,
			mac_tx_off => mac_tx_off,
			mac_tx_on => mac_tx_on,
			rst => rst,
			dma_addr => dma_addr,
			dma_dout => dma_dout,
			m_readdata => m_readdata,
			dma_ack_rd => dma_ack_rd,
			dma_ack_wr => dma_ack_wr,
			m_read => m_read,
			m_write => m_write,
			dma_din => dma_din,
			m_address => m_address,
			m_burstcount => m_burstcount,
			m_burstcounter => m_burstcounter,
			m_byteenable => m_byteenable,
			m_writedata => m_writedata
		);

	-- Add your stimulus here ...
	process
	begin
		dma_clk <= '1';
		wait for 10 ns;
		dma_clk <= '0';
		wait for 10 ns;
	end process;
	
	process
	begin
		clk100 <= '1';
		wait for 5 ns;
		clk100 <= '0';
		wait for 5 ns;
	end process;
	
	gen_m_clk1 : if test_with_plb generate
	begin
		MAC_DMA_CLK <= clk100;
	end generate;
	
	gen_m_clk2 : if not test_with_plb generate
	begin
		m_clk <= clk100;
	end generate;
	
	process
	begin
		rst <= '1';
		wait for 100 ns;
		rst <= '0';
		wait;
	end process;
	
	process(dma_clk, rst)
	variable i, j : integer;
	begin
		if rst = '1' then
			dma_addr <= (others => '0');
			dma_dout <= (others => '0');
			dma_req_rd <= '0'; dma_req_wr <= '0';
			i := 0; j := 0;
			mac_rx_off <= '0';
			mac_rx_on <= '0';
			mac_tx_on <= '0';
			mac_tx_off <= '0';
		elsif dma_clk = '1' and dma_clk'event then
			
			mac_rx_off <= '0';
			mac_rx_on <= '0';
			mac_tx_on <= '0';
			mac_tx_off <= '0';
			
			if ((i = 8 and j /= 1) or i = 32) and sim_done = false then
				--dma_req_rd <= '1';
				dma_req_wr <= '1';
				i := 0; j := j + 1;
				dma_dout <= dma_dout + 1;
				dma_addr <= dma_addr + 1;
			else
				i := i + 1;
			end if;
			
			if j = 46 then
				mac_rx_off <= '1';
				--mac_tx_off <= '1';
				dma_req_rd <= '0';
				dma_req_wr <= '0';
				j := 0; sim_done <= true;
			end if;
			
			if dma_ack_rd = '1' or dma_ack_wr = '1' then
				dma_req_rd <= '0';
				dma_req_wr <= '0';
			end if;
			
		end if;
	end process;
	
genAvalon : if test_with_plb = false generate
begin
	process(m_clk, rst)
	variable i, j : integer;
	variable isread : boolean;
	begin  
		if rst = '1' then
			m_readdatavalid <= '0';
			m_waitrequest <= '1';
			m_readdata <= (others => '0');
			isread := false;
		elsif m_clk = '1' and m_clk'event then
			m_waitrequest <= '1';
			m_readdatavalid <= '0';
			
			if isread = true and j = 0 then
				m_readdatavalid <= '1';
			elsif isread = true then
				j := j - 1;
			end if;
				
			
			if (m_read = '1' or m_write = '1') and m_waitrequest = '1' then
				i := conv_integer(m_burstcount);
				m_waitrequest <= '0';
				if m_read = '1' then 
					isread := true;
					j := 4;
				else 
					isread := false;
				end if;
			end if;
			
			if i /= 0 and ((m_write = '1' and m_waitrequest = '0') or (m_readdatavalid = '1')) then
				i := i - 1;
			elsif i = 0 then
				m_waitrequest <= '1'; isread := false;
			end if;
			
		end if;
	end process;
end generate;

genPLB : if test_with_plb = true generate
begin

	MAC_DMA_Rst <= rst;
	--	signal Bus2MAC_DMA_MstRd_d : std_logic_vector(C_MAC_DMA_PLB_NATIVE_DWIDTH-1 downto 0);
	--	signal Bus2MAC_DMA_MstRd_rem : std_logic_vector(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
	--	signal Bus2MAC_DMA_MstRd_sof_n : std_logic := '1';
	--	signal Bus2MAC_DMA_MstRd_eof_n : std_logic := '1';
	--	signal Bus2MAC_DMA_MstRd_src_rdy_n : std_logic := '1';
	--	signal Bus2MAC_DMA_MstRd_src_dsc_n : std_logic := '1';
	--	signal Bus2MAC_DMA_MstWr_dst_rdy_n : std_logic := '1';
	--	signal Bus2MAC_DMA_MstWr_dst_dsc_n : std_logic := '1';
	
	Bus2MAC_DMA_Mst_Error <= '0';
	Bus2MAC_DMA_Mst_Rearbitrate <= '0';
	Bus2MAC_DMA_Mst_Cmd_Timeout <= '0';
	
	process(MAC_DMA_CLK, MAC_DMA_Rst)
	variable i : integer := 0;
	begin
		if MAC_DMA_Rst = '1' then
			Bus2MAC_DMA_Mst_CmdAck <= '0';
		elsif rising_edge(MAC_DMA_CLK) then
			
			Bus2MAC_DMA_Mst_Cmplt <= '0';
			if Bus2MAC_DMA_MstRd_eof_n = '0' and Bus2MAC_DMA_MstRd_src_rdy_n = '0' then
				Bus2MAC_DMA_Mst_Cmplt <= '1';
			end if;
			
			if MAC_DMA2Bus_MstWr_eof_n = '0' and Bus2MAC_DMA_MstWr_dst_rdy_n = '0' then
				Bus2MAC_DMA_Mst_Cmplt <= '1';
			end if;
			
			Bus2MAC_DMA_Mst_CmdAck <= '0';
			if MAC_DMA2Bus_MstRd_Req = '1' or MAC_DMA2Bus_MstWr_Req = '1' then
				if i = 2 then
					Bus2MAC_DMA_Mst_CmdAck <= '1';
					i := 0;
				else
					i := i + 1;
				end if;
			end if;
		end if;
	end process;
	
	--Bus2MAC_DMA_MstWr_dst_rdy_n <= MAC_DMA2Bus_MstWr_src_rdy_n;
	process(MAC_DMA_CLK, MAC_DMA_Rst)
	variable i : integer := 0;
	begin
		if MAC_DMA_Rst = '1' then
			Bus2MAC_DMA_MstWr_dst_rdy_n <= '1';
		elsif rising_edge(MAC_DMA_CLK) then
			Bus2MAC_DMA_MstWr_dst_rdy_n <= '1';
			if MAC_DMA2Bus_MstWr_src_rdy_n = '0' then
				if i = 1 then
					Bus2MAC_DMA_MstWr_dst_rdy_n <= '0';
					i := 0;
				else
					i := i + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(MAC_DMA_CLK, MAC_DMA_Rst)
	variable i, j : integer := 0;
	variable doTran, firstTran : boolean;
	begin
		if MAC_DMA_Rst = '1' then
			doTran := false;
			Bus2MAC_DMA_MstRd_sof_n <= '1'; Bus2MAC_DMA_MstRd_src_rdy_n <= '1';
			Bus2MAC_DMA_MstRd_eof_n <= '1';
			Bus2MAC_DMA_MstRd_d <= (others => '0');
			j := 0; i := 0;
		elsif rising_edge(MAC_DMA_CLK) then
			Bus2MAC_DMA_MstRd_sof_n <= '1'; Bus2MAC_DMA_MstRd_src_rdy_n <= '1';
			Bus2MAC_DMA_MstRd_eof_n <= '1'; 
			
			if MAC_DMA2Bus_MstRd_Req = '1' and MAC_DMA2Bus_Mst_Type = '1' then
				i := conv_integer(MAC_DMA2Bus_Mst_Length) / 4;
				j := 5;
			end if;
			
			if j = 1 then
				doTran := true;
				firstTran := true;
				j := 0;
			elsif j /= 0 then
				j := j - 1;
			end if;
			
			if doTran = true then
				if firstTran = true then
					Bus2MAC_DMA_MstRd_sof_n <= '0';
					firstTran := false;
				end if;
				Bus2MAC_DMA_MstRd_src_rdy_n <= '0';
				Bus2MAC_DMA_MstRd_d <= Bus2MAC_DMA_MstRd_d + 1;
				i := i - 1;
				
				if i = 1 then
					Bus2MAC_DMA_MstRd_eof_n <= '0';
				end if;
				
				if i = 0 then
					doTran := false; Bus2MAC_DMA_MstRd_src_rdy_n <= '1';
				end if;
			end if;
			
		end if;
	end process;
	
	-- OBSERVE :
	--	signal MAC_DMA2Bus_MstRd_Req : std_logic := '0';
	--	signal MAC_DMA2Bus_MstWr_Req : std_logic := '0';
	--	signal MAC_DMA2Bus_Mst_Type : std_logic := '0';
	--	signal MAC_DMA2Bus_Mst_Addr : std_logic_vector(C_MAC_DMA_PLB_AWIDTH-1 downto 0);
	--	signal MAC_DMA2Bus_Mst_Length : std_logic_vector(11 downto 0);
	--	signal MAC_DMA2Bus_Mst_BE : std_logic_vector(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
	--	signal MAC_DMA2Bus_Mst_Lock : std_logic := '0';
	--	signal MAC_DMA2Bus_Mst_Reset : std_logic := '0';
	--	signal MAC_DMA2Bus_MstRd_dst_rdy_n : std_logic := '1';
	--	signal MAC_DMA2Bus_MstRd_dst_dsc_n : std_logic := '1';
	--	signal MAC_DMA2Bus_MstWr_d : std_logic_vector(C_MAC_DMA_PLB_NATIVE_DWIDTH-1 downto 0);
	--	signal MAC_DMA2Bus_MstWr_rem : std_logic_vector(C_MAC_DMA_PLB_NATIVE_DWIDTH/8-1 downto 0);
	--	signal MAC_DMA2Bus_MstWr_sof_n : std_logic := '1';
	--	signal MAC_DMA2Bus_MstWr_eof_n : std_logic := '1';
	--	signal MAC_DMA2Bus_MstWr_src_rdy_n : std_logic := '1';
	--	signal MAC_DMA2Bus_MstWr_src_dsc_n : std_logic := '1';
	
	PLB : entity work.plb_master_handler
		generic map(
			gen_rx_fifo_g => gen_rx_fifo_g,
			gen_tx_fifo_g => gen_tx_fifo_g,
			C_MAC_DMA_PLB_NATIVE_DWIDTH => 32,
			C_MAC_DMA_PLB_AWIDTH => 32,
			m_burstcount_width_g => m_burstcount_width_g
		)
		port map(
			MAC_DMA_CLK => MAC_DMA_CLK,
			MAC_DMA_Rst => MAC_DMA_Rst,
			Bus2MAC_DMA_Mst_CmdAck => Bus2MAC_DMA_Mst_CmdAck,
			Bus2MAC_DMA_Mst_Cmplt => Bus2MAC_DMA_Mst_Cmplt,
			Bus2MAC_DMA_Mst_Error => Bus2MAC_DMA_Mst_Error,
			Bus2MAC_DMA_Mst_Rearbitrate => Bus2MAC_DMA_Mst_Rearbitrate,
			Bus2MAC_DMA_Mst_Cmd_Timeout => Bus2MAC_DMA_Mst_Cmd_Timeout,
			Bus2MAC_DMA_MstRd_d => Bus2MAC_DMA_MstRd_d,
			Bus2MAC_DMA_MstRd_rem => Bus2MAC_DMA_MstRd_rem,
			Bus2MAC_DMA_MstRd_sof_n => Bus2MAC_DMA_MstRd_sof_n,
			Bus2MAC_DMA_MstRd_eof_n => Bus2MAC_DMA_MstRd_eof_n,
			Bus2MAC_DMA_MstRd_src_rdy_n => Bus2MAC_DMA_MstRd_src_rdy_n,
			Bus2MAC_DMA_MstRd_src_dsc_n => Bus2MAC_DMA_MstRd_src_dsc_n,
			Bus2MAC_DMA_MstWr_dst_rdy_n => Bus2MAC_DMA_MstWr_dst_rdy_n,
			Bus2MAC_DMA_MstWr_dst_dsc_n => Bus2MAC_DMA_MstWr_dst_dsc_n,
			MAC_DMA2Bus_MstRd_Req => MAC_DMA2Bus_MstRd_Req,
			MAC_DMA2Bus_MstWr_Req => MAC_DMA2Bus_MstWr_Req,
			MAC_DMA2Bus_Mst_Type => MAC_DMA2Bus_Mst_Type,
			MAC_DMA2Bus_Mst_Addr => MAC_DMA2Bus_Mst_Addr,
			MAC_DMA2Bus_Mst_Length => MAC_DMA2Bus_Mst_Length,
			MAC_DMA2Bus_Mst_BE => MAC_DMA2Bus_Mst_BE,
			MAC_DMA2Bus_Mst_Lock => MAC_DMA2Bus_Mst_Lock,
			MAC_DMA2Bus_Mst_Reset => MAC_DMA2Bus_Mst_Reset,
			MAC_DMA2Bus_MstRd_dst_rdy_n => MAC_DMA2Bus_MstRd_dst_rdy_n,
			MAC_DMA2Bus_MstRd_dst_dsc_n => MAC_DMA2Bus_MstRd_dst_dsc_n,
			MAC_DMA2Bus_MstWr_d => MAC_DMA2Bus_MstWr_d,
			MAC_DMA2Bus_MstWr_rem => MAC_DMA2Bus_MstWr_rem,
			MAC_DMA2Bus_MstWr_sof_n => MAC_DMA2Bus_MstWr_sof_n,
			MAC_DMA2Bus_MstWr_eof_n => MAC_DMA2Bus_MstWr_eof_n,
			MAC_DMA2Bus_MstWr_src_rdy_n => MAC_DMA2Bus_MstWr_src_rdy_n,
			MAC_DMA2Bus_MstWr_src_dsc_n => MAC_DMA2Bus_MstWr_src_dsc_n,
			m_read => m_read,
			m_write => m_write,
			m_byteenable => m_byteenable,
			m_address => m_address,
			m_writedata => m_writedata,
			m_burstcount => m_burstcount,
			m_burstcounter => m_burstcounter,
			m_readdata => m_readdata,
			m_waitrequest => m_waitrequest,
			m_readdatavalid => m_readdatavalid,
			m_clk => m_clk
		);
	
end generate;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_openmac_dmamaster of openmac_dmamaster_tb is
	for TB_ARCHITECTURE
		for UUT : openmac_dmamaster
			use entity work.openmac_dmamaster(strct);
		end for;
	end for;
end TESTBENCH_FOR_openmac_dmamaster;

