#! /bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: `basename $0` LocalTargetDB [force]"
  exit 1
fi

database=$1
force=$2

# BHP 20101206: add a force option so that production servers are not accidentally disconnected...
if [ "$force" == "force" ]
then
  procs=`ps -few | grep -i "postgres.*$database\ [0-9]" | grep -v grep | awk '{print $2}'`
  outstatememt="Killing ALL connection to $database, including production connections... "
else
  procs=`ps -few | grep -i "postgres.*$database\ [0-9]" | grep -v grep | grep -v 192.168.60 | awk '{print $2}'`
  outstatememt="Killing non-production connections... you can use the \"force\" option to kill production processes as well."
fi

echo $outstatement
for proc in $procs
do
  #kill $i
  sudo kill $proc
done

exit 0
