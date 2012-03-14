@echo off

del release\drv /S /Q

mkdir release\drv\openmac\source
mkdir release\drv\openmac\include
mkdir release\drv\spi\source
mkdir release\drv\spi\include
mkdir release\drv\mtdlib\example
mkdir release\drv\mtdlib\source
mkdir release\drv\mtdlib\include

copy driver\openmac\source\*.c		release\drv\openmac\source
copy driver\openmac\include\*.h		release\drv\openmac\include

copy driver\spi\source\*.c		    release\drv\spi\source
copy driver\spi\include\*.h		    release\drv\spi\include

copy driver\mtdlib\example\*.c		release\drv\mtdlib\example
copy driver\mtdlib\source\*.c		release\drv\mtdlib\source
copy driver\mtdlib\include\*.h		release\drv\mtdlib\include

@echo on