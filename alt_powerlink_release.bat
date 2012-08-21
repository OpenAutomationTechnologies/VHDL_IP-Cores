@echo on

:: set ip core name and directories
set ipcore_name=powerlink
set activehdl_dir=active_hdl
set alterasopc_dir=altera_qsys
set docu_dir=documentation
set release_dir=release\altera_qsys
set ipcore_dir=powerlink
set txt_dir=txt

:: delete directory
del %release_dir%\%ipcore_dir% /S /Q

:: create release directory
mkdir %release_dir%\%ipcore_dir%\src
mkdir %release_dir%\%ipcore_dir%\src\lib
mkdir %release_dir%\%ipcore_dir%\src\openMAC_DMAmaster
mkdir %release_dir%\%ipcore_dir%\sdc
mkdir %release_dir%\%ipcore_dir%\img
mkdir %release_dir%\%ipcore_dir%\doc

:: copy vhdls
copy %activehdl_dir%\src\lib\src\*.vhd                              %release_dir%\%ipcore_dir%\src\lib
copy %activehdl_dir%\src\openMAC\src\*.vhd                          %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\src\openMAC\src\*.mif                          %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\src\openMAC\src\openMAC_DMAmaster\*.vhd        %release_dir%\%ipcore_dir%\src\openMAC_DMAmaster
copy %activehdl_dir%\src\PDI\src\*.vhd                              %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\src\PDI\src\*.mif                              %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\src\POWERLINK\src\*.vhd                        %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\src\SPI\src\*.vhd                              %release_dir%\%ipcore_dir%\src
copy %activehdl_dir%\compile\*.vhd                                  %release_dir%\%ipcore_dir%\src

:: delete not needed vhdls
del %release_dir%\%ipcore_dir%\src\axi_*.vhd
del %release_dir%\%ipcore_dir%\src\plb_*.vhd
del %release_dir%\%ipcore_dir%\src\*_Xilinx.vhd
del %release_dir%\%ipcore_dir%\src\openMAC_DMAmaster\ipif_master_handler.vhd

:: copy others
copy %alterasopc_dir%\%ipcore_name%_hw.tcl                          %release_dir%\%ipcore_dir%
copy %alterasopc_dir%\*.sdc                                         %release_dir%\%ipcore_dir%\sdc
copy images\*.*                                                     %release_dir%\%ipcore_dir%\img
copy %txt_dir%\powerlink_revision.txt                               %release_dir%\%ipcore_dir%

::rename txt
rename %release_dir%\%ipcore_dir%\powerlink_revision.txt            revision.txt

:: copy documentation
copy %docu_dir%\*_Generic.pdf                                       %release_dir%\%ipcore_dir%\doc
copy %docu_dir%\*_Altera.pdf                                        %release_dir%\%ipcore_dir%\doc
copy %docu_dir%\OpenMAC.pdf                                         %release_dir%\%ipcore_dir%\doc

@echo off