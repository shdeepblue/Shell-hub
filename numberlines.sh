#!/bin/bash

# A program can change the current net gateway to specific one
# Usage 'numberlines filename'
# Created: 15th August 2011 by SC

MINPARAMS=1
USAGE="Usage: $(basename $0) 250"

# Check whether user input the gw that need to be changed to
if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
  echo $USAGE
  exit
fi 


for FILENAME in $1
do
  linecount="1"
  (while read line 
  do
    echo "${linecount}: $line"
    linecount="$(( $linecount + 1 ))"
  done) < $FILENAME
done

exit 0
