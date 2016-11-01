# 安装TCMalloc
* TCMalloc介绍
注意：如果是先安装的Nginx，后安装的TCMalloc的话，则需要重新编译Nginx

TCMalloc(Thread-Caching Malloc)与标准glibc库的malloc实现一样的功能，但是TCMalloc在效率和速度效率都比标准malloc高很多。TCMalloc是google-perftools工具中的一个（gperftools四个工具分别是：TCMalloc、heap-checker、heap-profiler和cpu-profiler），这个工具是开源的，以源码形式发布。如果觉得自己维护一个内存分配器麻烦的话，可以考虑将TCMalloc静态库连接到你的程序中。使用的时候和glibc中的malloc调用方式一模一样。你需要做的只是把TCMalloc的动态库或者静态库连接进你的程序中，你就可以获得一个高效，快速，安全的内存分配器。


* 安装TCMalloc
```
1. 安装libunwind(64位的操作系统需要安装)
[root@vm3 nginx]# tar -zxf libunwind-1.1.tar.gz 
[root@vm3 nginx]# cd libunwind-1.1
[root@vm3 libunwind-1.1]# ./configure 
[root@vm3 libunwind-1.1]# make CFLAGS=-fPIC
[root@vm3 libunwind-1.1]# make CFLAGS=-fPIC install

2. 安装TCMalloc
[root@vm3 nginx]# tar -zxf gperftools-2.1.tar.gz 
[root@vm3 nginx]# cd gperftools-2.1
[root@vm3 gperftools-2.1]# ./configure
[root@vm3 gperftools-2.1]# make
[root@vm3 gperftools-2.1]# make install

3. 执行ldconfig
方法1：修改/etc/ld.so.conf文件，增加/usr/local/lib，然后执行ldconfig
[root@vm3 opt]# cat /etc/ld.so.conf
include ld.so.conf.d/*.conf
/usr/local/lib
[root@vm3 opt]# 
[root@vm3 opt]# ldconfig

方法2：在/etc/ld.so.conf.d目录下创建一个以.conf结尾的文件，写入/usr/local/lib，并执行ldconfig
[root@vm3 opt]# echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
[root@vm3 opt]# ldconfig

备注说明：
32位系统，不需要安装libunwind，但是一定要添加--enable-frame-pointers参数，如下：
./configure --enable-frame-pointers 

4. 重新编译nginx(如果是先安装Nginx，后安装TCMalloc的话，需要执行这一步)


5. 创建线程目录
[root@vm3 nginx]# mkdir /usr/local/source/nginx18/tcmalloc
[root@vm3 nginx]# chown www:www tcmalloc
[root@vm3 nginx]# chmod 770 tcmalloc/

#修改Nginx的配置文件，并添加google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;
[root@vm3 ~]# vim /usr/local/source/nginx18/conf/nginx.conf 
#pid下一行添加
google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;

6. 测试
[root@vm3 tcmalloc]# pwd
/usr/local/source/nginx18/tcmalloc
[root@vm3 tcmalloc]# ls -l
total 0
-rw-rw-rw- 1 www www 0 Oct 31 11:23 tcmalloc.34551
[root@vm3 tcmalloc]# 

```

# 编译安装Nginx
* 创建运行Nginx的用户和组
```
[root@vm3 nginx]# groupadd -r www
[root@vm3 nginx]# useradd -r -g www -s /sbin/nologin www
[root@vm3 nginx]# 
```

* 安装依赖软件
```
[root@vm3 ~]# yum install -y pcre pcre-devel openssl openssl-devel zlib zlib-devel
```

* 编译安装Nginx
```
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-google_perftools_module
[root@vm3 nginx-1.8.1]# make
[root@vm3 nginx-1.8.1]# make install
```

# nginx指令说明
```
-v：查看版本号
-V：查看编译信息。
-t：检查配置文件的语法。
-p：设置nginx的prefix路径信息。
-c：指定nginx的配置文件。
-s：发送信号到nginx的master进程。可用的信号有：stop、quit、reload、reopen
```

* 信号说明
```
发送信号到Nginx的master进程的方法：kill -s <signal> <master-process-id>

TERM：快速停止Nginx。等同于kill -15
QUIT：graceful停止。等同于kill -3
HUP：reload。重新载入配置文件。当Nginx配置修改后，可以用该选项使用新的配置文件启动新的worker进程，并平滑关闭老的worker进程。master进程不会退出。等同于kill -1
USR1：重新打开日志文件，日志文件切割时使用。
USR2：平滑升级可执行程序。
WINCH：graceful shutdown worker process。
```

# Nginx的启停脚本
```
#!/bin/bash
# chkconfig: 2345 85 15
# description: start nginx on level 2345

. /etc/rc.d/init.d/functions

prefix="/usr/local/source/nginx18"
exec="$prefix/sbin/nginx"
config="$prefix/conf/nginx.conf"
lockfile="/var/lock/subsys/nginx"
prog="nginx"

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
    echo -n "Stoping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
	return $retval
}

restart() {
	configtest_quiet || configtest || return $?
	stop
	sleep 1
	start
}

graceful-restart() {
    #graceful restart program
    echo -n "graceful restart $prog: "
    killproc $prog -HUP
    retval=$?
    echo
}

reload() {
    #reload config file
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
    graceful-restart)
        $1
        ;;
    configtest)
		echo -n "Check config: $config "
		configtest_quiet
		retval=$?
		if [ $retval -eq 0 ]; then
			success
		else
			failure
			configtest
		fi
		echo	
        ;;
    reload)
        $1
        ;;
    *)
        echo "Usage: $0 start|stop|restart|status|configtest|graceful-restart|reload"
esac
```