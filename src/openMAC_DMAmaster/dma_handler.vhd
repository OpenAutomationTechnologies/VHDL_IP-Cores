-------------------------------------------------------------------------------
--
-- Title       : dma_handler
-- Design      : POWERLINK
--
-------------------------------------------------------------------------------
--
-- File        : C:\my_designs\POWERLINK\src\openMAC_DMAmaster\dma_handler.vhd
-- Generated   : Wed Aug  3 13:00:54 2011
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
-- 2011-08-03  	V0.01	zelenkaj    First version
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dma_handler is
	generic(
		gen_rx_fifo_g : boolean := true;
		gen_tx_fifo_g : boolean := true;
		dma_highadr_g : integer := 31;
		tx_fifo_word_size_log2_g : natural := 5;
		rx_fifo_word_size_log2_g : natural := 5
	);
	port(
		dma_clk : in std_logic;
		rst : in std_logic;
		mac_tx_on : in std_logic;
		mac_tx_off : in std_logic;
		mac_rx_on : in std_logic;
		mac_rx_off : in std_logic;
		dma_req_wr : in std_logic;
		dma_req_rd : in std_logic;
		dma_addr : in std_logic_vector(dma_highadr_g downto 1);
		dma_ack_wr : out std_logic;
		dma_ack_rd : out std_logic;
		tx_rd_clk : in std_logic;
		tx_rd_usedw : in std_logic_vector(tx_fifo_word_size_log2_g-1 downto 0);
		tx_rd_empty : in std_logic;
		tx_rd_full : in std_logic;
		tx_rd_req : out std_logic;
		rx_wr_full : in std_logic;
		rx_wr_empty : in std_logic;
		rx_wr_usedw : in std_logic_vector(rx_fifo_word_size_log2_g-1 downto 0);
		rx_wr_req : out std_logic;
		rx_aclr : out std_logic;
		rx_wr_clk : in std_logic;
		dma_addr_out : out std_logic_vector(dma_highadr_g downto 1);
		dma_new_addr_wr : out std_logic;
		dma_new_addr_rd : out std_logic
	);
end dma_handler;

architecture dma_handler of dma_handler is
--clock signal
signal clk : std_logic;

--fsm
type transfer_t is (idle, first, run);
signal tx_fsm, tx_fsm_next, rx_fsm, rx_fsm_next : transfer_t := idle;

--dma signals
signal dma_ack_rd_s, dma_ack_wr_s : std_logic;
begin
	--dma_clk, tx_rd_clk and rx_wr_clk are the same!
	clk <= dma_clk; --to ease typing
	
	rx_aclr <= rst;
	
	process(clk, rst)
	begin
		if rst = '1' then
			if gen_tx_fifo_g then
				tx_fsm <= idle;
			end if;
			if gen_rx_fifo_g then
				rx_fsm <= idle;
			end if;
		elsif clk = '1' and clk'event then
			if gen_tx_fifo_g then
				tx_fsm <= tx_fsm_next;
			end if;
			if gen_rx_fifo_g then
				rx_fsm <= rx_fsm_next;
			end if;
		end if;
	end process;
	
	tx_fsm_next <= 	idle when gen_tx_fifo_g = false else --hang here if generic disables tx handling
					first when tx_fsm = idle and dma_req_rd = '1' else
					run when tx_fsm = first else
					idle when tx_fsm = run and mac_tx_off = '1' else
					tx_fsm;
	
	rx_fsm_next <= 	idle when gen_rx_fifo_g = false else --hang here if generic disables rx handling
					first when rx_fsm = idle and dma_req_wr = '1' else
					run when rx_fsm = first else
					idle when rx_fsm = run and mac_rx_off = '1' else
					rx_fsm;
	
	dma_ack_rd <= dma_ack_rd_s;
	dma_ack_wr <= dma_ack_wr_s;
	
	dma_new_addr_wr <= '1' when rx_fsm = first else '0';
	dma_new_addr_rd <= '1' when tx_fsm = first else '0';
	
	process(clk, rst)
	begin
		if rst = '1' then
			
			dma_addr_out <= (others => '0');
			
			if gen_tx_fifo_g then
				tx_rd_req <= '0';
				dma_ack_rd_s <= '0';
			end if;
			
			if gen_rx_fifo_g then
				rx_wr_req <= '0';
				dma_ack_wr_s <= '0';
			end if;
			
		elsif clk = '1' and clk'event then
			
			--if the very first address is available, store it over the whole transfer
			if tx_fsm = first or rx_fsm = first then
				dma_addr_out <= dma_addr;
			end if;
			
			if gen_tx_fifo_g then
				tx_rd_req <= '0'; 
				dma_ack_rd_s <= '0';
				
				--dma request, TX fifo is not empty and not yet ack'd
				if dma_req_rd = '1' and tx_rd_empty = '0' and dma_ack_rd_s = '0' then
					tx_rd_req <= '1'; --read from TX fifo
					dma_ack_rd_s <= '1'; --ack the read request
				end if;
			end if;
			
			if gen_rx_fifo_g then
				rx_wr_req <= '0';
				dma_ack_wr_s <= '0';
				
				--dma request, RX fifo is not full and not yet ack'd
				if dma_req_wr = '1' and rx_wr_full = '0' and dma_ack_wr_s = '0' then
					rx_wr_req <= '1'; --write to RX fifo
					dma_ack_wr_s <= '1'; --ack the read request
				end if;
			end if;
			
		end if;
	end process;
end dma_handler;
