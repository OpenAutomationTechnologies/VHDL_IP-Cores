#!/bin/bash
# Runs modelsim to compile and simulate provided sources and toplevel.
# Call e.g. ./msim-sim.sh SETTING-FILE

proc_genList() {
    export GENLIST=

    for i in $*
    do
        GENLIST+="-g$i "
        shift
    done
}

# Get *.settings file
SETTINGS_FILE=$1

# Set defaults
SRC_LIST=
TOP_LEVEL=
GEN_LIST=("")
VCOM_LIST=
VSIM_LIST=
VHDL_STD="-93"

# Get parameters from *.settings file
source $SETTINGS_FILE

################################################################################
# Script changes to root directory to enable simple path settings files!
pushd ..

DOFILE=tools/sim.do

echo
echo "#### $TOP_LEVEL ####"

vlib work

#compile source files
vcom $VHDL_STD -work work $SRC_LIST $VCOM_LIST -check_synthesis
if test $? -ne 0
then
    popd
    exit 1
fi

CNT=0
for i in  "${GEN_LIST[@]}"
do
    proc_genList $i

    #simulate design
    vsim $TOP_LEVEL -c -do $DOFILE -lib work $GENLIST $VSIM_LIST

    #catch simulation return
    RET=$?

    echo
    if [ $RET -ne 0 ]; then
        echo "ERROR"
        popd
        exit $RET
    else
        echo "PASS"
    fi
    CNT=$(( CNT + 1 ))
done

popd
#exit with simulation return
exit $RET
