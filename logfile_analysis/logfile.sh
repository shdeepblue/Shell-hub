#!/bin/bash
#
# Author VBird ( web: http://linux.vbird.org; email: vbird at mail dot vbird dot idv dot tw )
##########################################################################################
# NOTE:
# The readme text is written by chinese.
# Please see this scripts in your chinese System.
# 
# �o��{���O�� VBird �������A�������X������b 2002/02/10 �I
# �D�n���\���M�N�O�i��y�n���ɡz�����R�F�I
# �ثe�D�n�w��X�Ӷ��ضi��n���ɪ����R�B�z�G
#
#	0. �D����T �ǥѤ��R port �T���I
#	1. �n����T /var/log/secure
#	2. �n���O�� /var/log/wtmp
#	3. ���n�O�� /var/log/messages
#	4. �l��O�� /var/log/maillog
#		    /var/log/mail
#
# �o��{�������ե��x�D�n�b Red Hat 7.2 �H�� Mandrake 9.0 �W���A
# �ثe�D�n�����ե��x�h�O Red Hat 9 �P Mandrake 10.0 ��I
# ���檺���G�ᬰ���Z�A�ҥH�A���ӥi�H�A�Φb�j������ Linux 
# distributions �~��I�Ʊ��ǥѳo��{�������R�A�i�H�a���z
# ��h��ξA���D���޲z��I
# 
# ���~�A�Y�z�b�Ӥѭ�᤻�I�H�e���楻�{���A�h���{���N�|���R�e�@�Ѫ��n���ɡA
# �Y�O���I�H��A�h���R��Ѫ��n���ɡ�
#
#
##########################################################################################
# INSTALL (�w�ˤ�k)
#
# 1. �إߤu�@�ؿ��G
#	mkdir -p /usr/local/virus/logfile
#	�ñN logfile.sh �ƻs��ӥؿ��U�I
#	�åB�ݭn�ק��v�������i�����I
#	chmod 755       /usr/local/virus/logfile/logfile.sh
#	chown root:root /usr/local/virus/logfile/logfile.sh
#
# 2. �קﭫ�n���Ѽƶ��ءG
#    �U���o�T�Ӷ��ؽЦۦ�ק令�z�һݭn���A�Ϊ̪����O�d�w�]��
#	email=.....
#	basedir=..
#	outputall=...
#
# 3. �ק� crontab 
#    vi /etc/crontab �åB�b�䤤�s�W�@��G
#	10 0 * * * root /usr/local/virus/logfile/logfile.sh > /dev/null 2>&1
#    �H��C�Ѫ���� 12:10 �t�δN�|���A���R�A���n���ɡA�ñH�� root ��I
#	
##########################################################################################
#====================================================================
# ���v�����G
# ����P�ק��		����
# -------------------------------------------------------------------
# 2002/03/21 VBird	�s�W�@�ǥD������T�����ʧ@
# 2002/04/02 VBird	���ܭ���ϥ� cut �����O�A�H awk ���O�Ө��N�C
# 2002/04/10 VBird	�N��� pop3 ���~�n�����T���A�ѴM�� maillog 
#			��� messages �o���ɮ׷��I
# 2002/04/14 VBird	�ק��X��ƪ��榡�I
# 2003/03/11 VBird	�i��j�T��g�I�s�W����T�|���G
#			1. �s�W port �������A�|�N���G��X�F
#			2. �s�W�w�Хثe�{�p��X�F
# 2003/03/15 VBird	�ק�F Postfix ����X�榡�A�ܪ�����n�ݤ@��
# 2003/03/16 VBird	�[�J�F�@�Ǳ���A�קK 23 �o�� telnet �� port 
#			�����F�I
# 2003/06/11 VBird	�[�J�F /var/log/procmail.log �����R��ơA
#			�åB�ק�F sendmail ���P�w�覡�C
#			���~�A��ק�F defer ���{�w�зǡI
# 2004/01/17 VBird	�N pop3 ���C�L�����F�I
# 2004/03/07 VBird	�ק� Postfix ����X�榡�A����e���ݪ����I
#			�o�����O�����׼s�i�H�󪺮榡�I
# 2004/04/17 VBird	�׭q�F Postfix �b�s�i�H��X���������e�I
# 2004/12/29 VBird	���s�s�覹�@�{���A�Ϧ��� function modules ���榡�I
# 2005/01/04 VBird	�׭q date ���榡�A +%H �令 +%k ���
# 2005/01/05 VBird	�׭q�F ps -aux ���� ps -aux 2> /dev/null �F�I
# 2005/01/09 VBird	�s�W OpenWebmail �Ҳզb ./function/openwebmail �ɮסI
# 2005/03/25 VBird	�]�� FC3 �ϥΪ��O dovecot �Ӻ޲z pop3 ���T���A�ҥH�즳�� pop3 �w�g
#			����A�ΡC�ҥH��F�@�p�������{���o�I
# 2005/04/05 VBird	�]���ѬO�N postfix �~�P�� sendmail �A�ҥH�A���s���_ postfix ���E�_����
# 2005/04/27 VBird	�]�� /var/log/messages �b�ϥηs�� net-snmp ����A�S�|�h�X�s����T�A
#			�o�Ӹ�T�i���i�L��ҥH�A�b�̩��U�C�X messages �������A�N�L�����I
# 2005/05/11 VBird	�s�W�[ Samba ���ҲաI
# 2005/06/11 VBird	�Ѻ��� TsLG-Linul<linul@tslg.idv.tw> �ӫH�i���T����ܪ��a��ѰO�[�W���޸��A
#			�P�¡I�w�g�׭q�I
# 2009/03/05 VBird	�׭q mail server �� port 25 �^���A�]�� postfix �|�ϥ� smtpd �� master
#--------------------------------------------------------------------


##########################################################################################
# YOU MUST KEYIN SOME PARAMETERS HERE!!
# ���U����ƬO�z�����n��g���I
email="root@localhost"		# �o�O�n�N logfile �H���֪� e-mail
				# �A�]�i�H�N�o�Ǹ�ƱH���\�h�l��a�}�A
				# �i�H�ϥΩ��U���榡�G
				# email="root@localhost,yourID@hostname"
				# �C�� email �γr���j�}�A���n�[�ť���I

basedir="/usr/local/virus/logfile"	# �o�ӬO logfile.sh �o��{����m���ؿ�

outputall="yes"		# �o�ӬO�y�O�_�n�N�Ҧ����n���ɤ��e���L�X�ӡH
			# ���@��s��ӻ��A�u�n�ݷJ�㪺��T�Y�i�A
			# �ҥH�o�̿�� "no" �A�p�G�Q�n���D�Ҧ���
			# �n���T���A�h�i�H�]�w�� "yes" �I


##########################################################################################
# ���U����ƬݬݴN�n�A�]�����ݭn��ʡA�{���w�g�]�p�n�F�I
# �p�G�z����L���B�~�o�{�A�i�H�i��i�@�B���ק��I ^_^
export email basedir outputall


##########################################################################################
# 0. �]�w�@�ǰ򥻪��ܼƤ��e�P���� basedir �O�_�s�b
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
LANG=en
LANGUAGE=en
LC_TIME=en
export PATH LANG LANGUAGE LC_TIME
localhostname=`hostname`

# �ק�ϥΪ̶l���}�I
temp=`echo $email | cut -d '@' -f2`
if [ "$temp" == "localhost" ]; then
	email=`echo $email | cut -d '@' -f1`\@"$localhostname"
fi

# ���� awk �P sed �P egrep ���|�ϥΨ쪺�{�� �O�_�s�b
errormesg=""
programs="awk sed egrep ps cat cut tee netstat df uptime"
for profile in $programs
do
	which $profile > /dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo -e "�z���t�ΨèS���]�t $profile �{���F(Your system do not have $profile )"
		errormesg="yes"
	fi
done
if [ "$errormesg" == "yes" ]; then
	echo "�z���t�ίʥF���{������һݭn���t�ΰ����ɡA $0 �N����@�~"
	exit 1
fi

# ���� syslog �O�_���ҰʡI
temp=`ps -aux 2> /dev/null | grep syslog| grep -v grep`
if [ "$temp" == "" ]; then
	echo -e "�z���t�ΨS���Ұ� syslog �o�� daemon �A"
	echo -e "�@��ӻ��A�o�� daemon �ܭ��n�A�S���ҰʡA�N��i��w�g�Q�J�I�F�I"
	echo -e "���{���D�n�w�� syslog ���ͪ� logfile �Ӥ��R�A"
	echo -e "�]���A�S�� syslog �h���{���S�����椧���n�C"
	exit 0
fi

# ����Ȧs�ؿ��O�_�s�b�I
if [ ! -d "$basedir" ]; then
	echo -e "$basedir ���ؿ��ä��s�b�A���{�� $0 �L�k�i��u�@�I"
	exit 1
fi


##########################################################################################
# 0.1 �]�w������T�A�H�ά����� log files ���e���I
lastdate="2006-09-22"
versions="Version 0.1-4-2"
hosthome=`hostname`
logfile="$basedir/logfile.mail"
declare -i datenu=`date +%k`
if [ "$datenu" -le "6" ]; then
	date --date='1 day ago' +%b' '%e  > "$basedir/dattime"
else
	date +%b' '%e  > "$basedir/dattime"
fi
y="`cat $basedir/dattime`"
export lastdate hosthome logfile y

# 0.1.0 ���� syslog.conf �o���ɮ׬O�_�s�b
if [ ! -f "/etc/syslog.conf" ]; then
	echo -e "���{���ǥѤ��R /etc/syslog.conf ���o�z���n���ɡA"
	echo -e "�M�ӱz���t�η��õL /etc/syslog.conf �A�]���A"
	echo -e "�бz�ۦ�ק糧�{���A�Ϊ̡A"
	echo -e "�p�G�T�w�t�Φs�b syslog.conf �A���L�ؿ��ä��b /etc ���U"
	echo -e "�i�H�ϥγs�����覡�ӳs���� /etc/ ���U�G"
	echo -e "ln -s /full/path/syslog.conf /etc/syslog.conf "
	echo -e "���~�^���Ш� http://linux.vbird.org �d�ݸ�T�I"
	exit 1
fi

# 0.1.1 secure file
log=`grep 'authpriv\.\*' /etc/syslog.conf | awk '{print $2}'| \
	head -n 1|tr -d '-'`
if [ "$log" != "" ]; then
	cat $log | grep "$y" > "$basedir/securelog"
fi

# 0.1.2 maillog file
log=`grep 'mail\.\*' /etc/syslog.conf | awk '{print $2}'| \
	head -n 1|tr -d '-'`
if [ "$log" != "" ]; then
	cat $log                | grep "$y" > "$basedir/maillog"
else
	log=`grep 'mail\.' /etc/syslog.conf | awk '{print $2}'| \
	tr -d '-'|grep -v 'message'`
	if [ "$log" != "" ]; then
		cat $log                | grep "$y" > "$basedir/maillog"
	fi
fi

# 0.1.3 messages file
cat /var/log/messages   | grep "$y" > "$basedir/messageslog"
touch "$basedir/securelog"
touch "$basedir/maillog"
touch "$basedir/messageslog"

# The following lines are detecting your PC live?
  timeset1=`uptime | grep day`
  timeset2=`uptime | grep min`
  if [ "$timeset1" == "" ]; then
        if [ "$timeset2" == "" ]; then
                UPtime=`uptime | awk '{print $3}'`
        else
                UPtime=`uptime | awk '{print $3 " " $4}'`
        fi
  else
        if [ "$timeset2" == "" ]; then
                UPtime=`uptime | awk '{print $3 " " $4 " " $5}'`
        else
                UPtime=`uptime | awk '{print $3 " " $4 " " $5 " " $6}'`
        fi
  fi


##########################################################################################
# 1. �إ��w��e���q���A�H�Ψt�Ϊ���ƷJ��I
echo "##########################################################"  > $logfile
echo "�w��ϥΥ��{���Ӭd��z���n����"                   >> $logfile
echo "���{���ثe�������G $versions"                     >> $logfile
echo "�{���̫��s������G $lastdate"                   >> $logfile
echo "�Y�b�z���t�Τ��o�{���{�������D, �w��P���p���I"   >> $logfile
echo "���������� http://linux.vbird.org"                >> $logfile
echo "���D�^���G http://phorum.vbird.org/viewtopic.php?t=3425"      >> $logfile
echo "##########################################################" >> $logfile
echo "  "                                               >> $logfile
echo "=============== �t�ηJ�� =================================" >> $logfile
echo "�֤ߪ���  : `cat /proc/version | \
	awk '{print $1 " " $2 " " $3 " " $4}'`" 	>> $logfile
echo "CPU ��T  : `cat /proc/cpuinfo | \
	 grep "model name" |\
	 awk '{print $4 " " $5 " " $6}'`"		>> $logfile
cat /proc/cpuinfo | grep "cpu MHz" | \
	awk '{print "          : " $4 " MHz"}' 		>> $logfile
echo "�D���W��  : `hostname`" 				>> $logfile
echo "�έp���  : `date +%Y/%B/%d' '%H:%M:%S' '\(' '%A' '\)`" \
							>> $logfile
echo "���R�����: `cat $basedir/dattime`"		>> $logfile
echo "�w�}������: `echo $UPtime`" 			>> $logfile
echo "�ثe�D�������� partitions"			>> $logfile
df -h	| sed 's/^/       /'				>> $logfile
echo " "						>> $logfile
echo " "						>> $logfile


# 1.1 Port ���R
if [ -f $basedir/function/ports ]; then
	source $basedir/function/ports
fi


##########################################################################################
# 2 �}�l���ջݭn�i�檺�ҲաI
# 2.1 ���� ssh �O�_�s�b�H
input=`cat $basedir/netstat.tcp.output |egrep '(22|sshd)'`
if [ "$input" != "" ]; then
	source $basedir/function/ssh
	funcssh
	echo " "	>> $logfile
fi

# 2.2 ���� FTP �����N���
input=`cat $basedir/netstat.tcp.output |egrep '(21|ftp)'`
if [ "$input" != "" ]; then
	if [ -f /etc/ftpaccess ]; then
		source $basedir/function/wuftp
		funcwuftp
	fi
	proftppro=`which proftpd 2> /dev/null`
	if [ "$proftppro" != "" ]; then
		source $basedir/function/proftp
		funcproftp
	fi
fi

# 2.3 pop3 ����
input=`cat $basedir/netstat.tcp.output |grep 110`
if [ "$input" != "" ]; then
	dovecot=`cat $basedir/netstat.tcp.output | grep dovecot`
	if [ "$dovecot" != "" ]; then
		source $basedir/function/dovecot
		funcdovecot
		echo " " >> $logfile
	else
		source $basedir/function/pop3
		funcpop3
		echo " "	>> $logfile
	fi
fi

# 2.4 Mail ����
input=`cat $basedir/netstat.tcp.output $basedir/netstat.tcp.local 2> /dev/null |grep 25`
if [ "$input" != "" ]; then
	postfixtest=`netstat -tlnp 2> /dev/null |grep ':25'|grep -E '(master|smtpd)'`
	#sendmailtest=`ps -aux 2> /dev/null |grep sendmail| grep -v 'grep'`
	if [ "$postfixtest" != "" ] ;  then
		source $basedir/function/postfix
		funcpost
	else
		source $basedir/function/sendmail
		funcsendmail
	fi
	procmail=`/bin/ls /var/log| grep procmail| head -n 1`
	if [ "$procmail" != "" ] ; then
		source $basedir/function/procmail
		funcprocmail
	fi

	openwebmail=`ls /var/log | grep openwebmail | head -n 1`
	if [ "$openwebmail" != "" ]; then
		source $basedir/function/openwebmail
		funcopenwebmail
	fi
fi

# 2.5 samba ����
input=`cat $basedir/netstat.tcp.output  2> /dev/null |grep 139|grep smbd`
if [ "$input" != "" ]; then
	source $basedir/function/samba
	funcsamba
fi

#####################################################################
# 10. ��������T�C�X���H�@�@�@�I
if [ "$outputall" == "yes" ] || [ "$outputall" == "YES" ] ; then
	echo "  "                                  				>> $logfile
	echo "================= �������n���ɸ�T�J�� ======================="	>> $logfile
	echo "1. ���n���n���O���� ( Secure file )"           >> $logfile
	echo "   �����G�w�g�����F pop3 ����T�I"	     >> $logfile
	grep -v 'pop3' $basedir/securelog                    >> $logfile
	echo " "                                             >> $logfile
	echo "2. �ϥ� last �o�ӫ��O��X�����G"               >> $logfile
	last -20                                             >> $logfile
	echo " "                                             >> $logfile
	echo "3. �N�S���n�� /var/log/messages �C�X���@�@�I"  >> $logfile
	echo "   �w�g���� crond �P snmpd ���T��"	     >> $logfile
	cat $basedir/messageslog | egrep -vi '\bcrond\[' |\
		grep -vi 'crond(' |\
		grep -v 'snmpd.*UDP\:\ \[127.0.0.1\]'	     >> $logfile
fi

# At last! we send this mail to you!
if [ -x /usr/bin/uuencode ]; then
	uuencode $logfile logfile.txt | mail -s "$hosthome ���n���ɤ��R���G" $email 
else
	mail -s "$hosthome ���n���ɤ��R���G" $email < $logfile
fi
