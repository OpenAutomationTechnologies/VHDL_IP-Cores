#!/bin/bash
# Runs modelsim to compile a given library.
# Call e.g. ./tools/msim-vcomLib.sh SETTING-FILE

# Defaults
VHDL_STD="-93"

# Get lib*.settings file
SETTINGS_FILE=$1

echo "INFO: Create and compile $LIB_NAME from $SETTINGS_FILE"
source $SETTINGS_FILE

# Create library
vlib $LIB_NAME

#compile source files
vcom $VHDL_STD -work $LIB_NAME $LIB_SRC -check_synthesis
if test $? -ne 0
then
    exit 1
fi

#exit with simulation return
exit $RET
