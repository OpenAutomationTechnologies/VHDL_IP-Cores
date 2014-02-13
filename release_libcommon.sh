#!/bin/bash
# ./release_libcommon.sh RELEASE_DIR
# e.g.: $ ./release_libcommon.sh release

DIR_RELEASE=$1
IP_VERSION=$2

if [ -z "${DIR_RELEASE}" ];
then
    DIR_RELEASE=release
fi

DIR_XIL="libcommon_${IP_VERSION}"

# create dir structure
echo "create release dir..."
mkdir -p ${DIR_RELEASE}

# Copy common files
cp --parents common/lib/src/global.vhd              ${DIR_RELEASE}
cp --parents common/lib/src/addrDecodeRtl.vhd       ${DIR_RELEASE}
cp --parents common/lib/src/bcd2ledRtl.vhd          ${DIR_RELEASE}
cp --parents common/lib/src/binaryEncoderRtl.vhd    ${DIR_RELEASE}
cp --parents common/lib/src/cntRtl.vhd              ${DIR_RELEASE}
cp --parents common/lib/src/edgedetectorRtl.vhd     ${DIR_RELEASE}
cp --parents common/lib/src/lutFileRtl.vhd          ${DIR_RELEASE}
cp --parents common/lib/src/nShiftRegRtl.vhd        ${DIR_RELEASE}
cp --parents common/lib/src/registerFileRtl.vhd     ${DIR_RELEASE}
cp --parents common/lib/src/synchronizerRtl.vhd     ${DIR_RELEASE}
cp --parents common/lib/src/syncTog-rtl-ea.vhd      ${DIR_RELEASE}
cp --parents common/lib/src/clkXingRtl.vhd          ${DIR_RELEASE}

# Copy Altera component
cp --parents altera/components/libcommon.qip        ${DIR_RELEASE}

# Copy Xilinx component
cp --parents xilinx/components/pcores/libcommon/data/libcommon_v2_1_0.pao ${DIR_RELEASE}

# create revision.txt
REV_FILE=${DIR_RELEASE}/common/lib/revision.txt
HASH=$(git rev-parse HEAD)
LASTTAG=$(git describe --abbrev=0 --tags)
echo "Revision (${HASH} / ${LASTTAG})" > $REV_FILE
echo "" >> $REV_FILE
git log --format="- %s" -- common/lib/* >> $REV_FILE
