library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity hwacc_tb is
	-- Generic declarations of the tested unit
		generic(
		useHwAcc_g : BOOLEAN := true;
		iSlaveAddrWidth_g : INTEGER := 12;
		iSlaveDataWidth_g : INTEGER := 16;
		iMasterAddrWidth_g : INTEGER := 30;
		iMasterDataWidth_g : INTEGER := 16;
		iTxFltNum_g : INTEGER := 1;
		iRxFltNum_g : INTEGER := 3;
		simulate_g : BOOLEAN := true );
end hwacc_tb;

architecture TB_ARCHITECTURE of hwacc_tb is
	-- Component declaration of the tested unit
	component hwacc
		generic(
		useHwAcc_g : BOOLEAN := false;
		iSlaveAddrWidth_g : INTEGER := 12;
		iSlaveDataWidth_g : INTEGER := 16;
		iMasterAddrWidth_g : INTEGER := 32;
		iMasterDataWidth_g : INTEGER := 16;
		iTxFltNum_g : INTEGER := 1;
		iRxFltNum_g : INTEGER := 3;
		simulate_g : BOOLEAN := false );
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		s_address : in STD_LOGIC_VECTOR(iSlaveAddrWidth_g-1 downto 0);
		s_chipselect : in STD_LOGIC;
		s_write : in STD_LOGIC;
		s_read : in STD_LOGIC;
		s_byteenable : in STD_LOGIC_VECTOR(iSlaveDataWidth_g/8-1 downto 0);
		s_writedata : in STD_LOGIC_VECTOR(iSlaveDataWidth_g-1 downto 0);
		s_readdata : out STD_LOGIC_VECTOR(iSlaveDataWidth_g-1 downto 0);
		bus_read_n : out STD_LOGIC;
		bus_write_n : out STD_LOGIC;
		bus_byteenable_n : out STD_LOGIC_VECTOR(iMasterDataWidth_g/8-1 downto 0);
		bus_address : out STD_LOGIC_VECTOR(iMasterAddrWidth_g-1 downto 0);
		bus_writedata : out STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
		bus_readdata : in STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
		bus_waitrequest : in STD_LOGIC;
		bus_arbiterlock : out STD_LOGIC;
		mac_read_n : in STD_LOGIC;
		mac_write_n : in STD_LOGIC;
		mac_byteenable_n : in STD_LOGIC_VECTOR(iMasterDataWidth_g/8-1 downto 0);
		mac_address : in STD_LOGIC_VECTOR(iMasterAddrWidth_g-1 downto 0);
		mac_writedata : in STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
		mac_readdata : out STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
		mac_waitrequest : out STD_LOGIC;
		mac_arbiterlock : in STD_LOGIC;
		macTxOnP : in STD_LOGIC;
		macTxOffP : in STD_LOGIC;
		macRxOnP : in STD_LOGIC;
		macRxOffP : in STD_LOGIC;
		macTxEn : in STD_LOGIC;
		macRxEn : in STD_LOGIC;
		rpdo_change_tog : out STD_LOGIC_VECTOR(2 downto 0);
		tpdo_change_tog : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal rst : STD_LOGIC;
	signal s_address : STD_LOGIC_VECTOR(iSlaveAddrWidth_g-1 downto 0);
	signal s_chipselect : STD_LOGIC;
	signal s_write : STD_LOGIC;
	signal s_read : STD_LOGIC;
	signal s_byteenable : STD_LOGIC_VECTOR(iSlaveDataWidth_g/8-1 downto 0);
	signal s_writedata : STD_LOGIC_VECTOR(iSlaveDataWidth_g-1 downto 0);
	signal bus_readdata : STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
	signal bus_waitrequest : STD_LOGIC;
	signal mac_read, mac_read_n : STD_LOGIC;
	signal mac_write, mac_write_n : STD_LOGIC;
	signal mac_byteenable, mac_byteenable_n : STD_LOGIC_VECTOR(iMasterDataWidth_g/8-1 downto 0);
	signal mac_address : STD_LOGIC_VECTOR(iMasterAddrWidth_g-1 downto 0);
	signal mac_writedata : STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
	signal mac_arbiterlock : STD_LOGIC;
	signal macTxOnP : STD_LOGIC;
	signal macTxOffP : STD_LOGIC;
	signal macRxOnP : STD_LOGIC;
	signal macRxOffP : STD_LOGIC;
	signal macTxEn : STD_LOGIC;
	signal macRxEn : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal s_readdata : STD_LOGIC_VECTOR(iSlaveDataWidth_g-1 downto 0);
	signal bus_read_n, bus_read : STD_LOGIC;
	signal bus_write_n, bus_write : STD_LOGIC;
	signal bus_byteenable_n : STD_LOGIC_VECTOR(iMasterDataWidth_g/8-1 downto 0);
	signal bus_address : STD_LOGIC_VECTOR(iMasterAddrWidth_g-1 downto 0);
	signal bus_writedata : STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
	signal bus_arbiterlock : STD_LOGIC;
	signal mac_readdata : STD_LOGIC_VECTOR(iMasterDataWidth_g-1 downto 0);
	signal mac_waitrequest : STD_LOGIC;
	signal rpdo_change_tog : STD_LOGIC_VECTOR(2 downto 0);
	signal tpdo_change_tog : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : hwacc
		generic map (
			useHwAcc_g => useHwAcc_g,
			iSlaveAddrWidth_g => iSlaveAddrWidth_g,
			iSlaveDataWidth_g => iSlaveDataWidth_g,
			iMasterAddrWidth_g => iMasterAddrWidth_g,
			iMasterDataWidth_g => iMasterDataWidth_g,
			iTxFltNum_g => iTxFltNum_g,
			iRxFltNum_g => iRxFltNum_g,
			simulate_g => simulate_g
		)

		port map (
			clk => clk,
			rst => rst,
			s_address => s_address,
			s_chipselect => s_chipselect,
			s_write => s_write,
			s_read => s_read,
			s_byteenable => s_byteenable,
			s_writedata => s_writedata,
			s_readdata => s_readdata,
			bus_read_n => bus_read_n,
			bus_write_n => bus_write_n,
			bus_byteenable_n => bus_byteenable_n,
			bus_address => bus_address,
			bus_writedata => bus_writedata,
			bus_readdata => bus_readdata,
			bus_waitrequest => bus_waitrequest,
			bus_arbiterlock => bus_arbiterlock,
			mac_read_n => mac_read_n,
			mac_write_n => mac_write_n,
			mac_byteenable_n => mac_byteenable_n,
			mac_address => mac_address,
			mac_writedata => mac_writedata,
			mac_readdata => mac_readdata,
			mac_waitrequest => mac_waitrequest,
			mac_arbiterlock => mac_arbiterlock,
			macTxOnP => macTxOnP,
			macTxOffP => macTxOffP,
			macRxOnP => macRxOnP,
			macRxOffP => macRxOffP,
			macTxEn => macTxEn,
			macRxEn => macRxEn,
			rpdo_change_tog => rpdo_change_tog,
			tpdo_change_tog => tpdo_change_tog
		);

	-- Add your stimulus here ...
	
	--clock and reset signal generator
	process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= not clk;
		wait for 10 ns;
	end process;
	
	process
	begin
		rst <= '1';
		wait for 100 ns;
		rst <= not rst;
		wait;
	end process;
	
	--slave interface signal generator
	process
	begin
		s_address <= conv_std_logic_vector(0, s_address'length);
		s_chipselect <= '0';
		s_write <= '0';
		s_read <= '0';
		s_byteenable <= conv_std_logic_vector(0, s_byteenable'length);
		s_writedata <= conv_std_logic_vector(0, s_writedata'length);
		
		wait until rst = '0';
		
		wait;
	end process;
	
	--avalon master signals from the bus
	bus_write <= not bus_write_n;
	bus_read <= not bus_read_n;
	
	process
	begin
		bus_readdata <= (others => '0');
		bus_waitrequest <= '1';
		wait until rst = '0';
		
		loop
			
			bus_waitrequest <= '1';
			
			if bus_write = '1' then
				wait until clk = '1' and clk'event;
				wait until clk = '1' and clk'event;
				bus_waitrequest <= '0';
			end if;
			
			if bus_read = '1' then
				wait until clk = '1' and clk'event;
				wait until clk = '1' and clk'event;
				bus_waitrequest <= '0';
				bus_readdata <= bus_readdata + 1;
			end if;
			
			wait until clk = '1' and clk'event;
			
		end loop;
		
		wait;
	end process;
	
	--avalon master signals and others set by mac
	mac_read_n <= not mac_read;
	mac_write_n <= not mac_write;
	mac_byteenable_n <= not mac_byteenable;
	
	process
	begin
		mac_read <= '0';
		mac_write <= '0';
		mac_byteenable <= (others => '0');
		mac_address <= (others => '0');
		mac_writedata <= (others => '0');
		mac_arbiterlock <= '0';
		wait until rst = '0';
		
		wait until macRxEn = '1' or macTxEn = '1';
		
		while macTxEn = '1' or macRxEn = '1' loop
			if macRxEn = '1' then
				mac_write <= '1';
				if bus_waitrequest = '0' then
					mac_writedata <= x"0010";
					mac_byteenable <= (others => '1');
					mac_arbiterlock <= '1'; --don't care this signal
					mac_address <= mac_address + 2;
				end if;
			elsif macTxEn = '1' then
				mac_read <= '1';
			end if;
			
			wait until clk = '1' and clk'event;
		end loop;
		
		mac_read <= '0';
		mac_write <= '0';
		mac_byteenable <= (others => '0');
		mac_address <= (others => '0');
		mac_writedata <= (others => '0');
		mac_arbiterlock <= '0';
		
		wait;
	end process;
	
	process
	begin
		macTxEn <= '0';
		macRxEn <= '0';
		wait until rst = '0';
		
		wait for 100 ns;
		macRxEn <= '1';
		wait for 6 us;
		macRxEn <= '0';
		
		wait;
	end process;
	
	process
	variable lastTx, lastRx : std_logic;
	begin
		lastTx := '0'; lastRx := '0';
		loop
			macTxOnP <= '0';
			macTxOffP <= '0';
			macRxOnP <= '0';
			macRxOffP <= '0';
			
			if lastTx = '0' and macTxEn = '1' then
				macTxOnP <= '1';
			elsif lastTx = '1' and macTxEn = '0' then
				macTxOffP <= '1';
			end if;
			
			if lastRx = '0' and macRxEn = '1' then
				macRxOnP <= '1';
			elsif lastRx = '1' and macRxEn = '0' then
				macRxOffP <= '1';
			end if;
			
			lastTx := macTxEn; lastRx := macRxEn;
			wait until clk = '1' and clk'event;
		end loop;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_hwacc of hwacc_tb is
	for TB_ARCHITECTURE
		for UUT : hwacc
			use entity work.hwacc(rtl);
		end for;
	end for;
end TESTBENCH_FOR_hwacc;

