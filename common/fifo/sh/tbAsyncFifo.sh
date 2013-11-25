#!/bin/bash
#
PAR=$*

ROOT=../../..

STIM_FILE_WRITE="${ROOT}/common/fifo/tb/tbAsyncFifo-write_stim.txt"
STIM_FILE_READ="${ROOT}/common/fifo/tb/tbAsyncFifo-read_stim.txt"

SRC_LIST="\
common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/busMasterPkg.vhd \
common/util/src/busMasterBhv.vhd \
\
common/lib/src/synchronizerRtl.vhd \
common/lib/src/dpRamSplxNbe-e.vhd \
\
xilinx/lib/src/dpRamSplxNbe-rtl-a.vhd \
\
common/fifo/src/fifoRead-rtl-ea.vhd \
common/fifo/src/fifoWrite-rtl-ea.vhd \
common/fifo/src/asyncFifo-e.vhd \
common/fifo/src/asyncFifo-rtl-a.vhd \
\
common/fifo/tb/tbAsyncFifo-bhv-tb.vhd \
"

GEN_LIST="\
gStimFileWrite=${STIM_FILE_WRITE} \
gStimFileRead=${STIM_FILE_READ} \
"

TOP_LEVEL=tbAsyncFifo

chmod +x $ROOT/common/util/sh/msim-sim.sh
./$ROOT/common/util/sh/msim-sim.sh $TOP_LEVEL $PAR -s $SRC_LIST -g $GEN_LIST

RET=$?

if test $RET -ne 0
then
    exit 1
fi
