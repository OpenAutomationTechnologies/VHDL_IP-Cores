@echo off

copy active_hdl\src\*.vhd				..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\lib\*.vhd				..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\lib
copy active_hdl\src\openMAC_DMAmaster\*.vhd		..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAmaster
copy active_hdl\src\openMAC_DMAFifo_Xilinx\*.vhd	..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAFifo_Xilinx
copy active_hdl\compile\*.vhd				..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\xilinx_xps\*.mpd			..\release\xilinx_xps\plb_powerlink_v1_00_a\data
copy active_hdl\src\xilinx_xps\*.pao			..\release\xilinx_xps\plb_powerlink_v1_00_a\data
copy documentation\*.pdf				..\release\xilinx_xps\plb_powerlink_v1_00_a\doc

del ..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\*_TB.vhd
del ..\release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\*_Altera.vhd

@echo on