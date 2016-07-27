[TOC]
#NTP的安装和配置
## 安装NTP
```bash
[root@control ~]# yum install -y ntp
```
##配置NTP
### 配置文件语法格式和参数说明
```text
主配置文件：/etc/ntp.conf

配置文件参数描述：
restrict：指定哪些客户端可以进行NTP对时。
	格式：restrict <ip_address|CIDR> mask <netmask> <参数>
	参数如下：
	ignore：忽略任何客户端的时间同步请求，不对外提供任何时间同步功能。
	nomodify：表示客户端不能修改NTP服务器的时间参数，但是客户端可以进行时间同步。
	noquery：不对客户端提供时间查询功能。但是可以进行时间同步。也就是客户端不能用ntpdc进行时间查询。
	notrap：不提供trap远程事件记录功能。
	notrust：拒绝没有通过认证的客户端
	kod：开启kod功能。kod是kiss of death（一种dos攻击），开启kod功能，可以防止对服务器的破坏。
	nopeer：不与其他同一层上的NTP服务器进行时间同步。
	如：
	restrict 172.17.100.0 mask 255.255.255.0 nomodify notrap kod nopeer 
	restrict default：default表示所有的主机。
server <ip|fqdn> [prefer]：指定为本地服务器提供时间的上层NTP服务器的IP地址或者是FQDN。在指定多个上层NTP服务器时，使用prefer参数的服务器的优先级更高，将优先使用。如果没有指定prefer的话，则按照顺序从上往下，由高到低。如果要以本地的时间作为时间源的话，则是server 127.127.1.0

fudge <ip|fqdn> stratum <1-15>：修改NTP服务器的stratum信息。如果stratum为16就认为该NTP服务器不可用。

driftfile <filename>：记录本地时间和上层NTP服务器之间的时间差值，该文件对于ntp用户来说要有w的权限。一般不需要修改.

logfile <log_file>：指定日志文件存放的位置。

pidfile <pid>: 指定pid文件存放的路径。默认为/var/run/ntp.pid
```

### 配置示例
```bash
[root@control ~]# cat /etc/ntp.conf
# ntp.conf

driftfile /var/lib/ntp/drift
pidfile   /var/run/ntp.pid
logfile   /var/log/ntp.log

## access contorl
restrict    default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1 

restrict 172.17.100.0 mask 255.255.255.0 nomodify notrap kod nopeer

## Local NTP Server
## 使用本地的机器的时间源,minpoll表示客户端最小同步间隔，maxpoll表示最大同步间隔。4和10表示的是2的4次方和2的10次方。
server 127.127.1.0 iburst minpoll 4 maxpoll 10
fudge 127.127.1.0 stratum 10
[root@control ~]# 

```

###启动服务并设置开机自动启动
```bash
[root@control ~]# /etc/init.d/ntpd restart
Shutting down ntpd:                                        [  OK  ]
Starting ntpd:                                             [  OK  ]
[root@control ~]# chkconfig ntpd on
[root@control ~]# 
```

###查看NTP服务器的相关信息
```bash
命令： ntp -p

[root@control ~]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
*LOCAL(0)        .LOCL.          10 l   16   16  177    0.000    0.000   0.000
[root@control ~]# 

*：表示当前正在使用的。
+：表示候选的，备用的。

ntp -q参数说明：
remote：NTP服务器的地址。
refid：给该NTP服务器提供时间的上层NTP服务器地址。
st：当前NTP服务器的Stratum。如果显示的值是16，则表示当前NTP服务器不可用。
t：表示ntp server的类型。有4种：b（broadcast），u（unicast），l（local）、m（multicast）
when：最近一次与NTP服务器进行时间同步已经过去了多长时间。
poll：多长时间进行一次同步。可以通过minpoll和maxpoll进行修改。minpoll和maxpoll后面的数值为2的多少次方，minpoll默认为6，maxpoll默认为10.
reach：一个8进制，已经成功同步的次数。
offset：时间补偿值。越小越好。
```

#客户端的配置
## Linux客户端的配置
```bash
方法1：使用ntpdate命令手动同步
ntpdate <ntp-server>

[root@vm2 ~]# ntpdate 172.17.100.250
11 Nov 15:46:42 ntpdate[1108]: step time server 172.17.100.250 offset -577.775185 sec
[root@vm2 ~]# 

方法2：计划任务
#创建一个计划任务
crontab -e
#添加一个计划
*/5 * * * * /usr/sbin/ntpdate 172.17.100.250 && hwclock -w

方法3：修改ntp.conf
server 172.17.100.250 minpoll 4 maxpoll 10 iburst
## 不允许172.17.100.250（ntp服务器）向客户端进行时间同步
restrict 172.17.100.250 mask 255.255.255.255 nomodify notrap noquery nopeer
```


##Windows客户端的配置
```text
默认情况下，windows客户端是每隔7天与服务器进行时间同步，如果要修改这个时间间隔，需要修改注册表。
windows打开注册表的方法：开始-->运行--> regedit
找到如下部分：
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControl Set\Services\W32Time
TimeProvides\NtpClient\SpecialPollInterval，在”数值数据”，中显示的就是时间同步间隔，单位为秒，修改以后，需要重启系统。
```


#和时间相关的文件
```text
/usr/share/zoneinfo/：在该目录下的文件主要定义了各个时区的时间配置文件。如亚洲/上海的时间配置文件就是：/usr/share/zoneinfo/Asia/Shanghai

/etc/sysconfig/clock：告诉系统应该使用/usr/share/zoneinfo/目录下的哪个时区的时间配置文件。

/etc/localtime：系统通过/etc/sysconfig/clock将/usr/share/zoneinfo/指定的时区的时间配置文件复制为/etc/localtime。
```
```text
修改时区的步骤：
1.查询/usr/share/zoneinfo/目录下要修改的时区的名称
2.将该名称写入到/etc/sysconfig/clock文件中
3.复制/usr/share/zoneinof/目录下的时区的时间配置文件为/etc/localtime
4.重启系统。
[root@vm1 ~]# more /etc/sysconfig/clock 
ZONE="Asia/Shanghai"
[root@vm1 ~]# 
```
```text
为每一个用户设置单独的时区
cat >> ~/.bashrc << EOF
export TZ="/usr/share/zoneinfo/Asia/Shanghai"
EOF
```