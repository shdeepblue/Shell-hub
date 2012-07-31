# 2010.7.21
# simon
#while true do
while [ 1 -le 2 ]; do
    echo "Simon Notice: don't close this program!  not it's checking sock5..."
    #netstat -tnlp | grep "240:7070" 
    if [ `netstat -tnlp | grep "10.20.70.240:7070" | wc -l` -lt 1 ]; then
        if [ `ping -c 5 10.20.70.254 | grep "ttl=[1-9]" | wc -l` -lt 3 ]; then
            echo "`date`: 10.20.70.254 is down" >> /root/7070-loop.log
            echo "10.20.70.254 is not reachable, check again after 60 secs..."
            sleep 60
            continue
        fi
        if [ `ping -c 5 sox1.su.com | grep "ttl=[1-9]" | wc -l` -lt 3 ]; then
            echo "`date`: sox1 is down" >> /root/7070-loop.log
            echo "sox1 is down, check again after 60 secs..."
            sleep 60
            continue
        fi
        stty sane
        service named restart
        echo "-----------------" >> /root/7070-loop.log
        date >> /root/7070-loop.log
        echo "ssh -D 10.20.70.240:7070 is down, now is up"
        echo "ssh -D 10.20.70.240:7070 is down, now is up" >> /root/7070-loop.log
	ssh -D 10.20.70.240:7070 simon.cao@sox1.su.com 
        #netstat -tnlp | grep "240:7070" 
        #netstat -tnlp | grep "240:7070" >> /root/7070-loop.log
        sleep 5
        continue
    fi
    echo "check is done. now will check it again after 15 secs..."
    sleep 15
    echo
done
