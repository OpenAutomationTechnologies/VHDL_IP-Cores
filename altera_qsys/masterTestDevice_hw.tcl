#------------------------------------------------------------------------------------------------------------------------
#-- MASTER TEST DEVICE for Avalon
#--
#-- 	  Copyright (C) 2012 B&R
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
#-- 2012-02-08  V0.01   zelenkaj    first generation
#-- 2012-03-07  V0.02   zelenkaj    converted to QSYS
#------------------------------------------------------------------------------------------------------------------------


package require -exact sopc 11.0

set_module_property DESCRIPTION "Can be used to evaluate interface and memory performance."
set_module_property NAME masterTestDevice
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Performance Evaluation"
set_module_property AUTHOR "Joerg Zelenka (B&R)"
set_module_property DISPLAY_NAME master_test_device
set_module_property TOP_LEVEL_HDL_FILE "src/masterTestDeviceRtl.vhd"
set_module_property TOP_LEVEL_HDL_MODULE masterTestDevice
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property STATIC_TOP_LEVEL_MODULE_NAME masterTestDevice
set_module_property FIX_110_VIP_PATH false


add_file "src/masterTestDeviceRtl.vhd" {SYNTHESIS SIMULATION}
add_file "src/lib/global.vhd" {SYNTHESIS SIMULATION}


add_parameter gSlaveAddrWidth NATURAL 16
set_parameter_property gSlaveAddrWidth DEFAULT_VALUE 16
set_parameter_property gSlaveAddrWidth DISPLAY_NAME gSlaveAddrWidth
set_parameter_property gSlaveAddrWidth TYPE NATURAL
set_parameter_property gSlaveAddrWidth UNITS None
set_parameter_property gSlaveAddrWidth AFFECTS_GENERATION false
set_parameter_property gSlaveAddrWidth HDL_PARAMETER true

add_parameter gSlaveDataWidth NATURAL 32
set_parameter_property gSlaveDataWidth DEFAULT_VALUE 32
set_parameter_property gSlaveDataWidth DISPLAY_NAME gSlaveDataWidth
set_parameter_property gSlaveDataWidth TYPE NATURAL
set_parameter_property gSlaveDataWidth UNITS None
set_parameter_property gSlaveDataWidth AFFECTS_GENERATION false
set_parameter_property gSlaveDataWidth HDL_PARAMETER true

add_parameter gMasterAddrWidth NATURAL 32
set_parameter_property gMasterAddrWidth DEFAULT_VALUE 32
set_parameter_property gMasterAddrWidth DISPLAY_NAME gMasterAddrWidth
set_parameter_property gMasterAddrWidth TYPE NATURAL
set_parameter_property gMasterAddrWidth UNITS None
set_parameter_property gMasterAddrWidth AFFECTS_GENERATION false
set_parameter_property gMasterAddrWidth HDL_PARAMETER true

add_parameter gMasterDataWidth NATURAL 32
set_parameter_property gMasterDataWidth DEFAULT_VALUE 32
set_parameter_property gMasterDataWidth DISPLAY_NAME gMasterDataWidth
set_parameter_property gMasterDataWidth TYPE NATURAL
set_parameter_property gMasterDataWidth UNITS None
set_parameter_property gMasterDataWidth AFFECTS_GENERATION false
set_parameter_property gMasterDataWidth HDL_PARAMETER true

add_parameter gMasterBurstCountWidth NATURAL 10
set_parameter_property gMasterBurstCountWidth DEFAULT_VALUE 10
set_parameter_property gMasterBurstCountWidth DISPLAY_NAME gMasterBurstCountWidth
set_parameter_property gMasterBurstCountWidth TYPE NATURAL
set_parameter_property gMasterBurstCountWidth UNITS None
set_parameter_property gMasterBurstCountWidth AFFECTS_GENERATION false
set_parameter_property gMasterBurstCountWidth HDL_PARAMETER true


add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
add_interface_port clock_sink iClk clk Input 1

add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
add_interface_port reset_sink iRst reset Input 1

add_interface slave_interface avalon end
set_interface_property slave_interface addressUnits WORDS
set_interface_property slave_interface associatedClock clock_sink
set_interface_property slave_interface associatedReset reset_sink
set_interface_property slave_interface bitsPerSymbol 8
set_interface_property slave_interface burstOnBurstBoundariesOnly false
set_interface_property slave_interface burstcountUnits WORDS
set_interface_property slave_interface explicitAddressSpan 0
set_interface_property slave_interface holdTime 0
set_interface_property slave_interface linewrapBursts false
set_interface_property slave_interface maximumPendingReadTransactions 0
set_interface_property slave_interface readLatency 0
set_interface_property slave_interface readWaitTime 1
set_interface_property slave_interface setupTime 0
set_interface_property slave_interface timingUnits Cycles
set_interface_property slave_interface writeWaitTime 0
set_interface_property slave_interface ENABLED true
add_interface_port slave_interface iSlaveChipselect chipselect Input 1
add_interface_port slave_interface iSlaveWrite write Input 1
add_interface_port slave_interface iSlaveRead read Input 1
add_interface_port slave_interface iSlaveAddress address Input gslaveaddrwidth
add_interface_port slave_interface iSlaveWritedata writedata Input gslavedatawidth
add_interface_port slave_interface oSlaveReaddata readdata Output gslavedatawidth
add_interface_port slave_interface oSlaveWaitrequest waitrequest Output 1

add_interface master_interface avalon start
set_interface_property master_interface addressUnits SYMBOLS
set_interface_property master_interface associatedClock clock_sink
set_interface_property master_interface associatedReset reset_sink
set_interface_property master_interface bitsPerSymbol 8
set_interface_property master_interface burstOnBurstBoundariesOnly false
set_interface_property master_interface burstcountUnits WORDS
set_interface_property master_interface doStreamReads false
set_interface_property master_interface doStreamWrites false
set_interface_property master_interface holdTime 0
set_interface_property master_interface linewrapBursts false
set_interface_property master_interface maximumPendingReadTransactions 0
set_interface_property master_interface readLatency 0
set_interface_property master_interface readWaitTime 1
set_interface_property master_interface setupTime 0
set_interface_property master_interface timingUnits Cycles
set_interface_property master_interface writeWaitTime 0
set_interface_property master_interface ENABLED true
add_interface_port master_interface oMasterWrite write Output 1
add_interface_port master_interface oMasterRead read Output 1
add_interface_port master_interface oMasterAddress address Output gmasteraddrwidth
add_interface_port master_interface oMasterWritedata writedata Output gmasterdatawidth
add_interface_port master_interface iMasterReaddata readdata Input gmasterdatawidth
add_interface_port master_interface iMasterWaitrequest waitrequest Input 1
add_interface_port master_interface iMasterReaddatavalid readdatavalid Input 1
add_interface_port master_interface oMasterBurstcount burstcount Output gmasterburstcountwidth
