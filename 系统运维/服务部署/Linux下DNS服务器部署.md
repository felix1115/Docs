[TOC]
#DNS介绍
在互联网中使用IP地址唯一的标识一台计算机，IP地址有两个版本，IPV4和IPV6，IPV4地址由32位二进制组成的，采用的是点分10进制表示的，分为4个字段，每个字段的范围都是0-255.但是这种表示方法对于我们来说记忆起来不是很方便，我们在浏览一个网站的时候，输入的并不是IP地址，而是URL，系统会通过一个称为名称解析系统将IP地址和主机名做一个映射，这个名称解析系统有多种类型，如WINS、HOSTS文件以及这里所要讲的DNS。究竟是通过哪个来进行名称解析的呢？这是通过NSS（Name Service Switch）来控制的，NSS是名称解析服务的一个框架，NSS的配置文件为/etc/nsswitch.conf。
在早期的TCP/IP网络中，名称解析工作是通过HOSTS文件来进行维护的，hosts文件是一个纯文本文件，维护着主机名和IP地址的对应关系，hosts文件的格式如下：
```bash
IP_address   FQDN    [aliases...]
IP地址    权威的主机名   别名

[root@vm1 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[root@vm1 ~]# 
```

##DNS查询过程
DNS查询过程是指通过DNS服务器将一个FQDN解析为IP地址或者是将IP地址解析为FQDN或者是查询一个区域邮件服务器的过程。

正向查找：将FQDN解析为IP地址
反向查找：将IP地址解析为FQDN

- **查询方式**
    - 递归查询：发生在DNS客户端和DNS服务器之间。当DNS服务器收到DNS客户端的一个查询请求时，要么做出查询成功的响应，要么做出查询失败的响应。只发出一次请求。
    - 迭代查询：发生在DNS服务器和DNS服务器之间。DNS服务器根据自己的缓存文件或者是区域数据，以最佳结果响应。如果DNS服务器无法进行解析，则会向根DNS服务器发出查询请求，请求顶级域DNS服务器的地址，然后在一级级的查找，直到查询超时或查询结果不存在为止。可能会发出多次请求。

* 权威DNS服务器返回结果有两种
    - 肯定答案：TTL
    - 否定答案：TTL

递归：应该只给允许的客户端执行递归查询。

##DNS资源记录类型
DNS服务器在提供名称解析时，会查询自己的数据库，在该数据库中包含了DNS区域资源信息的资源记录（resource record，RR）。常见的资源记录如下：
    - **SOA（Start of Authority Record起始授权记录）**: 在一个区域中是唯一的，定义了一个区域的全局参数，进行整个区域的管理。
    - **NS（Name Server名称服务器）**：在一个区域中至少有一条，记录了一个区域中的授权的DNS服务器。
    - **A（Address地址记录）**：记录了FQDN和IP地址的对应关系。
    - **CNAME（Canonical Name别名记录）**：别名记录。可以隐藏内部网络的细节。
    - **PTR**：反向记录，将IP地址映射到FQDN。
    - **MX(Mail eXchange)**：邮件交换记录。指向一个邮件服务器，根据收件人的地址后缀决定邮件服务器。

- **SOA资源记录定义方法**
```text
区域名称  网络类型  SOA  主域名服务器的FQDN  管理员邮箱  （
											序列号;Serial
											刷新间隔;refresh
											重试间隔;retry
											过期时间;expire
											TTL）

区域名称：@表示当前区域

网络类型：通常设置为IN

主域名服务器的FQDN： 区域中的master DNS服务器的FQDN，如ns1.frame.com.

管理员邮箱：用.代替@，如admin.frame.com

序列号：用于区域复制的依据。slave根据这个序列号来判断master的区域配置文件有没有发生变化。常用形式是YYYYMMDDCC，YYYY表示年，MM表示月，DD表示天，CC表示当天变化的次数。

刷新间隔：slave DNS服务器请求与master DNS服务器同步的等待时间。当刷新间隔到期后，slave DNS服务器请求master DNS服务器的SOA记录的副本，然后Slave DNS服务器将master DNS服务器的序列号与本地SOA记录的序列号比对，如果比本地的序列号大，则slave DNS服务器请求与Master进行区域传输。

重试间隔：slave DNS服务器在请求失败后，多长时间进行重试。要短于刷新间隔。

过期时间：如果这个时间到期后，辅助DNS服务器还是无法和master DNS服务器进行区域传输，则辅助DNS服务器就会把本地数据当作不可靠数据，不会为客户端提供查询功能。

TTL：这个TTL为否定答案的TTL。所谓的否定答案，即客户端请求了服务器端不存在的主机名后，所返回的TTL缓存时间值。
```

 - **NS记录**
```
区域名称 IN	NS	FQDN
```

- **A记录**
```text
FQDN   IN  A  IP地址
```

- **CNAME记录**
```
别名   IN  CNAME  FQDN(正式名称)
```


- **MX记录**
```
区域名   IN   MX  优先级  邮件服务器的FQDN

说明：
优先级的范围是0-99，数字越小，优先级越高。
```

- **PTR记录**
```
IP地址的主机号 IN   PTR   FQDN
```


#bind的安装和配置
##bind概述
在Linux系统中提供DNS服务的软件是Bind，也是最常用的软件，几乎90%的DNS服务器都是采用BIND。
DNS服务器采用的端口是UDP 53端口和TCP 53端口。

UDP 53端口：用于名称解析。
TCP 53端口：用于区域传输。

因此在配置防火墙时要同时放行TCP和UDP的53端口。

##bind安装
bind：bind的主程序软件包，进程名为named
bind-chroot：为bind提供chroot功能，将bind进程限制在自己的家目录下，防止错误的权限设置影响到整个系统。
bind-utils：提供一些工具。如dig
```bash
查询是否已经安装了bind：
[root@vm1 ~]# rpm -qa | grep bind
[root@vm1 ~]# 

安装bind：
[root@vm1 ~]# yum install -y bind bind-chroot bind-utils
```

## bind配置
全局配置文件：named.conf
如果没有使用chroot机制的话，则全局配置文件位于/etc/named.conf，如果使用了chroot机制的话，则全局配置文件位于/var/named/chroot/etc/named.conf。有没有使用chroot，对于bind的配置都是一样的，唯一的不同就是配置文件所在的路径不同了。
如果启用了chroot机制的话，且不希望bind的根目录为/var/named/chroot的话，则可以通过修改配置文件/etc/sysconfig/named中ROOTDIR来实现。
```bash
[root@vm1 ~]# grep '^ROOTDIR' /etc/sysconfig/named 
ROOTDIR=/var/named/chroot
[root@vm1 ~]# 
```

```
复制配置文件到chroot目录：

[root@vm1 ~]# cd /var/named/
[root@vm1 named]# ls -l
total 32
drwxr-x--- 6 root  named 4096 Nov 13 12:14 chroot
drwxrwx--- 2 named named 4096 Aug 27  2013 data
drwxrwx--- 2 named named 4096 Aug 27  2013 dynamic
-rw-r----- 1 root  named 1892 Feb 18  2008 named.ca
-rw-r----- 1 root  named  152 Dec 15  2009 named.empty
-rw-r----- 1 root  named  152 Jun 21  2007 named.localhost
-rw-r----- 1 root  named  168 Dec 15  2009 named.loopback
drwxrwx--- 2 named named 4096 Aug 27  2013 slaves
[root@vm1 named]# mv d* named.* slaves/ chroot/var/named/
[root@vm1 named]# 
[root@vm1 named]# cp -a /etc/named.* /var/named/chroot/etc/
[root@vm1 named]# 
```

##配置文件参数介绍
```bash
主配置文件参数（options块）

listen-on port：指定DNS监听的端口和地址。如果监听在本机的所有地址，可以用any。如listen-on port 53 { 172.17.100.1; };

listen-on-v6 port：指定DNS监听的IPV6的地址和端口。如listen-on-v6 port 53 { ::1; };

directory：指定区域数据文件所在的路径。默认为"/var/named"。如果使用了chroot，则该路径为相对路径，为/var/named/chroot/var/named

query-source port：指定DNS客户端在查询时必须使用的源端口。该参数通常不设置。

allow-query：允许哪些客户端进行查询，如果没有定义此选项，则表示允许所有的客户端提交的DNS查询请求。如：allow-query { 172.17.100.200; 172.17.100.210; }；则允许172.17.100.200和172.17.100.210这两个客户端提交的DNS查询请求。由外向内。通常都是any。允许所有的客户端查询。

allow-recursion：允许哪些客户端执行递归查询。如果该DNS服务器不对外开放，即不给互联网的用户执行查询时，则开启该选项。与allow-query不同的是，不执行客户端提交的递归查询。allow-query允许迭代查询和递归查询。allow-recursion由内向外。通常需要放行本地网段和127.0.0.0/8的。

recursion yes：默认为yes，则表示给所有的客户端执行递归。这样就成为一个开放的DNS服务器了。

forwarders：指定转发服务器。如果定义了多个转发服务器，则依次进行尝试，直到获得查询信息为止。本地的DNS服务器会将查询请求转发到转发服务器。如果该项目设置在区域定义之外的话，是对所有非本地区域的解析都转发到指定的DNS服务器；如果定义在某个区域内，则是将对该区域的解析转发到指定服务器。

forward only|first：only表示只将查询请求转发到所定义的转发服务器，不通过本机查询。first表示先将查询转发到所定义的转发服务器，如果没有响应，则通过本机进行迭代查询。默认为first。

querylog：yes启用查询日志记录功能。no关闭查询日志记录功能。

allow-transfer：允许哪些slave DNS服务器进行区域传输。

recursion：选项指定是否允许客户端递归查询其他域名服务器。如果希望对本地客户端的查询允许递归，但对来自外部的查询请求禁止递归，可以通过“allow-recursion”选项进行定义。allow-recursion选项可以指定一个允许执行递归查询操作的地址列表。

transfer-source x.x.x.x：指定slave在向master进行区域传输时所使用的源地址。

notify：是否启用notify功能。yes表示当Master端数据修改时，通知Slave进行区域传输，no表示不通知slave。

allow-update：是否允许通过DHCP获取IP地址的机器动态更新DNS信息，none表示不允许。

dnssec-enable:设定BIND是否支持DNSSEC，该技术并不对数据进行加密，它只是验证您所访问的站点地址是否有效。是一种端到端的安全协议。默认为yes。在做子域授权时，需要设置为no

dnssec-validation：默认为yes，在做子域授权时，需要设置为no

=========================================================================
view块的配置参数：

配置格式：
view view-name {

};
常用选项：
match-clients：允许哪些客户端提交的DNS查询请求。
match-destinations：客户端要去往的目的地。如any
match-recursive-only：是否允许递归。yes|no
include：把哪些文件也读进来。可以指定主配置文件。
在主配置文件中，可以定义多个view，如果DNS客户端所提交的查询满足第一个view，就使用第一个view进行处理，如果不满足，则查询是否满足下一个view，如果都不满足，则DNS服务器将返回query refused的消息。
可以使用view来实现智能DNS。根据用户的IP地址的不同，返回不同的结果。
==============================================================================

ACL格式：
acl  acl_name  {
    address_math_list ;
};
acl即访问控制列表，定义了一个地址匹配列表

==============================================================================

key语句格式：
key  key-id  {
    algorithm  string;
    secret  string;
};
key语句定义了用于服务器身份验证的加密密钥。

==============================================================================

zone语句格式：
zone语句是named.conf文件的核心部分，用于在域名系统中设置所使用的区域（分为正向解析区域和反向解析区域），并为每个区域设置适当的选项。zone语名的格式如下：

正向解析区域：
 zone  “domain_name” IN  {
      type  master;   ----- 表示区域的类型为主服务器；
      file  "path";   ----- 设置此区域的区域文件路径和文件名；
};

反向解析区域：
zone “x.x.x.in-addr.arpa” IN {
	type master;
	file  "path";
};

==============================================================================

Bind可以使用的区域类型及其说明如下：
master：主DNS区域。拥有该区域的区域数据文件，对该区域提供管理。
slave：从DNS区域。拥有master区域的区域数据文件的只读副本，slave区域从master区域获取所有的数据，这个过程称为区域传输。
forward：转发区域。用于转发DNS客户端的查询。
stub：存根区域。和slave区域类似，但是只复制master区域的NS记录和NS记录对应的A记录。
hint：提示区域，定义根所在的位置。用于查找根DNS服务器的位置。

==============================================================================

区域配置文件格式如下：

[名称]  [TTL]  [网络类型]   资源记录类型   数据 
名称：指定资源记录引用的对象名，可以是主机名，也可以是域名。对象名可以是相对名称也可以是完整名称。完整名称必须以点结尾。如果连续的几条资源记录类型是同一个对象名，则第一条资源记录后的资源记录可以省略对象名。相对名称表示相对与当前域名来说的，如当前域名为frame.com，则表示www主机时，完整名称为www.frame.com.，相对名称为www。

TTL：指定资源记录存在缓存中的时间，单位为秒。如果该字段省略，则使用在文件开始出的$TTL所定义的时间。

网络类型：常用的为IN

资源记录类型：常用的有SOA、NS、A、PTR、MX、CNAME

在定义资源记录时，一般情况下是SOA记录为第一行，NS记录第二行，接着是MX记录，其他的记录可以随便写。

;：表示注释
()：允许数据跨行。通常用于SOA记录
@：表示当前域。根据主配置文件zone中所定义的区域名称。
*：用于名称字段的通配符。
$ORIGIN :ORIGIN后面跟上的是字符串，即要补全的内容。

==============================================================================
IP地址的格式可以是如下的几种形式：
单一主机：x.x.x.x，如172.17.100.100
指定网段：x.x.x.或x.x.x.x/n，如172.17.100.或者是172.17.100.0/24
指定多个地址：x.x.x.xx.x.x.x如，172.17.100.100;172.17.100.200
使用!表示否定：如!172.17.100.100，则排除172.17.100.100
不匹配任何：none
匹配所有：any
本地主机（bind本机）：localhost
与bind主机同网段的所有IP地址：localnet


注：启动named服务的时候，如果比较慢，卡在如下部分，可以通过执行如下指令解决：
[root@zhh240 named]# /etc/init.d/named restart
Stopping named:                                            [  OK  ]
Generating /etc/rndc.key:

一直卡在Generating这一步，解决方法：
[root@vm1 ~]# rndc-confgen -r /dev/urandom -a
wrote key file "/etc/rndc.key"
[root@vm1 ~]# 

```

##配置示例

### Master DNS服务器配置示例
```bash
步骤1：安装bind、bind-chroot、bind-utils
[root@vm1 ~]# yum install -y bind bind-chroot bind-utils

步骤2：复制配置文件到chroot目录（/var/named/chroot）
[root@vm1 ~]# cd /var/named/
[root@vm1 named]# ls -l
total 32
drwxr-x--- 6 root  named 4096 Nov 13 12:14 chroot
drwxrwx--- 2 named named 4096 Aug 27  2013 data
drwxrwx--- 2 named named 4096 Aug 27  2013 dynamic
-rw-r----- 1 root  named 1892 Feb 18  2008 named.ca
-rw-r----- 1 root  named  152 Dec 15  2009 named.empty
-rw-r----- 1 root  named  152 Jun 21  2007 named.localhost
-rw-r----- 1 root  named  168 Dec 15  2009 named.loopback
drwxrwx--- 2 named named 4096 Aug 27  2013 slaves
[root@vm1 named]# mv d* named.* slaves/ chroot/var/named/
[root@vm1 named]# 
[root@vm1 named]# cp -a /etc/named.* /var/named/chroot/etc/
[root@vm1 named]# 

步骤3：修改主配置文件named.conf
options {
	listen-on port 53 { 172.17.100.1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };
	allow-recursion { 172.17.100.0/24; };

	dnssec-enable yes;
	dnssec-validation yes;
	dnssec-lookaside auto;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "felix.com" IN {
    type master;
    file "named.felix.com";
    allow-update { none; };  
    allow-transfer { 172.17.100.2; };
    notify yes;
};

zone "100.17.172.in-addr.arpa" IN {
    type master;
    file "named.172.17.100";
    allow-update { none; };
    allow-transfer { 172.17.100.2; };    
    notify yes;
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";


步骤4：创建区域数据文件，并修改权限。如果是通过named.localhost文件复制过来的，此步可以忽略。
[root@vm1 named]# touch named.felix.com named.172.17.100
[root@vm1 named]# chown root:named named.felix.com named.172.17.100
[root@vm1 named]# chmod 640 named.felix.com named.172.17.100
[root@vm1 named]# ls -l named.felix.com named.172.17.100
-rw-r----- 1 root named 0 Nov 13 13:04 named.felix.com
[root@vm1 named]# 

步骤5：创建区域数据
创建正向区域数据：named.felix.com

$TTL 3600
@   IN  SOA ns1.felix.com.  admin.felix.com.    (
                                    2015111301; Serial
                                    1H;Refresh
                                    15M;Retry
                                    7D;Expire
                                    1H;TTL
                                    )

    IN  NS  ns1.felix.com.
    IN  NS  ns2.felix.com.
ns1.felix.com.  IN  A   172.17.100.1
ns2.felix.com.  IN  A   172.17.100.2
ntp.felix.com.  IN  A   172.17.100.1
ftp.felix.com.  IN  A   172.17.100.1
www.felix.com.  IN  A    172.17.100.1
@               IN  A    172.17.100.1
 

创建反向区域数据：named.172.17.100
$TTL 3600
@   IN  SOA ns1.felix.com.  admin.felix.com.    (
                                    2015111301; Serial
                                    1H;Refresh
                                    15M;Retry
                                    7D;Expire
                                    1H;TTL
                                    )

    IN  NS  ns1.felix.com.
    IN  NS  ns2.felix.com.
1   IN  PTR ns1.felix.com.  
2   IN  PTR ns2.felix.com.  
1   IN  PTR ntp.felix.com.
1   IN  PTR ftp.felix.com.

步骤6：执行rndc-confgen，加快第一次启动服务的速度
[root@vm1 ~]# rndc-confgen -r /dev/urandom -a
wrote key file "/etc/rndc.key"
[root@vm1 ~]# 


步骤7：启动服务，并设置开机自动启动。如果出现错误使用tail -f /var/log/messages查看错误原因
[root@vm1 ~]# /etc/init.d/named restart
Stopping named: .                                          [  OK  ]
Starting named:                                            [  OK  ]
[root@vm1 ~]# chkconfig --level 35 named on
[root@vm1 ~]# 


步骤8：修改/etc/resolv.conf，添加域名和nameserver
domain：指定域名
search：指定搜索域
nameserver：定义nameserver的地址，最多3个

[root@vm1 ~]# cat /etc/resolv.conf 
domain felix.com
search felix.com
nameserver 172.17.100.1
nameserver 172.17.100.2
[root@vm1 ~]# 


步骤9：测试
[root@vm1 ~]# nslookup 
> ns1.felix.com 
Server:		172.17.100.1
Address:	172.17.100.1#53

Name:	ns1.felix.com
Address: 172.17.100.1

> ftp.felix.com
Server:		172.17.100.1
Address:	172.17.100.1#53

Name:	ftp.felix.com
Address: 172.17.100.1

> 172.17.100.2
Server:		172.17.100.1
Address:	172.17.100.1#53

2.100.17.172.in-addr.arpa	name = ns2.felix.com.
> 

```

### Slave DNS服务器配置示例

```bash
步骤1：安装bind、bind-utils、bind-chroot
[root@vm2 ~]# yum install -y bind bind-chroot bind-utils
 
步骤2：复制配置文件到chroot目录(/var/named/chroot)
[root@vm2 ~]# cd /var/named/
[root@vm2 named]# ls -l
total 32
drwxr-x--- 6 root  named 4096 Nov 13 13:31 chroot
drwxrwx--- 2 named named 4096 Aug 27  2013 data
drwxrwx--- 2 named named 4096 Aug 27  2013 dynamic
-rw-r----- 1 root  named 1892 Feb 18  2008 named.ca
-rw-r----- 1 root  named  152 Dec 15  2009 named.empty
-rw-r----- 1 root  named  152 Jun 21  2007 named.localhost
-rw-r----- 1 root  named  168 Dec 15  2009 named.loopback
drwxrwx--- 2 named named 4096 Aug 27  2013 slaves
[root@vm2 named]# mv d* named.* slaves/ /var/named/chroot/var/named/
[root@vm2 named]# cp -a /etc/named.* /var/named/chroot/etc/
[root@vm2 named]#

步骤3：修改主配置文件named.conf（可以从MASTER DNS服务器拷贝一份，并进行修改即可）
[root@vm1 ~]# scp /var/named/chroot/etc/named.conf root@172.17.100.2:/var/named/chroot/etc/
root@172.17.100.2's password: 
named.conf                                                                                                        100% 1357     1.3KB/s   00:00    
[root@vm1 ~]# 

修改named.conf配置文件：
type：指定为slave
masters：指定主DNS服务器的IP地址。
transfer-source：指定在进行区域传输时所使用的源IP地址。
file：指定通过区域传输过来的区域数据文件所存放的路径。通常放在/var/named/slaves/目录下。
```
![Slave DNS服务器配置示例](http://img.blog.csdn.net/20160526102519625)
```bash

步骤4：Master DNS服务器named.conf配置
在区域配置文件里面要增加如下信息：
allow-transfer：指定Slave DNS服务器的IP地址。
notify yes：当区域数据文件修改时，主动的通知Slave进行数据更新。

zone "felix.com" IN {
    type master;
    file "named.felix.com";
    allow-update { none; };  
    allow-transfer { 172.17.100.2; };
    notify yes;
};

zone "100.17.172.in-addr.arpa" IN {
    type master;
    file "named.172.17.100";
    allow-update { none; };
    allow-transfer { 172.17.100.2; };    
    notify yes;
};

步骤5：执行rndc-confgen，加快第一次启动服务的速度
[root@vm2 ~]# rndc-confgen -r /dev/urandom -a
wrote key file "/etc/rndc.key"
[root@vm2 ~]# 
  
步骤6：启动服务，并设置开机自动启动。如果出现错误使用tail -f /var/log/messages查看错误原因
[root@vm2 ~]# /etc/init.d/named restart
Stopping named: .                                          [  OK  ]
Starting named:                                            [  OK  ]
[root@vm2 ~]# chkconfig --level 35 named on
[root@vm2 ~]# 
  
步骤7：查看区域传输日志
Nov 13 13:51:13 vm2 named[1797]: zone felix.com/IN: Transfer started.
Nov 13 13:51:13 vm2 named[1797]: transfer of 'felix.com/IN' from 172.17.100.1#53: connected using 172.17.100.2#56675
Nov 13 13:51:13 vm2 named[1797]: zone felix.com/IN: transferred serial 2015111301
Nov 13 13:51:13 vm2 named[1797]: transfer of 'felix.com/IN' from 172.17.100.1#53: Transfer completed: 1 messages, 8 records, 213 bytes, 0.005 secs (42600 bytes/sec)
Nov 13 13:51:13 vm2 named[1797]: zone felix.com/IN: sending notifies (serial 2015111301)
Nov 13 13:51:14 vm2 named[1797]: zone 100.17.172.in-addr.arpa/IN: Transfer started.
Nov 13 13:51:14 vm2 named[1797]: transfer of '100.17.172.in-addr.arpa/IN' from 172.17.100.1#53: connected using 172.17.100.2#33093
Nov 13 13:51:14 vm2 named[1797]: zone 100.17.172.in-addr.arpa/IN: transferred serial 2015111301
Nov 13 13:51:14 vm2 named[1797]: transfer of '100.17.172.in-addr.arpa/IN' from 172.17.100.1#53: Transfer completed: 1 messages, 8 records, 232 bytes, 0.007 secs (33142 bytes/sec)
 
查看传输过来的区域数据文件：/var/named/chroot/var/named/slave/
[root@vm2 ~]# ls -l /var/named/chroot/var/named/slaves/
total 8
-rw-r--r-- 1 named named 426 Nov 13 13:51 named.172.17.100
-rw-r--r-- 1 named named 393 Nov 13 13:51 named.felix.com
[root@vm2 ~]#  
 
步骤8：测试
[root@vm2 ~]# nslookup 
> ns1.felix.com
Server:		172.17.100.2
Address:	172.17.100.2#53

Name:	ns1.felix.com
Address: 172.17.100.1
> 172.17.100.1
Server:		172.17.100.2
Address:	172.17.100.2#53

1.100.17.172.in-addr.arpa	name = ftp.felix.com.
1.100.17.172.in-addr.arpa	name = ns1.felix.com.
1.100.17.172.in-addr.arpa	name = ntp.felix.com.
> 

测试OK……

步骤9：dig测试同步区域传输
完整区域传输：
[root@vm2 ~]# dig -t AXFR felix.com

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.17.rc1.el6_4.6 <<>> -t AXFR felix.com
;; global options: +cmd
felix.com.		3600	IN	SOA	ns1.felix.com. admin.felix.com. 2015111301 3600 900 604800 3600
felix.com.		3600	IN	NS	ns1.felix.com.
felix.com.		3600	IN	NS	ns2.felix.com.
ftp.felix.com.		3600	IN	A	172.17.100.1
ns1.felix.com.		3600	IN	A	172.17.100.1
ns2.felix.com.		3600	IN	A	172.17.100.2
ntp.felix.com.		3600	IN	A	172.17.100.1
felix.com.		3600	IN	SOA	ns1.felix.com. admin.felix.com. 2015111301 3600 900 604800 3600
;; Query time: 1 msec
;; SERVER: 172.17.100.2#53(172.17.100.2)
;; WHEN: Fri Nov 13 13:56:49 2015
;; XFR size: 8 records (messages 1, bytes 213)

[root@vm2 ~]# 

```

## TSIG
```bash
TSIG(transaction signature)：事务签名。使用MD5加密的方式验证DNS Master和Slave之间数据传输的信息。
首先需要在Master DNS服务器上生成加密密钥，然后将此密钥传递到辅助的DNS服务器上，经过配置以后，由Slave DNS服务器以加密的方式将数据传输请求发送到Master DNS服务器上。同时还可以提供DDNS的加密。TSIG主要用于确保Slave DNS服务器所获取的信息是来自于真正的Master DNS服务器，而不是来自于虚假的DNS服务器。


Master DNS服务器配置步骤

步骤1：创建密钥
[root@vm1 etc]# pwd
/var/named/chroot/etc
[root@vm1 etc]# dnssec-keygen -a hmac-md5 -b 128 -n user felix
Kfelix.+157+45163
[root@vm1 etc]# 

[root@vm1 etc]# ls -l Kfelix.+157+45163.*
-rw------- 1 root root  47 Nov 13 14:31 Kfelix.+157+45163.key
-rw------- 1 root root 165 Nov 13 14:31 Kfelix.+157+45163.private
[root@vm1 etc]# 
说明：.key表示的是公钥。.private表示的是私钥。
 
步骤2：查看公钥文件的内容
[root@vm1 etc]# cat Kfelix.+157+45163.key 
felix. IN KEY 0 3 157 5hmTnN5cMHZMJQhSgfhN1Q==
[root@vm1 etc]# 
 
步骤3：修改named.conf，增加key和server选项，并修改allow-transfer
key felix {
    algorithm hmac-md5;
    secret "5hmTnN5cMHZMJQhSgfhN1Q==";
};

#server后面的地址为slave dns服务器的地址
server 172.17.100.2 {
    keys { felix; };
};  

zone "felix.com" IN {
    type master;
    file "named.felix.com";
    allow-update { none; };  
    #allow-transfer { 172.17.100.2; };
    allow-transfer { key felix; };
    notify yes;
};

zone "100.17.172.in-addr.arpa" IN {
    type master;
    file "named.172.17.100";
    allow-update { none; };
    #allow-transfer { 172.17.100.2; };    
    allow-transfer { key felix; };
    notify yes;
};

步骤4：重启named服务 
[root@vm1 etc]# /etc/init.d/named restart
Stopping named: .                                          [  OK  ]
Starting named:                                            [  OK  ]
[root@vm1 etc]# 


Slave DNS服务器配置步骤
步骤1：修改named.conf配置文件
key felix {
    algorithm hmac-md5;
    secret "5hmTnN5cMHZMJQhSgfhN1Q==";
};

#slave dns的server指向的是master dns的ip地址
server 172.17.100.1 {
    keys { felix; };
}; 
 
步骤2：重启named服务
[root@vm2 etc]# /etc/init.d/named restart
Stopping named: .                                          [  OK  ]
Starting named:                                            [  OK  ]
[root@vm2 etc]# 

查看log信息：
Nov 13 16:00:01 vm1 named[8391]: client 172.17.100.2#54582: transfer of '100.17.172.in-addr.arpa/IN': AXFR started: TSIG felix
Nov 13 16:00:01 vm1 named[8391]: client 172.17.100.2#54582: transfer of '100.17.172.in-addr.arpa/IN': AXFR ended
Nov 13 16:00:02 vm1 named[8391]: client 172.17.100.2#43042: transfer of 'felix.com/IN': AXFR started: TSIG felix
Nov 13 16:00:02 vm1 named[8391]: client 172.17.100.2#43042: transfer of 'felix.com/IN': AXFR ended
  
注意事项：
在进行TSIG区域传输的时候，请确保Master和Slave DNS服务器之间的时间同步，如果不同步，则在进行区域传输时会出现如下问题：
Jan 29 13:44:06 RS3 named[2570]: client 172.17.100.242#51453: request has invalid signature: TSIG named: tsig verify failure (BADTIME)
Jan 29 13:44:06 RS3 named[2570]: client 172.17.100.242#24885: request has invalid signature: TSIG named: tsig verify failure (BADTIME)
```