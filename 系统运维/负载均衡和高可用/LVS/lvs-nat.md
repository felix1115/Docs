# LVS-NAT
* 拓扑图
![LVS-NAT](https://github.com/felix1115/Docs/blob/master/Images/lvs01.png)

备注：VIP为172.17.100.100

* 防火墙配置
```
[root@fw ~]# iptables -t nat -A PREROUTING -i eth1 -p tcp -d 192.168.100.253 --dport 80 -j DNAT --to-dest 172.17.100.100:80
[root@fw ~]#
[root@fw ~]# cat /proc/sys/net/ipv4/ip_forward
1
[root@fw ~]#
```

* LVS-NAT配置
```
1. 开启ip_forward
[root@vm05 ~]# cat /proc/sys/net/ipv4/ip_forward
1
[root@vm05 ~]#

2. 配置ipvsadm规则
[root@vm05 ~]# ipvsadm -A -t 172.17.100.100:80 -s rr
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.1:80 -m
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.2:80 -m
[root@vm05 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.100.100:80 rr
  -> 172.17.100.1:80              Masq    1      0          0
  -> 172.17.100.2:80              Masq    1      0          0
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

* RS01和RS02的配置
```
1. RS的网关要指向VIP

[root@vm01 bind]# route add default gw 172.17.100.100
[root@vm01 bind]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
172.17.100.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         172.17.100.100  0.0.0.0         UG    0      0        0 eth0
[root@vm01 bind]#

```


* 测试
```
1. 客户端访问192.168.100.253，经过防火墙会转换成172.17.100.100(VIP)
[root@vm11 ~]# curl http://192.168.100.253/
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 01</h1>
[root@vm11 ~]# curl http://192.168.100.253/
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 02</h1>
[root@vm11 ~]# curl http://192.168.100.253/
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 01</h1>
[root@vm11 ~]# curl http://192.168.100.253/
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 02</h1>
[root@vm11 ~]#
```

# 同一网段做LVS-NAT
* 说明
```
同一网段：指的是客户端和VIP处于同一网段。

正常情况下，客户端和VIP不能处于同一网段。

在同一网段时，LVS会发送ICMP Redirect，需要在LVS端抑制发送重定向。并且RS端需要删除网络路由，使其走LVS转发流量。
```

* LVS-NAT配置
```
1. 开启ip_forward
[root@vm05 ~]# cat /proc/sys/net/ipv4/ip_forward
1
[root@vm05 ~]#

2. 配置ipvsadm规则
[root@vm05 ~]# ipvsadm -A -t 172.17.100.100:80 -s rr
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.1:80 -m
[root@vm05 ~]# ipvsadm -a -t 172.17.100.100:80 -r 172.17.100.2:80 -m
[root@vm05 ~]# ipvsadm -L -n
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.100.100:80 rr
  -> 172.17.100.1:80              Masq    1      0          0
  -> 172.17.100.2:80              Masq    1      0          0
[root@vm05 ~]#

3. 增加VIP
[root@vm05 ~]#
[root@vm05 ~]# ifconfig eth0:1 172.17.100.100 netmask 255.255.255.0 up
[root@vm05 ~]# ifconfig eth0:1
eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:95:75:79
          inet addr:172.17.100.100  Bcast:172.17.100.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

[root@vm05 ~]#

4. 关闭ICMP Redirect
4.1 查看默认值
[root@vm05 ~]# more /proc/sys/net/ipv4/conf/{all,default,eth0}/send_redirects
::::::::::::::
/proc/sys/net/ipv4/conf/all/send_redirects
::::::::::::::
1
::::::::::::::
/proc/sys/net/ipv4/conf/default/send_redirects
::::::::::::::
1
::::::::::::::
/proc/sys/net/ipv4/conf/eth0/send_redirects
::::::::::::::
1
[root@vm05 ~]#

4.2 关闭重定向
[root@vm05 ~]# echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
[root@vm05 ~]# echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
[root@vm05 ~]# echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
[root@vm05 ~]#
```

* RS端配置
```
1. 删除同网段的网络路由
[root@vm01 conf]# route del -net 172.17.100.0 netmask 255.255.255.0 dev eth0
[root@vm01 conf]#
[root@vm01 conf]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         172.17.100.100  0.0.0.0         UG    0      0        0 eth0
[root@vm01 conf]#
```

* 测试
```
[root@vm09 ~]# curl http://172.17.100.100
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 01</h1>
[root@vm09 ~]# curl http://172.17.100.100
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 02</h1>
[root@vm09 ~]# curl http://172.17.100.100
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 01</h1>
[root@vm09 ~]# curl http://172.17.100.100
<h1>Welcome to nginx!</h1>
<h1>Nginx Backend Server 02</h1>
[root@vm09 ~]#
```