#!/bin/bash
# ./release_atomicmodify_ipcore.sh RELEASE_DIR
# e.g.: $ ./release_atomicmodify_ipcore release

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
cp --parents altera/components/atomicmodify_hw.tcl                ${DIR_RELEASE}
cp --parents altera/atomicmodify/src/alteraAtomicmodifyRtl.vhd    ${DIR_RELEASE}
cp --parents common/atomicmodify/src/atomicmodifyRtl.vhd          ${DIR_RELEASE}
