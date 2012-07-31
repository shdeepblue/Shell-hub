#!/bin/bash
#cpudir=`/usr/bin/sar -r 1 5 | grep Average | awk '{print $3}'`
#cpusys=`/usr/bin/sar -r 1 5 | grep Average | awk '{print $5}'`
cpudir=`/usr/bin/sar -u 1 3 | grep Average | awk '{print $3}'`
cpusys=`/usr/bin/sar -u 1 3 | grep Average | awk '{print $5}'`
uptime=`/usr/bin/uptime | awk '{print $3 "" $4 ""$5}'`
echo $cpudir
echo $cpusys
echo $uptime
hostname
