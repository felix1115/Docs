# Linux服务器VLAN配置
* 加载模块
```
[root@vm11 ~]# modprobe 8021q
[root@vm11 ~]# lsmod | grep 8021q
8021q                  20362  0
garp                    7152  1 8021q
[root@vm11 ~]#
```

## vconfig命令的使用
* vconfig set_name_type
```
作用：设置VLAN显示类型。VLAN ID范围是0--4095
参数如下：
VLAN_PLUS_VID: 显示为vlan 加上 vlan id。用零填充。如vlan0005
VLAN_PLUS_VID_NO_PAD: 显示为vlan 加上 vlan id。不用零填充。如vlan5
DEV_PLUS_VID: 显示为"设备名.vlan id"。用零填充。如eth0.0005
DEV_PLUS_VID_NO_PAD: 显示为"设备名.vlan id"。不用零填充。如eth0.5
```

* 创建一个VLAN
```
语法：vconfig add [interface-name] [vlan_id]
说明：interface-name物理网卡名称。vlan_id表示VLAN号
注意：主接口配置的IP地址属于本征VLAN，不打Tag。

示例：
[root@vm11 ~]# vconfig add eth0 10
Added VLAN with VID == 10 to IF -:eth0:-
[root@vm11 ~]# ifconfig vlan10 192.168.100.10 netmask 255.255.255.0 up
[root@vm11 ~]# ifconfig vlan10
vlan10    Link encap:Ethernet  HWaddr 00:0C:29:91:84:29
          inet addr:192.168.100.10  Bcast:192.168.100.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe91:8429/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:238 (238.0 b)

[root@vm11 ~]#
```

* 删除一个VLAN
```
语法：vconfig rem [vlan-name]

[root@vm11 ~]# vconfig rem vlan10
Removed VLAN -:vlan10:-
[root@vm11 ~]#
```

* /proc/net/vlan/config
```
说明：该文件存储了所有VLAN的信息。

[root@vm11 ~]# cat /proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_PLUS_VID_NO_PAD
vlan10         | 10  | eth0
vlan20         | 20  | eth0
[root@vm11 ~]#
```

* VLAN永久有效
```
[root@vm11 ~]# cp -a /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
[root@vm11 ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0.10
DEVICE="eth0.10"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR=192.168.100.10
NETMASK=255.255.255.0
VLAN=yes
[root@vm11 ~]#
```