# -----------------------------------------------------------------------------
# openmac_hw.tcl
# -----------------------------------------------------------------------------
#
#    (c) B&R, 2013
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions
#    are met:
#
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#    3. Neither the name of B&R nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without prior written permission. For written
#       permission, please contact office@br-automation.com
#
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.
#
# -----------------------------------------------------------------------------

package require -exact sopc 10.1

# -----------------------------------------------------------------------------
# module
# -----------------------------------------------------------------------------
set_module_property NAME openmac
set_module_property VERSION 1.0.0
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property AUTHOR "B&R"
set_module_property DISPLAY_NAME "openMAC"
set_module_property TOP_LEVEL_HDL_FILE "../../altera/openmac/src/alteraOpenmacTop-rtl-ea.vhd"
set_module_property TOP_LEVEL_HDL_MODULE alteraOpenmacTop
set_module_property INSTANTIATE_IN_SYSTEM_MODULE TRUE
set_module_property EDITABLE false
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property ANALYZE_HDL FALSE
set_module_property ICON_PATH "img/br.png"

# -----------------------------------------------------------------------------
# file sets
# -----------------------------------------------------------------------------
#TODO: add_file "../../altera/components/sdc/openmac.sdc" {SYNTHESIS}
add_file "../../common/lib/src/global.vhd"                      {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/addrDecodeRtl.vhd"               {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/cntRtl.vhd"                      {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/dpRam-e.vhd"                     {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/dpRamSplx-e.vhd"                 {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/edgedetectorRtl.vhd"             {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/synchronizerRtl.vhd"             {SYNTHESIS SIMULATION}
add_file "../../common/lib/src/syncTog-rtl-ea.vhd"              {SYNTHESIS SIMULATION}
add_file "../../common/fifo/src/asyncFifo-e.vhd"                {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openmacPkg-p.vhd"            {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/dma_handler.vhd"             {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/master_handler.vhd"          {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openMAC_DMAmaster.vhd"       {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openfilter-rtl-ea.vhd"       {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openhub-rtl-ea.vhd"          {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openmacTimer-rtl-ea.vhd"     {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/phyActGen-rtl-ea.vhd"        {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/phyMgmt-rtl-ea.vhd"          {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/convRmiiToMii-rtl-ea.vhd"    {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openMAC.vhd"                 {SYNTHESIS SIMULATION}
add_file "../../common/openmac/src/openmacTop-rtl-ea.vhd"       {SYNTHESIS SIMULATION}
add_file "../../altera/lib/src/dpRam-rtl-a.vhd"                 {SYNTHESIS SIMULATION}
add_file "../../altera/lib/src/dpRamSplx-rtl-a.vhd"             {SYNTHESIS SIMULATION}
add_file "../../altera/fifo/src/asyncFifo-syn-a.vhd"            {SYNTHESIS SIMULATION}
add_file "../../altera/openmac/src/alteraOpenmacTop-rtl-ea.vhd" {SYNTHESIS SIMULATION}

source "../../altera/components/tcl/global.tcl"

# -----------------------------------------------------------------------------
# VHDL parameters
# -----------------------------------------------------------------------------
set hdlParamVisible FALSE

global_addHdlParam  gPhyPortCount           NATURAL 2           $hdlParamVisible
global_addHdlParam  gPhyPortType            NATURAL 1           $hdlParamVisible
global_addHdlParam  gSmiPortCount           NATURAL 1           $hdlParamVisible
global_addHdlParam  gEndianness             STRING  "little"    $hdlParamVisible
global_addHdlParam  gEnableActivity         NATURAL 0           $hdlParamVisible
global_addHdlParam  gEnableDmaObserver      NATURAL 0           $hdlParamVisible
global_addHdlParam  gDmaAddrWidth           NATURAL 32          $hdlParamVisible
global_addHdlParam  gDmaDataWidth           NATURAL 16          $hdlParamVisible
global_addHdlParam  gDmaBurstCountWidth     NATURAL 4           $hdlParamVisible
global_addHdlParam  gDmaWriteBurstLength    NATURAL 16          $hdlParamVisible
global_addHdlParam  gDmaReadBurstLength     NATURAL 16          $hdlParamVisible
global_addHdlParam  gDmaWriteFifoLength     NATURAL 16          $hdlParamVisible
global_addHdlParam  gDmaReadFifoLength      NATURAL 16          $hdlParamVisible
global_addHdlParam  gPacketBufferLocTx      NATURAL 1           $hdlParamVisible
global_addHdlParam  gPacketBufferLocRx      NATURAL 1           $hdlParamVisible
global_addHdlParam  gPacketBufferLog2Size   NATURAL 10          $hdlParamVisible
global_addHdlParam  gTimerCount             NATURAL 2           $hdlParamVisible
global_addHdlParam  gTimerEnablePulseWidth  NATURAL 0           $hdlParamVisible
global_addHdlParam  gTimerPulseRegWidth     NATURAL 10          $hdlParamVisible

# -----------------------------------------------------------------------------
# System Info parameters
# -----------------------------------------------------------------------------
set sysParamVisible FALSE

global_addSysParam sys_mainClk      INTEGER 0   {CLOCK_RATE mainClk}    $sysParamVisible
global_addSysParam sys_mainClkx2    INTEGER 0   {CLOCK_RATE mainClkx2}  $sysParamVisible
global_addSysParam sys_dmaAddrWidth INTEGER 0   {ADDRESS_WIDTH dma}     $sysParamVisible

# -----------------------------------------------------------------------------
# GUI parameters
# -----------------------------------------------------------------------------
# Constant for enums (borrowed from global.vhd)
set cFalse          0
set cTrue           1

# Constants for enums (borrowed from openmacPkg-p.vhd)
set cPktBufLocal    1
set cPktBufExtern   2
set cPhyPortRmii    1
set cPhyPortMii     2

global_addGuiParam  gui_phyType     NATURAL 1       "Phy(s) interface type"             ""          "${cPhyPortRmii}:RMII ${cPhyPortMii}:MII"
global_addGuiParam  gui_phyCount    NATURAL 1       "Number of Phys"                    ""          "1:15"
global_addGuiParam  gui_extraSmi    BOOLEAN FALSE   "Extra SMI ports"                   ""          ""
global_addGuiParam  gui_txBufLoc    NATURAL 1       "Tx Buffer Location"                ""          "${cPktBufLocal}:Local ${cPktBufExtern}:External"
global_addGuiParam  gui_txBufSize   NATURAL 1       "Tx Buffer Size"                    Kilobytes   "1:32"
global_addGuiParam  gui_txBurstSize NATURAL 1       "Tx Dma Burst Size"                 Words       "1 4 8 16 32 64"
global_addGuiParam  gui_rxBufLoc    NATURAL 1       "Rx Buffer Location"                ""          "${cPktBufLocal}:Local ${cPktBufExtern}:External"
global_addGuiParam  gui_rxBufSize   NATURAL 1       "Rx Buffer Size"                    Kilobytes   "1:32"
global_addGuiParam  gui_rxBurstSize NATURAL 1       "Rx Dma Burst Size"                 Words       "1 4 8 16 32 64"
global_addGuiParam  gui_tmrCount    NATURAL 1       "Number of Hardware Timers"         ""          "1:2"
global_addGuiParam  gui_tmrPulsEn   BOOLEAN FALSE   "Timer Pulse Width Control"         ""          ""
global_addGuiParam  gui_tmrPulseWdt NATURAL 10      "Timer Pulse Width register width"  ""          "1:31"
global_addGuiParam  gui_actEn       BOOLEAN FALSE   "Packet activity LED"               ""          ""

# -----------------------------------------------------------------------------
# GUI configuration
# -----------------------------------------------------------------------------
set gui_namePhyInt      "Phy Interface"
set gui_namePktBuf      "Packet Buffer"
set gui_nameTimer       "Timer"
set gui_nameOthers      "Others"

add_display_item        $gui_namePhyInt gui_phyType     PARAMETER
add_display_item        $gui_namePhyInt gui_phyCount    PARAMETER
add_display_item        $gui_namePhyInt gui_extraSmi    PARAMETER

add_display_item        $gui_namePktBuf gui_txBufLoc    PARAMETER
add_display_item        $gui_namePktBuf gui_txBufSize   PARAMETER
add_display_item        $gui_namePktBuf gui_txBurstSize PARAMETER
add_display_item        $gui_namePktBuf gui_rxBufLoc    PARAMETER
add_display_item        $gui_namePktBuf gui_rxBufSize   PARAMETER
add_display_item        $gui_namePktBuf gui_rxBurstSize PARAMETER

add_display_item        $gui_nameTimer  gui_tmrCount    PARAMETER
add_display_item        $gui_nameTimer  gui_tmrPulsEn   PARAMETER
add_display_item        $gui_nameTimer  gui_tmrPulseWdt PARAMETER

add_display_item        $gui_nameOthers gui_actEn       PARAMETER

# -----------------------------------------------------------------------------
# callbacks
# -----------------------------------------------------------------------------
proc validation_callback {} {
    controlGui
    checkGui
}

proc elaboration_callback {} {
    # Check clock rate (mainClk = 50 MHz and mainClkx2 = 100 MHz)
    set lst_clkRateParam    "sys_mainClk sys_mainClkx2"
    set lst_clkRateRate     "50e6 100e6"
    set ret [checkClkRate $lst_clkRateParam $lst_clkRateRate]
    if { $ret != "" } {
        send_message error "Clock $ret is connected to wrong clock rate!"
    }

    # Generate ports depending on GUI parameters.
    generatePktBuf
    generateDma
    generateRmii
    generateMii
    generateMisc

    # Set CMacro and Hdl generics
    setCmacro
    setHdl
}

# -----------------------------------------------------------------------------
# internal functions
# -----------------------------------------------------------------------------

# Controls the GUI visibility
proc controlGui {} {
    set phyCount    [get_parameter_value gui_phyCount]
    set txBufLoc    [get_parameter_value gui_txBufLoc]
    set rxBufLoc    [get_parameter_value gui_rxBufLoc]
    set tmrPulsEn   [get_parameter_value gui_tmrPulsEn]

    # If only one phy is used no extra SMI port necessary.
    if { ${phyCount} > 1 } {
        set_parameter_property gui_extraSmi VISIBLE TRUE
    } else {
        set_parameter_property gui_extraSmi VISIBLE FALSE
    }

    # Tx buffer location set to local enables size settings, but disables burst size.
    if { ${txBufLoc} == ${::cPktBufLocal} } {
        set_parameter_property gui_txBufSize    VISIBLE TRUE
        set_parameter_property gui_txBurstSize  VISIBLE FALSE
    } else {
        set_parameter_property gui_txBufSize    VISIBLE FALSE
        set_parameter_property gui_txBurstSize  VISIBLE TRUE
    }

    # Rx buffer location set to local enables size settings, but disables burst size.
    if { ${rxBufLoc} == ${::cPktBufLocal} } {
        set_parameter_property gui_rxBufSize    VISIBLE TRUE
        set_parameter_property gui_rxBurstSize  VISIBLE FALSE
    } else {
        set_parameter_property gui_rxBufSize    VISIBLE FALSE
        set_parameter_property gui_rxBurstSize  VISIBLE TRUE
    }

    # Enable timer pulse settings
    if { ${tmrPulsEn} } {
        set_parameter_property gui_tmrPulseWdt VISIBLE TRUE
    } else {
        set_parameter_property gui_tmrPulseWdt VISIBLE FALSE
    }
}

# Check GUI parameters set by user.
proc checkGui {} {
    # Get parameters and set to local variables...
    set phyType     [get_parameter_value gui_phyType]
    set txBufLoc    [get_parameter_value gui_txBufLoc]
    set rxBufLoc    [get_parameter_value gui_rxBufLoc]
    set tmrCount    [get_parameter_value gui_tmrCount]
    set tmrPulsEn   [get_parameter_value gui_tmrPulsEn]

    # Set warning if no RMII is used!
    if { ${phyType} != ${::cPhyPortRmii} } {
        send_message info "Consider to use RMII to reduce resource usage!"
    }

    # External packet buffer location requires connection to heap memory.
    if { [getDmaUsed] } {
        send_message info "Connect the Avalon Master 'dma' to the memory where Heap is located!"
    }

    # Timer pulse enable needs more than one timer!
    if { ${tmrCount} < 2 && ${tmrPulsEn} } {
        set tmrCountDisplay     [get_parameter_property gui_tmrCount DISPLAY_NAME]
        set tmrPulsEnDisplay    [get_parameter_property gui_tmrPulsEn DISPLAY_NAME]
        send_message error "If you enable \"${tmrPulsEnDisplay}\", the value \"${tmrCountDisplay}\" must be larger 2!"
    }
}

# Check clock rate system info parameters. Returns the parameter which fails.
proc checkClkRate { lstParam lstRate } {
    foreach param $lstParam rate $lstRate {
        if { [get_parameter_value $param] != $rate } {
            return $param
        }
    }

    return ""
}

# Generate packet buffer slave interface.
# -> Clock:     pktClk
# -> Reset:     pktRst
# -> MM Slave:  pktBuf
proc generatePktBuf {} {
    if { [getPktBufUsed] } {
        set_interface_property pktClk ENABLED TRUE
        set_interface_property pktRst ENABLED TRUE
        set_interface_property pktBuf ENABLED TRUE
    } else {
        set_interface_property pktClk ENABLED FALSE
        set_interface_property pktRst ENABLED FALSE
        set_interface_property pktBuf ENABLED FALSE
    }
}

# Generate dma master interface.
# -> Clock:     dmaClk
# -> Reset:     dmaRst
# -> MM Master: dma
proc generateDma {} {
    set txBufLoc    [get_parameter_value gui_txBufLoc]
    set rxBufLoc    [get_parameter_value gui_rxBufLoc]

    if { [getDmaUsed] } {
        # Enable DMA
        set_interface_property dma ENABLED TRUE
        set_interface_property dma ENABLED TRUE
        set_interface_property dma ENABLED TRUE

        # Terminate burstcount if no bursts are used
        if { [getBurstUsed] } {
            set_port_property avm_dma_burstcount termination FALSE
        } else {
            set_port_property avm_dma_burstcount termination TRUE
        }

        # Terminate read path if Tx buffer are not external
        if { ${txBufLoc} == ${::cPktBufExtern} } {
            set_port_property avm_dma_read          termination FALSE
            set_port_property avm_dma_readdata      termination FALSE
            set_port_property avm_dma_readdatavalid termination FALSE
        } else {
            set_port_property avm_dma_read          termination TRUE
            set_port_property avm_dma_readdata      termination TRUE
            set_port_property avm_dma_readdatavalid termination TRUE
        }

        # Terminate read path if Rx buffer are not external
        if { ${rxBufLoc} == ${::cPktBufExtern} } {
            set_port_property avm_dma_write         termination FALSE
            set_port_property avm_dma_writedata     termination FALSE
        } else {
            set_port_property avm_dma_write         termination TRUE
            set_port_property avm_dma_writedata     termination TRUE
        }
    } else {
        set_interface_property dma ENABLED FALSE
        set_interface_property dma ENABLED FALSE
        set_interface_property dma ENABLED FALSE
    }
}

# Generate RMII coe.
proc generateRmii {} {
    set phyType     [get_parameter_value gui_phyType]

    if { ${phyType} == ${::cPhyPortRmii} } {
        set_interface_property rmii ENABLED TRUE
    } else {
        set_interface_property rmii ENABLED FALSE
    }
}

# Generate MII coe.
proc generateMii {} {
    set phyType     [get_parameter_value gui_phyType]

    if { ${phyType} == ${::cPhyPortMii} } {
        set_interface_property mii ENABLED TRUE
    } else {
        set_interface_property mii ENABLED FALSE
    }
}

# Generate coe.
proc generateMisc {} {
    set actEn       [get_parameter_value gui_actEn]

    if { ${actEn} } {
        set_interface_property pktActivity ENABLED TRUE
    } else {
        set_interface_property pktActivity ENABLED FALSE
    }
}

# Set component's Cmacros.
proc setCmacro {} {
    set phyType     [get_parameter_value gui_phyType]
    set phyCount    [get_parameter_value gui_phyCount]
    set extraSmi    [get_parameter_value gui_extraSmi]
    set txBufLoc    [get_parameter_value gui_txBufLoc]
    set txBufSize   [get_parameter_value gui_txBufSize]
    set rxBufLoc    [get_parameter_value gui_rxBufLoc]
    set rxBufSize   [get_parameter_value gui_rxBufSize]
    set tmrCount    [get_parameter_value gui_tmrCount]
    set tmrPulsEn   [get_parameter_value gui_tmrPulsEn]
    set tmrPulseWdt [get_parameter_value gui_tmrPulseWdt]
    set actEn       [get_parameter_value gui_actEn]

    # Phy count
    set_module_assignment embeddedsw.CMacro.PHYCNT           ${phyCount}

    # DMA observer
    set_module_assignment embeddedsw.CMacro.DMAOBSERV           [getDmaUsed]

    # Packet buffer location Tx
    set_module_assignment embeddedsw.CMacro.PKTLOCTX            ${txBufLoc}

    # Packet buffer location Rx
    set_module_assignment embeddedsw.CMacro.PKTLOCRX            ${rxBufLoc}

    set_module_assignment embeddedsw.CMacro.PKTBUFSIZE          [getPktBufSize]

    # Timer count
    set_module_assignment embeddedsw.CMacro.TIMERCNT            ${tmrCount}

    # Timer pulse enabled
    set_module_assignment embeddedsw.CMacro.TIMERPULSE          ${tmrPulsEn}

    # Timer pulse width
    set_module_assignment embeddedsw.CMacro.TIMERPULSEREGWIDTH  ${tmrPulseWdt}
}

# Set component's Hdl generics.
proc setHdl {} {
    # GUI
    set phyType             [get_parameter_value gui_phyType]
    set phyCount            [get_parameter_value gui_phyCount]
    set extraSmi            [get_parameter_value gui_extraSmi]
    set txBufLoc            [get_parameter_value gui_txBufLoc]
    set txBufSize           [get_parameter_value gui_txBufSize]
    set txBurstSize         [get_parameter_value gui_txBurstSize]
    set rxBufLoc            [get_parameter_value gui_rxBufLoc]
    set rxBufSize           [get_parameter_value gui_rxBufSize]
    set rxBurstSize         [get_parameter_value gui_rxBurstSize]
    set tmrCount            [get_parameter_value gui_tmrCount]
    set tmrPulsEn           [get_parameter_value gui_tmrPulsEn]
    set tmrPulseWdt         [get_parameter_value gui_tmrPulseWdt]
    set actEn               [get_parameter_value gui_actEn]

    set_parameter_value gPhyPortCount           ${phyCount}
    set_parameter_value gPhyPortType            ${phyType}

    # Check if extra SMI is enabled...
    if { ${extraSmi} } {
        set smiCount ${phyCount}
    } else {
        set smiCount 1
    }
    set_parameter_value gSmiPortCount           ${smiCount}

    set_parameter_value gEndianness             "little"

    # Check if activity is enabled
    if { ${actEn} } {
        set enableActivity ${::cTrue}
    } else {
        set enableActivity ${::cFalse}
    }
    set_parameter_value gEnableActivity         ${enableActivity}

    # Check if location is external
    if { [getDmaUsed] } {
        set enableDmaObserver ${::cTrue}
    } else {
        set enableDmaObserver ${::cFalse}
    }
    set_parameter_value gEnableDmaObserver      ${enableDmaObserver}

    set_parameter_value gDmaAddrWidth           [getDmaAddrWidth]

    set_parameter_value gDmaDataWidth           [getDmaDataWidth]

    set_parameter_value gDmaBurstCountWidth     [getBurstCountWidth]
    set_parameter_value gDmaWriteBurstLength    ${rxBurstSize}
    set_parameter_value gDmaReadBurstLength     ${txBurstSize}

    # Find fifo size
    set_parameter_value gDmaWriteFifoLength     [getFifoLength ${rxBurstSize} ]
    set_parameter_value gDmaReadFifoLength      [getFifoLength ${txBurstSize} ]

    # Packet buffer location
    set_parameter_value gPacketBufferLocTx      ${txBufLoc}
    set_parameter_value gPacketBufferLocRx      ${rxBufLoc}

    # Log2 of packet buffer size (= PktBuf Address width!)
    set_parameter_value gPacketBufferLog2Size   [getPktBufSizeLog2]

    # Timer configuration
    set_parameter_value gTimerCount             ${tmrCount}
    set_parameter_value gTimerEnablePulseWidth  ${tmrPulsEn}
    set_parameter_value gTimerPulseRegWidth     ${tmrPulseWdt}

    ############
    # Debug: Print out all generics
    set hdlPara [get_parameters]

    foreach name $hdlPara {
        set val [get_parameter_value $name]
        send_message info "$name = $val"
    }
}

# Returns TRUE if DMA is used (any location is external).
proc getDmaUsed {} {
    set txBufLoc            [get_parameter_value gui_txBufLoc]
    set rxBufLoc            [get_parameter_value gui_rxBufLoc]

    if { ${txBufLoc} == ${::cPktBufExtern} || ${rxBufLoc} == ${::cPktBufExtern} } {
        return TRUE
    } else {
        return FALSE
    }
}

# Returns TRUE if packet buffer is used (any location is local).
proc getPktBufUsed {} {
    set txBufLoc            [get_parameter_value gui_txBufLoc]
    set rxBufLoc            [get_parameter_value gui_rxBufLoc]

    if { ${txBufLoc} == ${::cPktBufLocal} || ${rxBufLoc} == ${::cPktBufLocal} } {
        return TRUE
    } else {
        return FALSE
    }
}

# Returns the local packet buffer size. If no local buffers are used, returns 0.
proc getPktBufSize {} {
    set txBufLoc            [get_parameter_value gui_txBufLoc]
    set txBufSize           [get_parameter_value gui_txBufSize]
    set rxBufLoc            [get_parameter_value gui_rxBufLoc]
    set rxBufSize           [get_parameter_value gui_rxBufSize]

    # Total local packet buffer size
    set pktBufSize 0

    if { ${txBufLoc} == ${::cPktBufLocal} } {
        set pktBufSize [expr ${pktBufSize} + ${txBufSize} ]
    }

    if { ${rxBufLoc} == ${::cPktBufLocal} } {
        set pktBufSize [expr ${pktBufSize} + ${rxBufSize} ]
    }

    # Convert to byte
    set pktBufSize [expr ${pktBufSize} * 1024 ]

    return ${pktBufSize}
}

# Returns the burst count width. If no external buffers are used, returns 1.
proc getBurstCountWidth {} {
    set txBufLoc            [get_parameter_value gui_txBufLoc]
    set txBurstSize         [get_parameter_value gui_txBurstSize]
    set rxBufLoc            [get_parameter_value gui_rxBufLoc]
    set rxBurstSize         [get_parameter_value gui_rxBurstSize]

    # First set burst size of locals to zero.
    if { ${txBufLoc} != ${::cPktBufExtern} } {
        set txBurstSize     0
    }

    if { ${rxBufLoc} != ${::cPktBufExtern} } {
        set rxBurstSize     0
    }

    # Find burst count width, get maximum and log2 + 1
    if { ${txBurstSize} > ${rxBurstSize} } {
        set maxBurstSize    ${txBurstSize}
    } else {
        set maxBurstSize    ${rxBurstSize}
    }

    set burstCountWidth [expr [global_logDualis ${maxBurstSize}] + 1]

    return ${burstCountWidth}
}

# Returns TRUE if bursts are used.
proc getBurstUsed {} {
    if { [getBurstCountWidth] > 1 } {
        return TRUE
    } else {
        return FALSE
    }
}

# Returns the fifo length depending on the burst length.
proc getFifoLength { burstLength } {
    # Minimum fifo length:
    set fifoLength  16

    # Size of max transfers stored
    set maxTransfer [expr ${burstLength} * 2 ]

    if { ${maxTransfer} > ${fifoLength} } {
        set fifoLength  ${maxTransfer}
    }

    return ${fifoLength}
}

# Returns the DMA Address width. Note that the returned range is 6 ... 32
proc getDmaAddrWidth {} {
    # System info
    set dmaAddrWidth        [get_parameter_value sys_dmaAddrWidth]
    set minDmaAddrWidth     6
    set maxDmaAddrWidth     32

    if { ${dmaAddrWidth} < ${minDmaAddrWidth} } {
        set dmaAddrWidth    ${minDmaAddrWidth}
    } elseif { ${dmaAddrWidth} > ${maxDmaAddrWidth} } {
        set dmaAddrWidth    ${maxDmaAddrWidth}
    }

    return ${dmaAddrWidth}
}

# Returns the DMA Data width
proc getDmaDataWidth {} {
    return 16
}

# Returns packet buffer size log2 (=PktBuf Addr width)
proc getPktBufSizeLog2 {} {
    # The log2 value determines pktbuf address width, this value doesn't matter
    # (it avoids warnings) since packet buffer below 1k are unrealistic!
    set minLog2         4

    # Obtain packet buffer size and get log2 of it...
    set pktBufSize      [getPktBufSize]
    set pktBufSizeLog2  [global_logDualis ${pktBufSize} ]

    if { ${pktBufSizeLog2} < ${minLog2} } {
        set pktBufSizeLog2  ${minLog2}
    }

    return ${pktBufSizeLog2}
}

# -----------------------------------------------------------------------------
# connection points
# -----------------------------------------------------------------------------
# connection point mainClk
add_interface           mainClk clock end
set_interface_property  mainClk clockRate 0
set_interface_property  mainClk ENABLED true

add_interface_port      mainClk csi_mainClk_clock clk Input 1

# connection point mainClkx2
add_interface           mainClkx2 clock end
set_interface_property  mainClkx2 clockRate 0
set_interface_property  mainClkx2 ENABLED true

add_interface_port      mainClkx2 csi_mainClkx2_clock clk Input 1

# connection point dmaClk
add_interface           dmaClk clock end
set_interface_property  dmaClk clockRate 0
set_interface_property  dmaClk ENABLED true

add_interface_port      dmaClk csi_dmaClk_clock clk Input 1

# connection point pktClk
add_interface           pktClk clock end
set_interface_property  pktClk clockRate 0
set_interface_property  pktClk ENABLED true

add_interface_port      pktClk csi_pktClk_clock clk Input 1

# connection point mainRst
add_interface           mainRst reset end
set_interface_property  mainRst associatedClock ""
set_interface_property  mainRst synchronousEdges NONE
set_interface_property  mainRst ENABLED true

add_interface_port      mainRst rsi_mainRst_reset reset Input 1

# connection point dmaRst
add_interface           dmaRst reset end
set_interface_property  dmaRst associatedClock ""
set_interface_property  dmaRst synchronousEdges NONE
set_interface_property  dmaRst ENABLED true

add_interface_port      dmaRst rsi_dmaRst_reset reset Input 1

# connection point pktRst
add_interface           pktRst reset end
set_interface_property  pktRst associatedClock ""
set_interface_property  pktRst synchronousEdges NONE
set_interface_property  pktRst ENABLED true

add_interface_port      pktRst rsi_pktRst_reset reset Input 1

# connection point macReg
add_interface           macReg avalon end
set_interface_property  macReg addressUnits WORDS
set_interface_property  macReg associatedClock mainClk
set_interface_property  macReg associatedReset mainRst
set_interface_property  macReg bitsPerSymbol 8
set_interface_property  macReg burstOnBurstBoundariesOnly false
set_interface_property  macReg burstcountUnits WORDS
set_interface_property  macReg explicitAddressSpan 0
set_interface_property  macReg linewrapBursts false
set_interface_property  macReg maximumPendingReadTransactions 0
set_interface_property  macReg ENABLED true

add_interface_port      macReg avs_macReg_chipselect chipselect Input 1
add_interface_port      macReg avs_macReg_write write Input 1
add_interface_port      macReg avs_macReg_read read Input 1
add_interface_port      macReg avs_macReg_waitrequest waitrequest Output 1
add_interface_port      macReg avs_macReg_byteenable byteenable Input 2
add_interface_port      macReg avs_macReg_address address Input 12
add_interface_port      macReg avs_macReg_writedata writedata Input 16
add_interface_port      macReg avs_macReg_readdata readdata Output 16

# connection point macTimer
add_interface           macTimer avalon end
set_interface_property  macTimer addressUnits WORDS
set_interface_property  macTimer associatedClock mainClk
set_interface_property  macTimer associatedReset mainRst
set_interface_property  macTimer bitsPerSymbol 8
set_interface_property  macTimer burstOnBurstBoundariesOnly false
set_interface_property  macTimer burstcountUnits WORDS
set_interface_property  macTimer explicitAddressSpan 0
set_interface_property  macTimer linewrapBursts false
set_interface_property  macTimer maximumPendingReadTransactions 0
set_interface_property  macTimer ENABLED true

add_interface_port      macTimer avs_macTimer_chipselect chipselect Input 1
add_interface_port      macTimer avs_macTimer_write write Input 1
add_interface_port      macTimer avs_macTimer_read read Input 1
add_interface_port      macTimer avs_macTimer_waitrequest waitrequest Output 1
add_interface_port      macTimer avs_macTimer_address address Input 2
add_interface_port      macTimer avs_macTimer_writedata writedata Input 32
add_interface_port      macTimer avs_macTimer_readdata readdata Output 32

# connection point pktBuf
add_interface           pktBuf avalon end
set_interface_property  pktBuf addressUnits WORDS
set_interface_property  pktBuf associatedClock pktClk
set_interface_property  pktBuf associatedReset pktRst
set_interface_property  pktBuf bitsPerSymbol 8
set_interface_property  pktBuf burstOnBurstBoundariesOnly false
set_interface_property  pktBuf burstcountUnits WORDS
set_interface_property  pktBuf explicitAddressSpan 0
set_interface_property  pktBuf linewrapBursts false
set_interface_property  pktBuf maximumPendingReadTransactions 0
set_interface_property  pktBuf ENABLED true

add_interface_port      pktBuf avs_pktBuf_chipselect chipselect Input 1
add_interface_port      pktBuf avs_pktBuf_write write Input 1
add_interface_port      pktBuf avs_pktBuf_read read Input 1
add_interface_port      pktBuf avs_pktBuf_waitrequest waitrequest Output 1
add_interface_port      pktBuf avs_pktBuf_byteenable byteenable Input 4
add_interface_port      pktBuf avs_pktBuf_address address Input gpacketbufferlog2size-2
add_interface_port      pktBuf avs_pktBuf_writedata writedata Input 32
add_interface_port      pktBuf avs_pktBuf_readdata readdata Output 32

# connection point dma
add_interface           dma avalon start
set_interface_property  dma addressUnits SYMBOLS
set_interface_property  dma associatedClock dmaClk
set_interface_property  dma associatedReset dmaRst
set_interface_property  dma bitsPerSymbol 8
set_interface_property  dma burstOnBurstBoundariesOnly false
set_interface_property  dma burstcountUnits WORDS
set_interface_property  dma doStreamReads false
set_interface_property  dma doStreamWrites false
set_interface_property  dma linewrapBursts false
set_interface_property  dma maximumPendingReadTransactions 0
set_interface_property  dma ENABLED true

add_interface_port      dma avm_dma_write write Output 1
add_interface_port      dma avm_dma_read read Output 1
add_interface_port      dma avm_dma_waitrequest waitrequest Input 1
add_interface_port      dma avm_dma_readdatavalid readdatavalid Input 1
add_interface_port      dma avm_dma_byteenable byteenable Output gdmadatawidth/8
add_interface_port      dma avm_dma_address address Output gdmaaddrwidth
add_interface_port      dma avm_dma_burstcount burstcount Output gdmaburstcountwidth
add_interface_port      dma avm_dma_writedata writedata Output gdmadatawidth
add_interface_port      dma avm_dma_readdata readdata Input gdmadatawidth

# connection point timerIrq
add_interface           timerIrq interrupt end
set_interface_property  timerIrq associatedAddressablePoint macTimer
set_interface_property  timerIrq associatedClock mainClk
set_interface_property  timerIrq associatedReset mainRst
set_interface_property  timerIrq ENABLED true

add_interface_port      timerIrq ins_timerIrq_irq irq Output 1

# connection point macIrq
add_interface           macIrq interrupt end
set_interface_property  macIrq associatedAddressablePoint macReg
set_interface_property  macIrq associatedClock mainClk
set_interface_property  macIrq associatedReset mainRst
set_interface_property  macIrq ENABLED true

add_interface_port      macIrq ins_macIrq_irq irq Output 1

# connection point rmii
add_interface           rmii conduit end
set_interface_property  rmii ENABLED true

add_interface_port      rmii coe_rmii_txEnable export Output gphyportcount
add_interface_port      rmii coe_rmii_txData export Output gphyportcount*2
add_interface_port      rmii coe_rmii_rxError export Input gphyportcount
add_interface_port      rmii coe_rmii_rxDataValid export Input gphyportcount
add_interface_port      rmii coe_rmii_rxData export Input gphyportcount*2

# connection point mii
add_interface           mii conduit end
set_interface_property  mii ENABLED true

add_interface_port      mii coe_mii_txEnable export Output gphyportcount
add_interface_port      mii coe_mii_txData export Output gphyportcount*4
add_interface_port      mii coe_mii_txClk export Input gphyportcount
add_interface_port      mii coe_mii_rxError export Input gphyportcount
add_interface_port      mii coe_mii_rxDataValid export Input gphyportcount
add_interface_port      mii coe_mii_rxData export Input gphyportcount*4
add_interface_port      mii coe_mii_rxClk export Input gphyportcount

# connection point smi
add_interface           smi conduit end
set_interface_property  smi ENABLED true

add_interface_port      smi coe_smi_nPhyRst export Output gsmiportcount
add_interface_port      smi coe_smi_clk export Output gsmiportcount
add_interface_port      smi coe_smi_dio export Bidir gsmiportcount

# connection point pktActivity
add_interface           pktActivity conduit end
set_interface_property  pktActivity ENABLED true

add_interface_port      pktActivity coe_pktActivity export Output 1

# connection point macTimerOut
add_interface           macTimerOut conduit end
set_interface_property  macTimerOut ENABLED true

add_interface_port      macTimerOut coe_macTimerOut export Output gtimercount
