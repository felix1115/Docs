# 安装PPTP
## RPM包安装pptp
```
[root@vm01 ~]# yum install -y ppp
[root@vm01 ~]# yum localinstall -y pptpd-1.3.4-1.el6.x86_64.rpm 

[root@vm01 ~]#  pptpd --version
pptpd v1.3.4
[root@vm01 ~]# pppd --version
pppd version 2.4.5
[root@vm01 ~]# 

```

## 源码安装和配置PPTP
```
* 安装PPTP 1.3.4：
[root@vm01 ~]# tar -zxf pptpd-1.3.4.tar.gz 
[root@vm01 ~]# cd pptpd-1.3.4
[root@vm01 pptpd-1.3.4]# ./configure --prefix=/usr/local/source/pptpd-1.3.4
[root@vm01 pptpd-1.3.4]# make
[root@vm01 pptpd-1.3.4]# make install


* 拷贝配置文件和vpnuser工具
[root@vm01 pptpd-1.3.4]# mkdir /usr/local/source/pptpd-1.3.4/etc
[root@vm01 pptpd-1.3.4]# cp samples/* /usr/local/source/pptpd-1.3.4/etc
[root@vm01 pptpd-1.3.4]# cp tools/vpnuser /usr/local/source/pptpd-1.3.4/sbin/
[root@vm01 pptpd-1.3.4]# 


* 修改工具vpnuser中的config变量，指定chap-secrets的位置
[root@vm01 sbin]# grep 'config=' vpnuser  
config="/etc/ppp/chap-secrets"
[root@vm01 sbin]# 

```



# 配置PPTP
* 主配置文件：/etc/pptpd.conf
* 选项配置文件：/etc/ppp/options.pptpd
* 用户信息配置文件：/etc/ppp/chap-secrets

## 开启ip_forward
```
[root@vm01 ppp]# echo 1 > /proc/sys/net/ipv4/ip_forward 
[root@vm01 ppp]# 

```

## 加载ip_gre模块
```
说明：有时候会提示GRE相关错误信息，需要加载ip_gre模块。
[root@vm01 ppp]# modprobe ip_gre
[root@vm01 ppp]# lsmod | grep gre
ip_gre                  9575  0 
ip_tunnel              12693  1 ip_gre
[root@vm01 ppp]# 

```

## pptpd.conf
```
选项说明：

ppp /usr/sbin/pppd: 指定pppd程序的路径。这个是默认路径。
option /etc/ppp/options.pptpd: 指定选项配置文件的路径。
debug #开启debug模式，所有的输出都写入到日志文件。
stimeout 10：ctrl connections(控制连接)的超时时间。
logwtmp：使用wtmp(last命令使用的文件)文件记录客户端的连接和断开信息。
delegate：由pptpd负责分配空闲的IP地址给pppd，否则的话，则由radius分配IP地址。默认关闭。
connections 100：限制pptpd可以接受的最大客户端连接数。默认为100
localip：指定VPN服务器的IP地址。如果设置了delegate选项，则localip和remoteip会被忽略。
remoteip：指定分配给VPN Client的ip地址或地址段。
```

```
[root@vm01 ~]# grep -vE '^#|^$' /etc/pptpd.conf 
ppp /usr/sbin/pppd
option /etc/ppp/options.pptpd
debug
stimeout 10
connections 100
localip 172.17.100.1
remoteip 172.17.100.180-200
[root@vm01 ~]# 
```

## options.pptpd
```
选项说明：
name pptpd：指定本地系统用于认证的程序名称，这个要和/etc/ppp/chap-secrets的第二个字段一致。
ms-dns 172.17.100.1：指定给Microsoft Client分配的主DNS服务器地址。
ms-dns 172.17.100.2：指定给Microsoft Client分配的从DNS服务器地址。
proxyarp：开启代理arp
refuse-pap：拒绝pap身份验证，如果不需要可以注释
refuse-chap：拒绝chap身份验证，如果不需要可以注释
refuse-mschap：拒绝mschap身份验证，如果不需要可以注释
require-mschap-v2：需要使用使用mschap-v2身份验证方法。
require-mppe-128：需要使用128位MPPE加密
nologfd：注释该选项，使用logfile指定日志文件的位置。默认记录在/var/log/messages中。
logfile /var/log/pptpd.log：指定日志文件的存储位置。

```

```
说明：这里允许了chap和mschap认证。

[root@vm01 ~]# grep -vE '^#|^$' /etc/ppp/options.pptpd 
name pptpd
refuse-pap
require-mschap-v2
require-mppe-128
ms-dns 172.17.100.1
ms-dns 172.17.100.2
proxyarp
logfile /var/log/pptpd.log
lock
nobsdcomp 
novj
novjccomp
[root@vm01 ~]# 
```

## chap-secrets
```
说明：该文件指定了使用chap认证时用户的认证信息。
文件格式为：  client    server    secret   IP Address

client：客户端用户名
server：在options.pptpd中定义的name。
secret：客户端密码
IP Address：分配给客户端的IP地址。这里分配的是静态Ip地址地址，如果想动态分配地址，可以用*

示例：
frame   pptpd   frame123   172.17.100.180
```

# vpnuser命令的使用
```
vpnuser可以添加、删除、查看VPN用户信息。

查看：vpnuser show
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
[root@vm01 ~]# 


添加VPN用户：vpnuser add
[root@vm01 ~]# vpnuser add test test123
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
test	*	test123	*
[root@vm01 ~]# 


删除VPN用户：vpnuser del
[root@vm01 ~]# vpnuser del test
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
[root@vm01 ~]# 

```

# iptables设置
```
pptpd默认监听在TCP的1723端口。

放行TCP 1723：
[root@vm01 ~]# netstat -tunlp | grep pptpd
tcp        0      0 0.0.0.0:1723                0.0.0.0:*                   LISTEN      6041/pptpd          
[root@vm01 ~]# 


加载相关模块使iptables支持PPTP穿透：
[root@vmgw ~]# modprobe nf_nat_pptp
[root@vmgw ~]# modprobe nf_conntrack_pptp
[root@vmgw ~]# modprobe nf_conntrack_proto_gre
[root@vmgw ~]# modprobe nf_nat_proto_gre
[root@vmgw ~]# 

后者是直接加载ip_nat_pptp模块：
[root@vmgw ~]# modprobe ip_nat_pptp
[root@vmgw ~]# 



设置开机自动加载模块：
[root@vmgw ~]# cat /etc/sysconfig/iptables-config | grep '\<IPTABLES_MODULES\>'
IPTABLES_MODULES="ip_nat_pptp"
[root@vmgw ~]# 

```

```
[root@vmgw ~]# iptables -t nat -A PREROUTING -i eth0 -p tcp -d 172.17.200.1 --dport 1723 -j DNAT --to-dest 172.17.100.1:1723
[root@vmgw ~]# modprobe ip_nat_pptp
[root@vmgw ~]# 
[root@vmgw ~]# /etc/init.d/iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@vmgw ~]# 
```


## Linux客户端测试
## CentOS作为客户端
```
[root@vm3 ~]# yum install -y pptp-setup

创建连接：
[root@vm3 ~]# pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start

说明：
--create:表示创建一个VPN连接，test为连接名称，可以随便起。
--server:指定VPN服务器的地址。
--username:VPN用户名
--password:VPN密码。
--encrypt:加密
--start:创建完之后，启动这个连接。如果只是创建连接的话，可以没有--start，后面可以通过pppd call test进行连接。

删除连接：test为连接名称。
[root@vm3 ~]# pptpsetup --delete test

断开VPN：pkill pppd


示例：
[root@vm3 ~]# pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start
Using interface ppp0
Connect: ppp0 <--> /dev/pts/2
CHAP authentication succeeded
MPPE 128-bit stateless compression enabled
local  IP address 172.17.100.180
remote IP address 172.17.100.1
[root@vm3 ~]# 


[root@vm3 ~]# ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 b)  TX bytes:66 (66.0 b)

[root@vm3 ~]# 


断开连接：
[root@vm3 ~]# pkill pppd
[root@vm3 ~]# ifconfig ppp0
ppp0: error fetching interface information: Device not found
[root@vm3 ~]# 

重新连接：
[root@vm3 ~]# pppd call test
[root@vm3 ~]# ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 b)  TX bytes:66 (66.0 b)

[root@vm3 ~]# 


删除连接：
[root@vm3 ~]# pptpsetup --delete test
[root@vm3 ~]# 

```

## Ubuntu作为客户端
```
安装pptp-setup
felix@u01:~$ sudo apt-get install -y pptp-setup


创建连接：
felix@u01:~$ sudo pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start
Using interface ppp0
Connect: ppp0 <--> /dev/pts/0
CHAP authentication succeeded
MPPE 128-bit stateless compression enabled
local  IP address 172.17.100.180
remote IP address 172.17.100.1
felix@u01:~$ 
felix@u01:~$ sudo ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 B)  TX bytes:66 (66.0 B)

felix@u01:~$ 


停止VPN：poff test
felix@u01:~$ sudo poff test
felix@u01:~$ 
felix@u01:~$ sudo ifconfig ppp0
ppp0: error fetching interface information: Device not found
felix@u01:~$ 

启动连接：pon test
felix@u01:~$ sudo pon test
felix@u01:~$ sudo ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 B)  TX bytes:66 (66.0 B)

felix@u01:~$ 


删除连接：
felix@u01:~$ sudo pptpsetup --delete test
felix@u01:~$ 

```

# pptpd脚本
```
#!/bin/bash

# chkconfig: - 85 15
# description: PPTP server
# processname: pptpd


PROGRAM='/usr/local/source/pptpd-1.3.4'
CONFIG=$PROGRAM/etc/pptpd.conf
PPTPD=$PROGRAM/sbin/pptpd

# Source function library.
. /etc/rc.d/init.d/functions

# Source function library.
. /etc/rc.d/init.d/functions

case "$1" in
  start)
        echo -n "Starting pptpd: "
        if [ -f /var/lock/subsys/pptpd ] ; then
                echo
                exit 1
        fi
        daemon $PPTPD -c $CONFIG
        echo
        touch /var/lock/subsys/pptpd
        ;;
  stop)
        echo -n "Shutting down pptpd: "
        killproc pptpd
        echo
        rm -f /var/lock/subsys/pptpd
        ;;
  status)
        status pptpd
        ;;
  reload|restart)
        $0 stop
        $0 start
        echo "Warning: a pptpd restart does not terminate existing "
        echo "connections, so new connections may be assigned the same IP "
        echo "address and cause unexpected results.  Use restart-kill to "
        echo "destroy existing connections during a restart."
        ;;
  restart-kill)
        $0 stop
        ps -ef | grep pptpd | grep -v grep | grep -v rc.d | awk '{print $2}' | uniq | xargs kill 1> /dev/null 2>&1
        $0 start
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|restart-kill|status}"
        exit 1
esac

exit 0

```

# 其他一些工具
```
说明：这些工具位于/usr/share/doc/ppp-x.x.x/scripts中。
pon：开启VPN连接。
poff：关闭VPN连接
plog：查看VPN连接日志。
```