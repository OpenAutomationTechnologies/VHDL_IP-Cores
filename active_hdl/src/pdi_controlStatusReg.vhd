------------------------------------------------------------------------------------------------------------------------
-- Process Data Interface (PDI) status control register
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
-- 2011-09-14  	V0.01	zelenkaj    extract from pdi.vhd
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
						--STORED IN DPR					when 16#2C#,
						--STORED IN DPR					when 16#30#,
						(eventAckIn & asyncIrqCtrlIn) 	when 16#34#,
						tPdoBuffer 						when 16#38#,
						rPdo0Buffer 					when 16#3C#,
						rPdo1Buffer 					when 16#40#,
						rPdo2Buffer 					when 16#44#,
						asyncBuffer1Tx 					when 16#48#,
						asyncBuffer1Rx 					when 16#4C#,
						asyncBuffer2Tx 					when 16#50#,
						asyncBuffer2Rx 					when 16#54#,
						--RESERVED 						when 16#58#,
						--RESERVED 						when 16#5C#,
						(virtualBufferSelectRpdo0 & 
						virtualBufferSelectTpdo) 		when 16#60#,
						(virtualBufferSelectRpdo2 & 
						virtualBufferSelectRpdo1) 		when 16#64#,
						(x"0000" & apIrqControlIn) 		when 16#68#,
						--RESERVED						when 16#6C#,
						--RESERVED 						when 16#70#,
						(ledCnfgIn & ledCtrlIn) 		when 16#74#,
						(others => '0') 				when others;
	
	--ignored values
	asyncIrqCtrlOut(14 downto 1) <= (others => '0');
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
						--STORED IN DPR
					when 16#30# =>
						--STORED IN DPR
					
					when 16#34# =>
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
						--RO
					when 16#54# =>
						--RO
					when 16#58# =>
						--RESERVED
					when 16#5C# =>
						--RESERVED
					when 16#60# =>
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
					when 16#64# =>
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
					when 16#68# =>
						if be(0) = '1' then
							apIrqControlOut(7 downto 0) <= din(7 downto 0);
						end if;
						if be(1) = '1' then
							apIrqControlOut(15 downto 8) <= din(15 downto 8);
						end if;
					when 16#6C# =>
						--RESERVED
					when 16#70# =>
						--RESERVED
					when 16#74# =>
						if be(0) = '1' then
							ledCtrlOut(7 downto 0) <= din(7 downto 0);
						end if;
						if be(1) = '1' then
							ledCtrlOut(15 downto 8) <= din(15 downto 8);
						end if;
						if be(2) = '1' then
							ledCnfgOut(7 downto 0) <= din(23 downto 16);
						end if;
						if be(3) = '1' then
							ledCnfgOut(15 downto 8) <= din(31 downto 24);
						end if;
					when others =>
				end case;
			end if;
		end if;
	end process;
		
end architecture rtl;