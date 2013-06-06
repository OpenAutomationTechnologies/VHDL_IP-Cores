#!/bin/bash
#
echo
echo "---tbTripleBuf---"

ROOT=../../..

SRC_LIST="common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/resetGenBhv.vhd \
common/lib/src/tripleBufRtl.vhd \
common/lib/tb/tbTripleBufBhv.vhd"

TOP_LEVEL=tbTripleBuf

chmod +x $ROOT/common/util/sh/msim-sim.sh
exec "$ROOT/common/util/sh/msim-sim.sh" $TOP_LEVEL $SRC_LIST

exit $ret
