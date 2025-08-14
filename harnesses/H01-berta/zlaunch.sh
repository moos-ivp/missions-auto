#!/bin/bash 
#------------------------------------------------------------ 
#   Script: zlaunch.sh    
#   Author: Michael Benjamin   
#   LastEd: June 2025
#------------------------------------------------------------
#  Part 1: Set convenience functions for producing terminal
#          debugging output, and catching SIGINT (ctrl-c).
#------------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }
on_exit() { echo; echo "$ME: Halting all apps"; kill -- -$$; }
trap on_exit SIGINT

# Catch SIGTERM so we don't come down with our own kill below
trap "echo zlaunch.sh has received sigterm" SIGTERM

#------------------------------------------------------------
#  Part 2: Set global variable default values
#------------------------------------------------------------
ME=`basename "$0"`
CMD_ARGS=""
VERBOSE=""
JUST_MAKE=""
MISSION_DIR="${HOME}/research/missions-auto/01-berta"
HARNESS_DIR="${PWD}"
AMT=1
TIME_WARP="11"
NOGUI=""

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    CMD_ARGS+="${ARGI} "
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME: [OPTIONS] [time_warp]                     "
	echo "                                               "
	echo "Options:                                       "
	echo "  --help, -h         Show this help message    " 
	echo "  --verbose, -v      Verbose, confirm launch   "
        echo "  --just_make, -j    Only create targ files    "
	echo "                                               "
	echo "  --amt=<num>        Number of runs to execute " 
	echo "  --nogui            Run in headless mode      " 
	echo "                                               "
	echo "Examples:                                      "
	echo "  ./zlaunch.sh 15                              "
	echo "  ./zlaunch.sh --nogui                         "
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 11 ]; then
        TIME_WARP=$ARGI
    elif [ $ARGI = "-v" ]; then
        VERBOSE="yes"
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
        JUST_MAKE=$ARGI
    elif [ ${ARGI} = "--nogui" ]; then
        NOGUI=$ARGI
    elif [ "${ARGI:0:6}" = "--amt=" ]; then
        AMT="${ARGI#--amt=*}"
    else
	echo "$ME: Bad arg:" $ARGI "Exit Code 1."
        exit 1
    fi
done

#------------------------------------------------------------
#  Part 4: Prepare the mission
#------------------------------------------------------------
STEM="$MISSION_DIR/meta_shoreside.moos"
TARG="$MISSION_DIR/meta_shoreside.moosx"
PATCH="$HARNESS_DIR/all-shoreside.xmoos"

PATCH+=" $HARNESS_DIR/b00-shoreside.xmoos"

vecho "MISSION_DIR:$MISSION_DIR"
vecho "HARNESS_DIR:$HARNESS_DIR"

#------------------------------------------------------------
#  Part 4: CD to the MISSION_DIR and update / run
#------------------------------------------------------------
if [ ! -d "${MISSION_DIR}" ]; then
    echo "[${MISSION_DIR}] not found. Exit 5."
    exit 5
fi
cd $MISSION_DIR

for ((j=0; j<$AMT; ++j)); do
    ./clean.sh; ktm
    nspatch --stem=$STEM $PATCH --targ=$TARG 
    XLAUNCH_ARGS=" --max_time=800 $NOGUI $JUST_MAKE $TIME_WARP "
    xlaunch.sh $XLAUNCH_ARGS $MISSION_ARGS
    echo "JUST_MAKE:[$JUST_MAKE]"
    if [ "${JUST_MAKE}" = "" ]; then
	sleep 1; ktm; sleep 1; mykill.sh -q;
    fi
done

exit 0


