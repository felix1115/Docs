#!/bin/bash

# 当用户在FAIL_TIME时间内登录失败超过MAX_FAIL_COUNT时，用户会加入到黑名单里(秒) 
FAIL_TIME=60
# 当用户失败次数大于MAX_FAIL_COUNT时，用户被锁定的时间(秒)
LOCK_TIME=60
# 用户登录失败次数
MAX_FAIL_COUNT=9

# 检测时间间隔，单位为秒
MONITOR_INTVAL=5

CURRENTDIR=$(dirname $0) 
DENY_FILE='/etc/hosts.deny'
SECURE_FILE='/var/log/secure'
LOGIN_TIME_FILE1=$CURRENTDIR/login_time1.txt
LOGIN_TIME_FILE2=$CURRENTDIR/login_time2.txt
LOGIN_COUNT_FILE=$CURRENTDIR/login_count.txt
LOCK_TIME_FILE=$CURRENTDIR/lock.txt

function check_ssh_login() {
    # 判断secure和hosts.deny文件是否存在
    if [ ! -f $SECURE_FILE ]; then
        echo -e '\033[31m=============================================\033[m'
        echo -e "\033[31m Can not find secure file [$SECURE_FILE]\033[m"
        echo -e '\033[31m=============================================\033[m'
        exit 5
    elif [ ! -f $DENY_FILE ]; then
        echo -e '\033[31m=================================================\033[m'
        echo -e "\033[31m Can not find black list file [$DENY_FILE]\033[m"
        echo -e '\033[31m=================================================\033[m'
        exit 5
    fi
    
    # 统计用户登录失败的时间和用户IP地址
    cat $SECURE_FILE | awk '/Failed/ {print $1,$2,$3,$(NF-3)}' > $LOGIN_TIME_FILE1

    # 统计用户IP地址失败的次数
    cat $LOGIN_TIME_FILE1 | awk '{++ip[$NF]} END {for (i in ip) print i"="ip[i]}' > $LOGIN_COUNT_FILE
    
    # 清空文件内容
    > $LOGIN_TIME_FILE2
    
    # 读取时间格式1文件里面的内容，并传递给item变量
    cat $LOGIN_TIME_FILE1 | while read item
    do
        # 用户登录时间
        loginTime1=$(echo $item | awk '{print $1,$2,$3}')
        # 用户IP地址
        ip=$(echo $item | awk '{print $NF}')
        # 用户登录时间格式2以及登录的时间戳
        loginTime2=$(date -d "$loginTime1" +'%Y-%m-%d %H:%M:%S')
        timestamp=$(date -d "$loginTime1" +%s)
    
        echo "$loginTime2 $timestamp $ip" >> $LOGIN_TIME_FILE2
    done
    
    # 检测用户在指定时间内登录失败的次数，以及加入黑名单功能
    for item in $(cat $LOGIN_COUNT_FILE)
    do
        loginFailCount=0
        ip=$(echo $item | awk -F'=' '{print $1}')
        currentTimestamp=$(date +%s)
        let minTimestamp=$currentTimestamp-$FAIL_TIME
    
        times=$(cat $LOGIN_TIME_FILE2 | grep "\<$ip\>" | awk '{print $(NF-1)}')
    
        for time in $(echo $times)
        do
            if [ $time -ge $minTimestamp -a $time -le $currentTimestamp ];then
                let loginFailCount+=1
            fi
        done
        
        # 加入黑名单或解除黑名单
        if [ $loginFailCount -ge $MAX_FAIL_COUNT ]; then
            # 检测用户是否已经加入到黑名单里面
            grep "\<$ip\>" $DENY_FILE &> /dev/null
            RETVAL=$?
            if [  $RETVAL -ne 0 ]; then
                echo "sshd: $ip" >> $DENY_FILE
                let unlockTimestamp=$currentTimestamp+$LOCK_TIME
                echo "$unlockTimestamp $ip" >> $LOCK_TIME_FILE
            fi

        else
            # 判断用户是否需要解除黑名单限制
            if [ -s $LOCK_TIME_FILE ]; then
                unlockTime=$(cat $LOCK_TIME_FILE | grep "\<$ip\>" | awk '{print $1}')
                if [ $currentTimestamp -ge $unlockTime ]; then
                    sed -i "/\<$ip\>/d" $DENY_FILE
                    sed -i "/\<$ip\>/d" $LOCK_TIME_FILE
                fi
            fi
        fi

    done
}

# 可以用nohup将该程序放在后台持续监测
while :
do
    check_ssh_login
    sleep $MONITOR_INTVAL
done
