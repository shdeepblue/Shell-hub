#!/bin/bash
#
# Author VBird ( web: http://linux.vbird.org; email: vbird at mail dot vbird dot idv dot tw )
##########################################################################################
# NOTE:
# The readme text is written by chinese.
# Please see this scripts in your chinese System.
# 
# 這支程式是由 VBird 完成的，首次釋出的日期在 2002/02/10 ！
# 主要的功能當然就是進行『登錄檔』的分析了！
# 目前主要針對幾個項目進行登錄檔的分析處理：
#
#	0. 主機資訊 藉由分析 port 訊息！
#	1. 登錄資訊 /var/log/secure
#	2. 登錄記錄 /var/log/wtmp
#	3. 重要記錄 /var/log/messages
#	4. 郵件記錄 /var/log/maillog
#		    /var/log/mail
#
# 這支程式的測試平台主要在 Red Hat 7.2 以及 Mandrake 9.0 上面，
# 目前主要的測試平台則是 Red Hat 9 與 Mandrake 10.0 喔！
# 執行的結果頗為順暢，所以，應該可以適用在大部分的 Linux 
# distributions 才對！希望藉由這支程式的分析，可以帶給您
# 更多更舒適的主機管理喔！
# 
# 此外，若您在該天凌晨六點以前執行本程式，則本程式將會分析前一天的登錄檔，
# 若是六點以後，則分析當天的登錄檔～
#
#
##########################################################################################
# INSTALL (安裝方法)
#
# 1. 建立工作目錄：
#	mkdir -p /usr/local/virus/logfile
#	並將 logfile.sh 複製到該目錄下！
#	並且需要修改權限成為可執行喔！
#	chmod 755       /usr/local/virus/logfile/logfile.sh
#	chown root:root /usr/local/virus/logfile/logfile.sh
#
# 2. 修改重要的參數項目：
#    下面這三個項目請自行修改成您所需要的，或者直接保留預設值
#	email=.....
#	basedir=..
#	outputall=...
#
# 3. 修改 crontab 
#    vi /etc/crontab 並且在其中新增一行：
#	10 0 * * * root /usr/local/virus/logfile/logfile.sh > /dev/null 2>&1
#    以後每天的凌晨 12:10 系統就會幫你分析你的登錄檔，並寄給 root 喔！
#	
##########################################################################################
#====================================================================
# 歷史紀錄：
# 日期與修改者		項目
# -------------------------------------------------------------------
# 2002/03/21 VBird	新增一些主機的資訊收集動作
# 2002/04/02 VBird	改變原先使用 cut 的指令，以 awk 指令來取代。
# 2002/04/10 VBird	將原先 pop3 錯誤登錄的訊息，由尋找 maillog 
#			轉到 messages 這個檔案當中！
# 2002/04/14 VBird	修改輸出資料的格式！
# 2003/03/11 VBird	進行大幅改寫！新增的資訊會有：
#			1. 新增 port 的偵測，會將結果輸出；
#			2. 新增硬碟目前現況輸出；
# 2003/03/15 VBird	修改了 Postfix 的輸出格式，變的比較好看一些
# 2003/03/16 VBird	加入了一些控制元，避免 23 這個 telnet 的 port 
#			捉錯了！
# 2003/06/11 VBird	加入了 /var/log/procmail.log 的分析資料，
#			並且修改了 sendmail 的判定方式。
#			此外，亦修改了 defer 的認定標準！
# 2004/01/17 VBird	將 pop3 的列印拿掉了！
# 2004/03/07 VBird	修改 Postfix 的輸出格式，比較容易看的懂！
#			這部分是關於抵擋廣告信件的格式！
# 2004/04/17 VBird	修訂了 Postfix 在廣告信輸出的部分內容！
# 2004/12/29 VBird	重新編輯此一程式，使成為 function modules 的格式！
# 2005/01/04 VBird	修訂 date 的格式， +%H 改成 +%k 喔～
# 2005/01/05 VBird	修訂了 ps -aux 成為 ps -aux 2> /dev/null 了！
# 2005/01/09 VBird	新增 OpenWebmail 模組在 ./function/openwebmail 檔案！
# 2005/03/25 VBird	因為 FC3 使用的是 dovecot 來管理 pop3 的訊息，所以原有的 pop3 已經
#			不能適用。所以改了一小部分的程序囉！
# 2005/04/05 VBird	因為老是將 postfix 誤判為 sendmail ，所以，重新評斷 postfix 的診斷機制
# 2005/04/27 VBird	因為 /var/log/messages 在使用新的 net-snmp 之後，又會多出新的資訊，
#			這個資訊可有可無～所以，在最底下列出 messages 的部分，將他移除！
# 2005/05/11 VBird	新增加 Samba 的模組！
# 2005/06/11 VBird	由網友 TsLG-Linul<linul@tslg.idv.tw> 來信告知訊息顯示的地方忘記加上雙引號，
#			感謝！已經修訂！
# 2009/03/05 VBird	修訂 mail server 的 port 25 擷取，因為 postfix 會使用 smtpd 或 master
#--------------------------------------------------------------------


##########################################################################################
# YOU MUST KEYIN SOME PARAMETERS HERE!!
# 底下的資料是您必須要填寫的！
email="root@localhost"		# 這是要將 logfile 寄給誰的 e-mail
				# 你也可以將這些資料寄給許多郵件地址，
				# 可以使用底下的格式：
				# email="root@localhost,yourID@hostname"
				# 每個 email 用逗號隔開，不要加空白鍵！

basedir="/usr/local/virus/logfile"	# 這個是 logfile.sh 這支程式放置的目錄

outputall="yes"		# 這個是『是否要將所有的登錄檔內容都印出來？
			# 對於一般新手來說，只要看彙整的資訊即可，
			# 所以這裡選擇 "no" ，如果想要知道所有的
			# 登錄訊息，則可以設定為 "yes" ！


##########################################################################################
# 底下的資料看看就好，因為不需要更動，程式已經設計好了！
# 如果您有其他的額外發現，可以進行進一步的修改喔！ ^_^
export email basedir outputall


##########################################################################################
# 0. 設定一些基本的變數內容與檢驗 basedir 是否存在
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
LANG=en
LANGUAGE=en
LC_TIME=en
export PATH LANG LANGUAGE LC_TIME
localhostname=`hostname`

# 修改使用者郵件位址！
temp=`echo $email | cut -d '@' -f2`
if [ "$temp" == "localhost" ]; then
	email=`echo $email | cut -d '@' -f1`\@"$localhostname"
fi

# 測驗 awk 與 sed 與 egrep 等會使用到的程式 是否存在
errormesg=""
programs="awk sed egrep ps cat cut tee netstat df uptime"
for profile in $programs
do
	which $profile > /dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo -e "您的系統並沒有包含 $profile 程式；(Your system do not have $profile )"
		errormesg="yes"
	fi
done
if [ "$errormesg" == "yes" ]; then
	echo "您的系統缺乏本程式執行所需要的系統執行檔， $0 將停止作業"
	exit 1
fi

# 測驗 syslog 是否有啟動！
temp=`ps -aux 2> /dev/null | grep syslog| grep -v grep`
if [ "$temp" == "" ]; then
	echo -e "您的系統沒有啟動 syslog 這個 daemon ，"
	echo -e "一般來說，這個 daemon 很重要，沒有啟動，代表可能已經被入侵了！"
	echo -e "本程式主要針對 syslog 產生的 logfile 來分析，"
	echo -e "因此，沒有 syslog 則本程式沒有執行之必要。"
	exit 0
fi

# 測驗暫存目錄是否存在！
if [ ! -d "$basedir" ]; then
	echo -e "$basedir 此目錄並不存在，本程式 $0 無法進行工作！"
	exit 1
fi


##########################################################################################
# 0.1 設定版本資訊，以及相關的 log files 內容表格！
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

# 0.1.0 偵測 syslog.conf 這個檔案是否存在
if [ ! -f "/etc/syslog.conf" ]; then
	echo -e "本程式藉由分析 /etc/syslog.conf 取得您的登錄檔，"
	echo -e "然而您的系統當中並無 /etc/syslog.conf ，因此，"
	echo -e "請您自行修改本程式，或者，"
	echo -e "如果確定系統存在 syslog.conf ，不過目錄並不在 /etc 底下"
	echo -e "可以使用連結的方式來連結到 /etc/ 底下："
	echo -e "ln -s /full/path/syslog.conf /etc/syslog.conf "
	echo -e "錯誤回報請到 http://linux.vbird.org 查看資訊！"
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
# 1. 建立歡迎畫面通知，以及系統的資料彙整！
echo "##########################################################"  > $logfile
echo "歡迎使用本程式來查驗您的登錄檔"                   >> $logfile
echo "本程式目前版本為： $versions"                     >> $logfile
echo "程式最後更新日期為： $lastdate"                   >> $logfile
echo "若在您的系統中發現本程式有問題, 歡迎與我聯絡！"   >> $logfile
echo "鳥哥的首頁 http://linux.vbird.org"                >> $logfile
echo "問題回報： http://phorum.vbird.org/viewtopic.php?t=3425"      >> $logfile
echo "##########################################################" >> $logfile
echo "  "                                               >> $logfile
echo "=============== 系統彙整 =================================" >> $logfile
echo "核心版本  : `cat /proc/version | \
	awk '{print $1 " " $2 " " $3 " " $4}'`" 	>> $logfile
echo "CPU 資訊  : `cat /proc/cpuinfo | \
	 grep "model name" |\
	 awk '{print $4 " " $5 " " $6}'`"		>> $logfile
cat /proc/cpuinfo | grep "cpu MHz" | \
	awk '{print "          : " $4 " MHz"}' 		>> $logfile
echo "主機名稱  : `hostname`" 				>> $logfile
echo "統計日期  : `date +%Y/%B/%d' '%H:%M:%S' '\(' '%A' '\)`" \
							>> $logfile
echo "分析的日期: `cat $basedir/dattime`"		>> $logfile
echo "已開機期間: `echo $UPtime`" 			>> $logfile
echo "目前主機掛載的 partitions"			>> $logfile
df -h	| sed 's/^/       /'				>> $logfile
echo " "						>> $logfile
echo " "						>> $logfile


# 1.1 Port 分析
if [ -f $basedir/function/ports ]; then
	source $basedir/function/ports
fi


##########################################################################################
# 2 開始測試需要進行的模組！
# 2.1 測試 ssh 是否存在？
input=`cat $basedir/netstat.tcp.output |egrep '(22|sshd)'`
if [ "$input" != "" ]; then
	source $basedir/function/ssh
	funcssh
	echo " "	>> $logfile
fi

# 2.2 測試 FTP 的玩意兒～
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

# 2.3 pop3 測試
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

# 2.4 Mail 測試
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

# 2.5 samba 測試
input=`cat $basedir/netstat.tcp.output  2> /dev/null |grep 139|grep smbd`
if [ "$input" != "" ]; then
	source $basedir/function/samba
	funcsamba
fi

#####################################################################
# 10. 全部的資訊列出給人瞧一瞧！
if [ "$outputall" == "yes" ] || [ "$outputall" == "YES" ] ; then
	echo "  "                                  				>> $logfile
	echo "================= 全部的登錄檔資訊彙整 ======================="	>> $logfile
	echo "1. 重要的登錄記錄檔 ( Secure file )"           >> $logfile
	echo "   說明：已經取消了 pop3 的資訊！"	     >> $logfile
	grep -v 'pop3' $basedir/securelog                    >> $logfile
	echo " "                                             >> $logfile
	echo "2. 使用 last 這個指令輸出的結果"               >> $logfile
	last -20                                             >> $logfile
	echo " "                                             >> $logfile
	echo "3. 將特重要的 /var/log/messages 列出來瞧瞧！"  >> $logfile
	echo "   已經取消 crond 與 snmpd 的訊息"	     >> $logfile
	cat $basedir/messageslog | egrep -vi '\bcrond\[' |\
		grep -vi 'crond(' |\
		grep -v 'snmpd.*UDP\:\ \[127.0.0.1\]'	     >> $logfile
fi

# At last! we send this mail to you!
if [ -x /usr/bin/uuencode ]; then
	uuencode $logfile logfile.txt | mail -s "$hosthome 的登錄檔分析結果" $email 
else
	mail -s "$hosthome 的登錄檔分析結果" $email < $logfile
fi
