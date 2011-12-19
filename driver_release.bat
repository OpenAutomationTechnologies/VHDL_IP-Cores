@echo off

mkdir release\drv\openmac\source
mkdir release\drv\openmac\include
mkdir release\drv\spi\source
mkdir release\drv\spi\include

copy driver\openmac\source\*.c		release\drv\openmac\source
copy driver\openmac\include\*.h		release\drv\openmac\include

copy driver\spi\source\*.c		release\drv\spi\source
copy driver\spi\include\*.h		release\drv\spi\include

@echo on