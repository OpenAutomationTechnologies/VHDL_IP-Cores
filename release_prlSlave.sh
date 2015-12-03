#!/bin/bash

DIR_RELEASE=$1
IP_VERSION=$2
DIR_DOC=doc/parallelinterface

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

# generate docs
echo "generate docs..."
pushd $DIR_DOC
./create-this-doc --skip-doxygen
popd

# copy docs
echo "copy docs..."
cp --parents ${DIR_DOC}/wavedrom/parallelif_mplx_rd.svg         ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/parallelif_mplx_wr.svg         ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/parallelif_rd.svg              ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/parallelif_wr.svg              ${DIR_RELEASE}
cp --parents ${DIR_DOC}/md/parallelif.md                        ${DIR_RELEASE}
cp --parents ${DIR_DOC}/doxyfile                                ${DIR_RELEASE}
cp --parents ${DIR_DOC}/mainpage.txt                            ${DIR_RELEASE}

# create revision.txt
REV_FILE=${DIR_RELEASE}/${DIR_DOC}/revision.md
echo "Revision {#revision}" > $REV_FILE
echo "========" >> $REV_FILE
echo "" >> $REV_FILE
git log --format="- %s" -- */parallelinterface/* >> $REV_FILE

# Copy sources
cp --parents common/latch/src/dataLatch-e.vhd                   ${DIR_RELEASE}
cp --parents altera/latch/src/dataLatch-syn-a.vhd               ${DIR_RELEASE}
cp --parents common/parallelinterface/src/prlSlave-rtl-ea.vhd   ${DIR_RELEASE}

cp --parents altera/components/prlSlave_hw.tcl                  ${DIR_RELEASE}
cp --parents altera/components/sdc/prlSlave.sdc                 ${DIR_RELEASE}
cp --parents altera/components/tcl/qsysUtil.tcl                 ${DIR_RELEASE}
