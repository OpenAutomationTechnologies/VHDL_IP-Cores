@echo on

:: set ip core name and directories
set ipcore_name=plb_powerlink
set activehdl_dir=active_hdl
set xilinxxps_dir=xilinx_xps
set docu_dir=documentation
set release_dir=release\xilinx_xps\ipcore
set ipcore_dir=powerlink\pcores\%ipcore_name%_v1_00_a
set txt_dir=txt
set common_dir=common

:: delete directory
del %release_dir%\%ipcore_dir% /S /Q

:: create release directory
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl\lib
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl\openMAC_DMAmaster
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl\openMAC_DMAFifo_Xilinx
mkdir %release_dir%\%ipcore_dir%\data
mkdir %release_dir%\%ipcore_dir%\doc

:: copy vhdls
copy %common_dir%\lib\src\*.vhd                                     %release_dir%\%ipcore_dir%\hdl\vhdl\lib
copy %activehdl_dir%\src\openMAC\src\*.vhd                          %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\src\openMAC\src\openMAC_DMAmaster\*.vhd        %release_dir%\%ipcore_dir%\hdl\vhdl\openMAC_DMAmaster
copy %activehdl_dir%\src\openMAC\src\openMAC_DMAFifo_Xilinx\*.vhd   %release_dir%\%ipcore_dir%\hdl\vhdl\openMAC_DMAFifo_Xilinx
copy %activehdl_dir%\src\PDI\src\*.vhd                              %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\src\POWERLINK\src\*.vhd                        %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\src\SPI\src\*.vhd                              %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\compile\plb_powerlink.vhd                      %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\compile\OpenMAC_DMAFifo_Xilinx.vhd             %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\compile\openMAC_DMAmaster.vhd                  %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\compile\openMAC_Ethernet.vhd                   %release_dir%\%ipcore_dir%\hdl\vhdl

:: delete not needed vhdls
del %release_dir%\%ipcore_dir%\hdl\vhdl\axi_powerlink.vhd
del %release_dir%\%ipcore_dir%\hdl\vhdl\*_Altera.vhd

:: copy others
copy %xilinxxps_dir%\%ipcore_name%*.*                               %release_dir%\%ipcore_dir%\data
copy %txt_dir%\powerlink_revision.txt                               %release_dir%\%ipcore_dir%

::rename txt
rename %release_dir%\%ipcore_dir%\powerlink_revision.txt            revision.txt

:: copy documentation
copy %docu_dir%\*_Generic.pdf                                       %release_dir%\%ipcore_dir%\doc
copy %docu_dir%\*_Xilinx.pdf                                        %release_dir%\%ipcore_dir%\doc
copy %docu_dir%\OpenMAC.pdf                                         %release_dir%\%ipcore_dir%\doc

@echo off