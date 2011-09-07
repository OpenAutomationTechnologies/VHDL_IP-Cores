-------------------------------------------------------------------------------
--
-- Title       : delay_pulse
-- Design      : POWERLINK
--
-------------------------------------------------------------------------------
--
-- File        : C:\my_designs\POWERLINK\src\lib\delay_pulse.vhd
-- Generated   : Mon Aug  8 17:11:08 2011
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
--    (c) B&R, 2011
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
-------------------------------------------------------------------------------
--
-- 2011-08-08  	V0.01	zelenkaj    First version
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

entity delay_pulse is
	generic(
		delay_g : natural := 1
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		in_p : in std_logic;
		out_p : out std_logic
	);
end delay_pulse;

architecture rtl of delay_pulse is
constant iMaxCnt : integer := delay_g;
constant iMaxCntLog2 : integer := integer(ceil(log2(real(iMaxCnt))));

signal cnt, cnt_next : std_logic_vector(iMaxCntLog2 downto 0);
signal cnt_tc, cnt_en : std_logic;
begin
	
	process(clk, rst)
	begin
		if rst = '1' then
			cnt_en <= '0';
			cnt <= (others => '0');
		elsif clk = '1' and clk'event then
			cnt <= cnt_next;
			
			if in_p = '1' then
				cnt_en <= '1';
			elsif cnt_tc = '1' then
				cnt_en <= '0';
			end if;
		end if;
	end process;
	
	cnt_next <= cnt + 1 when cnt_en = '1' else (others => '0');
	
	cnt_tc <= '1' when cnt = iMaxCnt-1 and cnt_en = '1' else '0';
	
	out_p <= cnt_tc;
	
end rtl;
