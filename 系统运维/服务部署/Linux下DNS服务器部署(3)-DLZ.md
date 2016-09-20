# MySQL数据库
## 安装MySQL
```
* 安装MySQL
[root@vm01 ~]# yum install -y mysql mysql-devel mysql-libs mysql-server

* 启动MySQL
[root@vm01 ~]# /etc/init.d/mysqld start

* 修改密码
[root@vm01 ~]# mysqladmin -u root -h localhost password 'mysql'
[root@vm01 ~]# 

* 登陆MySQL
[root@vm01 ~]# mysql -u root -h localhost -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.1.71 Source distribution

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> 

* 删除test数据库
mysql> drop database test;
Query OK, 0 rows affected (0.00 sec)

mysql> 

```

# mysql-bind
## 下载mysql-bind
```
[root@vm01 ~]# https://sourceforge.net/projects/mysql-bind/files/mysql-bind/mysql-bind-0.2%20src/mysql-bind.tar.gz
```

## 查看mysql-bind的REDME文件
根据REDME文件内容进行修改bind9
```
[root@vm01 ~]# tar -zxf mysql-bind.tar.gz 
[root@vm01 ~]# cd mysql-bind
[root@vm01 mysql-bind]# less REDME
```

# 编译安装BIND配置
## 下载bind9
```
[root@vm01 ~]# wget ftp://ftp.isc.org/isc/bind9/9.10.3-P4/bind-9.10.4-P2.tar.gz
```

## 编译安装bind9
注意：修改方法可以参考mysql-bind的REDME文件

* 复制mysql-bind下的mysqldb.c和mysqldb.h到bind9/bin/named和bind9/bin/named/include目录
```
[root@vm01 ~]# tar -zxf bind-9.10.4-P2.tar.gz 
[root@vm01 ~]# cp mysql-bind/{mysqldb.c,mysqldb.h} bind-9.10.4-P2/bin/named/
[root@vm01 ~]# cp mysql-bind/{mysqldb.c,mysqldb.h} bind-9.10.4-P2/bin/named/include/
[root@vm01 ~]# 
```

* 修改bind9/bin/named/Makefile.in
```
步骤1：
DBDRIVER_OBJS = mysqldb.@O@
DBDRIVER_SRCS = mysqldb.c


步骤2：运行mysql_config --cflags将得到的结果添加到DBDRIVER_INCLUDES
[root@vm01 bind-9.10.4-P2]# mysql_config --cflags
-I/usr/include/mysql  -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -fno-strict-aliasing -fwrapv -fPIC   -DUNIV_LINUX -DUNIV_LINUX
[root@vm01 bind-9.10.4-P2]# 

结果如下：
DBDRIVER_INCLUDES = -I/usr/include/mysql  -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -fno-strict-    aliasing -fwrapv -fPIC   -DUNIV_LINUX -DUNIV_LINUX

步骤3：运行mysql_config --libs将得到的结果添加到DBRIVER_LIBS
[root@vm01 bind-9.10.4-P2]# mysql_config --libs
-rdynamic -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -lssl -lcrypto
[root@vm01 bind-9.10.4-P2]# 

结果如下：
DBDRIVER_LIBS = -rdynamic -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -lssl -lcrypto
```

* 修改bind9/bin/named/main.c
```
步骤1(此步骤mysql-bind给出的不正确)：增加#include <include/mysqldb.h>
#include <include/mysqldb.h>

正确方法：修改bind9/bin/named下的mysqldb.c文件
#include <include/mysqldb.h>
将named换成include即可。

步骤2：在setup()函数的ns_server_create之前，增加mysqldb_init()
mysqldb_init();
ns_server_create(ns_g_mctx, &ns_g_server);

步骤3：在cleanup()函数的ns_server_destroy之后，增加mysqldb_clear()
ns_server_destroy(&ns_g_server);
mysqldb_clear();

```

* 编译安装bind9
```
安装依赖软件包：
[root@vm01 bind-9.10.4-P2]# yum install -y gcc gcc-c++ openssl openssl-devel openss-libs mysql mysql-devel
[root@vm01 bind-9.10.4-P2]# ./configure --prefix=/usr/local/source/bind9 --enable-epoll --enable-threads --disable-ipv6 
[root@vm01 bind-9.10.4-P2]# make
[root@vm01 bind-9.10.4-P2]# make install

```

# 配置bind
## 创建named用户
```
[root@vm01 bind9]# useradd -M -d /usr/local/source/bind9/ -s /sbin/nologin -r named
[root@vm01 bind9]# grep named /etc/passwd
named:x:498:498::/usr/local/source/bind9/:/sbin/nologin
[root@vm01 bind9]# 
```

## 产生rndc.conf配置文件
```
[root@vm01 bind9]# pwd
/usr/local/source/bind9
[root@vm01 bind9]# ./sbin/rndc-confgen > etc/rndc.conf
[root@vm01 bind9]#
```

## named.conf配置文件
```
# named config
options {
	listen-on port 53 { 172.17.100.3; };
	directory "/usr/local/source/bind9/var/named";
	pid-file "/var/run/named.pid";
	allow-query { any; };
	allow-recursion { 172.17.100.0/24; };
};


key "rndc-key" {
  algorithm hmac-md5;
  secret "jlQcTMjww402HHxtZWeUBw==";
};

controls {
  inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };
};


zone "." IN {
	type hint;
	file "named.ca";
};

zone "felix.com" {
	type master;
	notify no;
	database "mysqldb dlz lan_felix_com 172.17.100.3 dlz dlz";
};


```
说明：
database "mysqldb dlz lan_felix_com 172.17.100.3 dlz dlz";
mysqldb：表示使用MySQL数据库
dlz：为数据库名称。
lan_felix_com：为表的名称。
172.17.100.3:数据库服务器的地址。
dlz：用户名
dlz：密码

## 产生named.ca文件(需要机器可以访问互联网)
```
[root@vm01 bind9]# mkdir var/named
[root@vm01 bind9]# dig -t NS . > var/named/named.ca
[root@vm01 bind9]# cat etc/named.ca
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.23.rc1.el6_5.1 <<>> -t NS .
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33356
;; flags: qr rd ra; QUERY: 1, ANSWER: 13, AUTHORITY: 0, ADDITIONAL: 13

;; QUESTION SECTION:
;.				IN	NS

;; ANSWER SECTION:
.			334119	IN	NS	e.root-servers.net.
.			334119	IN	NS	l.root-servers.net.
.			334119	IN	NS	i.root-servers.net.
.			334119	IN	NS	m.root-servers.net.
.			334119	IN	NS	k.root-servers.net.
.			334119	IN	NS	a.root-servers.net.
.			334119	IN	NS	c.root-servers.net.
.			334119	IN	NS	f.root-servers.net.
.			334119	IN	NS	b.root-servers.net.
.			334119	IN	NS	h.root-servers.net.
.			334119	IN	NS	g.root-servers.net.
.			334119	IN	NS	d.root-servers.net.
.			334119	IN	NS	j.root-servers.net.

;; ADDITIONAL SECTION:
a.root-servers.net.	52864	IN	A	198.41.0.4
a.root-servers.net.	170519	IN	AAAA	2001:503:ba3e::2:30
b.root-servers.net.	303121	IN	A	192.228.79.201
b.root-servers.net.	84815	IN	AAAA	2001:500:84::b
c.root-servers.net.	432079	IN	A	192.33.4.12
c.root-servers.net.	186581	IN	AAAA	2001:500:2::c
d.root-servers.net.	339114	IN	A	199.7.91.13
d.root-servers.net.	84815	IN	AAAA	2001:500:2d::d
e.root-servers.net.	552413	IN	A	192.203.230.10
e.root-servers.net.	252703	IN	AAAA	2001:500:a8::e
f.root-servers.net.	170519	IN	A	192.5.5.241
f.root-servers.net.	170519	IN	AAAA	2001:500:2f::f
g.root-servers.net.	91263	IN	A	192.112.36.4

;; Query time: 1 msec
;; SERVER: 100.100.2.136#53(100.100.2.136)
;; WHEN: Mon Sep 19 16:14:07 2016
;; MSG SIZE  rcvd: 508


```

## 修改权限
```
[root@vm01 etc]# chmod 640 *
[root@vm01 etc]# chown :named *
[root@vm01 etc]# pwd
/usr/local/source/bind9/etc
[root@vm01 etc]# 

[root@vm01 bind9]# chown -R :named var/named
[root@vm01 bind9]# ls -ld var/named
drwxr-xr-x 2 root named 4096 Sep 19 16:26 var/named
[root@vm01 bind9]# 


```

# MySQL数据库配置
## 创建用于DLZ的数据库
```
mysql> create database dlz;
Query OK, 1 row affected (0.00 sec)

mysql> grant all privileges on dlz.* to 'dlz'@'172.17.100.%' identified by 'dlz';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> 

```

## 创建表
```
mysql> use dlz;
Database changed
mysql> 

语句如下：

CREATE TABLE lan_felix_com (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=MyISAM;

说明：表结构的各个字段必须是name，ttl，rdtype和rddata，TYPE可以用MyISAM和InnoDB引擎都可以。
```

## 创建资源记录
```
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'SOA', 'felix.com. admin.felix.com. 2016091901 28800 7200 86400 600');
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'NS', 'ns1.felix.com.');
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'NS', 'ns2.felix.com.');
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'MX', '10 mail.felix.com.');
INSERT INTO lan_felix_com VALUES ('ns1.felix.com', 600, 'A', '172.17.100.1');
INSERT INTO lan_felix_com VALUES ('ns2.felix.com', 600, 'A', '172.17.100.2');
INSERT INTO lan_felix_com VALUES ('mail.felix.com', 600, 'A', '172.17.100.10');
INSERT INTO lan_felix_com VALUES ('nfs.felix.com', 600, 'A', '172.17.100.1');
INSERT INTO lan_felix_com VALUES ('ftp.felix.com', 600, 'Cname', 'nfs.felix.com.');
```

# bind9启动脚本
```
#!/bin/bash
# chkconfig: - 80 20
### BEGIN INIT INFO
# Provides: $named
# Required-Start: $local_fs $network $syslog
# Required-Stop: $local_fs $network $syslog
# Default-Start: 345
# Default-Stop: 0 1 2 3 4 5 6
# Short-Description: start|stop|status|restart|configtest|reload DNS server
# Description: control ISC BIND implementation of DNS server
### END INIT INFO


# Source function library.
. /etc/rc.d/init.d/functions

PROGRAM=/usr/local/source/bind9
NAMED=$PROGRAM/sbin/named
PROG=named
CHECKCONFIG=$PROGRAM/sbin/named-checkconf
CONFIGFILE=$PROGRAM/etc/named.conf
LOCKFILE=/var/lock/subsys/named


start() {
	# check named is or not running
	if [ -f $LOCKFILE ]; then
		echo "$PROG is already running"
		exit 0
	fi

	# check config syntax 
	if [ -x $CHECKCONFIG ]; then
		$CHECKCONFIG $CONFIGFILE &> /dev/null
		RETVAL=$?
		if [ $RETVAL -ne 0 ]; then
			echo -n "Config file named.conf: "
			failure
			echo
			$CHECKCONFIG $CONFIGFILE
			exit 2
		fi
	else
		echo -n "No binary: $CHECKCONFIG"
		failure
		echo
		exit 3
	fi

	if [ -x $NAMED ]; then
		echo -n "Starting $PROG: "
		daemon $NAMED -c $CONFIGFILE
		RETVAL=$?
		echo
		[ $RETVAL -eq 0 ] && touch $LOCKFILE
		return $RETVAL
	
	else
		echo -n "No binary: $NAMED"
		failure
		echo
		exit 4
	fi
}


stop() {
	echo -n "Stopping $PROG: "
	killproc $PROG
	RETVAL=$?
	echo
	[ $RETVAL -eq 0 ] && rm -f $LOCKFILE
	return $RETVAL
}


reload() {
	echo -n "Reloading $PROG: "
	kill -SIGHUP $(pidof $PROG) &> /dev/null
	RETVAL=$?
	[ $RETVAL -eq 0 ] && success || failure 
	echo
	return $RETVAL
}

configtest() {
	# check config file is or not exist
	if [ ! -f $CONFIGFILE ]; then
		echo -n "No config file: $CONFIGFILE"
		failure
		echo
		exit 1
	fi

	# check config syntax 
	if [ -x $CHECKCONFIG ]; then
		$CHECKCONFIG $CONFIGFILE &> /dev/null
		RETVAL=$?
		if [ $RETVAL -ne 0 ]; then
			echo -n "Config file named.conf: "
			failure
			echo
			$CHECKCONFIG $CONFIGFILE
			exit 2
		else
			echo -n "Config file named.conf: "
			success
			echo
		fi
	else
		echo -n "No binary: $CHECKCONFIG"
		failure
		echo
		exit 3
	fi
}

usage() {
	echo "Usage: $(dirname $0)/named {start|stop|status|restart|reload|configtest}"
}

if [ $# -ne 1 ]; then
	usage
	exit 0
fi

case $1 in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	status)
		status $PROG
		;;
	configtest)
		configtest
		;;
	reload)
		reload
		;;
	*)
		usage
		;;
esac
```

注意事项：如果named和mysql位于同一台机器上，需要确保mysql先启动，named后启动，否则named无法载入区域数据文件。或者是使用/etc/init.d/named reload重新载入配置文件也可以。
```
vim /etc/init.d/mysqld

在Required-Start和Required-Stop中将$named去掉即可。
原始的：
# Required-Start: $local_fs $remote_fs $network $named $syslog $time
# Required-Stop: $local_fs $remote_fs $network $named $syslog $time

新的：
 13 # Required-Start: $local_fs $remote_fs $network $syslog $time
 14 # Required-Stop: $local_fs $remote_fs $network $syslog $time


```


# 配置示例1：简单的DNS配置
## named.conf配置
```
# named config
# ACL Config
acl nets {
	172.17.100.0/24;
};

options {
	listen-on port 53 { 172.17.100.1; };
	directory "/usr/local/source/bind9/var/named";
	allow-query { any; };
	allow-recursion { nets; };
};

# Start of rndc.conf
key "rndc-key" {
	algorithm hmac-md5;
	secret "mEVbpBDaleGmHrrn2GvNBg==";
};

controls {
	inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { rndc-key; };
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "localhost" IN {
	type master;
	notify no;
	database "mysqldb dlz localhost 172.17.100.3 dlz dlz";
};

zone "0.0.127.in-addr.arpa" {
	type master;
	notify no;
	database "mysqldb dlz loopback 172.17.100.3 dlz dlz";
};

zone "felix.com" {
	type master;
	notify no;
	database "mysqldb dlz lan_felix_com 172.17.100.3 dlz dlz";
};

```

## 数据库表
### localhost表
```
创建表：
CREATE TABLE localhost (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;


插入数据：
INSERT INTO localhost VALUES ('localhost', 86400, 'SOA', 'localhost. admin.felix.com. 2016092001 28800 7200 86400 600');
INSERT INTO localhost VALUES ('localhost', 86400, 'NS', 'localhost.');
INSERT INTO localhost VALUES ('localhost', 86400, 'A', '127.0.0.1');

查询数据：
mysql> select * from localhost;
+-----------+-------+--------+-------------------------------------------------------------+
| name      | ttl   | rdtype | rdata                                                       |
+-----------+-------+--------+-------------------------------------------------------------+
| localhost | 86400 | SOA    | localhost. admin.felix.com. 2016092001 28800 7200 86400 600 |
| localhost | 86400 | NS     | localhost.                                                  |
| localhost | 86400 | A      | 127.0.0.1                                                   |
+-----------+-------+--------+-------------------------------------------------------------+
3 rows in set (0.00 sec)

mysql> 

```

### loopback表
```
创建表：
CREATE TABLE loopback (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;

插入数据：
INSERT INTO loopback VALUES ('0.0.127.in-addr.arpa', 86400, 'SOA', 'localhost. admin.felix.com. 2016092001 28800 7200 86400 600');
INSERT INTO loopback VALUES ('0.0.127.in-addr.arpa', 86400, 'NS', 'localhost.');
INSERT INTO loopback VALUES ('1.0.0.127.in-addr.arpa', 86400, 'PTR', 'localhost.');

查询数据：
mysql> select * from loopback;
+------------------------+-------+--------+-------------------------------------------------------------+
| name                   | ttl   | rdtype | rdata                                                       |
+------------------------+-------+--------+-------------------------------------------------------------+
| 0.0.127.in-addr.arpa   | 86400 | SOA    | localhost. admin.felix.com. 2016092001 28800 7200 86400 600 |
| 0.0.127.in-addr.arpa   | 86400 | NS     | localhost.                                                  |
| 1.0.0.127.in-addr.arpa | 86400 | PTR    | localhost.                                                  |
+------------------------+-------+--------+-------------------------------------------------------------+
3 rows in set (0.00 sec)

mysql> 

```

### 常规区域
```
创建表：
CREATE TABLE lan_felix_com (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;


插入数据：
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'SOA', 'felix.com. admin.felix.com. 2016092001 28800 7200 86400 600');
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'NS', 'ns1.felix.com.');
INSERT INTO lan_felix_com VALUES ('felix.com', 600, 'NS', 'ns2.felix.com.');
INSERT INTO lan_felix_com VALUES ('ns1.felix.com', 600, 'A', '172.17.100.1');
INSERT INTO lan_felix_com VALUES ('ns2.felix.com', 600, 'A', '172.17.100.2');
INSERT INTO lan_felix_com VALUES ('nfs.felix.com', 600, 'A', '172.17.100.1');
INSERT INTO lan_felix_com VALUES ('ftp.felix.com', 600, 'A', '172.17.100.1');
INSERT INTO lan_felix_com VALUES ('yum.felix.com', 600, 'A', '172.17.100.250');
INSERT INTO lan_felix_com VALUES ('ntp.felix.com', 600, 'A', '172.17.100.151');

```

# 配置示例2：DNS子域授权
* 父DNS的配置
```
zone "." IN {
    type hint;
    file "named.ca";
};

zone "localhost" IN {
    type master;
    notify no; 
    database "mysqldb dlz localhost 172.17.100.3 dlz dlz";
};

zone "0.0.127.in-addr.arpa" {
    type master;
    notify no; 
    database "mysqldb dlz loopback 172.17.100.3 dlz dlz";
};

zone "felix.com" {
    type master;
    notify no; 
    database "mysqldb dlz lan_felix_com 172.17.100.3 dlz dlz";
};
```

* 子DNS的配置
```
zone "." IN {
	type hint;
	file "named.ca";
};

zone "localhost" {
	type master;
	notify no;
	database "mysqldb dlz localhost 172.17.100.3 dlz dlz";
};

zone "0.0.127.in-addr.arpa" {
	type master;
	notify no;
	database "mysqldb dlz localhost 172.17.100.3 dlz dlz";
};

zone "felix.com" IN {
	type forward;
	forwarders { 172.17.100.1; 172.17.100.2; };
};


zone "tech.felix.com" {
	type master;
	notify no;
	database "mysqldb dlz lan_tech_felix_com 172.17.100.3 dlz dlz";
};

说明: zone "felix.com"中的forwarders的作用是将所有到达父域的请求都转发到父DNS服务器，否则子DNS服务器无法请求父DNS服务器中的记录。

```

* 父表：lan_felix_com
```
mysql> select * from lan_felix_com;
+--------------------+------+--------+-------------------------------------------------------------+
| name               | ttl  | rdtype | rdata                                                       |
+--------------------+------+--------+-------------------------------------------------------------+
| felix.com          |  600 | SOA    | felix.com. admin.felix.com. 2016092001 28800 7200 86400 600 |
| felix.com          |  600 | NS     | ns1.felix.com.                                              |
| felix.com          |  600 | NS     | ns2.felix.com.                                              |
| ns1.felix.com      |  600 | A      | 172.17.100.1                                                |
| ns2.felix.com      |  600 | A      | 172.17.100.2                                                |
| nfs.felix.com      |  600 | A      | 172.17.100.1                                                |
| ftp.felix.com      |  600 | A      | 172.17.100.1                                                |
| yum.felix.com      |  600 | A      | 172.17.100.250                                              |
| ntp.felix.com      |  600 | A      | 172.17.100.151                                              |
| tech.felix.com     |  600 | NS     | ns1.tech.felix.com.                                         |
| ns1.tech.felix.com |  600 | A      | 172.17.100.3                                                |
+--------------------+------+--------+-------------------------------------------------------------+
11 rows in set (0.00 sec)

mysql> 

说明：
| tech.felix.com     |  600 | NS     | ns1.tech.felix.com.                                         |
| ns1.tech.felix.com |  600 | A      | 172.17.100.3                                                |
这里增加了对子域的授权

```

* 子表：lan_tech_felix_com
```
mysql> select * from lan_tech_felix_com;
+---------------------+------+--------+------------------------------------------------------------------+
| name                | ttl  | rdtype | rdata                                                            |
+---------------------+------+--------+------------------------------------------------------------------+
| tech.felix.com      |  600 | SOA    | tech.felix.com. admin.felix.com. 2016092001 28800 7200 86400 600 |
| tech.felix.com      |  600 | NS     | ns1.tech.felix.com.                                              |
| ns1.tech.felix.com  |  600 | A      | 172.17.100.3                                                     |
| www.tech.felix.com  |  600 | A      | 172.17.100.3                                                     |
| test.tech.felix.com |  600 | A      | 172.17.100.100                                                   |
+---------------------+------+--------+------------------------------------------------------------------+
5 rows in set (0.00 sec)

mysql> 

```

