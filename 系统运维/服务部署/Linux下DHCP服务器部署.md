#DHCP介绍
DHCP：动态主机配置协议。为客户端动态提供IP地址、子网掩码、网关、DNS等信息的，可以简化客户端的配置、节约IP地址、降低IP地址冲突的风险。

##DHCP租约产生的过程
1. 客户端请求IP地址
	客户端通过广播的方式发送一个源IP为0.0.0.0，目标IP为255.255.255.255，源端口为68，目标端口为67的DHCP Discovery消息的数据包，该数据包还包含客户端的MAC地址和主机名，以便服务器端可以知道是哪个客户端发过来的请求。
	
2. 服务器响应
	当DHCP服务器收到客户端发来的DHCP Discovery消息时，首先查看是否有针对客户端所设置的固定IP信息，如果有的话，则分配该固定IP地址。如果没有的话就会在自己的租约文件中查看该客户端以前是否有使用过某一个地址，如果有且该地址目前可用，则将该地址发送给客户端。如果以上都没有，则从DHCP地址池中选择一个没有使用的地址分配给客户端，并以DHCP Offer消息发送。源IP地址为DHCP服务器的IP地址，源端口为67端口，目标地址为255.255.255.255，目标端口为68端口。该DHCP Offer消息中还包含以下信息：
	
    - 客户端的MAC地址（可以标识正确的客户端）。
    - 分配给客户端的IP地址、子网掩码、网关、DNS等信息。
    - 租约期限
    - DHCP服务器的IP地址
	
	服务器在将该地址分配给客户端之前，会发送一个ICMP Ping探测，判断该地址是否有客户端使用，如果收到ICMP Ping 响应的话，则重新分配一个地址，否则，将该地址分配给客户端。
3. 客户端选择
	在一个网段中，如果有多台DHCP服务器的话，则DHCP客户端可能会收到多个服务器发来的DHCP Offer消息，通常情况下，客户端会选择最先到达的DHCP Offer消息所提供的IP地址。这时，客户端发送的是DHCP Request消息，源IP为0.0.0.0，源端口为68，目标IP为255.255.255.255，目标端口为67。
客户端收到服务器发来的地址后，客户端会发送免费的ARP进行探测，如果收到响应的话，则会发送一个DHCP decline数据包给服务器，表明服务器所提供的TCP/IP信息不可用。然后重新进行新一轮的DHCP请求过程。如果可用的话，则发送DHCP Request消息。

4. 服务器确认
	服务器收到DHCP客户端发来的DHCP Request消息后，会使用DHCP ACK消息向客户端进行确认，租约正式生效。源IP为DHCP服务器的IP地址，源端口67，目标IP为255.255.255.255，目标端口为68.

整个过程中所有的数据包都是通过广播的形式发送的。

对于windows客户端来说，如果在发出DHCP Discovery消息后，没有收到服务器的响应的话，则会自动分配一个169.254.0.0/16的地址，这个过程叫做APIPA，以保证在没有获取IP地址的windows客户端之间也可以正常的通信。

##租约更新

当客户端重启或者是租约达到50%的时候，就需要重新更新租约。客户端会向提供租约的DHCP服务器直接发送DHCP Request消息请求租约的更新。如果服务器收到请求，则发送DHCP ACK消息给客户端，更新租约。如果客户端无法与DHCP服务器进行通信的话，则会在剩下时间的50%时，也就是总时间的75%时，会重新发送DHCP Request请求租约更新，如果收到响应则更新租约，如果没有收到响应，则客户端仍然可以使用该地址，然后客户端会在剩下时间再过去一半的时候，即总时间的87.5%的时候，重新进行租约的更新，这时采用的是DHCP Discovery消息以广播的形式向所有的DHCP服务器发送请求，如果DHCP服务器响应，则客户端会使用该服务器提供的地址更新现有的租约。如果没有收到DHCP服务器的响应的话，则无法使用现有的地址。

##中继代理
由于DHCP服务器和DHCP客户端之间的通信都是通过广播的形式，因此客户端和服务器之间必须在同一网段，如果不再同一网段的话，则必须要通过DHCP中继代理将DHCP客户端广播发送的数据包以单播的形式发送到DHCP服务器，同时将DHCP服务器单播产生的数据包以广播的形式转发给DHCP客户端。 
注意：静态分配的地址优先于先到的DHCP Offer提供的地址。


#DHCP的安装和配置
##DHCP的安装和相关文件说明
```bash
CentOS系列：
[root@control ~]# yum install -y dhcp

Ubuntu系列：
felix@u01:~$ sudo apt-get install -y isc-dhcp-server

服务启动：sudo /etc/init.d/isc-dhcp-server restart

```
```text
DHCP相关的配置文件：
[root@vm1 ~]# rpm -qc dhcp
/etc/dhcp/dhcpd.conf                  #ipv4的配置文件
/etc/dhcp/dhcpd6.conf                 #ipv66的配置文件
/etc/sysconfig/dhcpd                  #ipv4的dhcpd启动脚本的配置文件
/etc/sysconfig/dhcpd6                 #ipv6的dhcpd启动脚本的配置文件
/etc/sysconfig/dhcrelay               #dhcp relay的配置文件
/var/lib/dhcpd/dhcpd.leases           #ipv4的租约文件
/var/lib/dhcpd/dhcpd6.leases          #ipv6的租约文件
[root@vm1 ~]# 
```


##DHCP的配置
###语法格式
```text
A.以#开头的表示注释
B.对大小写不敏感。
C.每一行必须以分号（;）结束。
D.选项必须用option关键字。
```

###配置选项和参数
```text

声明的语法格式：
声明 {
    参数或选项;
}

常用声明
shared-network <nanme> {  }：定义一个超级作用域，可以配置多个subnet。
subnet <network> netmask <mask> {  }：定义作用域。
range <start-ip> <end-ip>：定义分配的IP地址范围。可以指定多个range
host <name>：分配固定IP地址。
group { }：为特定范围指定参数。 

常用参数
lease-file-name "/var/lib/dhcpd/dhcpd.leases"：该参数必须出现在配置文件的最顶部。指定DHCP服务器存放租约文件的路径。默认为/var/lib/dhcpd/dhcpd.leases。文件名必须得用引号引起来。
ddns-update-style none|interim|ad-hoc：指定动态DNS更新类型。none：不支持动态DNS更新。interim：DNS交互式更新模式。ad-hoc：特殊的DNS更新模式。
log-facility local7：指定日志等级
ignore client-updates：忽略客户端的更新

#PXE安装系统需要的参数
allow bootp：允许bootp查询。PXE安装操作系统需要配置该参数
allow booting：允许booting查询。PXE安装操作系统需要配置该参数
filename "file"：指定客户端初始化启动时要载入的文件名
next_server：指定提供初始化文件的主机的IP地址。如果没有指定，则默认为DHCP服务器的地址。

#指定租约时间
default-least-time：指定默认租约时间。单位为秒。
max-lease-time：最大租约时间。

#指定监听地址和端口
local-address：指定DHCP服务监听的地址。
local-port：指定DHCP服务监听的端口。默认为67。最好不要修改。

#为客户端分配固定IP地址
hardware <网卡类型> <MAC>：网卡类型通常为Ethernet。为指定MAC分配静态IP地址。
fixed-address <IP Address>：分配的固定IP地址
use-host-decl-names on:如果客户端没有主机名，则使用host声明的名字作为客户端的主机名。

#发送DHCP Offer消息前，是否探测IP地址的可用性
ping-check true|false：如果设置为true，则服务器在发送DHCP Offer消息前，会先发送ICMP ECHO消息探测该IP地址是否可用，等待1s，如果收到回应，则不分配该地址，否则的话，分配该地址。如果设置为false，则不发送ICMP ECHO消息。
ping-timeout：设置ping的超时时间，默认为1s。

常用选项
option subnet-mask <mask>：指定客户端的子网掩码
option routers：指定客户端的网关
option broadcast-address：指定广播地址
option domain-name "domain-name"：指定域名
option domain-name-servers：指定DNS服务器的地址，多个地址之间用逗号隔开
option time-offset -28800：指定时间偏差。客户端的时间与格林威治时间偏移值。单位为秒
option ntp-servers：指定NTP服务器的IP地址
option nis-domain "nis-domain"：指定NIS域名
```

###配置示例
```bash
[root@control ~]# more /etc/dhcp/dhcpd.conf 
ignore client-updates;
ddns-update-style none;

allow bootp;
allow booting;

option domain-name "felix.com";
option domain-name-servers 172.17.100.1, 172.17.100.2;

log-facility local7;

default-lease-time 14400;
max-lease-time 28800;

## 超级作用域配置
shared-network felix {
    subnet 172.17.100.0 netmask 255.255.255.0 {
        range 172.17.100.200 172.17.100.220;
        option routers 172.17.100.250;    
        filename "/pxelinux.0";
        next-server 172.17.100.250;
    }
}

group {
    use-host-decl-names on;
    include "/etc/dhcp/static.conf";
}

[root@control ~]# 


[root@control ~]# more /etc/dhcp/static.conf 
host vm10.felix.com {
    hardware ethernet 00:0C:29:8C:64:B8;
    fixed-address 172.17.100.10;
} 

host ubuntu01 {
    hardware ethernet 00:0c:29:5c:71:14;
    fixed-address 172.17.100.200;
}
[root@control ~]# 


```

###启动服务并设置开机自动启动
```bash
[root@control ~]# /etc/init.d/dhcpd restart
Starting dhcpd:                                            [  OK  ]
[root@control ~]# chkconfig dhcpd on
[root@control ~]# 

```

##DHCP Relay的配置
```bash
1. 配置文件：/etc/sysconfig/dhcrelay 
	参数说明
	INTERFACES="eth0 eth1"：指定接收DHCP消息的接口。多个接口之间用空格隔开.
	DHCPSERVERS="172.17.100.250"：指定DHCP服务器的地址。多个DHCP Server之间用空格隔开.

2. 开启数据包的转发功能
	临时开启：
	echo "1" > /proc/sys/net/ipv4/ip_forward
	
	永久开启：修改配置文件/etc/sysctl.conf
	net.ipv4.ip_forward = 1
	保存退出。使用sysctl –p使配置生效
	
3. 启动dhcrelay服务，并设置开机自动启动
[root@vm1 ~]# /etc/init.d/dhcrelay start
Starting dhcrelay:                                         [  OK  ]
[root@vm1 ~]# 
[root@vm1 ~]# chkconfig --level 35 dhcrelay on

```


#DHCP Load Balance

说明：
Primary Server: 172.17.100.240
Secondary Server: 172.17.100.241

## Primary Server的配置
```bash
# Primary Server Config
cat >> /etc/dhcp/dhcpd.conf << EOF
failover peer "dhcp_fo" {
	primary;
	address 172.17.100.240;
	port 647;
	peer address 172.17.100.241;
	peer port 647;
	max-response-delay 30;
    max-unacked-updates 10;
    mclt 1800;
    split 128;
    load balance max seconds 3;
}
EOF
# mclt: Maximum Client Lead Time, must be defined on the primary. it must not be defined on secondary 
# split" (or its alternate, "hba") is another parameter that should be defined on the primary and omitted from the configuration on the secondary. 
```

## Secondary Server的配置
```bash
cat >> /etc/dhcp/dhcpd.conf << EOF
failover peer "dhcp_fo" {
	secondary;
	address 172.17.100.241;
	port 647;
	peer address 172.17.100.240;
	peer port 647;
	max-response-delay 30;
    max-unacked-updates 10;
    load balance max seconds 3;
}
EOF
```
##Primary和Secondary配置IP Pool
``` 
# Create ip pool , put it in any declaration (network/shared-network).
# define it on primary and secondary
shared-network felix {
	subnet 172.17.100.0 netmask 255.255.255.0 {
		option domain-name-servers 172.17.100.242, 172.17.100.243;
		option domain-name "frame.com";
		option routers 172.17.100.1;
		option broadcast-address 172.17.100.255;
		default-lease-time 3600;
		max-lease-time 7200;
		}
		pool {
			failover peer "dhcp_fo";
 			range 172.17.100.100 172.17.100.150;
		};
}
```

##配置OMAPI和Secret Key（Option）

###产生secret key的工具
```bash
# generate key (Option)
dnssec-keygen -a HMAC-MD5 -b 128 -n USER DHCP_OMAPI
```

###Primary和Secondary都需要配置
```bash
####################################### OPTION ###########################################
# Configure OMAPI and define a secret key
# insert this (with your own key text substituted) into dhcpd.conf on primary and secondary.

omapi-port 7911;
omapi-key omapi_key;
key omapi_key {
     algorithm hmac-md5;
     secret Ofakekeyfakekeyfakekey==;
}

##########################################################################################
```


#Linux客户端的配置
```
编辑网卡配置文件：/etc/sysconfig/network-scripts/ifconfig-eth0
BOOTPROTO=dhcp
PEERDNS=yes

BOOTPROTO：设置引导协议为DHCP。手动指定IP地址为none或者是static
PEERDNS：yes或者是no。yes表示允许修改/etc/resolv.conf里面定义的DNS，如果使用DHCP服务器，则yes是默认设置。no表示不允许修改/etc/resolv.conf里面的配置。


网卡配置文件说明：/etc/sysconfig/network-scripts/ifconfig-eth0
DEVICE：指定设备名称。
BOOTPROTO：指定引导协议
BROADCAST：指定广播地址
HWADDR：指定网卡MAC地址
IPADDR：指定IP地址
NETMASK：指定子网掩码
NETWORK：指定网络号
ONBOOT：是否开机自动启动
USERCTL：是否允许普通用户控制网卡
IPV6INIT：是否启动IPV6
TYPE：指定网卡类型，通常为Ethernet
DNS1：设置第一个DNS地址
DNS2：设置第二个DNS地址
DNS3：设置第三个DNS地址

#网卡绑定设置的选项
MASTER=bond0：指定master网卡为bond0
SLAVE=yes：指定该网卡是否为SLAVE
BONDING_OPTIONS="mode=1 miimon=100"：指定MASTER网卡的绑定参数
```