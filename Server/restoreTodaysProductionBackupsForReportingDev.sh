#!/bin/sh

# NOTE: an archive is a remote copy of the production backup
# The process:
#   - scp todays prod backups from the archive server and compare their cksums.
#   - uncompress the local copies on the DB reporting server
#   - check to make sure there are 4 resulting files from the database dump for today.
#   - move them to the local manualDumps dir.
#   - run the DB restore script - and create the multi-schema env.
#   - email if any errors.


if [ $# -lt 1 ] ; then
  echo "Usage: $0 yes"
  exit 1
fi;

. /space/postgresql/SUScripts/paths.shinc

datestamp=`date +%Y%m%d`
thisnode=`uname -n`

dbname=ReportDev
dbuser=SUReportDev
#dbuser=SUDev

subject="$thisnode: $dbname DB Restore Status"
#tofolks="bp@studentuniverse.com"
tofolks="sys@studentuniverse.com, bp@studentuniverse.com, amy.lidstone@studentuniverse.com, chad@studentuniverse.com"

#dbdumpfiles="ContentMgt FarePrep FarePrepDisabled Member user_tracking Verification"
#dbdumpfiles="ContentMgt"
dbdumpfiles="ContentMgt Member"

archiveserver=bigmac
archiveuser=root
archivedir=/space/LogBackups/DBBackups

emailerrorlog=0

#logfile=$PGMANUALDUMPS/restoredbdumps.$datestamp.log
logfile=$PGMANUALDUMPS/$0.$datestamp.log
echo "Logging to $logfile ..."

function log() {
  #echo "$0[$$]:$(date +%Y%m%d%H%M):$@" >> $logfile
  echo "$(date +%Y%m%d%H%M):$@" >> $logfile
}

for dbdumpfile in $dbdumpfiles; do

  log "Retreiving $dbdumpfile archive..."

  scp -p $archiveuser@$archiveserver:$archivedir/$dbdumpfile/$dbdumpfile.$datestamp????*.gz /tmp
  if [ $? -ne 0 -a $? -ne 2 ]; then
    log "ERROR: Scp of $dbdumpfile failed... skipping to the next restore." 
    emailerrorlog=1
    continue
  fi

  cksumdbdump=`cksum /tmp/$dbdumpfile.$datestamp????.*.gz | awk '{ print $2 }' | tr -d "\n"`
  cksumarchive=`ssh $archiveuser@$archiveserver cksum $archivedir/$dbdumpfile/$dbdumpfile.$datestamp????*.gz | awk '{ print $2 }' | tr -d "\n"`
  if [ "$cksumdbdump" != "$cksumarchive" ]; then
    log "ERROR: Checksum failed for $dbdumpfile... skipping to the next restore."
    emailerrorlog=1
    continue
  fi

  nameofdbdumpfile=`ls /tmp/$dbdumpfile.$datestamp????.dmp.gz`
  nameofdbdumpfile=${nameofdbdumpfile#/tmp/}
  nameofdbdumpfile=${nameofdbdumpfile%.dmp.gz}

  gunzip -f /tmp/$nameofdbdumpfile.*.gz
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to gunzip $dbdumpfile... skipping to the next restore."
    emailerrorlog=1
    continue
  fi

  numofdbdumpfiles=`ls -1 /tmp/$nameofdbdumpfile.* 2>/dev/null | wc -l`

  let numofdbdumpfiles=numofdbdumpfiles+0
  case $numofdbdumpfiles in
  0)
    log "WARNING: No such db dump $nameofdbdumpfile... skipping to the next restore."
    continue
    ;;
  4)
    log "OK: There are 4 resulting db dump files for /tmp/$nameofdbdumpfile.*."
    ;;
  *)
    log "ERROR: Incorrect number of local db dump files ($numofdbdumpfiles/4)... skipping to the next restore."
    emailerrorlog=1
    continue
    ;;
  esac

  mv -f /tmp/$nameofdbdumpfile.* $PGMANUALDUMPS/
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to move $dbdumpfile to $PGMANUALDUMPS/... skipping to the next restore."
    emailerrorlog=1
    continue
  fi

  cd $PGHOME/SUScripts

  #if [ "$dbdumpfile" = "Member" ]; then
     ./disconnectUsersFromDB.sh $dbname
  #fi

  # need to drop public in case a restore craps out half way thru.
  log "INFO: Dropping the public schema."
  psql -e -U $dbuser $dbname -c "drop schema public cascade;"
  if [ $? -gt 1 ]; then
      log "ERROR: Failed to drop schema public... exiting."
      emailerrorlog=1
      break
  fi
  log "INFO: Dropping the ${dbdumpfile}Dev schema."
  psql -e -U $dbuser $dbname -c "drop schema \"${dbdumpfile}Dev\" cascade;"
  if [ $? -gt 1 ]; then
      log "WARNING: Failed to drop schema ${dbdumpfile}Dev... skipping to the next restore."
      emailerrorlog=1
      continue
  fi



  log "INFO: Restoring $dbdumpfile to $dbname."
#  ./restoredb.sh $dbuser $dbname $PGMANUALDUMPS/$nameofdbdumpfile
  ./restoredb.sh.new $dbuser $dbname $PGMANUALDUMPS/$nameofdbdumpfile
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to restore $dbdumpfile... skipping to the next restore."
    emailerrorlog=1
    continue
  fi
  log "SUCCESS: Successfully restored $dbdumpfile."



  # need to add some marketing views if this is the member db...
  if [ "$dbdumpfile" = "Member" ]; then
    log "INFO: Running post-restore actions for the Member schema..."
    psql -aeE -d $dbname -U $dbuser -f memberPostRestoreActions.sql
    if [ $? -ne 0 ]; then
      log "WARNING: Failed to run post-restore actions for the Member schema... skipping to the next restore."
      emailerrorlog=1
      continue
    fi
    log "SUCCESS: Completed post-restore actions for Member$dbname."

    echo "MemberDev Schema has been Restored to the Schema Integrated ReportDev DB." | mail -s "$thisnode: Restore to $dbname" "$tofolks"

  fi
    
  log "INFO: Renaming the public schema to ${dbdumpfile}Dev."
  psql -e -U $dbuser $dbname -c "alter schema public rename to \"${dbdumpfile}Dev\";"
  if [ $? -ne 0 ]; then
    log "ERROR: Failed rename the public schema to ${dbdumpfile}Dev... exiting the restore section."
    emailerrorlog=1
    break
  fi

done

log "INFO: Vacuuming/Analyzing the whole $dbname database."
# no need to run a vacuum on a freshly restored db...
#time psql -e -U $dbuser $dbname -c "vacuum verbose analyze"
time psql -e -U $dbuser $dbname -c "analyze verbose"
if [ $? -ne 0 ]; then
  log "ERROR: Vacuum Analyse failed for $dbname... exiting."
  exit 2
fi
log "SUCCESS: Vacuuming/Analyzing $dbname completed."

log "Done."

#if [ $emailerrorlog = 1 ]; then
#  cat $PGMANUALDUMPS/restoredbdumps.$datestamp.log | mail -s "$subject" "$tofolks"
#fi
cat $logfile | mail -s "$subject" "$tofolks"

exit 0
