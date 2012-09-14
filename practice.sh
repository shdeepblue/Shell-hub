#!/bin/bash
LOG_DIR=/var/log
ROOT_UID=0 #Only users with $UID 0 have root privileges.
LINES=50 #Default number of lines saved.
E_XCD=86 #Can't change director
E_NOTROOT=87 #Non-root exit error.


# Run as root, of course.
if [ "$UID" -ne "$ROOT_UID" ]
	then
		echo "Must be root to run this script."
		#exit $E_NOTROOT
	else
		echo " You are Root!"
fi

# Test whether command-line argument is present (non-empty).
if [ -n "$1" ] 
	then
		lines=$1
	else
		lines=$LINES # Default, if not specified on command-line.
fi




#Stephane Chazelas suggests the following,
#as a better way of checking command-line arguments,
#but this is still a bit advanced for this stage of the tutorial.

E_WRONGARGS=85 # Non-numerical argument (bad argument format).
case "$1" in
	"") lines=50;;
	*[!0-9]*) echo "Usage: `basename $0` file-to-cleanup"; exit $E_WRONGARGS;;
	*) lines=$1;;
esac
#Skip ahead to "Loops" chapter to decipher all this.

echo $lines
echo $LINES

# If cant change to specific directory will auto exit.
cd /var/log || {echo "Cannot change to necessary directory." >&2 exit $E_XCD; }






