#! /bin/sh
# Dump database - dump, no vacuum 
# This utility is usually meant to be executed manually for whatever reason

if [ $# -lt 1 ]; then
  echo "Usage: `basename $0` database"
  exit 1
fi

. /space/postgresql/SUScripts/paths.shinc

database=$1
datetimestamp=`date +%Y%m%d%H%M`

echo "Creating the schema file for $database..."

# dump the database schema
pg_dump -s -c -v -f $PGMANUALDUMPS/$database.$datetimestamp.clr $database > $PGMANUALDUMPS/$database.$datetimestamp.clr.log 2>&1

if [ $? -ne 0 ]; then
  echo "  ERROR: Failed to create the schema file for $database... exiting."
  exit -1
fi

echo "Generating the data dump for $database..."

# dump the database data
pg_dump -a -b -v -F c -f $PGMANUALDUMPS/$database.$datetimestamp.dmp $database > $PGMANUALDUMPS/$database.$datetimestamp.dmp.log 2>&1 

if [ $? -ne 0 ]; then
  echo "  ERROR: Failed to create the dump file for $database... exiting."
  exit -2
fi

#echo "Running a vacuum verbose analyse on $database..."
#
## vacuum database after dump
#psql -d $database -c "vacuum verbose analyse" -S > $PGVACUUMS/vacuum$database.$datetimestamp.log 2>&1 
#
#if [ $? -ne 0 ]; then
#  echo "  WARNING: Failed to proply vacuum $database, please check it manually... exiting."
#  exit -99
#fi

exit 0
