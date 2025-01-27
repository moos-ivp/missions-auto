#!/bin/bash
#----------------------------------------------------------
#  Script: launch.sh
#  Author: Michael Benjamin
#  LastEd: Dec 12th 2023
#----------------------------------------------------------
#  Part 1: Initialize default values
#----------------------------------------------------------
ME=$(basename "$0")
TIME_WARP=1
JUST_MAKE="no"
LAUNCH_GUI="yes"
VERBOSE=""
DRESET="false"
POINTS="false"

VNAME="abe"
VCOLOR="light_green"
SHORE_PSHARE="9200"
MODEL_RADIUS=5
OBSTACLE_AMT=8
SEP=10
ENC=25

#----------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#----------------------------------------------------------
for ARGI; do
    CMD_ARGS+=" ${ARGI}"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
        echo "launch.sh [SWITCHES] [time_warp]                   "
        echo "  --help, -h                                       "
        echo "    Show this help message                         "
        echo "  --just_make, -j                                  "
        echo "    Just create targ files, no launch              "
        echo "  --verbose, -v                                    "
        echo "    Verbose output, confirm before launching       "
        echo "  --dynamic_reset, -d                              "
        echo "    Enable dynamic resetting of obstacles in the   "
        echo "    obstacle simulator                             "
        echo "  --amt=<dist> (Default 8)                         "
        echo "    Number of obstacles                            "
        echo "  --enc=<amt>                                      "
        echo "    Number of encounters in headless mission       "
        echo "  --sep=<dist>                                     "
        echo "    Min separation between obstacles (Default 10)  "
        echo "  --model_radius=<dist>                            "
        echo "    (Default 5)                                    "
        echo "  --points, -p                                     "
        echo "    Enable the simulated sensor points mode in the "
        echo "    obstacle simulator                             "
        exit 0
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
        JUST_MAKE="yes"
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
        VERBOSE="--verbose"
    elif [ "${ARGI}" = "--auto" -o "${ARGI}" = "--nogui" ]; then
        LAUNCH_GUI="no"
    elif [ "${ARGI}" = "--dynamic_reset" -o "${ARGI}" = "-d" ]; then
        DRESET="true"
    elif [ "${ARGI}" = "--points" -o "${ARGI}" = "-p" ]; then
        POINTS="true"
    elif [ "${ARGI:0:6}" = "--amt=" ]; then
        OBSTACLE_AMT="${ARGI#--amt=*}"
    elif [ "${ARGI:0:6}" = "--enc=" ]; then
        ENC="${ARGI#--enc=*}"
    elif [ "${ARGI:0:6}" = "--sep=" ]; then
        SEP="${ARGI#--sep=*}"
    elif [[ "${ARGI}" = "--model_radius="* ]]; then
        MODEL_RADIUS="${ARGI#--model_radius=*}"
    else
        echo "$ME Bad arg:" $ARGI " Exiting with code: 1"
        exit 1
    fi
done

#--------------------------------------------------------------
#  Part 4: If verbose, show vars and confirm before launching
#--------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then
    echo "===================================================="
    echo "         launch.sh SUMMARY                          "
    echo "===================================================="
    echo "$ME"
    echo "CMD_ARGS =       [${CMD_ARGS}]      "
    echo "TIME_WARP =      [${TIME_WARP}]     "
    echo "----------------------------------  "
    echo "VNAME =          [${VNAME}]         "
    echo "OBSTACLE_AMT =   [${OBSTACLE_AMT}]  "
    echo "SEP =            [${SEP}]           "
    echo "ENC =            [${ENC}]           "
    echo -n "Hit the RETURN key to continue with launching"
    read ANSWER
fi

#-------------------------------------------------------
#  Part 3: Generate Obstacles
#-------------------------------------------------------
source fld_base.opf
EXIT_CODE=1
TRIES_LEFT=20
while [[ $EXIT_CODE -ne 0 && $TRIES_LEFT -gt 0 ]]; do
    TRIES_LEFT=$((TRIES_LEFT - 1))
    echo "obstacle file generated" >obstacles.txt
    gen_obstacles --poly=$BHT:$HHT:$HPT:$BPT \
        --min_size=5 --max_size=8 \
        --amt=$OBSTACLE_AMT \
        --min_range=$SEP >>obstacles.txt

    EXIT_CODE=$?
    if [ $EXIT_CODE != 0 ]; then
        echo "$ME Unable to Gen Obstacles. Trying again...."
    fi
done
if [ $EXIT_CODE != 0 ]; then
    echo "$ME Unable to Gen Obstacles. Exit code 2."
    exit 2
fi

START_POS="$CGT,190"

#-------------------------------------------------------
#  Part 3: Create the .moos and .bhv files.
#-------------------------------------------------------
LAUNCH_ARGS="--macros=fld_base.opf -i -f WARP=$TIME_WARP"

nsplug meta_vehicle.moos targ_$VNAME.moos $LAUNCH_ARGS \
    VNAME=$VNAME PSHARE_PORT="9201" \
    MOOS_PORT="9001" SHORE_PSHARE=$SHORE_PSHARE \
    VCOLOR=$VCOLOR START_POS=$START_POS \
    MODEL_RADIUS=$MODEL_RADIUS

nsplug meta_shoreside.moos targ_shoreside.moos $LAUNCH_ARGS \
    MOOS_PORT="9000" PSHARE_PORT=$SHORE_PSHARE \
    VNAMES=$VNAME1 DRESET=$DRESET \
    POINTS=$POINTS LAUNCH_GUI=$LAUNCH_GUI \
    SEP=$SEP TEST_ENCOUNTERS=$ENC

nsplug meta_vehicle.bhv targ_$VNAME.bhv $LAUNCH_ARGS \
    VNAME=$VNAME START_POS=$START_POS \
    SPEED=1.5

if [ ${JUST_MAKE} = "yes" ]; then
    echo "$ME: Files assembled; nothing launched; exiting per request."
    exit 0
fi

#----------------------------------------------------------
#  Part 4: Launch the processes
#----------------------------------------------------------
echo "Launching Shoreside MOOS Community. WARP is" $TIME_WARP
pAntler targ_shoreside.moos >&/dev/null &

echo "Launching $VNAME MOOS Community. WARP is" $TIME_WARP
pAntler targ_$VNAME.moos >&/dev/null &

#--------------------------------------------------------------
#  Part 5: Unless auto-launched, launch uMAC until mission quit
#--------------------------------------------------------------
if [ "${LAUNCH_GUI}" = "yes" ]; then
    uMAC targ_shoreside.moos --node=shoreside --proc=pMissionEval
    kill -- -$$
fi

exit 0
