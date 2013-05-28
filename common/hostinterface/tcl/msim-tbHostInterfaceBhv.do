#Repo root
set ROOT ../../..

#Stim file
set pcpPathStim $ROOT/common/hostinterface/tb/tbHostInterface_pcp_stim.txt
set hostPathStim $ROOT/common/hostinterface/tb/tbHostInterface_ap_stim.txt

echo "************************************************************************"
echo " CREATE WORK LIBRARY"
echo "************************************************************************"

vlib work

echo ""
echo "************************************************************************"
echo " COMPILE SOURCES"
echo "************************************************************************"

vcom -work work $ROOT/common/lib/src/global.vhd
vcom -work work $ROOT/common/util/src/clkGenBhv.vhd
vcom -work work $ROOT/common/util/src/resetGenBhv.vhd
vcom -work work $ROOT/common/util/src/busMasterBhv.vhd
vcom -work work $ROOT/common/util/src/spRamBhv.vhd
vcom -work work $ROOT/common/lib/src/addr_decoder.vhd
vcom -work work $ROOT/common/lib/src/binaryEncoderRtl.vhd
vcom -work work $ROOT/common/lib/src/edgedet.vhd
vcom -work work $ROOT/common/lib/src/lutFileRtl.vhd
vcom -work work $ROOT/common/lib/src/registerFileRtl.vhd
vcom -work work $ROOT/common/lib/src/sync.vhd
vcom -work work $ROOT/common/hostinterface/src/hostInterfacePkg.vhd
vcom -work work $ROOT/common/hostinterface/src/statusControlRegRtl.vhd
vcom -work work $ROOT/common/hostinterface/src/magicBridgeRtl.vhd
vcom -work work $ROOT/common/hostinterface/src/irqGenRtl.vhd
vcom -work work $ROOT/common/hostinterface/src/hostInterfaceRtl.vhd
vcom -work work $ROOT/common/hostinterface/tb/tbHostInterfaceBhv.vhd

echo ""
echo "************************************************************************"
echo " INITIALIZE SIMULATION"
echo "************************************************************************"

vsim tbHostInterface -lib work -g gPcpStim=$pcpPathStim -g gHostStim=$hostPathStim

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
