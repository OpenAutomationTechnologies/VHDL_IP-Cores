@echo off

del release\drv\openmac /S /Q

mkdir release\drv\openmac\source
mkdir release\drv\openmac\include

copy driver\openmac\source\*.c		release\drv\openmac\source
copy driver\openmac\include\*.h		release\drv\openmac\include

@echo on