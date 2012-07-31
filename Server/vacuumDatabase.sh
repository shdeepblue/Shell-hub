#! /bin/sh
# Manually Vacuum a database

if [ $# -lt 1 ]; then
  echo "Usage: `basename $0` database"
  exit 1
fi

. /space/postgresql/SUScripts/paths.shinc

datetimestamp=`date +%Y%m%d%H%M`

psql -d $1 -c "vacuum verbose analyse" -S > $PGMANUALDUMPS/vacuum${1}.$datetimestamp.log 2>&1 

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to failed to vacuum $database... exiting."
  exit -1
fi

exit 0
