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
-- 2010-06-28  V0.01	zelenkaj    First version
-- 2010-08-16  V0.10	zelenkaj	Added the possibility for more RPDOs
-- 2010-08-23  V0.11	zelenkaj	Added IRQ generation
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
			iRpdos_g					:		integer := 3;
			iTpdos_g					:		integer := 1;
			--PDO buffer size *3
			iTpdoBufSize_g				:		integer := 100;
			iRpdo0BufSize_g				:		integer := 100;
			iRpdo1BufSize_g				:		integer := 100;
			iRpdo2BufSize_g				:		integer := 100;
			--PDO-objects
			iTpdoObjNumber_g			:		integer := 10;
			iRpdoObjNumber_g			:		integer := 10; --includes all PDOs!!!
			--asynchronous TX and RX buffer size
			iAsyTxBufSize_g				:		integer := 1500;
			iAsyRxBufSize_g				:		integer := 1500
	);
			
	port (   
			pcp_reset					: in    std_logic;
			pcp_clk                  	: in    std_logic;
			ap_reset					: in    std_logic;
			ap_clk						: in	std_logic;
		-- Avalon Slave Interface for PCP
            pcp_chipselect              : in    std_logic;
            pcp_read					: in    std_logic;
            pcp_write					: in    std_logic;
            pcp_byteenable	            : in    std_logic_vector(3 DOWNTO 0);
            pcp_address                 : in    std_logic_vector(14 DOWNTO 0);
            pcp_writedata               : in    std_logic_vector(31 DOWNTO 0);
            pcp_readdata                : out   std_logic_vector(31 DOWNTO 0);
			pcp_irq						: in	std_logic; --should be connected to the Time Cmp Irq of openMAC!
		-- Avalon Slave Interface for AP
            ap_chipselect               : in    std_logic;
            ap_read						: in    std_logic;
            ap_write					: in    std_logic;
            ap_byteenable             	: in    std_logic_vector(3 DOWNTO 0);
            ap_address                  : in    std_logic_vector(14 DOWNTO 0);
            ap_writedata                : in    std_logic_vector(31 DOWNTO 0);
            ap_readdata                 : out   std_logic_vector(31 DOWNTO 0);
			ap_irq						: out	std_logic --Irq to the AP
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
constant	extCntStReg_c				: memoryMapping_t := (16#0000#, 16#3C#);
----asynchronous buffers
constant	extTAsynBuf_c				: memoryMapping_t := (16#0800#, iAsyTxBufSize_g + 4);
constant	extRAsynBuf_c				: memoryMapping_t := (16#1000#, iAsyRxBufSize_g + 4);
----pdo descriptors
constant	extTpdoDesc_c				: memoryMapping_t := (16#1800#, iTpdoObjNumber_g * 8);
constant	extRpdoDesc_c				: memoryMapping_t := (16#2000#, iRpdoObjNumber_g * 8);
----pdo buffer
constant	extTpdoBuf_c				: memoryMapping_t := (16#2800#, iTpdoBufSize_g + 0);
constant	extRpdo0Buf_c				: memoryMapping_t := (16#3000#, iRpdo0BufSize_g + 16);
constant	extRpdo1Buf_c				: memoryMapping_t := (16#3800#, iRpdo1BufSize_g + 16);
constant	extRpdo2Buf_c				: memoryMapping_t := (16#4000#, iRpdo2BufSize_g + 16);
---memory mapping inside the PDI's DPR
----control / status register
constant	intCntStReg_c				: memoryMapping_t := (16#0000#, 16#C#);
----asynchronous buffers
constant	intTAsynBuf_c				: memoryMapping_t := (intCntStReg_c.base + intCntStReg_c.span, align32(extTAsynBuf_c.span));
constant	intRAsynBuf_c				: memoryMapping_t := (intTAsynBuf_c.base + intTAsynBuf_c.span, align32(extRAsynBuf_c.span));
----pdo descriptors
constant	intTpdoDesc_c				: memoryMapping_t := (intRAsynBuf_c.base + intRAsynBuf_c.span, align32(extTpdoDesc_c.span));
constant	intRpdoDesc_c				: memoryMapping_t := (intTpdoDesc_c.base + intTpdoDesc_c.span, align32(extRpdoDesc_c.span));
----pdo buffers (triple buffers considered!)
constant	intTpdoBuf_c				: memoryMapping_t := (intRpdoDesc_c.base + intRpdoDesc_c.span, align32(extTpdoBuf_c.span) *3);
constant	intRpdo0Buf_c				: memoryMapping_t := (intTpdoBuf_c.base  + intTpdoBuf_c.span,  align32(extRpdo0Buf_c.span)*3);
constant	intRpdo1Buf_c				: memoryMapping_t := (intRpdo0Buf_c.base + intRpdo0Buf_c.span, align32(extRpdo1Buf_c.span)*3);
constant	intRpdo2Buf_c				: memoryMapping_t := (intRpdo1Buf_c.base + intRpdo1Buf_c.span, align32(extRpdo2Buf_c.span)*3);
----obtain dpr size of different configurations
constant	dprSize_c					: integer := (	intCntStReg_c.span +
														intTAsynBuf_c.span +
														intRAsynBuf_c.span +
														intTpdoDesc_c.span +
														intRpdoDesc_c.span +
														intTpdoBuf_c.span  +
														intRpdo0Buf_c.span +
														intRpdo1Buf_c.span +
														intRpdo2Buf_c.span );
constant	dprAddrWidth_c				: integer := integer(ceil(log2(real(dprSize_c))));
---other constants
constant	magicNumber_c				: integer := 16#50435000#;
														
------------------------------------------------------------------------------------------------------------------------
--signals
---dpr
type dprSig_t is
	record
			addr						: std_logic_vector(dprAddrWidth_c-2-1 downto 0); --double word address!
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
signal		dprTAsynBuf_s				: dprPdi_t;
signal		dprRAsynBuf_s				: dprPdi_t;
----pdo descriptors
signal		dprTpdoDesc_s				: dprPdi_t;
signal		dprRpdoDesc_s				: dprPdi_t;
----pdo buffers (triple buffers considered!)
signal		dprTpdoBuf_s				: dprPdi_t;
signal		dprRpdo0Buf_s				: dprPdi_t;
signal		dprRpdo1Buf_s				: dprPdi_t;
signal		dprRpdo2Buf_s				: dprPdi_t;
---chip select
----control / status register
signal		selCntStReg_s				: pdiSel_t;
----asynchronous buffers
signal		selTAsynBuf_s				: pdiSel_t;
signal		selRAsynBuf_s				: pdiSel_t;
----pdo descriptors
signal		selTpdoDesc_s				: pdiSel_t;
signal		selRpdoDesc_s				: pdiSel_t;
----pdo buffers (triple buffers considered!)
signal		selTpdoBuf_s				: pdiSel_t;
signal		selRpdo0Buf_s				: pdiSel_t;
signal		selRpdo1Buf_s				: pdiSel_t;
signal		selRpdo2Buf_s				: pdiSel_t;
---data output
----control / status register
signal		outCntStReg_s				: pdi32Bit_t;
----asynchronous buffers
signal		outTAsynBuf_s				: pdi32Bit_t;
signal		outRAsynBuf_s				: pdi32Bit_t;
----pdo descriptors
signal		outTpdoDesc_s				: pdi32Bit_t;
signal		outRpdoDesc_s				: pdi32Bit_t;
----pdo buffers (triple buffers considered!)
signal		outTpdoBuf_s				: pdi32Bit_t;
signal		outRpdo0Buf_s				: pdi32Bit_t;
signal		outRpdo1Buf_s				: pdi32Bit_t;
signal		outRpdo2Buf_s				: pdi32Bit_t;
---virtual buffer control/state
signal		vBufTriggerPdo_s			: pdiTrig_t; --tpdo, rpdo2, rpdo1, rpdo0
signal		vBufSel_s					: pdi32Bit_t := ((others => '1'), (others => '1')); --TXPDO_ACK | RXPDO2_ACK | RXPDO1_ACK | RXPDO0_ACK
---ap irq generation
signal		apIrqValue					: std_logic_vector(31 downto 0);
signal		apIrqControlPcp,
			apIrqControlAp				: std_logic_vector(7 downto 0);
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
							outTAsynBuf_s.pcp	when	selTAsynBuf_s.pcp = '1' else
							outRAsynBuf_s.pcp	when	selRAsynBuf_s.pcp = '1' else
							outTpdoDesc_s.pcp	when	selTpdoDesc_s.pcp = '1' else
							outRpdoDesc_s.pcp	when	selRpdoDesc_s.pcp = '1' else
							outTpdoBuf_s.pcp	when	selTpdoBuf_s.pcp  = '1' else
							outRpdo0Buf_s.pcp	when	selRpdo0Buf_s.pcp = '1' else
							outRpdo1Buf_s.pcp	when	selRpdo1Buf_s.pcp = '1'	else
							outRpdo2Buf_s.pcp	when	selRpdo2Buf_s.pcp = '1' else
							(others => '0');
		
		ap_readdata	<=		outCntStReg_s.ap	when 	selCntStReg_s.ap = '1' else
							outTAsynBuf_s.ap	when	selTAsynBuf_s.ap = '1' else
							outRAsynBuf_s.ap	when	selRAsynBuf_s.ap = '1' else
							outTpdoDesc_s.ap	when	selTpdoDesc_s.ap = '1' else
							outRpdoDesc_s.ap	when	selRpdoDesc_s.ap = '1' else
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
		address_a		=>		dpr.pcp.addr(dprAddrWidth_c-2-1 downto 0),
		address_b		=>		dpr.ap.addr(dprAddrWidth_c-2-1 downto 0),
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
	
	dpr.pcp	<=	dprCntStReg_s.pcp	when	selCntStReg_s.pcp = '1'	else
				dprTAsynBuf_s.pcp	when	selTAsynBuf_s.pcp = '1' else
				dprRAsynBuf_s.pcp	when	selRAsynBuf_s.pcp = '1' else
				dprTpdoDesc_s.pcp	when	selTpdoDesc_s.pcp = '1' else
				dprRpdoDesc_s.pcp	when	selRpdoDesc_s.pcp = '1' else
				dprTpdoBuf_s.pcp	when	selTpdoBuf_s.pcp = '1'	else
				dprRpdo0Buf_s.pcp	when	selRpdo0Buf_s.pcp = '1' and iRpdos_g >= 1 else
				dprRpdo1Buf_s.pcp	when	selRpdo1Buf_s.pcp = '1' and iRpdos_g >= 2 else
				dprRpdo2Buf_s.pcp	when	selRpdo2Buf_s.pcp = '1' and iRpdos_g >= 3 else
				((others => '0'), (others => '0'), (others => '0'), '0');
	
	dpr.ap	<=	dprCntStReg_s.ap	when	selCntStReg_s.ap = '1'	else
				dprTAsynBuf_s.ap	when	selTAsynBuf_s.ap = '1' 	else
				dprRAsynBuf_s.ap	when	selRAsynBuf_s.ap = '1' 	else
				dprTpdoDesc_s.ap	when	selTpdoDesc_s.ap = '1' 	else
				dprRpdoDesc_s.ap	when	selRpdoDesc_s.ap = '1' 	else
				dprTpdoBuf_s.ap		when	selTpdoBuf_s.ap = '1'	else
				dprRpdo0Buf_s.ap	when	selRpdo0Buf_s.ap = '1' 	and iRpdos_g >= 1 else
				dprRpdo1Buf_s.ap	when	selRpdo1Buf_s.ap = '1' 	and iRpdos_g >= 2 else
				dprRpdo2Buf_s.ap	when	selRpdo2Buf_s.ap = '1' 	and iRpdos_g >= 3 else
				((others => '0'), (others => '0'), (others => '0'), '0');
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- address decoder to generate select signals for different memory ranges
	theAddressDecoder : block
	begin
		--pcp side
		---control / status register
		selCntStReg_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extCntStReg_c.base and 
														 (conv_integer(pcp_address)*4 < extCntStReg_c.base + extCntStReg_c.span))
												else	'0';
		---asynchronous buffers
		selTAsynBuf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extTAsynBuf_c.base and 
														 (conv_integer(pcp_address)*4 < extTAsynBuf_c.base + extTAsynBuf_c.span))
												else	'0';
		selRAsynBuf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extRAsynBuf_c.base and 
														 (conv_integer(pcp_address)*4 < extRAsynBuf_c.base + extRAsynBuf_c.span))
												else	'0';
		---pdo descriptors
		selTpdoDesc_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extTpdoDesc_c.base and 
														 (conv_integer(pcp_address)*4 < extTpdoDesc_c.base + extTpdoDesc_c.span))
												else	'0';
		selRpdoDesc_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extRpdoDesc_c.base and 
														 (conv_integer(pcp_address)*4 < extRpdoDesc_c.base + extRpdoDesc_c.span))
												else	'0';
		---pdo buffers (triple buffers considered!)
		selTpdoBuf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extTpdoBuf_c.base and 
														 (conv_integer(pcp_address)*4 < extTpdoBuf_c.base + extTpdoBuf_c.span))
												else	'0';
		selRpdo0Buf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extRpdo0Buf_c.base and 
														 (conv_integer(pcp_address)*4 < extRpdo0Buf_c.base + extRpdo0Buf_c.span))
												else	'0';
		selRpdo1Buf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extRpdo1Buf_c.base and 
														 (conv_integer(pcp_address)*4 < extRpdo1Buf_c.base + extRpdo1Buf_c.span))
												else	'0';
		selRpdo2Buf_s.pcp	<=	pcp_chipselect	when	(conv_integer(pcp_address)*4 >= extRpdo2Buf_c.base and 
														 (conv_integer(pcp_address)*4 < extRpdo2Buf_c.base + extRpdo2Buf_c.span))
												else	'0';
		
		--ap side
		---control / status register
		selCntStReg_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extCntStReg_c.base and 
														 (conv_integer(ap_address)*4 < extCntStReg_c.base + extCntStReg_c.span))
												else	'0';
		---asynchronous buffers
		selTAsynBuf_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extTAsynBuf_c.base and 
														 (conv_integer(ap_address)*4 < extTAsynBuf_c.base + extTAsynBuf_c.span))
												else	'0';
		selRAsynBuf_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extRAsynBuf_c.base and 
														 (conv_integer(ap_address)*4 < extRAsynBuf_c.base + extRAsynBuf_c.span))
												else	'0';
		---pdo descriptors
		selTpdoDesc_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extTpdoDesc_c.base and 
														 (conv_integer(ap_address)*4 < extTpdoDesc_c.base + extTpdoDesc_c.span))
												else	'0';
		selRpdoDesc_s.ap	<=	ap_chipselect	when	(conv_integer(ap_address)*4 >= extRpdoDesc_c.base and 
														 (conv_integer(ap_address)*4 < extRpdoDesc_c.base + extRpdoDesc_c.span))
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
			--memory map from 0x4 to 0x0f into dpr
			iBaseDpr_g					=> 16#4#/4, --base address of content to be mapped to dpr
			iSpanDpr_g					=> intCntStReg_c.span/4, --size of content to be mapped to dpr
			iBaseMap2_g					=> intCntStReg_c.base/4, --base address in dpr
			iDprAddrWidth_g				=> dprCntStReg_s.pcp.addr'length,
			iRpdos_g					=> iRpdos_g
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
			---constant values
			magicNumber					=> conv_std_logic_vector(magicNumber_c, 32),
			tPdoBuffer					=> conv_std_logic_vector(extTpdoBuf_c.base, 16) & 
											conv_std_logic_vector(extTpdoBuf_c.span, 16),
			rPdo0Buffer					=> conv_std_logic_vector(extRpdo0Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo0Buf_c.span, 16),
			rPdo1Buffer					=> conv_std_logic_vector(extRpdo1Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo1Buf_c.span, 16),
			rPdo2Buffer					=> conv_std_logic_vector(extRpdo2Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo2Buf_c.span, 16),
			tPdoDesc					=> conv_std_logic_vector(extTpdoDesc_c.base, 16) & 
											conv_std_logic_vector(extTpdoDesc_c.span, 16),
			rPdoDesc					=> conv_std_logic_vector(extRpdoDesc_c.base, 16) & 
											conv_std_logic_vector(extRpdoDesc_c.span, 16),
			rAsyncBuffer				=> conv_std_logic_vector(extRAsynBuf_c.base, 16) & 
											conv_std_logic_vector(extRAsynBuf_c.span, 16),
			tAsyncBuffer				=> conv_std_logic_vector(extTAsynBuf_c.base, 16) & 
											conv_std_logic_vector(extTAsynBuf_c.span, 16),
			---virtual buffer control signals
			pdoVirtualBufferSel			=> vBufSel_s.pcp,
			tPdoTrigger					=> vBufTriggerPdo_s.pcp(3),
			rPdoTrigger					=> vBufTriggerPdo_s.pcp(2 downto 0),
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprCntStReg_s.pcp.addr,
			dprDin						=> dprCntStReg_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprCntStReg_s.pcp.be,
			dprWr						=> dprCntStReg_s.pcp.wr,
			--ap irq generation
			apIrqValue					=> apIrqValue,
			apIrqControl				=> apIrqControlPcp
	);
	
	theCntrlStatReg4Ap : entity work.pdiControlStatusReg
	generic map (
			bIsPcp						=> false,
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			--memory map from 0x4 to 0x0f into dpr
			iBaseDpr_g					=> 16#4#/4, --base address of content to be mapped to dpr
			iSpanDpr_g					=> intCntStReg_c.span/4, --size of content to be mapped to dpr
			iBaseMap2_g					=> intCntStReg_c.base/4, --base address in dpr
			iDprAddrWidth_g				=> dprCntStReg_s.ap.addr'length,
			iRpdos_g					=> iRpdos_g
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
			---constant values
			magicNumber					=> conv_std_logic_vector(magicNumber_c, 32),
			tPdoBuffer					=> conv_std_logic_vector(extTpdoBuf_c.base, 16) & 
											conv_std_logic_vector(extTpdoBuf_c.span, 16),
			rPdo0Buffer					=> conv_std_logic_vector(extRpdo0Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo0Buf_c.span, 16),
			rPdo1Buffer					=> conv_std_logic_vector(extRpdo1Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo1Buf_c.span, 16),
			rPdo2Buffer					=> conv_std_logic_vector(extRpdo2Buf_c.base, 16) & 
											conv_std_logic_vector(extRpdo2Buf_c.span, 16),
			tPdoDesc					=> conv_std_logic_vector(extTpdoDesc_c.base, 16) & 
											conv_std_logic_vector(extTpdoDesc_c.span, 16),
			rPdoDesc					=> conv_std_logic_vector(extRpdoDesc_c.base, 16) & 
											conv_std_logic_vector(extRpdoDesc_c.span, 16),
			rAsyncBuffer				=> conv_std_logic_vector(extRAsynBuf_c.base, 16) & 
											conv_std_logic_vector(extRAsynBuf_c.span, 16),
			tAsyncBuffer				=> conv_std_logic_vector(extTAsynBuf_c.base, 16) & 
											conv_std_logic_vector(extTAsynBuf_c.span, 16),
			---virtual buffer control signals
			pdoVirtualBufferSel			=> vBufSel_s.ap,
			tPdoTrigger					=> vBufTriggerPdo_s.ap(3),
			rPdoTrigger					=> vBufTriggerPdo_s.ap(2 downto 0),
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprCntStReg_s.ap.addr,
			dprDin						=> dprCntStReg_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprCntStReg_s.ap.be,
			dprWr						=> dprCntStReg_s.ap.wr,
			--ap irq generation
			--apIrqValue					=>
			apIrqControl				=> apIrqControlAp
	);
	
	theApIrqGenerator : entity work.apIrqGen
	generic map (
		cntWidth => 32
	)
			
	port map (
		--CLOCK DOMAIN PCP
		clkA => pcp_clk,
		rstA => pcp_reset,
		irqA => pcp_irq,
		preValA => apIrqValue,
		enableA => apIrqControlPcp(7),
		modeA => apIrqControlPcp(6),
		setA => apIrqControlPcp(0),
		--CLOCK DOMAIN AP
		clkB => ap_clk,
		rstB => ap_reset,
		ackB => apIrqControlAp(0),
		irqB => ap_irq
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Tx buffer
	theTxAsyncBuf4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intTAsynBuf_c.base/4,
			iDprAddrWidth_g				=> dprTAsynBuf_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selTAsynBuf_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outTAsynBuf_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprTAsynBuf_s.pcp.addr,
			dprDin						=> dprTAsynBuf_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprTAsynBuf_s.pcp.be,
			dprWr						=> dprTAsynBuf_s.pcp.wr
	);
	
	theTxAsyncBuf4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intTAsynBuf_c.base/4,
			iDprAddrWidth_g				=> dprTAsynBuf_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selTAsynBuf_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outTAsynBuf_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprTAsynBuf_s.ap.addr,
			dprDin						=> dprTAsynBuf_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprTAsynBuf_s.ap.be,
			dprWr						=> dprTAsynBuf_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- asynchronous Rx buffer
	theRxAsyncBuf4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intRAsynBuf_c.base/4,
			iDprAddrWidth_g				=> dprRAsynBuf_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selRAsynBuf_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outRAsynBuf_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprRAsynBuf_s.pcp.addr,
			dprDin						=> dprRAsynBuf_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprRAsynBuf_s.pcp.be,
			dprWr						=> dprRAsynBuf_s.pcp.wr
	);
	
	theRxAsyncBuf4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intRAsynBuf_c.base/4,
			iDprAddrWidth_g				=> dprRAsynBuf_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selRAsynBuf_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outRAsynBuf_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprRAsynBuf_s.ap.addr,
			dprDin						=> dprRAsynBuf_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprRAsynBuf_s.ap.be,
			dprWr						=> dprRAsynBuf_s.ap.wr
	);
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- TPDO descriptors
	theTpdoDesc4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intTpdoDesc_c.base/4,
			iDprAddrWidth_g				=> dprTpdoDesc_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selTpdoDesc_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outTpdoDesc_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprTpdoDesc_s.pcp.addr,
			dprDin						=> dprTpdoDesc_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprTpdoDesc_s.pcp.be,
			dprWr						=> dprTpdoDesc_s.pcp.wr
	);
	
	theTpdoDesc4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intTpdoDesc_c.base/4,
			iDprAddrWidth_g				=> dprTpdoDesc_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selTpdoDesc_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outTpdoDesc_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprTpdoDesc_s.ap.addr,
			dprDin						=> dprTpdoDesc_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprTpdoDesc_s.ap.be,
			dprWr						=> dprTpdoDesc_s.ap.wr
	);
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- RPDO descriptors
	theRpdoDesc4Pcp : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intRpdoDesc_c.base/4,
			iDprAddrWidth_g				=> dprRpdoDesc_s.pcp.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selRpdoDesc_s.pcp,
			wr							=> pcp_write,
			rd							=> pcp_read,
			addr						=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> pcp_byteenable,
			din							=> pcp_writedata,
			dout						=> outRpdoDesc_s.pcp,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprRpdoDesc_s.pcp.addr,
			dprDin						=> dprRpdoDesc_s.pcp.din,
			dprDout						=> dprOut.pcp,
			dprBe						=> dprRpdoDesc_s.pcp.be,
			dprWr						=> dprRpdoDesc_s.pcp.wr
	);
	
	theRpdoDesc4Ap : entity work.pdiSimpleReg
	generic map (
			iAddrWidth_g				=> extLog2MaxOneSpan-2,
			iBaseMap2_g					=> intRpdoDesc_c.base/4,
			iDprAddrWidth_g				=> dprRpdoDesc_s.ap.addr'length
	)
			
	port map (   
			--memory mapped interface
			sel							=> selRpdoDesc_s.ap,
			wr							=> ap_write,
			rd							=> ap_read,
			addr						=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			be							=> ap_byteenable,
			din							=> ap_writedata,
			dout						=> outRpdoDesc_s.ap,
			--dpr interface (from PCP/AP to DPR)
			dprAddr						=> dprRpdoDesc_s.ap.addr,
			dprDin						=> dprRpdoDesc_s.ap.din,
			dprDout						=> dprOut.ap,
			dprBe						=> dprRpdoDesc_s.ap.be,
			dprWr						=> dprRpdoDesc_s.ap.wr
	);
--
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
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intTpdoBuf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intTpdoBuf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprTpdoBuf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(3),
			pcpInAddr					=> pcp_address(extLog2MaxOneSpan-1-2 downto 0),
			pcpOutAddr					=> dprTpdoBuf_s.pcp.addr,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset						=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(3),
			apInAddr					=> ap_address(extLog2MaxOneSpan-1-2 downto 0),
			apOutAddr					=> dprTpdoBuf_s.ap.addr,
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
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo0Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo0Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo0Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(0),
			pcpInAddr					=> pcp_address(extLog2MaxOneSpan-1-2 downto 0), --tmpPcpAddr,
			pcpOutAddr					=> dprRpdo0Buf_s.pcp.addr,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset					=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(0),
			apInAddr					=> ap_address(extLog2MaxOneSpan-1-2 downto 0), --tmpApAddr,
			apOutAddr					=> dprRpdo0Buf_s.ap.addr,
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
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo1Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo1Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo1Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(1),
			pcpInAddr					=> pcp_address(extLog2MaxOneSpan-1-2 downto 0), --tmpPcpAddr,
			pcpOutAddr					=> dprRpdo1Buf_s.pcp.addr,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset					=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(1),
			apInAddr					=> ap_address(extLog2MaxOneSpan-1-2 downto 0), --tmpApAddr,
			apOutAddr					=> dprRpdo1Buf_s.ap.addr,
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
			--base address of virtual buffers in DPR
			iVirtualBufferBase_g		=> intRpdo2Buf_c.base/4, --double word!
			--size of one virtual buffer in DPR (must be aligned!!!)
			iVirtualBufferSize_g		=> intRpdo2Buf_c.span/3/4, --double word!
			--out address width
			iOutAddrWidth_g				=> dprRpdo2Buf_s.pcp.addr'length,
			--in address width
			iInAddrWidth_g				=> extLog2MaxOneSpan-2 --dprRpdo0Buf_s.pcp.addr'length
		)
		
		port map (
			pcpClk						=> pcp_clk,
			pcpReset					=> pcp_reset,
			pcpTrigger					=> vBufTriggerPdo_s.pcp(2),
			pcpInAddr					=> pcp_address(extLog2MaxOneSpan-1-2 downto 0), --tmpPcpAddr,
			pcpOutAddr					=> dprRpdo2Buf_s.pcp.addr,
			pcpOutSelVBuf				=> selVBufPcpOneHot,
			apClk						=> ap_clk,
			apReset					=> ap_reset,
			apTrigger					=> vBufTriggerPdo_s.ap(2),
			apInAddr					=> ap_address(extLog2MaxOneSpan-1-2 downto 0), --tmpApAddr,
			apOutAddr					=> dprRpdo2Buf_s.ap.addr,
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
			iRpdos_g					:		integer := 3
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
			---constant values
			magicNumber					: in	std_Logic_vector(31 downto 0);
			tPdoBuffer					: in	std_logic_vector(31 downto 0);
			rPdo0Buffer					: in	std_logic_vector(31 downto 0);
			rPdo1Buffer					: in	std_logic_vector(31 downto 0);
			rPdo2Buffer					: in	std_logic_vector(31 downto 0);
			tPdoDesc					: in	std_logic_vector(31 downto 0);
			rPdoDesc					: in	std_logic_vector(31 downto 0);
			rAsyncBuffer				: in	std_logic_vector(31 downto 0);
			tAsyncBuffer				: in	std_logic_vector(31 downto 0);
			---virtual buffer control signals
			pdoVirtualBufferSel			: in	std_logic_vector(31 downto 0); --for debugging purpose from SW side
			tPdoTrigger					: out	std_logic; --TPDO virtual buffer change trigger
			rPdoTrigger					: out	std_logic_vector(2 downto 0); --RPDOs virtual buffer change triggers
			---is used for Irq Generation and should be mapped to apIrqGen
			apIrqValue					: out	std_logic_vector(31 downto 0); --pcp only
			apIrqControl				: out	std_logic_vector(7 downto 0);
			--dpr interface (from PCP/AP to DPR)
			dprAddr						: out	std_logic_vector(iDprAddrWidth_g-1 downto 0);
			dprDin						: out	std_logic_vector(31 downto 0);
			dprDout						: in	std_logic_vector(31 downto 0);
			dprBe						: out	std_logic_vector(3 downto 0);
			dprWr						: out	std_logic
			
	);
end entity pdiControlStatusReg;

architecture rtl of pdiControlStatusReg is
signal selDpr							:		std_logic; --if '1' get/write content from/to dpr
signal nonDprDout						:		std_logic_vector(31 downto 0);
signal addrRes							:		std_logic_vector(dprAddr'range);
signal apIrqValue_s						: 		std_logic_vector(31 downto 0); --pcp only
signal apIrqControl_s					: 		std_logic_vector(7 downto 0);
begin	
	
	apIrqValue <= apIrqValue_s;
	apIrqControl <= apIrqControl_s;
	
	--generate dpr select signal
	selDpr	<=	sel		when	(conv_integer(addr) >= iBaseDpr_g AND
								 conv_integer(addr) <  iBaseDpr_g + iSpanDpr_g)
						else	'0';

	--assign content depending on selDpr
	dprDin	<=	din;
	dprBe	<=	be;
	dprWr	<=	wr		when	selDpr = '1'	else
				'0';
	dout	<=	dprDout	when	selDpr = '1'	else
				nonDprDout;
	dprAddr	<=	addrRes when	selDpr = '1'	else
				(others => '0');
	
	--address conversion
	---map external address mapping into dpr
	---e.g. external address 0x4 converts to internal address 0x0
	addrRes <=	conv_std_logic_vector(conv_integer(addr) - iBaseDpr_g + iBaseMap2_g, addrRes'length);
	
	--non dpr content
	process(clk, rst)
	begin
		if rst = '1' then
			tPdoTrigger <= '0';
			rPdoTrigger <= (others => '0');
			nonDprDout <= (others => '0');
			apIrqValue_s <= (others => '0');
			apIrqControl_s <= (others => '0');
		elsif clk = '1' and clk'event then
			tPdoTrigger <= '0';
			rPdoTrigger <= (others => '0');
			apIrqControl_s(0) <= '0'; --ack/set generates 50Meg pulse
			
			if rd = '1' then
				case conv_integer(addr)*4 is
					when 16#00# =>
						nonDprDout	<=	magicNumber;
					when 16#10# =>
						nonDprDout	<=	tPdoBuffer;
					when 16#14# =>
						nonDprDout	<=	rPdo0Buffer;
					when 16#18# =>
						if iRpdos_g >= 2 then
							nonDprDout	<=	rPdo1Buffer;
						else
							nonDprDout <= x"00C0FFEE";
						end if;
					when 16#1C# =>
						if iRpdos_g >= 3 then
							nonDprDout	<=	rPdo2Buffer;
						else
							nonDprDout <= x"00C0FFEE";
						end if;
					when 16#20# =>
						nonDprDout	<=	tPdoDesc;
					when 16#24# =>
						nonDprDout	<=	rPdoDesc;
					when 16#28# =>
						nonDprDout	<=	tAsyncBuffer;
					when 16#2C# =>
						nonDprDout	<=	rAsyncBuffer;
					when 16#30# =>
						nonDprDout	<=	pdoVirtualBufferSel;
					when 16#34# =>
						if bIsPcp then
							nonDprDout	<=	apIrqValue_s;
						else
							nonDprDout	<=	x"DEADC0DE";
						end if;
					when 16#38# =>
						nonDprDout	<=	x"000000" & apIrqControl_s; 
					when others =>
						nonDprDout	<=	x"DEADC0DE";
				end case;
			elsif wr = '1' and sel = '1' and selDpr = '0' then
				case conv_integer(addr)*4 is
					when 16#30# =>
						if be(3) = '1' then
							tPdoTrigger <= '1';
						end if;
						for i in 2 downto 0 loop
							if be(i) = '1' then
								rPdoTrigger(i) <= '1';
							end if;
						end loop;
					when 16#34# =>
						if bIsPcp then
							for i in 3 downto 0 loop
								if be(i) = '1' then
									apIrqValue_s((i+1)*8-1 downto i*8) <= din((i+1)*8-1 downto i*8);
								end if;
							end loop;
						end if;
					when 16#38# =>
						if be(0) = '1' then
							apIrqControl_s <= din(7 downto 0);
						end if;
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
		cntWidth						:		integer := 32
	);
			
	port (
		--CLOCK DOMAIN PCP
		clkA							: in	std_logic;
		rstA							: in	std_logic;
		irqA							: in	std_logic;
		preValA							: in	std_logic_vector(cntWidth-1 downto 0); --APIRQ_VALUE (by PCP)
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
type fsm_t is (wait4event, count, setIrq, wait4ack);
signal fsm								:		fsm_t;
signal preVal, cnt						:		std_logic_vector(cntWidth-1 downto 0);
signal enable, mode, irq, set, cntRst	:		std_logic;
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
							fsm <= count;
						else
							fsm <= wait4event;
						end if;
					when count =>
						if cntRst = '1' then
							fsm <= setIrq;
						else
							fsm <= count;
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
	
	theCounter : process(clkB, rstB)
	begin
		if rstB = '1' then
			cnt <= (others => '0');
		elsif clkB = '1' and clkB'event then
			if cntRst = '1' then
				cnt <= (others => '0');
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	cntRst <= '1' when cnt = preVal or fsm /= count else '0';
	
	--use only one stage synchronizer for preVal (less LE required!)
	process(clkB, rstB)
	begin
		if rstB = '1' then
			preVal <= (others => '0');
		elsif clkB = '1' and clkB'event then
			preVal <= preValA;
		end if;
	end process;
	--sync those signals to clkB
--	syncPreVal : for i in cntWidth-1 downto 0 generate
--		theSync : entity work.sync
--			port map (
--				inData => preValA(i),
--				outData => preVal(i),
--				clk => clkB,
--				rst => rstB
--			);
--	end generate;
	
	syncEnable : entity work.sync
		port map (
			inData => enableA,
			outData => enable,
			clk => clkB,
			rst => rstB
		);
	
	syncSet : entity work.slow2fastSync
		port map (
			dataSrc => setA,
			dataDst => set,
			clkSrc => clkA,
			rstSrc => rstA,
			clkDst => clkB,
			rstDst => rstB
		);
	
	syncMode : entity work.sync
		port map (
			inData => modeA,
			outData => mode,
			clk => clkB,
			rst => rstB
		);
	
	syncIrq : entity work.slow2fastSync
		port map (
			dataSrc => irqA,
			dataDst => irq,
			clkSrc => clkA,
			rstSrc => rstA,
			clkDst => clkB,
			rstDst => rstB
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
			dprAddr						: out	std_logic_vector(iDprAddrWidth_g-1 downto 0);
			dprDin						: out	std_logic_vector(31 downto 0);
			dprDout						: in	std_logic_vector(31 downto 0);
			dprBe						: out	std_logic_vector(3 downto 0);
			dprWr						: out	std_logic
			
	);
end entity pdiSimpleReg;

architecture rtl of pdiSimpleReg is
signal addrRes							:		std_logic_vector(dprAddr'range);
begin
	
	--assign content to dpr
	dprDin	<=	din;
	dprBe	<=	be;
	dprWr	<=	wr		when	sel = '1'		else
				'0';
	dout	<=	dprDout	when	sel = '1'		else
				(others => '0');
	dprAddr	<=	addrRes when	sel = '1'		else
				(others => '0');
	
	--address conversion
	---map external address mapping into dpr
	---e.g. external address 0x4 converts to internal address 0x0
	addrRes <=	conv_std_logic_vector(conv_integer(addr) + iBaseMap2_g, addrRes'length);
		
end architecture rtl;

----------------
--synchronizer--
----------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sync IS
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
	outData <= sync2_s;
	
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
signal toggle, toggleSync, pulse : std_logic;
begin
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
			any => dataDst,
			clk => clkDst,
			rst => rstDst
		);
		
END ARCHITECTURE rtl;
