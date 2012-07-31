#!/bin/bash
# mail-format.sh: format e-mail messages.

# get ride of carets, tabs, and also folds excessively long lines.

# ===========================================================================
#         standard check for script argument(s)

ARGS=1
E_BADARGS=65
E_NOFILE=66

if [ $# -ne $ARGS ] # correct number of arguments passed to script?
then
	echo "Usage: `basename $0` filename"
	exit $E_BADARGS
fi

if [ -f "$1" ]  # check if file exists.
then
	file_name=$1
else
	echo "file \"$1\" does not exist."
	exit $E_NOFILE
fi

#=============================================================================

MAXWIDTH=70  # Width to fold excessively long lines to.

# -----------------------------------
# A variable can hold a sed script.
sedscrpt='s/^>//
s/^  *>//
s/^  *//
s/          *//'
# -------------------------------------



