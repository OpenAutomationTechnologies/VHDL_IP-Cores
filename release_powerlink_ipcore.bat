@echo on

set DIR_AXI_POWERLINK=axi_powerlink_v0_30_a
set DIR_PLB_POWERLINK=plb_powerlink_v0_30_a

:: clean release dir
rmdir release /q /s

:: create dir structure
mkdir release\altera\components
mkdir release\altera\components\img
mkdir release\altera\components\doc
mkdir release\altera\openmac\src
mkdir release\altera\pdi\src
mkdir release\common\lib\src
mkdir release\common\openmac\src
mkdir release\common\pdi\src
mkdir release\common\powerlink\src
mkdir release\common\spi\src
mkdir release\doc
mkdir release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
mkdir release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\doc
mkdir release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\hdl\vhdl
mkdir release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
mkdir release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\doc
mkdir release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\hdl\vhdl
mkdir release\xilinx\openmac\src
mkdir release\xilinx\pdi\src

:: copy docs
copy doc\01_POWERLINK-IP-Core_Altera.pdf            release\doc
copy doc\01_POWERLINK-IP-Core_Xilinx.pdf            release\doc
copy doc\02_POWERLINK-IP-Core_Generic.pdf           release\doc
copy doc\03_OpenMAC.pdf                             release\doc

:: copy Altera POWERLINK
copy altera\components\doc\index.pdf                release\altera\components\doc
copy altera\components\img\*.*                      release\altera\components\img
copy altera\components\powerlink_hw.tcl             release\altera\components
copy altera\openmac\src\dpr_16_16.mif               release\altera\openmac\src
copy altera\openmac\src\dpr_16_32.mif               release\altera\openmac\src
copy altera\pdi\src\pdi_dpr.mif                     release\altera\pdi\src
copy common\powerlink\src\powerlink.vhd             release\common\powerlink\src
copy altera\openmac\src\openMAC_DPR.vhd             release\altera\openmac\src
copy altera\openmac\src\openMAC_DMAFifo.vhd         release\altera\openmac\src
copy common\openmac\src\openFILTER.vhd              release\common\openmac\src
copy common\openmac\src\openHUB.vhd                 release\common\openmac\src
copy common\openmac\src\openMAC.vhd                 release\common\openmac\src
copy common\openmac\src\openMAC_Ethernet.vhd        release\common\openmac\src
copy common\openmac\src\openMAC_cmp.vhd             release\common\openmac\src
copy common\openmac\src\openMAC_phyAct.vhd          release\common\openmac\src
copy common\openmac\src\openMAC_DMAmaster.vhd       release\common\openmac\src
copy common\openmac\src\dma_handler.vhd             release\common\openmac\src
copy common\openmac\src\master_handler.vhd          release\common\openmac\src
copy common\openmac\src\openMAC_PHYMI.vhd           release\common\openmac\src
copy common\openmac\src\openMAC_rmii2mii.vhd        release\common\openmac\src
copy altera\pdi\src\pdi_dpr.vhd                     release\altera\pdi\src
copy common\pdi\src\pdi.vhd                         release\common\pdi\src
copy common\pdi\src\pdi_par.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_tripleVBufLogic.vhd         release\common\pdi\src
copy common\pdi\src\pdi_apIrqGen.vhd                release\common\pdi\src
copy common\pdi\src\pdi_controlStatusReg.vhd        release\common\pdi\src
copy common\pdi\src\pdi_event.vhd                   release\common\pdi\src
copy common\pdi\src\pdi_led.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_simpleReg.vhd               release\common\pdi\src
copy common\pdi\src\portio.vhd                      release\common\pdi\src
copy common\pdi\src\portio_cnt.vhd                  release\common\pdi\src
copy common\pdi\src\pdi_spi.vhd                     release\common\pdi\src
copy common\spi\src\spi.vhd                         release\common\spi\src
copy common\spi\src\spi_sreg.vhd                    release\common\spi\src
copy common\lib\src\addr_decoder.vhd                release\common\lib\src
copy common\lib\src\edgedet.vhd                     release\common\lib\src
copy common\lib\src\req_ack.vhd                     release\common\lib\src
copy common\lib\src\sync.vhd                        release\common\lib\src
copy common\lib\src\slow2fastSync.vhd               release\common\lib\src
copy common\lib\src\memMap.vhd                      release\common\lib\src
copy common\lib\src\global.vhd                      release\common\lib\src

:: copy Xilinx AXI POWERLINK
copy common\lib\src\addr_decoder.vhd                release\common\lib\src
copy common\lib\src\edgedet.vhd                     release\common\lib\src
copy common\lib\src\memMap.vhd                      release\common\lib\src
copy common\lib\src\req_ack.vhd                     release\common\lib\src
copy common\lib\src\sync.vhd                        release\common\lib\src
copy common\lib\src\slow2fastSync.vhd               release\common\lib\src
copy common\lib\src\clkXingRtl.vhd                  release\common\lib\src
copy common\lib\src\global.vhd                      release\common\lib\src
copy xilinx\openmac\src\async_fifo_ctrl.vhd         release\xilinx\openmac\src
copy xilinx\openmac\src\fifo_read.vhd               release\xilinx\openmac\src
copy xilinx\openmac\src\fifo_write.vhd              release\xilinx\openmac\src
copy xilinx\openmac\src\n_synchronizer.vhd          release\xilinx\openmac\src
copy xilinx\openmac\src\ipif_master_handler.vhd     release\xilinx\openmac\src
copy xilinx\openmac\src\openMAC_DMAFifo.vhd         release\xilinx\openmac\src
copy xilinx\openmac\src\openMAC_DPR.vhd             release\xilinx\openmac\src
copy xilinx\pdi\src\pdi_dpr.vhd                     release\xilinx\pdi\src
copy common\openmac\src\dma_handler.vhd             release\common\openmac\src
copy common\openmac\src\master_handler.vhd          release\common\openmac\src
copy common\openmac\src\openFILTER.vhd              release\common\openmac\src
copy common\openmac\src\openHUB.vhd                 release\common\openmac\src
copy common\openmac\src\openMAC_16to32conv.vhd      release\common\openmac\src
copy common\openmac\src\openMAC_cmp.vhd             release\common\openmac\src
copy common\openmac\src\openMAC_DMAmaster.vhd       release\common\openmac\src
copy common\openmac\src\openMAC_Ethernet.vhd        release\common\openmac\src
copy common\openmac\src\openMAC_phyAct.vhd          release\common\openmac\src
copy common\openmac\src\openMAC_PHYMI.vhd           release\common\openmac\src
copy common\openmac\src\openMAC_rmii2mii.vhd        release\common\openmac\src
copy common\openmac\src\openMAC.vhd                 release\common\openmac\src
copy common\spi\src\spi_sreg.vhd                    release\common\spi\src
copy common\spi\src\spi.vhd                         release\common\spi\src
copy common\pdi\src\pdi_apIrqGen.vhd                release\common\pdi\src
copy common\pdi\src\pdi_controlStatusReg.vhd        release\common\pdi\src
copy common\pdi\src\pdi_event.vhd                   release\common\pdi\src
copy common\pdi\src\pdi_led.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_par.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_simpleReg.vhd               release\common\pdi\src
copy common\pdi\src\pdi_spi.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_tripleVBufLogic.vhd         release\common\pdi\src
copy common\pdi\src\pdi.vhd                         release\common\pdi\src
copy common\pdi\src\portio_cnt.vhd                  release\common\pdi\src
copy common\pdi\src\portio.vhd                      release\common\pdi\src
copy common\powerlink\src\powerlink.vhd             release\common\powerlink\src
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\data\axi_powerlink_v2_1_0.mdd     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\data\axi_powerlink_v2_1_0.mpd     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\data\axi_powerlink_v2_1_0.mui     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\data\axi_powerlink_v2_1_0.pao     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\data\axi_powerlink_v2_1_0.tcl     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\data
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\doc\index.pdf                     release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\doc
copy xilinx\library\pcores\axi_powerlink_vX_YY_Z\hdl\vhdl\axi_powerlink.vhd        release\xilinx\library\pcores\%DIR_AXI_POWERLINK%\hdl\vhdl

:: copy Xilinx PLB POWERLINK
copy common\lib\src\addr_decoder.vhd                release\common\lib\src
copy common\lib\src\edgedet.vhd                     release\common\lib\src
copy common\lib\src\memMap.vhd                      release\common\lib\src
copy common\lib\src\req_ack.vhd                     release\common\lib\src
copy common\lib\src\sync.vhd                        release\common\lib\src
copy common\lib\src\slow2fastSync.vhd               release\common\lib\src
copy common\lib\src\global.vhd                      release\common\lib\src
copy xilinx\openmac\src\async_fifo_ctrl.vhd         release\xilinx\openmac\src
copy xilinx\openmac\src\fifo_read.vhd               release\xilinx\openmac\src
copy xilinx\openmac\src\fifo_write.vhd              release\xilinx\openmac\src
copy xilinx\openmac\src\n_synchronizer.vhd          release\xilinx\openmac\src
copy xilinx\openmac\src\ipif_master_handler.vhd     release\xilinx\openmac\src
copy xilinx\openmac\src\openMAC_DMAFifo.vhd         release\xilinx\openmac\src
copy xilinx\openmac\src\openMAC_DPR.vhd             release\xilinx\openmac\src
copy xilinx\pdi\src\pdi_dpr.vhd                     release\xilinx\pdi\src
copy common\openmac\src\dma_handler.vhd             release\common\openmac\src
copy common\openmac\src\master_handler.vhd          release\common\openmac\src
copy common\openmac\src\openFILTER.vhd              release\common\openmac\src
copy common\openmac\src\openHUB.vhd                 release\common\openmac\src
copy common\openmac\src\openMAC_16to32conv.vhd      release\common\openmac\src
copy common\openmac\src\openMAC_cmp.vhd             release\common\openmac\src
copy common\openmac\src\openMAC_DMAmaster.vhd       release\common\openmac\src
copy common\openmac\src\openMAC_Ethernet.vhd        release\common\openmac\src
copy common\openmac\src\openMAC_phyAct.vhd          release\common\openmac\src
copy common\openmac\src\openMAC_PHYMI.vhd           release\common\openmac\src
copy common\openmac\src\openMAC_rmii2mii.vhd        release\common\openmac\src
copy common\openmac\src\openMAC.vhd                 release\common\openmac\src
copy common\spi\src\spi_sreg.vhd                    release\common\spi\src
copy common\spi\src\spi.vhd                         release\common\spi\src
copy common\pdi\src\pdi_apIrqGen.vhd                release\common\pdi\src
copy common\pdi\src\pdi_controlStatusReg.vhd        release\common\pdi\src
copy common\pdi\src\pdi_event.vhd                   release\common\pdi\src
copy common\pdi\src\pdi_led.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_par.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_simpleReg.vhd               release\common\pdi\src
copy common\pdi\src\pdi_spi.vhd                     release\common\pdi\src
copy common\pdi\src\pdi_tripleVBufLogic.vhd         release\common\pdi\src
copy common\pdi\src\pdi.vhd                         release\common\pdi\src
copy common\pdi\src\portio_cnt.vhd                  release\common\pdi\src
copy common\pdi\src\portio.vhd                      release\common\pdi\src
copy common\powerlink\src\powerlink.vhd             release\common\powerlink\src
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\data\plb_powerlink_v2_1_0.mdd     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\data\plb_powerlink_v2_1_0.mpd     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\data\plb_powerlink_v2_1_0.mui     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\data\plb_powerlink_v2_1_0.pao     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\data\plb_powerlink_v2_1_0.tcl     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\data
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\doc\index.pdf                     release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\doc
copy xilinx\library\pcores\plb_powerlink_vX_YY_Z\hdl\vhdl\plb_powerlink.vhd        release\xilinx\library\pcores\%DIR_PLB_POWERLINK%\hdl\vhdl


@echo off