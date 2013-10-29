#!/bin/bash
#
PAR=$*

ROOT=../../..

STIM_FILE="${ROOT}/common/openmac/tb/tbMmSlaveConv_stim.txt"

SRC_LIST="\
common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/busMasterPkg.vhd \
common/util/src/busMasterBhv.vhd \
common/util/src/spRamBhv.vhd \
\
common/openmac/src/mmSlaveConv-rtl-ea.vhd \
\
common/openmac/tb/tbMmSlaveConv-bhv-tb.vhd \
"

GEN_LIST="\
gStimFile=${STIM_FILE} \
"

TOP_LEVEL=tbMmSlaveConv

chmod +x $ROOT/common/util/sh/msim-sim.sh
./$ROOT/common/util/sh/msim-sim.sh $TOP_LEVEL $PAR -s $SRC_LIST -g $GEN_LIST

RET=$?

if test $RET -ne 0
then
    exit 1
fi
