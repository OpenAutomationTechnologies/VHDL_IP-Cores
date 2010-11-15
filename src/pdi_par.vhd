------------------------------------------------------------------------------------------------------------------------
-- Parallel port (8/16bit) for PDI
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
-- 2010-08-31  	V0.01	zelenkaj    First version
-- 2010-10-18	V0.02	zelenkaj	added selection Big/Little Endian
--									use bidirectional data bus
-- 2010-11-15	V0.03	zelenkaj	bug fix for 16bit parallel interface
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pdi_par is
	generic (
	papDataWidth_g				:		integer := 8;
	--16bit data is big endian if true
	papBigEnd_g					:		boolean := false
	);
			
	port (   
			-- 8/16bit parallel
			pap_cs						: in    std_logic;
			pap_rd						: in    std_logic;
			pap_wr 						: in    std_logic;
			pap_be						: in    std_logic_vector(papDataWidth_g/8-1 downto 0);
			pap_addr 					: in    std_logic_vector(15 downto 0);
--			pap_wrdata					: in    std_logic_vector(papDataWidth_g-1 downto 0);
--			pap_rddata					: out   std_logic_vector(papDataWidth_g-1 downto 0);
--			pap_doe						: out	std_logic;
			pap_data					: inout	std_logic_vector(papDataWidth_g-1 downto 0);
			pap_ready					: out	std_logic;
		-- clock for AP side
			ap_reset					: in    std_logic;
			ap_clk						: in	std_logic;
		-- Avalon Slave Interface for AP
            ap_chipselect               : out	std_logic;
            ap_read						: out	std_logic;
            ap_write					: out	std_logic;
            ap_byteenable             	: out	std_logic_vector(3 DOWNTO 0);
            ap_address                  : out	std_logic_vector(12 DOWNTO 0);
            ap_writedata                : out	std_logic_vector(31 DOWNTO 0);
            ap_readdata                 : in	std_logic_vector(31 DOWNTO 0)
	);
end entity pdi_par;

architecture rtl of pdi_par is
	type fsm_t is (idle, wr, rd, wr_ack, rd_ack);
	signal	fsm							:		fsm_t;
	
	signal ap_byteenable_s				:		std_logic_vector(ap_byteenable'range);
	signal pap_doe_s					:		std_logic;
	signal pap_wrdata, pap_rddata		:		std_logic_vector(papDataWidth_g-1 downto 0);
begin
	
	pap_ready <= '1' when fsm = wr_ack or fsm = rd_ack else '0';
	pap_doe_s <= '1' when fsm = rd or fsm = rd_ack else '0';
--	pap_doe <= pap_doe_s;
	
	ap_chipselect <= '1' when fsm = wr or fsm = rd or fsm = rd_ack else '0';
	ap_write <= '1' when fsm = wr else '0';
	ap_read <= '1' when fsm = rd or fsm = rd_ack else '0';
	ap_address <= pap_addr(ap_address'left+2 downto 2);
	
	gen8bitSigs : if papDataWidth_g = 8 generate
		--tri-state buffer
		pap_data <= pap_rddata when pap_doe_s = '1' else (others => 'Z');
		pap_wrdata <= pap_data;
		
		ap_byteenable_s <= 	"0001" when pap_addr(1 downto 0) = "00" else
							"0010" when pap_addr(1 downto 0) = "01" else
							"0100" when pap_addr(1 downto 0) = "10" else
							"1000" when pap_addr(1 downto 0) = "11" else
							(others => '0');
		ap_byteenable <= ap_byteenable_s;
		
		pap_rddata <= 		(others => '0') when pap_doe_s = '0' else
							ap_readdata( 7 downto  0) when ap_byteenable_s = "0001" else
							ap_readdata(15 downto  8) when ap_byteenable_s = "0010" else
							ap_readdata(23 downto 16) when ap_byteenable_s = "0100" else
							ap_readdata(31 downto 24) when ap_byteenable_s = "1000" else
							(others => '0'); --may not be the case
		ap_writedata <=		pap_wrdata & pap_wrdata & pap_wrdata & pap_wrdata;
	end generate gen8bitSigs;
	
	genBeSigs16bit : if papDataWidth_g = 16 generate
		--tri-state buffer + endian consideration
		pap_data <= pap_rddata 	when pap_doe_s = '1' and papBigEnd_g = false else
					pap_rddata(papDataWidth_g/2-1 downto 0) &
					pap_rddata(papDataWidth_g-1 downto papDataWidth_g/2)
								when pap_doe_s = '1' and papBigEnd_g = true else
					(others => 'Z');
		pap_wrdata <= pap_data 	when papBigEnd_g = false else
					pap_data(papDataWidth_g/2-1 downto 0) &
					pap_data(papDataWidth_g-1 downto papDataWidth_g/2)
								when papBigEnd_g = true else
					(others => '0');
		
		ap_byteenable_s <= 	"0001" when pap_addr(1 downto 1) = "0" and pap_be = "01" else
							"0010" when pap_addr(1 downto 1) = "0" and pap_be = "10" else
							"0011" when pap_addr(1 downto 1) = "0" and pap_be = "11" else
							"0100" when pap_addr(1 downto 1) = "1" and pap_be = "01" else
							"1000" when pap_addr(1 downto 1) = "1" and pap_be = "10" else
							"1100" when pap_addr(1 downto 1) = "1" and pap_be = "11" else
							(others => '0');
		ap_byteenable <= ap_byteenable_s;
		
		pap_rddata <= 		(others => '0') when pap_doe_s = '0' else
							ap_readdata( 7 downto  0) & ap_readdata( 7 downto  0) when ap_byteenable_s = "0001" else
							ap_readdata(15 downto  8) & ap_readdata(15 downto  8) when ap_byteenable_s = "0010" else
							ap_readdata(15 downto  0) when ap_byteenable_s = "0011" else
							ap_readdata(23 downto 16) & ap_readdata(23 downto 16) when ap_byteenable_s = "0100" else
							ap_readdata(31 downto 24) & ap_readdata(31 downto 24) when ap_byteenable_s = "1000" else
							ap_readdata(31 downto 16) when ap_byteenable_s = "1100" else
							(others => '0'); --may not be the case
		ap_writedata <=		pap_wrdata & pap_wrdata;
	end generate genBeSigs16bit;
	
	theFsm : process(ap_clk, ap_reset)
	variable timeout : integer range 0 to 2;
	begin
		if ap_reset = '1' then
			fsm <= idle;
			timeout := 0;
		elsif ap_clk = '1' and ap_clk'event then
			case fsm is
				when idle =>
					--exit idle state after timeout if read/write access
					if timeout = 2 and pap_cs = '1' then
						timeout := 0;
						if pap_rd = '1' then
							fsm <= rd;
						elsif pap_wr = '1' then
							fsm <= wr;
						else
							fsm <= idle;
						end if;
					elsif pap_cs = '1' then
						--cs is present wait for stable signals
						timeout := timeout + 1;
						fsm <= idle;
					else
						timeout := 0;
						fsm <= idle;
					end if;
					
				when wr =>
					--write access may last one cycle
					fsm <= wr_ack;
					
				when rd =>
					--read access takes 2 cycles + 1
					if timeout = 2 then
						fsm <= rd_ack;
						timeout := 0;
					else
						timeout := timeout + 1;
						fsm <= rd;
					end if;
					
				when wr_ack =>
					--wait for deassertion of wr
					if pap_wr = '0' then
						fsm <= idle;
					else
						fsm <= wr_ack;
					end if;
					
				when rd_ack =>
					--wait for deassertion of rd
					if pap_rd = '0' then
						fsm <= idle;
					else
						fsm <= rd_ack;
					end if;
					
			end case;
		end if;
	end process;
	
end architecture rtl;
