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
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	echo "clean.sh [SWITCHES]        "
	echo "  --verbose                " 
	echo "  --help, -h               " 
	exit 0;	
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ] ; then
	VERBOSE="-v"
    else 
	echo "clean.sh: Bad Arg:[$ARGI]. Exit Code 1."
	exit 1
    fi
done

#-------------------------------------------------------
#  Part 3: Do the cleaning!
#-------------------------------------------------------
if [ "${VERBOSE}" = "-v" ]; then
    echo "Cleaning: $PWD"
fi
rm -rf  $VERBOSE   MOOSLog_*  XLOG_* LOG_* 
rm -f   $VERBOSE   *~  *.moos++ results.log
rm -f   $VERBOSE   targ_* tmp_* *.tar
rm -f   $VERBOSE   .LastOpenedMOOSLogDirectory
rm -f   $VERBOSE   .mem_info* vloiterpos.txt vpositions.txt vdests.txt
rm -f   $VERBOSE   vnames.txt vcolors.txt vcolors.txt vspeeds.txt
rm -f   $VERBOSE   *.moosx *.bhvx

for file in *; do
    if [ -d $file ]; then
	ls $file/*.alog >& /dev/null
	if [ $? = 0 ]; then
	    rm -rf $file
	fi
    fi
done
