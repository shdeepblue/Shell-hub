#!/bin/bash

# A program can change the current net gateway to specific one
# Usage 'switch_2_gw.sh 140'
# Created: 15th August 2011 by SC

USAGE="Usage: $(basename $0) 250 [-ssh]  "

SSH_SERVER="sp1.wdc.studentuniverse.com"
LOCAL_PROXY_PORT="8889"
SSH_SERVER_USER="Weiguo.Hu"
SSH_SERVER_PASS='123456'

MINPARAMS=1


# Check whether user input the gw that need to be changed to
if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
  echo $USAGE
  exit 1
fi  


# Display the initial GW information
GW="$(ip route | awk '/default/{print $3}')"
#GW=`ip route | awk '/default/{print $3}'`

echo ' '
echo '********* Gateway information ********* '
echo 'The initial gateway is: '$GW
echo 'Now changing to: 10.20.70.'$1

# Now remove the inital GW
sudo route del default gw $GW
sleep 2
# Change to new GW
sudo route add default gw 10.20.70.$1

echo ''
echo '--------------------------------------'
# Display the result
echo 'Success! Now the gateway is '`ip route | awk '/default/{print $3}'`
echo ' '
sleep 2

# Staring VPN connection
echo '********* Starting VPN... ********* '
# Stop and start
sudo vpnc-disconnect
sleep 1
sudo vpnc su


if [ "$2" != "-ssh" ] ; then
	 exit 1
fi

# Staring SSH port mapping 
echo '********* Starting SSH... ********* '

existing_ssh="$(netstat -lntp | grep $LOCAL_PROXY_PORT | awk '{print $7}')"

if [ $existing_ssh != "" -a $existing_ssh != "-" ] ; then 
	echo "There is another process using this port: $existing_ssh , please kill it then start ssh again! "
	exit 1
else
	sudo sshpass -p $SSH_SERVER_PASS ssh -D10.20.70.120:$LOCAL_PROXY_PORT $SSH_SERVER_USER@$SSH_SERVER
fi

exit 0
