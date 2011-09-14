------------------------------------------------------------------------------------------------------------------------
-- RMII to MII converter
-- ex: openMAC - openHUB - RMII2MII - MII PHY
--
-- 	  Copyright (C) 2009 B&R
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
-- Note: Used DPR is specific to Altera/Xilinx. Use one of the following files:
--       OpenMAC_DPR_Altera.vhd
--       OpenMAC_DPR_Xilinx.vhd
--
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2010-09-13	V0.01		first version
-- 2010-11-15	V0.02		bug fix: increased size of rx fifo, because of errors with marvel 88e1111 mii phy
-- 2010-11-30	V0.03		bug fix: in case of no link some phys confuse tx fifo during tx => aclr fifo
-- 2011-05-06	V0.10		bug fix: use the RX_ER signal, it has important meaning!
-- 2011-07-23	V0.11		forward RxErr to RMII
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rmii2mii is
	port (
		clk50				: in 	std_logic; --used by RMII as well!!!
		rst					: in 	std_logic;
		--RMII (MAC)
		rTxEn				: in	std_logic;
		rTxDat				: in 	std_logic_vector(1 downto 0);
		rRxDv				: out	std_logic;
		rRxDat				: out	std_logic_vector(1 downto 0);
		rRxEr				: out	std_logic;
		--MII (PHY)
		mTxEn				: out	std_logic;
		mTxDat				: out	std_logic_vector(3 downto 0);
		mTxClk				: in	std_logic;
		mRxDv				: in	std_logic;
		mRxEr				: in	std_logic;
		mRxDat				: in	std_logic_vector(3 downto 0);
		mRxClk				: in	std_logic
	);
end rmii2mii;

architecture rtl of rmii2mii is
begin
	
	TX_BLOCK : block
		signal fifo_half, fifo_full, fifo_empty, fifo_valid, fifo_wrempty : std_logic;
		signal fifo_wr, fifo_rd : std_logic;
		signal fifo_din : std_logic_vector(1 downto 0);
		signal fifo_dout : std_logic_vector(3 downto 0);
		signal fifo_rdUsedWord : std_logic_vector (3 downto 0);
		signal fifo_wrUsedWord : std_logic_vector (4 downto 0);
		signal clk50_n : std_logic;
		--necessary for clr fifo
		signal aclr, mTxEn_s, mTxEn_ss : std_logic;
	begin
		clk50_n <= not clk50;
		
		fifo_din <= rTxDat;
		fifo_wr <= rTxEn;
		
		mTxDat <= fifo_dout when fifo_valid = '1' else (others => '0');
		mTxEn <= fifo_valid;
		
		fifo_half <= fifo_rdUsedWord(fifo_rdUsedWord'left);
		
		process(mTxClk, rst)
		begin
			if rst = '1' then
				fifo_rd <= '0';
				fifo_valid <= '0';
			elsif mTxClk = '1' and mTxClk'event then
				if fifo_rd = '0' and fifo_half = '1' then
					fifo_rd <= '1';
				elsif fifo_rd = '1' and fifo_empty = '1' then
					fifo_rd <= '0';
				end if;
				
				if fifo_rd = '1' and fifo_rdUsedWord > conv_std_logic_vector(1, fifo_rdUsedWord'length) then
					fifo_valid <= '1';
				else
					fifo_valid <= '0';
				end if;
			end if;
		end process;
		
		theTxFifo : entity work.txFifo
			port map (
				aclr		=> aclr,
				data		=> fifo_din,
				rdclk		=> mTxClk,
				rdreq		=> fifo_rd,
				wrclk		=> clk50_n,
				wrreq		=> fifo_wr,
				q			=> fifo_dout,
				rdempty		=> fifo_empty,
				rdfull		=> open,
				rdusedw		=> fifo_rdUsedWord,
				wrempty		=> fifo_wrempty,
				wrfull		=> fifo_full,
				wrusedw		=> fifo_wrUsedWord
			);
		
		--sync Mii Tx En (=fifo_valid) to wr clk
		process(clk50_n, rst)
		begin
			if rst = '1' then
				aclr <= '1'; --reset fifo
				mTxEn_s <= '0';
				mTxEn_ss <= '0';
			elsif clk50_n = '1' and clk50_n'event then
				aclr <= '0'; --default
				
				mTxEn_ss <= fifo_valid;
				mTxEn_s <= mTxEn_ss;
				
				--clear fifo if no tx is in progress and fifo is filled
				if mTxEn_s = '0' and rTxEn = '0' and (fifo_full = '1' or fifo_wrempty = '0') then
					aclr <= '1';
				end if;				
			end if;
		end process;
		
	end block;
	
	RX_BLOCK : block
		signal fifo_half, fifo_full, fifo_empty, fifo_valid : std_logic;
		signal fifo_wr, fifo_rd : std_logic;
		signal fifo_din : std_logic_vector(3 downto 0);
		signal fifo_dout : std_logic_vector(1 downto 0);
		signal fifo_rdUsedWord : std_logic_vector(4 downto 0);
		signal fifo_wrUsedWord : std_logic_vector(3 downto 0);
		signal rRxErL, rRxErLL : std_logic;
	begin
		
		fifo_din <= mRxDat;
		fifo_wr <= mRxDv and not mRxEr;
		
		rRxDat <= fifo_dout when fifo_valid = '1' else (others => '0');
		rRxDv <= fifo_valid;
		
		fifo_half <= fifo_rdUsedWord(fifo_rdUsedWord'left);
		
		rRxEr <= rRxErLL;
		
		process(clk50, rst)
		begin
			if rst = '1' then
				fifo_rd <= '0';
				fifo_valid <= '0';
				rRxErL <= '0'; rRxErLL <= '0';
			elsif clk50 = '1' and clk50'event then
				rRxErLL <= rRxErL;
				rRxErL <= mRxEr;
				if fifo_rd = '0' and fifo_half = '1' then
					fifo_rd <= '1';
				elsif fifo_rd = '1' and fifo_empty = '1' then
					fifo_rd <= '0';
				end if;
				
				if fifo_rd = '1' and fifo_rdUsedWord > conv_std_logic_vector(1, fifo_rdUsedWord'length) then
					fifo_valid <= '1';
				else
					fifo_valid <= '0';
				end if;
			end if;
		end process;
		
		theRxFifo : entity work.rxFifo
			port map (
				aclr		=> rst,
				data		=> fifo_din,
				rdclk		=> clk50,
				rdreq		=> fifo_rd,
				wrclk		=> mRxClk,
				wrreq		=> fifo_wr,
				q			=> fifo_dout,
				rdempty		=> fifo_empty,
				rdfull		=> open,
				rdusedw		=> fifo_rdUsedWord,
				wrempty		=> open,
				wrfull		=> fifo_full,
				wrusedw		=> fifo_wrUsedWord
			);
		
	end block;
	
end rtl;
