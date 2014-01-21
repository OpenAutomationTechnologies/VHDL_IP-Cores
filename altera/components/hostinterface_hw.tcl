# -----------------------------------------------------------------------------
# hostinterface_hw.tcl
#
# Qsys hardware component specification
#
# -----------------------------------------------------------------------------
#
#    (c) B&R, 2012
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

package require -exact qsys 12.0

# -----------------------------------------------------------------------------
# module
# -----------------------------------------------------------------------------
set_module_property NAME hostinterface
set_module_property VERSION 0.0.4
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Bridges and Adapters/Memory Mapped"
set_module_property AUTHOR "B&R"
set_module_property DISPLAY_NAME hostinterface
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ICON_PATH "img/br.png"


# -----------------------------------------------------------------------------
# file sets
# -----------------------------------------------------------------------------
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH         fileset_callback
set_fileset_property QUARTUS_SYNTH              TOP_LEVEL alteraHostInterface
set_fileset_property QUARTUS_SYNTH              ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file "dpRam-e.vhd"                  VHDL PATH "../../common/lib/src/dpRam-e.vhd"
add_fileset_file "dpRam-rtl-a.vhd"              VHDL PATH "../../altera/lib/src/dpRam-rtl-a.vhd"
add_fileset_file "addrDecodeRtl.vhd"            VHDL PATH "../../common/lib/src/addrDecodeRtl.vhd"
add_fileset_file "binaryEncoderRtl.vhd"         VHDL PATH "../../common/lib/src/binaryEncoderRtl.vhd"
add_fileset_file "cntRtl.vhd"                   VHDL PATH "../../common/lib/src/cntRtl.vhd"
add_fileset_file "edgedetectorRtl.vhd"          VHDL PATH "../../common/lib/src/edgedetectorRtl.vhd"
add_fileset_file "lutFileRtl.vhd"               VHDL PATH "../../common/lib/src/lutFileRtl.vhd"
add_fileset_file "synchronizerRtl.vhd"          VHDL PATH "../../common/lib/src/synchronizerRtl.vhd"
add_fileset_file "registerFileRtl.vhd"          VHDL PATH "../../common/lib/src/registerFileRtl.vhd"
add_fileset_file "alteraHostInterfaceRtl.vhd"   VHDL PATH "../../altera/hostinterface/src/alteraHostInterfaceRtl.vhd"
add_fileset_file "hostInterfacePkg.vhd"         VHDL PATH "../../common/hostinterface/src/hostInterfacePkg.vhd"
add_fileset_file "hostInterfaceRtl.vhd"         VHDL PATH "../../common/hostinterface/src/hostInterfaceRtl.vhd"
add_fileset_file "irqGenRtl.vhd"                VHDL PATH "../../common/hostinterface/src/irqGenRtl.vhd"
add_fileset_file "dynamicBridgeRtl.vhd"         VHDL PATH "../../common/hostinterface/src/dynamicBridgeRtl.vhd"
add_fileset_file "statusControlRegRtl.vhd"      VHDL PATH "../../common/hostinterface/src/statusControlRegRtl.vhd"
add_fileset_file "parallelInterfaceRtl.vhd"     VHDL PATH "../../common/hostinterface/src/parallelInterfaceRtl.vhd"
add_fileset_file "global.vhd"                   VHDL PATH "../../common/lib/src/global.vhd"


# -----------------------------------------------------------------------------
# VHDL parameters
# -----------------------------------------------------------------------------
add_parameter           gVersionMajor       NATURAL             255
set_parameter_property  gVersionMajor       DEFAULT_VALUE       255
set_parameter_property  gVersionMajor       TYPE                NATURAL
set_parameter_property  gVersionMajor       DERIVED             TRUE
set_parameter_property  gVersionMajor       HDL_PARAMETER       TRUE
set_parameter_property  gVersionMajor       AFFECTS_ELABORATION FALSE
set_parameter_property  gVersionMajor       VISIBLE             FALSE

add_parameter           gVersionMinor       NATURAL             255
set_parameter_property  gVersionMinor       DEFAULT_VALUE       255
set_parameter_property  gVersionMinor       TYPE                NATURAL
set_parameter_property  gVersionMinor       DERIVED             TRUE
set_parameter_property  gVersionMinor       HDL_PARAMETER       TRUE
set_parameter_property  gVersionMinor       AFFECTS_ELABORATION FALSE
set_parameter_property  gVersionMinor       VISIBLE             FALSE

add_parameter           gVersionRevision    NATURAL             255
set_parameter_property  gVersionRevision    DEFAULT_VALUE       255
set_parameter_property  gVersionRevision    TYPE                NATURAL
set_parameter_property  gVersionRevision    DERIVED             TRUE
set_parameter_property  gVersionRevision    HDL_PARAMETER       TRUE
set_parameter_property  gVersionRevision    AFFECTS_ELABORATION FALSE
set_parameter_property  gVersionRevision    VISIBLE             FALSE

add_parameter           gVersionCount       NATURAL             0
set_parameter_property  gVersionCount       DEFAULT_VALUE       0
set_parameter_property  gVersionCount       TYPE                NATURAL
set_parameter_property  gVersionCount       DERIVED             TRUE
set_parameter_property  gVersionCount       HDL_PARAMETER       TRUE
set_parameter_property  gVersionCount       AFFECTS_ELABORATION FALSE
set_parameter_property  gVersionCount       VISIBLE             FALSE

add_parameter           gBaseDynBuf0        NATURAL             2048
set_parameter_property  gBaseDynBuf0        DEFAULT_VALUE       2048
set_parameter_property  gBaseDynBuf0        TYPE                NATURAL
set_parameter_property  gBaseDynBuf0        DERIVED             TRUE
set_parameter_property  gBaseDynBuf0        HDL_PARAMETER       TRUE
set_parameter_property  gBaseDynBuf0        AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseDynBuf0        VISIBLE             FALSE
set_parameter_property  gBaseDynBuf0        DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseDynBuf1        NATURAL             4096
set_parameter_property  gBaseDynBuf1        DEFAULT_VALUE       4096
set_parameter_property  gBaseDynBuf1        TYPE                NATURAL
set_parameter_property  gBaseDynBuf1        DERIVED             TRUE
set_parameter_property  gBaseDynBuf1        HDL_PARAMETER       TRUE
set_parameter_property  gBaseDynBuf1        AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseDynBuf1        VISIBLE             FALSE
set_parameter_property  gBaseDynBuf1        DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseErrCntr        NATURAL             6144
set_parameter_property  gBaseErrCntr        DEFAULT_VALUE       6144
set_parameter_property  gBaseErrCntr        TYPE                NATURAL
set_parameter_property  gBaseErrCntr        DERIVED             TRUE
set_parameter_property  gBaseErrCntr        HDL_PARAMETER       TRUE
set_parameter_property  gBaseErrCntr        AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseErrCntr        VISIBLE             FALSE
set_parameter_property  gBaseErrCntr        DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseTxNmtQ         NATURAL             10240
set_parameter_property  gBaseTxNmtQ         DEFAULT_VALUE       10240
set_parameter_property  gBaseTxNmtQ         TYPE                NATURAL
set_parameter_property  gBaseTxNmtQ         DERIVED             TRUE
set_parameter_property  gBaseTxNmtQ         HDL_PARAMETER       TRUE
set_parameter_property  gBaseTxNmtQ         AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseTxNmtQ         VISIBLE             FALSE
set_parameter_property  gBaseTxNmtQ         DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseTxGenQ         NATURAL             14336
set_parameter_property  gBaseTxGenQ         DEFAULT_VALUE       14336
set_parameter_property  gBaseTxGenQ         TYPE                NATURAL
set_parameter_property  gBaseTxGenQ         DERIVED             TRUE
set_parameter_property  gBaseTxGenQ         HDL_PARAMETER       TRUE
set_parameter_property  gBaseTxGenQ         AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseTxGenQ         VISIBLE             FALSE
set_parameter_property  gBaseTxGenQ         DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseTxSynQ         NATURAL             18432
set_parameter_property  gBaseTxSynQ         DEFAULT_VALUE       18432
set_parameter_property  gBaseTxSynQ         TYPE                NATURAL
set_parameter_property  gBaseTxSynQ         DERIVED             TRUE
set_parameter_property  gBaseTxSynQ         HDL_PARAMETER       TRUE
set_parameter_property  gBaseTxSynQ         AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseTxSynQ         VISIBLE             FALSE
set_parameter_property  gBaseTxSynQ         DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseTxVetQ         NATURAL             22528
set_parameter_property  gBaseTxVetQ         DEFAULT_VALUE       22528
set_parameter_property  gBaseTxVetQ         TYPE                NATURAL
set_parameter_property  gBaseTxVetQ         DERIVED             TRUE
set_parameter_property  gBaseTxVetQ         HDL_PARAMETER       TRUE
set_parameter_property  gBaseTxVetQ         AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseTxVetQ         VISIBLE             FALSE
set_parameter_property  gBaseTxVetQ         DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseRxVetQ         NATURAL             26624
set_parameter_property  gBaseRxVetQ         DEFAULT_VALUE       26624
set_parameter_property  gBaseRxVetQ         TYPE                NATURAL
set_parameter_property  gBaseRxVetQ         DERIVED             TRUE
set_parameter_property  gBaseRxVetQ         HDL_PARAMETER       TRUE
set_parameter_property  gBaseRxVetQ         AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseRxVetQ         VISIBLE             FALSE
set_parameter_property  gBaseRxVetQ         DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseK2UQ           NATURAL             28672
set_parameter_property  gBaseK2UQ           DEFAULT_VALUE       28672
set_parameter_property  gBaseK2UQ           TYPE                NATURAL
set_parameter_property  gBaseK2UQ           DERIVED             TRUE
set_parameter_property  gBaseK2UQ           HDL_PARAMETER       TRUE
set_parameter_property  gBaseK2UQ           AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseK2UQ           VISIBLE             FALSE
set_parameter_property  gBaseK2UQ           DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseU2KQ           NATURAL             36864
set_parameter_property  gBaseU2KQ           DEFAULT_VALUE       36864
set_parameter_property  gBaseU2KQ           TYPE                NATURAL
set_parameter_property  gBaseU2KQ           DERIVED             TRUE
set_parameter_property  gBaseU2KQ           HDL_PARAMETER       TRUE
set_parameter_property  gBaseU2KQ           AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseU2KQ           VISIBLE             FALSE
set_parameter_property  gBaseU2KQ           DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseTpdo           NATURAL             45056
set_parameter_property  gBaseTpdo           DEFAULT_VALUE       45056
set_parameter_property  gBaseTpdo           TYPE                NATURAL
set_parameter_property  gBaseTpdo           DERIVED             TRUE
set_parameter_property  gBaseTpdo           HDL_PARAMETER       TRUE
set_parameter_property  gBaseTpdo           AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseTpdo           VISIBLE             FALSE
set_parameter_property  gBaseTpdo           DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseRpdo           NATURAL             57344
set_parameter_property  gBaseRpdo           DEFAULT_VALUE       57344
set_parameter_property  gBaseRpdo           TYPE                NATURAL
set_parameter_property  gBaseRpdo           DERIVED             TRUE
set_parameter_property  gBaseRpdo           HDL_PARAMETER       TRUE
set_parameter_property  gBaseRpdo           AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseRpdo           VISIBLE             FALSE
set_parameter_property  gBaseRpdo           DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gBaseRes            NATURAL             81920
set_parameter_property  gBaseRes            DEFAULT_VALUE       81920
set_parameter_property  gBaseRes            TYPE                NATURAL
set_parameter_property  gBaseRes            DERIVED             TRUE
set_parameter_property  gBaseRes            HDL_PARAMETER       TRUE
set_parameter_property  gBaseRes            AFFECTS_ELABORATION FALSE
set_parameter_property  gBaseRes            VISIBLE             FALSE
set_parameter_property  gBaseRes            DISPLAY_HINT        "HEXADECIMAL"

add_parameter           gHostIfType         NATURAL             0
set_parameter_property  gHostIfType         DEFAULT_VALUE       0
set_parameter_property  gHostIfType         TYPE                NATURAL
set_parameter_property  gHostIfType         DERIVED             TRUE
set_parameter_property  gHostIfType         HDL_PARAMETER       TRUE
set_parameter_property  gHostIfType         AFFECTS_ELABORATION FALSE
set_parameter_property  gHostIfType         VISIBLE             FALSE

add_parameter           gParallelDataWidth  NATURAL             32
set_parameter_property  gParallelDataWidth  DEFAULT_VALUE       32
set_parameter_property  gParallelDataWidth  TYPE                NATURAL
set_parameter_property  gParallelDataWidth  DERIVED             TRUE
set_parameter_property  gParallelDataWidth  HDL_PARAMETER       TRUE
set_parameter_property  gParallelDataWidth  AFFECTS_ELABORATION FALSE
set_parameter_property  gParallelDataWidth  VISIBLE             FALSE

add_parameter           gParallelMultiplex  NATURAL             0
set_parameter_property  gParallelMultiplex  DEFAULT_VALUE       0
set_parameter_property  gParallelMultiplex  TYPE                NATURAL
set_parameter_property  gParallelMultiplex  DERIVED             TRUE
set_parameter_property  gParallelMultiplex  HDL_PARAMETER       TRUE
set_parameter_property  gParallelMultiplex  AFFECTS_ELABORATION FALSE
set_parameter_property  gParallelMultiplex  VISIBLE             FALSE

# -----------------------------------------------------------------------------
# System Info parameters
# -----------------------------------------------------------------------------

add_parameter           sys_uniqueId        INTEGER             0
set_parameter_property  sys_uniqueId        DEFAULT_VALUE       0
set_parameter_property  sys_uniqueId        AFFECTS_GENERATION  TRUE
set_parameter_property  sys_uniqueId        HDL_PARAMETER       FALSE
set_parameter_property  sys_uniqueId        DERIVED             TRUE
set_parameter_property  sys_uniqueId        SYSTEM_INFO         GENERATION_ID
set_parameter_property  sys_uniqueId        ENABLED             FALSE
set_parameter_property  sys_uniqueId        VISIBLE             FALSE

# -----------------------------------------------------------------------------
# GUI parameters
# -----------------------------------------------------------------------------
add_parameter           gui_interfaceTyp    NATURAL             0
set_parameter_property  gui_interfaceTyp    DEFAULT_VALUE       0
set_parameter_property  gui_interfaceTyp    TYPE                NATURAL
set_parameter_property  gui_interfaceTyp    DISPLAY_NAME        "Host Interface Configuration"
set_parameter_property  gui_interfaceTyp    ALLOWED_RANGES      {0:Avalon 1:Parallel}
set_parameter_property  gui_interfaceTyp    DISPLAY_HINT        RADIO

add_parameter           gui_parallelMltplx  NATURAL             0
set_parameter_property  gui_parallelMltplx  DEFAULT_VALUE       0
set_parameter_property  gui_parallelMltplx  TYPE                NATURAL
set_parameter_property  gui_parallelMltplx  DISPLAY_NAME        "Address-/Data-Bus Multiplexing"
set_parameter_property  gui_parallelMltplx  ALLOWED_RANGES      {0:Demultiplexed 1:Multiplexed}
set_parameter_property  gui_parallelMltplx  DISPLAY_HINT        RADIO

add_parameter           gui_parallelDwidth  NATURAL             16
set_parameter_property  gui_parallelDwidth  DEFAULT_VALUE       16
set_parameter_property  gui_parallelDwidth  TYPE                NATURAL
set_parameter_property  gui_parallelDwidth  DISPLAY_NAME        "Data Width"
set_parameter_property  gui_parallelDwidth  ALLOWED_RANGES      {16 32}
set_parameter_property  gui_parallelDwidth  UNITS               "Bits"

add_parameter           gui_sizeDynBuf0     NATURAL             2
set_parameter_property  gui_sizeDynBuf0     DEFAULT_VALUE       2
set_parameter_property  gui_sizeDynBuf0     TYPE                NATURAL
set_parameter_property  gui_sizeDynBuf0     DISPLAY_NAME        "Dynamic Buffer for RX Virtual Ethernet Queue"
set_parameter_property  gui_sizeDynBuf0     UNITS               "Kilobytes"
set_parameter_property  gui_sizeDynBuf0     ALLOWED_RANGES      {2}

add_parameter           gui_sizeDynBuf1     NATURAL             2
set_parameter_property  gui_sizeDynBuf1     DEFAULT_VALUE       2
set_parameter_property  gui_sizeDynBuf1     TYPE                NATURAL
set_parameter_property  gui_sizeDynBuf1     DISPLAY_NAME        "Dynamic Buffer for Kernel-to-User Queue"
set_parameter_property  gui_sizeDynBuf1     UNITS               "Kilobytes"
set_parameter_property  gui_sizeDynBuf1     ALLOWED_RANGES      {2}

add_parameter           gui_sizeErrorCnter  NATURAL             3108
set_parameter_property  gui_sizeErrorCnter  DEFAULT_VALUE       3108
set_parameter_property  gui_sizeErrorCnter  TYPE                NATURAL
set_parameter_property  gui_sizeErrorCnter  DISPLAY_NAME        "Error Counter"
set_parameter_property  gui_sizeErrorCnter  UNITS               "Bytes"
set_parameter_property  gui_sizeErrorCnter  ALLOWED_RANGES      {36:CN 3108:MN 1024 2048 4096 8192}

add_parameter           gui_sizeTxNmtQ      NATURAL             2
set_parameter_property  gui_sizeTxNmtQ      DEFAULT_VALUE       2
set_parameter_property  gui_sizeTxNmtQ      TYPE                NATURAL
set_parameter_property  gui_sizeTxNmtQ      DISPLAY_NAME        "TX NMT Queue"
set_parameter_property  gui_sizeTxNmtQ      UNITS               "Kilobytes"
set_parameter_property  gui_sizeTxNmtQ      ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeTxGenQ      NATURAL             2
set_parameter_property  gui_sizeTxGenQ      DEFAULT_VALUE       2
set_parameter_property  gui_sizeTxGenQ      TYPE                NATURAL
set_parameter_property  gui_sizeTxGenQ      DISPLAY_NAME        "TX Generic Queue"
set_parameter_property  gui_sizeTxGenQ      UNITS               "Kilobytes"
set_parameter_property  gui_sizeTxGenQ      ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeTxSyncQ     NATURAL             2
set_parameter_property  gui_sizeTxSyncQ     DEFAULT_VALUE       2
set_parameter_property  gui_sizeTxSyncQ     TYPE                NATURAL
set_parameter_property  gui_sizeTxSyncQ     DISPLAY_NAME        "TX Sync Queue"
set_parameter_property  gui_sizeTxSyncQ     UNITS               "Kilobytes"
set_parameter_property  gui_sizeTxSyncQ     ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeTxVethQ     NATURAL             2
set_parameter_property  gui_sizeTxVethQ     DEFAULT_VALUE       2
set_parameter_property  gui_sizeTxVethQ     TYPE                NATURAL
set_parameter_property  gui_sizeTxVethQ     DISPLAY_NAME        "TX Virtual Ethernet Queue"
set_parameter_property  gui_sizeTxVethQ     UNITS               "Kilobytes"
set_parameter_property  gui_sizeTxVethQ     ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeRxVethQ     NATURAL             1
set_parameter_property  gui_sizeRxVethQ     DEFAULT_VALUE       1
set_parameter_property  gui_sizeRxVethQ     TYPE                NATURAL
set_parameter_property  gui_sizeRxVethQ     DISPLAY_NAME        "RX Virtual Ethernet Queue"
set_parameter_property  gui_sizeRxVethQ     UNITS               "Kilobytes"
set_parameter_property  gui_sizeRxVethQ     ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeK2UQ        NATURAL             8
set_parameter_property  gui_sizeK2UQ        DEFAULT_VALUE       8
set_parameter_property  gui_sizeK2UQ        TYPE                NATURAL
set_parameter_property  gui_sizeK2UQ        DISPLAY_NAME        "Kernel-to-User Queue"
set_parameter_property  gui_sizeK2UQ        UNITS               "Kilobytes"
set_parameter_property  gui_sizeK2UQ        ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeU2KQ        NATURAL             8
set_parameter_property  gui_sizeU2KQ        DEFAULT_VALUE       8
set_parameter_property  gui_sizeU2KQ        TYPE                NATURAL
set_parameter_property  gui_sizeU2KQ        DISPLAY_NAME        "User-to-Kernel Queue"
set_parameter_property  gui_sizeU2KQ        UNITS               "Kilobytes"
set_parameter_property  gui_sizeU2KQ        ALLOWED_RANGES      {1 2 4 8 16 32 64}

add_parameter           gui_sizeTpdo        NATURAL             12288
set_parameter_property  gui_sizeTpdo        DEFAULT_VALUE       12288
set_parameter_property  gui_sizeTpdo        TYPE                NATURAL
set_parameter_property  gui_sizeTpdo        DISPLAY_NAME        "Transmit Process Data Objects (TPDO)"
set_parameter_property  gui_sizeTpdo        UNITS               "Bytes"

add_parameter           gui_sizeRpdo        NATURAL             24576
set_parameter_property  gui_sizeRpdo        DEFAULT_VALUE       24576
set_parameter_property  gui_sizeRpdo        TYPE                NATURAL
set_parameter_property  gui_sizeRpdo        DISPLAY_NAME        "Receive Process Data Objects (RPDO)"
set_parameter_property  gui_sizeRpdo        UNITS               "Bytes"

add_parameter           gui_sizeTotal       NATURAL             49152
set_parameter_property  gui_sizeTotal       DEFAULT_VALUE       49152
set_parameter_property  gui_sizeTotal       TYPE                NATURAL
set_parameter_property  gui_sizeTotal       DISPLAY_NAME        "Total Memory Size"
set_parameter_property  gui_sizeTotal       UNITS               "Bytes"
set_parameter_property  gui_sizeTotal       DERIVED             TRUE

add_parameter           gui_baseAddrTblName STRING_LIST
set_parameter_property  gui_baseAddrTblName DISPLAY_NAME        "Buffers"
set_parameter_property  gui_baseAddrTblName DERIVED             TRUE
set_parameter_property  gui_baseAddrTblName DISPLAY_HINT        "fixed_size"

add_parameter           gui_baseAddrTblVal  INTEGER_LIST
set_parameter_property  gui_baseAddrTblVal  DISPLAY_NAME        "Offset"
set_parameter_property  gui_baseAddrTblVal  DERIVED             TRUE
set_parameter_property  gui_baseAddrTblVal  DISPLAY_HINT        "HEXADECIMAL"

# -----------------------------------------------------------------------------
# GUI configuration
# -----------------------------------------------------------------------------
add_display_item        "" "General"                            GROUP TAB
add_display_item        "General"           gui_interfaceTyp    PARAMETER
add_display_item        "General"           "Avalon"            GROUP
add_display_item        "General"           "Parallel Interface" GROUP
add_display_item        "Parallel Interface" gui_parallelDwidth PARAMETER
add_display_item        "Parallel Interface" gui_parallelMltplx PARAMETER

add_display_item        "" "Buffer Configuration"               GROUP TAB
add_display_item        "Buffer Configuration" "Queues"         GROUP
add_display_item        "Buffer Configuration" "Pdo"            GROUP
add_display_item        "Buffer Configuration" "Others"         GROUP
add_display_item        "Others"            gui_sizeDynBuf0     PARAMETER
add_display_item        "Others"            gui_sizeDynBuf1     PARAMETER
add_display_item        "Others"            gui_sizeErrorCnter  PARAMETER
add_display_item        "Queues"            gui_sizeTxNmtQ      PARAMETER
add_display_item        "Queues"            gui_sizeTxGenQ      PARAMETER
add_display_item        "Queues"            gui_sizeTxSyncQ     PARAMETER
add_display_item        "Queues"            gui_sizeTxVethQ     PARAMETER
add_display_item        "Queues"            gui_sizeRxVethQ     PARAMETER
add_display_item        "Queues"            gui_sizeK2UQ        PARAMETER
add_display_item        "Queues"            gui_sizeU2KQ        PARAMETER
add_display_item        "Pdo"               gui_sizeTpdo        PARAMETER
add_display_item        "Pdo"               gui_sizeRpdo        PARAMETER

add_display_item        "" "Information"                        GROUP TAB
add_display_item        "Information"       "Memory Map"        GROUP
add_display_item        "Memory Map"        gui_sizeTotal       PARAMETER
add_display_item        "Memory Map"        baseAddrTbl         GROUP TABLE
add_display_item        baseAddrTbl         gui_baseAddrTblName PARAMETER
add_display_item        baseAddrTbl         gui_baseAddrTblVal  PARAMETER

# -----------------------------------------------------------------------------
# callbacks
# -----------------------------------------------------------------------------

proc fileset_callback { entityName } {
    send_message INFO "Generating entity $entityName"

    set ifCfg [get_interfaceConfiguration]

    switch $ifCfg {
        0 {
            # Avalon Interface selected
            # -> no sdc file required!
        }
        1 {
            # Parallel Interface selected
            switch [get_parallelInterfaceConfiguration] {
                0 {
                    # asynchronous
                    add_fileset_file "hostinterface/hostinterface-async.sdc" SDC PATH "sdc/hostinterface-async.sdc"
                }
                1 {
                    # synchronous
                    send_message ERROR "Synchronous Parallel Interface not yet supported!"
                    #TODO: add sdc file if sync parallel interface is selected
                }
                default {

                }
            }
        }
        default {

        }
    }
}

proc elaboration_callback {} {

    #control GUI
    display_parallelInterface

    #generate HDL generics and C macros
    generate_version
    generate_memory_mapping
    generate_hostInterface

}

# -----------------------------------------------------------------------------
# internal functions
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# display control
proc display_parallelInterface {} {
    set_display_item_property "Avalon" VISIBLE FALSE
    set_display_item_property "Parallel Interface" VISIBLE FALSE

    set ifCfg [get_interfaceConfiguration]

    switch $ifCfg {
        0 {
            set_display_item_property "Avalon" VISIBLE TRUE
        }
        1 {
            set_display_item_property "Parallel Interface" VISIBLE TRUE
        }
        default {

        }
    }
}

# -----------------------------------------------------------------------------
# generate
proc generate_hostInterface {} {
    set interfaceConfig [get_interfaceConfiguration]
    set hdlNameList [list "gHostIfType"]
    set hdlParamList [list $interfaceConfig]

    # check if Avalon or parallel interface is selected
    if {$interfaceConfig == 0} {
        #enable Avalon host
        set_interface_property host ENABLED TRUE

        #disable parallel host
        set_interface_property parHost ENABLED FALSE

    } else {
        #enable parallel host
        set_interface_property parHost ENABLED TRUE

        #disable Avalon host
        set_interface_property host ENABLED FALSE

        #terminate multiplex signals
        set interfaceMultiplex [get_interfaceParallelMultiplex]

        if {$interfaceMultiplex == 0} {
            #terminate multiplex signals since not in use
            set_port_property coe_parHost_addressLatchEnable termination true
            set_port_property coe_parHost_addressData termination true
        } else {
            #terminate demultiplex signals since not in use
            set_port_property coe_parHost_address termination true
            set_port_property coe_parHost_data termination true
        }

        #set HDL generics
        set hdlNameList [concat $hdlNameList "gParallelDataWidth" "gParallelMultiplex"]
        set hdlParamList [concat $hdlParamList [get_interfaceParallelDwidth] $interfaceMultiplex]
    }

    set_list_hdl $hdlNameList $hdlParamList
}

proc generate_version {} {
    set listVersionParam [list "gVersionMajor" "gVersionMinor" "gVersionRevision" "gVersionCount"]
    set listVersionCmacro [list "VERSION_MAJOR" "VERSION_MINOR" "VERSION_REVISION" "VERSION_COUNT"]
    set stringVersion [get_module_property VERSION]

    set listVersionDigit [concat [split $stringVersion "."] [get_version_count [get_parameter_value sys_uniqueId] 255]]

    set_list_hdl $listVersionParam $listVersionDigit

    set_list_cmacro $listVersionCmacro $listVersionDigit
}

proc generate_memory_mapping {} {
    set listSizeGuiParam [list "gui_sizeDynBuf0" "gui_sizeDynBuf1" "gui_sizeErrorCnter" "gui_sizeTxNmtQ" "gui_sizeTxGenQ" "gui_sizeTxSyncQ" "gui_sizeTxVethQ" "gui_sizeRxVethQ" "gui_sizeK2UQ" "gui_sizeU2KQ" "gui_sizeTpdo" "gui_sizeRpdo"]
    set queueHeaderSize 16
    set listSizeGuiHeaders [list 0 0 0 $queueHeaderSize $queueHeaderSize $queueHeaderSize $queueHeaderSize $queueHeaderSize $queueHeaderSize $queueHeaderSize 0 0]
    set listSizeCmacro [list "SIZE_DYNBUF0" "SIZE_DYNBUF1" "SIZE_ERRORCOUNTER" "SIZE_TXNMTQ" "SIZE_TXGENQ" "SIZE_TXSYNCQ" "SIZE_TXVETHQ" "SIZE_RXVETHQ" "SIZE_K2UQ" "SIZE_U2KQ" "SIZE_TPDO" "SIZE_RPDO"]
    set listBaseCmacro [list "BASE_DYNBUF0" "BASE_DYNBUF1" "BASE_ERRORCOUNTER" "BASE_TXNMTQ" "BASE_TXGENQ" "BASE_TXSYNCQ" "BASE_TXVETHQ" "BASE_RXVETHQ" "BASE_K2UQ" "BASE_U2KQ" "BASE_TPDO" "BASE_RPDO"]
    set listBaseParam [list "gBaseDynBuf0" "gBaseDynBuf1" "gBaseErrCntr" "gBaseTxNmtQ" "gBaseTxGenQ" "gBaseTxSynQ" "gBaseTxVetQ" "gBaseRxVetQ" "gBaseK2UQ" "gBaseU2KQ" "gBaseTpdo" "gBaseRpdo" "gBaseRes"]
    set statusControlBase 0
    set statusControlSize 2048
    set memorySpanKb 128

    #get sizes from GUI
    set listSize [get_gui_size $listSizeGuiParam ]

    #add size for header
    set listSize [add_value_to_list $listSize $listSizeGuiHeaders]

    #insert status control at the beginnig of list
    set listSize [linsert $listSize 0 $statusControlSize]

    #calulate base addresses
    set listBase [get_base_addresses $statusControlBase $listSize]

    #omit status control base and size (don't need it in HDL and C)
    set listBase [lrange $listBase 1 end]
    set listSize [lrange $listSize 1 end]

    #get required memory span
    set memorySpan [get_required_memory_span $listBase]

    set_parameter_value gui_sizeTotal $memorySpan

    #test memory mapping
    set ret [check_memory_mapping $listBase $memorySpanKb]

    switch $ret {
        "SUCCESSFUL" { }
        "EXCEED" {
            send_message Error "The buffer size settings exceed the $memorySpanKb Kilobyte span!"
        }
        default {
            send_message Warning "check_memory_mapping returned $ret"
        }
    }

    set_list_hdl $listBaseParam $listBase

    set_list_cmacro $listBaseCmacro $listBase
    set_list_cmacro $listSizeCmacro $listSize

    #write memory mapping to table
    set_parameter_value gui_baseAddrTblName $listBaseParam
    set_parameter_value gui_baseAddrTblVal $listBase
}

# functions for generate_version
proc get_version_count { value maxvalue } {
    if {$maxvalue == 0} {
        set maxvalue 1
    }

    # get positive remainder of the division to limit returned value
    set value [expr abs(int(fmod($value, $maxvalue)))]

    return $value
}

# functions for generate_memory_mapping
proc get_gui_size { listParam } {
    set listSize ""

    foreach param $listParam {
        set unit [get_parameter_property $param UNITS]
        set val [get_parameter_value $param]

        switch $unit {
            "Bytes" {
                set fact 1
                if {[expr $val % 4] != 0} {
                    send_message Error "[get_parameter_property $param DISPLAY_NAME] is not 32-bit-aligned!"
                }
            }
            "Kilobytes" {
                set fact 1024
            }
            default {
                send_message Error "Unknown unit!"
            }
        }
        set listSize [concat $listSize [expr int($val * $fact)]]
    }

    return $listSize
}

proc add_value_to_list { listParam listValue } {
    set listRet ""

    foreach param $listParam adder $listValue {

        set listRet [concat $listRet [expr $param + $adder]]
    }

    return $listRet
}

proc get_base_addresses { base listSize } {
    set listBase $base
    set accumulator $base

    foreach size $listSize {
        set listBase [concat $listBase [expr $accumulator + $size]]
        set accumulator [expr $accumulator + $size]
    }

    return $listBase
}

proc get_required_memory_span { listBase } {
    return [lindex $listBase end]
}

proc check_memory_mapping { listBase memorySpanKb } {
    set memorySpan [expr $memorySpanKb * 1024]
    set ret "SUCCESSFUL"

    set lastListBase [get_required_memory_span $listBase]

    if {$lastListBase <= $memorySpan}  {

    } else {
        set ret "EXCEED"
    }

    return $ret
}

# functions for reading/checking GUI parameters
proc get_interfaceConfiguration { } {
    set param "gui_interfaceTyp"
    set val [get_parameter_value $param]

    switch $val  {
        0 {
        #Avalon
        }
        1 {
        #Parallel
        }
        default {
            send_message Error "Set [get_parameter_property $param DISPLAY_NAME]"
        }
    }

    return $val
}

proc get_parallelInterfaceConfiguration { } {
    #Note: This procedure returns always 0 (asynchronous), since no GUI configuration
    #      is implemented!
    set param ""
    set val 0

    switch $val {
        0 {
        # asynchronous configuration
        }
        1 {
        # synchronous configuration
        }
        default {
        }
    }

    return $val
}

proc get_interfaceParallelDwidth { } {
    set param "gui_parallelDwidth"
    set val [get_parameter_value $param]

    switch $val  {
        16 {
        }
        32 {
        }
        default {
            send_message Error "Set [get_parameter_property $param DISPLAY_NAME]"
        }
    }

    return $val
}

proc get_interfaceParallelMultiplex { } {
    set param "gui_parallelMltplx"
    set val [get_parameter_value $param]

    switch $val  {
        0 {
        #Demultiplexed
        }
        1 {
        #Multiplexed
        }
        default {
            send_message Error "Set [get_parameter_property $param DISPLAY_NAME]"
        }
    }

    return $val
}

# utilities
proc set_list_hdl { listParam listValue } {
    foreach param $listParam value $listValue {
        set_parameter_value $param $value
    }
}

proc set_list_cmacro { listCmacro listValue } {
    foreach cmacro $listCmacro digit $listValue {
        set_module_assignment embeddedsw.CMacro.$cmacro $digit
    }
}

proc get_list_param { listParam } {
    set listTmp ""
    foreach param $listParam {
        set tmp [get_parameter_value $param]
        set listTmp [concat $listTmp $tmp]
    }
    return $listTmp
}

# -----------------------------------------------------------------------------
# connection points
# -----------------------------------------------------------------------------
# connection point c0
add_interface c0 clock end
set_interface_property c0 clockRate 0
set_interface_property c0 ENABLED true

add_interface_port c0 csi_c0_clock clk Input 1


# connection point r0
add_interface r0 reset end
set_interface_property r0 associatedClock c0
set_interface_property r0 synchronousEdges DEASSERT
set_interface_property r0 ENABLED true

add_interface_port r0 rsi_r0_reset reset Input 1


# connection point host
add_interface host avalon end
set_interface_property host addressUnits WORDS
set_interface_property host associatedClock c0
set_interface_property host associatedReset r0
set_interface_property host bitsPerSymbol 8
set_interface_property host burstOnBurstBoundariesOnly false
set_interface_property host burstcountUnits WORDS
set_interface_property host explicitAddressSpan 0
set_interface_property host holdTime 0
set_interface_property host linewrapBursts false
set_interface_property host maximumPendingReadTransactions 0
set_interface_property host readLatency 0
set_interface_property host readWaitTime 1
set_interface_property host setupTime 0
set_interface_property host timingUnits Cycles
set_interface_property host writeWaitTime 0
set_interface_property host ENABLED FALSE

add_interface_port host avs_host_address address Input 15
add_interface_port host avs_host_byteenable byteenable Input 4
add_interface_port host avs_host_read read Input 1
add_interface_port host avs_host_readdata readdata Output 32
add_interface_port host avs_host_write write Input 1
add_interface_port host avs_host_writedata writedata Input 32
add_interface_port host avs_host_waitrequest waitrequest Output 1
set_interface_assignment host embeddedsw.configuration.isFlash 0
set_interface_assignment host embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment host embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment host embeddedsw.configuration.isPrintableDevice 0


# connection point pcp
add_interface pcp avalon end
set_interface_property pcp addressUnits WORDS
set_interface_property pcp associatedClock c0
set_interface_property pcp associatedReset r0
set_interface_property pcp bitsPerSymbol 8
set_interface_property pcp burstOnBurstBoundariesOnly false
set_interface_property pcp burstcountUnits WORDS
set_interface_property pcp explicitAddressSpan 0
set_interface_property pcp holdTime 0
set_interface_property pcp linewrapBursts false
set_interface_property pcp maximumPendingReadTransactions 0
set_interface_property pcp readLatency 0
set_interface_property pcp readWaitTime 1
set_interface_property pcp setupTime 0
set_interface_property pcp timingUnits Cycles
set_interface_property pcp writeWaitTime 0
set_interface_property pcp ENABLED true

add_interface_port pcp avs_pcp_address address Input 9
add_interface_port pcp avs_pcp_byteenable byteenable Input 4
add_interface_port pcp avs_pcp_read read Input 1
add_interface_port pcp avs_pcp_readdata readdata Output 32
add_interface_port pcp avs_pcp_write write Input 1
add_interface_port pcp avs_pcp_writedata writedata Input 32
add_interface_port pcp avs_pcp_waitrequest waitrequest Output 1
set_interface_assignment pcp embeddedsw.configuration.isFlash 0
set_interface_assignment pcp embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment pcp embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment pcp embeddedsw.configuration.isPrintableDevice 0


# connection point hostBridge
add_interface hostBridge avalon start
set_interface_property hostBridge addressUnits SYMBOLS
set_interface_property hostBridge associatedClock c0
set_interface_property hostBridge associatedReset r0
set_interface_property hostBridge bitsPerSymbol 8
set_interface_property hostBridge burstOnBurstBoundariesOnly false
set_interface_property hostBridge burstcountUnits WORDS
set_interface_property hostBridge doStreamReads false
set_interface_property hostBridge doStreamWrites false
set_interface_property hostBridge holdTime 0
set_interface_property hostBridge linewrapBursts false
set_interface_property hostBridge maximumPendingReadTransactions 0
set_interface_property hostBridge readLatency 0
set_interface_property hostBridge readWaitTime 1
set_interface_property hostBridge setupTime 0
set_interface_property hostBridge timingUnits Cycles
set_interface_property hostBridge writeWaitTime 0
set_interface_property hostBridge ENABLED true

add_interface_port hostBridge avm_hostBridge_address address Output 30
add_interface_port hostBridge avm_hostBridge_byteenable byteenable Output 4
add_interface_port hostBridge avm_hostBridge_read read Output 1
add_interface_port hostBridge avm_hostBridge_readdata readdata Input 32
add_interface_port hostBridge avm_hostBridge_write write Output 1
add_interface_port hostBridge avm_hostBridge_writedata writedata Output 32
add_interface_port hostBridge avm_hostBridge_waitrequest waitrequest Input 1


# connection point irqSync
add_interface irqSync interrupt start
set_interface_property irqSync associatedAddressablePoint hostBridge
set_interface_property irqSync associatedClock c0
set_interface_property irqSync associatedReset r0
set_interface_property irqSync irqScheme INDIVIDUAL_REQUESTS
set_interface_property irqSync ENABLED true

add_interface_port irqSync inr_irqSync_irq irq Input 1


# connection point irqOut
add_interface irqOut interrupt end
set_interface_property irqOut associatedAddressablePoint host
set_interface_property irqOut associatedClock c0
set_interface_property irqOut associatedReset r0
set_interface_property irqOut ENABLED true

add_interface_port irqOut ins_irqOut_irq irq Output 1


# connection point parallel host interface
add_interface parHost conduit end
set_interface_property parHost ENABLED false
add_interface_port parHost coe_parHost_chipselect export Input 1
add_interface_port parHost coe_parHost_read export Input 1
add_interface_port parHost coe_parHost_write export Input 1
add_interface_port parHost coe_parHost_addressLatchEnable export Input 1
add_interface_port parHost coe_parHost_acknowledge export Output 1
add_interface_port parHost coe_parHost_byteenable export Input gParallelDataWidth/8
add_interface_port parHost coe_parHost_address export Input 16
add_interface_port parHost coe_parHost_data export Bidir gParallelDataWidth
add_interface_port parHost coe_parHost_addressData export Bidir gParallelDataWidth
