@echo off
mkdir release\altera_sopc\POWERLINK\src
mkdir release\altera_sopc\POWERLINK\src\lib 
mkdir release\altera_sopc\POWERLINK\src\openMAC_DMAmaster
mkdir release\altera_sopc\POWERLINK\sdc
mkdir release\altera_sopc\POWERLINK\doc
mkdir release\altera_sopc\mif
mkdir release\altera_sopc\POWERLINK\img

copy active_hdl\src\mif\*.mif						        release\altera_sopc\mif
copy active_hdl\src\openMAC\src\*.vhd				        release\altera_sopc\POWERLINK\src
copy active_hdl\src\openMAC\src\openMAC_DMAmaster\*.vhd		release\altera_sopc\POWERLINK\src\openMAC_DMAmaster
copy active_hdl\src\PDI\src\*.vhd				            release\altera_sopc\POWERLINK\src
copy active_hdl\src\SPI\src\*.vhd				            release\altera_sopc\POWERLINK\src
copy active_hdl\src\lib\src\*.vhd					        release\altera_sopc\POWERLINK\src\lib
copy active_hdl\compile\*.vhd						        release\altera_sopc\POWERLINK\src
copy altera_sopc\powerlink_hw.tcl	                        release\altera_sopc\POWERLINK
copy altera_sopc\*.sdc				                        release\altera_sopc\POWERLINK\sdc
copy documentation\*_Generic.pdf					        release\altera_sopc\POWERLINK\doc
copy documentation\*_Altera.pdf						        release\altera_sopc\POWERLINK\doc
copy documentation\OpenMAC.pdf						        release\altera_sopc\POWERLINK\doc
copy images\*.png							                release\altera_sopc\POWERLINK\img

del release\altera_sopc\POWERLINK\src\*_TB.vhd
del release\altera_sopc\POWERLINK\src\*_Xilinx.vhd
del release\altera_sopc\POWERLINK\src\openMAC_DMAmaster\ipif_master_handler.vhd
del release\altera_sopc\POWERLINK\src\plb_powerlink.vhd

@echo on