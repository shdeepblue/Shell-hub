#!/bin/sh
# 2010.6.1 Simon.Cao
# 2010.7.5 Changed to /space/SUSscripts/China 

TMP="/tmp/xensum.$(date +%s)"

while getopts r:e option; do
	case ${option} in
		"r")
			option_r=$OPTARG
			;;
		"e")
			em="true"
			;;
	esac
done



# for m in $(cat /space/SUScripts/mkthosts.txt) $(cat /space/SUScripts/geminihosts.txt) $(cat /space/SUScripts/xenhosts.txt); do
for m in $(cat /space/SUScripts/China/cn-xenhosts.txt); do
        echo "DOING.... ${m}"
         if [ "$(ping -c 1 ${m} | grep -o "100% packet loss" )"  = "100% packet loss" ]
         then
        echo "___________________________________________________________" >> ${TMP}
        echo "___________________________________________________________" >> ${TMP}
        echo "${m} DOES NOT RESPOND TO PINGS at $( "nslookup" ${m} | grep "Address: " ) "  >> ${TMP}
         else
        echo "___________________________________________________________" >> ${TMP}
	echo "___________________________________________________________" >> ${TMP}
	echo "XENHOST NAME:  ${m}" >> ${TMP}
	echo "  INTERFACES:" >> ${TMP} 

	for x in $(ssh ${m} "ifconfig" | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }' | grep -v "127.0.0.1" ); do
	echo "               ${x} $( "nslookup" ${x} | grep -o "= ".* | awk '{ print $2 }') " >> ${TMP}
	done
	echo "                   " >> ${TMP}
	echo "   KERNEL VERSION:  $(ssh ${m} "uname -a" | awk '{print $3}') " >>  ${TMP}
        echo "       PROCESSORS:  $(ssh ${m} "cat /proc/cpuinfo" | grep -c proc ) " >> ${TMP}
	echo "       OS VERSION:  $(ssh ${m} cat /etc/SuSE-release | grep SUSE ) " >>  ${TMP}
        echo "        TOTAL RAM:  $(ssh ${m} "xm info" | grep '^total_memory' | awk '{ print $3 }') MB" >> ${TMP}
	echo "           OS RAM:  $(ssh ${m} "free -m" | grep Mem | awk '{print $2}') MB" >> ${TMP}
	echo "         FREE RAM:  $(ssh ${m} "xm info" | grep ^free_mem | awk '{print $3}' ) MB" >> ${TMP}
        echo "TOTAL  DISK SPACE:  $(ssh ${m} "vgs" | grep VG[0-9]0 | awk '{ print $6 }')" >> ${TMP}
        echo "  FREE DISK SPACE:  $(ssh ${m} "vgs" | grep VG[0-9]0 | awk '{ print $7 }')" >> ${TMP}



        for x in $(ssh ${m} "xm list" | tail +3 | grep b- | awk '{ print $1 }' ); do
	  echo "              ${x} " >> ${TMP}
	  echo "                   FREE RAM: $(ssh ${x} "free -om" | grep 'Mem:' | awk '{print $4}')MB  " >> ${TMP}
	  echo "                  TOTAL RAM: $(ssh ${x} "free -om" | grep 'Mem:' | awk '{print $2}')MB  " >> ${TMP}
	  echo "                 INTERFACES: " >> ${TMP}
	  for p in $(ssh ${x} "ifconfig" | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }' | grep -v "127.0.0.1" ); do
              echo "                      ${p} $( "nslookup" ${p} | grep -o "= ".* | awk '{ print $2 }') " >> ${TMP}
            done
        done



      fi
done


if [[ "${em:-"false"}" == "true" ]]; then
	cat ${TMP} | mail -r "Systems Notification <simon.cao@studentuniverse.com>" -s "China Daily Xenhost Summary Report: $(date "+%m/%d/%Y")" "${option_r:="simon.cao@studentuniverse.com"}"
else
	cat ${TMP}
fi

rm -f ${TMP}

exit 0 
