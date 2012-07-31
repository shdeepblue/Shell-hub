#!/bin/bash
# rename_files.sh
#   rename file names to the specific name or types.

ARGS=2
E_BADARGS=85
ONE=1

if [ $# -ne $ARGS ]
then
	echo "Usage: `base name $0` old-pattern new-pattern"
	exit $E_BADARGS
fi

member=0   # keep track of how many files actually renamed.

for filename in *$1*
do
	if [ -f "$filename" ]
	then
		fname=`basename $filename`
		echo $fname | sed -e 's/$1/$2/'
		#mv $fname $n
		let "member+=1"

	fi
done

#if [ "$member" -eq "$ONE" ]
#then
	echo "$member file renamed."
#else
#	echo "$member files renamed."
#fi

exit $?
