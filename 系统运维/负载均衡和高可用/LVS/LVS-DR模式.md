# LVS-DR模式需要解决的问题
* 说明

> 在LVS DR和TUN模式下，用户的访问请求到达RS后，RS将处理结果直接返回给客户端，不经过前端的Director Server因此每一个RS上就需要有VIP的地址，这样数据才能够直接返回给客户端。
> 
> 通常情况下，是在lo:0口配置VIP的地址。
> 
> 在LVS-DR模式下，Director将请求发送到RS的过程中，数据包的源IP地址和目标IP地址都没有发生改变，Director仅仅是将目标MAC地址修改为选中的RS的MAC地址，源MAC地址改为Director内网网卡的MAC地址。
> 

* ARP原理

>ARP称为地址解析协议，根据IP地址获取对应的MAC地址。
>
>在以太网中，主机要发送一个数据包，首先需要获取目标主机的MAC地址(如果两台主机在同一网段，则目标MAC地址就是目标主机的MAC地址，否则就是网关或下一跳的MAC地址)，而获取MAC地址就是通过ARP协议来完成的。获取MAC地址是通过发送ARP请求来完成的。
>
>ARP请求：在该数据包中，包含有发送方的IP地址和发送方的MAC地址以及目标的IP地址，由于不知道目标的MAC地址，所有目标MAC地址这一块是00:00:00:00:00:00，并且使用广播发送。因此在同一个网段中的所有主机都会收到该请求。
>
>ARP响应：具有ARP请求中的目标IP地址的主机，将会发送ARP响应数据包对ARP请求进行回应，在ARP响应数据包中包含有发送发的IP地址、MAC地址，目标方的IP地址和MAC地址，以单播的方式发送。
>
>
>在发送ARP请求时，需要包含发送方的IP地址，这个IP地址是什么呢？
>1. 如果主机只有一个IP地址，则发送方的IP地址为要发送的IP数据包中的源IP地址。
>2. 如果主机有多个接口和IP地址的话，则发送方的地址则不一定是要发送的IP数据包中的源IP地址。在Linux系统中，可以通过arp_announce进行控制。
>
>arp_announce就是控制发送方IP地址的选择条件的。
>
>
>
>
>




* 需要解决的问题
1. RS要避免客户端发来的对VIP的ARP请求进行响应
```
修改2个内核参数：arp_announce和arp_ignore

arp_announce：定义Linux主机在发送ARP请求时，如果选择数据包中使用的发送方IP地址。
arp_announce就是控制发送方IP地址的选择条件的。
arp_announce有3个值，分别是0、1、2。
0：默认值，允许使用任意网络接口配置的IP地址(即任一本地地址)，通常就是待发送的IP数据包的源IP地址。
1：尽量避免使用不属于该网络接口(即发送数据包的网络接口)子网的本地地址作为发送方的IP地址。
2：忽略IP数据包的源IP地址，总是选择网口所配置的最合适的IP地址作为ARP请求数据包的发送方IP地址

arp_ignore：定义Linux主机在收到ARP请求后，发送ARP响应数据包的条件级别。取值范围是0-8。
0：默认值，只要ARP请求数据包所请求的IP地址属于任一本机地址，就会回应ARP响应，即使该IP地址不属于接收到ARP请求数据包的网卡。
1：只有ARP请求数据包所请求的IP地址属于当前网卡的IP地址，才会发送ARP响应。
2：除了满足1的条件外，还要满足ARP请求数据包的发送方IP地址也属于当前网卡所属子网，这样才会发送ARP响应。
3：如果ARP请求数据包所请求的IP地址对应的本地地址其作用域(scope)为主机(host)，则不回应ARP响应数据包，如果作用域为全局(global)或链路(link)，则回应ARP响应数据包。
4-7：保留。
8：即使ARP请求数据包所请求的IP地址属于任何一个本地地址，也不回应ARP响应数据包。
```

* arp_announce和arp_ignore
```
Real Server修改内核参数

临时生效：
echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce 
echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce 

临时生效：
sysctl –w net.ipv4.conf.lo.arp_announce=2
sysctl –w net.ipv4.conf.all.arp_announce=2
sysctl –w net.ipv4.conf.lo.arp_ignore=1
sysctl –w net.ipv4.conf.all.arp_ignore=1


永久生效：
vim /etc/sysctl.conf
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
然后执行，sysctl –p
```

# LVS-DR模式配置
* 拓扑图

![LVS-DR](https://github.com/felix1115/Docs/blob/master/Images/lvs02.png)

* 防火墙配置
```
1. 作用：将所有去往192.168.100.253的80端口都转换成VIP(172.17.100.100)的80端口。
2. 对防火墙开启数据包转发功能。

[root@fw ~]# iptables -t nat -A PREROUTING -i eth1 -p tcp -d 192.168.100.253 --dport 80 -j DNAT --to-dest 172.17.100.100:80
[root@fw ~]#
[root@fw ~]# cat /proc/sys/net/ipv4/ip_forward
1
[root@fw ~]#
```

* LVS-DR模式配置
```
1. 开启ip_forward
[root@vm05 ~]# cat /proc/sys/net/ipv4/ip_forward
1
[root@vm05 ~]#

2. 配置ipvsadm规则
[root@vm05 ~]# ipvsadm -A -t 172.17.100.100:80 -s rr
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.1:80 -g
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.2:80 -g
[root@vm05 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.100.100:80 rr
  -> 172.17.100.1:80              Route   1      0          0
  -> 172.17.100.2:80              Route   1      0          0
[root@vm05 ~]#

3. 增加VIP
[root@vm05 ~]#
[root@vm05 ~]# ifconfig eth0:1 172.17.100.100 netmask 255.255.255.0 up
[root@vm05 ~]# ifconfig eth0:1
eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:95:75:79
          inet addr:172.17.100.100  Bcast:172.17.100.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

[root@vm05 ~]#

```

* RS配置
```
1. RS的网关为实际网关，不需要指向VIP
[root@vm01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
172.17.100.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         172.17.100.253  0.0.0.0         UG    0      0        0 eth0
[root@vm01 ~]#

2. RS在lo:0接口配置VIP地址
[root@vm01 ~]# ifconfig lo:0 172.17.100.100 netmask 255.255.255.255 broadcast 172.17.100.100 up
[root@vm01 ~]#

[root@vm02 ~]# ifconfig lo:0 172.17.100.100 netmask 255.255.255.255 broadcast 172.17.100.100 up
[root@vm02 ~]#

3. RS端配置arp_anonounce和arp_ignore
[root@vm01 ~]# echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
[root@vm01 ~]# echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
[root@vm01 ~]# echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
[root@vm01 ~]# echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
[root@vm01 ~]#
```

* 测试
```
[root@vm11 ~]# host www.felix.com
www.felix.com has address 192.168.100.253
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 02</h1>
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 01</h1>
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 02</h1>
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 01</h1>
[root@vm11 ~]#
```