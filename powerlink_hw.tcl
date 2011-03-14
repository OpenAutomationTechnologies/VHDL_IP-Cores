#------------------------------------------------------------------------------------------------------------------------
#-- POWERLINK SOPC COMPONENT
#--
#-- 	  Copyright (C) 2010 B&R
#--
#--    Redistribution and use in source and binary forms, with or without
#--    modification, are permitted provided that the following conditions
#--    are met:
#--
#--    1. Redistributions of source code must retain the above copyright
#--       notice, this list of conditions and the following disclaimer.
#--
#--    2. Redistributions in binary form must reproduce the above copyright
#--       notice, this list of conditions and the following disclaimer in the
#--       documentation and/or other materials provided with the distribution.
#--
#--    3. Neither the name of B&R nor the names of its
#--       contributors may be used to endorse or promote products derived
#--       from this software without prior written permission. For written
#--       permission, please contact office@br-automation.com
#--
#--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#--    POSSIBILITY OF SUCH DAMAGE.
#--
#------------------------------------------------------------------------------------------------------------------------
#-- Version History
#------------------------------------------------------------------------------------------------------------------------
#-- 2010-08-24	V0.01	zelenkaj	first generation
#-- 2010-09-13	V0.02	zelenkaj	added selection Rmii / Mii
#-- 2010-10-04  V0.03	zelenkaj	bugfix: Rmii / Mii selection was faulty
#-- 2010-10-11  V0.04	zelenkaj	changed pdi dpr size calculation
#-- 2010-10-18	V0.05	zelenkaj	added selection Big/Little Endian (pdi_par)
#--									use bidirectional data bus (pdi_par)
#-- 2010-11-15	V0.06	zelenkaj	bugfix: rpdo header was calculated twice
#-- 2010-11-22	V0.07	zelenkaj	Added 2 GPIO signals to parallel interface
#--									Added Operational Flag to simple I/O interface
#--									Omitted T/RPDO descriptor sections in DPR
#--									Added ability to verify connected clock rates (to clkEth and clk50meg)
#--									Added generic to set duration of valid assertion (portio)
#-- 2010-11-29	V0.08	zelenkaj	Changed several Endianness sel. to one for AP
#--									Allocation of ping-pong tx buffers (necessary by openPOWERLINK stack)
#-- 2010-11-30	V0.09	zelenkaj	Added other picture as Block Diagram (3 design approaches)
#-- 2010-12-06	V0.10	zelenkaj	Changed Cmacros
#--									Added openMAC only parameter
#--									Added SPI IRQ active high/low choice
#-- 2010-12-07	V0.11	zelenkaj	Bugfix: AP IRQ was generated incorrect for SPI
#--									Code clean up
#-- 2011-01-25	V0.12	zelenkaj	Added generic internal/external packet storage
#-- 2011-02-24	V0.13	zelenkaj	Bugfix: openMAC only with RMII generates division by zero
#--									minor changes (naming conventions Mii->SMI)
#-- 2011-03-14	V0.14	zelenkaj	Added generic for packet storage (RX int/ext)
#------------------------------------------------------------------------------------------------------------------------

package require -exact sopc 10.0

set_module_property DESCRIPTION "POWERLINK IP-core"
set_module_property NAME powerlink
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP POWERLINK
set_module_property AUTHOR "Joerg Zelenka (B&R 2010)"
set_module_property DISPLAY_NAME "POWERLINK"
set_module_property TOP_LEVEL_HDL_FILE powerlink.vhd
set_module_property TOP_LEVEL_HDL_MODULE powerlink
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property ICON_PATH img/br.png

#files
add_file src/powerlink.vhd {SYNTHESIS SIMULATION}
add_file src/pdi.vhd {SYNTHESIS SIMULATION}
add_file src/pdi_par.vhd {SYNTHESIS SIMULATION}
add_file src/pdi_dpr.vhd {SYNTHESIS SIMULATION}
add_file src/pdi_tripleVBufLogic.vhd {SYNTHESIS SIMULATION}
add_file src/OpenFILTER.vhd {SYNTHESIS SIMULATION}
add_file src/OpenHUB.vhd {SYNTHESIS SIMULATION}
add_file src/OpenMAC.vhd {SYNTHESIS SIMULATION}
add_file src/OpenMAC_AvalonIF.vhd {SYNTHESIS SIMULATION}
add_file src/OpenMAC_DPR_Altera.vhd {SYNTHESIS SIMULATION}
add_file src/OpenMAC_DMAFifo.vhd {SYNTHESIS SIMULATION}
add_file src/OpenMAC_PHYMI.vhd {SYNTHESIS SIMULATION}
add_file src/rmii2mii.vhd {SYNTHESIS SIMULATION}
add_file src/portio.vhd {SYNTHESIS SIMULATION}
add_file src/spi.vhd {SYNTHESIS SIMULATION}
add_file src/spi_sreg.vhd {SYNTHESIS SIMULATION}
add_file src/pdi_spi.vhd {SYNTHESIS SIMULATION}


#callbacks
set_module_property VALIDATION_CALLBACK my_validation_callback
set_module_property ELABORATION_CALLBACK my_elaboration_callback

#parameters
add_parameter clkRateEth INTEGER 0
set_parameter_property clkRateEth SYSTEM_INFO {CLOCK_RATE clkEth}
set_parameter_property clkRateEth VISIBLE false

add_parameter clkRate50 INTEGER 0
set_parameter_property clkRate50 SYSTEM_INFO {CLOCK_RATE clk50meg}
set_parameter_property clkRate50 VISIBLE false

add_parameter clkRatePcp INTEGER 0
set_parameter_property clkRatePcp SYSTEM_INFO {CLOCK_RATE pcp_clk}
set_parameter_property clkRatePcp VISIBLE false

add_parameter configPowerlink STRING "CN with Processor Interface"
set_parameter_property configPowerlink DISPLAY_NAME "POWERLINK Slave Design Configuration"
set_parameter_property configPowerlink ALLOWED_RANGES {"Direct I/O CN" "CN with Processor Interface" "openMAC only"}
set_parameter_property configPowerlink DISPLAY_HINT radio

add_parameter configApInterface STRING "Avalon"
set_parameter_property configApInterface VISIBLE true
set_parameter_property configApInterface DISPLAY_NAME "Interface to AP"
set_parameter_property configApInterface ALLOWED_RANGES {"Avalon" "Parallel" "SPI"}
set_parameter_property configApInterface DISPLAY_HINT radio

add_parameter configApParallelInterface STRING "8bit"
set_parameter_property configApParallelInterface VISIBLE false
set_parameter_property configApParallelInterface DISPLAY_NAME "Size of Parallel Interface to AP"
set_parameter_property configApParallelInterface ALLOWED_RANGES {"8bit" "16bit"}

add_parameter configApParSigs STRING "High Active"
set_parameter_property configApParSigs VISIBLE false
set_parameter_property configApParSigs DISPLAY_NAME "Active State of Control Signal (Cs, Wr, Rd and Be)"
set_parameter_property configApParSigs ALLOWED_RANGES {"High Active" "Low Active"}

add_parameter configApParOutSigs STRING "High Active"
set_parameter_property configApParOutSigs VISIBLE false
set_parameter_property configApParOutSigs DISPLAY_NAME "Active State of Output Signals (Irq and Ready)"
set_parameter_property configApParOutSigs ALLOWED_RANGES {"High Active" "Low Active"}

add_parameter configApEndian STRING "Little"
set_parameter_property configApEndian VISIBLE false
set_parameter_property configApEndian DISPLAY_NAME "Endianness of AP"
set_parameter_property configApEndian ALLOWED_RANGES {"Little" "Big"}

add_parameter configApSpi_CPOL STRING "0"
set_parameter_property configApSpi_CPOL VISIBLE false
set_parameter_property configApSpi_CPOL DISPLAY_NAME "SPI CPOL"
set_parameter_property configApSpi_CPOL ALLOWED_RANGES {"0" "1"}

add_parameter configApSpi_CPHA STRING "0"
set_parameter_property configApSpi_CPHA VISIBLE false
set_parameter_property configApSpi_CPHA DISPLAY_NAME "SPI CPHA"
set_parameter_property configApSpi_CPHA ALLOWED_RANGES {"0" "1"}

add_parameter configApSpi_IRQ STRING "High Active"
set_parameter_property configApSpi_IRQ VISIBLE false
set_parameter_property configApSpi_IRQ DISPLAY_NAME "Active State of Output Signals (Irq)"
set_parameter_property configApSpi_IRQ ALLOWED_RANGES {"High Active" "Low Active"}

add_parameter rpdoNum INTEGER 3
set_parameter_property rpdoNum ALLOWED_RANGES {1 2 3}
set_parameter_property rpdoNum DISPLAY_NAME "Number of RPDO Buffers"

add_parameter rpdo0size INTEGER 1
set_parameter_property rpdo0size ALLOWED_RANGES 1:1490
set_parameter_property rpdo0size UNITS bytes
set_parameter_property rpdo0size DISPLAY_NAME "1st RPDO Buffer Size"

add_parameter rpdo1size INTEGER 1
set_parameter_property rpdo1size ALLOWED_RANGES 1:1490
set_parameter_property rpdo1size UNITS bytes
set_parameter_property rpdo1size DISPLAY_NAME "2nd RPDO Buffer Size"

add_parameter rpdo2size INTEGER 1
set_parameter_property rpdo2size ALLOWED_RANGES 1:1490
set_parameter_property rpdo2size UNITS bytes
set_parameter_property rpdo2size DISPLAY_NAME "3rd RPDO Buffer Size"

add_parameter tpdoNum INTEGER 1
set_parameter_property tpdoNum ALLOWED_RANGES 1
set_parameter_property tpdoNum DISPLAY_NAME "Number of TPDO Buffers"

add_parameter tpdo0size INTEGER 1
set_parameter_property tpdo0size ALLOWED_RANGES 1:1490
set_parameter_property tpdo0size UNITS bytes
set_parameter_property tpdo0size DISPLAY_NAME "1st TPDO Buffer Size"

add_parameter asyncTxBufSize INTEGER 1514
set_parameter_property asyncTxBufSize ALLOWED_RANGES 1:1518
set_parameter_property asyncTxBufSize UNITS bytes
set_parameter_property asyncTxBufSize DISPLAY_NAME "Asynchronous TX Buffer Size"

add_parameter asyncRxBufSize INTEGER 1514
set_parameter_property asyncRxBufSize ALLOWED_RANGES 1:1518
set_parameter_property asyncRxBufSize UNITS bytes
set_parameter_property asyncRxBufSize DISPLAY_NAME "Asynchronous RX Buffer Size"

add_parameter phyIF STRING "RMII"
set_parameter_property phyIF VISIBLE true
set_parameter_property phyIF DISPLAY_NAME "Ethernet Phy Interface"
set_parameter_property phyIF ALLOWED_RANGES {"RMII" "MII"}
set_parameter_property phyIF DISPLAY_HINT radio

add_parameter packetLoc STRING "TX and RX into DPRAM"
set_parameter_property packetLoc VISIBLE true
set_parameter_property packetLoc DISPLAY_NAME "Packet Buffer Location"
set_parameter_property packetLoc ALLOWED_RANGES {"TX and RX into DPRAM" "TX into DPRAM and RX over Avalon Master" "TX and RX over Avalon Master"}
set_parameter_property packetLoc DISPLAY_HINT radio

add_parameter validSet INTEGER "1"
set_parameter_property validSet VISIBLE false
set_parameter_property validSet ALLOWED_RANGES 1:128
set_parameter_property validSet DISPLAY_NAME "Valid signal set Clock Cycles"

add_parameter validAssertDuration STRING "1000"
set_parameter_property validAssertDuration VISIBLE false
set_parameter_property validAssertDuration DISPLAY_NAME "Implemented Valid signal set duration (Clock Cycles x Clock Period)"
set_parameter_property validAssertDuration DISPLAY_UNITS "ns"
set_parameter_property validAssertDuration ENABLED false
set_parameter_property validAssertDuration DERIVED TRUE

add_parameter macTxBuf INTEGER 1514
set_parameter_property macTxBuf UNITS bytes
set_parameter_property macTxBuf DISPLAY_NAME "openMAC TX Buffer Size"

add_parameter macRxBuf INTEGER 1514
set_parameter_property macRxBuf UNITS bytes
set_parameter_property macRxBuf DISPLAY_NAME "openMAC RX Buffer Size"

#parameters for PDI HDL
add_parameter genPdi_g BOOLEAN true
set_parameter_property genPdi_g HDL_PARAMETER true
set_parameter_property genPdi_g VISIBLE false
set_parameter_property genPdi_g DERIVED TRUE

add_parameter genAvalonAp_g BOOLEAN true
set_parameter_property genAvalonAp_g HDL_PARAMETER true
set_parameter_property genAvalonAp_g VISIBLE false
set_parameter_property genAvalonAp_g DERIVED TRUE

add_parameter genSimpleIO_g BOOLEAN false
set_parameter_property genSimpleIO_g HDL_PARAMETER true
set_parameter_property genSimpleIO_g VISIBLE false
set_parameter_property genSimpleIO_g DERIVED TRUE

add_parameter genSpiAp_g BOOLEAN false
set_parameter_property genSpiAp_g HDL_PARAMETER true
set_parameter_property genSpiAp_g VISIBLE false
set_parameter_property genSpiAp_g DERIVED TRUE

add_parameter iRpdos_g INTEGER 1
set_parameter_property iRpdos_g HDL_PARAMETER true
set_parameter_property iRpdos_g ALLOWED_RANGES {0 1 2 3}
set_parameter_property iRpdos_g VISIBLE false
set_parameter_property iRpdos_g DERIVED TRUE

add_parameter iTpdos_g INTEGER 1
set_parameter_property iTpdos_g HDL_PARAMETER true
set_parameter_property iTpdos_g ALLOWED_RANGES {0 1}
set_parameter_property iTpdos_g VISIBLE false
set_parameter_property iTpdos_g DERIVED TRUE

add_parameter iTpdoBufSize_g INTEGER 1
set_parameter_property iTpdoBufSize_g HDL_PARAMETER true
set_parameter_property iTpdoBufSize_g VISIBLE false
set_parameter_property iTpdoBufSize_g DERIVED TRUE

add_parameter iRpdo0BufSize_g INTEGER 1
set_parameter_property iRpdo0BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo0BufSize_g VISIBLE false
set_parameter_property iRpdo0BufSize_g DERIVED TRUE

add_parameter iRpdo1BufSize_g INTEGER 1
set_parameter_property iRpdo1BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo1BufSize_g VISIBLE false
set_parameter_property iRpdo1BufSize_g DERIVED TRUE

add_parameter iRpdo2BufSize_g INTEGER 1
set_parameter_property iRpdo2BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo2BufSize_g VISIBLE false
set_parameter_property iRpdo2BufSize_g DERIVED TRUE

add_parameter iAsyTxBufSize_g INTEGER 1514
set_parameter_property iAsyTxBufSize_g HDL_PARAMETER true
set_parameter_property iAsyTxBufSize_g VISIBLE false
set_parameter_property iAsyTxBufSize_g DERIVED TRUE

add_parameter iAsyRxBufSize_g INTEGER 1514
set_parameter_property iAsyRxBufSize_g HDL_PARAMETER true
set_parameter_property iAsyRxBufSize_g VISIBLE false
set_parameter_property iAsyRxBufSize_g DERIVED TRUE

#parameters for OPENMAC HDL
add_parameter Simulate BOOLEAN false
set_parameter_property Simulate HDL_PARAMETER true
set_parameter_property Simulate VISIBLE false
set_parameter_property Simulate DERIVED TRUE

add_parameter iBufSize_g INTEGER 1024
set_parameter_property iBufSize_g HDL_PARAMETER true
set_parameter_property iBufSize_g VISIBLE false
set_parameter_property iBufSize_g DERIVED TRUE

add_parameter iBufSizeLOG2_g INTEGER 10
set_parameter_property iBufSizeLOG2_g HDL_PARAMETER true
set_parameter_property iBufSizeLOG2_g VISIBLE false
set_parameter_property iBufSizeLOG2_g DERIVED TRUE

add_parameter useRmii_g BOOLEAN true
set_parameter_property useRmii_g HDL_PARAMETER true
set_parameter_property useRmii_g VISIBLE false
set_parameter_property useRmii_g DERIVED true

add_parameter useIntPacketBuf_g BOOLEAN true
set_parameter_property useIntPacketBuf_g HDL_PARAMETER true
set_parameter_property useIntPacketBuf_g VISIBLE false
set_parameter_property useIntPacketBuf_g DERIVED true

add_parameter useRxIntPacketBuf_g BOOLEAN true
set_parameter_property useRxIntPacketBuf_g HDL_PARAMETER true
set_parameter_property useRxIntPacketBuf_g VISIBLE false
set_parameter_property useRxIntPacketBuf_g DERIVED true

#parameters for parallel interface
add_parameter papDataWidth_g INTEGER 16
set_parameter_property papDataWidth_g HDL_PARAMETER true
set_parameter_property papDataWidth_g VISIBLE false
set_parameter_property papDataWidth_g DERIVED TRUE

add_parameter papLowAct_g BOOLEAN false
set_parameter_property papLowAct_g HDL_PARAMETER true
set_parameter_property papLowAct_g VISIBLE false
set_parameter_property papLowAct_g DERIVED TRUE

add_parameter papBigEnd_g BOOLEAN false
set_parameter_property papBigEnd_g HDL_PARAMETER true
set_parameter_property papBigEnd_g VISIBLE false
set_parameter_property papBigEnd_g DERIVED TRUE

#parameters for SPI
add_parameter spiCPOL_g BOOLEAN false
set_parameter_property spiCPOL_g HDL_PARAMETER true
set_parameter_property spiCPOL_g VISIBLE false
set_parameter_property spiCPOL_g DERIVED TRUE

add_parameter spiCPHA_g BOOLEAN false
set_parameter_property spiCPHA_g HDL_PARAMETER true
set_parameter_property spiCPHA_g VISIBLE false
set_parameter_property spiCPHA_g DERIVED TRUE

add_parameter spiBigEnd_g BOOLEAN false
set_parameter_property spiBigEnd_g HDL_PARAMETER true
set_parameter_property spiBigEnd_g VISIBLE false
set_parameter_property spiBigEnd_g DERIVED TRUE

#parameters for portio
add_parameter pioValLen_g INTEGER 50
set_parameter_property pioValLen_g HDL_PARAMETER true
set_parameter_property pioValLen_g VISIBLE false
set_parameter_property pioValLen_g DERIVED TRUE

proc my_validation_callback {} {
#do some preparation stuff
	set configPowerlink 			[get_parameter_value configPowerlink]
	set configApInterface 			[get_parameter_value configApInterface]
	set configApParallelInterface 	[get_parameter_value configApParallelInterface]
	set spiCpol						[get_parameter_value configApSpi_CPOL]
	set spiCpha						[get_parameter_value configApSpi_CPHA]
	set rpdos						[get_parameter_value rpdoNum]
	set tpdos						[get_parameter_value tpdoNum]
	set rpdo0size					[get_parameter_value rpdo0size]
	set rpdo1size					[get_parameter_value rpdo1size]
	set rpdo2size					[get_parameter_value rpdo2size]
	set tpdo0size					[get_parameter_value tpdo0size]
	set asyncTxBufSize				[get_parameter_value asyncTxBufSize]
	set asyncRxBufSize				[get_parameter_value asyncRxBufSize]
	set macTxBuf					[get_parameter_value macTxBuf]
	set macRxBuf					[get_parameter_value macRxBuf]
	
	set mii							[get_parameter_value phyIF]
	set ploc						[get_parameter_value packetLoc]
	
	if {$mii == "RMII"} {
		set_parameter_value useRmii_g true
	} else {
		set_parameter_value useRmii_g false
		send_message info "Consider to use RMII to reduce resource usage!"
	}
	
	if {$ploc == "TX and RX into DPRAM"} {
		set_parameter_value useIntPacketBuf_g true
		set_parameter_value useRxIntPacketBuf_g true
	} elseif {$ploc == "TX into DPRAM and RX over Avalon Master" } {
		set_parameter_value useIntPacketBuf_g true
		set_parameter_value useRxIntPacketBuf_g false
		send_message info "Connect the Avalon Master 'MAC_DMA' to the memory where Heap is located!"
	} elseif {$ploc == "TX and RX over Avalon Master"} {
		set_parameter_value useIntPacketBuf_g false
		set_parameter_value useRxIntPacketBuf_g false
		send_message info "Connect the Avalon Master 'MAC_DMA' to low latency memory! Heap must be located in the same memory!"
	} else {
		send_message error "error 0x01"
	}
	
	set memRpdo 0
	set memTpdo 0
	
	#add to RPDOs and Async buffers the header (since it isn't done by vhdl anymore)
	set rpdo0size 					[expr $rpdo0size + 16]
	set rpdo1size 					[expr $rpdo1size + 16]
	set rpdo2size 					[expr $rpdo2size + 16]
	set tpdo0size 					[expr $tpdo0size + 0]
	set asyncTxBufSize				[expr $asyncTxBufSize + 4]
	set asyncRxBufSize				[expr $asyncRxBufSize + 4]
	
	set genPdi false
	set genAvalonAp false
	set genSimpleIO false
	set genSpiAp false
	
	#some constants from openMAC
	set macPktLength	4
	# tx buffer header (header + packet length)
	set macTxHd			[expr  0 + $macPktLength]
	# rx buffer header (header + packet length)
	set macRxHd 		[expr 12 + $macPktLength]
	# max rx buffers
	set macRxBuffers 	16
	# max tx buffers
	set macTxBuffers	16
	# mtu by ieee
	set mtu 			1500
	# eth header
	set ethHd			14
	# crc size by ieee
	set crc				4

#so, now verify which configuration should be set
	#default assignments...
	set_parameter_property configApInterface VISIBLE false
	set_parameter_property configApParallelInterface VISIBLE false
	set_parameter_property configApParSigs VISIBLE false
	set_parameter_property configApParOutSigs VISIBLE false
	set_parameter_property configApEndian VISIBLE false
	set_parameter_property configApSpi_CPOL VISIBLE false
	set_parameter_property configApSpi_CPHA VISIBLE false
	set_parameter_property configApSpi_IRQ VISIBLE false
	set_parameter_property asyncTxBufSize VISIBLE false
	set_parameter_property asyncRxBufSize VISIBLE false
	set_parameter_property rpdo0size VISIBLE false
	set_parameter_property rpdo1size VISIBLE false
	set_parameter_property rpdo2size VISIBLE false
	set_parameter_property tpdo0size VISIBLE false
	set_parameter_property validAssertDuration VISIBLE false
	set_parameter_property validSet VISIBLE false
	set_parameter_property macTxBuf VISIBLE false
	set_parameter_property macRxBuf VISIBLE false
	
	set_parameter_property rpdoNum VISIBLE true
	set_parameter_property tpdoNum VISIBLE true
	
	if {$configPowerlink == "openMAC only"} {
		#no PDI, only openMAC
		if {$ploc == "TX and RX into DPRAM"} {
			set_parameter_property macTxBuf VISIBLE true
			set_parameter_property macRxBuf VISIBLE true
		} elseif {$ploc == "TX into DPRAM and RX over Avalon Master"} {
			set_parameter_property macTxBuf VISIBLE true
		} elseif {$ploc == "TX and RX over Avalon Master"} {
			#nothing to set
		} else {
			send_message error "error 0x02"
		}
		
		set_parameter_property rpdoNum VISIBLE false
		set_parameter_property tpdoNum VISIBLE false
	} elseif {$configPowerlink == "Direct I/O CN"} {
		#CN is only a Direct I/O CN, so there are only 4bytes I/Os
		if {$rpdos == 1} {
			set rpdo0size [expr 4 + 16]
			set rpdo1size 0
			set rpdo2size 0
			set macRxBuffers 4
		} elseif {$rpdos == 2} {
			set rpdo0size [expr 4 + 16]
			set rpdo1size [expr 4 + 16]
			set rpdo2size 0
			set macRxBuffers 5
		} elseif {$rpdos == 3} {
			set rpdo0size [expr 4 + 16]
			set rpdo1size [expr 4 + 16]
			set rpdo2size [expr 4 + 16]
			set macRxBuffers 6
		}
		#and fix tpdo size
		set tpdo0size 4
		
		set genSimpleIO true
		
		set_parameter_property validAssertDuration VISIBLE true
		set_parameter_property validSet VISIBLE true
		
	} elseif {$configPowerlink == "CN with Processor Interface"} {
		#CN is connected to AP processor, so enable everything for this
		set_parameter_property configApInterface VISIBLE true
		set_parameter_property asyncTxBufSize VISIBLE true
		set_parameter_property asyncRxBufSize VISIBLE true
		#AP can be big or little endian - allow choice
		set_parameter_property configApEndian VISIBLE true
		
		set genPdi true
		
		#set rpdo size to zero if not used
		if {$rpdos == 1} {
			set_parameter_property rpdo0size VISIBLE true
			set_parameter_property rpdo1size VISIBLE false
			set_parameter_property rpdo2size VISIBLE false
			set rpdo1size 0
			set rpdo2size 0
			set macRxBuffers 4
			set memRpdo [expr ($rpdo0size)*3]
		} elseif {$rpdos == 2} {
			set_parameter_property rpdo0size VISIBLE true
			set_parameter_property rpdo1size VISIBLE true
			set_parameter_property rpdo2size VISIBLE false
			set rpdo2size 0
			set macRxBuffers 5
			set memRpdo [expr ($rpdo0size + $rpdo1size)*3]
		} elseif {$rpdos == 3} {
			set_parameter_property rpdo0size VISIBLE true
			set_parameter_property rpdo1size VISIBLE true
			set_parameter_property rpdo2size VISIBLE true
			set macRxBuffers 6
			set memRpdo [expr ($rpdo0size + $rpdo1size + $rpdo2size )*3]
		}
		set_parameter_property tpdo0size VISIBLE true
		set memTpdo [expr ($tpdo0size)*3]
		
		if {$configApInterface == "Avalon"} {
			#avalon is used for the ap!
			set genAvalonAp true
			
		} elseif {$configApInterface == "Parallel"} {
			#the parallel interface is used
			
			set_parameter_property configApParallelInterface VISIBLE true
			set_parameter_property configApParSigs VISIBLE true
			set_parameter_property configApParOutSigs VISIBLE true
			
		} elseif {$configApInterface == "SPI"} {
			#let's use spi
			set_parameter_property configApSpi_CPOL VISIBLE true
			set_parameter_property configApSpi_CPHA VISIBLE true
			set_parameter_property configApSpi_IRQ VISIBLE true
			
			set genSpiAp true
			
		}
	}
	
	#calc tx packet size
	set IdRes 	[expr 176 				+ $crc + $macTxHd]
	set StRes 	[expr 72 				+ $crc + $macTxHd]
	set NmtReq 	[expr $ethHd + $mtu		+ $crc + $macTxHd]
	set nonEpl	[expr $ethHd + $mtu		+ $crc + $macTxHd]
	set PRes	[expr 24 + $tpdo0size	+ $crc + $macTxHd]
	#sync response for poll-resp-ch (44 bytes + padding = 60bytes)
	set SyncRes [expr 60				+ $crc + $macTxHd]
	
	#align all tx buffers
	set IdRes 	[expr ($IdRes + 3) & ~3]
	set StRes 	[expr ($StRes + 3) & ~3]
	set NmtReq 	[expr ($NmtReq + 3) & ~3]
	set nonEpl 	[expr ($nonEpl + 3) & ~3]
	set PRes 	[expr ($PRes + 3) & ~3]
	set SyncRes [expr ($SyncRes + 3) & ~3]
	
	#calculate tx buffer size out of tpdos and other packets
	set txBufSize [expr $IdRes + $StRes + $NmtReq + $nonEpl + $PRes + $SyncRes]
	set macTxBuffers 6
	
	#openPOWERLINK allocates TX buffers twice (ping-pong)
	set txBufSize [expr $txBufSize * 2]
	set macTxBuffers [expr $macTxBuffers * 2]
	
	#calculate rx buffer size out of packets per cycle
	set rxBufSize [expr $ethHd + $mtu + $crc + $macRxHd]
	set rxBufSize [expr ($rxBufSize + 3) & ~3]
	set rxBufSize [expr $macRxBuffers * $rxBufSize]
	
	if {$configPowerlink == "openMAC only"} {
		#overwrite done calulations
		set txBufSize $macTxBuf
		set rxBufSize $macRxBuf
		
		#set unsupported to zeros or allowed range
		set macTxBuffers 0
		set macRxBuffers 0
		set rpdos 0
		set tpdos 0
		set rpdo0size 0
		set rpdo1size 0
		set rpdo2size 0
		set tpdo0size 0
		set asyncTxBufSize 0
		set asyncRxBufSize 0
	}
	
	if {$ploc == "TX and RX into DPRAM"} {
		set macBufSize [expr $txBufSize + $rxBufSize]
		set log2MacBufSize [expr int(ceil(log($macBufSize) / log(2.)))]
	} elseif {$ploc == "TX into DPRAM and RX over Avalon Master" } {
		set macBufSize $txBufSize
		#no rx buffers are stored in dpram => set to zero
		set rxBufSize 0
		set log2MacBufSize [expr int(ceil(log($macBufSize) / log(2.)))]
		set macRxBuffers 16
	} elseif {$ploc == "TX and RX over Avalon Master"} {
		#any value to avoid errors in SOPC
		set macBufSize 0
		#no rx and tx buffers are stored in dpram => set to zero
		set rxBufSize 0
		set txBufSize 0
		set log2MacBufSize 3
	} else {
		set macBufSize 0
		set rxBufSize 0
		set txBufSize 0
		set log2MacBufSize 3
	}
	
	#set pdi generics
	set_parameter_value iRpdos_g			$rpdos
	set_parameter_value iTpdos_g			$tpdos
	set_parameter_value iTpdoBufSize_g		$tpdo0size
	set_parameter_value iRpdo0BufSize_g		$rpdo0size
	set_parameter_value iRpdo1BufSize_g		$rpdo1size
	set_parameter_value iRpdo2BufSize_g		$rpdo2size
	set_parameter_value iAsyTxBufSize_g		$asyncTxBufSize
	set_parameter_value iAsyRxBufSize_g		$asyncRxBufSize
	
#now, let's set generics to HDL
	set_parameter_value genPdi_g			$genPdi
	set_parameter_value genAvalonAp_g		$genAvalonAp
	set_parameter_value genSimpleIO_g		$genSimpleIO
	set_parameter_value genSpiAp_g			$genSpiAp
	
	set_parameter_value Simulate			false
	set_parameter_value iBufSize_g			$macBufSize
	set_parameter_value iBufSizeLOG2_g		$log2MacBufSize
	
	if {[get_parameter_value configApParallelInterface] == "8bit"} {
		set_parameter_value papDataWidth_g	8
	} else {
		set_parameter_value papDataWidth_g	16
	}
	if {[get_parameter_value configApEndian] == "Little"} {
		set_parameter_value papBigEnd_g	false
		set_parameter_value spiBigEnd_g	false
	} else {
		set_parameter_value papBigEnd_g	true
		set_parameter_value spiBigEnd_g	true
	}
	if {[get_parameter_value configApParSigs] == "Low Active"} {
		set_parameter_value papLowAct_g	true
	} else {
		set_parameter_value papLowAct_g	false
	}
	if {$spiCpol == "1"} {
		set_parameter_value spiCPOL_g true
	} else {
		set_parameter_value spiCPOL_g false
	}
	if {$spiCpha == "1"} {
		set_parameter_value spiCPHA_g true
	} else {
		set_parameter_value spiCPHA_g false
	}
	
	#forward parameters to system.h
	
	# workaround: strings are erroneous => no blanks, etc.
	if {$configPowerlink == "Direct I/O CN"} {
																	#direct I/O
		set_module_assignment embeddedsw.CMacro.CONFIG				0
	} elseif {$configPowerlink == "CN with Processor Interface"} {
		if {$configApInterface == "Avalon"} {
																	#Avalon
			set_module_assignment embeddedsw.CMacro.CONFIG			4
		} elseif {$configApInterface == "Parallel"} {
			if {[get_parameter_value configApParallelInterface] == "8bit"} {
																	#parallel 8bit
				set_module_assignment embeddedsw.CMacro.CONFIG		1
			} else {
																	#parallel 16bit
				set_module_assignment embeddedsw.CMacro.CONFIG		2
			}
		} else {
																	#SPI
			set_module_assignment embeddedsw.CMacro.CONFIG			3
		}
	} elseif {$configPowerlink == "openMAC only"} {
																	#openMAC only
		set_module_assignment embeddedsw.CMacro.CONFIG				5
	}
	
	if {[get_parameter_value configApEndian] == "Little"} {
																	#little endian
		set_module_assignment embeddedsw.CMacro.CONFIGAPENDIAN		0
	} else {
																	#big endian
		set_module_assignment embeddedsw.CMacro.CONFIGAPENDIAN		1
	}
	
	if {$ploc == "TX and RX into DPRAM"} {							#all packets stored in openMAC DPRAM
		set_module_assignment embeddedsw.CMacro.PKTLOC				0
	} elseif {$ploc == "TX into DPRAM and RX over Avalon Master"} {	#Rx packets stored in heap
		set_module_assignment embeddedsw.CMacro.PKTLOC				2
	} elseif {$ploc == "TX and RX over Avalon Master"} {			#all packets stored in heap
		set_module_assignment embeddedsw.CMacro.PKTLOC				1
	} else {
		send_message error "error 0x03"
	}
	
	set_module_assignment embeddedsw.CMacro.MACBUFSIZE				$macBufSize
	set_module_assignment embeddedsw.CMacro.MACRXBUFSIZE			$rxBufSize
	set_module_assignment embeddedsw.CMacro.MACRXBUFFERS			$macRxBuffers
	set_module_assignment embeddedsw.CMacro.MACTXBUFSIZE			$txBufSize
	set_module_assignment embeddedsw.CMacro.MACTXBUFFERS			$macTxBuffers
	set_module_assignment embeddedsw.CMacro.PDIRPDOS				$rpdos
	set_module_assignment embeddedsw.CMacro.PDITPDOS				$tpdos
}

#display
add_display_item "Block Diagram" id0 icon img/designs.png
add_display_item "General Settings" configPowerlink PARAMETER
add_display_item "Process Data Interface Settings" configApInterface PARAMETER
add_display_item "Process Data Interface Settings" configApParallelInterface PARAMETER
add_display_item "Process Data Interface Settings" configApParOutSigs PARAMETER
add_display_item "Process Data Interface Settings" configApParSigs PARAMETER
add_display_item "Process Data Interface Settings" configApSpi_IRQ PARAMETER
add_display_item "Process Data Interface Settings" configApEndian PARAMETER
add_display_item "Process Data Interface Settings" configApSpi_CPOL PARAMETER
add_display_item "Process Data Interface Settings" configApSpi_CPHA PARAMETER
add_display_item "Process Data Interface Settings" validSet PARAMETER
add_display_item "Process Data Interface Settings" validAssertDuration PARAMETER
add_display_item "Receive Process Data" rpdoNum PARAMETER
add_display_item "Transmit Process Data" tpdoNum PARAMETER
add_display_item "Transmit Process Data" tpdo0size PARAMETER
add_display_item "Receive Process Data" rpdo0size PARAMETER
add_display_item "Receive Process Data" rpdo1size PARAMETER
add_display_item "Receive Process Data" rpdo2size PARAMETER
add_display_item "Asynchronous Buffer" asyncTxBufSize  PARAMETER
add_display_item "Asynchronous Buffer" asyncRxBufSize  PARAMETER
add_display_item "openMAC" phyIF  PARAMETER
add_display_item "openMAC" macTxBuf  PARAMETER
add_display_item "openMAC" macRxBuf  PARAMETER
add_display_item "openMAC" packetLoc  PARAMETER

#INTERFACES

#Clock Sinks
##pcp clk
add_interface pcp_clk clock end
set_interface_property pcp_clk ENABLED true
add_interface_port pcp_clk clkPcp clk Input 1
add_interface_port pcp_clk rstPcp reset Input 1

##ap clk
add_interface ap_clk clock end
set_interface_property ap_clk ENABLED true
add_interface_port ap_clk clkAp clk Input 1
add_interface_port ap_clk rstAp reset Input 1

##clk Ethernet
add_interface clkEth clock end
set_interface_property clkEth ENABLED true
add_interface_port clkEth clkEth clk Input 1

##clk 50MHz
add_interface clk50meg clock end
set_interface_property clk50meg ENABLED true
add_interface_port clk50meg clk50 clk Input 1

#openMAC
##Avalon Memory Mapped Slave: Compare Unit 
add_interface MAC_CMP avalon end
set_interface_property MAC_CMP addressAlignment DYNAMIC
set_interface_property MAC_CMP associatedClock clk50meg
set_interface_property MAC_CMP burstOnBurstBoundariesOnly false
set_interface_property MAC_CMP explicitAddressSpan 0
set_interface_property MAC_CMP holdTime 0
set_interface_property MAC_CMP isMemoryDevice false
set_interface_property MAC_CMP isNonVolatileStorage false
set_interface_property MAC_CMP linewrapBursts false
set_interface_property MAC_CMP maximumPendingReadTransactions 0
set_interface_property MAC_CMP printableDevice false
set_interface_property MAC_CMP readLatency 0
set_interface_property MAC_CMP readWaitTime 1
set_interface_property MAC_CMP setupTime 0
set_interface_property MAC_CMP timingUnits Cycles
set_interface_property MAC_CMP writeWaitTime 0
set_interface_property MAC_CMP ENABLED true
add_interface_port MAC_CMP tcp_read_n read_n Input 1
add_interface_port MAC_CMP tcp_write_n write_n Input 1
add_interface_port MAC_CMP tcp_byteenable_n byteenable_n Input 4
add_interface_port MAC_CMP tcp_address address Input 2
add_interface_port MAC_CMP tcp_writedata writedata Input 32
add_interface_port MAC_CMP tcp_readdata readdata Output 32
add_interface_port MAC_CMP tcp_chipselect chipselect Input 1

##MAC COMPARE IRQ source
add_interface MACCMP_IRQ interrupt end
set_interface_property MACCMP_IRQ associatedAddressablePoint MAC_CMP
set_interface_property MACCMP_IRQ ASSOCIATED_CLOCK clk50meg
set_interface_property MACCMP_IRQ ENABLED true
add_interface_port MACCMP_IRQ tcp_irq irq Output 1

##Avalon Memory Mapped Slave: MAC_REG Register
add_interface MAC_REG avalon end
set_interface_property MAC_REG addressAlignment DYNAMIC
set_interface_property MAC_REG associatedClock clk50meg
set_interface_property MAC_REG burstOnBurstBoundariesOnly false
set_interface_property MAC_REG explicitAddressSpan 0
set_interface_property MAC_REG holdTime 0
set_interface_property MAC_REG isMemoryDevice false
set_interface_property MAC_REG isNonVolatileStorage false
set_interface_property MAC_REG linewrapBursts false
set_interface_property MAC_REG maximumPendingReadTransactions 0
set_interface_property MAC_REG printableDevice false
set_interface_property MAC_REG readLatency 0
set_interface_property MAC_REG readWaitTime 1
set_interface_property MAC_REG setupTime 0
set_interface_property MAC_REG timingUnits Cycles
set_interface_property MAC_REG writeWaitTime 0
set_interface_property MAC_REG ENABLED true
add_interface_port MAC_REG mac_chipselect chipselect Input 1
add_interface_port MAC_REG mac_read_n read_n Input 1
add_interface_port MAC_REG mac_write_n write_n Input 1
add_interface_port MAC_REG mac_byteenable_n byteenable_n Input 2
add_interface_port MAC_REG mac_address address Input 12
add_interface_port MAC_REG mac_writedata writedata Input 16
add_interface_port MAC_REG mac_readdata readdata Output 16

##MAC IRQ source
add_interface MAC_IRQ interrupt end
set_interface_property MAC_IRQ associatedAddressablePoint MAC_REG
set_interface_property MAC_IRQ ASSOCIATED_CLOCK clk50meg
set_interface_property MAC_IRQ ENABLED true
add_interface_port MAC_IRQ mac_irq irq Output 1

##Export Phy Management 0
add_interface PHYM0 conduit end
set_interface_property PHYM0 ENABLED true
add_interface_port PHYM0 phy0_SMIClk export Output 1
add_interface_port PHYM0 phy0_SMIDat export Bidir 1
add_interface_port PHYM0 phy0_Rst_n export Output 1

##Export Phy Management 1
add_interface PHYM1 conduit end
set_interface_property PHYM1 ENABLED true
add_interface_port PHYM1 phy1_SMIClk export Output 1
add_interface_port PHYM1 phy1_SMIDat export Bidir 1
add_interface_port PHYM1 phy1_Rst_n export Output 1

##Export Rmii Phy 0
add_interface RMII0 conduit end
set_interface_property RMII0 ENABLED true
add_interface_port RMII0 phy0_RxDat export Input 2
add_interface_port RMII0 phy0_RxDv export Input 1
add_interface_port RMII0 phy0_TxDat export Output 2
add_interface_port RMII0 phy0_TxEn export Output 1

##Export Rmii Phy 1
add_interface RMII1 conduit end
set_interface_property RMII1 ENABLED true
add_interface_port RMII1 phy1_RxDat export Input 2
add_interface_port RMII1 phy1_RxDv export Input 1
add_interface_port RMII1 phy1_TxDat export Output 2
add_interface_port RMII1 phy1_TxEn export Output 1

##Export Mii Phy 0
add_interface MII0 conduit end
set_interface_property MII0 ENABLED false
add_interface_port MII0 phyMii0_TxClk export Input 1
add_interface_port MII0 phyMii0_TxEn export Output 1
add_interface_port MII0 phyMii0_TxEr export Output 1
add_interface_port MII0 phyMii0_TxDat export Output 4
add_interface_port MII0 phyMii0_RxClk export Input 1
add_interface_port MII0 phyMii0_RxDv export Input 1
add_interface_port MII0 phyMii0_RxDat export Input 4

##Export Mii Phy 1
add_interface MII1 conduit end
set_interface_property MII1 ENABLED false
add_interface_port MII1 phyMii1_TxClk export Input 1
add_interface_port MII1 phyMii1_TxEn export Output 1
add_interface_port MII1 phyMii1_TxEr export Output 1
add_interface_port MII1 phyMii1_TxDat export Output 4
add_interface_port MII1 phyMii1_RxClk export Input 1
add_interface_port MII1 phyMii1_RxDv export Input 1
add_interface_port MII1 phyMii1_RxDat export Input 4

##Avalon Memory Mapped Slave: MAC_REG Buffer
add_interface MAC_BUF avalon end
set_interface_property MAC_BUF addressAlignment DYNAMIC
set_interface_property MAC_BUF associatedClock pcp_clk
set_interface_property MAC_BUF burstOnBurstBoundariesOnly false
set_interface_property MAC_BUF explicitAddressSpan 0
set_interface_property MAC_BUF holdTime 0
set_interface_property MAC_BUF isMemoryDevice false
set_interface_property MAC_BUF isNonVolatileStorage false
set_interface_property MAC_BUF linewrapBursts false
set_interface_property MAC_BUF maximumPendingReadTransactions 0
set_interface_property MAC_BUF printableDevice false
set_interface_property MAC_BUF readLatency 0
set_interface_property MAC_BUF readWaitStates 2
set_interface_property MAC_BUF readWaitTime 2
set_interface_property MAC_BUF setupTime 0
set_interface_property MAC_BUF timingUnits Cycles
set_interface_property MAC_BUF writeWaitTime 0
set_interface_property MAC_BUF ENABLED true
add_interface_port MAC_BUF mbf_chipselect chipselect Input 1
add_interface_port MAC_BUF mbf_read_n read_n Input 1
add_interface_port MAC_BUF mbf_write_n write_n Input 1
add_interface_port MAC_BUF mbf_byteenable byteenable Input 4
add_interface_port MAC_BUF mbf_address address Input "(iBufSizeLOG2_g-2)"
add_interface_port MAC_BUF mbf_writedata writedata Input 32
add_interface_port MAC_BUF mbf_readdata readdata Output 32

##Avalon Memory Mapped Master: MAC_DMA
add_interface MAC_DMA avalon start
set_interface_property MAC_DMA adaptsTo ""
set_interface_property MAC_DMA burstOnBurstBoundariesOnly false
set_interface_property MAC_DMA doStreamReads false
set_interface_property MAC_DMA doStreamWrites false
set_interface_property MAC_DMA linewrapBursts false
set_interface_property MAC_DMA ASSOCIATED_CLOCK clk50meg
set_interface_property MAC_DMA ENABLED false
add_interface_port MAC_DMA m_read_n read_n Output 1
add_interface_port MAC_DMA m_write_n write_n Output 1
add_interface_port MAC_DMA m_byteenable_n byteenable_n Output 2
add_interface_port MAC_DMA m_address address Output 30
add_interface_port MAC_DMA m_writedata writedata Output 16
add_interface_port MAC_DMA m_readdata readdata Input 16
add_interface_port MAC_DMA m_waitrequest waitrequest Input 1
add_interface_port MAC_DMA m_arbiterlock arbiterlock Output 1

#PDI
##Avalon Memory Mapped Slave: PCP
add_interface PDI_PCP avalon end
set_interface_property PDI_PCP addressAlignment DYNAMIC
set_interface_property PDI_PCP associatedClock pcp_clk
set_interface_property PDI_PCP burstOnBurstBoundariesOnly false
set_interface_property PDI_PCP explicitAddressSpan 0
set_interface_property PDI_PCP holdTime 0
set_interface_property PDI_PCP isMemoryDevice false
set_interface_property PDI_PCP isNonVolatileStorage false
set_interface_property PDI_PCP linewrapBursts false
set_interface_property PDI_PCP maximumPendingReadTransactions 0
set_interface_property PDI_PCP printableDevice false
set_interface_property PDI_PCP readLatency 0
set_interface_property PDI_PCP readWaitStates 2
set_interface_property PDI_PCP readWaitTime 2
set_interface_property PDI_PCP setupTime 0
set_interface_property PDI_PCP timingUnits Cycles
set_interface_property PDI_PCP writeWaitTime 0
set_interface_property PDI_PCP ENABLED true
add_interface_port PDI_PCP pcp_chipselect chipselect Input 1
add_interface_port PDI_PCP pcp_read read Input 1
add_interface_port PDI_PCP pcp_write write Input 1
add_interface_port PDI_PCP pcp_byteenable byteenable Input 4
add_interface_port PDI_PCP pcp_address address Input 13
add_interface_port PDI_PCP pcp_writedata writedata Input 32
add_interface_port PDI_PCP pcp_readdata readdata Output 32

##Avalon Memory Mapped Slave: AP
add_interface PDI_AP avalon end
set_interface_property PDI_AP addressAlignment DYNAMIC
set_interface_property PDI_AP associatedClock ap_clk
set_interface_property PDI_AP burstOnBurstBoundariesOnly false
set_interface_property PDI_AP explicitAddressSpan 0
set_interface_property PDI_AP holdTime 0
set_interface_property PDI_AP isMemoryDevice false
set_interface_property PDI_AP isNonVolatileStorage false
set_interface_property PDI_AP linewrapBursts false
set_interface_property PDI_AP maximumPendingReadTransactions 0
set_interface_property PDI_AP printableDevice false
set_interface_property PDI_AP readLatency 0
set_interface_property PDI_AP readWaitStates 2
set_interface_property PDI_AP readWaitTime 2
set_interface_property PDI_AP setupTime 0
set_interface_property PDI_AP timingUnits Cycles
set_interface_property PDI_AP writeWaitTime 0
set_interface_property PDI_AP ENABLED true
add_interface_port PDI_AP ap_chipselect chipselect Input 1
add_interface_port PDI_AP ap_read read Input 1
add_interface_port PDI_AP ap_write write Input 1
add_interface_port PDI_AP ap_byteenable byteenable Input 4
add_interface_port PDI_AP ap_address address Input 13
add_interface_port PDI_AP ap_writedata writedata Input 32
add_interface_port PDI_AP ap_readdata readdata Output 32

###PDI AP IRQ source
add_interface PDI_AP_IRQ interrupt end
set_interface_property PDI_AP_IRQ associatedAddressablePoint PDI_AP
set_interface_property PDI_AP_IRQ ASSOCIATED_CLOCK clk50meg
set_interface_property PDI_AP_IRQ ENABLED true
add_interface_port PDI_AP_IRQ ap_irq irq Output 1

##AP external IRQ
add_interface AP_EX_IRQ conduit end
set_interface_property AP_EX_IRQ ENABLED false
add_interface_port AP_EX_IRQ ap_irq export Output 1
add_interface_port AP_EX_IRQ ap_irq_n export Output 1

##SPI AP export
add_interface SPI_AP conduit end
set_interface_property SPI_AP ENABLED false
add_interface_port SPI_AP spi_clk export Input 1
add_interface_port SPI_AP spi_sel_n export Input 1
add_interface_port SPI_AP spi_mosi export Input 1
add_interface_port SPI_AP spi_miso export Output 1

##Parallel AP Interface export
add_interface PAR_AP conduit end
set_interface_property PAR_AP ENABLED false
###control signals
add_interface_port PAR_AP pap_cs export Input 1
add_interface_port PAR_AP pap_rd export Input 1
add_interface_port PAR_AP pap_wr export Input 1
add_interface_port PAR_AP pap_be export Input papDataWidth_g/8
add_interface_port PAR_AP pap_cs_n export Input 1
add_interface_port PAR_AP pap_rd_n export Input 1
add_interface_port PAR_AP pap_wr_n export Input 1
add_interface_port PAR_AP pap_be_n export Input papDataWidth_g/8
###bus
add_interface_port PAR_AP pap_addr export Input 16
add_interface_port PAR_AP pap_data export Bidir papDataWidth_g
###ready
add_interface_port PAR_AP pap_ready export Output 1
add_interface_port PAR_AP pap_ready_n export Output 1
###GPIO
add_interface_port PAR_AP pap_gpio export Bidir 2

#Simple I/O
##Avalon Memory Mapped Slave: SMP
add_interface SMP avalon end
set_interface_property SMP addressAlignment DYNAMIC
set_interface_property SMP associatedClock pcp_clk
set_interface_property SMP burstOnBurstBoundariesOnly false
set_interface_property SMP explicitAddressSpan 0
set_interface_property SMP holdTime 0
set_interface_property SMP isMemoryDevice false
set_interface_property SMP isNonVolatileStorage false
set_interface_property SMP linewrapBursts false
set_interface_property SMP maximumPendingReadTransactions 0
set_interface_property SMP printableDevice false
set_interface_property SMP readLatency 0
set_interface_property SMP readWaitTime 1
set_interface_property SMP setupTime 0
set_interface_property SMP timingUnits Cycles
set_interface_property SMP writeWaitTime 0
set_interface_property SMP ENABLED false
add_interface_port SMP smp_address address Input 1
add_interface_port SMP smp_read read Input 1
add_interface_port SMP smp_readdata readdata Output 32
add_interface_port SMP smp_write write Input 1
add_interface_port SMP smp_writedata writedata Input 32
add_interface_port SMP smp_byteenable byteenable Input 4

##Portio export
add_interface SMP_PIO conduit end
set_interface_property SMP_PIO ENABLED false
add_interface_port SMP_PIO pio_pconfig export Input 4
add_interface_port SMP_PIO pio_portInLatch export Input 4
add_interface_port SMP_PIO pio_portOutValid export Output 4
add_interface_port SMP_PIO pio_portio export Bidir 32
add_interface_port SMP_PIO pio_operational export Output 1

proc my_elaboration_callback {} {
#get system info...
set EthernetClkRate [get_parameter_value clkRateEth]
set ClkRate50meg [get_parameter_value clkRate50]

#valid set
set ClkPcp [get_parameter_value clkRatePcp]
if {$ClkPcp == 0} {
	# avoid 1 / zero!
	set ClkPcp 1
}
set ClkPcpPeriod [expr 1. / $ClkPcp * 1000 * 1000 * 1000]
set validTicks [get_parameter_value validSet]
if {$validTicks <= 0} {
	set validTicks 1
}
set validLength [expr $validTicks * $ClkPcpPeriod]

set_parameter_value validAssertDuration $validLength
set_parameter_value pioValLen_g $validTicks

if {$ClkRate50meg == 50000000} {

} else {
	send_message error "MAC_CMP and MAC_REG must be connected to 50MHz Clock!"
}

#find out, which interfaces (avalon, exports, etc) are not necessary for the configurated device!
	#set defaults
	set_interface_property ap_clk ENABLED false
	set_interface_property PDI_PCP ENABLED false
	set_interface_property PDI_AP ENABLED false
	set_interface_property PDI_AP_IRQ ENABLED false
	set_interface_property SPI_AP ENABLED false
	set_interface_property PAR_AP ENABLED false
	set_interface_property SMP ENABLED false
	set_interface_property SMP_PIO ENABLED false
	set_interface_property AP_EX_IRQ ENABLED false
	
	set_interface_property MAC_DMA ENABLED false
	set_interface_property MAC_BUF ENABLED false
	
	#verify which packet location is set and disable/enable dma/dpr
	if {[get_parameter_value packetLoc] == "TX and RX into DPRAM"} {
		#use internal packet buffering
		set_interface_property MAC_BUF ENABLED true
	} elseif {[get_parameter_value packetLoc] == "TX into DPRAM and RX over Avalon Master"} {
		#use internal packet buffering
		set_interface_property MAC_BUF ENABLED true
		#use DMA for Rx packets
		set_interface_property MAC_DMA ENABLED true
	} elseif {[get_parameter_value packetLoc] == "TX and RX over Avalon Master"} {
		#use external packet buffering
		set_interface_property MAC_DMA ENABLED true
	} else {
		send_message error "error 0x04"
	}
	
	if {[get_parameter_value useRmii_g]} {
		set_interface_property RMII0 ENABLED true
		set_interface_property RMII1 ENABLED true
		set_interface_property MII0 ENABLED false
		set_interface_property MII1 ENABLED false
		set_interface_property clkEth ENABLED true
		if {$EthernetClkRate == 100000000} {
		
		} else {
			send_message error "Clock Source of 100MHz required!"
		}
	} else {
		set_interface_property RMII0 ENABLED false
		set_interface_property RMII1 ENABLED false
		set_interface_property MII0 ENABLED true
		set_interface_property MII1 ENABLED true
		set_interface_property clkEth ENABLED false
	}
	
	if {[get_parameter_value configPowerlink] == "openMAC only"} {
		if {[get_parameter_value packetLoc] == "TX and RX into DPRAM"} {
			#pcp_clk necessary!
		} elseif {[get_parameter_value packetLoc] == "TX into DPRAM and RX over Avalon Master"} {
			#pcp_clk necessary!
		} elseif {[get_parameter_value packetLoc] == "TX and RX over Avalon Master"} {
			#pcp_clk not necessary!
			set_interface_property pcp_clk ENABLED false
		} else {
			send_message error "error 0x05"
		}
	} elseif {[get_parameter_value configPowerlink] == "Direct I/O CN"} {
		#the Direct I/O CN requires:
		# MAC stuff
		# portio export
		# Avalon SMP
		set_interface_property SMP ENABLED true
		set_interface_property SMP_PIO ENABLED true
	} else {
		#CN with Processor Interface requires:
		# MAC stuff
		# PDI_PCP
		set_interface_property PDI_PCP ENABLED true
		if {[get_parameter_value configApInterface] == "Avalon"} {
		# AP as Avalon (PDI_AP)
			set_interface_property PDI_AP ENABLED true
			set_interface_property PDI_AP_IRQ ENABLED true
			set_interface_property ap_clk ENABLED true
			
		} elseif {[get_parameter_value configApInterface] == "Parallel"} {
		# AP is external (PAR_AP)
			set_interface_property PAR_AP ENABLED true
			set_interface_property AP_EX_IRQ ENABLED true
			if {[get_parameter_value papDataWidth_g] == 8} {
				#we don't need byteenable for 8bit data bus width!
				set_port_property pap_be termination true
			}
			if {[get_parameter_value configApParOutSigs] == "Low Active"} {
				#low active output signals (ap_irq_n and pap_ready_n) are used
				set_port_property pap_ready termination true
				set_port_property ap_irq termination true
			} else {
				#high active output signals (ap_irq and pap_ready) are used
				set_port_property pap_ready_n termination true
				set_port_property ap_irq_n termination true
			}
			if {[get_parameter_value configApParSigs] == "Low Active"} {
				#low active input signals (pap_cs_n, pap_rd_n, pap_wr_n and pap_be_n) are used
				set_port_property pap_cs termination true
				set_port_property pap_rd termination true
				set_port_property pap_wr termination true
				set_port_property pap_be termination true
			} else {
				#high active input signals (pap_cs, pap_rd, pap_wr and pap_be) are used
				set_port_property pap_cs_n termination true
				set_port_property pap_rd_n termination true
				set_port_property pap_wr_n termination true
				set_port_property pap_be_n termination true
			}
		} elseif {[get_parameter_value configApInterface] == "SPI"} {
		# AP is external via SPI (SPI_AP)
			set_interface_property SPI_AP ENABLED true
			set_interface_property AP_EX_IRQ ENABLED true
			if {[get_parameter_value configApSpi_IRQ] == "Low Active"} {
				#low active output signal (irq_n) is used
				set_port_property ap_irq termination true
			} else {
				#high active output signal (irq) is used
				set_port_property ap_irq_n termination true
			}
		}
	}
}
