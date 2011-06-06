------------------------------------------------------------------------------------------------------------------------
-- OpenMAC DMA FIFO
--
-- 	  Copyright (C) 2011 B&R
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
-- 2011-06-06	V0.01		added generic and export fifo word vector
------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;

entity openmac_dmafifo is
	generic (
		log2words_g	: natural := 4
	);
	port (
		aclr		: in std_logic ;
		clock		: in std_logic ;
		data		: in std_logic_vector(15 downto 0);
		rdreq		: in std_logic ;
		sclr		: in std_logic ;
		usedw		: out std_logic_vector(log2words_g-1 downto 0);
		wrreq		: in std_logic ;
		empty		: out std_logic ;
		full		: out std_logic ;
		q		: out std_logic_vector(15 downto 0)
	);
end openmac_dmafifo;


architecture syn of openmac_dmafifo is

	component scfifo
	generic (
		add_ram_output_register : string;
		lpm_numwords : natural;
		lpm_showahead : string;
		lpm_type : string;
		lpm_width : natural;
		lpm_widthu : natural;
		overflow_checking : string;
		underflow_checking : string;
		use_eab : string
	);
	port (
		rdreq : in std_logic;
		sclr : in std_logic;
		empty : out std_logic;
		aclr : in std_logic;
		clock : in std_logic;
		q : out std_logic_vector (15 downto 0);
		wrreq : in std_logic;
		data : in std_logic_vector (15 downto 0);
		full : out std_logic;
		usedw : out std_logic_vector (log2words_g-1 downto 0)
	);
	end component;

begin
	
	scfifo_component : scfifo
	generic map (
		add_ram_output_register => "on",
		lpm_numwords => 2**log2words_g,
		lpm_showahead => "off",
		lpm_type => "scfifo",
		lpm_width => 16,
		lpm_widthu => log2words_g,
		overflow_checking => "on",
		underflow_checking => "on",
		use_eab => "on"
	)
	port map (
		rdreq => rdreq,
		sclr => sclr,
		aclr => aclr,
		clock => clock,
		wrreq => wrreq,
		data => data,
		empty => empty,
		q => q,
		full => full,
		usedw => usedw
	);



end syn;
