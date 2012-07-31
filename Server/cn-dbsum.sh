#!/bin/sh
# Simon.Cao
# 2010.6.1

TMP="/tmp/dbsum.$(date +%s)"

while getopts r:e option; do
	case ${option} in
		"r")
			option_r=$OPTARG
			;;
		"e")
			em="true"
			;;
	esac
done



for m in $(cat /space/SUScripts/China/cn-db.txt); do
	echo "GOING TO: ${m}"   
	 if [ "$(ping -c 1 ${m} | grep -o "100% packet loss" )"  = "100% packet loss" ]
	 then
	echo "___________________________________________________________" >> ${TMP}
        echo "___________________________________________________________" >> ${TMP}
	echo "${m} DOES NOT RESPOND TO PINGS at $( "nslookup" ${m} | grep "Address: " ) "  >> ${TMP}
	 else
        echo "___________________________________________________________" >> ${TMP}
	echo "___________________________________________________________" >> ${TMP}
	echo "     HOSTNAME:  ${m}" >> ${TMP}
	echo "   INTERFACES:" >> ${TMP} 

	  for x in $(ssh ${m} "ifconfig" | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }' | grep -v "127.0.0.1" ); do
	echo "             ${x} $( "nslookup" ${x} | grep -o "= ".* | awk '{ print $2 }') " >> ${TMP}
	  done

	echo "                   " >> ${TMP}
	echo "   KERNEL VER:  $(ssh ${m} "uname -a" | awk '{print $3}')" >> ${TMP}
	echo "   PROCESSORS:  $(ssh ${m} "cat /proc/cpuinfo" | grep -c proc ) " >> ${TMP}
	echo "   OS VERSION:  $(ssh ${m} "cat /etc/SuSE-release" | grep SUSE) " >> ${TMP}
	echo "    TOTAL RAM:  $(ssh ${m} "free -m" | grep Mem | awk '{ print $2 }' ) MB" >> ${TMP}
	echo "     FREE RAM:  $(ssh ${m} "free -m" | grep Mem | awk '{ print $4 }' ) MB" >> ${TMP}

        if [ `ssh ${m} df -h | grep /dev/hda1 | wc | awk '{print $1}'` -eq 1 ]; then
	echo "          " >> ${TMP}
	echo "   SPACE Name:  /dev/hda1         " >> ${TMP}
        echo "  TOTAL SPACE:  $(ssh ${m} "df -h" | grep "/dev/hda1" | awk '{print $2 }')" >> ${TMP}
        echo "   FREE SPACE:  $(ssh ${m} "df -h" | grep "/dev/hda1" | awk '{print $4 }')" >> ${TMP}
        echo " PERCENT FULL:  $(ssh ${m} "df -h" | grep "/dev/hda1" | awk '{print $5 }')" >> ${TMP}
	fi

        if [ `ssh ${m} df -h | grep /dev/xvda1 | wc | awk '{print $1}'` -eq 1 ]; then
	echo "          " >> ${TMP}
	echo "   SPACE Name:  /dev/xvda1         " >> ${TMP}
        echo "  TOTAL SPACE:  $(ssh ${m} "df -h" | grep "/dev/xvda1" | awk '{print $2 }')" >> ${TMP}
        echo "   FREE SPACE:  $(ssh ${m} "df -h" | grep "/dev/xvda1" | awk '{print $4 }')" >> ${TMP}
        echo " PERCENT FULL:  $(ssh ${m} "df -h" | grep "/dev/xvda1" | awk '{print $5 }')" >> ${TMP}
	fi

        if [ `ssh ${m} df -h | grep /dev/hdb | wc | awk '{print $1}'` -eq 1 ]; then
	echo "          " >> ${TMP}
	echo "   SPACE Name:  /dev/hdb         " >> ${TMP}
        echo "  TOTAL SPACE:  $(ssh ${m} "df -h" | grep "/dev/hdb" | awk '{print $2 }')" >> ${TMP}
        echo "   FREE SPACE:  $(ssh ${m} "df -h" | grep "/dev/hdb" | awk '{print $4 }')" >> ${TMP}
        echo " PERCENT FULL:  $(ssh ${m} "df -h" | grep "/dev/hdb" | awk '{print $5 }')" >> ${TMP}
        fi

        if [ `ssh ${m} df -h | grep /dev/xvdc1 | wc | awk '{print $1}'` -eq 1 ]; then
	echo "          " >> ${TMP}
	echo "   SPACE Name:  /dev/xvdc1         " >> ${TMP}
        echo "  TOTAL SPACE:  $(ssh ${m} "df -h" | grep "/dev/xvdc1" | awk '{print $2 }')" >> ${TMP}
        echo "   FREE SPACE:  $(ssh ${m} "df -h" | grep "/dev/xvdc1" | awk '{print $4 }')" >> ${TMP}
        echo " PERCENT FULL:  $(ssh ${m} "df -h" | grep "/dev/xvdc1" | awk '{print $5 }')" >> ${TMP}
        fi

        echo "                   " >> ${TMP} 

        if [ `ssh ${m} ps -ef | grep postgres | wc -l` -ge 1 ]; then
	echo " PSQL VERSION:  $(ssh ${m} "psql --version" | grep psql | awk '{ print $2 $3 }' )" >> ${TMP}
        echo "    DATABASES:" >> ${TMP}
         for x in $(ssh ${m} "psql -l -U postgres" | cut -d\| -f1 -s | egrep -v 'Name|template[01]' | sort ); do
            dbsize=$(ssh ${m} "psql -d ${x} -U postgres -t -c \"select sum(c.relpages*8) as totalsizekb from pg_class c where c.relowner <> 1\"" | xargs echo)
	    if [ `expr length ${x}` -ge 9 ]; then 
                echo -e "             ${x}  \t     SIZE:  ${dbsize} KB" >> ${TMP}
            else 
                echo -e "             ${x}  \t\t     SIZE:  ${dbsize} KB" >> ${TMP}
	    fi
         done
         fi

        if [ `ssh ${m} ps -ef | grep mysqld | wc -l` -ge 1 ]; then
	    echo " MYSQL VERSION:  $(ssh ${m} "mysql --version" | awk '{ print $5 }' )" >> ${TMP}
            echo "    DATABASES:" >> ${TMP}
             for x in $(ssh ${m} "echo 'show databases' | mysql | grep -v 'Database'" ); do
              dbsize=$(ssh ${m} "echo 'select round(sum(DATA_LENGTH)/1024) from information_schema.TABLES where TABLE_SCHEMA=\"${x}\"' | mysql" | grep -v sum)
	    if [ `expr length ${x}` -ge 24 ]; then 
                echo -e "             ${x}\t  SIZE: ${dbsize}  KB" >> ${TMP}
	    else
	      if [ `expr length ${x}` -ge 16 ]; then 
                echo -e "             ${x}\t\t\t  SIZE: ${dbsize}  KB" >> ${TMP}
	      else
                echo -e "             ${x}\t\t\t\t  SIZE: ${dbsize}  KB" >> ${TMP}
  	    fi
	    fi
             done
        fi


         fi
done

if [[ "${em:-"false"}" == "true" ]]; then
	cat ${TMP} | mail -r "Systems Notification <simon.cao@studentuniverse.com>" -s "China Daily DB Summary Report: $(date "+%m/%d/%Y")" "${option_r:="simon.cao@studentuniverse.com"}"
else
	cat ${TMP}
fi

rm -f ${TMP}

exit 0 
