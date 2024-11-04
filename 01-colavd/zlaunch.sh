#!/bin/bash 
#----------------------------------------------------------
#  Script: zlaunch.sh
#  Author: Michael Benjamin
#  LastEd: Oct 29th 2024
#----------------------------------------------------------
#  Part 1: Set convenience functions for producing terminal
#          debugging output, and catching SIGTERM.
#----------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }
on_exit() { echo; echo "Halting all zlaunch.sh apps"; kill -- -$$; exit; }
trap on_exit SIGINT
trap "echo received sigterm2" SIGTERM

#----------------------------------------------------------
#  Part 1: Set global var defaults
#----------------------------------------------------------
ME=`basename "$0"`
TIME_WARP=1
VERBOSE=""
FLOW_DOWN_ARGS=""
EACH=1

#----------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#----------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [SWITCHES] [time_warp]                      " 
	echo "  --help, -h      Show this help message               " 
        echo "  --verbose, -v   Enable verbose mode                  "
	echo "  --each=N        Run each sim N times. Default is 1   " 
	echo "  --res, -r       Tell xlaunch to generate report      " 
	echo "  --send, -s      Tell xlaunch to gen and send report  " 
	echo "  --silent        Run silently, no iSay                " 
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then 
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
        FLOW_DOWN_ARGS+="${ARGI} "
        VERBOSE="yes"
    elif [ "${ARGI:0:7}" = "--each=" ]; then
        EACH="${ARGI#--each=*}"
    elif [ "${ARGI}" = "--res" -o "${ARGI}" = "-r" ]; then
        FLOW_DOWN_ARGS+="${ARGI} "
    elif [ "${ARGI}" = "--send" -o "${ARGI}" = "-s" ]; then
        FLOW_DOWN_ARGS+="${ARGI} "
    elif [ "${ARGI}" = "--silent" ]; then
        FLOW_DOWN_ARGS+="${ARGI} "
    else 
        echo "$ME Bad arg:" $ARGI "Exiting with code: 1"
        exit 1
    fi
done

#----------------------------------------------------------
#  Part 3: Determine random zhash for this zbatch
#----------------------------------------------------------
ZBATCH=`mhash_gen -z`
vecho "ZBATCH: " $ZBATCH

#----------------------------------------------------------
#  Part 4: Begin Testing
#----------------------------------------------------------
FLOW_DOWN_ARGS+="${TIME_WARP} --nogui -a --zbatch=${ZBATCH}" 
vecho "zlaunch.sh FLOW_DOWN_ARGS:[$FLOW_DOWN_ARGS]"

for ((i=0; i<8; ++i)); do 
    STEP=5
    DELTA=$(($STEP * $i))
    for ((j=0; j<$EACH; ++j)); do
	MIN_UTIL_CPA=$((5+$DELTA))
	MAX_UTIL_CPA=$((20+$DELTA))
	TEST_ARGS="--min_util_cpa=$MIN_UTIL_CPA"
	TEST_ARGS+=" --max_util_cpa=$MAX_UTIL_CPA"
	xlaunch.sh $FLOW_DOWN_ARGS $TEST_ARGS 
    done
done

exit 0

# Convert raw results, to a file with averages over all experiments
if [ -f "results.log" ]; then
    alogavg results.log > results.dat
fi

# Build a plot using matlab
if [ -f "results.dat" ]; then
    matlab plotx.m -nodisplay -nosplash -r "plotx(\"results.dat\", \"plot.png\")"
fi
