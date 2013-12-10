#!/usr/bin/tclsh
# This file creates the GUI for the triple buffer ipcore

set CON_PARAM conBufSize
set CON_MAX_BUF 32
set CON_BUF_NAME "Consumer Buffer Size"
set CON_BUF_UNIT "Bytes"

set PRO_PARAM proBufSize
set PRO_MAX_BUF 32
set PRO_BUF_NAME "Producer Buffer Size"
set PRO_BUF_UNIT "Bytes"

# Generate Consumer buffer size parameters
add_display_item "" "Consumer Buffers" GROUP

add_parameter numOfCon NATURAL 4
set_parameter_property numOfCon DISPLAY_NAME "Number of Consumer Buffers"
set_parameter_property numOfCon ALLOWED_RANGES {0:32}

add_display_item "Consumer Buffers" "numOfCon" PARAMETER

set glb_listCon ""
for {set i 0} {$i < ${CON_MAX_BUF}} {incr i} {
    add_parameter ${CON_PARAM}${i} NATURAL 0
    set_parameter_property ${CON_PARAM}${i} DISPLAY_NAME "${CON_BUF_NAME} ${i}"
    set_parameter_property ${CON_PARAM}${i} UNITS ${CON_BUF_UNIT}

    add_display_item "Consumer Buffers" "${CON_PARAM}${i}" PARAMETER

    set glb_listCon [concat $glb_listCon ${CON_PARAM}${i}]
}

# Generate Producer buffer size parameters
add_display_item "" "Producer Buffers" GROUP

add_parameter numOfPro NATURAL 4
set_parameter_property numOfPro DISPLAY_NAME "Number of Producer Buffers"
set_parameter_property numOfPro ALLOWED_RANGES {0:32}

add_display_item "Producer Buffers" "numOfPro" PARAMETER

set glb_listPro ""
for {set i 0} {$i < ${PRO_MAX_BUF}} {incr i} {
    add_parameter ${PRO_PARAM}${i} NATURAL 0
    set_parameter_property ${PRO_PARAM}${i} DISPLAY_NAME "${PRO_BUF_NAME} ${i}"
    set_parameter_property ${PRO_PARAM}${i} UNITS ${PRO_BUF_UNIT}


    add_display_item "Producer Buffers" "${PRO_PARAM}${i}" PARAMETER

    set glb_listPro [concat $glb_listPro ${PRO_PARAM}${i}]
}
