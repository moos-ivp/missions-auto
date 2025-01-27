#!/bin/bash -e
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
VEHICLE_AMT="1"
VERBOSE=""
RAND_VPOS="no"

# Custom
OBSTACLE_AMT=8
OBSTACLE_SEP=10

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
	echo "                                               "
	echo "Options (custom):                              "
	echo "  --obs=<8>          Number of Obstacles       " 
	echo "  --sep=<10>         Min dist between obstacles"
	exit 0;
    elif [ "${ARGI:0:6}" = "--amt=" ]; then
        VEHICLE_AMT="${ARGI#--amt=*}"
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE=$ARGI
    elif [ "${ARGI}" = "--rand" -o "${ARGI}" = "-r" ]; then
        RAND_VPOS="yes"

    elif [ "${ARGI:0:6}" = "--obs=" ]; then
        OBSTACLE_AMT="${ARGI#--obs=*}"
    elif [ "${ARGI:0:6}" = "--sep=" ]; then
        OBSTACLE_SEP="${ARGI#--sep=*}"

    else 
	echo "$ME: Bad Arg: $ARGI. Exit Code 1."
	exit 1
    fi
done

#------------------------------------------------------------
#  Part 4: Source local coordinate grid if it exits
#------------------------------------------------------------
source fld_base.opf

#------------------------------------------------------------
#  Part 5: Set starting positions, speeds, vnames, colors
#------------------------------------------------------------
if [ "${RAND_VPOS}" = "yes" -o  ! -f "vpositions.txt" ]; then
    pickpos --poly="29,4,: 52,17 : 60,0 : 34,-7" \
            --amt=$VEHICLE_AMT --hdg="-48,-57,0" > vpositions.txt
fi

pickpos --amt=$VEHICLE_AMT --vnames  > vnames.txt
pickpos --amt=$VEHICLE_AMT --colors  > vcolors.txt
pickpos --amt=$VEHICLE_AMT --spd=2:2 > vspeeds.txt

#------------------------------------------------------------
#  Part 6: Set other aspects of the field, e.g., obstacles
#------------------------------------------------------------
echo "obstacle file generated" > obstacles.txt
gen_obstacles --poly=$BHT:$HHT:$HPT:$BPT  \
	      --min_size=5 --max_size=8   \
	      --amt=$OBSTACLE_AMT         \
	      --min_range=$OBSTACLE_SEP >> obstacles.txt

if [ $? != 0 ]; then
    echo "$ME Unable to Gen Obstacles. Exit code 2."
    exit 2
fi

#------------------------------------------------------------
#  Part 7: If verbose, show file contents
#------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then
    echo "--------------------------------------"
    echo "VEHICLE_AMT = $VEHICLE_AMT"
    echo "RAND_VPOS   = $RAND_VPOS"
    echo "--------------------------------------(pos/spd)"
    echo "vpositions.txt:"; cat  vpositions.txt
    echo "vspeeds.txt:";    cat  vspeeds.txt
    echo "--------------------------------------(vprops)"
    echo "vnames.txt:";     cat  vnames.txt
    echo "vcolors.txt:";    cat  vcolors.txt
    echo "--------------------------------------(custom)"
    echo -n "Hit any key to continue"
    read ANSWER
fi


exit 0

