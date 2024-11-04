#!/bin/bash 
#------------------------------------------------------------
#   Script: init_field.sh
#   Author: M.Benjamin
#   LastEd: May 26 2024
#------------------------------------------------------------
#  Part 1: A convenience function for producing terminal
#          debugging/status output depending on verbosity.
#------------------------------------------------------------
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }

#------------------------------------------------------------
#  Part 2: Set global variable default values
#------------------------------------------------------------
ME=`basename "$0"`
VEHICLE_AMT="2"
VERBOSE=""
RAND_VPOS="no"
REGION_A="-20,-60:20,-60:20,-90:-20,-90"
#REGION_A="-20,-20:20,-20:20,-110:-20,-110"
REGION_A_PT="0,-65"
#REGION_B="150,-20:190,-20:190,-110:150,-110"
REGION_B="150,-60:190,-60:190,-90:150,-90"
REGION_B_PT="170,-65"

#------------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#------------------------------------------------------------
for ARGI; do
    CMD_ARGS+=" ${ARGI}"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS] [time_warp]                      "
	echo "                                               "
	echo "Options:                                       "
	echo "  --amt=N            Num vehicles to launch    "
	echo "  --verbose, -v      Verbose, confirm values   "
	echo "  --rand, -r         Rand vehicle positions    "
       exit 0;
    elif [ "${ARGI:0:6}" = "--amt=" ]; then
        VEHICLE_AMT="${ARGI#--amt=*}"
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE=$ARGI
    elif [ "${ARGI}" = "--rand" -o "${ARGI}" = "-r" ]; then
        RAND_VPOS="yes"

    else 
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#------------------------------------------------------------
#  Part 4: Source local coordinate grid if it exits
#------------------------------------------------------------

#------------------------------------------------------------
#  Part 5: Set starting positions, speeds, vnames, colors
#------------------------------------------------------------
if [ "${RAND_VPOS}" = "yes" -o  ! -f "${VPOS_FILE}" ]; then
    pickpos --poly="${REGION_A}" --amt=1 --hdg=$REGION_B_PT,0  > vpositions.txt
    pickpos --poly="${REGION_B}" --amt=1 --hdg=$REGION_A_PT,0 >> vpositions.txt
else
    echo "$REGION_A_PT"  > vpositions.txt
    echo "$REGION_B_PT" >> vpositions.txt
fi

echo "$REGION_B_PT"  > vdests.txt
echo "$REGION_A_PT" >> vdests.txt

if [ "${RAND_VPOS}" = "yes" -o  ! -f "vspeeds.txt" ]; then
    pickpos --amt=$VEHICLE_AMT --spd=1:2 > vspeeds.txt
fi

pickpos --amt=$VEHICLE_AMT --vnames  > vnames.txt
pickpos --amt=$VEHICLE_AMT --colors  > vcolors.txt


#------------------------------------------------------------
#  Part 6: Set other aspects of the field, e.g., obstacles
#------------------------------------------------------------

#------------------------------------------------------------
#  Part 7: If verbose, show file contents
#------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then
    echo "--------------------------------------"
    echo "VEHICLE_AMT = $VEHICLE_AMT "
    echo "RAND_VPOS   = $RAND_VPOS   "
    echo "CIRCLE      = $CIRCLE      "
    echo "START       = $START       "
    echo "--------------------------------------(pos/spd)"
    echo "vpositions.txt:"; cat  vpositions.txt
    echo "--------------------------------------(custom)"
    echo "joust.txt:";      cat  joust.txt
    echo -n "Hit any key to continue"
    read ANSWER
fi

exit 0

