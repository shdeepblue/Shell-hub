#! /bin/bash
#
# check vpnc , if not , restart it
# Simon Cao May 25,2010
#

echo "--------------------------------" >> /root/vpnc.log
date >> /root/vpnc.log
#date | mail -s "checking vpnc (test)" simon.cao@studentuniverse.com 
#date | mail -s "checking vpnc (test)" cao_lu@hoperun.com

echo "check-vpnc is checking now..." >> /root/vpnc.log

if [ `ip route| grep tun0 | wc | /bin/awk '{print $1}'` -lt 3 ]; then
	/bin/echo "vpnc is not running, now is restarting"
	/bin/echo "vpnc is not running, now is restarting" >> /root/vpnc.log
        echo "--------------------------------" >> /root/vpnc_error.log
	date >> /root/vpnc_error.log
	date >> /root/vpnc_error.log
	/bin/echo "--- old : ip route ---" >> /root/vpnc.log
	ip route >> /root/vpnc_error.log
	/bin/echo "vpnc is not running, now is restarting" >> /root/vpnc_error.log
	/usr/local/sbin/vpnc
        date | mail -s "vpnc is down & restarting" simon.cao@studentuniverse.com 
        #date | mail -s "vpnc is down & restarting" simon.cao2000@gmail.com 
	/bin/echo "--- new : ip route ---" >> /root/vpnc.log
	ip route >> /root/vpnc_error.log
	sleep 5
        if [ `ip route | grep tun0 | wc | /bin/awk '{print $1}'` -lt 3 ]; then
	     /bin/echo "!!!! vpnc is failed restarting" >> /root/vpnc_error.log
	     # send email to me
	else 
	     /bin/echo "vpnc is restarted successfully." >> /root/vpnc_error.log
        fi
else
        if [ `ping -c 5 192.168.60.123 | grep "ttl=[1-9]" | wc | awk '{print $1}'` -lt 3 ]; then
		date | mail -s "vpnc is dead, restarting now" simon.cao@studentuniverse.com
	        echo "vpnc is dead, restarting now" >> /root/vpnc_error.log
		/usr/local/sbin/vpnc-disconnect
		sleep 3
		/usr/local/sbin/vpnc
	else
	
		echo "vpnc is working well." >> /root/vpnc.log
	fi
fi

ping -c 4 192.168.60.15 >> /root/vpnc.log

# double check netstat
if [ `netstat -rn | grep "10.20.0.0" | wc | /bin/awk '{print $1}'` -lt 1 ]; then
	echo "running route add -net 10.20.0.0/16 br0" >> /root/vpnc.log
	route add -net 10.20.0.0/16 br0
	echo "ip route for 10.20 is added." >> /root/vpnc_error.log
else
	echo "ip route for 10.20 is working well." >> /root/vpnc.log
fi

if [ `netstat -rn | grep "192.168.0.0" | wc | /bin/awk '{print $1}'` -lt 1 ]; then
	echo "running route add -net 192.168.0.0/16 tun0" >> /root/vpnc.log
	route add -net 192.168.0.0/16 tun0
	echo "ip route for 192.168 is added." >> /root/vpnc_error.log
else
	echo "ip route for 192.168 is working well." >> /root/vpnc.log
fi

# double check iptables
if [ `iptables -L -t nat | grep MASQUERADE | wc | /bin/awk '{print $1}'` -lt 1 ]; then
	echo "running iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE" >> /root/vpnc.log
	iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
	echo "iptables is added." >> /root/vpnc_error.log
        # send mail to me
else
	echo "iptables is working well." >> /root/vpnc.log
fi
