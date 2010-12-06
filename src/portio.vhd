------------------------------------------------------------------------------------------------------------------------
-- Simple Port I/O
--
-- 	  Copyright (C) 2010 B&R
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
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2010-08-16  	V0.01	zelenkaj    First version
-- 2010-10-04  	V0.02	zelenkaj	Bugfix: PORTDIR was mapped incorrectly (according to doc) to Avalon bus
-- 2010-11-23	V0.03	zelenkaj	Added Operational Flag to portio
--									Added counter for valid assertion duration
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity portio is
	generic (
		pioValLen_g 	:		integer := 50 --clock ticks of pcp_clk
	);
	port (
		s0_address    	: in    std_logic;
		s0_read       	: in    std_logic;
		s0_readdata   	: out   std_logic_vector(31 downto 0);
		s0_write      	: in    std_logic;
		s0_writedata  	: in    std_logic_vector(31 downto 0);
		s0_byteenable 	: in    std_logic_vector(3 downto 0);
		clk        		: in    std_logic;
		reset      		: in    std_logic;
		x_pconfig    	: in    std_logic_vector(3 downto 0);
		x_portInLatch	: in 	std_logic_vector(3 downto 0);
		x_portOutValid 	: out 	std_logic_vector(3 downto 0);
		x_portio     	: inout std_logic_vector(31 downto 0);
		x_operational 	: out 	std_logic
	);
end entity portio;

architecture rtl of portio is
	signal sPortConfig : std_logic_vector(x_pconfig'range);
	signal sPortOut : std_logic_vector(x_portio'range);
	signal sPortIn, sPortInL : std_logic_vector(x_portio'range);
	signal x_operational_s : std_logic;
	signal x_portOutValid_s : std_logic_vector(x_portOutValid'range);
begin

	sPortConfig <= x_pconfig;
	x_operational <= x_operational_s;
	
	portGen : for i in 3 downto 0 generate
		--if port configuration bit is set to '0', the appropriate port-byte is an output
		x_portio((i+1)*8-1 downto (i+1)*8-8) 	<= sPortOut((i+1)*8-1 downto (i+1)*8-8) when sPortConfig(i) = '0' else (others => 'Z');
		--if port configuration bit is set to '1', the appropriate port-byte is forwarded to the portio registers for the PCP
		sPortIn((i+1)*8-1 downto (i+1)*8-8)		<= x_portio((i+1)*8-1 downto (i+1)*8-8) when sPortConfig(i) = '1' else (others => '0');
	end generate;
	
	--Avalon interface
	avalonPro : process(clk, reset)
	begin
		if reset = '1' then
			s0_readdata <= (others => '0');
			x_portOutValid_s <= (others => '0');
			sPortOut <= (others => '0');
			x_operational_s <= '0';
			
		elsif clk = '1' and clk'event then
			s0_readdata <= (others => '0');
			x_portOutValid_s <= (others => '0');
			
			if s0_write = '1' then
				case s0_address is
					when '0' =>	--write port
						for i in 3 downto 0 loop
							if s0_byteenable(i) = '1' then
								sPortOut((i+1)*8-1 downto (i+1)*8-8) <= s0_writedata((i+1)*8-1 downto (i+1)*8-8);
								x_portOutValid_s(i) <= '1';
							end if;
						end loop;
					when '1' => --write to config register operational flag
						if s0_byteenable(3) = '1' then
							x_operational_s <= s0_writedata(s0_writedata'left);
						end if;
					when others =>
				end case;
				
			elsif s0_read = '1' then
				case s0_address is
					when '0' =>	--read port
						s0_readdata <= sPortInL;
					when '1' =>	--read port config
						s0_readdata <= x_operational_s & "000" & x"00000" & x"0" & sPortConfig;
					when others =>
							s0_readdata <= x"deadc0de";
				end case;
				
			end if;
		end if;
	end process;
	
	thePortioCnters : for i in 0 to 3 generate
		thePortioCnt : entity work.portio_cnt
		generic map (
			maxVal =>	pioValLen_g
		)
		port map (
			clk => clk,
			rst => reset,
			pulse => x_portOutValid_s(i),
			valid => x_portOutValid(i)
		);
	end generate;
	
	--latch input signals
	latchInPro : process(clk, reset)
	begin
		if reset = '1' then
			sPortInL <= (others => '0');
		elsif clk = '1' and clk'event then
			
			for i in 3 downto 0 loop
				if x_portInLatch(i) = '1' then
					sPortInL((i+1)*8-1 downto (i+1)*8-8) <= sPortIn((i+1)*8-1 downto (i+1)*8-8);
				end if;
			end loop;
			
		end if;
	end process;
	
end architecture rtl;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity portio_cnt is
	generic (
		maxVal 			:		integer := 50 --clock ticks of pcp_clk
	);
	port (
		clk				:		in std_logic;
		rst				:		in std_logic;
		pulse			:		in std_logic;
		valid			:		out std_logic
	);
end entity portio_cnt;

architecture rtl of portio_cnt is
signal cnt : integer range 0 to maxVal-2;
signal tc, en : std_logic;
begin
	genCnter : if maxVal > 1 generate
		tc <= '1' when cnt = maxVal-2 else '0';
		valid <= en or pulse;
		
		counter : process(clk, rst)
		begin
			if rst = '1' then
				cnt <= 0;
			elsif clk = '1' and clk'event then
				if tc = '1' then
					cnt <= 0;
				elsif en = '1' then
					cnt <= cnt + 1;
				else
					cnt <= 0;
				end if;
			end if;
		end process;
		
		enGen : process(clk, rst)
		begin
			if rst = '1' then
				en <= '0';
			elsif clk = '1' and clk'event then
				if pulse = '1' then
					en <= '1';
				elsif tc = '1' then
					en <= '0';
				end if;
			end if;
		end process;
	end generate;
	
	genSimple : if maxVal = 1 generate
		valid <= pulse;
	end generate;
	
end architecture rtl;
