#!/bin/bash
# Runs all available shell scripts that start with "tb".
# The compilation/simulation results are copied to results directory.

echo
echo "Starting simulation of all available shell-scripts..."
echo

#store current path
export ORIGIN_DIR=.

#find all shell scripts starting with "tb" and store in list
TBSH_LIST=`find $ORIGIN_DIR -name "tb*.sh"`

#loop through tb*.sh list
for TBSH in $TBSH_LIST
do
    #change to directory of current tb*.sh
    pushd `dirname $TBSH`

    echo
    echo "Simulate" `basename $TBSH .sh`

    #run sh
    chmod +x ./`basename $TBSH .sh`.sh
    ./`basename $TBSH .sh`.sh

    #store return
    RET=$?

    popd

    #copy work to results
    mkdir ./results/`basename $TBSH .sh` -p
    cp `dirname $TBSH`/work ./results/`basename $TBSH .sh`/work -r
    #copy waves to results and convert to vcd
    cp `dirname $TBSH`/*.wlf ./results/`basename $TBSH .sh` -r
    wlf2vcd `dirname $TBSH`/*.wlf -o ./results/`basename $TBSH .sh`/wave.vcd

    #check return
    if [ $RET -ne 0 ]; then
        exit 1
    fi
done

exit 0
