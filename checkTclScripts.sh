#!/bin/bash
# Runs tcl scripts provided in TCL_LIST

echo
echo "Starting TCL script checks..."
echo

#store current path
export ORIGIN_DIR=.

#find all tcl scripts starting with "test" and store in list
TCL_LIST=`find $ORIGIN_DIR -name "test-*.tcl"`

#loop through list
for TCL in $TCL_LIST
do
    #change to directoy
    pushd `dirname $TCL`

    echo
    echo "Call" `basename $TCL .tcl`

    tclsh `basename $TCL .tcl`.tcl
    RET=$?

    popd

    if [ $RET -ne 0 ]; then
        exit $RET
    fi
done

exit 0
