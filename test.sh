#!/bin/bash

echo "the # here does not begin a comment."
echo 'The # here does not begin a comment.'
echo The \# here does ont begin a comment.
echo The # here gegins a comment.

echo ${PATH#*:} # parameter substituion, not a comment.
echo $((2#101011)) #base conversion, not a commet.
###################################
filename='test.sh'

echo "comment in same line"
if [ -x "$filename" ]; then # Note the spage after the semicolon. #+
	echo "File $filename exists."; 
	cp $filename $filename.back
else
	echo "file $filename not found."; touch $filename
fi; echo "file test complete" 

variable='abc'
case "$variable" in
	abc) echo "\$variable = abc" ;;
	xyz) echo "\$variable = xyz" ;;
esac

###################################
: # null command, the shell builtin 'true'
echo $?
# 0
#-----------------------------------
while :
do
	operation-1
	operation-2
	...
	operation-n
done
# Same as:
# while true
#do
#...
#done

#--------------------------
: > data.xxx
# File "data.xxx" now empty.
# Same effect as cat /dev/null >data.xxx
# However, this does not fork a new process, since ":" is a builtin.

###################################

for file in /{,usr/}bin/*calc
#^ Find all executable files ending in "calc"
#+ in /bin and /usr/bin directories.
do
	if [ -x "$file" ]
	then
		echo $file
	fi
done

#####################################

(( var0 = var1<98?9:21 ))
#                ^ ^
#if [ "$var1" -lt 98 ]
#then
#	var0=9
#else
#	var0=21
#fi

#####################################

echo \"{These,words,are,quoted}\" # " prefix and suffix
# "These" "words" "are" "quoted"

cat {file1,file2,file3} > combined_file
# Concatenates the files file1, file2, and file3 into combined_file.

cp file22.{txt,backup}
# Copies "file22.txt" to "file22.backup"

#-------------------------------------

a=123
{ a=321; }
echo "a = $a"
# a = 321
(value inside code block)


a="ls -l"
echo $a
echo
#echo "$a"


