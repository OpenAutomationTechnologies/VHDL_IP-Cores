#Repo root
set ROOT ../../..

echo "************************************************************************"
echo " CREATE WORK LIBRARY"
echo "************************************************************************"

vlib work

echo ""
echo "************************************************************************"
echo " COMPILE SOURCES"
echo "************************************************************************"

vcom -work work $ROOT/common/lib/src/sync.vhd
vcom -work work $ROOT/common/lib/src/global.vhd
vcom -work work $ROOT/common/lib/src/sync.vhd
vcom -work work $ROOT/common/lib/src/edgedet.vhd
vcom -work work $ROOT/common/util/src/clkGenBhv.vhd
vcom -work work $ROOT/common/util/src/resetGenBhv.vhd
vcom -work work $ROOT/common/hostinterface/src/hostInterfacePkg.vhd
vcom -work work $ROOT/common/hostinterface/src/parallelInterfaceRtl.vhd
vcom -work work $ROOT/common/hostinterface/tb/tbParallelInterfaceBhv.vhd

echo ""
echo "************************************************************************"
echo " INITIALIZE SIMULATION"
echo "************************************************************************"

vsim tbParallelInterface -lib work -g gMultiplex=1

view objects
view locals
view source
view wave

add wave -ports DUT/*

echo ""
echo "************************************************************************"
echo " RUN SIMULATION"
echo "************************************************************************"

run -all
