[TOC]

#  NFS的安装和配置
## NFS介绍
>NFS：Network File System网络文件系统。用于Unix-Like操作系统之间进行文件的共享。通过NFS，客户端可以将服务器端共享出来的目录挂载到本地，就像操作本地文件一样。而NFS在启动之前需要向RPC注册，告诉RPC，相应的服务所使用的端口。NFS可以说是RPC服务的一种。NFS通常情况下启动的端口为2049端口，RPC启动的端口为111端口，而NFS如果要想提供其他的服务，则还要启动不同的端口，这些端口都是随机的，如果不向RPC注册的话，客户端将不知道服务所使用的端口。


## NFS的安装
* 所需软件包
rpc主程序：rpcbind
nfs主程序：nfs-utils

* 软件安装
```bash
[root@control ~]# yum install -y rpcbind nfs-utils
```

* 设置开机自动启动
```bash
[root@control ~]# chkconfig rpcbind on
[root@control ~]# chkconfig nfs on
[root@control ~]# chkconfig nfslock on
[root@control ~]# 

```



## NFS的配置
```
NFS的配置文件为：/etc/exports

该文件的语法结构为：
A.以#开头的表示注释
B.大小写敏感
C.语法格式为：
共享目录  客户端1(参数1)  客户端2(参数2) ……


* 共享目录：指定要共享的目录的实际路径。如/opt/test
* 客户端：指定哪些客户端可以访问共享目录。如果不指定则所有的客户端均可以访问。客户端的匹配条件如下：
    1.指定单一主机：如192.168.1.1或者是通过FQDN的方式，如nfs.frame.com
    2.指定网段：如192.168.1.0/255.255.255.0或192.168.1.0/24或192.168.1.*
    3.指定域名范围：如*.felix.com，则表示客户端的DNS后缀为felix.com的都放行。
    4.所有主机：*
    
* 参数：对满足客户端匹配条件的客户端的权限设置。常用的如下：
ro：默认选项，以只读的方式共享。
rw：以读写的方式共享。
root_squash：压缩root用户的权限为NFS的匿名用户（nfsnobody）。
no_root_squash：不压缩root用户的权限。客户端如果使用root用户访问，则映射后的权限依然为root。
all_squash：默认选项，压缩所有用户的权限为nfs匿名用户(nfsnobody)。
anonuid：指定匿名用户的UID
anongid：指定匿名用户的GID
sync：默认选项，保持数据同步，数据写入到硬盘时才提示客户端写入成功。
async：数据没有写入到硬盘时就提示客户端数据写入成功，此时数据还可能存在于内存中。可以提高性能，但是有可能会引起数据丢失。
secure：NFS客户端必须使用NFS保留端口（通常是1024以下的端口），默认选项。
insecure：允许NFS客户端不使用NFS保留端口（通常是1024以上的端口）。
```

## 配置示例
* 配置示例
```bash
[root@control ~]# cat /etc/exports
/data/ftp/vusers/software  172.17.100.0/24(rw,sync,no_root_squash)
[root@control ~]# 
```

* 启动服务（先启动rpcbind，然后是nfs，最后是nfslock）
```bash
[root@control ~]# /etc/init.d/rpcbind restart
Stopping rpcbind:                                          [FAILED]
Starting rpcbind:                                          [  OK  ]
[root@control ~]# /etc/init.d/nfs restart
Shutting down NFS daemon:                                  [FAILED]
Shutting down NFS mountd:                                  [FAILED]
Shutting down RPC idmapd:                                  [FAILED]
Starting NFS services:                                     [  OK  ]
Starting NFS mountd: rpc.mountd: svc_tli_create: could not open connection for udp6
rpc.mountd: svc_tli_create: could not open connection for tcp6
rpc.mountd: svc_tli_create: could not open connection for udp6
rpc.mountd: svc_tli_create: could not open connection for tcp6
rpc.mountd: svc_tli_create: could not open connection for udp6
rpc.mountd: svc_tli_create: could not open connection for tcp6
                                                           [  OK  ]
Starting NFS daemon: rpc.nfsd: address family inet6 not supported by protocol TCP
                                                           [  OK  ]
Starting RPC idmapd:                                       [  OK  ]
[root@control ~]# /etc/init.d/nfslock restart
Stopping NFS locking:                                      [  OK  ]
Stopping NFS statd:                                        [FAILED]
Starting NFS statd:                                        [  OK  ]
[root@control ~]# 

```

* 客户端查看服务器端共享出来的内容，并挂载
客户端可以使用showmount这个命令来查看服务器端的共享目录和权限。（需要安装nfs-utils软件）
```
[root@vm1 ~]# yum install -y nfs-utils

[root@vm1 ~]# showmount -e 172.17.100.250
Export list for 172.17.100.250:
/data/ftp/vusers/software 172.17.100.0/24
[root@vm1 ~]# 

客户端mount，需要使用-t指定文件系统类型为nfs
[root@vm1 ~]# mkdir -p /data/software
[root@vm1 ~]# mount -t nfs 172.17.100.250:/data/ftp/vusers/software /data/software/
[root@vm1 ~]# df -h
Filesystem                                Size  Used Avail Use% Mounted on
/dev/sda3                                  18G  1.1G   16G   7% /
tmpfs                                     116M     0  116M   0% /dev/shm
/dev/sda1                                 194M   27M  158M  15% /boot
172.17.100.250:/data/ftp/vusers/software   18G   13G  4.1G  76% /data/software
[root@vm1 ~]# 

```


# NFS客户端配置
* 手动挂载
```
格式：mount -t nfs server_ip|fqdn:shared_directory mount_to_local_directory

[root@vm1 ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        18G  1.1G   16G   7% /
tmpfs           116M     0  116M   0% /dev/shm
/dev/sda1       194M   27M  158M  15% /boot
[root@vm1 ~]# 
[root@vm1 ~]# mount -t nfs nfs.felix.com:/data/ftp/vusers/software /data/software
[root@vm1 ~]# df -h
Filesystem                               Size  Used Avail Use% Mounted on
/dev/sda3                                 18G  1.1G   16G   7% /
tmpfs                                    116M     0  116M   0% /dev/shm
/dev/sda1                                194M   27M  158M  15% /boot
nfs.felix.com:/data/ftp/vusers/software   18G   13G  4.1G  76% /data/software
[root@vm1 ~]# 

```

* 开机自动挂载
```
etc/fstab的语法格式：

需要挂载的设备或远程文件系统     本地挂载点    文件系统类型    挂载选项    是否需要被dump备份（0表示不需要备份）    是否需要被fsck检查（根文件系统需要设置为1，表示优先检查，其他的可以设置为2或者是0） 
```

```
[root@vm1 ~]# cat /etc/fstab | tail -n 1
nfs.felix.com:/data/ftp/vusers/software /data/software  nfs defaults,_netdev    0 0
[root@vm1 ~]# 

 
设置完之后，需要使用mount -a进行测试，防止出现开机时出现挂载不了的情况。
[root@vm1 ~]# mount -a
[root@vm1 ~]# df -h
Filesystem                               Size  Used Avail Use% Mounted on
/dev/sda3                                 18G  1.1G   16G   7% /
tmpfs                                    116M     0  116M   0% /dev/shm
/dev/sda1                                194M   27M  158M  15% /boot
nfs.felix.com:/data/ftp/vusers/software   18G   13G  4.1G  76% /data/software
[root@vm1 ~]# 
```

* 需要时自动挂载
自动挂载是使用autofs来实现的，当需要使用该目录的时候，系统会自动挂载，在不需要的时候，系统会自动卸载该目录。

```bash
步骤1：安装autofs软件包
[root@vm1 ~]# yum install -y autofs

步骤2：修改/etc/auto.master文件，增加/-  /etc/auto.nfs
修改后的文件内容如下：
[root@vm1 ~]# cat /etc/auto.master | grep -vE '^#|^$'
/misc	/etc/auto.misc
/-  /etc/auto.nfs
/net	-hosts
+auto.master
[root@vm1 ~]# 


步骤3：创建auto.nfs文件

格式如下：本地挂载点    -fstype=文件系统类型    远程文件系统信息

[root@vm1 ~]# cp -a /etc/auto.misc /etc/auto.nfs
[root@vm1 ~]# 

[root@vm1 ~]# cat /etc/auto.nfs
## auto mount
/data/software  -fstype=nfs nfs.felix.com:/data/ftp/vusers/software
[root@vm1 ~]# 

步骤4：重启autofs服务，并设置开机自动启动
[root@vm1 ~]# /etc/init.d/autofs stop
Stopping automount:                                        [  OK  ]
[root@vm1 ~]# /etc/init.d/autofs start
Loading autofs4:                                           [  OK  ]
Starting automount:                                        [  OK  ]
[root@vm1 ~]# chkconfig autofs on
[root@vm1 ~]# 

步骤5：测试，当进入到/data/software目录时，自动挂载
[root@vm1 ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        18G  1.1G   16G   7% /
tmpfs           116M     0  116M   0% /dev/shm
/dev/sda1       194M   27M  158M  15% /boot
[root@vm1 ~]# cd /data/software/
[root@vm1 software]# df -h
Filesystem                               Size  Used Avail Use% Mounted on
/dev/sda3                                 18G  1.1G   16G   7% /
tmpfs                                    116M     0  116M   0% /dev/shm
/dev/sda1                                194M   27M  158M  15% /boot
nfs.felix.com:/data/ftp/vusers/software   18G   13G  4.1G  76% /data/software
[root@vm1 software]# 

```

使用autofs自动挂载的文件系统，默认情况下，如果在5分钟（300s）内没有使用的话，则会被自动的卸载掉，该超时时间是在/etc/sysconfig/autofs中的TIMEOUT参数设置的。


# NFS启动在固定端口
NFS主程序使用的端口是2049端口，为了实现不同的功能，需要启用不同的端口，而这些端口需要向RPC注册，但是在配置防火墙时，由于这些端口不是固定的，因此配置起来就比较麻烦，为了方便防火墙的配置，因此需要让NFS启动在固定端口。

```
修改配置文件：/etc/sysconfig/nfs
LOCKD_TCPPORT=3001
LOCKD_UDPPORT=3001
MOUNTD_PORT=3002
STATD_PORT=3003
STATD_OUTGOING_PORT=3004
将上述几个端口修改为相应的端口。
 
 
iptables设置（rpcbind所使用的端口是111）：
[root@control ~]# iptables -A INPUT -i eth0 -p tcp -s 172.17.100.0/24 -d 172.17.100.250 -m multiport --dport 111,2049,3001:3004 -j ACCEPT
[root@control ~]# iptables -A INPUT -i eth0 -p udp -s 172.17.100.0/24 -d 172.17.100.250 -m multiport --dport 111,2049,3001:3004 -j ACCEPT
[root@control ~]# 

```