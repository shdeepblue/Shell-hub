#!/bin/bash
SSH_SERVER="sp1.wdc.studentuniverse.com"
LOCAL_PROXY_PORT="8889"
SSH_SERVER_USER="Weiguo.Hu"
SSH_SERVER_PASS='123456'

echo '********* Starting SSH... ********* '

existing_ssh="$(netstat -lntp | grep 8889 | awk '{print $7}')"
echo $existing_ssh

if [ $existing_ssh = "" ] ; then 
	echo "yes"
else
	echo "No"
fi

exit 0
