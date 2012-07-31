#! /bin/sh

if [ $# -lt 3 ]; then
    echo "Usage: `basename $0` DBUserName DBName DumpPathAndName"
    exit 1
fi

. /space/postgresql/SUScripts/paths.shinc

logfile=/tmp/$$.log
echo "Logging to $logfile..."

function log() {
  echo "$0[$$]:$(date +%Y%m%d%H%M):$@" >> $logfile 
}

checkdbexistence=`psql -l -U $1 | grep -w $2 | awk '{ print $1 }'`

if [ "$checkdbexistence" == "$2" ]; then
  log "Dropping database $2..."
  time dropdb -e -U $1 $2 >> $logfile 2>&1
  if [ $? -ne 0 ]; then
    log "ERROR: Drop failed for $2... exiting."
    exit 2
  fi
else
  log "WARN: $2 Does not Exist."
fi 

log "Creating UNICODE database $2 as user $1..." 
#time createdb -e -U $1 $2 >> $logfile 2>&1
time createdb -e -E UNICODE -U $1 $2 >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Create failed for $2 as user $1... exiting."
  exit 3
fi


log "Preprocessing $3.clr..."
# make multiline statments into one, grep certain ones out.
# hacked to do tilde in sed since \n isn't working 
# in some versions. tr changes it back to newline.
grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "CREATE .*INDEX" >/tmp/$$.last 2>&1
# for a 7.3 to 7.4 restore...
grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "CREATE CONSTRAINT TRIGGER" >/tmp/$$.verylast 2>&1
grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep "ALTER TABLE ONLY .* ADD CONSTRAINT" >>/tmp/$$.verylast 2>&1
#grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep -v -e "CREATE .*INDEX" -e "DROP " -e "CREATE CONSTRAINT TRIGGER" >/tmp/$$.first 2>&1 
grep -v "^--" $3.clr|tr -d '\n'|sed "s/;/;\~/g"|tr '~' '\n'|grep -v -e "CREATE .*INDEX" -e "DROP " -e "CREATE CONSTRAINT TRIGGER" -e "ALTER TABLE ONLY .* ADD CONSTRAINT" >/tmp/$$.first 2>&1 


log "Creating Schema in $2..."
time psql -e -U $1 $2 -f /tmp/$$.first >> $logfile 2>&1
if [ $? -ne 0 ]; then
  log "ERROR: Schema creation failed for $2... exiting."
  exit 4
fi


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
