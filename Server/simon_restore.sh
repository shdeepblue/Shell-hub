#! /bin/sh

#DB=hotel_bookings.201103140330
DB=hotel_bookings.201104060330
dbname=hotel_bookings_test
user='SUChina'

grep -v "^--" $DB.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "CREATE .*INDEX" >/tmp/DB.last 2>&1
# for a 7.3 to 7.4 restore...
grep -v "^--" $DB.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "CREATE CONSTRAINT TRIGGER" >/tmp/DB.verylast 2>&1
grep -v "^--" $DB.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "ALTER TABLE ONLY .* ADD CONSTRAINT" >>/tmp/DB.verylast 2>&1
#grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep -v -e "CREATE .*INDEX" -e "DROP " -e "CREATE CONSTRAINT TRIGGER" >/tmp/$$.first 2>&1 
grep -v "^--" $DB.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep -v -e "CREATE .*INDEX" -e "DROP " -e "CREATE CONSTRAINT TRIGGER" -e "ALTER TABLE ONLY .* ADD CONSTRAINT" >/tmp/DB.first 2>&1 


log "Creating Schema in $dbname ..."
time psql -e -U $user $dbname -f /tmp/DB.first 
if [ $? -ne 0 ]; then
  echo "ERROR: Schema creation failed .. exiting."
fi


exit

log "Restoring Data from $3.dmp to $2..."
#time pg_restore -U $1 -d $2 $3.dmp >> $logfile 2>&1
#time pg_restore -r -v -U $1 -d $2 $3.dmp >> $logfile 2>&1
time pg_restore -v -U $1 -d $2 $3.dmp >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Restore failed for $2... exiting."
  exit 5
fi


# -- ---------------------------------
#exit $?
# -- ---------------------------------


log "Creating indexes in $2..."
time psql -e -U $1 $2 -f /tmp/$$.last >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Index creation failed for $2... exiting." >> $logfile
  exit 6
fi


log "Creating constraint triggers in $2..."
time psql -e -U $1 $2 -f /tmp/$$.verylast >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Drop failed for $2... exiting."
  exit 7
fi


log "Vacuuming $2..."
#time psql -e -U $1 $2 <<EOF 
#vacuum verbose analyze;
#\q
#\\q
#EOF>> $logfile 2>&1
time psql -e -U $1 $2 -c "vacuum verbose analyze" >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Vacuum failed for $2... exiting."
  exit 8
fi


log "Cleaning up.  Log file is $logfile."
#rm /tmp/$$.first /tmp/$$.last


log "Done"
exit 0
