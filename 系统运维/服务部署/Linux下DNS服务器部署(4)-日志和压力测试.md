# bind logging

```
语法格式：

logging {
    channel string {
        file log_file;
        syslog optional_facility;
        null;
        stderr;
        severity log_severity;
        print-time boolean;
        print-severity boolean;
        print-category boolean;
    };
    category string { string; ... };
};

```

* bind日志术语
```
channel：通道。日志输出方式，如file、syslog、stderr、null。
category：类别。日志的消息类别。如，查询消息、动态更新消息等。
module：模块。产生消息的来源模块名称。
facility：设备。syslog的设备名。
severity：严重性。消息的严重等级。
```

* channel
```
channel用于定义日志输出的位置。
	null：表示送往该通道的日志都丢弃。
	stderr：表示送往该通道的日志都发送到标准错误输出。
	file：表示送往该通道的日志都发送到指定的文件。在file中可以指定versions(保留多少个备份文件。如file.log0,file.log1,file.log2等)，size(指定log文件的大小，则表示单个日志文件的大小。)。如果定义了size，则没有定义versions，则当日志超过size时，服务器将停止写入该文件。
	syslog：日志输出到syslog(可以是系统日志或者是syslog服务器)中。
```

* severity
```
用于指定消息的严重级别。

从高到低如下：
critical
error
warning
notice
info
debug [level]
dynamic：是一个特殊的值，它匹配了服务器当前的debug级别。

定义某个级别后，系统会记录包括该级别以及该级别以上的所有消息。
```

* category
```
category用于定义哪一种bind的消息使用那个或者哪几个通道输出。

bind的category如下：
client：处理客户端的请求。
config：配置文件分析和处理。
database：同bind内部数据库相关的信息，用来存储zone和缓存记录。
default：匹配所有未明确指定通道的类别。
dnssec：处理DNSSEC签名的响应。
general：包括所有未明确分类的BIND消息。
lame-servers：发现错误授权，及残缺服务器。
network：网络操作。
notify：区域更新通知消息。
queries：查询日志。
resolver：名字解析，包括对来自解析器的递归查询信息。
security：批准或非批准的请求。
update：动态更新信息。
xfer-in：从远程DNS服务器到本地DNS服务器的区域传输。
xfer-out：从本地DNS服务器到远程DNS服务器的区域传输。
```

* print-time yes：表示显示时间。

* print-severity yes：表示显示严重等级

* print-category yes：表示显示bind消息种类。

## 配置示例
```
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

```

# bind压力测试
对bind进行压力测试的工具是queryperf，该工具位于bind源码包中的contrib/queryperf中。

## 安装queryperf
```
[root@vm02 queryperf]# pwd
/root/bind-9.10.4-P2/contrib/queryperf
[root@vm02 queryperf]#
[root@vm02 queryperf]# ./configure --prefix=/usr/local/source/bind9/
[root@vm02 queryperf]# make

make完成之后，会在该目录下生成一个可执行的二进制程序queryperf，将该程序复制到指定的目录即可。
[root@vm02 queryperf]# ls -l queryperf
-rwxr-xr-x 1 root root 46046 Sep 21 10:36 queryperf
[root@vm02 queryperf]# cp -a queryperf /usr/local/source/bind9/bin/
[root@vm02 queryperf]# 

```

## queryperf的使用
```
语法格式：
-d：指定要查询的数据文件名称。文件格式为：FQDN 记录类型，如www.frame.com A。
-s：指定查询时所使用的DNS服务器地址，默认为127.0.0.1
-p：指定DNS服务器的端口，默认53
-q：指定查询次数。
-t：指定查询超时时间。默认为5s。


说明：当开启logging时，特别影响性能。

[root@vm02 bin]# wc -l /tmp/dns_test.txt 
9240 /tmp/dns_test.txt
[root@vm02 bin]# 


[root@vm02 bin]# ./queryperf -d /tmp/dns_test.txt -s 172.17.100.2

DNS Query Performance Testing Tool
Version: $Id: queryperf.c,v 1.12 2007/09/05 07:36:04 marka Exp $

[Status] Processing input data
[Status] Sending queries (beginning with 172.17.100.2)
[Status] Testing complete

Statistics:

  Parse input file:     once
  Ended due to:         reaching end of file

  Queries sent:         9240 queries
  Queries completed:    9240 queries
  Queries lost:         0 queries
  Queries delayed(?):   0 queries

  RTT max:         	0.465791 sec
  RTT min:              0.011858 sec
  RTT average:          0.074104 sec
  RTT std deviation:    0.017219 sec
  RTT out of range:     0 queries

  Percentage completed: 100.00%
  Percentage lost:        0.00%

  Started at:           Wed Sep 21 11:49:10 2016
  Finished at:          Wed Sep 21 11:49:44 2016
  Ran for:              34.385217 seconds

  Queries per second:   268.720131 qps

[root@vm02 bin]#
```

