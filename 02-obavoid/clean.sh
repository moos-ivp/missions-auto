#!/bin/bash 
#--------------------------------------------------------------
#   Script: clean.sh                                    
#   Author: Michael Benjamin  
#     Date: June 2020     
#----------------------------------------------------------
#  Part 1: Declare global var defaults
#----------------------------------------------------------
VERBOSE=""

#-------------------------------------------------------
#  Part 1: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "clean.sh [SWITCHES]        "
	echo "   --verbose, -v           "
	echo "   --help, -h              "
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="-v"
    else
	echo "clean.sh: Bad Arg:" $ARGI
	exit 1
    fi
done

#-------------------------------------------------------
#  Part 2: Do the cleaning!
#-------------------------------------------------------
if [ "${VERBOSE}" = "-v" ]; then
    echo "Cleaning: $PWD"
fi

rm -rf  $VERBOSE   MOOSLog_* XLOG_* LOG_* \#*
rm -f   $VERBOSE   *~  *.moos++ *.tar tmp_*
rm -f   $VERBOSE   targ_* results.* vnames.txt
rm -f   $VERBOSE   vpositions.txt vspeeds.txt 
rm -f   $VERBOSE   vcolors.txt vheadings.txt 
rm -f   $VERBOSE   obstacles.txt 
rm -f   $VERBOSE   .LastOpenedMOOSLogDirectory

