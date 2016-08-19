# 定义环境变量和语言环境
```
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8
```

# 定义作者、脚本功能、日期、联系方式
```
# date： 2016-08-13
# author：felix.zhang
# email：felix.zhang@kakaocorp.com
# function：something to here
```

# 清屏和提示
```
清屏
clear

提示
printf "
###########################################
#                                         #
#   This block can put som tips in here   #
#                                         #
###########################################
"
```

# 定义颜色输出
```
CSI=$(echo -e "\033[")
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CQUESTION="$CMAGENTA"
CWARNING="$CYELLOW"
CMSG="$CCYAN"
CEND="${CSI}0m"


使用上述定义的颜色的方法：
[root@vm10 ~]# echo $CSUCCESS'Success'$CEND
Success
[root@vm10 ~]# echo $CMSG'Success'$CEND
Success
[root@vm10 ~]# echo $CWARNING'Success'$CEND
Success
[root@vm10 ~]# echo $CFAILURE'Success'$CEND
Success
[root@vm10 ~]# echo $CGREEN'Success'$CEND
Success
[root@vm10 ~]# echo $CDGREEN'Success'$CEND
Success
[root@vm10 ~]#
```

# 用户检测
```
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }
```

# 临时目录和锁文件
```
TMP1=/tmp/.tmp1
TMP2=/tmp/.tmp2
LOCKFILE=/tmp/.$(basename $0)
> ${TMP1}
> ${TMP2}
> ${LOCKFILE}
程序执行结束后要删除临时文件和锁文件：
rm -rf $LOCKfile $TMP1 $TMP2
```

# 函数定义和调用
```
定义函数：
function function-name() {
    statement
    ...
}

调用函数：function-name

```