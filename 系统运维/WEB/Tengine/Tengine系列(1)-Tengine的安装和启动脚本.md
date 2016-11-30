# Tengine的安装

[Tengine官网](http://tengine.taobao.org/)

* 创建运行tengine的用户和组
```
[root@vm3 ~]# useradd -r -g www -s /sbin/nologin www
[root@vm3 ~]# 
```

* 编译安装Tengine
```
说明：Tengine的编译安装和Nginx一致。

[root@vm03 opt]# tar -zxf tengine-2.1.2.tar.gz
[root@vm03 opt]# cd tengine-2.1.2
[root@vm03 tengine-2.1.2]# ./configure --prefix=/usr/local/source/tengine --with-google_perftools_module
[root@vm03 tengine-2.1.2]# make
[root@vm03 tengine-2.1.2]# make install
```

* 命令行参数
```
Usage: nginx [-?hvmVtdq] [-s signal] [-c filename] [-p prefix] [-g directives]

说明：
-?，-h：显示帮助
-v：查看版本并退出。
-m：查看所有模块并退出。
-l：列出所有的指令并退出。
-V：查看版本、模块和configure选项并退出。
-t：检查配置文件并退出。
-d：输出配置文件的内容，包括include的内容，并退出。
-q：在测试配置文件期间，只显示错误信息。
-s：发送指定的信号到master进程。如stop、quit、reload、reopen
-p：设置prefix路径。
-c：指定tengine的配置文件。

tengine从1.4以后，支持动态模块，使用tengine -m选项，可以列出模块是动态的还是静态的。
static：表示静态编译。
shared：表示动态编译。
```

# Tengine的启动脚本
* 说明
```
1. Tengine的启动脚本和Nginx的完全通用，只需要修改一下prefix即可。
2. 如果使用TCMalloc的话，则需要做如下设置：
    [root@vm03 tengine]# mkdir /usr/local/source/tengine/tcmalloc
    [root@vm03 tengine]# chown www:www /usr/local/source/tengine/tcmalloc
    [root@vm03 tengine]# chmod 770 /usr/local/source/tengine/tcmalloc
    [root@vm03 tengine]#
```

```
#!/bin/bash
# chkconfig: 2345 85 15
# description: start nginx on level 2345

. /etc/rc.d/init.d/functions

prefix="/usr/local/source/tengine"
exec="$prefix/sbin/nginx"
config="$prefix/conf/nginx.conf"
lockfile="/var/lock/subsys/nginx"
prog="nginx"
# if nginx use tcmalloc, please set it to yes, otherwise set it to no
tcmalloc="yes"
tcmallow_path="$prefix/tcmalloc"

getNginxMaster() {
    number=$(ps aux | grep 'nginx: master' | grep -v 'grep' | wc -l)
    return $number
}

start() {
    [ -x $exec ] || exit 5
    [ -f $config ] || exit 6
    #start program
    echo -n "Starting $prog: "
    daemon $exec -c $config
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    # stop program
    echo -n "Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    if [ $tcmalloc == 'yes' ]; then
        rm -f $tcmallow_path/*
    fi
    return $retval
}

restart() {
    configtest_quiet || configtest || return $?
    stop
    sleep 1

    while :
    do
        getNginxMaster
        retval=$?
        if [ $retval -eq 1 ]; then
            echo  -n "Waiting for shutdown $prog"
            echo
            sleep 2
        else
            break
        fi
    done

    start
}

graceful-restart() {
    #graceful restart program
    configtest_quiet || configtest || return $?
    echo -n "graceful restart $prog: "
    killproc $prog -HUP
    retval=$?
    echo
}

reload() {
    #reload config file
    configtest_quiet || configtest || return $?
    echo -n "Reload config $config: "
    killproc $prog -HUP
    retval=$?
    echo
}

configtest() {
    $exec -t -c $config
}

configtest_quiet() {
    configtest &> /dev/null
}



case $1 in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    status)
        status $prog
        ;;
    reload|graceful-restart)
        $1
        ;;
    configtest)
        configtest_quiet
        retval=$?
        if [ $retval -eq 0 ]; then
            echo -n "Check config: $config "
            success
        else
            configtest
        fi
        echo
        ;;
    *)
        echo "Usage: $0 start|stop|restart|status|configtest|graceful-restart|reload"
esac
```