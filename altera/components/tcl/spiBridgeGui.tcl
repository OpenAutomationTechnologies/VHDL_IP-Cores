#!/usr/bin/tclsh
# This file creates the GUI for the spi bridge ipcore

add_parameter           gui_cpol        NATURAL             0
set_parameter_property  gui_cpol        ALLOWED_RANGES      {0 1}
set_parameter_property  gui_cpol        DISPLAY_NAME        "Clock Polarity"

add_parameter           gui_cpha        NATURAL             0
set_parameter_property  gui_cpha        ALLOWED_RANGES      {0 1}
set_parameter_property  gui_cpha        DISPLAY_NAME        "Clock Phase"

add_parameter           gui_shiftdir    NATURAL             0
set_parameter_property  gui_shiftdir    ALLOWED_RANGES      {"0:LSB first" "1:MSB first"}
set_parameter_property  gui_shiftdir    DISPLAY_NAME        "Shift Direction"

add_parameter           gui_regsize     NATURAL             8
set_parameter_property  gui_regsize     ALLOWED_RANGES      {8 16 32}
set_parameter_property  gui_regsize     DISPLAY_NAME        "Register Size"
set_parameter_property  gui_regsize     DISPLAY_UNITS       "Bits"
