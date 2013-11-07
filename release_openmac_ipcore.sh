#!/bin/bash
# ./release_openmac_ipcore.sh RELEASE_DIR IP_VERSION
# e.g.: $ ./release_powerlink_ipcore release v1_00_a

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

DIR_AXI="axi_openmac_${IP_VERSION}"

# create dir structure
echo "create release dir..."
mkdir -p ${DIR_RELEASE}

# copy docs
# TODO

# copy Altera POWERLINK
echo "copy Altera openmac ipcore..."
cp --parents altera/components/sdc/openmacTop-mii.sdc         ${DIR_RELEASE}
cp --parents altera/components/sdc/openmacTop-rmii.sdc        ${DIR_RELEASE}
cp --parents altera/components/img/br.png                     ${DIR_RELEASE}
cp --parents altera/components/openmac_hw.tcl                 ${DIR_RELEASE}
cp --parents altera/components/tcl/global.tcl                 ${DIR_RELEASE}
cp --parents common/lib/src/global.vhd                        ${DIR_RELEASE}
cp --parents common/lib/src/addrDecodeRtl.vhd                 ${DIR_RELEASE}
cp --parents common/lib/src/cntRtl.vhd                        ${DIR_RELEASE}
cp --parents common/lib/src/dpRam-e.vhd                       ${DIR_RELEASE}
cp --parents common/lib/src/dpRamSplx-e.vhd                   ${DIR_RELEASE}
cp --parents common/lib/src/edgedetectorRtl.vhd               ${DIR_RELEASE}
cp --parents common/lib/src/synchronizerRtl.vhd               ${DIR_RELEASE}
cp --parents common/lib/src/syncTog-rtl-ea.vhd                ${DIR_RELEASE}
cp --parents common/fifo/src/asyncFifo-e.vhd                  ${DIR_RELEASE}
cp --parents common/openmac/src/openmacPkg-p.vhd              ${DIR_RELEASE}
cp --parents common/openmac/src/dma_handler.vhd               ${DIR_RELEASE}
cp --parents common/openmac/src/master_handler.vhd            ${DIR_RELEASE}
cp --parents common/openmac/src/openMAC_DMAmaster.vhd         ${DIR_RELEASE}
cp --parents common/openmac/src/openfilter-rtl-ea.vhd         ${DIR_RELEASE}
cp --parents common/openmac/src/openhub-rtl-ea.vhd            ${DIR_RELEASE}
cp --parents common/openmac/src/openmacTimer-rtl-ea.vhd       ${DIR_RELEASE}
cp --parents common/openmac/src/phyActGen-rtl-ea.vhd          ${DIR_RELEASE}
cp --parents common/openmac/src/phyMgmt-rtl-ea.vhd            ${DIR_RELEASE}
cp --parents common/openmac/src/convRmiiToMii-rtl-ea.vhd      ${DIR_RELEASE}
cp --parents common/openmac/src/openMAC.vhd                   ${DIR_RELEASE}
cp --parents common/openmac/src/openmacTop-rtl-ea.vhd         ${DIR_RELEASE}
cp --parents altera/lib/src/dpRam-rtl-a.vhd                   ${DIR_RELEASE}
cp --parents altera/lib/src/dpRamSplx-rtl-a.vhd               ${DIR_RELEASE}
cp --parents altera/fifo/src/asyncFifo-syn-a.vhd              ${DIR_RELEASE}
cp --parents altera/openmac/src/alteraOpenmacTop-rtl-ea.vhd   ${DIR_RELEASE}

# copy Xilinx AXI OPENMAC
#echo "copy Xilinx axi openmac ipcore..."
# TODO
