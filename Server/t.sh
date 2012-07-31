# 2010.7.21
# simon
#while true do
if [ $# != 1 ] ; then
	echo "Usage: $0 hostname"
	echo " e.g.: $0 sox2"
	exit 1;
fi

HOST=$1
while [ 1 -le 2 ]; do
    echo "Simon Notice: don't close this program!  not it's checking sock5..."
    #netstat -tnlp | grep "240:7071" 
    if [ `netstat -tnlp | grep "10.20.70.240:7071" | wc -l` -lt 1 ]; then
        if [ `ping -c 5 10.20.70.254 | grep "ttl=[1-9]" | wc -l` -lt 3 ]; then
            echo "`date`: 10.20.70.254 is down" >> /root/7071-loop.log
            echo "10.20.70.254 is not reachable, check again after 60 secs..."
            sleep 60
            continue
        fi
        if [ `ping -c 5 ${HOST}.su.com | grep "ttl=[1-9]" | wc -l` -lt 3 ]; then
            echo "`date`: $HOST is down" >> /root/7071-loop.log
            echo "${HOST} is down, check again after 60 secs..."
            sleep 60
            continue
        fi
        echo "ssh -T -D 10.20.70.240:7071 is down, now is up"
	ssh -T -D 10.20.70.240:7071 simon.cao@${HOST}.su.com 

        #netstat -tnlp | grep "240:7071" 
        #netstat -tnlp | grep "240:7071" >> /root/7071-loop.log
        sleep 5
        continue
    fi
    echo "check is done. now will check it again after 15 secs..."
    sleep 15
    echo
done
