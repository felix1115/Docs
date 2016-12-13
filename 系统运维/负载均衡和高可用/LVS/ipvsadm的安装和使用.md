# ipvsadm的安装
## 查看当前系统的内核是否支持ipvs
```
使用modprobe -l | grep ipvs，如果有输出，则当前内核已经支持了ipvs，否则需要重新编译内核。

[root@vm05 ~]# modprobe -l | grep ipvs
kernel/net/netfilter/ipvs/ip_vs.ko
kernel/net/netfilter/ipvs/ip_vs_rr.ko
kernel/net/netfilter/ipvs/ip_vs_wrr.ko
kernel/net/netfilter/ipvs/ip_vs_lc.ko
kernel/net/netfilter/ipvs/ip_vs_wlc.ko
kernel/net/netfilter/ipvs/ip_vs_lblc.ko
kernel/net/netfilter/ipvs/ip_vs_lblcr.ko
kernel/net/netfilter/ipvs/ip_vs_dh.ko
kernel/net/netfilter/ipvs/ip_vs_sh.ko
kernel/net/netfilter/ipvs/ip_vs_sed.ko
kernel/net/netfilter/ipvs/ip_vs_nq.ko
kernel/net/netfilter/ipvs/ip_vs_ftp.ko
kernel/net/netfilter/ipvs/ip_vs_pe_sip.ko
[root@vm05 ~]#
```

## rpm包安装
```
[root@vm05 ~]# yum install -y ipvsadm

[root@vm05 ~]# rpm -q ipvsadm
ipvsadm-1.26-4.el6.x86_64
[root@vm05 ~]#
```

## 源码包安装
```
[root@vm05 ipvsadm-1.26]# yum install -y gcc gcc-c++ libnl* popt* 
[root@vm05 ~]# tar -zxf ipvsadm-1.26.tar.gz
[root@vm05 ~]# cd ipvsadm-1.26
[root@vm05 ipvsadm-1.26]# make
[root@vm05 ipvsadm-1.26]# make install
```

# ipvsadm的使用
* 用法
```
ipvsadm -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine]
ipvsadm -D -t|u|f service-address
ipvsadm -C
ipvsadm -R
ipvsadm -S [-n]
ipvsadm -a|e -t|u|f service-address -r server-address [options]
ipvsadm -d -t|u|f service-address -r server-address
ipvsadm -L|l [options]
ipvsadm -Z [-t|u|f service-address]
ipvsadm --set tcp tcpfin udp
ipvsadm --start-daemon state [--mcast-interface interface] [--syncid sid]
ipvsadm --stop-daemon state
ipvsadm -h
```

* 具体命令
```
-A：添加虚拟服务器。
-D：删除虚拟服务器。
-E：编辑虚拟服务器。
-C：清楚所有虚拟服务器。
-R：从备份文件恢复虚拟服务器。
-S：将虚拟服务器保存到文件。
-L：显示虚拟服务器列表。
-Z：将虚拟服务器的计数器清零。

--set tcp tcpfin udp：设置连接超时时间。
--timeout：显示tcp、tcpfin、udp的timeout值。

--start-daemon：启动同步守护进程。可以跟上master或backup，用来说明LVS Router是master还是backup，该功能可以用keepalived来实现。
--stop-daemon：停止同步守护进程。
--daemon：显示同步守护进程的状态。
--mcast-interface：指定sync daemon发送组播消息的接口，或者是sync backup daemon监听组播的接口。

-c：显示LVS目前的连接。
--rate：显示速率信息。
-n：不进行地址转换，以数字形式显示。
--stats：显示统计信息。

-x：指定服务器连接数的上限阀值。范围0-65535，如果为0则没有上限，如果为该范围内的其他值，则超过该值后，将不会有请求发送到该服务器。
-y：指定重新发送请求到该服务器时的下限值。范围是0-65535，如果是0，则没有设置下限阀值。当服务器释放的连接数小于该下限值时，该服务器将会接收新的连接。如果没有设置下限，但是设置了上限，则当连接释放掉上限的四分之三时，该服务器将会接收新的请求。

-t：虚拟服务器提供的是TCP服务。
-u：虚拟服务器提供的是UDP服务。
-f：经过iptables标记过的服务。
-s：使用的调度算法。如：rr、wrr、lc、wlc等。默认的是wlc。
-p：持久性连接。这个选项的意思是来自同一个客户的多次请求，将被同一台真实的服务器处理。timeout 的默认值为300 秒。在SSL和FTP时，该选项比较重要。在处理FTP连接时，如果采用的是TUN和DR模式，则该选项必须使用，如果使用的是NAT模式，则该选项不是必须的，但是必须手动的载入ip_vs_ftp模块。
-M：持久性连接的颗粒度。

-r：real server。
-w：reasl server的权重。

-g：工作模式为Direct Routing(LVS-DR)
-i：工作模式为LVS-TUN
-m：工作模式为LVS-NAT
```

# ipvs规则的备份和恢复
* 备份
```
方法1：使用ipvsadm脚本
[root@vm05 ~]# ipvsadm -A -t 172.17.100.100:80 -s rr
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.1:80 -g
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.2:80 -g
[root@vm05 ~]# /etc/init.d/ipvsadm save
ipvsadm: Saving IPVS table to /etc/sysconfig/ipvsadm:      [确定]
[root@vm05 ~]#

方法2：使用ipvsadm-save或ipvsadm -S -n
[root@vm05 ~]# ipvsadm-save -n > /tmp/test.ipvsadm
[root@vm05 ~]# more /tmp/test.ipvsadm
-A -t 172.17.100.100:80 -s rr
-a -t 172.17.100.100:80 -r 172.17.100.1:80 -g -w 1
-a -t 172.17.100.100:80 -r 172.17.100.2:80 -g -w 1
[root@vm05 ~]#

```

* 恢复
```
方法1：使用ipvsadm-restore 或 ipvsadm -R
[root@vm05 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
[root@vm05 ~]# ipvsadm-restore < /tmp/test.ipvsadm
[root@vm05 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.100.100:80 rr
  -> 172.17.100.1:80              Route   1      0          0
  -> 172.17.100.2:80              Route   1      0          0
[root@vm05 ~]#

```