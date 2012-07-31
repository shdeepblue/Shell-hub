#! /bin/sh

# NOTE: a backup is local; an archive is a remote copy of the local backup
# The process:
#   - check to make sure there are 4 resulting files from the database dump for today.
#   - compress todays backups on the backup server and move them to the local archive dir
#   - scp them to the archive server and compare their cksums.
#   - email if any errors


. /space/postgresql/SUScripts/paths.shinc

thisnode=`uname -n`
datestamp=`date +%Y%m%d`
subject="$thisnode: DB Backup Error"
tofolks="sys@studentuniverse.com, bp@studentuniverse.com"

backupfiles="ContentMgt FarePrep FarePrepDisabled Member Verification ContentMgtDev FareDev MemberDev ReportDev hotel_bookings"

archiveserver=bigmac
archiveuser=root
archivedir=/space/LogBackups/DBBackups

emailerrorlog=0

logfile=$PGBACKUPS/scpdbbackups.$datestamp.log
echo "Logging to $logfile..."

function log() {
  echo "$0[$$]:$(date +%Y%m%d%H%M):$@" >> $logfile
}

for backupfile in $backupfiles; do

  log "Archiving $backupfile..."

  numofbackupfiles=`ls -1 $PGBACKUPS/$backupfile.$datestamp* 2>/dev/null | wc -l`
  let numofbackupfiles=numofbackupfiles+0

  case $numofbackupfiles in
  0)
    log "WARNING: No such backup... skipping $PGBACKUPS/$backupfile.$datestamp."
    continue
    ;;
  4)
    log "OK: There are 4 resulting backup files for $PGBACKUPS/$backupfile.$datestamp."
    ;;
  *)
    log "ERROR: Incorrect number of local backup files ($numofbackupfiles/4)... skipping $PGBACKUPS/$backupfile.$datestamp."
    emailerrorlog=1
    continue
    ;;
  esac

  gzip $PGBACKUPS/$backupfile.$datestamp*  
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to gzip $PGBACKUPS/$backupfile.$datestamp*... skipping $PGBACKUPS/$backupfile.$datestamp."
    emailerrorlog=1
    continue 
  fi 

  scp -p $PGBACKUPS/$backupfile.$datestamp* $archiveuser@$archiveserver:$archivedir/$backupfile/
  if [ $? -ne 0 -a $? -ne 2 ]; then
    log "ERROR: Scp of the backups failed... skipping $PGBACKUPS/archives/$backupfile.$datestamp."
    emailerrorlog=1
    continue 
  fi 
 
  cksumbackup=`cksum $PGBACKUPS/$backupfile.$datestamp* | awk '{ print $2 }' | tr -d "\n"`
  cksumarchive=`ssh $archiveuser@$archiveserver cksum $archivedir/$backupfile/$backupfile.$datestamp* | awk '{ print $2 }' | tr -d "\n"`
  if [ "$cksumbackup" != "$cksumarchive" ]; then 
    log "ERROR: Checksum of archive failed for $PGBACKUPS/$backupfile.$datestamp."
    emailerrorlog=1
    continue 
  fi

  mv $PGBACKUPS/$backupfile.$datestamp* $PGBACKUPS/archives/
  if [ $? -ne 0 ]; then
    log "WARNING: Failed to move $PGBACKUPS/$backupfile.$datestamp*.gz to $PGBACKUPS/archives/... skipping $PGBACKUPS/$backupfile.$datestamp."
    emailerrorlog=1
    continue 
  fi 

  for i in `ls $PGBACKUPS/archives/$backupfile.$datestamp*`; do
    mv $i $i.archived
    if [ $? -ne 0 ]; then
      log "WARNING: Failed to rename $PGBACKUPS/archives/$backupfile.$datestamp*.gz to .archived... skipping $PGBACKUPS/$backupfile.$datestamp."
      emailerrorlog=1
      continue 
    fi
  done

  log "SUCCESS: Successfully archived $backupfile."
   
done

log "Done"

if [ $emailerrorlog = 1 ]; then
  cat $PGBACKUPS/scpdbbackups.$datestamp.log | mail -s "$subject" "$tofolks"
fi

if [ $emailerrorlog = 0 ]; then
  find /space/postgresql/backups/archives/*.gz.archived -mtime +14 | xargs rm
  find /space/postgresql/manualDumps/ -mtime +14 | xargs rm
fi
exit 0
