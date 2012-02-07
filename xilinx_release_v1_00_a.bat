@echo on

mkdir release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
mkdir release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\lib
mkdir release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAmaster
mkdir release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAFifo_Xilinx
mkdir release\xilinx_xps\plb_powerlink_v1_00_a\data
mkdir release\xilinx_xps\plb_powerlink_v1_00_a\doc


copy active_hdl\src\openMAC\src\*.vhd							release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\openMAC\src\openMAC_DMAmaster\*.vhd			release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAmaster
copy active_hdl\src\openMAC\src\openMAC_DMAFifo_Xilinx\*.vhd	release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAFifo_Xilinx
copy active_hdl\src\PDI\src\*.vhd							    release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\SPI\src\*.vhd							    release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\lib\src\*.vhd						        release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\lib
copy active_hdl\compile\*.vhd						            release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl
copy xilinx_xps\plb_*.mpd			                            release\xilinx_xps\plb_powerlink_v1_00_a\data
copy xilinx_xps\plb_*.mdd			                            release\xilinx_xps\plb_powerlink_v1_00_a\data
copy xilinx_xps\plb_*.pao			                            release\xilinx_xps\plb_powerlink_v1_00_a\data
copy xilinx_xps\plb_*.mui			                            release\xilinx_xps\plb_powerlink_v1_00_a\data
copy xilinx_xps\plb_*.tcl			                            release\xilinx_xps\plb_powerlink_v1_00_a\data
copy documentation\*_Generic.pdf					            release\xilinx_xps\plb_powerlink_v1_00_a\doc
copy documentation\*_Xilinx.pdf						            release\xilinx_xps\plb_powerlink_v1_00_a\doc
copy documentation\OpenMAC.pdf						            release\xilinx_xps\plb_powerlink_v1_00_a\doc

del release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\*_TB.vhd
del release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\*_Altera.vhd
del release\xilinx_xps\plb_powerlink_v1_00_a\hdl\vhdl\axi_*.vhd



mkdir release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl
mkdir release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\lib
mkdir release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAmaster
mkdir release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAFifo_Xilinx
mkdir release\xilinx_xps\axi_powerlink_v1_00_a\data
mkdir release\xilinx_xps\axi_powerlink_v1_00_a\doc


copy active_hdl\src\openMAC\src\*.vhd							release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\openMAC\src\openMAC_DMAmaster\*.vhd			release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAmaster
copy active_hdl\src\openMAC\src\openMAC_DMAFifo_Xilinx\*.vhd	release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\openMAC_DMAFifo_Xilinx
copy active_hdl\src\PDI\src\*.vhd							    release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\SPI\src\*.vhd							    release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl
copy active_hdl\src\lib\src\*.vhd						        release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\lib
copy active_hdl\compile\*.vhd						            release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl
copy xilinx_xps\axi_*.mpd			                            release\xilinx_xps\axi_powerlink_v1_00_a\data
copy xilinx_xps\axi_*.mdd			                            release\xilinx_xps\axi_powerlink_v1_00_a\data
copy xilinx_xps\axi_*.pao			                            release\xilinx_xps\axi_powerlink_v1_00_a\data
copy xilinx_xps\axi_*.mui			                            release\xilinx_xps\axi_powerlink_v1_00_a\data
copy xilinx_xps\axi_*.tcl			                            release\xilinx_xps\axi_powerlink_v1_00_a\data
copy documentation\*_Generic.pdf					            release\xilinx_xps\axi_powerlink_v1_00_a\doc
copy documentation\*_Xilinx.pdf						            release\xilinx_xps\axi_powerlink_v1_00_a\doc
copy documentation\OpenMAC.pdf						            release\xilinx_xps\axi_powerlink_v1_00_a\doc

del release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\*_TB.vhd
del release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\*_Altera.vhd
del release\xilinx_xps\axi_powerlink_v1_00_a\hdl\vhdl\plb_*.vhd

@echo on