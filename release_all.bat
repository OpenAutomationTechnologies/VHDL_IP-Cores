@echo off

:: delete the release directory
::del release /S /Q

:: call altera releases
call alt_powerlink_release
call alt_powerlink_sopc_release

:: call xilinx releases
call xil_axi_powerlink_release
call xil_plb_powerlink_release

:: call driver release
call driver_openmac_release
call driver_spi_release

@echo on
