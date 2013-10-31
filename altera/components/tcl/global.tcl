#!/usr/bin/tclsh
# This file provides general functions to be used for Sopc/Qsys components.

# This procedure adds an HDL parameter.
proc global_addHdlParam { name type default visible } {
    add_parameter           ${name} ${type}         ${default}
    set_parameter_property  ${name} DERIVED         TRUE
    set_parameter_property  ${name} HDL_PARAMETER   TRUE
    set_parameter_property  ${name} VISIBLE         ${visible}
}

# This procedure adds a GUI parameter.
proc global_addGuiParam { name type default display units range } {
    add_parameter           ${name} ${type}         ${default}
    set_parameter_property  ${name} DISPLAY_NAME    ${display}
    set_parameter_property  ${name} DISPLAY_UNITS   ${units}
    set_parameter_property  ${name} ALLOWED_RANGES  ${range}
}

# This procedure adds a SYSTEM INFO parameter
proc global_addSysParam { name type default sysInfo visible } {
    add_parameter           ${name} ${type}         ${default}
    set_parameter_property  ${name} SYSTEM_INFO     ${sysInfo}
    set_parameter_property  ${name} VISIBLE         ${visible}
}

# This procedure calculates the log dualis of the input param.
# Note that param should be an integer
proc global_logDualis { param } {
    # initialize climping values
    set accu    1
    set result  0

    # ceil the input parameter
    set val [expr int(ceil(${param})) ]

    while {${accu} < ${val}} {
        set accu    [expr ${accu} * 2 ]
        set result  [expr ${result} + 1 ]
    }

    return ${result}
}
