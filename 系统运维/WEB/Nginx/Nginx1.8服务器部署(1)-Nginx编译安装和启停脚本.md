# ��װTCMalloc
* TCMalloc����
ע�⣺������Ȱ�װ��Nginx����װ��TCMalloc�Ļ�������Ҫ���±���Nginx

TCMalloc(Thread-Caching Malloc)���׼glibc���mallocʵ��һ���Ĺ��ܣ�����TCMalloc��Ч�ʺ��ٶ�Ч�ʶ��ȱ�׼malloc�ߺܶࡣTCMalloc��google-perftools�����е�һ����gperftools�ĸ����߷ֱ��ǣ�TCMalloc��heap-checker��heap-profiler��cpu-profiler������������ǿ�Դ�ģ���Դ����ʽ��������������Լ�ά��һ���ڴ�������鷳�Ļ������Կ��ǽ�TCMalloc��̬�����ӵ���ĳ����С�ʹ�õ�ʱ���glibc�е�malloc���÷�ʽһģһ��������Ҫ����ֻ�ǰ�TCMalloc�Ķ�̬����߾�̬�����ӽ���ĳ����У���Ϳ��Ի��һ����Ч�����٣���ȫ���ڴ��������


* ��װTCMalloc
```
1. ��װlibunwind(64λ�Ĳ���ϵͳ��Ҫ��װ)
[root@vm3 nginx]# tar -zxf libunwind-1.1.tar.gz 
[root@vm3 nginx]# cd libunwind-1.1
[root@vm3 libunwind-1.1]# ./configure 
[root@vm3 libunwind-1.1]# make CFLAGS=-fPIC
[root@vm3 libunwind-1.1]# make CFLAGS=-fPIC install

2. ��װTCMalloc
[root@vm3 nginx]# tar -zxf gperftools-2.1.tar.gz 
[root@vm3 nginx]# cd gperftools-2.1
[root@vm3 gperftools-2.1]# ./configure
[root@vm3 gperftools-2.1]# make
[root@vm3 gperftools-2.1]# make install

3. ִ��ldconfig
����1���޸�/etc/ld.so.conf�ļ�������/usr/local/lib��Ȼ��ִ��ldconfig
[root@vm3 opt]# cat /etc/ld.so.conf
include ld.so.conf.d/*.conf
/usr/local/lib
[root@vm3 opt]# 
[root@vm3 opt]# ldconfig

����2����/etc/ld.so.conf.dĿ¼�´���һ����.conf��β���ļ���д��/usr/local/lib����ִ��ldconfig
[root@vm3 opt]# echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
[root@vm3 opt]# ldconfig

��ע˵����
32λϵͳ������Ҫ��װlibunwind������һ��Ҫ���--enable-frame-pointers���������£�
./configure --enable-frame-pointers 

4. ���±���nginx(������Ȱ�װNginx����װTCMalloc�Ļ�����Ҫִ����һ��)


5. �����߳�Ŀ¼
[root@vm3 nginx]# mkdir /usr/local/source/nginx18/tcmalloc
[root@vm3 nginx]# chown www:www tcmalloc
[root@vm3 nginx]# chmod 770 tcmalloc/

#�޸�Nginx�������ļ��������google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;
[root@vm3 ~]# vim /usr/local/source/nginx18/conf/nginx.conf 
#pid��һ�����
google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;

6. ����
[root@vm3 tcmalloc]# pwd
/usr/local/source/nginx18/tcmalloc
[root@vm3 tcmalloc]# ls -l
total 0
-rw-rw-rw- 1 www www 0 Oct 31 11:23 tcmalloc.34551
[root@vm3 tcmalloc]# 

```

# ���밲װNginx
* ��������Nginx���û�����
```
[root@vm3 nginx]# groupadd -r www
[root@vm3 nginx]# useradd -r -g www -s /sbin/nologin www
[root@vm3 nginx]# 
```

* ��װ�������
```
[root@vm3 ~]# yum install -y pcre pcre-devel openssl openssl-devel zlib zlib-devel
```

* ���밲װNginx
```
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-google_perftools_module
[root@vm3 nginx-1.8.1]# make
[root@vm3 nginx-1.8.1]# make install
```

# nginxָ��˵��
```
-v���鿴�汾��
-V���鿴������Ϣ��
-t����������ļ����﷨��
-p������nginx��prefix·����Ϣ��
-c��ָ��nginx�������ļ���
-s�������źŵ�nginx��master���̡����õ��ź��У�stop��quit��reload��reopen
```

* �ź�˵��
```
�����źŵ�Nginx��master���̵ķ�����kill -s <signal> <master-process-id>

TERM������ֹͣNginx����ͬ��kill -15
QUIT��gracefulֹͣ����ͬ��kill -3
HUP��reload���������������ļ�����Nginx�����޸ĺ󣬿����ø�ѡ��ʹ���µ������ļ������µ�worker���̣���ƽ���ر��ϵ�worker���̡�master���̲����˳�����ͬ��kill -1
USR1�����´���־�ļ�����־�ļ��и�ʱʹ�á�
USR2��ƽ��������ִ�г���
WINCH��graceful shutdown worker process��
```

# Nginx����ͣ�ű�
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