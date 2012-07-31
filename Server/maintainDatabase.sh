#! /bin/sh
# Maintain database - dump and vacuum (not a full vacuum which locks tables)
# This utility is usually meant to be croned on all important database servers

if [ $# -lt 1 ]; then
  echo "Usage: `basename $0` database"
  exit 1
fi

database=$1

. /space/postgresql/SUScripts/paths.shinc

datetimestamp=`date +%Y%m%d%H%M`

echo "Creating the schema file for $database..."

# dump the database schema
time pg_dump -s -c -v -f $PGBACKUPS/$database.$datetimestamp.clr $database > $PGBACKUPS/$database.$datetimestamp.clr.log 2>&1

if [ $? -ne 0 ]; then
  echo "  ERROR: Failed to create the schema file for $database... exiting."
  exit -1
fi

echo "Generating the data dump for $database..."

# dump the database data
time pg_dump -a -b -v -F c -f $PGBACKUPS/$database.$datetimestamp.dmp $database > $PGBACKUPS/$database.$datetimestamp.dmp.log 2>&1

if [ $? -ne 0 ]; then
  echo "  ERROR: Failed to create the dump file for $database... exiting."
  exit -2
fi

echo "scp-ing the dump file for archiving..."
/space/postgresql/SUScripts/scpTodaysProductionBackups.sh

# no longer needed with 8.3.7 upgrade and its autovacuum
#echo "Running a vacuum verbose analyse on $database..."
#
## vacuum database after dump
#time psql -d $database -c "vacuum verbose analyse" -S > $PGVACUUMS/vacuum$database.$datetimestamp.log 2>&1
#
#if [ $? -ne 0 ]; then
#  echo "  WARNING: Failed to proply vacuum $database, please check it manually... exiting."
#  exit -99
#fi

exit 0
