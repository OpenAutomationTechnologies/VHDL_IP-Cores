#!/bin/bash
# ./release_spiBridge_ipcore.sh RELEASE_DIR
# e.g.: $ ./release_spiBridge_ipcore release

DIR_RELEASE=$1

if [ -z "${DIR_RELEASE}" ];
then
    DIR_RELEASE=release
fi

# create dir structure
echo "create dir structure..."
mkdir -p ${DIR_RELEASE}

# copy Altera
echo "copy altera ipcore..."
cp --parents altera/components/spiBridge_hw.tcl       ${DIR_RELEASE}
cp --parents altera/components/tcl/spiBridgeGui.tcl   ${DIR_RELEASE}
cp --parents altera/components/sdc/spiBridge-aclk.sdc ${DIR_RELEASE}
cp --parents altera/spi/src/alteraSpiBridgeRtl.vhd    ${DIR_RELEASE}
cp --parents common/spi/src/spiSlave-e.vhd            ${DIR_RELEASE}
cp --parents common/spi/src/spiSlave-rtl_aclk-a.vhd   ${DIR_RELEASE}
cp --parents common/spi/src/protStreamRtl.vhd         ${DIR_RELEASE}
cp --parents common/spi/src/spiBridgeRtl.vhd          ${DIR_RELEASE}
