#!/bin/bash
#
PAR=$*

ROOT=../../..

STIM_FILE_MACREG="${ROOT}/common/openmac/tb/tbOpenmacTop-macReg_stim.txt"
STIM_FILE_PKTBUF="${ROOT}/common/openmac/tb/tbOpenmacTop-pktBuf_stim.txt"
STIM_FILE_MACTIMER="${ROOT}/common/openmac/tb/tbOpenmacTop-macTimer_stim.txt"

SRC_LIST="\
common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/busMasterPkg.vhd \
common/util/src/busMasterBhv.vhd \
\
common/lib/src/addrDecodeRtl.vhd \
common/lib/src/cntRtl.vhd \
common/lib/src/dpRam-e.vhd \
common/lib/src/dpRamSplx-e.vhd \
common/lib/src/edgedetectorRtl.vhd \
common/lib/src/synchronizerRtl.vhd \
common/lib/src/syncTog-rtl-ea.vhd \
\
common/util/src/dpRam-bhv-a.vhd \
altera/lib/src/dpRamSplx-rtl-a.vhd \
\
common/fifo/src/fifoRead-rtl-ea.vhd \
common/fifo/src/fifoWrite-rtl-ea.vhd \
common/fifo/src/asyncFifo-e.vhd \
common/fifo/src/asyncFifo-rtl-a.vhd \
\
common/openmac/src/openmacPkg-p.vhd \
common/openmac/src/dma_handler.vhd \
common/openmac/src/master_handler.vhd \
common/openmac/src/openMAC_DMAmaster.vhd \
common/openmac/src/openfilter-rtl-ea.vhd \
common/openmac/src/openhub-rtl-ea.vhd \
common/openmac/src/openmacTimer-rtl-ea.vhd \
common/openmac/src/phyActGen-rtl-ea.vhd \
common/openmac/src/phyMgmt-rtl-ea.vhd \
common/openmac/src/convRmiiToMii-rtl-ea.vhd \
common/openmac/src/openMAC.vhd \
common/openmac/src/openmacTop-rtl-ea.vhd \
\
common/openmac/tb/tbOpenmacTop-bhv-tb.vhd \
"

GEN_LIST="\
gStimFileMacReg=${STIM_FILE_MACREG} \
gStimFilePktBuf=${STIM_FILE_PKTBUF} \
gStimFileMacTimer=${STIM_FILE_MACTIMER} \
"

TOP_LEVEL=tbOpenmacTop

chmod +x $ROOT/common/util/sh/msim-sim.sh
./$ROOT/common/util/sh/msim-sim.sh $TOP_LEVEL $PAR -s $SRC_LIST -g $GEN_LIST

RET=$?

if test $RET -ne 0
then
    exit 1
fi
