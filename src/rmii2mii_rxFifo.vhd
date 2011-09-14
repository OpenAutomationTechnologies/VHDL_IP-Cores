------------------------------------------------------------------------------------------------------------------------
-- RMII to MII converter rx fifo
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
--
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2011-09-14	V0.01		extract from rmii2mii.vhd
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY rxFifo IS
	PORT
	(
		aclr		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdfull		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		wrempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END rxFifo;


ARCHITECTURE SYN OF rxFifo IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL sub_wire6	: STD_LOGIC_VECTOR (4 DOWNTO 0);



	COMPONENT dcfifo_mixed_widths
	GENERIC (
		clocks_are_synchronized		: STRING;
		intended_device_family		: STRING;
		lpm_numwords		: NATURAL;
		lpm_showahead		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL;
		lpm_widthu		: NATURAL;
		lpm_widthu_r		: NATURAL;
		lpm_width_r		: NATURAL;
		overflow_checking		: STRING;
		underflow_checking		: STRING;
		use_eab		: STRING
	);
	PORT (
			aclr	: IN STD_LOGIC;
			rdclk	: IN STD_LOGIC ;
			wrempty	: OUT STD_LOGIC ;
			wrfull	: OUT STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			rdempty	: OUT STD_LOGIC ;
			rdfull	: OUT STD_LOGIC ;
			wrclk	: IN STD_LOGIC ;
			wrreq	: IN STD_LOGIC ;
			wrusedw	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			data	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			rdreq	: IN STD_LOGIC ;
			rdusedw	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	wrempty    <= sub_wire0;
	wrfull    <= sub_wire1;
	q    <= sub_wire2(1 DOWNTO 0);
	rdempty    <= sub_wire3;
	rdfull    <= sub_wire4;
	wrusedw    <= sub_wire5(3 DOWNTO 0);
	rdusedw    <= sub_wire6(4 DOWNTO 0);

	dcfifo_mixed_widths_component : dcfifo_mixed_widths
	GENERIC MAP (
		clocks_are_synchronized => "FALSE",
		intended_device_family => "Cyclone III",
		lpm_numwords => 16,
		lpm_showahead => "OFF",
		lpm_type => "dcfifo",
		lpm_width => 4,
		lpm_widthu => 4,
		lpm_widthu_r => 5,
		lpm_width_r => 2,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "OFF"
	)
	PORT MAP (
		aclr => aclr,
		rdclk => rdclk,
		wrclk => wrclk,
		wrreq => wrreq,
		data => data,
		rdreq => rdreq,
		wrempty => sub_wire0,
		wrfull => sub_wire1,
		q => sub_wire2,
		rdempty => sub_wire3,
		rdfull => sub_wire4,
		wrusedw => sub_wire5,
		rdusedw => sub_wire6
	);



END SYN;