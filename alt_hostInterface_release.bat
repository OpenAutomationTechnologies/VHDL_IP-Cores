@echo on

:: set ip core name and directories
set ipcore_name=hostinterface
set activehdl_dir=active_hdl
set alterasopc_dir=altera_qsys
set driver_dir=driver
set docu_dir=documentation
set release_dir=release\altera_qsys
set ipcore_dir=hostinterface
set txt_dir=txt

:: delete directory
del %release_dir%\%ipcore_dir% /S /Q

:: create release directory
mkdir %release_dir%\%ipcore_dir%\hdl
mkdir %release_dir%\%ipcore_dir%\hdl\lib
mkdir %release_dir%\%ipcore_dir%\img
mkdir %release_dir%\%ipcore_dir%\doc

:: copy vhdls
copy %activehdl_dir%\src\lib\src\*.vhd                              %release_dir%\%ipcore_dir%\hdl\lib
copy %activehdl_dir%\src\HOST_INTERFACE\src\*.vhd                   %release_dir%\%ipcore_dir%\hdl

:: delete not needed vhdls

:: copy others
copy %alterasopc_dir%\%ipcore_name%\%ipcore_name%_hw.tcl            %release_dir%\%ipcore_dir%
::copy %alterasopc_dir%\*.sdc                                         %release_dir%\%ipcore_dir%\sdc
::copy images\*.*                                                     %release_dir%\%ipcore_dir%\img
copy %txt_dir%\hostinterface_revision.txt                           %release_dir%\%ipcore_dir%
copy %alterasopc_dir%\%ipcore_name%\*.ipx                           %release_dir%\%ipcore_dir%

::rename txt
rename %release_dir%\%ipcore_dir%\hostinterface_revision.txt        revision.txt

:: copy documentation
::copy %docu_dir%\*_Generic.pdf                                       %release_dir%\%ipcore_dir%\doc
::copy %docu_dir%\*_Altera.pdf                                        %release_dir%\%ipcore_dir%\doc
::copy %docu_dir%\OpenMAC.pdf                                         %release_dir%\%ipcore_dir%\doc

@echo off