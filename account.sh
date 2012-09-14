#!/bin/bash
#
# 這支程式主要在幫您建立大量的帳號之用，
# 更多的使用方法請參考：
# http://linux.vbird.org/linux_basic/0410accountmanager.php#manual_amount
#
# 本程式為鳥哥自行開發，在 FC4 上使用沒有問題，
# 但不保證絕不會發生錯誤！使用時，請自行負擔風險～
#
# History:
# 2005/09/05    VBird   剛剛才寫完，使用看看先～
PATH=/sbin:/usr/sbin:/bin:/usr/bin; export PATH
accountfile="user.passwd"

# 1. 進行帳號相關的輸入先！
read -p "帳號開頭代碼 ( Input title name, ex> std )======> " username_start
read -p "帳號層級或年級 ( Input degree, ex> 1 or enter )=> " username_degree
read -p "起始號碼 ( Input start number, ex> 520 )========> " nu_start
read -p "帳號數量 ( Input amount of users, ex> 100 )=====> " nu_amount
read -p "密碼標準 1) 與帳號相同 2)亂數自訂 ==============> " pwm
if [ "$username_start" == "" ]; then
        echo "沒有輸入開頭的代碼，不給你執行哩！" ; exit 1
fi
testing1=`echo $nu_amount | grep '[^0-9]' `
testing2=`echo $nu_start  | grep '[^0-9]' `
if [ "$testing1" != "" ] || [ "$testing2" != "" ]; then
        echo "輸入的號碼不對啦！有非為數字的內容！" ; exit 1
fi
if [ "$pwm" != "1" ]; then
        pwm="2"
fi

# 2. 開始輸出帳號與密碼檔案！
[ -f "$accountfile" ] && mv $accountfile "$accountfile"`date +%Y%m%d`
nu_end=$(($nu_start+$nu_amount-1))
for (( i=$nu_start; i<=$nu_end; i++ ))
do
        account=$username_start$username_degree$i
        if [ "$pwm" == "1" ]; then
                password="$account"
        else
                password=""
                test_nu=0
                until [ "$test_nu" == "8" ]
                do
                        temp_nu=$(($RANDOM*50/32767+30))
                        until [ "$temp_nu" != "60" ]
                        do
                                temp_nu=$(($RANDOM*50/32767+30))
                        done
                        test_nu=$(($test_nu+1))
                        temp_ch=`printf "\x$temp_nu"`
                        password=$password$temp_ch
                done
        fi
        echo "$account":"$password" | tee -a "$accountfile"
done

# 3. 開始建立帳號與密碼！
        cat "$accountfile" | cut -d':' -f1 | xargs -n 1 useradd -m
        chpasswd < "$accountfile"
        pwconv
	echo "OK！建立完成！"
