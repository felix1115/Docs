# Keepalived的介绍
* LVS的缺点
```
1. Director的单点。只有一台Director，如果Director出现故障，无法提供服务。
2. Direct将所有的请求根据所指定的算法发送到后端服务器，如果后端服务器出现异常，则客户端的访问出现问题。Director无法提供对后端服务器的健康状态检查。
```

* keepalived的体系结构

![keepalived的体系结构](https://github.com/felix1115/Docs/blob/master/Images/keepalived体系结构.png)

```
Keepalived大致分为两层空间：user space和kernel space。

watchdog：负责监控checkers和VRRP Stack进程的状况。
checkers：负责真实服务器的健康检查（health checking），是keepalived最主要的功能。换句话说，可以没有VRRP Stack，但是不能没有Checkers。
VRRP Stack：负责负载均衡器之间的失败切换FailOver，如果只有一个负载均衡器，则VRRP Stack不是必须的。
IPVS Wrappers：用来发送设定的规则（通过ipvsadm设置的规则）到内核ipvs的代码。
Netlink Reflector：用来设定VRRP的VIP等。
```

# Keepalived的安装
* RPM包安装
```
[root@vm05 ~]# yum install -y keepalived
```

* 源码安装
```
[root@vm05 ~]# yum install -y openssl-devel
[root@vm05 ~]# tar -zxf keepalived-1.3.2.tar.gz
[root@vm05 ~]# cd keepalived-1.3.2
[root@vm05 keepalived-1.3.2]# ./configure
[root@vm05 keepalived-1.3.2]# make
[root@vm05 keepalived-1.3.2]# make install
```

* 为配置文件创建符号链接
```
[root@vm05 keepalived-1.3.2]# ln -s /usr/local/sbin/keepalived /usr/sbin/
[root@vm05 keepalived-1.3.2]# ln -s /usr/local/etc/keepalived /etc/
[root@vm05 keepalived-1.3.2]# ln -s /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
[root@vm05 keepalived-1.3.2]#
```


* keepalived启动脚本
```
#!/bin/sh
#
# keepalived   High Availability monitor built upon LVS and VRRP
#
# chkconfig:   - 86 14
# description: Robust keepalive facility to the Linux Virtual Server project \
#              with multilayer TCP/IP stack checks.

### BEGIN INIT INFO
# Provides: keepalived
# Required-Start: $local_fs $network $named $syslog
# Required-Stop: $local_fs $network $named $syslog
# Should-Start: smtpdaemon httpd
# Should-Stop: smtpdaemon httpd
# Default-Start:
# Default-Stop: 0 1 2 3 4 5 6
# Short-Description: High Availability monitor built upon LVS and VRRP
# Description:       Robust keepalive facility to the Linux Virtual Server
#                    project with multilayer TCP/IP stack checks.
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

exec="/usr/sbin/keepalived"
prog="keepalived"
config="/etc/keepalived/keepalived.conf"

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/keepalived

start() {
    [ -x $exec ] || exit 5
    [ -e $config ] || exit 6
    echo -n $"Starting $prog: "
    daemon $exec $KEEPALIVED_OPTIONS
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    echo -n $"Reloading $prog: "
    killproc $prog -1
    retval=$?
    echo
    return $retval
}

force_reload() {
    restart
}

rh_status() {
    status $prog
}

rh_status_q() {
    rh_status &>/dev/null
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
```