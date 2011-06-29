------------------------------------------------------------------------------------------------------------------------
-- Process Data Interface (PDI) for
--	POWERLINK Communication Processor (PCP): Avalon
--	Application Processor (AP): Avalon
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
-- 2010-06-28  	V0.01	zelenkaj    First version
-- 2010-08-16  	V0.10	zelenkaj	Added the possibility for more RPDOs
-- 2010-08-23  	V0.11	zelenkaj	Added IRQ generation
-- 2010-10-04  	V0.12	zelenkaj	Changed memory size calculation (e.g. generics must include header size)
-- 2010-10-11  	V0.13	zelenkaj	Bugfix: PCP can't be producer in any case => added generic
-- 2010-10-25	V0.14	zelenkaj	Use one Address Adder per DPR port side (reduces LE usage)
-- 2010-11-08	V0.15	zelenkaj	Add 8 bytes to control reg of pdi mapped to dpr
-- 2010-11-23	V0.16	zelenkaj	Omitted T/RPDO descriptor sections in DPR
--									Omitted "HEX Words" (e.g. DEADC0DE, C00FFEE) and replaced with ZEROS
-- 2011-03-21	V0.17	zelenkaj	clean up
-- 2011-03-28	V0.20	zelenkaj	Changed: Structure of Control/Status Register
--									Added: LED
--									Added: Events
--									Added/Changed: Asynchronous buffer 2x Ping-Pong
-- 2011-04-06	V0.21	zelenkaj	minor fix: activity is only valid if link is present
-- 2011-04-26	V0.22	zelenkaj	generic for clock domain selection
--									area optimization in Status/Control Register
-- 2011-04-28  	V0.23	zelenkaj	clean up to reduce Quartus II warnings
-- 2011-05-06	V0.24	zelenkaj	some naming convention changes
-- 2011-05-09	V0.25	zelenkaj	minor change in edge detector and syncs (reset to zero)
-- 2011-06-06	V0.26	zelenkaj	status/control register enhanced by 8 bytes
-- 2011-06-10	V0.27	zelenkaj	bug fix: if dpr size goes below 2**10, error of dpr address width
-- 2011-06-29	V0.28	zelenkaj	bug fix: led control was gone and dpr addr width still buggy
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
USE work.memMap.all; --used for memory mapping (alignment, ...)

entity pdi is
	generic (
			genOnePdiClkDomain_g		:		boolean := false;
			iPdiRev_g					:		integer := 0; --for HW/SW match verification (0..65535)
			iRpdos_g					:		integer := 3;
			iTpdos_g					:		integer := 1;
			--PDO buffer size *3
			iTpdoBufSize_g				:		integer := 100;
			iRpdo0BufSize_g				:		integer := 116; --includes header
			iRpdo1BufSize_g				:		integer := 116; --includes header
			iRpdo2BufSize_g				:		integer := 116; --includes header
			--asynchronous buffer size
			iABuf1_g					:		integer := 512; --includes header
			iABuf2_g					:		integer := 512  --includes header
	);
			
	port (   
			pcp_reset					: in    std_logic;
			pcp_clk                  	: in    std_logic;
			ap_reset					: in    std_logic;
			ap_clk						: in	std_logic;
		-- Avalon Slave Interface for PCP
            pcp_chipselect            	: in    std_logic;
            pcp_read					: in    std_logic;
            pcp_write					: in    std_logic;
            pcp_byteenable	        	: in    std_logic_vector(3 DOWNTO 0);
            pcp_address               	: in    std_logic_vector(12 DOWNTO 0);
            pcp_writedata             	: in    std_logic_vector(31 DOWNTO 0);
            pcp_readdata              	: out   std_logic_vector(31 DOWNTO 0);
			pcp_irq						: in	std_logic; --should be connected to the Time Cmp Toggle of openMAC!
		-- Avalon Slave Interface for AP
            ap_chipselect               : in    std_logic;
            ap_read						: in    std_logic;
            ap_write					: in    std_logic;
            ap_byteenable             	: in    std_logic_vector(3 DOWNTO 0);
            ap_address                  : in    std_logic_vector(12 DOWNTO 0);
            ap_writedata                : in    std_logic_vector(31 DOWNTO 0);
            ap_readdata                 : out   std_logic_vector(31 DOWNTO 0);
			ap_irq						: out	std_logic; --Sync Irq to the AP
		-- async interrupt
			ap_asyncIrq					: out	std_logic; --Async Irq to the Ap
		-- LED
			ledsOut						: out	std_logic_vector(7 downto 0); --LEDs: O1, O0, PA1, PL1, PA0, PL0, E, S
			phyLink						: in	std_logic_vector(1 downto 0); --link: phy1, phy0
			phyAct						: in	std_logic_vector(1 downto 0); --acti: phy1, phy0
		--PDI change buffer triggers
			rpdo_change_tog				: in	std_logic_vector(2 downto 0);
			tpdo_change_tog				: in	std_logic
	);
end entity pdi;

architecture rtl of pdi is
------------------------------------------------------------------------------------------------------------------------
--types
---for pcp and ap side
type pdiSel_t is
	record
			pcp 						: std_logic;
			ap 							: std_logic;
	end record;
type pdiTrig_t is
	record
			pcp 						: std_logic_vector(3 downto 0);
			ap 							: std_logic_vector(3 downto 0);
	end record;
type pdi32Bit_t is
	record
			pcp 						: std_logic_vector(31 downto 0);
			ap 							: std_logic_vector(31 downto 0);
	end record;
------------------------------------------------------------------------------------------------------------------------
--constants
---memory mapping from outside (e.g. Avalon or SPI)
----max memory span of one space
constant	extMaxOneSpan				: integer := 2 * 1024; --2kB
constant	extLog2MaxOneSpan			: integer := integer(ceil(log2(real(extMaxOneSpan))));
----control / status register
constant	extCntStReg_c				: memoryMapping_t := (16#0000#, 16#70#);
----asynchronous buffers
constant	extABuf1Tx_c				: memoryMapping_t := (16#0800#, iABuf1_g); --header is included in generic value!
constant	extABuf1Rx_c				: memoryMapping_t := (16#1000#, iABuf1_g); --header is included in generic value!
constant	extABuf2Tx_c				: memoryMapping_t := (16#1800#, iABuf2_g); --header is included in generic value!
constant	extABuf2Rx_c				: memoryMapping_t := (16#2000#, iABuf2_g); --header is included in generic value!
----pdo buffer
constant	extTpdoBuf_c				: memoryMapping_t := (16#2800#, iTpdoBufSize_g); --header is included in generic value!
constant	extRpdo0Buf_c				: memoryMapping_t := (16#3000#, iRpdo0BufSize_g); --header is included in generic value!
constant	extRpdo1Buf_c				: memoryMapping_t := (16#3800#, iRpdo1BufSize_g); --header is included in generic value!
constant	extRpdo2Buf_c				: memoryMapping_t := (16#4000#, iRpdo2BufSize_g); --header is included in generic value!
---memory mapping inside the PDI's DPR
----control / status register
constant	intCntStReg_c				: memoryMapping_t := (16#0000#, 9 * 4); --bytes mapped to dpr (dword alignment!!!)
----asynchronous buffers
constant	intABuf1Tx_c				: memoryMapping_t := (intCntStReg_c.base + intCntStReg_c.span, align32(extABuf1Tx_c.span));
constant	intABuf1Rx_c				: memoryMapping_t := (intABuf1Tx_c.base + intABuf1Tx_c.span, align32(extABuf1Rx_c.span));
constant	intABuf2Tx_c				: memoryMapping_t := (intABuf1Rx_c.base + intABuf1Rx_c.span, align32(extABuf2Tx_c.span));
constant	intABuf2Rx_c				: memoryMapping_t := (intABuf2Tx_c.base + intABuf2Tx_c.span, align32(extABuf2Rx_c.span));
----pdo buffers (triple buffers considered!)
constant	intTpdoBuf_c				: memoryMapping_t := (intABuf2Rx_c.base + intABuf2Rx_c.span, align32(extTpdoBuf_c.span) *3);
constant	intRpdo0Buf_c				: memoryMapping_t := (intTpdoBuf_c.base  + intTpdoBuf_c.span,  align32(extRpdo0Buf_c.span)*3);
constant	intRpdo1Buf_c				: memoryMapping_t := (intRpdo0Buf_c.base + intRpdo0Buf_c.span, align32(extRpdo1Buf_c.span)*3);
constant	intRpdo2Buf_c				: memoryMapping_t := (intRpdo1Buf_c.base + intRpdo1Buf_c.span, align32(extRpdo2Buf_c.span)*3);
----obtain dpr size of different configurations
constant	dprSize_c					: integer := (	intCntStReg_c.span +
														intABuf1Tx_c.span +
														intABuf1Rx_c.span +
														intABuf2Tx_c.span +
														intABuf2Rx_c.span +
														intTpdoBuf_c.span  +
														intRpdo0Buf_c.span +
														intRpdo1Buf_c.span +
														intRpdo2Buf_c.span );
constant	dprAddrWidth_c				: integer := integer(ceil(log2(real(dprSize_c))));
---other constants
constant	magicNumber_c				: integer := 16#50435000#;
constant	pdiRev_c					: integer := iPdiRev_g;
														
------------------------------------------------------------------------------------------------------------------------
--signals
---dpr
type dprSig_t is
	record
			addr						: std_logic_vector(dprAddrWidth_c-2-1 downto 0); --double word address!
			addrOff						: std_logic_vector(dprAddrWidth_c-2 downto 0); --double word address!
			be							: std_logic_vector(3 downto 0);
			din							: std_logic_vector(31 downto 0);
			wr							: std_logic;
	end record;
type dprPdi_t is
	record
			pcp							: dprSig_t;
			ap							: dprSig_t;
	end record;
----signals to the DPR
signal		dpr							: dprPdi_t;
signal		dprOut						: pdi32Bit_t;
----control / status register
signal		dprCntStReg_s				: dprPdi_t;
----asynchronous buffers
signal		dprABuf1Tx_s				: dprPdi_t;
signal		dprABuf1Rx_s				: dprPdi_t;
signal		dprABuf2Tx_s				: dprPdi_t;
signal		dprABuf2Rx_s				: dprPdi_t;
----pdo buffers (triple buffers considered!)
signal		dprTpdoBuf_s				: dprPdi_t := (((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'),
														((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'));
signal		dprRpdo0Buf_s				: dprPdi_t := (((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'),
														((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'));
signal		dprRpdo1Buf_s				: dprPdi_t := (((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'),
														((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'));
signal		dprRpdo2Buf_s				: dprPdi_t := (((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'),
														((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0'));
---chip select
----control / status register
signal		selCntStReg_s				: pdiSel_t;
----asynchronous buffers
signal		selABuf1Tx_s				: pdiSel_t;
signal		selABuf1Rx_s				: pdiSel_t;
signal		selABuf2Tx_s				: pdiSel_t;
signal		selABuf2Rx_s				: pdiSel_t;
----pdo buffers (triple buffers considered!)
signal		selTpdoBuf_s				: pdiSel_t;
signal		selRpdo0Buf_s				: pdiSel_t;
signal		selRpdo1Buf_s				: pdiSel_t;
signal		selRpdo2Buf_s				: pdiSel_t;
---data output
----control / status register
signal		outCntStReg_s				: pdi32Bit_t;
----asynchronous buffers
signal		outABuf1Tx_s				: pdi32Bit_t;
signal		outABuf1Rx_s				: pdi32Bit_t;
signal		outABuf2Tx_s				: pdi32Bit_t;
signal		outABuf2Rx_s				: pdi32Bit_t;
----pdo buffers (triple buffers considered!)
signal		outTpdoBuf_s				: pdi32Bit_t := ((others => '0'), (others => '0'));
signal		outRpdo0Buf_s				: pdi32Bit_t := ((others => '0'), (others => '0'));
signal		outRpdo1Buf_s				: pdi32Bit_t := ((others => '0'), (others => '0'));
signal		outRpdo2Buf_s				: pdi32Bit_t := ((others => '0'), (others => '0'));
---virtual buffer control/state
signal		vBufTriggerPdo_s			: pdiTrig_t; --tpdo, rpdo2, rpdo1, rpdo0
signal		vBufSel_s					: pdi32Bit_t := ((others => '1'), (others => '1')); --TXPDO_ACK | RXPDO2_ACK | RXPDO1_ACK | RXPDO0_ACK
---ap irq generation
signal		apIrqValue					: std_logic_vector(31 downto 0);
signal		apIrqControlPcp,
			apIrqControlPcp2,
			apIrqControlApOut,
			apIrqControlApIn			: std_logic_vector(15 downto 0);
signal		ap_irq_s					: std_logic;
---address calulation result
signal		pcp_addrRes					: std_logic_vector(dprAddrWidth_c-2 downto 0);
signal		ap_addrRes					: std_logic_vector(dprAddrWidth_c-2 downto 0);

---EVENT stuff
signal		pcp_eventSet_s, --pulse to set event
			pcp_eventRead				: std_logic_vector(15 downto 0);
signal		ap_eventAck_p, --pulse to ack event
			ap_eventAck					: std_logic_vector(15 downto 0);
signal		asyncIrqCtrlOut_s,
			asyncIrqCtrlIn_s			: std_logic_vector(15 downto 0);
signal		ap_asyncIrq_s				: std_logic; --Async Irq to the Ap
signal		phyLink_s,
			phyLinkEvent				: std_logic_vector(phyLink'range);

--LED stuff
signal		pcp_ledForce_s,
			pcp_ledSet_s				: std_logic_vector(15 downto 0);
signal		ap_ledForce_s,
			ap_ledSet_s					: std_logic_vector(15 downto 0);
signal		hw_ledForce_s,
			hw_ledSet_s					: std_logic_vector(15 downto 0);
begin
	
	ASSERT NOT(iRpdos_g < 1 or iRpdos_g > 3)
		REPORT "Only 1, 2 or 3 Rpdos are supported!" 
		severity failure;
		
	ASSERT NOT(iTpdos_g /= 1)
		REPORT "Only 1 Tpdo is supported!"
			severity failure;

------------------------------------------------------------------------------------------------------------------------
-- merge data to pcp/ap
	theMerger : block
	begin
		pcp_readdata	<=	outCntStReg_s.pcp	when 	selCntStReg_s.pcp = '1' else
							outABuf1Tx_s.pcp	when	selABuf1Tx_s.pcp  = '1' else
							outABuf1Rx_s.pcp	when	selABuf1Rx_s.pcp  = '1' else
							outABuf2Tx_s.pcp	when	selABuf2Tx_s.pcp  = '1' else
							outABuf2Rx_s.pcp	when	selABuf2Rx_s.pcp  = '1' else
							outTpdoBuf_s.pcp	when	selTpdoBuf_s.pcp  = '1' else
							outRpdo0Buf_s.pcp	when	selRpdo0Buf_s.pcp = '1' else
							outRpdo1Buf_s.pcp	when	selRpdo1Buf_s.pcp = '1'	else
							outRpdo2Buf_s.pcp	when	selRpdo2Buf_s.pcp = '1' else
							(others => '0');
		
		ap_readdata	<=		outCntStReg_s.ap	when 	selCntStReg_s.ap = '1' else
							outABuf1Tx_s.ap 	when	selABuf1Tx_s.ap  = '1' else
							outABuf1Rx_s.ap 	when	selABuf1Rx_s.ap  = '1' else
							outABuf2Tx_s.ap 	when	selABuf2Tx_s.ap  = '1' else
							outABuf2Rx_s.ap 	when	selABuf2Rx_s.ap  = '1' else
							outTpdoBuf_s.ap		when	selTpdoBuf_s.ap  = '1' else
							outRpdo0Buf_s.ap	when	selRpdo0Buf_s.ap = '1' else
							outRpdo1Buf_s.ap	when	selRpdo1Buf_s.ap = '1' else
							outRpdo2Buf_s.ap	when	selRpdo2Buf_s.ap = '1' else
							(others => '0');
	end block;
--
------------------------------------------------------------------------------------------------------------------------
	
------------------------------------------------------------------------------------------------------------------------
-- dual ported RAM
	theDpr : entity work.pdi_dpr
		generic map (
		NUM_WORDS		=>		(dprSize_c/4),
		LOG2_NUM_WORDS	=>		dprAddrWidth_c-2
		)
		port map (
		address_a		=>		pcp_addrRes(dprAddrWidth_c-2-1 downto 0),
		address_b		=>		ap_addrRes(dprAddrWidth_c-2-1 downto 0),
		byteena_a		=>		dpr.pcp.be,
		byteena_b		=>		dpr.ap.be,
		clock_a			=>		pcp_clk,
		clock_b			=>		ap_clk,
		data_a			=>		dpr.pcp.din,
		data_b			=>		dpr.ap.din,
		wren_a			=>		dpr.pcp.wr,
		wren_b			=>		dpr.ap.wr,
		q_a				=>		dprOut.pcp,
		q_b				=>		dprOut.ap
		);
	
	pcp_addrRes <= '0' & pcp_address(dprAddrWidth_c-2-1 downto 0) + dpr.pcp.addrOff;
	
	dpr.pcp	<=	dprCntStReg_s.pcp	when	selCntStReg_s.pcp = '1'	else
				dprABuf1Tx_s.pcp	when	selABuf1Tx_s.pcp  = '1' else
				dprABuf1Rx_s.pcp	when	selABuf1Rx_s.pcp  = '1' else
				dprABuf2Tx_s.pcp	when	selABuf2Tx_s.pcp  = '1' else
				dprABuf2Rx_s.pcp	when	selABuf2Rx_s.pcp  = '1' else
				dprTpdoBuf_s.pcp	when	selTpdoBuf_s.pcp = '1'	else
				dprRpdo0Buf_s.pcp	when	selRpdo0Buf_s.pcp = '1' and iRpdos_g >= 1 else
				dprRpdo1Buf_s.pcp	when	selRpdo1Buf_s.pcp = '1' and iRpdos_g >= 2 else
				dprRpdo2Buf_s.pcp	when	selRpdo2Buf_s.pcp = '1' and iRpdos_g >= 3 else
				((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0');
				
				
	ap_addrRes <= '0' & ap_address(dprAddrWidth_c-2-1 downto 0) + dpr.ap.addrOff;
	
	dpr.ap	<=	dprCntStReg_s.ap	when	selCntStReg_s.ap = '1'	else
				dprABuf1Tx_s.ap 	when	selABuf1Tx_s.ap   = '1' else
				dprABuf1Rx_s.ap 	when	selABuf1Rx_s.ap   = '1' else
				dprABuf2Tx_s.ap 	when	selABuf2Tx_s.ap   = '1' else
				dprABuf2Rx_s.ap 	when	selABuf2Rx_s.ap   = '1' else
				dprTpdoBuf_s.ap		when	selTpdoBuf_s.ap = '1'	else
				dprRpdo0Buf_s.ap	when	selRpdo0Buf_s.ap = '1' 	and iRpdos_g >= 1 else
				dprRpdo1Buf_s.ap	when	selRpdo1Buf_s.ap = '1' 	and iRpdos_g >= 2 else
				dprRpdo2Buf_s.ap	when	selRpdo2Buf_s.ap = '1' 	and iRpdos_g >= 3 else
				((others => '0'), (others => '0'), (others => '0'), (others => '0'), '0');
				
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- address decoder to generate select signals for different memory ranges
	theAddressDecoder : block
	begin
		--pcp side
		---control / status register
		selCntStReg_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extCntStReg_c.base and 
															(conv_integer(pcp_address)*4 < extCntStReg_c.base + extCntStReg_c.span))
													else	'0';
		---asynchronous buffers
		selABuf1Tx_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extABuf1Tx_c.base and 
														 	(conv_integer(pcp_address)*4 < extABuf1Tx_c.base + extABuf1Tx_c.span))
													else	'0';
		selABuf1Rx_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extABuf1Rx_c.base and 
														 	(conv_integer(pcp_address)*4 < extABuf1Rx_c.base + extABuf1Rx_c.span))
													else	'0';
		selABuf2Tx_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extABuf2Tx_c.base and 
														 	(conv_integer(pcp_address)*4 < extABuf2Tx_c.base + extABuf2Tx_c.span))
													else	'0';
		selABuf2Rx_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extABuf2Rx_c.base and 
														 	(conv_integer(pcp_address)*4 < extABuf2Rx_c.base + extABuf2Rx_c.span))
													else	'0';
		
		---pdo buffers (triple buffers considered!)
		selTpdoBuf_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extTpdoBuf_c.base and 
														 	(conv_integer(pcp_address)*4 < extTpdoBuf_c.base + extTpdoBuf_c.span))
													else	'0';
		selRpdo0Buf_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extRpdo0Buf_c.base and 
														 	(conv_integer(pcp_address)*4 < extRpdo0Buf_c.base + extRpdo0Buf_c.span))
													else	'0';
		selRpdo1Buf_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extRpdo1Buf_c.base and 
														 	(conv_integer(pcp_address)*4 < extRpdo1Buf_c.base + extRpdo1Buf_c.span))
													else	'0';
		selRpdo2Buf_s.pcp	<=	pcp_chipselect		when	(conv_integer(pcp_address)*4 >= extRpdo2Buf_c.base and 
														 	(conv_integer(pcp_address)*4 < extRpdo2Buf_c.base + extRpdo2Buf_c.span))
													else	'0';
		
		--ap side
		---control / status register
		selCntStReg_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extCntStReg_c.base and 
														 (conv_integer(ap_address)*4 < extCntStReg_c.base + extCntStReg_c.span))
												else	'0';
		---asynchronous buffers
		selABuf1Tx_s.ap 	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extABuf1Tx_c.base and 
														 (conv_integer(ap_address)*4 < extABuf1Tx_c.base + extABuf1Tx_c.span))
												else	'0';
		selABuf1Rx_s.ap 	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extABuf1Rx_c.base and 
														 (conv_integer(ap_address)*4 < extABuf1Rx_c.base + extABuf1Rx_c.span))
												else	'0';
		selABuf2Tx_s.ap 	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extABuf2Tx_c.base and 
														 (conv_integer(ap_address)*4 < extABuf2Tx_c.base + extABuf2Tx_c.span))
												else	'0';
		selABuf2Rx_s.ap 	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extABuf2Rx_c.base and 
														 (conv_integer(ap_address)*4 < extABuf2Rx_c.base + extABuf2Rx_c.span))
												else	'0';
		---pdo buffers (triple buffers considered!)
		selTpdoBuf_s.ap		<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extTpdoBuf_c.base and 
														 (conv_integer(ap_address)*4 < extTpdoBuf_c.base + extTpdoBuf_c.span))
												else	'0';
		selRpdo0Buf_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extRpdo0Buf_c.base and 
														 (conv_integer(ap_address)*4 < extRpdo0Buf_c.base + extRpdo0Buf_c.span))
												else	'0';
		selRpdo1Buf_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extRpdo1Buf_c.base and 
														 (conv_integer(ap_address)*4 < extRpdo1Buf_c.base + extRpdo1Buf_c.span))
												else	'0';
		selRpdo2Buf_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extRpdo2Buf_c.base and 
														 (conv_integer(ap_address)*4 < extRpdo2Buf_c.base + extRpdo2Buf_c.span))
												else	'0';
	end block theAddressDecoder;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- control / status register
	theCntrlStatReg4Pcp : entity work.pdiControlStatusReg
	generic map (
			bIsPcp						=> true,
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseDpr_g					=> 16#8#/4, --base address of content to be mapped to dpr
			iSpanDpr_g					=> intCntStReg_c.span/4, --size of content to be mapped to dpr
			iBaseMap2_g					=> intCntStReg_c.base/4, --base address in dpr
			iDprAddrWidth_g				=> dprCntStReg_s.pcp.addr'length,
			iRpdos_g					=> iRpdos_g,
			--register content
			---constant values
			magicNumber					=> conv_std_logic_vector(magicNumber_c, 32),
			pdiRev						=> conv_std_logic_vector(pdiRev_c, 16),
			tPdoBuffer					=> conv_std_logic_vector(extTpdoBuf_c.base, 16) & 
											conv_std_logic_vector(extTpdoBuf_c.span, 16),
			rPdo0Buffer					=> conv_std_logic_vector(extRpdo0Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo0Buf_c.span, 16),
			rPdo1Buffer					=> conv_std_logic_vector(extRpdo1Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo1Buf_c.span, 16),
			rPdo2Buffer					=> conv_std_logic_vector(extRpdo2Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo2Buf_c.span, 16),
			asyncBuffer1Tx				=> conv_std_logic_vector(extABuf1Tx_c.base, 16) &
											conv_std_logic_vector(extABuf1Tx_c.span, 16),
			asyncBuffer1Rx				=> conv_std_logic_vector(extABuf1Rx_c.base, 16) &
											conv_std_logic_vector(extABuf1Rx_c.span, 16),
			asyncBuffer2Tx				=> conv_std_logic_vector(extABuf2Tx_c.base, 16) &
											conv_std_logic_vector(extABuf2Tx_c.span, 16),
			asyncBuffer2Rx				=> conv_std_logic_vector(extABuf2Rx_c.base, 16) &
											conv_std_logic_vector(extABuf2Rx_c.span, 16)
	)
			
	port map (   
			--memory mapped interface
			clk							=> pcp_clk,
			rst							=> pcp_reset,
			sel							=> selCntStReg_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outCntStReg_s.pcp,
			--register content
			---virtual buffer control signals
			pdoVirtualBufferSel			=> vBufSel_s.pcp,
			tPdoTrigger					=> vBufTriggerPdo_s.pcp(3),
			rPdoTrigger					=> vBufTriggerPdo_s.pcp(2 downto 0),
			---event registers
			eventAckIn 					=> pcp_eventRead,
			eventAckOut					=> pcp_eventSet_s,
			---async irq (by event)
			asyncIrqCtrlIn				=> (others => '0'), --not for pcp
			asyncIrqCtrlOut				=> open, --not for pcp
			---led stuff
			ledCnfgIn 					=> pcp_ledForce_s,
			ledCnfgOut 					=> pcp_ledForce_s,
			ledCtrlIn 					=> pcp_ledSet_s,
			ledCtrlOut 					=> pcp_ledSet_s,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprCntStReg_s.pcp.addrOff,
			dprDin						=> dprCntStReg_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprCntStReg_s.pcp.be,
			dprWr						=> dprCntStReg_s.pcp.wr,
			--ap irq generation
			apIrqControlOut				=> apIrqControlPcp,
			--SW is blind, thus, use the transferred enable signal from AP!
			apIrqControlIn				=> apIrqControlPcp2,
			--hw acc triggering
			rpdo_change_tog				=> rpdo_change_tog,
			tpdo_change_tog				=> tpdo_change_tog
	);
	
	--only read 15 bits of the written, the msbit is read from transferred AP bit
	apIrqControlPcp2(14 downto 0) <= apIrqControlPcp(14 downto 0);
	
	--transfer the AP's enable signal to PCP, since SW is blind... :)
	syncApEnable2Pcp : entity work.sync
		generic map (
			doSync_g => not genOnePdiClkDomain_g
		)
		port map (
			inData => apIrqControlApOut(15),
			outData => apIrqControlPcp2(15),
			clk => pcp_clk,
			rst => pcp_reset
		);
	
	theCntrlStatReg4Ap : entity work.pdiControlStatusReg
	generic map (
			bIsPcp						=> false,
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseDpr_g					=> 16#8#/4, --base address of content to be mapped to dpr
			iSpanDpr_g					=> intCntStReg_c.span/4, --size of content to be mapped to dpr
			iBaseMap2_g					=> intCntStReg_c.base/4, --base address in dpr
			iDprAddrWidth_g				=> dprCntStReg_s.ap.addr'length,
			iRpdos_g					=> iRpdos_g,
			--register content
			---constant values
			magicNumber					=> conv_std_logic_vector(magicNumber_c, 32),
			pdiRev						=> conv_std_logic_vector(pdiRev_c, 16),
			tPdoBuffer					=> conv_std_logic_vector(extTpdoBuf_c.base, 16) & 
											conv_std_logic_vector(extTpdoBuf_c.span, 16),
			rPdo0Buffer					=> conv_std_logic_vector(extRpdo0Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo0Buf_c.span, 16),
			rPdo1Buffer					=> conv_std_logic_vector(extRpdo1Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo1Buf_c.span, 16),
			rPdo2Buffer					=> conv_std_logic_vector(extRpdo2Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo2Buf_c.span, 16),
			asyncBuffer1Tx				=> conv_std_logic_vector(extABuf1Tx_c.base, 16) &
											conv_std_logic_vector(extABuf1Tx_c.span, 16),
			asyncBuffer1Rx				=> conv_std_logic_vector(extABuf1Rx_c.base, 16) &
											conv_std_logic_vector(extABuf1Rx_c.span, 16),
			asyncBuffer2Tx				=> conv_std_logic_vector(extABuf2Tx_c.base, 16) &
											conv_std_logic_vector(extABuf2Tx_c.span, 16),
			asyncBuffer2Rx				=> conv_std_logic_vector(extABuf2Rx_c.base, 16) &
											conv_std_logic_vector(extABuf2Rx_c.span, 16)
	)
			
	port map (   
			--memory mapped interface
			clk							=> ap_clk,
			rst							=> ap_reset,
			sel							=> selCntStReg_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outCntStReg_s.ap,
			--register content
			---virtual buffer control signals
			pdoVirtualBufferSel			=> vBufSel_s.ap,
			tPdoTrigger					=> vBufTriggerPdo_s.ap(3),
			rPdoTrigger					=> vBufTriggerPdo_s.ap(2 downto 0),
			---event registers
			eventAckIn 					=> ap_eventAck,
			eventAckOut					=> ap_eventAck_p,
			---async irq (by event)
			asyncIrqCtrlIn				=> asyncIrqCtrlIn_s,
			asyncIrqCtrlOut				=> asyncIrqCtrlOut_s,
			---led stuff
			ledCnfgIn 					=> ap_ledForce_s,
			ledCnfgOut 					=> ap_ledForce_s,
			ledCtrlIn 					=> ap_ledSet_s,
			ledCtrlOut 					=> ap_ledSet_s,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprCntStReg_s.ap.addrOff,
			dprDin						=> dprCntStReg_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprCntStReg_s.ap.be,
			dprWr						=> dprCntStReg_s.ap.wr,
			--ap irq generation
			--apIrqValue					=>
			apIrqControlOut				=> apIrqControlApOut,
			apIrqControlIn				=> apIrqControlApIn,
			rpdo_change_tog				=> (others => '0'),
			tpdo_change_tog				=> '0'
	);
	
	theApIrqGenerator : entity work.apIrqGen
		generic map (
			genOnePdiClkDomain_g => genOnePdiClkDomain_g
		)
		port map (
			--CLOCK DOMAIN PCP
			clkA => pcp_clk,
			rstA => pcp_reset,
			irqA => pcp_irq,
			--preValA => apIrqValue,
			enableA => apIrqControlPcp(7),
			modeA => apIrqControlPcp(6),
			setA => apIrqControlPcp(0),
			--CLOCK DOMAIN AP
			clkB => ap_clk,
			rstB => ap_reset,
			ackB => apIrqControlApOut(0),
			irqB => ap_irq_s
		);
	
	--irq enabled by apIrqControlApOut(15)
	ap_irq <= ap_irq_s and apIrqControlApOut(15);
	apIrqControlApIn <= apIrqControlApOut(15) & "000" & x"00" & "000" & ap_irq_s;
	
	--the LED stuff
	--first set the hw leds
	hw_ledForce_s <= x"00" & "00111100"; --phy1 and 0 act and link
	hw_ledSet_s <= x"00" & "00" & (phyAct(1) and phyLink(1)) & phyLink(1) & (phyAct(0) and phyLink(0)) & phyLink(0) & "00";
	
	theLedGadget : entity work.pdiLed
	generic map (
		iLedWidth_g						=> ledsOut'length
	)
	port map (
		--src A (lowest priority)
		srcAled							=> hw_ledSet_s(ledsOut'range),
		srcAforce						=> hw_ledForce_s(ledsOut'range),
		--src B
		srcBled							=> pcp_ledSet_s(ledsOut'range),
		srcBforce						=> pcp_ledForce_s(ledsOut'range),
		--src C (highest priority)
		srcCled							=> ap_ledSet_s(ledsOut'range),
		srcCforce						=> ap_ledForce_s(ledsOut'range),
		--led output
		ledOut							=> ledsOut
	);
	
	theEventBlock : block
		--set here the number of events
		constant iSwEvent_c : integer := 1;
		constant iHwEvent_c : integer := 2;
		
		signal eventSetA	: std_logic_vector(iSwEvent_c-1 downto 0);
		signal eventReadA	: std_logic_vector(iSwEvent_c+iHwEvent_c-1 downto 0);
		
		signal eventAckB	: std_logic_vector(iSwEvent_c+iHwEvent_c-1 downto 0);
		signal eventReadB	: std_logic_vector(iSwEvent_c+iHwEvent_c-1 downto 0);
	begin
		
		--event mapping: 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
		-- in register    x  x  x  x  x  x  x  x hw hw  x  x  x  x  x sw
		-- in pdiEvent                                          hw hw sw
		eventSetA <= pcp_eventSet_s(0 downto 0); --pcp sets sw event (I know, its called generic event, bla...)
		pcp_eventRead <= x"00" & eventReadA(iSwEvent_c+iHwEvent_c-1 downto iSwEvent_c) & 
						"00000" & eventReadA(iSwEvent_c-1 downto 0);
		
		eventAckB <= ap_eventAck_p(7 downto 6) & ap_eventAck_p(0); --ap acks events
		ap_eventAck <= x"00" & eventReadB(iSwEvent_c+iHwEvent_c-1 downto iSwEvent_c) & 
						"00000" & eventReadB(iSwEvent_c-1 downto 0);
		
		theEventStuff : entity work.pdiEvent
		--16 bit
		-- sw is at bit 0
		-- hw is at bit 6 and 7
		generic map (
				genOnePdiClkDomain_g => genOnePdiClkDomain_g,
				iSwEvent_g => 1,
				iHwEvent_g => 2
		)
				
		port map (  
				--port A -> PCP
				clkA						=> pcp_clk,
				rstA						=> pcp_reset,
				eventSetA					=> eventSetA,
				eventReadA					=> eventReadA,
				--port B -> AP
				clkB						=> ap_clk,
				rstB						=> ap_reset,
				eventAckB					=> eventAckB,
				eventReadB					=> eventReadB,
				--hw event set pulse (must be synchronous to clkB!)
				hwEventSetPulseB			=> phyLinkEvent
		);
		
		--generate async interrupt
		asyncIrq : process(ap_eventAck)
		variable tmp : std_logic;
		begin
			tmp := '0';
			for i in ap_eventAck'range loop
				tmp := tmp or ap_eventAck(i);
			end loop;
			ap_asyncIrq_s <= tmp;
		end process;
		--IRQ is asserted if enabled by AP
		ap_asyncIrq <= ap_asyncIrq_s and asyncIrqCtrlOut_s(15);
		
		asyncIrqCtrlIn_s(15) <= asyncIrqCtrlOut_s(15);
		asyncIrqCtrlIn_s(14 downto 1) <= (others => '0'); --ignoring the rest
		asyncIrqCtrlIn_s(0) <= ap_asyncIrq_s; --AP may poll IRQ level
		
		syncPhyLinkGen : for i in phyLink'range generate
			syncPhyLink : entity work.sync
				generic map (
					doSync_g => not genOnePdiClkDomain_g
				)
				port map (
					inData => phyLink(i),
					outData => phyLink_s(i),
					clk => ap_clk,
					rst => ap_reset
				);
			
			detPhyLinkEdge : entity work.edgeDet
				port map (
					inData => phyLink_s(i),
					rising => open,
					falling => phyLinkEvent(i), --if phy link deasserts - EVENT!!!
					any => open,
					clk => ap_clk,
					rst => ap_reset
				);
		end generate;
	end block;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Buffer 1 Tx
	theAsyncBuf1Tx4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf1Tx_c.base/4,
			iDprAddrWidth_g				=> dprABuf1Tx_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf1Tx_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outABuf1Tx_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf1Tx_s.pcp.addrOff,
			dprDin						=> dprABuf1Tx_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprABuf1Tx_s.pcp.be,
			dprWr						=> dprABuf1Tx_s.pcp.wr
	);
	
	theAsyncBuf1Tx4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf1Tx_c.base/4,
			iDprAddrWidth_g				=> dprABuf1Tx_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf1Tx_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outABuf1Tx_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf1Tx_s.ap.addrOff,
			dprDin						=> dprABuf1Tx_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprABuf1Tx_s.ap.be,
			dprWr						=> dprABuf1Tx_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Buffer 1 Rx
	theAsyncBuf1Rx4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf1Rx_c.base/4,
			iDprAddrWidth_g				=> dprABuf1Rx_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf1Rx_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outABuf1Rx_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf1Rx_s.pcp.addrOff,
			dprDin						=> dprABuf1Rx_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprABuf1Rx_s.pcp.be,
			dprWr						=> dprABuf1Rx_s.pcp.wr
	);
	
	theAsyncBuf1Rx4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf1Rx_c.base/4,
			iDprAddrWidth_g				=> dprABuf1Rx_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf1Rx_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outABuf1Rx_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf1Rx_s.ap.addrOff,
			dprDin						=> dprABuf1Rx_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprABuf1Rx_s.ap.be,
			dprWr						=> dprABuf1Rx_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Buffer 2 Tx
	theAsyncBuf2Tx4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf2Tx_c.base/4,
			iDprAddrWidth_g				=> dprABuf2Tx_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf2Tx_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outABuf2Tx_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf2Tx_s.pcp.addrOff,
			dprDin						=> dprABuf2Tx_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprABuf2Tx_s.pcp.be,
			dprWr						=> dprABuf2Tx_s.pcp.wr
	);
	
	theAsyncBuf2Tx4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf2Tx_c.base/4,
			iDprAddrWidth_g				=> dprABuf2Tx_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf2Tx_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outABuf2Tx_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf2Tx_s.ap.addrOff,
			dprDin						=> dprABuf2Tx_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprABuf2Tx_s.ap.be,
			dprWr						=> dprABuf2Tx_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Buffer 2 Rx
	theAsyncBuf2Rx4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf2Rx_c.base/4,
			iDprAddrWidth_g				=> dprABuf2Rx_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf2Rx_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outABuf2Rx_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf2Rx_s.pcp.addrOff,
			dprDin						=> dprABuf2Rx_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprABuf2Rx_s.pcp.be,
			dprWr						=> dprABuf2Rx_s.pcp.wr
	);
	
	theAsyncBuf2Rx4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intABuf2Rx_c.base/4,
			iDprAddrWidth_g				=> dprABuf2Rx_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selABuf2Rx_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outABuf2Rx_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					=> dprABuf2Rx_s.ap.addrOff,
			dprDin						=> dprABuf2Rx_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprABuf2Rx_s.ap.be,
			dprWr						=> dprABuf2Rx_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--TPDO buffer
	theTpdoTrippleBuffer : block
	signal selVBufPcpOneHot				: std_logic_vector(2 downto 0);
	signal selVBufApOneHot				: std_logic_vector(2 downto 0);
	begin
		
		vBufSel_s.pcp(31 downto 24) <= 	x"00" when selVBufPcpOneHot = "001" else
										x"11" when selVBufPcpOneHot = "010" else
										x"22" when selVBufPcpOneHot = "100" else
										x"FF";
		
		vBufSel_s.ap(31 downto 24) <= 	x"00" when selVBufApOneHot = "001" else
										x"11" when selVBufApOneHot = "010" else
										x"22" when selVBufApOneHot = "100" else
										x"FF";
		
		dprTpdoBuf_s.pcp.din <= pcp_writedata;
		outTpdoBuf_s.pcp <= dprOut.pcp;
		dprTpdoBuf_s.pcp.be <= pcp_byteenable;
		dprTpdoBuf_s.pcp.wr <= pcp_write;
		
		dprTpdoBuf_s.ap.din <= ap_writedata;
		outTpdoBuf_s.ap <= dprOut.ap;
		dprTpdoBuf_s.ap.be <= ap_byteenable;
		dprTpdoBuf_s.ap.wr <= ap_write;
		
		theTrippleMechanism : entity work.tripleVBufLogic
		generic map (
			genOnePdiClkDomain_g 		=> genOnePdiClkDomain_g,
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intTpdoBuf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intTpdoBuf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprTpdoBuf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2,
			--ap is producer
			bApIsProducer				=> true
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(3),
			pcpOutAddrOff				=> dprTpdoBuf_s.pcp.addrOff,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset						=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(3),
			apOutAddrOff				=> dprTpdoBuf_s.ap.addrOff,
			apOutSelVBuf				=> selVBufApOneHot
		);
		
	end block;	
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--RPDO0 buffer
	theRpdo0TrippleBuffer : block
	signal selVBufPcpOneHot				: std_logic_vector(2 downto 0);
	signal selVBufApOneHot				: std_logic_vector(2 downto 0);
	begin
		
		vBufSel_s.pcp(7 downto 0) <= 	x"00" when selVBufPcpOneHot = "001" else
										x"11" when selVBufPcpOneHot = "010" else
										x"22" when selVBufPcpOneHot = "100" else
										x"FF";
		
		vBufSel_s.ap(7 downto 0) <= 	x"00" when selVBufApOneHot = "001" else
										x"11" when selVBufApOneHot = "010" else
										x"22" when selVBufApOneHot = "100" else
										x"FF";
		
		dprRpdo0Buf_s.pcp.din <= pcp_writedata;
		outRpdo0Buf_s.pcp <= dprOut.pcp;
		dprRpdo0Buf_s.pcp.be <= pcp_byteenable;
		dprRpdo0Buf_s.pcp.wr <= pcp_write;
		
		dprRpdo0Buf_s.ap.din <= ap_writedata;
		outRpdo0Buf_s.ap <= dprOut.ap;
		dprRpdo0Buf_s.ap.be <= ap_byteenable;
		dprRpdo0Buf_s.ap.wr <= ap_write;
		
		theTrippleMechanism : entity work.tripleVBufLogic
		generic map (
			genOnePdiClkDomain_g 		=> genOnePdiClkDomain_g,
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo0Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo0Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo0Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2,
			--ap is NOT producer
			bApIsProducer				=> false
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(0),
			pcpOutAddrOff				=> dprRpdo0Buf_s.pcp.addrOff,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset					=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(0),
			apOutAddrOff				=> dprRpdo0Buf_s.ap.addrOff,
			apOutSelVBuf				=> selVBufApOneHot
		);
		
	end block;	
--
------------------------------------------------------------------------------------------------------------------------
genRpdo1 : if iRpdos_g >= 2 generate
------------------------------------------------------------------------------------------------------------------------
--RPDO1 buffer
	theRpdo1TrippleBuffer : block
	signal selVBufPcpOneHot				: std_logic_vector(2 downto 0);
	signal selVBufApOneHot				: std_logic_vector(2 downto 0);
	begin
		
		vBufSel_s.pcp(15 downto 8) <= 	x"00" when selVBufPcpOneHot = "001" else
										x"11" when selVBufPcpOneHot = "010" else
										x"22" when selVBufPcpOneHot = "100" else
										x"FF";
		
		vBufSel_s.ap(15 downto 8) <= 	x"00" when selVBufApOneHot = "001" else
										x"11" when selVBufApOneHot = "010" else
										x"22" when selVBufApOneHot = "100" else
										x"FF";
		
		dprRpdo1Buf_s.pcp.din <= pcp_writedata;
		outRpdo1Buf_s.pcp <= dprOut.pcp;
		dprRpdo1Buf_s.pcp.be <= pcp_byteenable;
		dprRpdo1Buf_s.pcp.wr <= pcp_write;
		
		dprRpdo1Buf_s.ap.din <= ap_writedata;
		outRpdo1Buf_s.ap <= dprOut.ap;
		dprRpdo1Buf_s.ap.be <= ap_byteenable;
		dprRpdo1Buf_s.ap.wr <= ap_write;
		
		theTrippleMechanism : entity work.tripleVBufLogic
		generic map (
			genOnePdiClkDomain_g 		=> genOnePdiClkDomain_g,
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo1Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo1Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo1Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2,
			--ap is NOT producer
			bApIsProducer				=> false
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(1),
			pcpOutAddrOff				=> dprRpdo1Buf_s.pcp.addrOff,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset						=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(1),
			apOutAddrOff				=> dprRpdo1Buf_s.ap.addrOff,
			apOutSelVBuf				=> selVBufApOneHot
		);
		
	end block;	
--
------------------------------------------------------------------------------------------------------------------------
end generate;

genRpdo2 : if iRpdos_g >= 3 generate
------------------------------------------------------------------------------------------------------------------------
--RPDO2 buffer
	theRpdo2TrippleBuffer : block
	signal selVBufPcpOneHot				: std_logic_vector(2 downto 0);
	signal selVBufApOneHot				: std_logic_vector(2 downto 0);
	begin
		
		vBufSel_s.pcp(23 downto 16) <= 	x"00" when selVBufPcpOneHot = "001" else
										x"11" when selVBufPcpOneHot = "010" else
										x"22" when selVBufPcpOneHot = "100" else
										x"FF";
		
		vBufSel_s.ap(23 downto 16) <= 	x"00" when selVBufApOneHot = "001" else
										x"11" when selVBufApOneHot = "010" else
										x"22" when selVBufApOneHot = "100" else
										x"FF";
		
		dprRpdo2Buf_s.pcp.din <= pcp_writedata;
		outRpdo2Buf_s.pcp <= dprOut.pcp;
		dprRpdo2Buf_s.pcp.be <= pcp_byteenable;
		dprRpdo2Buf_s.pcp.wr <= pcp_write;
		
		dprRpdo2Buf_s.ap.din <= ap_writedata;
		outRpdo2Buf_s.ap <= dprOut.ap;
		dprRpdo2Buf_s.ap.be <= ap_byteenable;
		dprRpdo2Buf_s.ap.wr <= ap_write;
		
		theTrippleMechanism : entity work.tripleVBufLogic
		generic map (
			genOnePdiClkDomain_g 		=> genOnePdiClkDomain_g,
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo2Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo2Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo2Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2,
			--ap is NOT producer
			bApIsProducer				=> false
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(2),
			pcpOutAddrOff				=> dprRpdo2Buf_s.pcp.addrOff,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset						=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(2),
			apOutAddrOff				=> dprRpdo2Buf_s.ap.addrOff,
			apOutSelVBuf				=> selVBufApOneHot
		);
		
	end block;	
--
------------------------------------------------------------------------------------------------------------------------
end generate;

end architecture rtl;

------------------------------------------------------------------------------------------------------------------------
-- package for memory mapping
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

package memMap is
	type memoryMapping_t is
	record
		base 							: integer;
		span 							: integer;
	end record;
	
	function align32 (inVal : integer) return integer;
end package memMap;

package body memMap is
	function align32 (inVal : integer) return integer is
	variable tmp : std_logic_vector(31 downto 0);
	variable result : integer;
	begin
		tmp := (conv_std_logic_vector(inVal, tmp'length) + x"00000003") and not x"00000003";
		result := conv_integer(tmp);
		return result;
	end function;
end package body memMap;

------------------------------------------------------------------------------------------------------------------------
-- entity for those events
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

--the order of events:
-- e.g. sw event = 1 and hw event = 2
-- event = (HW1 & HW0 & SW0)
-- pcp only sets SW0, but can read SW0
-- ap ack all events

entity pdiEvent is
	generic (
		genOnePdiClkDomain_g		:		boolean := false;
		iSwEvent_g					:		integer := 1;
		iHwEvent_g					:		integer := 2
	);
			
	port (  
			--port A -> PCP
			clkA						: in	std_logic;
			rstA						: in	std_logic;
			eventSetA					: in	std_logic_vector(iSwEvent_g-1 downto 0); --to set event (pulse!)
			eventReadA					: out	std_logic_vector(iSwEvent_g+iHwEvent_g-1 downto 0); --to read event set (can be acked by ap!!!)
			--port B -> AP
			clkB						: in	std_logic;
			rstB						: in	std_logic;
			eventAckB					: in	std_logic_vector(iSwEvent_g+iHwEvent_g-1 downto 0); --to ack events (pulse!)
			eventReadB					: out	std_logic_vector(iSwEvent_g+iHwEvent_g-1 downto 0); --to read event set
			--hw event set pulse (must be synchronous to clkB!)
			hwEventSetPulseB			: in	std_logic_vector(iHwEvent_g-1 downto 0)
	);
end entity pdiEvent;

architecture rtl of pdiEvent is
--in clk domain A
signal	eventA_s, --stores the events in A domain
		eventA_ackPulse --ack the event (by ap)
										:		std_logic_vector(iSwEvent_g+iHwEvent_g-1 downto 0);
signal	eventA_setPulse --sets the sw event only (by pcp)
										:		std_logic_vector(iSwEvent_g-1 downto 0);
signal	hwEventA_setPulse --sets the hw event only
										:		std_logic_vector(iHwEvent_g-1 downto 0);
--in clk domain B
signal	eventB_s, --stores the events in B domain
		eventB_ackPulse --ack the event (by ap)
										:		std_logic_vector(iSwEvent_g+iHwEvent_g-1 downto 0);
signal	eventB_setPulse --sets the sw event only (by pcp)
										:		std_logic_vector(iSwEvent_g-1 downto 0);
begin
	
	--pcp
	eventReadA <= eventA_s;
	
	--eventA_s stores all events
	--eventA_ackPulse sends acks for all events
	--eventA_setPulse sends set for sw event only
	eventA_setPulse <= eventSetA;
	--hwEventA_setPulse sends set for hw event only
	process(clkA, rstA)
	variable event_var : std_logic_vector(eventA_s'range);		
	begin  
		if rstA = '1' then
			eventA_s <= (others => '0');
		elsif clkA = '1' and clkA'event then
			--get event state to do magic
			event_var := eventA_s;
			
			--first let the ack does its work...
			event_var := event_var and not eventA_ackPulse;
			
			--second the sw events may overwrite the ack...
			event_var(iSwEvent_g-1 downto 0) := event_var(iSwEvent_g-1 downto 0) or
			eventA_setPulse(iSwEvent_g-1 downto 0);
			
			--last but not least, the hw events have its chance too
			event_var(iSwEvent_g+iHwEvent_g-1 downto iSwEvent_g) := event_var(iSwEvent_g+iHwEvent_g-1 downto iSwEvent_g) or
			hwEventA_setPulse(iHwEvent_g-1 downto 0);
			
			--and now, export it
			eventA_s <= event_var;
		end if;
	end process;	
	
	--ap
	eventReadB <= eventB_s;
	
	--eventB_s stores all events
	--eventB_ackPulse sends acks for all events
	eventB_ackPulse <= eventAckB;
	--eventB_setPulse sends set for sw event only
	--hwEventSetPulseB sends set for hw event only
	process(clkB, rstB)
	variable event_var : std_logic_vector(eventB_s'range);
	begin  
		if rstB = '1' then
			eventB_s <= (others => '0');
		elsif clkB = '1' and clkB'event then
			--I know, its almost the same as for A, but for clarity...
			--get event state
			event_var := eventB_s;
			
			--doing ack
			event_var := event_var and not eventB_ackPulse;
			
			--sw events may overwrite
			event_var(iSwEvent_g-1 downto 0) := event_var(iSwEvent_g-1 downto 0) or 
			eventB_setPulse(iSwEvent_g-1 downto 0);
			
			--hw events may overwrite too
			event_var(iSwEvent_g+iHwEvent_g-1 downto iSwEvent_g) := event_var(iSwEvent_g+iHwEvent_g-1 downto iSwEvent_g) or 
			hwEventSetPulseB(iHwEvent_g-1 downto 0);
			
			--and let's export
			eventB_s <= event_var;
		end if;
	end process;
	
	--xing the domains a to b
	syncEventSetGen : for i in 0 to iSwEvent_g-1 generate
		--only the software events are transferred!
		syncEventSet : entity work.slow2fastSync
			generic map (
				doSync_g => not genOnePdiClkDomain_g
			)
			port map (
				clkSrc => clkA,
				rstSrc => rstA,
				dataSrc => eventA_setPulse(i),
				clkDst => clkB,
				rstDst => rstB,
				dataDst => eventB_setPulse(i)
			);
		end generate;
	
	--xing the domains b to a
	syncEventAckGen : for i in eventB_s'range generate
		--all events are transferred
		syncEventAck : entity work.slow2fastSync
			generic map (
				doSync_g => not genOnePdiClkDomain_g
			)
			port map (
				clkSrc => clkB,
				rstSrc => rstB,
				dataSrc => eventB_ackPulse(i),
				clkDst => clkA,
				rstDst => rstA,
				dataDst => eventA_ackPulse(i)
			);
		end generate;
	
	syncHwEventGen : for i in 0 to iHwEvent_g-1 generate
		--hw events are transferred
		syncEventAck : entity work.slow2fastSync
			generic map (
				doSync_g => not genOnePdiClkDomain_g
			)
			port map (
				clkSrc => clkB,
				rstSrc => rstB,
				dataSrc => hwEventSetPulseB(i),
				clkDst => clkA,
				rstDst => rstA,
				dataDst => hwEventA_setPulse(i)
			);
		end generate;
end architecture rtl;

------------------------------------------------------------------------------------------------------------------------
-- entity for led gadget
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

--the led gadget can be set by three different sources
-- source A, B and C
-- the highest priority has C

entity pdiLed is
	generic (
		iLedWidth_g						:		integer := 8
	);
	port (
		--src A
		srcAled							: in	std_logic_vector(iLedWidth_g-1 downto 0);
		srcAforce						: in	std_logic_vector(iLedWidth_g-1 downto 0);
		--src B
		srcBled							: in	std_logic_vector(iLedWidth_g-1 downto 0);
		srcBforce						: in	std_logic_vector(iLedWidth_g-1 downto 0);
		--src C
		srcCled							: in	std_logic_vector(iLedWidth_g-1 downto 0);
		srcCforce						: in	std_logic_vector(iLedWidth_g-1 downto 0);
		--led output
		ledOut							: out	std_logic_vector(iLedWidth_g-1 downto 0)
	);
end entity pdiLed;

architecture rtl of pdiLed is
begin
	theLedGadget : process(srcAled, srcAforce, srcBled, srcBforce, srcCled, srcCforce)
		variable tmp_led : std_logic_vector(ledOut'range);
	begin
		tmp_led := (others => '0');
		
		for i in tmp_led'range loop
			--okay, src A may drive if forced
			if srcAforce(i) = '1' then
				tmp_led(i) := srcAled(i);
			end if;
			
			--same vaild for src B, but it overrules src A
			if srcBforce(i) = '1' then
				tmp_led(i) := srcBled(i);
			end if;
			
			--and the head of the logics => src C
			if srcCforce(i) = '1' then
				tmp_led(i) := srcCled(i);
			end if;
		end loop;
		
		--let's export and go for a coffee...
		ledOut <= tmp_led;		
	end process;
end architecture rtl;

------------------------------------------------------------------------------------------------------------------------
-- entity for control status register
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pdiControlStatusReg is
	generic (
			bIsPcp						:		boolean := true;
			iAddrWidth_g				:		integer := 8;
			iBaseDpr_g					:		integer := 16#4#; --base address (in external mapping) of content in dpr
			iSpanDpr_g					:		integer := 12; --span of content in dpr
			iBaseMap2_g					:		integer := 0; --base address in dpr
			iDprAddrWidth_g				:		integer := 11;
			iRpdos_g					:		integer := 3;
			--register content
			---constant values
			magicNumber					: 		std_Logic_vector(31 downto 0) := (others => '0');
			pdiRev						: 		std_logic_vector(15 downto 0) := (others => '0');
			tPdoBuffer					: 		std_logic_vector(31 downto 0) := (others => '0');
			rPdo0Buffer					: 		std_logic_vector(31 downto 0) := (others => '0');
			rPdo1Buffer					: 		std_logic_vector(31 downto 0) := (others => '0');
			rPdo2Buffer					: 		std_logic_vector(31 downto 0) := (others => '0');
			asyncBuffer1Tx				: 		std_logic_vector(31 downto 0) := (others => '0');
			asyncBuffer1Rx				: 		std_logic_vector(31 downto 0) := (others => '0');
			asyncBuffer2Tx				: 		std_logic_vector(31 downto 0) := (others => '0');
			asyncBuffer2Rx				:		std_logic_vector(31 downto 0) := (others => '0')
	);
			
	port (   
			--memory mapped interface
			clk							: in    std_logic;
			rst                  		: in    std_logic;
			sel							: in	std_logic;
			wr							: in	std_logic;
			rd							: in	std_logic;
			addr						: in	std_logic_vector(iAddrWidth_g-1 downto 0);
			be							: in	std_logic_vector(3 downto 0);
			din							: in	std_logic_vector(31 downto 0);
			dout						: out	std_logic_vector(31 downto 0);
			--register content
			---virtual buffer control signals
			rpdo_change_tog				: in	std_logic_vector(2 downto 0); --change buffer from hw acc
			tpdo_change_tog				: in	std_logic; --change buffer from hw acc
			pdoVirtualBufferSel			: in	std_logic_vector(31 downto 0); 	--for debugging purpose from SW side
																				--TXPDO_ACK | RXPDO2_ACK | RXPDO1_ACK | RXPDO0_ACK
			tPdoTrigger					: out	std_logic; --TPDO virtual buffer change trigger
			rPdoTrigger					: out	std_logic_vector(2 downto 0); --RPDOs virtual buffer change triggers
			---is used for Irq Generation and should be mapped to apIrqGen
			apIrqControlOut				: out	std_logic_vector(15 downto 0);
			apIrqControlIn				: in	std_logic_vector(15 downto 0);
			---event registers
			eventAckIn 					: in	std_logic_vector(15 downto 0);
			eventAckOut					: out	std_logic_vector(15 downto 0);
			---async irq (by event)
			asyncIrqCtrlIn				: In	std_logic_vector(15 downto 0); --Ap only
			asyncIrqCtrlOut				: out	std_logic_vector(15 downto 0); --Ap only
			---led stuff
			ledCnfgIn 					: in	std_logic_vector(15 downto 0);
			ledCnfgOut 					: out	std_logic_vector(15 downto 0);
			ledCtrlIn 					: in	std_logic_vector(15 downto 0);
			ledCtrlOut 					: out	std_logic_vector(15 downto 0);
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					: out	std_logic_vector(iDprAddrWidth_g downto 0);
			dprDin						: out	std_logic_vector(31 downto 0);
			dprDout						: in	std_logic_vector(31 downto 0);
			dprBe						: out	std_logic_vector(3 downto 0);
			dprWr						: out	std_logic
			
	);
end entity pdiControlStatusReg;

architecture rtl of pdiControlStatusReg is
signal selDpr							:		std_logic; --if '1' get/write content from/to dpr
signal nonDprDout						:		std_logic_vector(31 downto 0);
signal addrRes							:		std_logic_vector(dprAddrOff'range);
--signal apIrqValue_s						: 		std_logic_vector(31 downto 0); --pcp only

signal virtualBufferSelectTpdo			:		std_logic_vector(15 downto 0);
signal virtualBufferSelectRpdo0			:		std_logic_vector(15 downto 0);
signal virtualBufferSelectRpdo1			:		std_logic_vector(15 downto 0);
signal virtualBufferSelectRpdo2			:		std_logic_vector(15 downto 0);

--edge detection
signal rpdo_change_tog_l				: 		std_logic_vector(2 downto 0); --change buffer from hw acc
signal tpdo_change_tog_l				: 		std_logic; --change buffer from hw acc
begin	
	--map to 16bit register
	--TXPDO_ACK | RXPDO2_ACK | RXPDO1_ACK | RXPDO0_ACK
	virtualBufferSelectRpdo0 <= pdoVirtualBufferSel( 7 downto  0) & pdoVirtualBufferSel( 7 downto  0);
	virtualBufferSelectRpdo1 <= pdoVirtualBufferSel(15 downto  8) & pdoVirtualBufferSel(15 downto  8);
	virtualBufferSelectRpdo2 <= pdoVirtualBufferSel(23 downto 16) & pdoVirtualBufferSel(23 downto 16);
	virtualBufferSelectTpdo  <= pdoVirtualBufferSel(31 downto 24) & pdoVirtualBufferSel(31 downto 24);
	
	--generate dpr select signal
	selDpr	<=	sel		when	(conv_integer(addr) >= iBaseDpr_g AND
								 conv_integer(addr) <  iBaseDpr_g + iSpanDpr_g)
						else	'0';

	--assign content depending on selDpr
	dprDin		<=	din;
	dprBe		<=	be;
	dprWr		<=	wr		when	selDpr = '1'	else
					'0';
	dout		<=	dprDout	when	selDpr = '1'	else
					nonDprDout;
	dprAddrOff	<=	addrRes when	selDpr = '1'	else
					(others => '0');
	
	--address conversion
	---map external address mapping into dpr
	addrRes <= 	conv_std_logic_vector(iBaseMap2_g - iBaseDpr_g, addrRes'length);
	
	--non dpr read
	with conv_integer(addr)*4 select
		nonDprDout <=	magicNumber 					when 16#00#,
						(x"0000" & pdiRev) 				when 16#04#,
						--STORED IN DPR 				when 16#08#,
						--STORED IN DPR 				when 16#0C#,
						--STORED IN DPR 				when 16#10#,
						--STORED IN DPR 				when 16#14#,
						--STORED IN DPR 				when 16#18#,
						--STORED IN DPR 				when 16#1C#,
						--STORED IN DPR 				when 16#20#,
						--STORED IN DPR 				when 16#24#,
						--STORED IN DPR 				when 16#28#,
						(eventAckIn & asyncIrqCtrlIn) 	when 16#2C#,
						tPdoBuffer 						when 16#30#,
						rPdo0Buffer 					when 16#34#,
						rPdo1Buffer 					when 16#38#,
						rPdo2Buffer 					when 16#3C#,
						asyncBuffer1Tx 					when 16#40#,
						asyncBuffer1Rx 					when 16#44#,
						asyncBuffer2Tx 					when 16#48#,
						asyncBuffer2Rx 					when 16#4C#,
						--RESERVED 						when 16#50#,
						--RESERVED 						when 16#54#,
						(virtualBufferSelectRpdo0 & 
						virtualBufferSelectTpdo) 		when 16#58#,
						(virtualBufferSelectRpdo2 & 
						virtualBufferSelectRpdo1) 		when 16#5C#,
						(x"0000" & apIrqControlIn) 		when 16#60#,
						--RESERVED						when 16#64#,
						--RESERVED 						when 16#68#,
						(ledCnfgIn & ledCtrlIn) 		when 16#6C#,
						(others => '0') 				when others;
	
	--ignored values
	asyncIrqCtrlOut(14 downto 1) <= (others => '0');
	ledCtrlOut(15 downto 8) <= (others => '0');
	ledCnfgOut(15 downto 8) <= (others => '0');
	eventAckOut(15 downto 8) <= (others => '0');
	--non dpr write
	process(clk, rst)
	begin
		if rst = '1' then
			tPdoTrigger <= '0';
			rPdoTrigger <= (others => '0');
			apIrqControlOut <= (others => '0');
			asyncIrqCtrlOut(0) <= '0';
			asyncIrqCtrlOut(15) <= '0';
			eventAckOut(7 downto 0) <= (others => '0');
			ledCtrlOut(7 downto 0) <= (others => '0');
			ledCnfgOut(7 downto 0) <= (others => '0');
			if bIsPcp then
				rpdo_change_tog_l <= (others => '0');
				tpdo_change_tog_l <= '0';
			end if;
		elsif clk = '1' and clk'event then
			--default assignments
			tPdoTrigger <= '0';
			rPdoTrigger <= (others => '0');
			apIrqControlOut(0) <= '0'; --PCP: set pulse // AP: ack pulse
			eventAckOut(7 downto 0) <= (others => '0'); --PCP: set pulse // AP: ack pulse
			
			if bIsPcp then
				--shift register for edge det
				rpdo_change_tog_l <= rpdo_change_tog;
				tpdo_change_tog_l <= tpdo_change_tog;
				
				--edge detection
				---tpdo
				if tpdo_change_tog_l /= tpdo_change_tog then
					tPdoTrigger <= '1';
				end if;
				---rpdo
				for i in rpdo_change_tog'range loop
					if rpdo_change_tog_l(i) /= rpdo_change_tog(i) then
						rPdoTrigger(i) <= '1';
					end if;
				end loop;
			end if;
			
			if wr = '1' and sel = '1' and selDpr = '0' then
				case conv_integer(addr)*4 is
					when 16#00# =>
						--RO
					when 16#04# =>
						--RO
					when 16#08# =>
						--STORED IN DPR
					when 16#0C# =>
						--STORED IN DPR
					when 16#10# =>
						--STORED IN DPR
					when 16#14# =>
						--STORED IN DPR
					when 16#18# =>
						--STORED IN DPR
					when 16#1C# =>
						--STORED IN DPR
					when 16#20# =>
						--STORED IN DPR
					when 16#24# =>
						--STORED IN DPR
					when 16#28# =>
						--STORED IN DPR
					when 16#2C# =>
						--AP ONLY
						if be(0) = '1' and bIsPcp = false then
							--asyncIrqCtrlOut(7 downto 0) <= din(7 downto 0);
							asyncIrqCtrlOut(0) <= din(0); --rest is ignored
						end if;
						if be(1) = '1' and bIsPcp = false then
							--asyncIrqCtrlOut(15 downto 8) <= din(15 downto 8);
							asyncIrqCtrlOut(15) <= din(15); --rest is ignored
						end if;
						if be(2) = '1' then
							eventAckOut(7 downto 0) <= din(23 downto 16);
						end if;
--ignore higher byte of event ack
--						if be(3) = '1' then
--							eventAckOut(15 downto 8) <= din(31 downto 24);
--						end if;
					when 16#30# =>
						--RO
					when 16#34# =>
						--RO
					when 16#38# =>
						--RO
					when 16#3C# =>
						--RO
					when 16#40# =>
						--RO
					when 16#44# =>
						--RO
					when 16#48# =>
						--RO
					when 16#4C# =>
						--RO
					when 16#50# =>
						--RESERVED
					when 16#54# =>
						--RESERVED
					when 16#58# =>
						if be(0) = '1' then
							tPdoTrigger <= '1';
						end if;
						if be(1) = '1' then
							tPdoTrigger <= '1';
						end if;
						if be(2) = '1' then
							rPdoTrigger(0) <= '1';
						end if;
						if be(3) = '1' then
							rPdoTrigger(0) <= '1';
						end if;
					when 16#5C# =>
						if be(0) = '1' then
							rPdoTrigger(1) <= '1';
						end if;
						if be(1) = '1' then
							rPdoTrigger(1) <= '1';
						end if;
						if be(2) = '1' then
							rPdoTrigger(2) <= '1';
						end if;
						if be(3) = '1' then
							rPdoTrigger(2) <= '1';
						end if;
					when 16#60# =>
						if be(0) = '1' then
							apIrqControlOut(7 downto 0) <= din(7 downto 0);
						end if;
						if be(1) = '1' then
							apIrqControlOut(15 downto 8) <= din(15 downto 8);
						end if;
					when 16#64# =>
						--RESERVED
					when 16#68# =>
						--RESERVED
					when 16#6C# =>
						if be(0) = '1' then
							ledCtrlOut(7 downto 0) <= din(7 downto 0);
						end if;
--ignore higher byte of led gadget
--						if be(1) = '1' then
--							ledCtrlOut(15 downto 8) <= din(15 downto 8);
--						end if;
						if be(2) = '1' then
							ledCnfgOut(7 downto 0) <= din(23 downto 16);
						end if;
--						if be(3) = '1' then
--							ledCnfgOut(15 downto 8) <= din(31 downto 24);
--						end if;
					when others =>
				end case;
			end if;
		end if;
	end process;
		
end architecture rtl;

------------------------------------------------------------------------------------------------------------------------
-- entity for AP IRQ generation
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity apIrqGen is
	generic (
		genOnePdiClkDomain_g		:		boolean := false
	);
	port (
		--CLOCK DOMAIN PCP
		clkA							: in	std_logic;
		rstA							: in	std_logic;
		irqA							: in	std_logic; --toggle from MAC
		enableA							: in	std_logic; --APIRQ_CONTROL / IRQ_En
		modeA							: in	std_logic; --APIRQ_CONTROL / IRQ_MODE
		setA							: in	std_logic; --APIRQ_CONTROL / IRQ_SET
		--CLOCK DOMAIN AP
		clkB							: in	std_logic;
		rstB							: in	std_logic;
		ackB							: in	std_logic; --APIRQ_CONTROL / IRQ_ACK
		irqB							: out	std_logic
	);
end entity apIrqGen;

architecture rtl of apIrqGen is
type fsm_t is (wait4event, setIrq, wait4ack);
signal fsm								:		fsm_t;
signal enable, mode, irq, toggle, set	:		std_logic;
begin
	
	--everything is done in clkB domain!
	theFsm : process(clkB, rstB)
	begin
		if rstB = '1' then
			irqB <= '0';
			fsm <= wait4event;
		elsif clkB = '1' and clkB'event then
			if enable = '1' then
				case fsm is
					when wait4event =>
						if mode = '0' and set = '1' then
							fsm <= setIrq;
						elsif mode = '1' and irq = '1' then
							fsm <= setIrq;
						else
							fsm <= wait4event;
						end if;
					when setIrq =>
						irqB <= '1';
						fsm <= wait4ack;
					when wait4ack =>
						if ackB = '1' then
							irqB <= '0';
							fsm <= wait4event;
						else
							fsm <= wait4ack;
						end if;
				end case;
			else
				irqB <= '0';
				fsm <= wait4event;
			end if;
		end if;
	end process;
	
	syncEnable : entity work.sync
		generic map (
			doSync_g => not genOnePdiClkDomain_g
		)
		port map (
			inData => enableA,
			outData => enable,
			clk => clkB,
			rst => rstB
		);
	
	syncSet : entity work.slow2fastSync
		generic map (
			doSync_g => not genOnePdiClkDomain_g
		)
		port map (
			dataSrc => setA,
			dataDst => set,
			clkSrc => clkA,
			rstSrc => rstA,
			clkDst => clkB,
			rstDst => rstB
		);
	
	syncMode : entity work.sync
		generic map (
			doSync_g => not genOnePdiClkDomain_g
		)
		port map (
			inData => modeA,
			outData => mode,
			clk => clkB,
			rst => rstB
		);
	
	syncToggle : entity work.sync
		generic map (
			doSync_g => not genOnePdiClkDomain_g
		)
		port map (
			inData => irqA,
			outData => toggle,
			clk => clkB,
			rst => rstB
		);
	
	toggleEdgeDet : entity work.edgeDet
		port map (
			inData => toggle,
			rising => open,
			falling => open,
			any => irq,
			clk => clkB,
			rst => rstB
		);
	
end architecture rtl;

------------------------------------------------------------------------------------------------------------------------
-- entity for asynchronous Tx/Rx buffers, and Tpdo/Rpdo descriptors (simple dpr mapping)
------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pdiSimpleReg is
	generic (
			iAddrWidth_g				:		integer := 10; --only use effective addr range (e.g. 2kB leads to iAddrWidth_g := 10)
			iBaseMap2_g					:		integer := 0; --base address in dpr
			iDprAddrWidth_g				:		integer := 12
	);
			
	port (   
			--memory mapped interface
			sel							: in	std_logic;
			wr							: in	std_logic;
			rd							: in	std_logic;
			addr						: in	std_logic_vector(iAddrWidth_g-1 downto 0);
			be							: in	std_logic_vector(3 downto 0);
			din							: in	std_logic_vector(31 downto 0);
			dout						: out	std_logic_vector(31 downto 0);
			--dpr interface (from PCP/AP to DPR)
			dprAddrOff					: out	std_logic_vector(iDprAddrWidth_g downto 0);
			dprDin						: out	std_logic_vector(31 downto 0);
			dprDout						: in	std_logic_vector(31 downto 0);
			dprBe						: out	std_logic_vector(3 downto 0);
			dprWr						: out	std_logic
			
	);
end entity pdiSimpleReg;

architecture rtl of pdiSimpleReg is
signal addrRes							:		std_logic_vector(dprAddrOff'range);
begin
	
	--assign content to dpr
	dprDin		<=	din;
	dprBe		<=	be;
	dprWr		<=	wr		when	sel = '1'		else
					'0';
	dout		<=	dprDout	when	sel = '1'		else
					(others => '0');
	dprAddrOff	<=	addrRes when	sel = '1'		else
					(others => '0');
	
	--address conversion
	---map external address mapping into dpr
	addrRes <= '0' & conv_std_logic_vector(iBaseMap2_g, addrRes'length - 1);
		
end architecture rtl;

----------------
--synchronizer--
----------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sync IS
	GENERIC (
			doSync_g					:		BOOLEAN := TRUE
	);
	PORT (
			inData						: IN	STD_LOGIC;
			outData						: OUT	STD_LOGIC;
			clk							: IN	STD_LOGIC;
			rst							: IN	STD_LOGIC
	);
END ENTITY sync;

ARCHITECTURE rtl OF sync IS
SIGNAL sync1_s, sync2_s					: STD_LOGIC;
BEGIN
	
	outData <= sync2_s when doSync_g = TRUE else inData;
	
	genSync : IF doSync_g = TRUE GENERATE
		syncShiftReg : PROCESS(clk, rst)
		BEGIN
			IF rst = '1' THEN
				sync1_s <= '0';
				sync2_s <= '0';
			ELSIF clk = '1' AND clk'EVENT THEN
				sync1_s <= inData; --1st ff
				sync2_s <= sync1_s; --2nd ff
			END IF;
		END PROCESS syncShiftReg;
	END GENERATE;
END ARCHITECTURE rtl;

-----------------
--edge detector--
-----------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY edgeDet IS
	PORT (
			inData						: IN	STD_LOGIC;
			rising						: OUT	STD_LOGIC;
			falling						: OUT	STD_LOGIC;
			any							: OUT	STD_LOGIC;
			clk							: IN	STD_LOGIC;
			rst							: IN	STD_LOGIC
	);
END ENTITY edgeDet;

ARCHITECTURE rtl OF edgeDet IS
SIGNAL sreg								: STD_LOGIC_VECTOR(1 downto 0);
BEGIN
	
	any <= sreg(1) xor sreg(0);
	falling <= sreg(1) and not sreg(0);
	rising <= not sreg(1) and sreg(0);
	
	shiftReg : PROCESS(clk, rst)
	BEGIN
		IF rst = '1' THEN
			sreg <= (others => '0');
		ELSIF clk = '1' AND clk'EVENT THEN
			sreg <= sreg(0) & inData;
		END IF;
	END PROCESS;
	
END ARCHITECTURE rtl;

--------------------------
--slow2fast synchronizer--
--------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY slow2fastSync IS
	GENERIC (
			doSync_g					:		BOOLEAN := TRUE
	);
	PORT (
			dataSrc						: IN	STD_LOGIC;
			dataDst						: OUT	STD_LOGIC;
			clkSrc						: IN	STD_LOGIC;
			rstSrc						: IN	STD_LOGIC;
			clkDst						: IN	STD_LOGIC;
			rstDst						: IN	STD_LOGIC
	);
END ENTITY slow2fastSync;

ARCHITECTURE rtl OF slow2fastSync IS
signal toggle, toggleSync, pulse, dataDst_s : std_logic;
begin
	
	dataDst <= dataDst_s when doSync_g = TRUE else dataSrc;
	
	genSync : IF doSync_g = TRUE GENERATE
		firstEdgeDet : entity work.edgeDet
			port map (
				inData => dataSrc,
				rising => pulse,
				falling => open,
				any => open,
				clk => clkSrc,
				rst => rstSrc
			);
		
		process(clkSrc, rstSrc)
		begin
			if rstSrc = '1' then
				toggle <= '0';
			elsif clkSrc = '1' and clkSrc'event then
				if pulse = '1' then
					toggle <= not toggle;
				end if;
			end if;
		end process;
		
		sync : entity work.sync
			port map (
				inData => toggle,
				outData => toggleSync,
				clk => clkDst,
				rst => rstDst
			);
		
		secondEdgeDet : entity work.edgeDet
			port map (
				inData => toggleSync,
				rising => open,
				falling => open,
				any => dataDst_s,
				clk => clkDst,
				rst => rstDst
			);
	END GENERATE;
		
END ARCHITECTURE rtl;
