#!/bin/sh
#
# Batch run SQL scripts under specific directories
#
# Simon.Cao
# 2010.11.2 
#

dir=/tmp/1
log=/tmp/1/log.txt
username=""
DB="hotel_bookings"
USER="SUChina"

if [ ! -d $log ]; then
    touch $log
fi

if [ $# -lt 1 ] ; then
        echo
        echo "Run SQL Files as Patch. Version 1.0"
        echo
        echo "Usage: cn-patch.sh [-d directory] [-u username] [-l]|[-a]|[-y]"
        echo
        echo "       -d directory : for specified directory"
        echo "                      default dir is [$dir] "
        echo "       -u username  : default username is null"
        echo "       -l           : only list new SQL files"
        echo "       -a           : list all SQL files"
        echo "       -y           : excute the new SQL files"
        echo
        exit
fi;

DO_NOTHING=0
LIST_NEW=1
LIST_ALL=2
RUN_SQL=3

todo=${LIST_NO}

today=$(date '+%Y-%m-%d')
echo
echo "Today: $today    Dir: $dir"
echo

while getopts u:d:lay option; do
    case ${option} in
	"u")
		username=$OPTARG
		;;
	"d")
		dir=$OPTARG
		;;
	"a")
		todo=${LIST_ALL}
		;;
	"l")
		todo=${LIST_NEW}
		;;
	"y")
		todo=${RUN_SQL}
		;;
    esac
done

run_sql()
{
    echo -e "Running: $1"
    echo "${today} : ${username}: $1" >> $log
    #su postgres -c 'psql -U "$USER" -d "$DB" -c "select count(1) from actor;"'
    #su postgres -c 'psql -U "$USER" -d "$DB" -f $1'
    cmd="psql -U "$USER" -d $DB -f $1"
    su postgres -c "$cmd"
}

#echo "todo: $todo dir: $dir"

dirs=(`ls $dir`)

num_new=0

for i in "${dirs[@]}"; do
    if [ ! -d $dir/$i ]; then continue; fi
    #echo
    #echo "Bingo --> dir : $dir/$i"
    cd $dir/$i
    files=(`ls`)
    #echo -e "\tfiles:[${files[@]}]"

    if [ "$files" == "" ]; then  
	#echo -e "\tEmpty directory !"
	continue; fi

    for j in "${files[@]}"; do
	#echo -e "\t==>$j"

    	if [ `cat $log| grep "$dir/$i/$j" | wc -l` -lt 1 ]; then
    	    if [ "$todo" == "${RUN_SQL}" ]; then
    	    	run_sql "$dir/$i/$j"
            fi
    	    if [ "$todo" == "${LIST_NEW}" ] || [ "$todo" == "${LIST_ALL}" ]; then
		let "num_new++"
    	    	echo "+ $dir/$i/$j"
  	    else
		:
	    fi
        else
	        #echo -e "\tNo new SQL files!"
    	        if [ "$todo" == "${LIST_ALL}" ]; then
    	    	    echo "  $dir/$i/$j"
		fi
        fi
    done

done

echo
if [ $num_new -gt 0 ]; then
    echo "New SQL files: $num_new"
    echo
fi

exit 0 
