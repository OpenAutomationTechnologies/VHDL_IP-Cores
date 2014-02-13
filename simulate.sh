#!/bin/bash
# Compile all needed libraries.
# Runs msim with all available tb*.settings files.
# The script provides it's runtime after completion.

DIR_TOOLS=tools

#Get start time.
TIME_START=$(date +"%s")

#store current path
export ORIGIN_DIR=.

echo
echo "Compile libraries..."
echo

LIBST_LIST="\
common/lib/sh/libcommon.settings \
common/util/sh/libutil.settings \
"

RET=1
for LIBSET in $LIBST_LIST
do
    echo "###############################################################################"
    echo "# Compile library $LIBSET"

    chmod +x ./${DIR_TOOLS}/msim-vcomLib.sh
    ./${DIR_TOOLS}/msim-vcomLib.sh ${LIBSET}
    RET=$?

    #check return
    if [ $RET -ne 0 ]; then
        echo "-> ERROR!"
        break
    else
        echo "-> SUCCESSFUL!"
    fi

    echo "###############################################################################"
    echo
done

echo
echo "Starting simulation of all available shell-scripts..."
echo

#find all *.settings
TBSET_LIST=`find $ORIGIN_DIR -name "tb*.settings"`

#loop through tb*.setting list
RET=1
for TBSET in $TBSET_LIST
do
    echo "###############################################################################"
    echo "# Run testbench of path ${TBSET}"

    chmod +x ./${DIR_TOOLS}/msim-sim.sh
    ./${DIR_TOOLS}/msim-sim.sh ${TBSET}
    RET=$?

    #check return
    if [ $RET -ne 0 ]; then
        echo "-> ERROR!"
        break
    else
        echo "-> SUCCESSFUL!"
    fi

    echo "###############################################################################"
    echo
done

#Get completion time, calculate duration time and give seconds in time format.
TIME_COMPLETE=$(date +"%s")
SEC_DUR=$(( $TIME_COMPLETE - $TIME_START ))
TIME_DUR=$(date -u -d @${SEC_DUR} +"%T")

echo
if [ $RET -ne 0 ]; then
    printf "Simulation completed with errors! (RET=${RET} "
else
    printf "Simulation completed successful! ("
fi

echo "Runtime=${TIME_DUR})"

exit $RET
