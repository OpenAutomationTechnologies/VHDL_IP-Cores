library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity openmac_tb is
	-- Generic declarations of the tested unit
		generic(
		HighAdr : INTEGER := 16;
		Timer : BOOLEAN := true;
		TxSyncOn : BOOLEAN := true;
		TxDel : BOOLEAN := true;
		Simulate : BOOLEAN := true );
end openmac_tb;

architecture TB_ARCHITECTURE of openmac_tb is
	-- Component declaration of the tested unit
	component openmac
		generic(
		HighAdr : INTEGER := 16;
		Timer : BOOLEAN := false;
		TxSyncOn : BOOLEAN := false;
		TxDel : BOOLEAN := false;
		Simulate : BOOLEAN := false );
	port(
		nRes : in STD_LOGIC;
		Clk : in STD_LOGIC;
		s_nWr : in STD_LOGIC;
		Sel_Ram : in STD_LOGIC;
		Sel_Cont : in STD_LOGIC;
		S_nBe : in STD_LOGIC_VECTOR(1 downto 0);
		S_Adr : in STD_LOGIC_VECTOR(10 downto 1);
		S_Din : in STD_LOGIC_VECTOR(15 downto 0);
		S_Dout : out STD_LOGIC_VECTOR(15 downto 0);
		nTx_Int : out STD_LOGIC;
		nRx_Int : out STD_LOGIC;
		nTx_BegInt : out STD_LOGIC;
		Dma_Req : out STD_LOGIC;
		Dma_Rw : out STD_LOGIC;
		Dma_Ack : in STD_LOGIC;
		Dma_Addr : out STD_LOGIC_VECTOR(HighAdr downto 1);
		Dma_Dout : out STD_LOGIC_VECTOR(15 downto 0);
		Dma_Din : in STD_LOGIC_VECTOR(15 downto 0);
		rRx_Dat : in STD_LOGIC_VECTOR(1 downto 0);
		rCrs_Dv : in STD_LOGIC;
		rTx_Dat : out STD_LOGIC_VECTOR(1 downto 0);
		rTx_En : out STD_LOGIC;
		Hub_Rx : in STD_LOGIC_VECTOR(1 downto 0);
		Mac_Zeit : out STD_LOGIC_VECTOR(31 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal nRes : STD_LOGIC;
	signal Clk : STD_LOGIC;
	signal s_nWr : STD_LOGIC;
	signal Sel_Ram : STD_LOGIC;
	signal Sel_Cont : STD_LOGIC;
	signal S_nBe : STD_LOGIC_VECTOR(1 downto 0);
	signal S_Adr : STD_LOGIC_VECTOR(10 downto 1);
	signal S_Din : STD_LOGIC_VECTOR(15 downto 0);
	signal Dma_Ack : STD_LOGIC;
	signal Dma_Din : STD_LOGIC_VECTOR(15 downto 0);
	signal rRx_Dat : STD_LOGIC_VECTOR(1 downto 0);
	signal rCrs_Dv : STD_LOGIC;
	signal Hub_Rx : STD_LOGIC_VECTOR(1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal S_Dout : STD_LOGIC_VECTOR(15 downto 0);
	signal nTx_Int : STD_LOGIC;
	signal nRx_Int : STD_LOGIC;
	signal nTx_BegInt : STD_LOGIC;
	signal Dma_Req : STD_LOGIC;
	signal Dma_Rw : STD_LOGIC;
	signal Dma_Addr : STD_LOGIC_VECTOR(HighAdr downto 1);
	signal Dma_Dout : STD_LOGIC_VECTOR(15 downto 0);
	signal rTx_Dat : STD_LOGIC_VECTOR(1 downto 0);
	signal rTx_En : STD_LOGIC;
	signal Mac_Zeit : STD_LOGIC_VECTOR(31 downto 0);

	constant frameSize_c : integer := 8 + 14 + 46 + 4; --pre + header + payload + crc32
	type frame_t is array(0 to frameSize_c-1) of std_logic_vector(7 downto 0);
	signal mRxFrame : frame_t;
	
	signal config_done : std_logic;
	

begin

	-- Unit Under Test port map
	UUT : openmac
		generic map (
			HighAdr => HighAdr,
			Timer => Timer,
			TxSyncOn => TxSyncOn,
			TxDel => TxDel,
			Simulate => Simulate
		)

		port map (
			nRes => nRes,
			Clk => Clk,
			s_nWr => s_nWr,
			Sel_Ram => Sel_Ram,
			Sel_Cont => Sel_Cont,
			S_nBe => S_nBe,
			S_Adr => S_Adr,
			S_Din => S_Din,
			S_Dout => S_Dout,
			nTx_Int => nTx_Int,
			nRx_Int => nRx_Int,
			nTx_BegInt => nTx_BegInt,
			Dma_Req => Dma_Req,
			Dma_Rw => Dma_Rw,
			Dma_Ack => Dma_Ack,
			Dma_Addr => Dma_Addr,
			Dma_Dout => Dma_Dout,
			Dma_Din => Dma_Din,
			rRx_Dat => rRx_Dat,
			rCrs_Dv => rCrs_Dv,
			rTx_Dat => rTx_Dat,
			rTx_En => rTx_En,
			Hub_Rx => Hub_Rx,
			Mac_Zeit => Mac_Zeit
		);

	--stimulus
	
	--clk and rst
	theClkStim : process
	begin
		Clk <= '0';
		wait for 10ns;
		clk <= '1';
		wait for 10ns;
	end process;
	
	theResStim : process
	begin
		nRes <= '0';
		wait for 100ns;
		nRes <= '1';
		wait;
	end process;
	
	Hub_Rx <= (others => '0');
	
	theCpuStim : process(Clk, nRes)
	variable i : integer;
	begin
		if nRes = '0' then
			i := 0;
			config_done <= '0';
			
			Sel_Ram <= '0';
			Sel_Cont <= '0';
			S_Din <= (others => '0');
			S_Adr <= (others => '0');
			S_nBe <= (others => '1');
			s_nWr <= not '0';
			
		elsif Clk = '1' and Clk'event then
			--default
			Sel_Ram <= '0';
			Sel_Cont <= '0';
			S_Din <= (others => '0');
			S_Adr <= (others => '0');
			S_nBe <= (others => '1');
			s_nWr <= not '0';
			
			case i is
				when 0 to 16#5ff# =>
				--set dpr to zeros
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(i, s_adr'length);
				s_din <= conv_std_logic_vector(0, s_din'length);
				s_nbe <= not "11";
				s_nwr <= not '1';
				
				when 1540 =>
				--set rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#200#, s_adr'length);
				s_din <= conv_std_logic_vector(16#0101#, s_din'length); --owner
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1541 =>
				--set rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#201#, s_adr'length);
				s_din <= conv_std_logic_vector(1500, s_din'length); --length
				s_nbe <= "00";
				s_nwr <= not '1';
				
				when 1542 =>
				--set rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#202#, s_adr'length);
				s_din <= conv_std_logic_vector(16#1234#, s_din'length); --addr
				s_nbe <= "00";
				s_nwr <= not '1';
				
				when 1543 =>
				--set rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#203#, s_adr'length);
				s_din <= conv_std_logic_vector(16#1000#, s_din'length); --addr
				s_nbe <= "00";
				s_nwr <= not '1';
				
				when 1544 =>
				--set rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#200#, s_adr'length);
				--s_din <= conv_std_logic_vector(16#0303#, s_din'length); --owner+last
				s_din <= conv_std_logic_vector(16#0101#, s_din'length); --owner+last
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1550 =>
				--set filter
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#1f#, s_adr'length);
				s_din <= conv_std_logic_vector(16#0000#, s_din'length); --clear command reg
				s_nbe <= "10";
				s_nwr <= not '1';
				
				when 1551 to 1551+31 =>
				--set filter
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector((i-1551), s_adr'length);
				s_din <= conv_std_logic_vector(16#0000#, s_din'length); --set mask
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1583 to 1583+31 =>
				--set filter
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector((i-1583), s_adr'length);
				s_din <= conv_std_logic_vector(16#0000#, s_din'length); --set mask
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1615 =>
				--set filter
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#1f#, s_adr'length);
				s_din <= conv_std_logic_vector(16#0000#, s_din'length); --clear empty place
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1616 =>
				--set filter
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#1f#, s_adr'length);
				s_din <= conv_std_logic_vector(16#4040#, s_din'length); --enable filter
				s_nbe <= "10";
				s_nwr <= not '1';
				
				when 1620 =>
				--set tx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#2f9#, s_adr'length);
				s_din <= conv_std_logic_vector(100, s_din'length); --set length
				s_nbe <= "00";
				s_nwr <= not '1';
				
				when 1621 =>
				--set tx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#2fa#, s_adr'length);
				s_din <= conv_std_logic_vector(16#2000#, s_din'length); --set addr
				s_nbe <= "00";
				s_nwr <= not '1';
				
				when 1622 =>
				--set tx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#2f8#, s_adr'length);
				s_din <= conv_std_logic_vector(16#2101#, s_din'length); --set Beg + owner
				s_nbe <= "01";
				s_nwr <= not '1';
				
				when 1623 =>
				--set filter for tx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#1f#, s_adr'length);
				s_din <= conv_std_logic_vector(16#cfcf#, s_din'length); --txEn+FltOn + TxDesc#
				s_nbe <= "10";
				s_nwr <= not '1';
				
				when 1537 =>
				--set tx state reg
				sel_cont <= '1';
				s_adr <= conv_std_logic_vector(0, s_adr'length);
				s_din <= conv_std_logic_vector(16#A080#, s_din'length); --ie+half+run
				s_nbe <= not "11";
				s_nwr <= not '1';
				
				when 1538 =>
				--set rx state reg
				sel_cont <= '1';
				s_adr <= conv_std_logic_vector(4, s_adr'length);
				s_din <= conv_std_logic_vector(16#8080#, s_din'length); --ie+run
				s_nbe <= not "11";
				s_nwr <= not '1';
				
				when 1650 =>
				--config is done
				config_done <= '1';
				
				when 1651 =>
				--read rx desc #0
				sel_ram <= '1';
				s_adr <= conv_std_logic_vector(16#200#, s_adr'length);
				s_din <= conv_std_logic_vector(16#0000#, s_din'length);
				s_nbe <= "00";
				s_nwr <= not '0';
				
				when others =>
				
				end case;
								
			if config_done /= '1' then
				i:=i+1;
			end if;
			
		end if;
	end process;
	
	thePacketGen : process(Clk, nRes)
	variable i : integer;
	variable dibit : integer range 0 to 3;
	begin
		if nRes = '0' then
			i := 0;
			dibit := 0;
			
			rCrs_Dv <= '0';
			rRx_Dat <= (others => '0');
			
			for j in mRxFrame'range loop
				case j is
					--pre
					when 0 to 6 =>
					mRxFrame(j) <= x"55";
					when 7 =>
					mRxFrame(j) <= x"d5";					
					
					--crc
					when frameSize_c-4 + 0 =>
					mRxFrame(j) <= x"08";
					when frameSize_c-4 + 1 =>
					mRxFrame(j) <= x"89";
					when frameSize_c-4 + 2 =>
					mRxFrame(j) <= x"12";
					when frameSize_c-4 + 3 =>
					mRxFrame(j) <= x"04";
					
					when others =>
					mRxFrame(j) <= x"00";
				end case;
			end loop;
			
		elsif clk = '1' and clk'event then
			
			rCrs_Dv <= '0';
			rRx_Dat <= (others => '0');
			
			if config_done = '1' and i /= frameSize_c then
				rCrs_Dv <= '1';
				case dibit is
					when 0 =>
					rRx_Dat <= mRxFrame(i)(1 downto 0);
					when 1 =>
					rRx_Dat <= mRxFrame(i)(3 downto 2);
					when 2 =>
					rRx_Dat <= mRxFrame(i)(5 downto 4);
					when 3 =>
					rRx_Dat <= mRxFrame(i)(7 downto 6);
					i := i + 1;
					when others =>
				end case;
				if dibit = 3 then
					dibit := 0; 
				else
					dibit := dibit + 1;
				end if;
			end if;
			
		end if;
	end process;
	
	dma_din <= (others => '0');
	
	theDmaAcker : process(clk, nres)
	begin
		if nres = '0' then
			dma_ack <= '0';
		elsif clk = '1' and clk'event then
			
			dma_ack <= '0';
			if dma_req = '1' and dma_ack = '0' then
				dma_ack <= '1';
			end if;
		end if;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_openmac of openmac_tb is
	for TB_ARCHITECTURE
		for UUT : openmac
			use entity work.openmac(struct);
		end for;
	end for;
end TESTBENCH_FOR_openmac;

