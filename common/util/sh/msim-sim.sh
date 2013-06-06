#!/bin/bash
# Runs modelsim to compile and simulate provided sources and toplevel.
# Call e.g. ./msim-sim.sh $TOP_LEVEL $SRC_LIST

hdlSim () {
    vsim $1 -c -do $2 -lib work

    return $?
}

echo
echo "--- msim-sim.sh ---"
ROOT=../../..
DOFILE=$ROOT/common/util/do/sim.do
TOP_LEVEL=$1

rm work -rf
vlib work

echo $PWD

for i in $*
do
    echo
    if test $i != $TOP_LEVEL
    then
        vcom -work work $ROOT/$i
    fi
    if test $? -ne 0
    then
        exit 1
    fi
done

hdlSim $TOP_LEVEL $DOFILE

exit $?
