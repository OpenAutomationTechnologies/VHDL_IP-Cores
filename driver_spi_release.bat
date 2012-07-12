@echo off

del release\drv\spi /S /Q

mkdir release\drv\spi\source
mkdir release\drv\spi\include

copy driver\spi\source\*.c		    release\drv\spi\source
copy driver\spi\include\*.h		    release\drv\spi\include

@echo on