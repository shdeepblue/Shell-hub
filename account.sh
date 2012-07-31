#!/bin/bash
#
# �o��{���D�n�b���z�إߤj�q���b�����ΡA
# ��h���ϥΤ�k�аѦҡG
# http://linux.vbird.org/linux_basic/0410accountmanager.php#manual_amount
#
# ���{���������ۦ�}�o�A�b FC4 �W�ϥΨS�����D�A
# �����O�ҵ����|�o�Ϳ��~�I�ϥήɡA�Цۦ�t�᭷�I��
#
# History:
# 2005/09/05    VBird   ���~�g���A�ϥάݬݥ���
PATH=/sbin:/usr/sbin:/bin:/usr/bin; export PATH
accountfile="user.passwd"

# 1. �i��b����������J���I
read -p "�b���}�Y�N�X ( Input title name, ex> std )======> " username_start
read -p "�b���h�ũΦ~�� ( Input degree, ex> 1 or enter )=> " username_degree
read -p "�_�l���X ( Input start number, ex> 520 )========> " nu_start
read -p "�b���ƶq ( Input amount of users, ex> 100 )=====> " nu_amount
read -p "�K�X�з� 1) �P�b���ۦP 2)�üƦۭq ==============> " pwm
if [ "$username_start" == "" ]; then
        echo "�S����J�}�Y���N�X�A�����A������I" ; exit 1
fi
testing1=`echo $nu_amount | grep '[^0-9]' `
testing2=`echo $nu_start  | grep '[^0-9]' `
if [ "$testing1" != "" ] || [ "$testing2" != "" ]; then
        echo "��J�����X����աI���D���Ʀr�����e�I" ; exit 1
fi
if [ "$pwm" != "1" ]; then
        pwm="2"
fi

# 2. �}�l��X�b���P�K�X�ɮסI
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

# 3. �}�l�إ߱b���P�K�X�I
        cat "$accountfile" | cut -d':' -f1 | xargs -n 1 useradd -m
        chpasswd < "$accountfile"
        pwconv
	echo "OK�I�إߧ����I"
