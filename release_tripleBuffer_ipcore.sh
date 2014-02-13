#!/bin/bash
# ./release_tripleBuffer_ipcore.sh RELEASE_DIR
# e.g.: $ ./release_tripleBuffer_ipcore release

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
cp --parents altera/components/tripleBuffer_hw.tcl                ${DIR_RELEASE}
cp --parents altera/components/tripleBuffer_sw.tcl                ${DIR_RELEASE}
cp --parents altera/components/tcl/tripleBufferGui.tcl            ${DIR_RELEASE}
cp --parents altera/components/tcl/tripleBuffer.tcl               ${DIR_RELEASE}
cp --parents altera/tripleBuffer/src/alteraTripleBufferRtl.vhd    ${DIR_RELEASE}
cp --parents altera/memory/src/dpRam-rtl-a.vhd                    ${DIR_RELEASE}
cp --parents common/memory/src/dpRam-e.vhd                        ${DIR_RELEASE}
cp --parents common/tripleBuffer/tcl/calcTriBuf.tcl               ${DIR_RELEASE}
cp --parents common/tripleBuffer/src/tripleBufferPkg.vhd          ${DIR_RELEASE}
cp --parents common/tripleBuffer/src/tripleBridgeRtl.vhd          ${DIR_RELEASE}
cp --parents common/tripleBuffer/src/tripleLogicRtl.vhd           ${DIR_RELEASE}
cp --parents common/tripleBuffer/src/tripleBufferRtl.vhd          ${DIR_RELEASE}
cp --parents common/util/tcl/writeFile.tcl                        ${DIR_RELEASE}
