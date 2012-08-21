@echo on

:: set ip core name and directories
set ipcore_name=axi_master_test_device
set activehdl_dir=active_hdl
set xilinxxps_dir=xilinx_xps
set docu_dir=
set release_dir=release\xilinx_xps\ipcore
set ipcore_dir=hpmn\pcores\%ipcore_name%_v1_00_a

:: delete directory
del %release_dir%\%ipcore_dir% /S /Q

:: create release directory
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl
mkdir %release_dir%\%ipcore_dir%\hdl\vhdl\lib
mkdir %release_dir%\%ipcore_dir%\data
mkdir %release_dir%\%ipcore_dir%\doc

:: copy vhdls
copy %activehdl_dir%\src\lib\src\global.vhd                         %release_dir%\%ipcore_dir%\hdl\vhdl\lib
copy %activehdl_dir%\src\MASTER_TEST_DEVICE\src\*.vhd               %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\src\openMAC\src\openMAC_DMAmaster\ipif_master_handler.vhd  %release_dir%\%ipcore_dir%\hdl\vhdl
copy %activehdl_dir%\compile\%ipcore_name%.vhd                      %release_dir%\%ipcore_dir%\hdl\vhdl

:: delete not needed vhdls
:: del %release_dir%\%ipcore_dir%\hdl\vhdl\axi_*.vhd
:: del %release_dir%\%ipcore_dir%\hdl\vhdl\*_Altera.vhd

:: copy others
copy %xilinxxps_dir%\%ipcore_name%*.*                               %release_dir%\%ipcore_dir%\data

:: copy documentation
copy %activehdl_dir%\src\MASTER_TEST_DEVICE\doc\*.pdf               %release_dir%\%ipcore_dir%\doc

@echo off