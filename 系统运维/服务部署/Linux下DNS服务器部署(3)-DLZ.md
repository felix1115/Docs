# MySQL���ݿ�
## ��װMySQL
```
* ��װMySQL
[root@vm01 ~]# yum install -y mysql mysql-devel mysql-libs mysql-server

* ����MySQL
[root@vm01 ~]# /etc/init.d/mysqld start

* �޸�����
[root@vm01 ~]# mysqladmin -u root -h localhost password 'mysql'
[root@vm01 ~]# 

* ��½MySQL
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

* ɾ��test���ݿ�
mysql> drop database test;
Query OK, 0 rows affected (0.00 sec)

mysql> 

```

# mysql-bind
## ����mysql-bind
```
[root@vm01 ~]# https://sourceforge.net/projects/mysql-bind/files/mysql-bind/mysql-bind-0.2%20src/mysql-bind.tar.gz
```

## �鿴mysql-bind��REDME�ļ�
����REDME�ļ����ݽ����޸�bind9
```
[root@vm01 ~]# tar -zxf mysql-bind.tar.gz 
[root@vm01 ~]# cd mysql-bind
[root@vm01 mysql-bind]# less REDME
```

# ���밲װBIND����
## ����bind9
```
[root@vm01 ~]# wget ftp://ftp.isc.org/isc/bind9/9.10.3-P4/bind-9.10.4-P2.tar.gz
```

## ���밲װbind9
ע�⣺�޸ķ������Բο�mysql-bind��REDME�ļ�

* ����mysql-bind�µ�mysqldb.c��mysqldb.h��bind9/bin/named��bind9/bin/named/includeĿ¼
```
[root@vm01 ~]# tar -zxf bind-9.10.4-P2.tar.gz 
[root@vm01 ~]# cp mysql-bind/{mysqldb.c,mysqldb.h} bind-9.10.4-P2/bin/named/
[root@vm01 ~]# cp mysql-bind/{mysqldb.c,mysqldb.h} bind-9.10.4-P2/bin/named/include/
[root@vm01 ~]# 
```

* �޸�bind9/bin/named/Makefile.in
```
����1��
DBDRIVER_OBJS = mysqldb.@O@
DBDRIVER_SRCS = mysqldb.c


����2������mysql_config --cflags���õ��Ľ����ӵ�DBDRIVER_INCLUDES
[root@vm01 bind-9.10.4-P2]# mysql_config --cflags
-I/usr/include/mysql  -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -fno-strict-aliasing -fwrapv -fPIC   -DUNIV_LINUX -DUNIV_LINUX
[root@vm01 bind-9.10.4-P2]# 

������£�
DBDRIVER_INCLUDES = -I/usr/include/mysql  -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -fno-strict-    aliasing -fwrapv -fPIC   -DUNIV_LINUX -DUNIV_LINUX

����3������mysql_config --libs���õ��Ľ����ӵ�DBRIVER_LIBS
[root@vm01 bind-9.10.4-P2]# mysql_config --libs
-rdynamic -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -lssl -lcrypto
[root@vm01 bind-9.10.4-P2]# 

������£�
DBDRIVER_LIBS = -rdynamic -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -lssl -lcrypto
```

* �޸�bind9/bin/named/main.c
```
����1(�˲���mysql-bind�����Ĳ���ȷ)������#include <include/mysqldb.h>
#include <include/mysqldb.h>

��ȷ�������޸�bind9/bin/named�µ�mysqldb.c�ļ�
#include <include/mysqldb.h>
��named����include���ɡ�

����2����setup()������ns_server_create֮ǰ������mysqldb_init()
mysqldb_init();
ns_server_create(ns_g_mctx, &ns_g_server);

����3����cleanup()������ns_server_destroy֮������mysqldb_clear()
ns_server_destroy(&ns_g_server);
mysqldb_clear();

```

* ���밲װbind9
```
��װ�����������
[root@vm01 bind-9.10.4-P2]# yum install -y gcc gcc-c++ openssl openssl-devel openss-libs mysql mysql-devel
[root@vm01 bind-9.10.4-P2]# ./configure --prefix=/usr/local/source/bind9 --enable-epoll --enable-threads --disable-ipv6 
[root@vm01 bind-9.10.4-P2]# make
[root@vm01 bind-9.10.4-P2]# make install

```

# ����bind
## ����named�û�
```
[root@vm01 bind9]# useradd -M -d /usr/local/source/bind9/ -s /sbin/nologin -r named
[root@vm01 bind9]# grep named /etc/passwd
named:x:498:498::/usr/local/source/bind9/:/sbin/nologin
[root@vm01 bind9]# 
```

## ����rndc.conf�����ļ�
```
[root@vm01 bind9]# pwd
/usr/local/source/bind9
[root@vm01 bind9]# ./sbin/rndc-confgen > etc/rndc.conf
[root@vm01 bind9]#
```

## named.conf�����ļ�
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
˵����
database "mysqldb dlz lan_felix_com 172.17.100.3 dlz dlz";
mysqldb����ʾʹ��MySQL���ݿ�
dlz��Ϊ���ݿ����ơ�
lan_felix_com��Ϊ������ơ�
172.17.100.3:���ݿ�������ĵ�ַ��
dlz���û���
dlz������

## ����named.ca�ļ�(��Ҫ�������Է��ʻ�����)
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

## �޸�Ȩ��
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

# MySQL���ݿ�����
## ��������DLZ�����ݿ�
```
mysql> create database dlz;
Query OK, 1 row affected (0.00 sec)

mysql> grant all privileges on dlz.* to 'dlz'@'172.17.100.%' identified by 'dlz';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> 

```

## ������
```
mysql> use dlz;
Database changed
mysql> 

������£�

CREATE TABLE lan_felix_com (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=MyISAM;

˵������ṹ�ĸ����ֶα�����name��ttl��rdtype��rddata��TYPE������MyISAM��InnoDB���涼���ԡ�
```

## ������Դ��¼
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

# bind9�����ű�
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

ע��������named��mysqlλ��ͬһ̨�����ϣ���Ҫȷ��mysql��������named������������named�޷��������������ļ���������ʹ��/etc/init.d/named reload�������������ļ�Ҳ���ԡ�
```
vim /etc/init.d/mysqld

��Required-Start��Required-Stop�н�$namedȥ�����ɡ�
ԭʼ�ģ�
# Required-Start: $local_fs $remote_fs $network $named $syslog $time
# Required-Stop: $local_fs $remote_fs $network $named $syslog $time

�µģ�
 13 # Required-Start: $local_fs $remote_fs $network $syslog $time
 14 # Required-Stop: $local_fs $remote_fs $network $syslog $time


```


# ����ʾ��1���򵥵�DNS����
## named.conf����
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

## ���ݿ��
### localhost��
```
������
CREATE TABLE localhost (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;


�������ݣ�
INSERT INTO localhost VALUES ('localhost', 86400, 'SOA', 'localhost. admin.felix.com. 2016092001 28800 7200 86400 600');
INSERT INTO localhost VALUES ('localhost', 86400, 'NS', 'localhost.');
INSERT INTO localhost VALUES ('localhost', 86400, 'A', '127.0.0.1');

��ѯ���ݣ�
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

### loopback��
```
������
CREATE TABLE loopback (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;

�������ݣ�
INSERT INTO loopback VALUES ('0.0.127.in-addr.arpa', 86400, 'SOA', 'localhost. admin.felix.com. 2016092001 28800 7200 86400 600');
INSERT INTO loopback VALUES ('0.0.127.in-addr.arpa', 86400, 'NS', 'localhost.');
INSERT INTO loopback VALUES ('1.0.0.127.in-addr.arpa', 86400, 'PTR', 'localhost.');

��ѯ���ݣ�
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

### ��������
```
������
CREATE TABLE lan_felix_com (
  name varchar(255) default NULL,
  ttl int(11) default NULL,
  rdtype varchar(255) default NULL,
  rdata varchar(255) default NULL
) TYPE=InnoDB;


�������ݣ�
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

# ����ʾ��2��DNS������Ȩ
* ��DNS������
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

* ��DNS������
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

˵��: zone "felix.com"�е�forwarders�������ǽ����е��︸�������ת������DNS��������������DNS�������޷�����DNS�������еļ�¼��

```

* ����lan_felix_com
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

˵����
| tech.felix.com     |  600 | NS     | ns1.tech.felix.com.                                         |
| ns1.tech.felix.com |  600 | A      | 172.17.100.3                                                |
���������˶��������Ȩ

```

* �ӱ�lan_tech_felix_com
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

