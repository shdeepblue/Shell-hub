


#======================================
function test_f2
{
echo "Select a terminal type:"
cat <<EOF
1)linux
2)xterm
3)sun
EOF
read choice
case $choice in
1)TERM=linux
   export TERM
   ;;
2)TERM=xterm
   export TERM
;;
3)TERM=sun
   export TERM
;;
*) echo "please select correct chioce,ths!"
;;
esac
echo "TERM is $TERM"
}
#=====================================
function test_f3
{
	PS3="Please choose one of the three boys or quit:"
	select choice in Linux Xterm Sun
	do
		case $choice in
			Linux) echo "linux" 
			break
			;;
			Xterm) echo "Xterm" 
			break
			;;
			Sun)echo "Sun" 
			break
			;;
			*) echo "wrong input"
			;;
			esac
	done
}

function test_f4
{
	#Name:shift
	#Usage:shift test

	while (($#>0))
	do
	    echo "$*"
	    shift
	done
}
#this si a test=====================================
function test_f5
{
#break n   ---n 代表退出第几层循环，默认退出一层。continue n 类似
#Usage : break test

declare -i x=0
declare -i y=0
	while true
	do
		while (( x<20 ))
		do
   			x=$x+1
   			echo $x
   			if (( $x==10 ));then
    			echo "if"
    			#break
				break 2
   			fi
		done
		echo "loop end"
		y=$y+1
		if (($y>5));then
   			break
		fi
	done
}

#====================================
function test_f6
{
# read each line from file

	#while read line
	#do
	#	echo $line
	#done</home/shichao/Desktop/neeee

	cat /home/shichao/Desktop/neeee | while read line
	do
		echo $line
	done
}

#====================================
function test_f7
{
list="aa bb cc dd"
set -- `echo $list`
for((i=1;i<5;i++))
do
	echo $1
	shift
done
}

#====================================
function test_f8
{
	var=Thisisatestlink
	awk 'BEGIN {print length("'$var'")}'
	{#var}
	echo -n $var | wc -c
	expr length $var
	expr $var : .\*
	expr match $var .*

}

#======================================
function test_f9
{
# 1. 让使用者输入文件名称,并取得 fileuser 这个变量;
echo -e "I will use 'touch' command to create 3 files."
read -p "Please input the filename what you want: " fileuser
# 2. 为了避免使用者随意按 Enter ,利用变量功能分析文件名是否有设定?
filename=${fileuser:-"filename"}
echo $filename
}

#======================================
function test_f10
{
# 1. 让使用者输入档名,并且判断使用者是否真的有输入字符串?
echo -e "The program will show you that filename is exist which input by you.\n\n"
read -p "Input a filename : " filename
test -z $filename && echo "You MUST input a filename." && exit 0
# 2. 判断档案是否存在?
test ! -e $filename && echo "The filename $filename DO NOT exist" && exit 0
# 3. 开始判断档案类型与属性
test -f $filename && filetype="regulare file"
test -d $filename && filetype="directory"
test -r $filename && perm="readable"
test -w $filename && perm="$perm writable"
test -x $filename && perm="$perm executable"
# 4. 开始输出信息!
echo "The filename: $filename is a $filetype"
echo "And the permission are : $perm"

}

function test_f10_1
{
read -p "Please input (Y/N): " yn
[ "$yn" == "Y" -o "$yn" == "y" ] && echo "OK, continue" && exit 0
[ "$yn" == "N" -o "$yn" == "n" ] && echo "Oh, interrupt!" && exit 0
echo "I don't know what is your choise" && exit 0

}

function test_f11
{
# this test can see the init param for shell scripts 
#The program will show it's name and first 3 parameters.
echo "The script name is => $0" 
[ -n "$1" ] && echo "First paramter is => $1" || exit 0 

[ -n "$2" ] && echo "Second paramter is => $2" || exit 0 

[ -n "$3" ] && echo "Third paramter is => $3" || exit 0

}

function test_f12
{
#/{,usr/}bin/*calc
echo $PWD
for file in $PWD
#             ^    Find all executable files ending in "calc"
#+                 in /bin and /usr/bin directories.
do
        echo "file path is: $file"
	if [ -x "$file" ]
        then
          echo $file
        fi
done
}

function test_f11_1
{
# read args from command
minpaparms=10
echo
echo "The name of this script is \"$0\"."
# adds ./ for current directory
echo "the name of this script is \"`basename $0`\"."

echo

if [ -n "$1" ]
then
	echo "paramerter #1 is $1"
fi

if [ -n "${10}" ]  # Parameters > $9 must be enclosed in {brackets}.
then
 echo "Parameter #10 is ${10}"
fi 

echo "-----------------------------------"
echo "All the command-line parameters are: "$*""

if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
fi  

echo

exit 0
}

function test_date
{
date1=`date --date='30 days ago' +%Y%m%d`
date2=`date --date='4762 days ago' +%Y%m%d`
echo $date1
echo date1=`date --date='2 days ago' +%Y%m%d`
echo $date2 

echo "the parameters are `$*`"
}


# end of functon group

# run funcitons


test_date
# 1. 让使用者输入档名,并且判断使用者是否真的有输入字符串?
# 1. 让使用者输入档名,并且判断使用者是否真的有输入字符串?
# 1. 让使用者输入档名,并且判断使用者是否真的有输入字符串?



