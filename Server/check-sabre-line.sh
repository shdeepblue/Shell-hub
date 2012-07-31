#!/bin/sh

# Simon Cao 7/23/2010
# get the percentage of linesBad vs. total lines ,see  http://admin/gdsinfo/
# linesIdle + linesActive + linesBad = total lines
# To send email notification based on linesBad vs. total lines
# send critical when bad line rate > 60%
# send warning  when bad line rate > 30%
#

if [ $# -lt 1 ] ; then
	echo "Usage: check-sabre-line.sh -e -r <your_email@your_domain.com> -s <your_server_list.txt>"
	echo "Example: check-sabre-line.sh -e -y   : send regular report"
	echo "         check-sabre-line.sh -e      : send error report to default guy if exist"
	echo "         check-sabre-line.sh         : show report"
	echo "         check-sabre-line.sh -e -r sys@studentuniverse.com     "
	echo "                                     : send error report to sys@studentuniverse.com"
	echo
fi;

while getopts r:s:ye option; do
    case ${option} in
        "r")
            option_r=$OPTARG
            ;;
        "e")
            em="true"
            ;;
        "s")
            server_list=$OPTARG
            ;;
        "y")
            report="true"
            ;;
    esac
done


# for sabre
sabre1_total=0
sabre1_bad=0
sabre1_active=0
sabre1_idle=0

# for sabrews
sabre2_total=0
sabre2_bad=0
sabre2_active=0
sabre2_idle=0

# for unreachable hosts
failhosts=""

for m in $(cat ${server_list:="/space/SUScripts/China/gds_servers.txt"}); do
    if [[ "${em:-"false"}" == "false" ]]; then echo "checking ${m}"; fi

    all=$(wget --quiet -O - "http://${m}.wdc.studentuniverse.com/rawmonitor2.jsp" | grep "=" | sed -e 's/\x0d/\\n/g')
	
	if [ "$all" = "" ]; then 
		failhosts="${failhosts} \n\n${m} is not reachable !!!\n"
		echo -e "\t\t${m} is not reachable !!!"
		continue; 
	fi

    idle1=$(echo -e $all  |grep "sabre_linesIdle="  |tr -d "[a-z][A-Z][_][=]")
    active1=$(echo -e $all|grep "sabre_linesActive="|tr -d "[a-z][A-Z][_][=]")
    bad1=$(echo -e $all   |grep "sabre_linesBad="   |tr -d "[a-z][A-Z][_][=]")
    idle2=$(echo -e $all  |grep "sabrews_linesIdle="  |tr -d "[a-z][A-Z][_][=]")
    active2=$(echo -e $all|grep "sabrews_linesActive="|tr -d "[a-z][A-Z][_][=]")
    bad2=$(echo -e $all   |grep "sabrews_linesBad="   |tr -d "[a-z][A-Z][_][=]")

    total1=$(expr $idle1 + $active1 + $bad1)
    total2=$(expr $idle2 + $active2 + $bad2)

    if [[ "${em:-"false"}" == "false" ]]; then
        echo -e "\t\tsabre   idle:$idle1, active:$active1, bad:$bad1, total:$total1"
        echo -e "\t\tsabrews idle:$idle2, active:$active2, bad:$bad2, total:$total2"
    fi

	sabre1_idle=$(expr $sabre_idle + $idle1)
	sabre1_active=$(expr $sabre_active + $active1)
	sabre1_bad=$(expr $sabre_bad + $bad1)
	sabre1_total=$(expr $sabre_total + $total1)
	sabre2_idle=$(expr $sabre2_idle + $idle2)
	sabre2_active=$(expr $sabre2_active + $active2)
	sabre2_bad=$(expr $sabre2_bad + $bad2)
	sabre2_total=$(expr $sabre2_total + $total2)

done

rate1=$(echo "scale=2; $sabre1_bad / $sabre1_total * 100" | bc)
rate2=$(echo "scale=2; $sabre2_bad / $sabre2_total * 100" | bc)

if [[ "${em:-"false"}" == "false" ]]; then
   echo
   echo -n "Sabre   total line:$sabre1_total , bad line:$sabre1_bad , active:$sabre1_active ,"
   echo "  Bad line rate:$rate1"
   echo -n "Sabrews total line:$sabre2_total , bad line:$sabre2_bad , active:$sabre2_active ,"
   echo "  Bad line rate:$rate1"
fi

if [ `echo "$rate1 >= 60" | bc` -eq 1 ] ; then
    mess1="Critical !!! Sabre bad line >= 60%." 
elif [ `echo "$rate1 >= 30" | bc` -eq 1 ] ; then
    mess1="Warning ! Sabre bad line >= 30%." 
else
    mess1="Sabre System works Normally.   Bad line < 30%" 
fi

if [ `echo "$rate2 >= 60" | bc` -eq 1 ] ; then
    mess2="Critical !!! Sabrews bad line >= 60%." 
elif [ `echo "$rate2 >= 30" | bc` -eq 1 ] ; then
    mess2="Warning ! Sabrews bad line >= 30%." 
else
    mess2="Sabrews System works Normally.   Bad line < 30%" 
fi

if [[ "${em:-"false"}" == "true" ]]; then
    if [ `echo "$rate1 >= 30" | bc` -eq 1 ] ; then
        echo -e "${failhosts} $mess1 \n\nSabre Bad line rate is $rate1 %.\n\nActive line: $sabre1_active, \nBad line: $sabre1_bad, \nIdle line: $sabre1_idle \n\nTotal line: $sabre1_total" | mail -r "Systems Notification <sys@studentuniverse.com>" -s "$mess1 $(date "+%m/%d/%Y")" "${option_r:="simon.cao@studentuniverse.com"}"
    fi
    if [ `echo "$rate2 >= 30" | bc` -eq 1 ] ; then
        echo -e "${failhosts} $mess2 \n\nSabrews Bad line rate is $rate2 %.\n\nActive line: $sabre2_active, \nBad line: $sabre2_bad, \nIdle line: $sabre2_idle \n\nTotal line: $sabre2_total" | mail -r "Systems Notification <sys@studentuniverse.com>" -s "$mess2 $(date "+%m/%d/%Y")" "${option_r:="simon.cao@studentuniverse.com"}"
    fi
else
    echo -e $failhosts
    echo $mess1
    echo $mess2
fi

# force to send regular report even sabre work fine.
if [[ "${report:-"false"}" = "true" ]]; then 
		#echo "sending Sabre Bad Line Report..."
        echo -e "${failhosts} \nSabre\n------\nTotal: $sabre1_total \nBad line: $sabre1_bad \nActive: $sabre1_active \nIdle: $sabre1_idle \nBad line rate: $rate1 \n\n\nSabrews\n------\nTotal: $sabre2_total \nBad line: $sabre2_bad \nActive: $sabre2_active \nIdle: $sabre2_idle \nBad line rate: $rate2" | mail -r "Systems Notification <sys@studentuniverse.com>" -s "Sabre Bad Line Report $(date "+%m/%d/%Y")" "${option_r:="simon.cao@studentuniverse.com"}"
fi
