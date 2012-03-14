-------------------------------------------------------------------------------
-- Entity : Master Test Device for AXI
-------------------------------------------------------------------------------
--
--    (c) B&R, 2012
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
-- Design unit header --
--
-- This is the toplevel file for using the Master Test Device IP-Core
-- with Xilinx AXI.
--
-------------------------------------------------------------------------------
--
-- 2012-02-13   V0.01   zelenkaj    First version
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;

library axi_lite_ipif_v1_01_a;
use axi_lite_ipif_v1_01_a.axi_lite_ipif;

library axi_master_burst_v1_00_a;
use axi_master_burst_v1_00_a.axi_master_burst;

-- other libraries declarations
library AXI_LITE_IPIF_V1_01_A;
library AXI_MASTER_BURST_V1_00_A;

entity axi_master_test_device is
  generic(
       --master axi
       C_M_AXI_ADDR_WIDTH : integer := 32;
       C_M_AXI_DATA_WIDTH : integer := 32;
       C_M_AXI_NATIVE_DWIDTH : integer := 32;
       C_M_AXI_LENGTH_WIDTH : integer := 12;
       C_M_AXI_MAX_BURST_LEN : integer := 16;
       --slave axi
       C_S_AXI_RNG0_BASEADDR : std_logic_vector(31 downto 0) := (others => '1');
       C_S_AXI_RNG0_HIGHADDR : std_logic_vector(31 downto 0) := (others => '0');
       C_S_AXI_DATA_WIDTH : integer := 32;
       C_S_AXI_ADDR_WIDTH : integer := 32;
       C_S_AXI_USE_WSTRB : integer := 1;
       C_S_AXI_DPHASE_TIMEOUT : integer := 0
  );
  port(
       S_AXI_ACLK : in std_logic;
       S_AXI_ARESETN : in std_logic;
       S_AXI_ARVALID : in std_logic;
       S_AXI_AWVALID : in std_logic;
       S_AXI_BREADY : in std_logic;
       S_AXI_RREADY : in std_logic;
       S_AXI_WVALID : in std_logic;
       m_axi_aclk : in std_logic;
       m_axi_aresetn : in std_logic;
       m_axi_arready : in std_logic;
       m_axi_awready : in std_logic;
       m_axi_bvalid : in std_logic;
       m_axi_rlast : in std_logic;
       m_axi_rvalid : in std_logic;
       m_axi_wready : in std_logic;
       S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
       m_axi_bresp : in std_logic_vector(1 downto 0);
       m_axi_rdata : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
       m_axi_rresp : in std_logic_vector(1 downto 0);
       S_AXI_ARREADY : out std_logic;
       S_AXI_AWREADY : out std_logic;
       S_AXI_BVALID : out std_logic;
       S_AXI_RVALID : out std_logic;
       S_AXI_WREADY : out std_logic;
       m_axi_arvalid : out std_logic;
       m_axi_awvalid : out std_logic;
       m_axi_bready : out std_logic;
       m_axi_rready : out std_logic;
       m_axi_wlast : out std_logic;
       m_axi_wvalid : out std_logic;
       md_error : out std_logic;
       S_AXI_BRESP : out std_logic_vector(1 downto 0);
       S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_RRESP : out std_logic_vector(1 downto 0);
       m_axi_araddr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
       m_axi_arburst : out std_logic_vector(1 downto 0);
       m_axi_arcache : out std_logic_vector(3 downto 0);
       m_axi_arlen : out std_logic_vector(7 downto 0);
       m_axi_arprot : out std_logic_vector(2 downto 0);
       m_axi_arsize : out std_logic_vector(2 downto 0);
       m_axi_awaddr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
       m_axi_awburst : out std_logic_vector(1 downto 0);
       m_axi_awcache : out std_logic_vector(3 downto 0);
       m_axi_awlen : out std_logic_vector(7 downto 0);
       m_axi_awprot : out std_logic_vector(2 downto 0);
       m_axi_awsize : out std_logic_vector(2 downto 0);
       m_axi_wdata : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
       m_axi_wstrb : out std_logic_vector((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
       test_port : out std_logic_vector(127 downto 0) := (others => '0')
  );
-- Entity declarations --
-- Click here to add additional declarations --
attribute SIGIS : string;

end axi_master_test_device;

architecture rtl of axi_master_test_device is

---- Component declarations -----

component ipif_master_handler
  generic(
       C_MAC_DMA_IPIF_AWIDTH : integer := 32;
       C_MAC_DMA_IPIF_NATIVE_DWIDTH : integer := 32;
       dma_highadr_g : integer := 31;
       gen_rx_fifo_g : boolean := true;
       gen_tx_fifo_g : boolean := true;
       m_burstcount_width_g : integer := 4
  );
  port (
       Bus2MAC_DMA_MstRd_d : in std_logic_vector(C_MAC_DMA_IPIF_NATIVE_DWIDTH-1 downto 0);
       Bus2MAC_DMA_MstRd_eof_n : in std_logic := '1';
       Bus2MAC_DMA_MstRd_rem : in std_logic_vector(C_MAC_DMA_IPIF_NATIVE_DWIDTH/8-1 downto 0);
       Bus2MAC_DMA_MstRd_sof_n : in std_logic := '1';
       Bus2MAC_DMA_MstRd_src_dsc_n : in std_logic := '1';
       Bus2MAC_DMA_MstRd_src_rdy_n : in std_logic := '1';
       Bus2MAC_DMA_MstWr_dst_dsc_n : in std_logic := '1';
       Bus2MAC_DMA_MstWr_dst_rdy_n : in std_logic := '1';
       Bus2MAC_DMA_Mst_CmdAck : in std_logic := '0';
       Bus2MAC_DMA_Mst_Cmd_Timeout : in std_logic := '0';
       Bus2MAC_DMA_Mst_Cmplt : in std_logic := '0';
       Bus2MAC_DMA_Mst_Error : in std_logic := '0';
       Bus2MAC_DMA_Mst_Rearbitrate : in std_logic := '0';
       MAC_DMA_CLK : in std_logic;
       MAC_DMA_Rst : in std_logic;
       m_address : in std_logic_vector(dma_highadr_g downto 0);
       m_burstcount : in std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_burstcounter : in std_logic_vector(m_burstcount_width_g-1 downto 0);
       m_byteenable : in std_logic_vector(3 downto 0);
       m_read : in std_logic := '0';
       m_write : in std_logic := '0';
       m_writedata : in std_logic_vector(31 downto 0);
       MAC_DMA2Bus_MstRd_Req : out std_logic := '0';
       MAC_DMA2Bus_MstRd_dst_dsc_n : out std_logic := '1';
       MAC_DMA2Bus_MstRd_dst_rdy_n : out std_logic := '1';
       MAC_DMA2Bus_MstWr_Req : out std_logic := '0';
       MAC_DMA2Bus_MstWr_d : out std_logic_vector(C_MAC_DMA_IPIF_NATIVE_DWIDTH-1 downto 0);
       MAC_DMA2Bus_MstWr_eof_n : out std_logic := '1';
       MAC_DMA2Bus_MstWr_rem : out std_logic_vector(C_MAC_DMA_IPIF_NATIVE_DWIDTH/8-1 downto 0);
       MAC_DMA2Bus_MstWr_sof_n : out std_logic := '1';
       MAC_DMA2Bus_MstWr_src_dsc_n : out std_logic := '1';
       MAC_DMA2Bus_MstWr_src_rdy_n : out std_logic := '1';
       MAC_DMA2Bus_Mst_Addr : out std_logic_vector(C_MAC_DMA_IPIF_AWIDTH-1 downto 0);
       MAC_DMA2Bus_Mst_BE : out std_logic_vector(C_MAC_DMA_IPIF_NATIVE_DWIDTH/8-1 downto 0);
       MAC_DMA2Bus_Mst_Length : out std_logic_vector(11 downto 0);
       MAC_DMA2Bus_Mst_Lock : out std_logic := '0';
       MAC_DMA2Bus_Mst_Reset : out std_logic := '0';
       MAC_DMA2Bus_Mst_Type : out std_logic := '0';
       m_clk : out std_logic;
       m_readdata : out std_logic_vector(31 downto 0);
       m_readdatavalid : out std_logic := '0';
       m_waitrequest : out std_logic := '1'
  );
end component;
component masterTestDevice
  generic(
       gMasterAddrWidth : natural := 32;
       gMasterBurstCountWidth : natural := 10;
       gMasterDataWidth : natural := 32;
       gSlaveAddrWidth : natural := 16;
       gSlaveDataWidth : natural := 32
  );
  port (
       iClk : in std_logic;
       iMasterReaddata : in std_logic_vector(gMasterDataWidth-1 downto 0);
       iMasterReaddatavalid : in std_logic;
       iMasterWaitrequest : in std_logic;
       iRst : in std_logic;
       iSlaveAddress : in std_logic_vector(gSlaveAddrWidth-1 downto 0);
       iSlaveChipselect : in std_logic;
       iSlaveRead : in std_logic;
       iSlaveWrite : in std_logic;
       iSlaveWritedata : in std_logic_vector(gSlaveDataWidth-1 downto 0);
       oMasterAddress : out std_logic_vector(gMasterAddrWidth-1 downto 0);
       oMasterBurstCounter : out std_logic_vector(gMasterBurstCountWidth-1 downto 0);
       oMasterBurstcount : out std_logic_vector(gMasterBurstCountWidth-1 downto 0);
       oMasterRead : out std_logic;
       oMasterWrite : out std_logic;
       oMasterWritedata : out std_logic_vector(gMasterDataWidth-1 downto 0);
       oSlaveReaddata : out std_logic_vector(gSlaveDataWidth-1 downto 0);
       oSlaveWaitrequest : out std_logic
  );
end component;
component axi_lite_ipif
  generic(
       C_ARD_ADDR_RANGE_ARRAY : slv64_array_type := (X"0000_0000_7000_0000",X"0000_0000_7000_00FF",X"0000_0000_7000_0100",X"0000_0000_7000_01FF");
       C_ARD_NUM_CE_ARRAY : integer_array_type := (4,12);
       C_DPHASE_TIMEOUT : integer range 0 to 512 := 8;
       C_FAMILY : string := "virtex6";
       C_S_AXI_ADDR_WIDTH : integer := 32;
       C_S_AXI_DATA_WIDTH : integer range 32 to 32 := 32;
       C_S_AXI_MIN_SIZE : std_logic_vector(31 downto 0) := X"000001FF";
       C_USE_WSTRB : integer := 0
  );
  port (
       IP2Bus_Data : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       IP2Bus_Error : in std_logic;
       IP2Bus_RdAck : in std_logic;
       IP2Bus_WrAck : in std_logic;
       S_AXI_ACLK : in std_logic;
       S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_ARESETN : in std_logic;
       S_AXI_ARVALID : in std_logic;
       S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
       S_AXI_AWVALID : in std_logic;
       S_AXI_BREADY : in std_logic;
       S_AXI_RREADY : in std_logic;
       S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
       S_AXI_WVALID : in std_logic;
       Bus2IP_Addr : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
       Bus2IP_BE : out std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
       Bus2IP_CS : out std_logic_vector((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2-1 downto 0);
       Bus2IP_Clk : out std_logic;
       Bus2IP_Data : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       Bus2IP_RNW : out std_logic;
       Bus2IP_RdCE : out std_logic_vector(calc_num_ce(C_ARD_NUM_CE_ARRAY)-1 downto 0);
       Bus2IP_Resetn : out std_logic;
       Bus2IP_WrCE : out std_logic_vector(calc_num_ce(C_ARD_NUM_CE_ARRAY)-1 downto 0);
       S_AXI_ARREADY : out std_logic;
       S_AXI_AWREADY : out std_logic;
       S_AXI_BRESP : out std_logic_vector(1 downto 0);
       S_AXI_BVALID : out std_logic;
       S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
       S_AXI_RRESP : out std_logic_vector(1 downto 0);
       S_AXI_RVALID : out std_logic;
       S_AXI_WREADY : out std_logic
  );
end component;
component axi_master_burst
  generic(
       C_ADDR_PIPE_DEPTH : integer range 1 to 14 := 1;
       C_FAMILY : string := "virtex6";
       C_LENGTH_WIDTH : integer range 12 to 20 := 12;
       C_MAX_BURST_LEN : integer range 16 to 256 := 16;
       C_M_AXI_ADDR_WIDTH : integer range 32 to 32 := 32;
       C_M_AXI_DATA_WIDTH : integer range 32 to 256 := 32;
       C_NATIVE_DATA_WIDTH : integer range 32 to 128 := 32
  );
  port (
       ip2bus_mst_addr : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
       ip2bus_mst_be : in std_logic_vector((C_NATIVE_DATA_WIDTH/8)-1 downto 0);
       ip2bus_mst_length : in std_logic_vector(C_LENGTH_WIDTH-1 downto 0);
       ip2bus_mst_lock : in std_logic;
       ip2bus_mst_reset : in std_logic;
       ip2bus_mst_type : in std_logic;
       ip2bus_mstrd_dst_dsc_n : in std_logic;
       ip2bus_mstrd_dst_rdy_n : in std_logic;
       ip2bus_mstrd_req : in std_logic;
       ip2bus_mstwr_d : in std_logic_vector(C_NATIVE_DATA_WIDTH-1 downto 0);
       ip2bus_mstwr_eof_n : in std_logic;
       ip2bus_mstwr_rem : in std_logic_vector((C_NATIVE_DATA_WIDTH/8)-1 downto 0);
       ip2bus_mstwr_req : in std_logic;
       ip2bus_mstwr_sof_n : in std_logic;
       ip2bus_mstwr_src_dsc_n : in std_logic;
       ip2bus_mstwr_src_rdy_n : in std_logic;
       m_axi_aclk : in std_logic;
       m_axi_aresetn : in std_logic;
       m_axi_arready : in std_logic;
       m_axi_awready : in std_logic;
       m_axi_bresp : in std_logic_vector(1 downto 0);
       m_axi_bvalid : in std_logic;
       m_axi_rdata : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
       m_axi_rlast : in std_logic;
       m_axi_rresp : in std_logic_vector(1 downto 0);
       m_axi_rvalid : in std_logic;
       m_axi_wready : in std_logic;
       bus2ip_mst_cmd_timeout : out std_logic;
       bus2ip_mst_cmdack : out std_logic;
       bus2ip_mst_cmplt : out std_logic;
       bus2ip_mst_error : out std_logic;
       bus2ip_mst_rearbitrate : out std_logic;
       bus2ip_mstrd_d : out std_logic_vector(C_NATIVE_DATA_WIDTH-1 downto 0);
       bus2ip_mstrd_eof_n : out std_logic;
       bus2ip_mstrd_rem : out std_logic_vector((C_NATIVE_DATA_WIDTH/8)-1 downto 0);
       bus2ip_mstrd_sof_n : out std_logic;
       bus2ip_mstrd_src_dsc_n : out std_logic;
       bus2ip_mstrd_src_rdy_n : out std_logic;
       bus2ip_mstwr_dst_dsc_n : out std_logic;
       bus2ip_mstwr_dst_rdy_n : out std_logic;
       m_axi_araddr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
       m_axi_arburst : out std_logic_vector(1 downto 0);
       m_axi_arcache : out std_logic_vector(3 downto 0);
       m_axi_arlen : out std_logic_vector(7 downto 0);
       m_axi_arprot : out std_logic_vector(2 downto 0);
       m_axi_arsize : out std_logic_vector(2 downto 0);
       m_axi_arvalid : out std_logic;
       m_axi_awaddr : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
       m_axi_awburst : out std_logic_vector(1 downto 0);
       m_axi_awcache : out std_logic_vector(3 downto 0);
       m_axi_awlen : out std_logic_vector(7 downto 0);
       m_axi_awprot : out std_logic_vector(2 downto 0);
       m_axi_awsize : out std_logic_vector(2 downto 0);
       m_axi_awvalid : out std_logic;
       m_axi_bready : out std_logic;
       m_axi_rready : out std_logic;
       m_axi_wdata : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
       m_axi_wlast : out std_logic;
       m_axi_wstrb : out std_logic_vector((C_M_AXI_DATA_WIDTH/8)-1 downto 0);
       m_axi_wvalid : out std_logic;
       md_error : out std_logic
  );
end component;

---- Architecture declarations -----
constant C_FAMILY : string := "spartan6";
constant C_ADDR_PAD_ZERO : std_logic_vector(31 downto 0) := (others => '0');
-- S_AXI
constant C_S_AXI_BASE : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_S_AXI_RNG0_BASEADDR;
constant C_S_AXI_HIGH : std_logic_vector(63 downto 0) := C_ADDR_PAD_ZERO & C_S_AXI_RNG0_HIGHADDR;
--constant C_S_AXI_MINSIZE : std_logic_vector(31 downto 0) := C_S_AXI_RNG0_HIGHADDR;


----     Constants     -----
constant VCC_CONSTANT   : std_logic := '1';
constant GND_CONSTANT   : std_logic := '0';

---- Signal declarations used on the diagram ----

signal Bus2IP_RNW : std_logic;
signal Bus2IP_WNR : std_logic;
signal Bus2MAC_DMA_MstRd_eof_n : std_logic;
signal Bus2MAC_DMA_MstRd_sof_n : std_logic;
signal Bus2MAC_DMA_MstRd_src_dsc_n : std_logic;
signal Bus2MAC_DMA_MstRd_src_rdy_n : std_logic;
signal Bus2MAC_DMA_MstWr_dst_dsc_n : std_logic;
signal Bus2MAC_DMA_MstWr_dst_rdy_n : std_logic;
signal Bus2MAC_DMA_Mst_CmdAck : std_logic;
signal Bus2MAC_DMA_Mst_Cmd_Timeout : std_logic;
signal Bus2MAC_DMA_Mst_Cmplt : std_logic;
signal Bus2MAC_DMA_Mst_Error : std_logic;
signal Bus2MAC_DMA_Mst_Rearbitrate : std_logic;
signal GND : std_logic;
signal IP2Bus_Error : std_logic;
signal IP2Bus_RdAck : std_logic;
signal IP2Bus_WrAck : std_logic;
signal MAC_DMA2Bus_MstRd_dst_dsc_n : std_logic;
signal MAC_DMA2Bus_MstRd_dst_rdy_n : std_logic;
signal MAC_DMA2Bus_MstRd_Req : std_logic;
signal MAC_DMA2Bus_MstWr_eof_n : std_logic;
signal MAC_DMA2Bus_MstWr_Req : std_logic;
signal MAC_DMA2Bus_MstWr_sof_n : std_logic;
signal MAC_DMA2Bus_MstWr_src_dsc_n : std_logic;
signal MAC_DMA2Bus_MstWr_src_rdy_n : std_logic;
signal MAC_DMA2Bus_Mst_Lock : std_logic;
signal MAC_DMA2Bus_Mst_Reset : std_logic;
signal MAC_DMA2Bus_Mst_Type : std_logic;
signal m_axi_areset : std_logic;
signal m_read : std_logic;
signal m_readdatavalid : std_logic;
signal m_waitrequest : std_logic;
signal m_write : std_logic;
signal slaveWaitrequest : std_logic;
signal VCC : std_logic;
signal Bus2IP_Addr : std_logic_vector (C_S_AXI_ADDR_WIDTH-1 downto 0);
signal Bus2IP_CS : std_logic_vector (0 downto 0);
signal Bus2IP_Data : std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
signal Bus2MAC_DMA_MstRd_d : std_logic_vector (C_M_AXI_NATIVE_DWIDTH-1 downto 0);
signal Bus2MAC_DMA_MstRd_rem : std_logic_vector (C_M_AXI_NATIVE_DWIDTH/8-1 downto 0);
signal IP2Bus_Data : std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0);
signal MAC_DMA2Bus_MstWr_d : std_logic_vector (C_M_AXI_NATIVE_DWIDTH-1 downto 0);
signal MAC_DMA2Bus_MstWr_rem : std_logic_vector (C_M_AXI_NATIVE_DWIDTH/8-1 downto 0);
signal MAC_DMA2Bus_Mst_Addr : std_logic_vector (C_M_AXI_ADDR_WIDTH-1 downto 0);
signal MAC_DMA2Bus_Mst_BE : std_logic_vector (C_M_AXI_NATIVE_DWIDTH/8-1 downto 0);
signal MAC_DMA2Bus_Mst_Length : std_logic_vector (C_M_AXI_LENGTH_WIDTH-1 downto 0);
signal m_address : std_logic_vector (C_M_AXI_ADDR_WIDTH-1 downto 0);
signal m_burstcount : std_logic_vector (C_M_AXI_LENGTH_WIDTH-2-1 downto 0);
signal m_burstcounter : std_logic_vector (C_M_AXI_LENGTH_WIDTH-2-1 downto 0);
signal m_byteenable : std_logic_vector (3 downto 0);
signal m_readdata : std_logic_vector (31 downto 0);
signal m_writedata : std_logic_vector (31 downto 0);
signal slaveAddress : std_logic_vector (C_S_AXI_ADDR_WIDTH-2-1 downto 0);

begin

---- User Signal Assignments ----
slaveAddress <= Bus2IP_Addr(C_S_AXI_ADDR_WIDTH-1 downto 2);
--test_port(127 downto 0)
test_port(127 downto 124) <= m_read & m_write & m_waitrequest & m_readdatavalid;
test_port(110 downto 108) <= Bus2IP_RNW & Bus2IP_CS(0) & slaveWaitrequest;

test_port(C_M_AXI_LENGTH_WIDTH-2-1+64 downto 64) <= m_burstcount; --95 .. 64
test_port(C_M_AXI_LENGTH_WIDTH-2-1+32 downto 32) <= m_burstcounter; --63 .. 32
test_port(C_M_AXI_ADDR_WIDTH-1+0 downto 0) <= m_address; --31 .. 0

----  Component instantiations  ----

AXI_MASTER : axi_master_burst
  generic map (
       C_ADDR_PIPE_DEPTH => 1,
       C_FAMILY => C_FAMILY,
       C_LENGTH_WIDTH => C_M_AXI_LENGTH_WIDTH,
       C_MAX_BURST_LEN => C_M_AXI_MAX_BURST_LEN,
       C_M_AXI_ADDR_WIDTH => C_M_AXI_ADDR_WIDTH,
       C_M_AXI_DATA_WIDTH => C_M_AXI_DATA_WIDTH,
       C_NATIVE_DATA_WIDTH => C_M_AXI_NATIVE_DWIDTH
  )
  port map(
       bus2ip_mst_cmd_timeout => Bus2MAC_DMA_Mst_Cmd_Timeout,
       bus2ip_mst_cmdack => Bus2MAC_DMA_Mst_CmdAck,
       bus2ip_mst_cmplt => Bus2MAC_DMA_Mst_Cmplt,
       bus2ip_mst_error => Bus2MAC_DMA_Mst_Error,
       bus2ip_mst_rearbitrate => Bus2MAC_DMA_Mst_Rearbitrate,
       bus2ip_mstrd_d => Bus2MAC_DMA_MstRd_d( C_M_AXI_NATIVE_DWIDTH-1 downto 0 ),
       bus2ip_mstrd_eof_n => Bus2MAC_DMA_MstRd_eof_n,
       bus2ip_mstrd_rem => Bus2MAC_DMA_MstRd_rem( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       bus2ip_mstrd_sof_n => Bus2MAC_DMA_MstRd_sof_n,
       bus2ip_mstrd_src_dsc_n => Bus2MAC_DMA_MstRd_src_dsc_n,
       bus2ip_mstrd_src_rdy_n => Bus2MAC_DMA_MstRd_src_rdy_n,
       bus2ip_mstwr_dst_dsc_n => Bus2MAC_DMA_MstWr_dst_dsc_n,
       bus2ip_mstwr_dst_rdy_n => Bus2MAC_DMA_MstWr_dst_rdy_n,
       ip2bus_mst_addr => MAC_DMA2Bus_Mst_Addr( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       ip2bus_mst_be => MAC_DMA2Bus_Mst_BE( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       ip2bus_mst_length => MAC_DMA2Bus_Mst_Length( C_M_AXI_LENGTH_WIDTH-1 downto 0 ),
       ip2bus_mst_lock => MAC_DMA2Bus_Mst_Lock,
       ip2bus_mst_reset => MAC_DMA2Bus_Mst_Reset,
       ip2bus_mst_type => MAC_DMA2Bus_Mst_Type,
       ip2bus_mstrd_dst_dsc_n => MAC_DMA2Bus_MstRd_dst_dsc_n,
       ip2bus_mstrd_dst_rdy_n => MAC_DMA2Bus_MstRd_dst_rdy_n,
       ip2bus_mstrd_req => MAC_DMA2Bus_MstRd_Req,
       ip2bus_mstwr_d => MAC_DMA2Bus_MstWr_d( C_M_AXI_NATIVE_DWIDTH-1 downto 0 ),
       ip2bus_mstwr_eof_n => MAC_DMA2Bus_MstWr_eof_n,
       ip2bus_mstwr_rem => MAC_DMA2Bus_MstWr_rem( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       ip2bus_mstwr_req => MAC_DMA2Bus_MstWr_Req,
       ip2bus_mstwr_sof_n => MAC_DMA2Bus_MstWr_sof_n,
       ip2bus_mstwr_src_dsc_n => MAC_DMA2Bus_MstWr_src_dsc_n,
       ip2bus_mstwr_src_rdy_n => MAC_DMA2Bus_MstWr_src_rdy_n,
       m_axi_aclk => m_axi_aclk,
       m_axi_araddr => m_axi_araddr( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       m_axi_arburst => m_axi_arburst,
       m_axi_arcache => m_axi_arcache,
       m_axi_aresetn => m_axi_aresetn,
       m_axi_arlen => m_axi_arlen,
       m_axi_arprot => m_axi_arprot,
       m_axi_arready => m_axi_arready,
       m_axi_arsize => m_axi_arsize,
       m_axi_arvalid => m_axi_arvalid,
       m_axi_awaddr => m_axi_awaddr( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       m_axi_awburst => m_axi_awburst,
       m_axi_awcache => m_axi_awcache,
       m_axi_awlen => m_axi_awlen,
       m_axi_awprot => m_axi_awprot,
       m_axi_awready => m_axi_awready,
       m_axi_awsize => m_axi_awsize,
       m_axi_awvalid => m_axi_awvalid,
       m_axi_bready => m_axi_bready,
       m_axi_bresp => m_axi_bresp,
       m_axi_bvalid => m_axi_bvalid,
       m_axi_rdata => m_axi_rdata( C_M_AXI_DATA_WIDTH-1 downto 0 ),
       m_axi_rlast => m_axi_rlast,
       m_axi_rready => m_axi_rready,
       m_axi_rresp => m_axi_rresp,
       m_axi_rvalid => m_axi_rvalid,
       m_axi_wdata => m_axi_wdata( C_M_AXI_DATA_WIDTH-1 downto 0 ),
       m_axi_wlast => m_axi_wlast,
       m_axi_wready => m_axi_wready,
       m_axi_wstrb => m_axi_wstrb( (C_M_AXI_DATA_WIDTH/8)-1 downto 0 ),
       m_axi_wvalid => m_axi_wvalid,
       md_error => md_error
  );

AXI_SLAVE : axi_lite_ipif
  generic map (
       C_ARD_ADDR_RANGE_ARRAY => (C_S_AXI_BASE,C_S_AXI_HIGH),
       C_ARD_NUM_CE_ARRAY => (0=>1),
       C_DPHASE_TIMEOUT => C_S_AXI_DPHASE_TIMEOUT,
       C_FAMILY => C_FAMILY,
       C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
       C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
       C_S_AXI_MIN_SIZE => X"000001FF",
       C_USE_WSTRB => C_S_AXI_USE_WSTRB
  )
  port map(
       Bus2IP_Addr => Bus2IP_Addr( C_S_AXI_ADDR_WIDTH-1 downto 0 ),
       Bus2IP_BE => open,
       Bus2IP_CS => Bus2IP_CS( 0 downto 0 ),
       Bus2IP_Clk => open,
       Bus2IP_Data => Bus2IP_Data( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       Bus2IP_RNW => Bus2IP_RNW,
       Bus2IP_RdCE => open,
       Bus2IP_Resetn => open,
       Bus2IP_WrCE => open,
       IP2Bus_Data => IP2Bus_Data( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       IP2Bus_Error => IP2Bus_Error,
       IP2Bus_RdAck => IP2Bus_RdAck,
       IP2Bus_WrAck => IP2Bus_WrAck,
       S_AXI_ACLK => S_AXI_ACLK,
       S_AXI_ARADDR => S_AXI_ARADDR( C_S_AXI_ADDR_WIDTH-1 downto 0 ),
       S_AXI_ARESETN => S_AXI_ARESETN,
       S_AXI_ARREADY => S_AXI_ARREADY,
       S_AXI_ARVALID => S_AXI_ARVALID,
       S_AXI_AWADDR => S_AXI_AWADDR( C_S_AXI_ADDR_WIDTH-1 downto 0 ),
       S_AXI_AWREADY => S_AXI_AWREADY,
       S_AXI_AWVALID => S_AXI_AWVALID,
       S_AXI_BREADY => S_AXI_BREADY,
       S_AXI_BRESP => S_AXI_BRESP,
       S_AXI_BVALID => S_AXI_BVALID,
       S_AXI_RDATA => S_AXI_RDATA( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       S_AXI_RREADY => S_AXI_RREADY,
       S_AXI_RRESP => S_AXI_RRESP,
       S_AXI_RVALID => S_AXI_RVALID,
       S_AXI_WDATA => S_AXI_WDATA( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       S_AXI_WREADY => S_AXI_WREADY,
       S_AXI_WSTRB => S_AXI_WSTRB( (C_S_AXI_DATA_WIDTH/8)-1 downto 0 ),
       S_AXI_WVALID => S_AXI_WVALID
  );

IPIF_MASTER_WRAPPER : ipif_master_handler
  generic map (
       C_MAC_DMA_IPIF_AWIDTH => C_M_AXI_DATA_WIDTH,
       C_MAC_DMA_IPIF_NATIVE_DWIDTH => C_M_AXI_NATIVE_DWIDTH,
       dma_highadr_g => C_M_AXI_ADDR_WIDTH-1,
       gen_rx_fifo_g => true,
       gen_tx_fifo_g => true,
       m_burstcount_width_g => C_M_AXI_LENGTH_WIDTH-2
  )
  port map(
       Bus2MAC_DMA_MstRd_d => Bus2MAC_DMA_MstRd_d( C_M_AXI_NATIVE_DWIDTH-1 downto 0 ),
       Bus2MAC_DMA_MstRd_eof_n => Bus2MAC_DMA_MstRd_eof_n,
       Bus2MAC_DMA_MstRd_rem => Bus2MAC_DMA_MstRd_rem( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       Bus2MAC_DMA_MstRd_sof_n => Bus2MAC_DMA_MstRd_sof_n,
       Bus2MAC_DMA_MstRd_src_dsc_n => Bus2MAC_DMA_MstRd_src_dsc_n,
       Bus2MAC_DMA_MstRd_src_rdy_n => Bus2MAC_DMA_MstRd_src_rdy_n,
       Bus2MAC_DMA_MstWr_dst_dsc_n => Bus2MAC_DMA_MstWr_dst_dsc_n,
       Bus2MAC_DMA_MstWr_dst_rdy_n => Bus2MAC_DMA_MstWr_dst_rdy_n,
       Bus2MAC_DMA_Mst_CmdAck => Bus2MAC_DMA_Mst_CmdAck,
       Bus2MAC_DMA_Mst_Cmd_Timeout => Bus2MAC_DMA_Mst_Cmd_Timeout,
       Bus2MAC_DMA_Mst_Cmplt => Bus2MAC_DMA_Mst_Cmplt,
       Bus2MAC_DMA_Mst_Error => Bus2MAC_DMA_Mst_Error,
       Bus2MAC_DMA_Mst_Rearbitrate => Bus2MAC_DMA_Mst_Rearbitrate,
       MAC_DMA2Bus_MstRd_Req => MAC_DMA2Bus_MstRd_Req,
       MAC_DMA2Bus_MstRd_dst_dsc_n => MAC_DMA2Bus_MstRd_dst_dsc_n,
       MAC_DMA2Bus_MstRd_dst_rdy_n => MAC_DMA2Bus_MstRd_dst_rdy_n,
       MAC_DMA2Bus_MstWr_Req => MAC_DMA2Bus_MstWr_Req,
       MAC_DMA2Bus_MstWr_d => MAC_DMA2Bus_MstWr_d( C_M_AXI_NATIVE_DWIDTH-1 downto 0 ),
       MAC_DMA2Bus_MstWr_eof_n => MAC_DMA2Bus_MstWr_eof_n,
       MAC_DMA2Bus_MstWr_rem => MAC_DMA2Bus_MstWr_rem( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       MAC_DMA2Bus_MstWr_sof_n => MAC_DMA2Bus_MstWr_sof_n,
       MAC_DMA2Bus_MstWr_src_dsc_n => MAC_DMA2Bus_MstWr_src_dsc_n,
       MAC_DMA2Bus_MstWr_src_rdy_n => MAC_DMA2Bus_MstWr_src_rdy_n,
       MAC_DMA2Bus_Mst_Addr => MAC_DMA2Bus_Mst_Addr( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       MAC_DMA2Bus_Mst_BE => MAC_DMA2Bus_Mst_BE( C_M_AXI_NATIVE_DWIDTH/8-1 downto 0 ),
       MAC_DMA2Bus_Mst_Length => MAC_DMA2Bus_Mst_Length( C_M_AXI_LENGTH_WIDTH-1 downto 0 ),
       MAC_DMA2Bus_Mst_Lock => MAC_DMA2Bus_Mst_Lock,
       MAC_DMA2Bus_Mst_Reset => MAC_DMA2Bus_Mst_Reset,
       MAC_DMA2Bus_Mst_Type => MAC_DMA2Bus_Mst_Type,
       MAC_DMA_CLK => m_axi_aclk,
       MAC_DMA_Rst => m_axi_areset,
       m_address => m_address( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       m_burstcount => m_burstcount( C_M_AXI_LENGTH_WIDTH-2-1 downto 0 ),
       m_burstcounter => m_burstcounter( C_M_AXI_LENGTH_WIDTH-2-1 downto 0 ),
       m_byteenable => m_byteenable,
       m_clk => open,
       m_read => m_read,
       m_readdata => m_readdata,
       m_readdatavalid => m_readdatavalid,
       m_waitrequest => m_waitrequest,
       m_write => m_write,
       m_writedata => m_writedata
  );

THE_MASTER_TEST_DEVICE : masterTestDevice
  generic map (
       gMasterAddrWidth => C_M_AXI_DATA_WIDTH,
       gMasterBurstCountWidth => C_M_AXI_LENGTH_WIDTH-2,
       gMasterDataWidth => C_M_AXI_ADDR_WIDTH,
       gSlaveAddrWidth => C_S_AXI_ADDR_WIDTH-2,
       gSlaveDataWidth => C_S_AXI_DATA_WIDTH
  )
  port map(
       iClk => m_axi_aclk,
       iMasterReaddata => m_readdata( 31 downto 0 ),
       iMasterReaddatavalid => m_readdatavalid,
       iMasterWaitrequest => m_waitrequest,
       iRst => m_axi_areset,
       iSlaveAddress => slaveAddress( C_S_AXI_ADDR_WIDTH-2-1 downto 0 ),
       iSlaveChipselect => Bus2IP_CS(0),
       iSlaveRead => Bus2IP_RNW,
       iSlaveWrite => Bus2IP_WNR,
       iSlaveWritedata => Bus2IP_Data( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       oMasterAddress => m_address( C_M_AXI_ADDR_WIDTH-1 downto 0 ),
       oMasterBurstCounter => m_burstcounter( C_M_AXI_LENGTH_WIDTH-2-1 downto 0 ),
       oMasterBurstcount => m_burstcount( C_M_AXI_LENGTH_WIDTH-2-1 downto 0 ),
       oMasterRead => m_read,
       oMasterWrite => m_write,
       oMasterWritedata => m_writedata( 31 downto 0 ),
       oSlaveReaddata => IP2Bus_Data( C_S_AXI_DATA_WIDTH-1 downto 0 ),
       oSlaveWaitrequest => slaveWaitrequest
  );

m_axi_areset <= not(m_axi_aresetn);

Bus2IP_WNR <= not(Bus2IP_RNW);

IP2Bus_WrAck <= not(slaveWaitrequest);

IP2Bus_RdAck <= not(slaveWaitrequest);


---- Power , ground assignment ----

VCC <= VCC_CONSTANT;
GND <= GND_CONSTANT;
m_byteenable(3) <= VCC;
m_byteenable(2) <= VCC;
m_byteenable(1) <= VCC;
m_byteenable(0) <= VCC;
IP2Bus_Error <= GND;

end rtl;
