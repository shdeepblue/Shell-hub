#! /bin/bash
#
# check xen-vpn & route, if not , restart it and add route
# Simon Cao May 25,2010
#

echo "--------------------------------" >> /root/7070.log
date >> /root/7070.log
netstat -tnlp | grep "10.20.70.240:" >> /root/7070.log

date | mail -s "check-sock5 is checking(test only)" simon.cao@studentuniverse.com

echo "check-sock5 is checking 10.20.70.254 now...(stage 1)" >> /root/7070.log
echo "check-sock5 is checking 10.20.70.254 now...(stage 1)" 

if [ `ping -c 3 10.20.70.254 | grep "ttl=[1-9]" | wc -l` -lt 2 ]; then
    	date | mail -s "Gateway(10.20.70.254) is unavailable!" simon.cao@studentuniverse.com
    	echo "stage 1: Gateway(10.20.70.254) is unavailable!" >> /root/7070.log
	# kill old process
        if [ `ps -ef|grep "ssh -D 10.20.70.240:7070" |grep -v grep|wc -l` -gt 0 ]; then
          echo `ps -ef|grep "240:7070" |grep -v grep|awk '{print $2}'` "is killed."
          echo `ps -ef|grep "240:7070" |grep -v grep|awk '{print $2}'` "is killed." >>/root/7070.log
	  kill -9 `ps -ef | grep "ssh -D 10.20.70.240:7070" |grep -v grep| awk '{print $2}'`
  	fi
        exit
else
        echo "stage 1: Gateway(10.20.70.254) is working well." 
fi

echo "check-sock5 is checking sox3.su.com now...(stage 2)" >> /root/7070.log
echo "check-sock5 is checking sox3.su.com now...(stage 2)" 

if [ `ping -c 5 sox3.su.com | grep "ttl=[1-9]" | wc -l` -lt 2 ]; then
    	date | mail -s "sox3.su.com is unavailable!" simon.cao@studentuniverse.com
    	echo "stage 2: sox3.su.com is unavailable!" >> /root/7070.log
        if [ `ps -ef|grep "ssh -D 10.20.70.240:7070" |grep -v grep|wc -l` -gt 0 ]; then
          echo `ps -ef|grep "240:7070" |grep -v grep|awk '{print $2}'` "is killed."
          echo `ps -ef|grep "240:7070" |grep -v grep|awk '{print $2}'` "is killed." >>/root/7070.log
	  kill -9 `ps -ef | grep "ssh -D 10.20.70.240:7070" |grep -v grep| awk '{print $2}'`
  	fi
        exit
else
        echo "stage 2: sox3.su.com is working well." 
fi


echo "check-sock5 is checking netstat -tnl now...(stage 3)" >> /root/7070.log
echo "check-sock5 is checking netstat -tnl now...(stage 3)" 

#if [ `netstat -tnlp | grep "10.20.70.240:7070" | wc -l` -lt 1 ]; then
#        echo " stage 3: sock5 is not listening, now is restarting"
#        echo "sock5 is not listening, now is restarting======" >> /root/7070.log
#	ssh -D 10.20.70.240:7070 simon.cao@sox3.su.com &
#        sleep3
#        netstat -tnlp | grep "240:7070" >> /root/7070.log
#        netstat -tnlp | mail -s "sock5 is down & restarting" simon.cao@studentuniverse.com
#else
#	echo "sock5 is working pretty well on 10.20.70.240 !"
#        exit
#fi

echo "check-sock5 is checking netstat -tnl again...(stage 4)" >> /root/7070.log
echo "check-sock5 is checking netstat -tnl again...(stage 4)" 

if [ `netstat -tnlp | grep "10.20.70.240:7070" | wc -l` -lt 1 ]; then
        echo "stage 4:sock5 is not listening, now is restarting"
        echo "sock5 is not listening, now is restarting" >> /root/7070.log
        netstat -tnlp | mail -s "sock5 has big problem !!!!!" simon.cao@studentuniverse.com
        exit
fi

echo "check-7070 is done on 10.20.70.240 !"

exit
