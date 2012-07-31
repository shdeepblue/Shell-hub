#!/bin/sh
# Simon.Cao
# 2010.6.1


TMP=/tmp/p

for m in $(cat /space/SUScripts/China/p); do
	echo "GOING TO: ${m}"   
	 if [ "$(ping -c 1 ${m} | grep -o "100% packet loss" )"  = "100% packet loss" ]
	 then
	echo "___________________________________________________________"   
        echo "___________________________________________________________"   
	echo "${m} DOES NOT RESPOND TO PINGS at $( "nslookup" ${m} | grep "Address: " ) "    
	 else
        echo "___________________________________________________________"   
	echo "___________________________________________________________"   
	echo "     HOSTNAME:  ${m}"   
	echo "   INTERFACES:"    

        echo "                   " 
	echo " PSQL VERSION:  $(ssh ${m} "psql --version" | grep psql | awk '{ print $2 $3 }' )" 
        echo "    DATABASES:" 
         for x in $(ssh ${m} "psql -l -U postgres" | cut -d\| -f1 -s | egrep -v 'Name|template[01]' | sort ); do
echo "--1---"
           ssh ${m} "psql -d ${x} -U postgres -t -c \"select sum(c.relpages*8) as totalsizekb from pg_class c where c.relowner <> 1\""
echo "--2---"
            dbsize=$(ssh ${m} "psql -d ${x} -U postgres -t -c \"select sum(c.relpages*8) as totalsizekb from pg_class c where c.relowner <> 1\"" | xargs echo)
	    echo $dbsize
echo "--3---"
            echo  "SIZE: " $dbsize" KB "
            echo "0SIZE:"  ${dbsize} " KB" 
            echo -e "1SIZE:  ${dbsize} KB" 
            echo -e "             ${x}  \t\t\t     SIZE:  $dbsize KB" 
         done
         fi
done


exit 0 
