#!/bin/bash

DIR_RELEASE=$1
IP_VERSION=$2

if [ -z "${DIR_RELEASE}" ];
then
    DIR_RELEASE=release
fi

if [ -z "${IP_VERSION}" ];
then
    IP_VERSION=v1_02_a
fi

# create dir structure
echo "create release dir..."
mkdir -p ${DIR_RELEASE}

cp --parents common/parallelinterface/src/prlMaster-rtl-ea.vhd  ${DIR_RELEASE}

cp --parents altera/components/prlMaster_hw.tcl                 ${DIR_RELEASE}
cp --parents altera/components/sdc/prlMaster.sdc                ${DIR_RELEASE}
cp --parents altera/components/tcl/qsysUtil.tcl                 ${DIR_RELEASE}
