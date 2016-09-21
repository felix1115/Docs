# VIEW(����DNS)
ͨ��ʹ��view�Ĺ��ܿ���ʵ������DNS����ν��view���ܣ����Ǹ����û�����Դ��ͬ���ز�ͬ�Ĳ�ѯ���������û��ǵ����û������Ҫ���ʵ���ҳΪwww.felix.com�Ļ����򷵻صĽ����1.1.1.1���������ͨ�û����򷵻صĽ����2.2.2.2�Ӷ�ʵ�ֿ��ٷ��ʵ�Ŀ�ġ�

ע�⣺
һ��������view�������е�����Ӧ��λ����view���档������ֻ��Ҫ��������Ҫִ�еݹ��view���档

����˵����
172.17.100.2����nfs.felix.com�ĵ�ַ��172.17.100.1
172.17.100.3����nfs.felix.com�ĵ�ַ��172.17.200.1

## named.conf����
```
# named config
# ACL Config
acl nets {
	172.17.100.0/24;
};

acl lan01 {
	172.17.100.2;
};

acl lan02 {
	172.17.100.3;
};

options {
	listen-on port 53 { 172.17.100.1; };
	directory "/usr/local/source/bind9/var/named";
	allow-query { any; };
	allow-recursion { nets; };
};

logging {
	channel test {
		#file "/var/log/named-test.log" versions 3 size 1M;
		null;
		severity info;
		print-time yes;
		print-severity yes;
		print-category yes;
	};
	category queries { test; };
};

# Start of rndc.conf
key "rndc-key" {
	algorithm hmac-md5;
	secret "mEVbpBDaleGmHrrn2GvNBg==";
};

controls {
	inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { rndc-key; };
};

view "test01" {
	match-clients { lan01; };
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
};

view "test02" {
	match-clients { lan02; };
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
		database "mysqldb dlz test_lan_felix_com 172.17.100.3 dlz dlz";
	};
};

```


## ���ݿ�����
* lan_felix_com
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

```

* test_lan_felix_com
```
mysql> select * from test_lan_felix_com;
+---------------+------+--------+-------------------------------------------------------------+
| name          | ttl  | rdtype | rdata                                                       |
+---------------+------+--------+-------------------------------------------------------------+
| felix.com     |  600 | SOA    | felix.com. admin.felix.com. 2016092001 28800 7200 86400 600 |
| felix.com     |  600 | NS     | ns1.felix.com.                                              |
| ns1.felix.com |  600 | A      | 172.17.100.1                                                |
| nfs.felix.com |  600 | A      | 172.17.200.1                                                |
+---------------+------+--------+-------------------------------------------------------------+
4 rows in set (0.00 sec)

mysql> 

```

## ����
```
[root@vm02 bin]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:89:FB:8D  
          inet addr:172.17.100.2  Bcast:172.17.100.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:617290 errors:0 dropped:0 overruns:0 frame:0
          TX packets:615295 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:131626700 (125.5 MiB)  TX bytes:68294688 (65.1 MiB)

[root@vm02 bin]# 

[root@vm02 bin]# dig -t a nfs.felix.com @172.17.100.1

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.17.rc1.el6_4.6 <<>> -t a nfs.felix.com @172.17.100.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 324
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 2

;; QUESTION SECTION:
;nfs.felix.com.			IN	A

;; ANSWER SECTION:
nfs.felix.com.		600	IN	A	172.17.100.1

;; AUTHORITY SECTION:
felix.com.		600	IN	NS	ns2.felix.com.
felix.com.		600	IN	NS	ns1.felix.com.

;; ADDITIONAL SECTION:
ns1.felix.com.		600	IN	A	172.17.100.1
ns2.felix.com.		600	IN	A	172.17.100.2

;; Query time: 7 msec
;; SERVER: 172.17.100.1#53(172.17.100.1)
;; WHEN: Wed Sep 21 16:02:34 2016
;; MSG SIZE  rcvd: 115

[root@vm02 bin]#

```

```
[root@vm3 ~]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:F8:6E:E6  
          inet addr:172.17.100.3  Bcast:172.17.100.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fef8:6ee6/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1132178 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1134885 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:128669201 (122.7 MiB)  TX bytes:259008382 (247.0 MiB)

[root@vm3 ~]# 


[root@vm3 ~]# dig -t a nfs.felix.com @172.17.100.1

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.17.rc1.el6_4.6 <<>> -t a nfs.felix.com @172.17.100.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19859
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;nfs.felix.com.			IN	A

;; ANSWER SECTION:
nfs.felix.com.		600	IN	A	172.17.200.1

;; AUTHORITY SECTION:
felix.com.		600	IN	NS	ns1.felix.com.

;; ADDITIONAL SECTION:
ns1.felix.com.		600	IN	A	172.17.100.1

;; Query time: 15 msec
;; SERVER: 172.17.100.1#53(172.17.100.1)
;; WHEN: Wed Sep 21 15:39:51 2016
;; MSG SIZE  rcvd: 81

[root@vm3 ~]# 

```