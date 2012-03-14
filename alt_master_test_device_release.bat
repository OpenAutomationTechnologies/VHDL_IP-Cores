@echo on

:: set ip core name and directories
set ipcore_name=masterTestDevice
set activehdl_dir=active_hdl
set alteraqsys_dir=altera_qsys
set docu_dir=
set release_dir=release\altera_qsys
set ipcore_dir=MASTER_TEST_DEVICE

:: delete directory
del %release_dir%\%ipcore_dir% /S /Q

:: create release directory
mkdir %release_dir%\%ipcore_dir%\src
mkdir %release_dir%\%ipcore_dir%\src\lib
mkdir %release_dir%\%ipcore_dir%\doc
mkdir %release_dir%\%ipcore_dir%\img

:: copy vhdls
copy %activehdl_dir%\src\lib\src\global.vhd                         %release_dir%\%ipcore_dir%\src\lib
copy %activehdl_dir%\src\MASTER_TEST_DEVICE\src\*.vhd               %release_dir%\%ipcore_dir%\src

:: copy others
copy %alteraqsys_dir%\%ipcore_name%_hw.tcl                          %release_dir%\%ipcore_dir%
copy images\br.png                                                  %release_dir%\%ipcore_dir%\img

:: copy documentation
copy %activehdl_dir%\src\MASTER_TEST_DEVICE\doc\*.pdf               %release_dir%\%ipcore_dir%\doc


@echo off