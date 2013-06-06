#!/bin/bash
#
echo
echo "---tbBinaryEncoder---"

ROOT=../../..

SRC_LIST="common/lib/src/global.vhd \
common/util/src/clkGenBhv.vhd \
common/util/src/resetGenBhv.vhd \
common/lib/src/binaryEncoderRtl.vhd \
common/lib/tb/tbBinaryEncoderBhv.vhd"

TOP_LEVEL=tbBinaryEncoder

chmod +x $ROOT/common/util/sh/msim-sim.sh
exec "$ROOT/common/util/sh/msim-sim.sh" $TOP_LEVEL $SRC_LIST

exit $ret
