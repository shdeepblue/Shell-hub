#!/bin/sh
#
# Batch run SQL scripts under specific directories
#
# Simon.Cao
# 2010.11.2 
#

#DIR=/tmp/1
#LOG=/tmp/1/log.txt
#DB="hotel_bookings"
#USER="SUChina"
#IP="10.20.70.238"
cfgfile="/space/SUScripts/sql-patch.conf"
FILE_TYPE="*.sql"
#FILE_TYPE="*.txt"
USER=""
DEBUG=0
SHOW_TIME=0

show_howto() 
{
        echo
        echo "Run SQL Files for Patching database. Version 1.0,  2010/DEC/2"
        echo "Default config file is : $cfgfile "
        echo
        echo "Usage: sql-patch.sh [-u username] [-l]|[-a]|[-y]"
        echo
        echo "       -u username  : your name , don't use blank"
        echo "       -l           : only list new SQL files"
        echo "       -a           : list all SQL files"
        echo "       -y           : excute the new SQL files"
        echo
        echo "Example:       sql-patch.sh -l "
        echo "               sql-patch.sh -y -u Simon"
        echo
        echo "Advance Option:"
        echo "       -D           : Debug Mode, show more detail"
        #echo "       -F           : file type, default is *.sql"
        echo "       -t           : Show last change time of file"
        echo
}


show_debug()
{
    if [ $DEBUG -gt 0 ]; then 
	echo -n -e "\t\033[40;32m--DEBUG-- $1\033[0m" 
    fi
}


if [ $# -lt 1 ] ; then
	show_howto
        exit
fi

DO_NOTHING=0
LIST_NEW=1
LIST_ALL=2
RUN_SQL=3

DIR2=""
LOG2=""
todo=${DO_NOTHING}

while getopts F:f:u:d:g:layDt option; do
    case ${option} in
	"u")
		USER=$OPTARG
		;;
	"f")
		cfgfile=$OPTARG
		;;
	"d")
		DIR2=$OPTARG
		;;
	"g")
		LOG2=$OPTARG
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
	"D")
		DEBUG=1
		;;
	"F")
		FILE_TYPE=$OPTARG
		;;
	"t")
		SHOW_TIME=1
		;;
    esac
done

if [ "$USER" == "" ] && [ "$todo" == "${RUN_SQL}" ]; then
	show_howto
        exit
fi

if [ ! -f $cfgfile ]; then
	echo "Config file [$cfgfile] not existed !"
	echo
	exit
fi

DB=$(cat $cfgfile | grep "DB=" | sed 's/DB=//g')
DB_USER=$(cat $cfgfile | grep "DB_USER=" | sed 's/DB_USER=//g')
IP=$(cat $cfgfile | grep "IP=" | sed 's/IP=//g')
if [ "$DIR2" == "" ]; then
    DIR=$(cat $cfgfile | grep "DIR=" | sed 's/DIR=//g')
else
    DIR=$DIR2
fi
if [ "$LOG2" == "" ]; then
    LOG=$(cat $cfgfile | grep "LOG=" | sed 's/LOG=//g')
else
    LOG=$LOG2
fi


if [ ! -f $LOG ]; then
    touch $LOG
    chmod a+rw $LOG
fi


today=$(date '+%Y-%m-%d %H:%M')
echo
echo -e "Today: $today\n"
echo -e "Config File: $cfgfile\n"
echo -e "SQL_Dir: $DIR  \nLOGFILE: $LOG "
echo -e "HOST/IP: $IP  \nDB_NAME: $DB  \nDB_USER: $DB_USER"
echo

err_num=0
err_sql=""

run_sql()
{
    stat=$(stat -c %y "$DIR/$i/$j")
    echo -e "\nRunning: $1"
    #if [ $DEBUG -gt 0 ]; then echo -e "\t[Modified Time: ${stat:0:16} ]"; else echo; fi
    #show_debug "[Modified Time: ${stat:0:16} ]\n"; 
    today=$(date '+%Y-%m-%d %H:%M')
    echo "${today} ${USER}: $1" >> $LOG
    echo "${today} ${USER}: $1" > "$DIR/$i/$j.log"
    #su postgres -c 'psql -U "$USER" -d "$DB" -c "select count(1) from actor;"'
    #su postgres -c 'psql -U "$USER" -d "$DB" -f $1'
    if [ `id | grep "postgres" | wc -l` -lt 1 ]; then
        cmd="psql -h $IP -U "$DB_USER" -d $DB -f '$1'"
        su postgres -c "$cmd" >> "$DIR/$i/$j.log" 2>> "$DIR/$i/$j.log"
    else
	psql -h $IP -U "$DB_USER" -d $DB -f '$1' >> "$DIR/$i/$j.log" 2>> "$DIR/$i/$j.log"
    fi 
    if [ `sed -n '2,$p'  "$DIR/$i/$j.log" | egrep "ERROR|WARN|warn|error" | wc -l` -ge 1 ]; then
        sed -n '2,$p'  "$DIR/$i/$j.log" >> $LOG
	err_sql="${err_sql}$1\n"
	let "err_num++"
        #echo -e "\033[41;37m something here \033[0m"
        echo -e "\033[41;37mError ${err_num}:\033[0m"
	cat "$DIR/$i/$j.log"
    else
	if [ $2 -gt 0 ];then 
            times=$2
	    let "times++"
            echo -e "\033[40;32mSucceeded. (Modified & Run for $times times) \033[0m"
	else
            echo -e "\033[40;32mSucceeded.\033[0m"
	fi
    fi

}

#echo "todo: $todo dir: $DIR"

dirs=(`ls $DIR`)

num_new=0
#IFS=$'\t'
#IFS=$','
if [ "$todo" == "${RUN_SQL}" ]; then
	echo "------------${USER}-------------" >> $LOG
fi

for i in "${dirs[@]}"; do
    if [ ! -d "$DIR/$i" ]; then continue; fi
    #echo
    show_debug "Bingo -> $DIR/$i\n"

    cd "$DIR/$i"

    files=(`ls ${FILE_TYPE} 2>/dev/null | sed 's/ /_#BLANK#_/g'`)

    file_list=`echo ${files[@]}`
    show_debug "Bingo -> [${file_list}]\n"

    if [ "$files" == "" ]; then  
	#echo -e "\tEmpty directory !"
	continue; fi

    No=0


    for j in "${files[@]}"; do
	j=`echo $j | sed 's/_#BLANK#_/ /g'`
        stat=$(stat -c %y "$DIR/$i/$j")

	let "No++"
        show_debug "No $No --> [$j]\n" 

    	# if [ `cat $LOG | grep "$DIR/$i/$j" | wc -l` -lt 1 ]; then
        done_times=$(cat $LOG | grep "$DIR/$i/$j" | wc -l)
    	if [ ! -f "$DIR/$i/$j.log" ]; then
    	    if [ "$todo" == "${RUN_SQL}" ]; then
    	    	run_sql "$DIR/$i/$j" ${done_times}
		let "num_new++"
            fi
    	    if [ "$todo" == "${LIST_NEW}" ] || [ "$todo" == "${LIST_ALL}" ]; then
		let "num_new++"
		if [ $done_times -eq 0 ]; then
    	    	    echo -n "+ $DIR/$i/$j"
		else
    	    	    echo -n "+(${done_times}) $DIR/$i/$j"
		fi
    		if [ $SHOW_TIME -eq 1 ]; then 
			echo -e "\t[Modified Time: ${stat:0:16}]";
                else echo; fi
  	    else
		:
	    fi
        else
	        #echo -e "\tNo new SQL files!"
    	        if [ "$todo" == "${LIST_ALL}" ]; then
		    if [ $done_times -eq 0 ]; then
    	    	        echo -n "  $DIR/$i/$j"
		    else
    	    	        echo -n " (${done_times})  $DIR/$i/$j"
		    fi
    		    if [ $SHOW_TIME -eq 1 ]; then 
			echo -e "\t[Modified Time: ${stat:0:16}]"; 
                    else echo; fi
		fi
        fi
    done

done

echo

if [ $num_new -gt 0 ]; then
    echo "New SQL files: $num_new"
else
    echo "No New SQL file."
    echo
    exit 0
fi

if [ $err_num -gt 0 ]; then
    #echo -e "\033[41;37m something here \033[0m"
    echo -e "\n\033[41;37m${err_num} SQL files failed:\033[0m"
    echo -e "$err_sql"
else
    if [ "$todo" == "${RUN_SQL}" ]; then
    	echo -e "\033[40;32mAll Succeeded.\033[0m"
    fi
fi 

echo

exit 0 
