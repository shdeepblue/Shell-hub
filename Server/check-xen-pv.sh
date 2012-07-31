#! /bin/bash
#
# check xen-vpn & route, if not , restart it and add route
# Simon Cao May 25,2010
#

date '+%Y-%m-%d %H:%M:%S' >> /root/xen-err.log
#date | mail -s "checking xen (test)" simon.cao@studentuniverse.com
#date | mail -s "checking xen (test)" cao_lu@hoperun.com

#echo "check-xen is checking now..." >> /root/xen-err.log

if [ `xm list | grep "proxy-vpn" | egrep "b|r"| wc -l` -lt 1 ]; then
        echo "proxy-vpn is not running, now is restarting"
        echo "proxy-vpn is not running, now is restarting" >> /root/xen-err.log
        date '+%Y-%m-%d %H:%M:%S' >> /root/xen-err.log
        echo "--- old : xm list ---" >> /root/xen-err.log
        xm list >> /root/xen-err.log
        echo "xen-vpn is not running, now is restarting" >> /root/xen-err.log
        xm start proxy-vpn
        date | mail -s "xen is down & restarting" simon.cao@studentuniverse.com
        echo "--- new : xm list ---" >> /root/xen-err.log
        xen list >> /root/xen-err.log
        sleep 5
        if [ `xm list | grep "proxy-vpn" |grep "r|b"| wc -l` -lt 1 ]; then
             echo "!!! proxy-vpn is failed restarting" >> /root/xen-err.log
             date | mail -s "!!! proxy-vpn is failed !!!" simon.cao@studentuniverse.com
        else
             echo "proxy-vpn is restarted successfully." >> /root/xen-err.log
        fi
fi

if [ `ip route | grep "192.168.0.0/16 via 10.20.70.170 dev br0" | wc -l` -lt 1 ]; then
	route add -net 192.168.0.0/16 gw 10.20.70.170 dev br0
        echo "route add -net 192.168.0.0/16 gw 10.20.70.170 dev br0" >> /root/xen-err.log
fi 

if [ `ip route | grep "10.20.0.0/16 via 10.20.70.254 dev br0" | wc -l` -lt 1 ]; then
	route add -net 10.20.0.0/16 gw 10.20.70.254 dev br0
        echo "route add -net 10.20.0.0/16 gw 10.20.70.254 dev br0" >> /root/xen-err.log
fi

if [ `ps -ef|grep svnserve | grep -v grep| wc -l` -lt 1 ]; then
	svnserve -d -r /srv/svn
        echo "svnserve -d -r /srv/svn" >> /root/xen-err.log
fi
