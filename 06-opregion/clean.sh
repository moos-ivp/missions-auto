#!/bin/bash
#---------------------------------------------------------------
#   Script: clean.sh
#   Author: Mike Benjamin
#---------------------------------------------------------------
#  Part 1: Set global var defaults
#---------------------------------------------------------------
ME=`basename "$0"`
VERBOSE=""
ARCHIVE="yes"
ALL="no"

#-------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS]                              "
	echo "  --help, -h                               " 
	echo "    Display this help message              " 
	echo "  --verbose                                " 
	echo "    Verbose output                         " 
	echo "  --force, -f                              " 
	echo "    Will remove Logs instead of archiving  " 
	echo "  --all, -a                                " 
	echo "    Remove logs and clear arhived_logs     " 
	exit 0;	
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE="-v"
    elif [ "${ARGI}" = "--force" -o "${ARGI}" = "-f" ]; then
	ARCHIVE="no"
    elif [ "${ARGI}" = "--all" -o "${ARGI}" = "-a" ]; then
	ALL="yes"
    else 
	echo "$ME Bad Arg: $ARGI"
	exit 1
    fi
done

#-------------------------------------------------------
#  Part 3: Do the cleaning!
#-------------------------------------------------------

if [ "${ALL}" = "yes" ]; then
    rm -rf  $VERBOSE  MOOSLog_*  LOG_* XLOG_* archive_logs/*
elif [ "${ARCHIVE}" = "yes" ]; then
    mv -f LOG_*   archive_logs >& /dev/null
    mv -f XLOG_*  archive_logs >& /dev/null
else
    rm -rf  $VERBOSE  MOOSLog_*  LOG_* XLOG_*
fi

rm -f $VERBOSE  *~ targ_* *.moos++ 
rm -f $VERBOSE  .LastOpenedMOOSLogDirectory
rm -f $VERBOSE  vnames.txt vpositions.txt
rm -f $VERBOSE  vcolors.txt vspeeds.txt

exit 0
