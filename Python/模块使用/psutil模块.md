# psutil模块
* 说明
```
psutil模块用于获取系统的CPU/Memory/Disk/Network以及进程等相关的信息，主要用于系统监控。

需要使用：pip install psuitl或者是python setup.py install
```

# CPU
* 获取物理CPU和逻辑CPU的个数
```
import psutil
physical_cpu = psutil.cpu_count(logical=False)
logical_cpu = psutil.cpu_count(logical=True)

print 'Physical cpu: %s' % physical_cpu
print 'Logical cpu: %s' % logical_cpu

示例：
➜  ~ python test.py
Physical cpu: 2
Logical cpu: 4
```

* 获取CPU利用率
```
用法：psutil.cpu_percent(interval=None, percpu=False)
说明：如果没有指定interval，则会比较在该interval之前和之后消逝的CPU时间。

注意：当interval为0或者是None，则会比较上一次模块调用或者是模块导入所消逝的CPU时间。如果是第一次使用，则会返回0.0，这个值是没有意义的，需要忽略掉。

示例1：
In [38]: psutil.cpu_percent(interval=1)
Out[38]: 1.0

In [39]: psutil.cpu_percent(interval=1)
Out[39]: 0.0

In [40]:

示例2：
In [40]: psutil.cpu_percent(interval=1, percpu=True)
Out[40]: [0.0]

In [41]: psutil.cpu_percent(interval=1, percpu=True)
Out[41]: [0.0]

In [42]:

示例3：
In [42]: for i in range(3):
    ...:     print psutil.cpu_percent(interval=1)
    ...:
2.0
0.0
0.0

In [43]:

```

# Memory
* 查看内存的统计
```
说明：psutil.virtual_memory()的输出是命名元组。单位是：字节
In [50]: psutil.virtual_memory()
Out[50]: svmem(total=497672192, available=299352064, percent=39.8, used=187064320, free=197222400, active=149319680, inactive=74915840, buffers=12271616, cached=101113856, shared=249856)

In [51]:

说明：主要的指标
total：总的物理内存。
available：不需要交换到swap中，可以立即分配给应用程序使用的内存。这部分看到的应该是系统里面的total - free + buffer + cache

其他指标：
used：表示已经使用的内存。包括操作系统使用的内存，也包括应用程序使用的内存，也包括缓存部分。
free：表示的是操作系统还没有使用的内存。

linux计算方式为：total-free = used

```

* 获取内存的总量、使用量、剩余量以及使用率等
```
ONE_M = 1 * 1024 * 1024
mem = psutil.virtual_memory()
total_memory = mem.total / ONE_M
used_memory = (mem.total - mem.free) / ONE_M
free_memory = mem.free / ONE_M
available_memory = mem.available / ONE_M
memory_percent = mem.percent

print "Total Memory: %sM" % total_memory
print "Used Memory: %sM" % used_memory
print "Free Memory: %sM" % free_memory
print "Available Memory: %sM" % available_memory
print "Memory Percent: %.1f%%" % memory_percent
```

* swap
```
ONE_M = 1 * 1024 * 1024 # 1MB
swap = psutil.swap_memory()

total_swap = swap.total / ONE_M
used_swap = swap.used / ONE_M
free_swap = swap.free / ONE_M
swap_percent = swap.percent

print "Total swap: %sM" % total_swap
print "Used swap: %sM" % used_swap
print "Free swap: %sM" % free_swap
print "swap Percent: %.1f%%" % swap_percent

输出：
Total swap: 4095M
Used swap: 0M
Free swap: 4095M
swap Percent: 0.0%
```

# Disk
* 获取所有磁盘分区
```
import psutil

disk_part = psutil.disk_partitions()

print ' disk info '.center(60, '*')
for disk in disk_part:
    print "Device: %s\tMountPoint: %s\tfstype: %s" % (disk.device, disk.mountpoint, disk.fstype)

print '*' * 60

输出：
[root@vm01 psutil]# ./disk.py
************************ disk info *************************
Device: /dev/sda3   MountPoint: /   fstype: ext4
Device: /dev/sda1   MountPoint: /boot   fstype: ext4
************************************************************
[root@vm01 psutil]#
```

* 模拟df -h
```
#!/bin/env python2.7
# coding: utf-8
# Author: felix
# E-mail: 573713035@qq.com
# Version: 1.0

import psutil

def bytes2human(n):
    symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
    prefix = {}

    for i, s in enumerate(symbols, 1):
        prefix[s] = 1 << (i * 10)

    for s in reversed(symbols):
        if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)
    return '%sB' % n


output_format = "%-17s %8s %8s %8s %5s%% %9s  %s"
print output_format % ("Device", "Total", "Used", "Free", "Use", "Type", "Mount On")

disk_part = psutil.disk_partitions(all=True)

for part in disk_part:
    usage = psutil.disk_usage(part.mountpoint)
    if not part.device or not usage.total:
        continue

    print output_format % (
                        part.device,
                        bytes2human(usage.total),
                        bytes2human(usage.used),
                        bytes2human(usage.free),
                        int(usage.percent),
                        part.fstype,
                        part.mountpoint )

输出示例：
[root@vm01 psutil]# ./disk.py
Device               Total     Used     Free   Use%      Type  Mount On
/dev/sda3            15.4G     7.8G     6.8G    53%      ext4  /
tmpfs               237.3M       0B   237.3M     0%     tmpfs  /dev/shm
/dev/sda1           189.7M    30.0M   149.7M    16%      ext4  /boot
[root@vm01 psutil]#x`
```

# User
* 模拟who
```
#/bin/env python
#coding: utf-8

import psutil
import time


def who():
    output_format = '%-8s %-10s %-20s %-15s'
    print output_format % ("User", "Terminal", "Login Time", "Host")

    users = psutil.users()

    for u in users:
        print output_format % (
            u.name,
            u.terminal,
            time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(u.started)),
            u.host
        )


if __name__ == '__main__':
    who()


输出：
[root@vm01 psutil]# ./who.py
User     Terminal   Login Time           Host
root     pts/0      2016-12-09 09:16:48  172.17.100.254
root     pts/1      2016-12-09 09:16:48  172.17.100.254
root     pts/2      2016-12-09 10:31:28  172.17.100.254
[root@vm01 psutil]#
```

# Network
* 获取接口的IP地址和MAC地址
```
#!/usr/bin/env python
# coding: utf-8

import psutil
import socket

af_net = {
    socket.AF_INET: 'IPv4',
    socket.AF_INET6: 'IPv6',
    psutil.AF_LINK: 'MAC'
}


def interface_info(interface):
    interface_dict = psutil.net_if_addrs()
    for addr in interface_dict[interface]:
        if af_net.get(addr.family) == 'IPv4':
            print "\t%-12s: %s" % ('IPv4 Address', addr.address)
            print "\t%-12s: %s" % ('IPv4 Netmask', addr.netmask)
        elif af_net.get(addr.family) == 'MAC':
            print "\t%-12s: %s" % ('MAC Address', addr.address)


if __name__ == '__main__':
    for interface in psutil.net_if_addrs():
        print '%s:' % interface
        interface_info(interface)
        print


执行结果：
[root@vm01 psutil]# ./ifconfig.py
lo:
    IPv4 Address: 127.0.0.1
    IPv4 Netmask: 255.0.0.0
    MAC Address : 00:00:00:00:00:00

eth0:1:
    IPv4 Address: 172.17.100.200
    IPv4 Netmask: 255.255.255.128

eth0:
    IPv4 Address: 172.17.100.1
    IPv4 Netmask: 255.255.255.0
    MAC Address : 00:0c:29:e9:ec:d0

[root@vm01 psutil]#
```