#!/bin/sh
# Simon.Cao 2010.5.31
# send email notification when there's change on MemberDev schema
#

dbname=MemberDev
hostip=192.168.60.82
username=SUUser

sqlcmd=$(cat <<SETVAR
        select * 
        from pg_tables
        where schemaname='public' order by tablename
SETVAR
)

psql -d $dbname -U $username -c "$sqlcmd"  | grep public  | awk '{ print $3 }' > memdev_tab.txt

> memdev2.txt
date >> simon.txt

for tabname in `cat memdev_tab.txt` ;do

#echo $tabname
sqlcmd=$(cat <<SETVAR
	SELECT '$tabname' as tablename, a.attnum, a.attname AS field, 
                t.typname AS type, a.attlen AS length, 
		a.Atttypmod AS lengthvar, a.attnotnull AS notnull 
	FROM pg_class c, pg_attribute a, pg_type t 
	WHERE c.relname = '$tabname' and a.attnum> 0 and a.attrelid = c.oid and a.Atttypid = t.oid 
	ORDER BY a.attnum
SETVAR
)

#echo $sqlcmd
if [ ! -e memdev1.txt ] ;then  echo "---" > memdev1.txt ; fi
if [ ! -e memdev_ver.txt ] ;then  echo "--unknown--" > memdev_ver.txt ; fi

echo "Table name: " $tabname >> memdev2.txt
echo -n "."
psql -d $dbname -U $username -c "$sqlcmd" >> memdev2.txt 
#echo "Table name: " $tabname >> memdev2.txt
#echo " " >> memdev2.txt

done

echo

if [ "`cmp memdev2.txt memdev1.txt`" = "" ]
then
     
   if [ "`date +%a`" = "Mon" ]
   then 
	echo -e "MemberDev Last modification time is " `cat memdev_ver.txt` "\n\nWe check its change every 12 hours. You should receive a plain notification on each Monday or Tuesday if there's no change.\n\n Simon Cao" | mail -s "MemberDev schema keeps same!" "jiang_xinxing@hoperun.com,simon.cao@studentuniverse.com"
   fi
   echo "MemberDev schema keeps same !"
else
   echo "MemberDev schema is changed !"
   diff memdev2.txt memdev1.txt | mail -s "MemberDev schema is changed  !" "zhang_p@hoperun.com,jiang_xinxing@hoperun.com,simon.cao@studentuniverse.com"
   cp memdev2.txt memdev1.txt
   date > memdev_ver.txt
fi

exit 0
