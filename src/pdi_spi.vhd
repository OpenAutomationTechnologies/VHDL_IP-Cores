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
-- 2010-08-31  V0.01	zelenkaj    First version
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pdi_spi is
	generic (
		spiSize_g			: integer	:= 8;
		cpol_g				: boolean	:= false;
		cpha_g				: boolean	:= false
	);
			
	port (   
		-- SPI
		spi_clk				: in 	std_logic;
		spi_sel				: in 	std_logic;
		spi_miso			: out 	std_logic;
		spi_mosi			: in 	std_logic;
		-- clock for AP side
		ap_reset			: in    std_logic;
		ap_clk				: in	std_logic;
		-- Avalon Slave Interface for AP
        ap_chipselect       : out	std_logic;
        ap_read				: out	std_logic;
        ap_write			: out	std_logic;
        ap_byteenable       : out	std_logic_vector(3 DOWNTO 0);
        ap_address          : out	std_logic_vector(12 DOWNTO 0);
        ap_writedata        : out	std_logic_vector(31 DOWNTO 0);
        ap_readdata         : in	std_logic_vector(31 DOWNTO 0)
	);
end entity pdi_spi;

architecture rtl of pdi_spi is
--spi frame constants
constant cmdHighaddr_c		:		std_logic_vector(2 downto 0)	:= "100";
constant cmdMidaddr_c		:		std_logic_vector(2 downto 0)	:= "101";
constant cmdWr_c			:		std_logic_vector(2 downto 0)	:= "110";
constant cmdRd_c			:		std_logic_vector(2 downto 0)	:= "111";
constant cmdIdle_c			:		std_logic_vector(2 downto 0)	:= "0--";
--pdi_spi control signals
type fsm_t is (idle, decode, waitwr, waitrd, wr, rd);
signal	fsm					:		fsm_t;
signal	addrReg				:		std_logic_vector(ap_address'left+2 downto 0);
signal	cmd					:		std_logic_vector(2 downto 0);
--spi core signals
signal	clk					:  		std_logic;
signal	rst					:  		std_logic;
signal	din					:  		std_logic_vector(spiSize_g-1 downto 0);
signal	load				: 		std_logic;
signal	dout				:  		std_logic_vector(spiSize_g-1 downto 0);
signal	valid				: 		std_logic;
begin
	
	clk <= ap_clk;
	rst <= ap_reset;
	
	ap_chipselect <= '1' when fsm = wr or fsm = rd or fsm = waitrd else '0';
	ap_write <= '1' when fsm = wr else '0';
	ap_read <= '1' when fsm = waitrd or fsm = rd else '0';
	ap_address <= addrReg(addrReg'left downto 2);
	ap_byteenable <=	"0001" when addrReg(1 downto 0) = "00" else
						"0010" when addrReg(1 downto 0) = "01" else
						"0100" when addrReg(1 downto 0) = "10" else
						"1000" when addrReg(1 downto 0) = "11" else
						"0000";
	
	ap_writedata <=		(x"00" & x"00" & x"00" & dout)	when addrReg(1 downto 0) = "00" else
						(x"00" & x"00" & dout & x"00")	when addrReg(1 downto 0) = "01" else
						(x"00" & dout & x"00" & x"00")	when addrReg(1 downto 0) = "10" else
						(dout & x"00" & x"00" & x"00")	when addrReg(1 downto 0) = "11" else
						(others => '0');
	
	din <=				ap_readdata( 7 downto  0) when addrReg(1 downto 0) = "00" else
						ap_readdata(15 downto  8) when addrReg(1 downto 0) = "01" else
						ap_readdata(23 downto 16) when addrReg(1 downto 0) = "10" else
						ap_readdata(31 downto 24) when addrReg(1 downto 0) = "11" else
						(others => '0');
	
	load <= '1' when fsm = rd else '0'; --load data from pdi to spi shift register
	
	cmd <= dout(dout'left downto dout'left-2); --get cmd pattern
	
	thePdiSpiFsm : process(clk, rst)
	variable timeout : integer range 0 to 3;
	begin
		if rst = '1' then
			fsm <= idle;
			timeout := 0;
			addrReg <= (others => '0');
		elsif clk = '1' and clk'event then
			
			case fsm is
				when idle =>
					if valid = '1' then
						fsm <= decode;
					else
						fsm <= idle;
					end if;
					
				when decode =>
					fsm <= idle; --default
					case cmd is
						when cmdHighaddr_c =>
							addrReg(addrReg'left downto addrReg'left-4) <= dout(spiSize_g-4 downto 0);
						when cmdMidaddr_c =>
							addrReg(addrReg'left-5 downto addrReg'left-9) <= dout(spiSize_g-4 downto 0);
						when cmdWr_c =>
							addrReg(addrReg'left-10 downto 0) <= dout(spiSize_g-4 downto 0);
							fsm <= waitwr;
						when cmdRd_c =>
							addrReg(addrReg'left-10 downto 0) <= dout(spiSize_g-4 downto 0);
							fsm <= waitrd;
						when cmdIdle_c =>
							--don't interpret the command 
						when others =>
							--error => idle
					end case;
					
				when waitwr =>
					--wait for data from spi master
					if valid = '1' then
						fsm <= wr;
						--data is stored in dout
					else
						fsm <= waitwr;
					end if;
					
				when waitrd =>
					--spi master wants to read
					--wait for dpr to read
					if timeout = 3 then
						fsm <= rd;
						timeout := 0;
					else
						timeout := timeout + 1;
						fsm <= waitrd;
					end if;
					
				when wr =>
					fsm <= idle;
				
				when rd =>
					fsm <= idle;
				
			end case;
			
		end if;
	end process;
	
	theSpiCore : entity work.spi
	generic map (
		frameSize_g			=> spiSize_g,
		cpol_g				=> cpol_g,
		cpha_g				=> cpha_g
	)
	port map (
		-- Control Interface
		clk					=> clk,
		rst					=> rst,
		din					=> din,
		load				=> load,
		dout				=> dout,
		valid				=> valid,
		-- SPI
		sck					=> spi_clk,
		ss					=> spi_sel,
		miso				=> spi_miso,
		mosi				=> spi_mosi
	);
	
end architecture rtl;
