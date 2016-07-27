[TOC]

# 通信过程介绍
1. 客户端要和服务器进行通信，客户端需要有IP地址，因此需要部署DHCP服务器。
2. 客户端要进行引导，服务器端需要提供相应的文件。如内核vmlinuz、虚拟文件系统initrd等。这些文件可以通过TFTP提供。
3. 客户端在安装过程中，需要软件包，因此服务器端需要提供必要的软件包。这些软件包可以通过FTP、NFS或者是HTTP提供。
4. 在安装的过程中，需要配置主机名、磁盘分区等，这些需要在服务器端指定应答文件ks.cfg。
5. 客户端如何知道ks.cfg就是应答文件呢？因此需要在pxelinxu.cfg的配置文件中default中指定。

# PXE  Kickstart部署全过程
## DHCP服务器部署
详细配置参见另一篇博客：http://blog.csdn.net/xrwwuming/article/details/51497391

```bash
[root@control ~]# cat /etc/dhcp/dhcpd.conf 
# DHCP Config
#
ignore client-updates;
ddns-update-style interim;
allow bootp;
allow booting;

option domain-name "felix.com";
option domain-name-servers 172.17.100.1, 172.17.100.2;

log-facility local7;

default-lease-time 14400;
max-lease-time 28800;

shared-network felix {
    subnet 172.17.100.0 netmask 255.255.255.0 {
        range 172.17.100.150 172.17.100.200;
        option routers 172.17.100.254;
        filename "/pxelinux.0";
        next-server 172.17.100.250;
    }    
}
[root@control ~]# 

```

## TFTP-Server部署
```bash
* 安装xinetd和tftp-server软件
[root@control ~]# yum install -y xinetd tftp-server

* 配置tftp（/etc/xinetd.d/tftp）,将disable = yes改为disable = no
[root@control ~]# cat /etc/xinetd.d/tftp | grep -v '^#'
service tftp
{
        disable                 = no
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -B 1380 -v -s /var/lib/tftpboot
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}

[root@control ~]# 

```

## Apache服务器部署
```bash
* 安装httpd
[root@control ~]# yum install -y httpd

* 简单配置httpd（只需要修改ServerName）
[root@control ~]# cat /etc/httpd/conf/httpd.conf | grep '^ServerName'
ServerName control.felix.com:80
[root@control ~]# 

* 在/var/www/html目录下创建一个image目录，用于存放CentOS光盘里面的内容
[root@control ~]# mkdir /var/www/html/image

* 在上述创建的image目录下，创建一个kickstart目录，用于存放ks.cfg文件
[root@control ~]# mkdir /var/www/html/image/kickstart

* 挂载光盘，并将里面的内容复制到/var/www/html/image目录下
[root@control ~]# mount /dev/cdrom /mnt
[root@control ~]# cp -a /mnt/* /var/www/html/image/
```

## 复制文件到tftp的配置目录
需要复制的文件有：pxelinux.0、vmlinuz、initrd
pxelinux.0：需要安装syslinux软件
vmlinuz和initrd：CentOS安装光盘里面有。

数据复制到的目录是TFTP的家目录(在/etc/xinetd.d/tftp的server_args参数指定的目录)，这里为/var/lib/tftpboot

```bash
* 安装syslinux
[root@control ~]# yum install -y syslinux

查找pxelinux.0文件，并复制到/var/lib/tftpboot
[root@control ~]# find / -name pxelinux.0
/usr/share/syslinux/pxelinux.0
[root@control ~]# 
 
[root@control ~]# cp -a /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
[root@control ~]# 
 
复制vmlinuz和initrd
[root@control ~]# cp /var/www/html/image/isolinux/{vmlinuz,initrd.img} /var/lib/tftpboot/
[root@control ~]# ls -l /var/lib/tftpboot/
total 36664
-r--r--r-- 1 root root 33383679 Nov 19 17:11 initrd.img
-rw-r--r-- 1 root root    26828 Feb 22  2013 pxelinux.0
-r-xr-xr-x 1 root root  4128368 Nov 19 17:11 vmlinuz
[root@control ~]# 

```

## ks文件
ks文件可以通过安装system-config-kickstart软件包，在图形界面下产生。也可以使用/root目录下anaconda-ks.conf文件进行简单的修改。

注意：下面的这个ks文件给出了两种磁盘分区的方式，一个是普通的分区（#Normal Config），一个是LVM（#LVM Config），可以根据需要进行修改。

在该ks文件中，都做了相应的注释，方便理解。

将此ks文件放在http服务器的kickstart目录下(/var/www/html/image/kickstart)

```
#安装系统
install
#键盘和语言设置
keyboard us
lang en_US
#root用户的密码
rootpw felix
#时区设置
timezone Asia/Shanghai
#用户认证配置
authconfig --enableshadow --passalgo=sha512
#LVM Config
#/boot分区的大小为200MB，类型为ext4
part /boot --fstype=ext4 --size=200
#创建一个PV，--grow的意思是将剩下的空间都作为一个PV
part pv.008002 --grow --size=200
#在PV中创建一个vg，名称为vg_root，PE的大小为4MB
volgroup vg_root --pesize=4096 pv.008002
#创建lv，一个是swap_lv,挂载点为swap，大小为2048MB。然后创建一个lv，名称为root_lv，类型为ext4，--grow表示剩下的所有空间都分给root_lv，挂载点为/。
logvol / --grow --fstype=ext4 --name=root_lv --vgname=vg_root --size=18224
logvol swap --name=swap_lv --vgname=vg_root --size=2048
# Normal Config
#part /boot --size=200 --fstype=ext4  
#part swap --size=1024 --fstype=swap
#part / --grow  --fstype=ext4 --size=200
#bootloader配置
bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
#网络配置
network --bootproto=dhcp --device=eth0 --onboot=yes --noipv6
#删除所有分区
clearpart --all --initlabel
#清空MBR
zerombr
#关闭防火墙
firewall --disabled
#关闭SELinux
selinux --disabled
#通过HTTP的方式安装
url --url http://172.17.100.250/image
#安装完成后，重启系统
reboot
#安装的软件包
%packages
@core
@server-policy
@workstation-policy
openssh-clients
zlib
zlib-devel
openssl
openssl-devel
%end
#安装完成后执行的一些脚本
%post
/etc/init.d/NetworkManager stop
chkconfig NetworkManager off
%end
```

## default文件
```bash
* 在/var/lib/tftpboot目录下，创建pxelinux.cfg目录
[root@control ~]# mkdir /var/lib/tftpboot/pxelinux.cfg
[root@control ~]# 

* 将光盘中的isolinux目录下的isolinux.cfg文件复制到pxelinux.cfg目录下，并重命名为default
[root@control ~]# cp -a /var/www/html/image/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
[root@control ~]# 
 
* 给default文件赋予w权限
[root@control ~]# chmod +x /var/lib/tftpboot/pxelinux.cfg/default
[root@control ~]# 


* 修改default文件的内容

[root@control ~]# cat /var/lib/tftpboot/pxelinux.cfg/default
default pxelinux
#prompt 1
timeout 600

label pxelinux
  menu label ^Install or upgrade an existing system
  menu default
  kernel vmlinuz
  append initrd=initrd.img ks=http://172.17.100.250/image/kickstart/ks.cfg
label local
  menu label Boot from ^local drive
  localboot 0xffff
[root@control ~]# 
```

## 启动所有服务
要求：
1. 关闭SELinux
2. 最好关闭iptables。否则需要放行tftp的UDP 69端口和httpd的TCP 80端口。
3. 客户端需要设置为从pxe引导

```bash
[root@control ~]# /etc/init.d/dhcpd restart
Shutting down dhcpd:                                       [  OK  ]
Starting dhcpd:                                            [  OK  ]
[root@control ~]# /etc/init.d/xinetd restart
Stopping xinetd:                                           [  OK  ]
Starting xinetd:                                           [  OK  ]
[root@control ~]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@control ~]# 
```