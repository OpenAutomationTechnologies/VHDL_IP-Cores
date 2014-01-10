#!/bin/bash
# ./release_hostinterface.sh RELEASE_DIR
# e.g.: $ ./release_hostinterface.sh release

DIR_RELEASE=$1
DIR_DOC=doc/hostinterface

if [ -z "${DIR_RELEASE}" ];
then
    DIR_RELEASE=release
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
cp --parents ${DIR_DOC}/images/hostif-common_vs_dynamic_bridge.png  ${DIR_RELEASE}
cp --parents ${DIR_DOC}/images/hostif-example_sys_int.png           ${DIR_RELEASE}
cp --parents ${DIR_DOC}/images/hostif-dyn_bridge.png                ${DIR_RELEASE}
cp --parents ${DIR_DOC}/images/hostif-memmap.png                    ${DIR_RELEASE}
cp --parents ${DIR_DOC}/md/hostif.md                                ${DIR_RELEASE}
cp --parents ${DIR_DOC}/md/hostif_sc.md                             ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_mplx_rd-wr.svg              ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_rd-wr.svg                   ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_mplx_rd.svg                 ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_rd.svg                      ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_mplx_wr.svg                 ${DIR_RELEASE}
cp --parents ${DIR_DOC}/wavedrom/hostif_wr.svg                      ${DIR_RELEASE}
cp --parents ${DIR_DOC}/Doxyfile                                    ${DIR_RELEASE}
cp --parents ${DIR_DOC}/mainpage.txt                                ${DIR_RELEASE}

# copy drivers
echo "copy drivers..."
cp --parents drivers/hostinterface/hostiflib.c                      ${DIR_RELEASE}
cp --parents drivers/hostinterface/hostiflib.h                      ${DIR_RELEASE}
cp --parents drivers/hostinterface/hostiflib_l.c                    ${DIR_RELEASE}
cp --parents drivers/hostinterface/hostiflib_l.h                    ${DIR_RELEASE}
cp --parents drivers/hostinterface/hostiflib_nios.h                 ${DIR_RELEASE}
cp --parents drivers/hostinterface/hostiflib_target.h               ${DIR_RELEASE}
cp --parents drivers/hostinterface/lfqueue.c                        ${DIR_RELEASE}
cp --parents drivers/hostinterface/lfqueue.h                        ${DIR_RELEASE}

# copy Altera host interface
echo "copy altera powerlink ipcore..."
cp --parents altera/components/hostinterface_hw.tcl                 ${DIR_RELEASE}
cp --parents altera/components/hostinterface_sw.tcl                 ${DIR_RELEASE}
cp --parents altera/components/img/br.png                           ${DIR_RELEASE}
cp --parents altera/components/sdc/hostinterface-async.sdc          ${DIR_RELEASE}
cp --parents altera/components/tcl/hostinterface.tcl                ${DIR_RELEASE}
cp --parents altera/lib/src/dpRam-rtl-a.vhd                         ${DIR_RELEASE}
cp --parents common/lib/src/dpRam-e.vhd                             ${DIR_RELEASE}
cp --parents common/lib/src/addrDecodeRtl.vhd                       ${DIR_RELEASE}
cp --parents common/lib/src/binaryEncoderRtl.vhd                    ${DIR_RELEASE}
cp --parents common/lib/src/cntRtl.vhd                              ${DIR_RELEASE}
cp --parents common/lib/src/edgedetectorRtl.vhd                     ${DIR_RELEASE}
cp --parents common/lib/src/lutFileRtl.vhd                          ${DIR_RELEASE}
cp --parents common/lib/src/registerFileRtl.vhd                     ${DIR_RELEASE}
cp --parents common/lib/src/synchronizerRtl.vhd                     ${DIR_RELEASE}
cp --parents altera/hostinterface/src/alteraHostInterfaceRtl.vhd    ${DIR_RELEASE}
cp --parents common/hostinterface/revision.txt                      ${DIR_RELEASE}
cp --parents common/hostinterface/src/hostInterfacePkg.vhd          ${DIR_RELEASE}
cp --parents common/hostinterface/src/hostInterfaceRtl.vhd          ${DIR_RELEASE}
cp --parents common/hostinterface/src/irqGenRtl.vhd                 ${DIR_RELEASE}
cp --parents common/hostinterface/src/dynamicBridgeRtl.vhd          ${DIR_RELEASE}
cp --parents common/hostinterface/src/statusControlRegRtl.vhd       ${DIR_RELEASE}
cp --parents common/hostinterface/src/parallelInterfaceRtl.vhd      ${DIR_RELEASE}
cp --parents common/lib/src/global.vhd                              ${DIR_RELEASE}

# create revision.txt
REV_FILE=${DIR_RELEASE}/${DIR_DOC}/revision.md
echo "Revision {#revision}" > $REV_FILE
echo "========" >> $REV_FILE
echo "" >> $REV_FILE
git log --format="- %s" -- */hostinterface/* */lib/* >> $REV_FILE
