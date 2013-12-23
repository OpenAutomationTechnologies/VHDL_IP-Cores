#!/bin/bash
# Runs msim with all available tb*.settings files.
# The script provides it's runtime after completion.

DIR_TOOLS=tools

#Get start time.
TIME_START=$(date +"%s")

echo
echo "Starting simulation of all available shell-scripts..."
echo

#store current path
export ORIGIN_DIR=.

#find all *.settings
TBSET_LIST=`find $ORIGIN_DIR -name "tb*.settings"`

#loop through tb*.setting list
RET=1
pushd $DIR_TOOLS
for TBSET in $TBSET_LIST
do
    echo "###############################################################################"
    echo "# Run testbench of path ${TBSET}"

    chmod +x ./msim-sim.sh
    ./msim-sim.sh ../${TBSET}
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
popd

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
