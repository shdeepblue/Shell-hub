#!/bin/bash
# This script will monitor the KBread/sec &KBwriten/sec of Disk.
# Creater: CCC IT loren   ext:2288    2005/8/3
# As sda ,sdb,sdc,sdd,hda.


# disk=sda
#!/bin/sh
hd=sda
disk=/dev/$hd
UPtime=`/usr/bin/uptime |awk '{print $3""$4""$5}'` 
KBread_sec=`iostat $disk|grep $hd |awk '{print $3}'`
KBwrite_sec=`iostat $disk|grep $hd |awk '{print $4}'`
echo $KBread_sec
echo $KBwrite_sec
echo $UPtime
hostname

