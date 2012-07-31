#!/bin/sh

# NOTE: an archive is a remote copy of the production backup
# The process:
#   - scp todays prod backups from the archive server and compare their cksums.
#   - uncompress the local copies on the DB reporting server
#   - check to make sure there are 4 resulting files from the database dump for today.
#   - move them to the local manualDumps dir
#   - run the DB restore script
#   - email if any errors


# xxxTODO: BHP:  need to change tee to redirect for error checking statements to work
#           - Actually tee is fine here sinceit just used in the echo lines, the true tee problem is in the restoredb.sh script.
# -   This is done.

if [ $# -lt 1 ] ; then
  echo "Usage: $0 yes"
  exit -1
fi;

. /space/postgresql/SUScripts/paths.shinc

thisnode=`uname -n`
datestamp=`date +%Y%m%d`
subject="$thisnode: DB Report Restore Status"
tofolks="sys@studentuniverse.com, bp@studentuniverse.com, amy.lidstone@studentuniverse.com, chad@studentuniverse.com, mathews@studentuniverse.com"

#dbdumpfiles="ContentMgt FarePrep FarePrepDisabled Member Verification"
dbdumpfiles="ContentMgt Member FarePrep"

archiveserver=bigmac
archiveuser=root
archivedir=/space/LogBackups/DBBackups

emailerrorlog=0

logfile=$PGMANUALDUMPS/restoredbdumps.$datestamp.log
echo "Logging to $logfile..."

function log() {
  echo "$0[$$]:$(date +%Y%m%d%H%M):$@" >> $logfile
}

for dbdumpfile in $dbdumpfiles; do

  log "Retreiving $dbdumpfile archive..."

  scp -p $archiveuser@$archiveserver:$archivedir/$dbdumpfile/$dbdumpfile.$datestamp????*.gz /tmp
  if [ $? -ne 0 -a $? -ne 2 ]; then
    log "ERROR: Scp of $dbdumpfile failed... skipping /tmp/$dbdumpfile.$datestamp????*.gz."
    emailerrorlog=1
    continue
  fi

  cksumdbdump=`cksum /tmp/$dbdumpfile.$datestamp????.*.gz | awk '{ print $2 }' | tr -d "\n"`
  cksumarchive=`ssh $archiveuser@$archiveserver cksum $archivedir/$dbdumpfile/$dbdumpfile.$datestamp????*.gz | awk '{ print $2 }' | tr -d "\n"`
  if [ "$cksumdbdump" != "$cksumarchive" ]; then
    log "ERROR: Checksum failed for $dbdumpfile... skipping /tmp/$dbdumpfile.$datestamp????*.gz."
    emailerrorlog=1
    continue
  fi

  nameofdbdumpfile=`ls /tmp/$dbdumpfile.$datestamp????.dmp.gz`
  nameofdbdumpfile=${nameofdbdumpfile#/tmp/}
  nameofdbdumpfile=${nameofdbdumpfile%.dmp.gz}

  gunzip -f /tmp/$nameofdbdumpfile.*.gz
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to gunzip $dbdumpfile... skipping /tmp/$nameofdbdumpfile.*.gz."
    emailerrorlog=1
    continue
  fi

  numofdbdumpfiles=`ls -1 /tmp/$nameofdbdumpfile.* 2>/dev/null | wc -l`
  let numofdbdumpfiles=numofdbdumpfiles+0

  case $numofdbdumpfiles in
  0)
    log "WARNING: No such db dump... skipping $PGMANUALDUMPS/$nameofdbdumpfile.*."
    continue
    ;;
  4)
    log "OK: There are 4 resulting db dump files for /tmp/$nameofdbdumpfile.*."
    ;;
  *)
    log "ERROR: Incorrect number of local db dump files ($numofdbdumpfiles/4)... skipping /tmp/$nameofdbdumpfile.*."
    emailerrorlog=1
    continue
    ;;
  esac

  mv -f /tmp/$nameofdbdumpfile.* $PGMANUALDUMPS/
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to move $dbdumpfile to $PGMANUALDUMPS/... skipping /tmp/$nameofdbdumpfile.*."
    emailerrorlog=1
    continue
  fi

  cd $PGHOME/SUScripts
  ./disconnectUsersFromDB.sh ${dbdumpfile}Report
  ./restoredb.sh SUReport ${dbdumpfile}Report $PGMANUALDUMPS/$nameofdbdumpfile
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to restore $dbdumpfile... skipping /tmp/$nameofdbdumpfile.*.gz."
    emailerrorlog=1
    continue
  fi
  log "SUCCESS: Successfully restored $dbdumpfile."

  # hardcode the following for MemberReport only for added security...
  if [ "$dbdumpfile" = "Member" ]; then
    log "INFO: Running post-restore actions for MemberReport..."
    psql -aeE -d MemberReport -U SUReport -f memberPostRestoreActions.sql
    if [ $? -ne 0 ]; then
      log "WARNING: Failed to run post-restore actions for MemberReport... skipping."
      emailerrorlog=1
      continue
    fi
    log "SUCCESS: Completed post-restore actions for MemberReport."
    echo "Restore to MemberReport has completed." | mail -s "$thisnode: Restore to MemberReport" "amy.lidstone@studentuniverse.com, bp@studentuniverse.com, chad@studentuniverse.com, mathews@studentuniverse.com"
  fi

done

log "Done"

#if [ $emailerrorlog = 1 ]; then
#  cat $PGMANUALDUMPS/restoredbdumps.$datestamp.log | mail -s "$subject" "$tofolks"
#fi
cat $PGMANUALDUMPS/restoredbdumps.$datestamp.log | mail -s "$subject" "$tofolks"

exit 0
