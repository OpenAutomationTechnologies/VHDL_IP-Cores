#!/bin/bash
# Calls wavedrom to generate svg out of json
# E.g. call ./wavedrom.sh FILENAME.json

# First parameter is json file
JSON=$1

WAVEDROM=WaveDromEditor

# check if wavedrom is installed
which ${WAVEDROM} >> /dev/null

if [ $? -ne 0 ];
then
    echo "Wavedrom not found!"
    exit 1
fi

# Cut file extension to generate svg with same name
JSON_DIR=`dirname $JSON`
JSON_SRC=`basename $JSON .json`

# Call wavedrom and hope everything is fine!
# Note: Wavedrom does not return any error, instead GUI shows error msg!
printf "Convert $JSON_SRC ..."

${WAVEDROM} source ${PWD}/${JSON_DIR}/${JSON_SRC}.json svg ${PWD}/${JSON_DIR}/${JSON_SRC}.svg

printf " done\n"

exit 0
