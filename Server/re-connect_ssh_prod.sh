#!/usr/bin/expect
#spawn rsync
spawn ssh -i /root/client.travelonomy.id_rsa travelonomy@prod.doloforge.com pwd
expect "(yes/no)?"
send "yes\n"

expect eof
exit
