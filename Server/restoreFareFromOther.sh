#! /bin/sh
# Restore fare db after scping it

if [ $# -lt 2 ]; then
    echo "Usage: `basename $0` RemoteDumpFile LocalTargetDB"
    exit 1
fi

scp 192.168.60.84:/space/postgresql/manualDumps/$1.* ../manualDumps/
time ./restoredb.sh SUFare $2 ../manualDumps/$1

exit 0
