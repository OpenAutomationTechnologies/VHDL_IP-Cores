#!/bin/bash
#
echo
echo "---tbAddrDecode---"

ROOT=../../..

SRC_LIST="common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/resetGenBhv.vhd \
common/lib/src/addrDecodeRtl.vhd \
common/lib/tb/tbAddrDecodeBhv.vhd"

TOP_LEVEL=tbAddrDecode

chmod +x $ROOT/common/util/sh/msim-sim.sh
exec "$ROOT/common/util/sh/msim-sim.sh" $TOP_LEVEL $SRC_LIST

exit $ret
