#! /bin/bash
#
# check xen-vpn & route, if not , restart it and add route
# Simon Cao May 25,2010
#

echo "--------------------------------" >> /root/xen.log
date >> /root/xen.log
#date | mail -s "checking xen (test)" simon.cao@studentuniverse.com
#date | mail -s "checking xen (test)" cao_lu@hoperun.com

echo "check-xen is checking now..." >> /root/xen.log

if [ `xm list | grep vpn |grep "\-b"| wc -l` -lt 1 ]; then
        /bin/echo "xen is not running, now is restarting"
        /bin/echo "xen is not running, now is restarting" >> /root/xen_error.log
        date >> /root/xen_error.log
        /bin/echo "--- old : xm list ---" >> /root/xen_error.log
        xm list >> /root/xen_error.log
        /bin/echo "xen-vpn is not running, now is restarting" >> /root/xen_error.log
        xm start vpn
        date | mail -s "xen is down & restarting" simon.cao@studentuniverse.com
        #date | mail -s "xen is down & restarting" simon.cao2000@gmail.com
        /bin/echo "--- new : xm list ---" >> /root/xen_error.log
        xen list >> /root/xen_error.log
        sleep 5
        if [ `xm list | grep vpn |grep "\-b"| wc -l` -lt 1 ]; then
             /bin/echo "!!! xen-vpn is failed restarting" >> /root/xen_error.log
             # send email to me
             date | mail -s "!!! xen-vpn is failed !!!" simon.cao@studentuniverse.com
        else
             /bin/echo "xen is restarted successfully." >> /root/xen_error.log
        fi
else
        #echo "xen is working well." >> /root/xen.log
        ping -c 3 10.20.70.170 >> /root/xen.log
fi

#su-xen:~ # ip route
#10.20.70.0/24 dev br0  proto kernel  scope link  src 10.20.70.240
#10.20.0.0/16 via 10.20.70.254 dev br0
#192.168.0.0/16 via 10.20.70.241 dev br0
#127.0.0.0/8 dev lo  scope link
#default via 10.20.70.254 dev br0
if [ `ip route | grep "192.168.0.0/16 via 10.20.70.170 dev br0" | wc -l` -lt 1 ]; then
	route add -net 192.168.0.0/16 gw 10.20.70.170 dev br0
        echo "route add -net 192.168.0.0/16 gw 10.20.70.170 dev br0" >> /root/xen_error.log
fi 

if [ `ip route | grep "10.20.0.0/16 via 10.20.70.254 dev br0" | wc -l` -lt 1 ]; then
	route add -net 10.20.0.0/16 gw 10.20.70.254 dev br0
        echo "route add -net 10.20.0.0/16 gw 10.20.70.254 dev br0" >> /root/xen_error.log
fi

if [ `ps -ef|grep svnserve | grep -v grep| wc -l` -lt 1 ]; then
	svnserve -d -r /srv/svn
	date >> /root/xen_error.log
        echo "svnserve -d -r /srv/svn" >> /root/xen_error.log
fi
