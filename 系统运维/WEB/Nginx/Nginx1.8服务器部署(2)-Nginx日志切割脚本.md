# Nginx日志切割脚本
* 日志存储路径示例：/data/logs/nginx/2016/10/30/access_log-20161030.tar.bz2
```
#!/bin/bash
#description: backup access.log for nginx and execute the script in 01:00 everyday use crontal.
#show the crontal ,pls use crontab -l

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

BACKUPDIR="/data/logs/nginx"
ACCESS_LOG="access.log"
LOGDIR="/var/log/nginx"
PID="/var/run/nginx.pid"

if [ ! -f ${LOGDIR}/${ACCESS_LOG} ];then
    echo
    echo "Can not find the $ACCESS_LOG in $LOGDIR"
    echo
    exit 5
fi

if [ ! -f $PID ]; then
    echo
    echo "Nginx seems is not running! Quit"
    echo
    exit 6
fi

[ -d $BACKUPDIR ] || mkdir $BACKUPDIR

#backup access.log
Yesterday=$(date --date="yesterday" +'%Y%m%d')
YEAR=$(date --date="yesterday" +'%Y')
MONTH=$(date --date="yesterday" +'%m')

mkdir -p ${BACKUPDIR}/${YEAR}/${MONTH}
cd $LOGDIR

if [ ! -f ${BACKUPDIR}/${YEAR}/${MONTH}/access_log-${Yesterday}.tar.bz2 ];then
    tar --remove-files -cjvf ${BACKUPDIR}/${YEAR}/${MONTH}/access_log-$Yesterday.tar.bz2 $ACCESS_LOG &> /dev/null
else
    tar --remove-files -cjvf ${BACKUPDIR}/${YEAR}/${MONTH}/access_log-${Yesterday}-$(date +%H%M%S).tar.bz2 $ACCESS_LOG &> /dev/null
fi

kill -USR1 $(cat $PID)
```

* 日志存储路径示例：/data/logs/nginx/access_log-20161030.tar.bz2
```
#!/bin/bash
#description: backup access.log for nginx and execute the script in 01:00 everyday use crontal.
#show the crontal ,pls use crontab -l

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export PATH

BACKUPDIR="/data/logs/nginx"
ACCESS_LOG="access.log"
#LOGDIR="/var/log/nginx"
LOGDIR="/usr/local/source/nginx18/logs"
PID="/var/run/nginx.pid"

if [ ! -f ${LOGDIR}/${ACCESS_LOG} ];then
    echo
    echo "Can not find the $ACCESS_LOG in $LOGDIR"
    echo
    exit 5
fi

if [ ! -f $PID ]; then
    echo
    echo "Nginx seems is not running! Quit"
    echo
    exit 6
fi

[ -d $BACKUPDIR ] || mkdir $BACKUPDIR &> /dev/null

#backup access.log
Yesterday=$(date --date="yesterday" +'%Y%m%d')

cd $LOGDIR

if [ ! -f ${BACKUPDIR}/access_log-${Yesterday}.tar.bz2 ];then
    tar --remove-files -cjvf ${BACKUPDIR}/access_log-$Yesterday.tar.bz2 $ACCESS_LOG &> /dev/null
else
    tar --remove-files -cjvf ${BACKUPDIR}/access_log-${Yesterday}-$(date +%H%M%S).tar.bz2 $ACCESS_LOG &> /dev/null
fi

kill -USR1 $(cat $PID)
```

# 设置计划任务
```
设置计划任务：crontab -e

0   0   *   *   *    /usr/local/sbin/nginx_log.sh &
```