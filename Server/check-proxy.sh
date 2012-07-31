#! /bin/bash
#
# check-proxy 7/8/2010
# Simon Cao
#
#sock5:~ # ip route
#10.20.70.0/24 dev eth0  proto kernel  scope link  src 10.20.70.150
#169.254.0.0/16 dev eth0  scope link
#127.0.0.0/8 dev lo  scope link
#default via 10.20.70.240 dev eth0
#sock5:~ # ps -ef|grep redsocks
#simon     1865     1  0 Jul07 ?        00:00:00 ./redsocks
#sock5:~ # route add -net 10.20.0.0/16 eth0
#sock5:~ # route add -net 192.168.0.0/16 gw 10.20.70.241 dev eth0

echo "--------------------------------" >> /root/redsock.log
date >> /root/redsock.log
ip route >> /root/redsock.log

date | mail -s "check-proxy is checking(test only)" simon.cao@studentuniverse.com

echo "check-proxy is checking 10.20.70.0 ...(stage 0)" >> /root/redsock.log
echo "check-proxy is checking 10.20.70.0 for ip route...(stage 0)" 

if [ `ip route | grep "10.20.70.0/24 dev eth0  scope link" | wc -l` -lt 1 ]; then
        echo "10.20.70.0/24 dev eth0  scope link is not in route table"
        echo "10.20.70.0/24 dev eth0  scope link is not in route table" >> /root/redsock.log
        route add -net 10.20.70.0/24 eth0
fi

echo "check-proxy is checking 10.20.0.0 ...(stage 1)" >> /root/redsock.log
echo "check-proxy is checking 10.20.0.0 for ip route...(stage 1)" 

if [ `ip route | grep "10.20.0.0/16 via" | wc -l` -lt 1 ]; then
        echo "10.20.0.0/16 via is not in route table"
        echo "10.20.0.0/16 via is not in route table" >> /root/redsock.log
        route add -net 10.20.0.0/16 gw 10.20.70.254 dev eth0
fi

echo "check-proxy is checking 192.168.0.0 ...(stage 2)" >> /root/redsock.log
echo "check-proxy is checking 192.168.0.0 for ip route...(stage 2)" 

if [ `ip route | grep "192.168.0.0/16 via 10.20.70.241" | wc -l` -lt 1 ]; then
        echo "192.168.0.0/16 via 10.20.70.241 is not in route table"
        echo "192.168.0.0/16 via 10.20.70.241 is not in route table" >> /root/redsock.log
	route add -net 192.168.0.0/16 gw 10.20.70.241 dev eth0
fi


#    /home/soft/rsock/sock5.sh iptables
#    su simon -c "/home/soft/rsock/redsocks"

echo "check-proxy is checking ps -ef for redsocks ...(stage 3)" >> /root/redsock.log
echo "check-proxy is checking ps -ef for redsocks ...(stage 3)" 

if [ `ps -ef | grep "redsocks" | grep -v grep | wc -l` -lt 1 ]; then
        echo "redsocks is not running, now is restarting"
        echo "redsocks is not running, now is restarting" >> /root/redsock.log
        date >> /root/redsock.log
        cd /home/soft/rsock/
        chmod a+w /home/soft/*.log
    	su simon -c "/home/soft/rsock/redsocks"
        ps -ef | grep "redsocks" | grep -v grep >> /root/redsock.log
        iptables -L -t nat >> /root/redsock.log
fi


#proxy:/home/soft/rsock # /home/soft/rsock/sock5.sh iptables
#proxy:/home/soft/rsock # iptables -L -t nat


echo "check-proxy is checking iptables for redsocks ...(stage 4)" >> /root/redsock.log
echo "check-proxy is checking iptables for redsocks ...(stage 4)" 
if [ `iptables -L -t nat | grep REDSOCK | wc -l` -lt 4 ]; then
        echo "iptables -L -t nat is not good, now is restarting" 
        echo "iptables -L -t nat is not good, now is restarting" >> /root/redsock.log
        iptables -L -t nat >> /root/redsock.log
        echo "=============" >> /root/redsock.log
        cd /home/soft/rsock/
	./sock5.sh iptables
        iptables -L -t nat >> /root/redsock.log
	exit
fi

echo "redsock has good route table now!"
echo "---------------------check over" >> /root/redsock.log

exit
