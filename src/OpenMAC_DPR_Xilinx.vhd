------------------------------------------------------------------------------------------------------------------------
-- OpenMAC - DPR for Xilinx FPGA
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
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------      
--  2009-08-07  V0.01        Converted to official version.
------------------------------------------------------------------------------------------------------------------------
--
LIBRARY ieee;          
USE ieee.std_logic_1164.all;  
USE ieee.std_logic_arith.all;  
USE ieee.std_logic_unsigned.all;

entity DPR_v is 
 port	(	Clk_A,		Clk_B		: in  std_logic			:= '0';
			En_A,		En_B		: in  std_logic			:= '0';
			We_A,		We_B		: in  std_logic			:= '0';
			Addr_A,		Addr_B		: in  std_logic_vector;
			Be_A,		Be_B		: in  std_logic_vector;
			Di_A ,		Di_B		: in  std_logic_vector;
			Do_A,		Do_B		: out std_logic_vector
  );

end DPR_v;

architecture struct of DPR_v is

	constant	Size	:	integer	:=	(2**(Addr_A'high ));       			
	constant	Byts	:	integer	:=	(Di_A'high + 1 ) / 8;                	
	constant	Bits	:	integer :=	8 + ((Di_A'high + 1 ) Mod 8) / Byts;	

	type tReg is array (Size-1 downto 0) of std_logic_vector ( Di_A'range ) ;
	shared variable	Reg0			: tReg := ( others => (Di_A'range => '0'));

	signal	Wd_A, Wd_B				: std_logic_vector (Di_A'range);
	signal	Wr_A, Wr_B				: std_logic_vector (Byts-1 downto  0);
	signal	Ws_A, Ws_B				: std_logic;

	signal	 iWe_A,   iWe_B		:  std_logic;
	signal	 iEn_A,   iEn_B		:  std_logic;
	signal	 iBe_A,   iBe_B		:  std_logic_vector(Be_A'range);
	signal	 iAddr_A			:  std_logic_vector(Addr_A'range);
	signal	 iAddr_B			:  std_logic_vector(Addr_B'range);
	signal	 iDi_A				:  std_logic_vector(Di_A'range);
	signal	 iDi_B				:  std_logic_vector(Di_B'range);
	
begin

	iEn_A    <= En_A   	after 1 nS;		iEn_B    <= En_B   	after 1 nS;
	iBe_A    <= Be_A   	after 1 nS;		iBe_B    <= Be_B   	after 1 nS;
	iWe_A    <= We_A 	after 1 nS;  	iWe_B    <= We_B   	after 1 nS;
	iAddr_A  <= Addr_A 	after 1 nS;		iAddr_B  <= Addr_B 	after 1 nS;
	iDi_A    <= Di_A   	after 1 nS;		iDi_B    <= Di_B   	after 1 nS;

gWeA:	for i in 0 to Byts-1 generate
	Wr_A(i) <= iWe_A and iBe_A(i);
end generate;

process ( Clk_A, Wr_A, iDi_A )
begin
	Ws_A <= '0';
	for i in 0 to Byts-1	loop
		if (Wr_A(i) = '1')	then	Wd_A(((i+1)*Bits)-1 downto i*Bits) <= iDi_A(((i+1)*Bits)-1 downto i*Bits);
									Ws_A <= '1';
		else						Wd_A(((i+1)*Bits)-1 downto i*Bits) <= Reg0(conv_integer(iAddr_A))(((i+1)*Bits)-1 downto i*Bits);
		end if;
	end loop;
end process;

process (Clk_A)
begin
	if (Clk_A'event and Clk_A = '1') then
		if (iEn_A = '1') then
			Do_A <= Wd_A after 1 nS;							--	Write First									
--			Do_A <= Reg0(conv_integer(iAddr_A)) after 1 nS;		--	Read first
		end if;
		if (Ws_A = '1') then
			Reg0(conv_integer(iAddr_A)) := Wd_A;
		end if;
	end if;
end process;

gWeB:	for i in 0 to Byts-1 generate
	Wr_B(i) <= iWe_B and iBe_B(i);
end generate;

process ( Clk_B, Wr_B, iDi_B )
begin
	Ws_B <= '0';
	for i in 0 to Byts-1	loop
		if (Wr_B(i) = '1')	then	Wd_B(((i+1)*Bits)-1 downto i*Bits) <= iDi_B(((i+1)*Bits)-1 downto i*Bits);
									Ws_B <= '1';
		else						Wd_B(((i+1)*Bits)-1 downto i*Bits) <= Reg0(conv_integer(iAddr_B))(((i+1)*Bits)-1 downto i*Bits);
		end if;
	end loop;
end process;

process (Clk_B)
begin
	if (Clk_B'event and Clk_B = '1') then
		if (iEn_B = '1') then
			Do_B <= Wd_B;										--	Write First							
--			Do_B <= Reg0(conv_integer(iAddr_B)) after 1 nS;		--	Read first  
		end if;
		if (Ws_B = '1') then
			Reg0(conv_integer(iAddr_B)) := Wd_B;
		end if;
	end if;
end process;

end struct;

LIBRARY ieee;                   
USE ieee.std_logic_1164.all;    
USE ieee.std_logic_arith.all;   
USE ieee.std_logic_unsigned.all;

entity Dpr_16_16 is
  generic(Simulate	:  in	boolean);
  port (
	 ClkA,  ClkB		:  in  std_logic;
	 WeA,   WeB			:  in  std_logic := '0';
	 EnA,   EnB			:  in  std_logic := '1';
	 BeA				:  in  std_logic_vector( 1 downto 0) := "11";
	 AddrA				:  in  std_logic_vector;
	 DiA				:  in  std_logic_vector(15 downto 0) := (others => '0');
	 DoA				:  out std_logic_vector(15 downto 0); 
	 BeB				:  in  std_logic_vector( 1 downto 0) := "11";
	 AddrB 				:  in  std_logic_vector;
	 DiB				:  in  std_logic_vector(15 downto 0) := (others => '0');
	 DoB				:  out std_logic_vector(15 downto 0) 
	 );
end Dpr_16_16;

architecture struct of Dpr_16_16 is
begin

cDpr_16_16:		entity work.DPR_v
	port map (	Clk_A	=>	ClkA,	Clk_B	=>	ClkB,		
				We_A	=>	WeA	,	We_B	=>	WeB,		
				En_A	=>	EnA,	En_B	=>	EnB,		
				Be_A	=>	BeA,	Be_B	=>	BeB,		
				Addr_A	=>	AddrA,	Addr_B	=>	AddrB,		
				Di_A 	=>	DiA,	Di_B	=>	DiB,		
				Do_A	=>	DoA,	Do_B	=>	DoB	
  );

end struct;

LIBRARY ieee;                   
USE ieee.std_logic_1164.all;    
USE ieee.std_logic_arith.all;   
USE ieee.std_logic_unsigned.all;

entity Dpr_16_32 is
  generic(Simulate	:  in	boolean);
  port (
	 ClkA,  ClkB		:  in  std_logic;
	 WeA				:  in  std_logic := '0';
	 EnA,   EnB			:  in  std_logic := '1';
	 AddrA				:  in  std_logic_vector;
	 DiA				:  in  std_logic_vector (15 downto 0) := (others => '0');
	 BeA				:  in  std_logic_vector ( 1 downto 0) := "11";
	 AddrB 				:  in  std_logic_vector;								
	 DoB				:  out  std_logic_vector(31 downto 0) 
	 );
end Dpr_16_32;

architecture struct of Dpr_16_32 is
	constant gnd			: std_logic := '0';
  	signal	Be_A			: std_logic_vector ( 3 downto 0);
	signal	Addr_A			: std_logic_vector (AddrA'high downto 1);
	signal	Di_A			: std_logic_vector (31 downto 0);
	signal	Do_A			: std_logic_vector (31 downto 0);	
  	signal	BeB				: std_logic_vector ( 3 downto 0);	
	signal	Di_B			: std_logic_vector (31 downto 0);	

begin

	Be_A(3) <= BeA(1) and	  AddrA(0);
	Be_A(2) <= BeA(0) and	  AddrA(0);
	Be_A(1) <= BeA(1) and not AddrA(0);
	Be_A(0) <= BeA(0) and not AddrA(0);
	Addr_A  <= AddrA(AddrA'high downto 1);
	Di_A    <= DiA & DiA;
	BeB     <= "1111";
	
cDpr_16_32:		entity work.DPR_v
	port map (	Clk_A	=>	ClkA,		Clk_B	=>	ClkB,		
				We_A	=>	WeA	,		We_B	=>	gnd,		
				En_A	=>	EnA,		En_B	=>	EnB,		
				Be_A	=>	Be_A,		Be_B	=>	BeB,		
				Addr_A	=>	Addr_A,		Addr_B	=>	AddrB,		 
				Di_A 	=>	Di_A,		Di_B	=>	Di_B,		
				Do_A	=>	Do_A,		Do_B	=>	DoB	
  );

end struct;




