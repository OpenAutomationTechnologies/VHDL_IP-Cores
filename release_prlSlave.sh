#!/bin/bash

DIR_RELEASE=$1
IP_VERSION=$2

if [ -z "${DIR_RELEASE}" ];
then
    DIR_RELEASE=release
fi

if [ -z "${IP_VERSION}" ];
then
    IP_VERSION=v1_00_a
fi

# create dir structure
echo "create release dir..."
mkdir -p ${DIR_RELEASE}

cp --parents common/latch/src/dataLatch-e.vhd                   ${DIR_RELEASE}
cp --parents altera/latch/src/dataLatch-syn-a.vhd               ${DIR_RELEASE}
cp --parents common/parallelinterface/src/prlSlave-rtl-ea.vhd   ${DIR_RELEASE}

cp --parents altera/components/prlSlave_hw.tcl                  ${DIR_RELEASE}
cp --parents altera/components/tcl/qsysUtil.tcl                 ${DIR_RELEASE}
