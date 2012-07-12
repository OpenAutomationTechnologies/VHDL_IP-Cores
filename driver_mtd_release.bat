@echo off

del release\drv\mtdlib /S /Q

mkdir release\drv\mtdlib\example
mkdir release\drv\mtdlib\source
mkdir release\drv\mtdlib\include

copy driver\mtdlib\example\*.c		release\drv\mtdlib\example
copy driver\mtdlib\source\*.c		release\drv\mtdlib\source
copy driver\mtdlib\include\*.h		release\drv\mtdlib\include

@echo on