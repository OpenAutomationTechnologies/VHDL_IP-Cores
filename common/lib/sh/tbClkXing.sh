#!/bin/bash
#
PAR=$*

ROOT=../../..

STIM_FILE="${ROOT}/common/lib/tb/tbClkXing-bhv-tb.txt"

SRC_LIST="\
common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/resetGenBhv.vhd \
common/util/src/busMasterPkg.vhd \
common/util/src/busMasterBhv.vhd \
common/lib/src/synchronizerRtl.vhd \
common/lib/src/edgedetectorRtl.vhd \
common/lib/src/syncTog-rtl-ea.vhd \
common/lib/src/clkXingRtl.vhd \
common/lib/tb/tbClkXing-bhv-tb.vhd \
"

GEN_LIST="\
gStimFile=${STIM_FILE} \
"

TOP_LEVEL=tbClkXing

chmod +x $ROOT/common/util/sh/msim-sim.sh
./$ROOT/common/util/sh/msim-sim.sh $TOP_LEVEL $PAR -s $SRC_LIST -g $GEN_LIST

RET=$?

if test $RET -ne 0
then
    exit 1
fi
