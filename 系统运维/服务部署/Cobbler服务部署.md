[cobbler官网](http://cobbler.github.io)

[cobbler下载](http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/noarch/)

[libyaml下载](http://pkgs.repoforge.org/libyaml/)

# Cobbler安装
## 机器访问不了外网
```
1. Cobbler相关软件列表
[root@vm02 cobbler]# ls -l
total 1136
-rw-r--r-- 1 root root 539348 Apr 27 18:51 cobbler-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 206468 Apr 27 18:51 cobbler-web-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 122684 Apr 27 18:51 koan-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 109420 Apr 26 21:27 libyaml-0.1.4-1.el6.rf.x86_64.rpm
-rw-r--r-- 1 root root  12516 Apr 26 21:27 libyaml-devel-0.1.4-1.el6.rf.x86_64.rpm
-rw-r--r-- 1 root root 160544 Apr 26 21:17 PyYAML-3.10-3.el6.x86_64.rpm
[root@vm02 cobbler]# 

2. 安装相关软件
[root@vm02 cobbler]# yum install -y httpd dhcp pykickstart rsync tftp-server

3. 安装cobbler
[root@vm02 cobbler]# yum localinstall -y libyaml-* PyYAML-3.10-3.el6.x86_64.rpm cobbler-2.6.6-23.2.noarch.rpm 

```

## 机器可以访问外网
```
1. 安装epel
[root@vm02 cobbler]# rpm -Uvh http://mirrors.opencas.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
Retrieving http://mirrors.opencas.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
warning: /var/tmp/rpm-tmp.7uH9WZ: Header V3 RSA/SHA256 Signature, key ID 0608b895: NOKEY
Preparing...                ########################################### [100%]
   1:epel-release           ########################################### [100%]
[root@vm02 cobbler]# 

2. 安装cobbler
[root@vm02 cobbler]# yum install -y cobbler
```

# Cobbler相关文件说明
```
配置文件:/etc/cobbler/
-rw-r--r-- 1 root root  2946 Jan 23 16:41 dhcp.template            # DHCP服务的配置模板。
-rw-r--r-- 1 root root   385 Jan 23 16:41 dnsmasq.template         # DNS服务dnsmasq的配置模板。
-rw-r--r-- 1 root root  2014 Jan 23 16:41 import_rsync_whitelist
drwxr-xr-x 2 root root  4096 Apr 26 21:29 iso                      # iso模板配置文件的目录
drwxr-xr-x 2 root root  4096 Apr 26 21:29 ldap
-rw-r--r-- 1 root root  3076 Jan 23 16:41 modules.conf             # cobbler的模块配置文件
-rw-r--r-- 1 root root    43 Jan 23 16:41 mongodb.conf
-rw-r--r-- 1 root root   680 Oct 16  2015 named.template           # DNS服务named配置模板。
drwxr-xr-x 2 root root  4096 Apr 26 21:29 power                    # 电源的配置文件目录。
drwxr-xr-x 2 root root  4096 Apr 26 21:29 pxe                      # pxe模板文件目录。
drwxr-xr-x 2 root root  4096 Apr 26 21:29 reporting
-rw-r--r-- 1 root root   368 Jan 23 16:41 rsync.exclude
-rw-r--r-- 1 root root  1073 Oct 16  2015 rsync.template           # rsync服务的配置模板。
-rw-r--r-- 1 root root   754 Oct 16  2015 secondary.template       # 从DNS服务named的配置模板。
-rw-r--r-- 1 root root 19648 Jan 23 21:57 settings                 # cobbler的主配置文件，格式：YAML。
-rw-r--r-- 1 root root 19648 Jan 23 21:57 settings.orig
-rw-r--r-- 1 root root   740 Oct 16  2015 tftpd.template           # TFTP服务的配置模板。
-rw-r--r-- 1 root root   848 Jan 23 16:41 users.conf               # web服务授权配置文件 
-rw-r--r-- 1 root root    49 Jan 23 16:41 users.digest             # 用于web访问的用户名密码配置文件。
-rw-r--r-- 1 root root   117 Jan 23 21:57 version

cobbler的数据目录:/var/lib/cobbler/
drwxr-xr-x 10 root   root  4096 Apr 26 21:29 config              # 配置文件
drwxr-xr-x  3 root   root  4096 Apr 26 21:29 kickstarts          # 默认存放kickstart文件的目录
drwxr-xr-x  2 root   root  4096 Jan 23 21:57 loaders             # 存放各种引导程序。

cobbler的镜像:/var/www/cobbler/
drwxr-xr-x 2 root root 4096 Jan 23 21:57 images                  # 导入的系统镜像启动文件。
drwxr-xr-x 3 root root 4096 Apr 26 21:29 ks_mirror               # 导入的系统镜像列表。
drwxr-xr-x 2 root root 4096 Jan 23 21:57 repo_mirror             # yum源存储目录
```

# cobbler设计方式
![cobbler设计方式](https://github.com/felix1115/Docs/blob/master/Images/cobbler-1.png)

* Distribution
```
发行版。表示一个操作系统，承载了内核和initrd以及内核参数等其他数据。
```

* Profile
```
配置文件。包含一个distribution、一个kickstart文件以及repostory，还包含更多特定的内核参数等其他数据。
```

* System
```
系统。表示要配置的机器。包含一个配置文件或一个镜像。还包含IP地址和MAC地址、电源管理等。
```

* Repository
```
存储库。保存一个yum或rsync存储库的镜像信息。
```

# 安装Cobbler
说明：
DHCP服务器：vm01,172.17.100.1
TFTP服务器：vm02,172.17.100.2
HTTP服务器：vm02,172.17.100.2
Cobbler服务器：vm02,172.17.100.2

## 检查cobbler配置
```
命令：cobbler check

[root@vm02 ~]# cobbler check
The following are potential configuration items that you may want to fix:

1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
3 : missing /etc/xinetd.d/tftp, install tftp-server?
4 : missing configuration file: /etc/xinetd.d/tftp
5 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
6 : change 'disable' to 'no' in /etc/xinetd.d/rsync
7 : debmirror package is not installed, it will be required to manage debian deployments and repositories
8 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
9 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

Restart cobblerd and then run 'cobbler sync' to apply changes.
[root@vm02 ~]# 


** 根据提示修改配置文件/etc/cobbler/setting **

* server
指定cobbler服务器的地址。

* next_server
指定TFTP服务器的地址。

* 防止循环通过PXE安装系统
将pxe_just_once:0修改为pxe_just_once:1

** 每一次修改都需要重启cobblerd服务并执行cobbler sync然后执行cobbler check **


[root@vm02 ~]# cobbler check
The following are potential configuration items that you may want to fix:

1 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
2 : change 'disable' to 'no' in /etc/xinetd.d/rsync
3 : debmirror package is not installed, it will be required to manage debian deployments and repositories
4 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
5 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

Restart cobblerd and then run 'cobbler sync' to apply changes.
[root@vm02 ~]# 


* 获取boot-loader
如果机器可以访问互联网，可以使用cobbler get-loaders命令从官网下载boot loader。
如果机器不能访问互联网，可以安装syslinux软件将pxelinux.0和menu.c32文件复制到/var/lib/cobbler/loaders目录下。
[root@vm02 ~]# cp -a /usr/share/syslinux/{pxelinux.0,menu.c32} /var/lib/cobbler/loaders/
[root@vm02 ~]# 

* 修改/etc/xinetd.d/rsync将yes改为no
[root@vm02 ~]# sed -i '/disable/s/yes/no/' /etc/xinetd.d/rsync
[root@vm02 ~]# 

* 修改新机器root用户的密码
说明：这里有个slat，使用openssl rand -hex产生。密码为123456
[root@vm02 ~]# openssl passwd -1 -salt $(openssl rand -hex 4) '123456'
$1$e089ff93$GEEqtB6CpKjyGxSWVGBfv/
[root@vm02 ~]#
将上述产生的字符串，添加到/etc/cobbler/setting的default_password_crypted字段。


设置完之后，重启cobblerd并执行cobbler sync，然后在执行cobbler check。

```

## DHCP服务器配置
```
[root@vm01 ~]# more /etc/dhcp/dhcpd.conf 
# DHCP Config File
#
ddns-update-style none;
ignore client-updates;

log-facility local7;

allow bootp;
allow booting;

option domain-name "felix.com";
option domain-name-servers 172.17.100.1, 172.17.100.2;

default-lease-time 14400;
max-lease-time 28800;

shared-network felix {
	subnet 172.17.100.0 netmask 255.255.255.0 {
		range 172.17.100.101 172.17.100.150;
		option routers 172.17.100.253;
		filename "/pxelinux.0";
		next-server 172.17.100.2;
	}
}

group {
	use-host-decl-names on;
	include "/etc/dhcp/static.conf";
}
[root@vm02 ~]# 
```

## TFTP服务器配置
```
[root@vm02 tftpboot]# more /etc/xinetd.d/tftp 
# default: off
# description: The tftp server serves files using the trivial file transfer \
#	protocol.  The tftp protocol is often used to boot diskless \
#	workstations, download configuration files to network-aware printers, \
#	and to start the installation process for some operating systems.
service tftp
{
	socket_type		= dgram
	protocol		= udp
	wait			= yes
	user			= root
	server			= /usr/sbin/in.tftpd
	server_args		= -s /var/lib/tftpboot
	disable			= no 
	per_source		= 11
	cps			= 100 2
	flags			= IPv4
}
[root@vm02 tftpboot]# 
```

## 导入distribution
```
[root@vm02 ~]# cobbler import --path=/images/ --name=CentOS6.5x64 --arch=x86_64

说明：
--path：指定iso镜像文件的挂载路径
--name：指定该发行版的名称。
--arch：指定安装源的类型。可以是x86、ia64、x86_64

使用该指令后，cobbler会将镜像中的所有文件都存放在/var/www/cobbler/ks_mirror下的--name所指定的目录下.

* 查看distribution列表
[root@vm02 ~]# cobbler distro list
   CentOS6.5x64-x86_64
[root@vm02 ~]# 


* 重命名distribution
[root@vm02 ~]# cobbler distro rename --name CentOS6.5x64-x86_64 --newname CentOS6.5-x86_64
[root@vm02 ~]#

* 查看distribution的详细信息
[root@vm02 ~]# cobbler distro report --name CentOS6.5-x86_64
Name                           : CentOS6.5-x86_64
Architecture                   : x86_64
TFTP Boot Files                : {}
Breed                          : redhat
Comment                        : 
Fetchable Files                : {}
Initrd                         : /var/www/cobbler/ks_mirror/CentOS6.5-x86_64/images/pxeboot/initrd.img
Kernel                         : /var/www/cobbler/ks_mirror/CentOS6.5-x86_64/images/pxeboot/vmlinuz
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart Metadata             : {'tree': 'http://@@http_server@@/cblr/links/CentOS6.5x64-x86_64'}
Management Classes             : []
OS Version                     : rhel6
Owners                         : ['admin']
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Template Files                 : {}

[root@vm02 ~]# 

这里可以看到initrd和kernel以及kickstart的信息。
```

## 指定kickstart文件
cobbler默认的kickstart文件位于/var/lib/cobbler/kickstarts目录下。
```
1. 将准备好的ks文件复制到该目录下。
[root@vm02 kickstart]# cp -a centosminiks.cfg /var/lib/cobbler/kickstarts/
[root@vm02 kickstart]# 

2. 查看profile的详细信息
[root@vm02 kickstarts]# cobbler profile list
   CentOS6.5x64-x86_64
[root@vm02 kickstarts]# cobbler profile report
Name                           : CentOS6.5x64-x86_64
TFTP Boot Files                : {}
Comment                        : 
DHCP Tag                       : default
Distribution                   : CentOS6.5-x86_64
Enable gPXE?                   : 0
Enable PXE Menu?               : 1
Fetchable Files                : {}
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart                      : /var/lib/cobbler/kickstarts/sample_end.ks
Kickstart Metadata             : {}
Management Classes             : []
Management Parameters          : <<inherit>>
Name Servers                   : []
Name Servers Search Path       : []
Owners                         : ['admin']
Parent Profile                 : 
Internal proxy                 : 
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Repos                          : []
Server Override                : <<inherit>>
Template Files                 : {}
Virt Auto Boot                 : 1
Virt Bridge                    : xenbr0
Virt CPUs                      : 1
Virt Disk Driver Type          : raw
Virt File Size(GB)             : 5
Virt Path                      : 
Virt RAM (MB)                  : 512
Virt Type                      : kvm

[root@vm02 kickstarts]# 

3. 将ks文件和profile关联
[root@vm02 kickstarts]# cobbler profile edit --name CentOS6.5x64-x86_64 --kickstart /var/lib/cobbler/kickstarts/centosminiks.cfg 
[root@vm02 kickstarts]# 

4. 再次查看profile所对应的kickstart
[root@vm02 kickstarts]# cobbler profile report --name CentOS6.5x64-x86_64
Name                           : CentOS6.5x64-x86_64
TFTP Boot Files                : {}
Comment                        : 
DHCP Tag                       : default
Distribution                   : CentOS6.5-x86_64
Enable gPXE?                   : 0
Enable PXE Menu?               : 1
Fetchable Files                : {}
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart                      : /var/lib/cobbler/kickstarts/centosminiks.cfg
Kickstart Metadata             : {}
Management Classes             : []
Management Parameters          : <<inherit>>
Name Servers                   : []
Name Servers Search Path       : []
Owners                         : ['admin']
Parent Profile                 : 
Internal proxy                 : 
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Repos                          : []
Server Override                : <<inherit>>
Template Files                 : {}
Virt Auto Boot                 : 1
Virt Bridge                    : xenbr0
Virt CPUs                      : 1
Virt Disk Driver Type          : raw
Virt File Size(GB)             : 5
Virt Path                      : 
Virt RAM (MB)                  : 512
Virt Type                      : kvm

[root@vm02 kickstarts]# 

5. ks文件内容
install
keyboard us
lang en_US
rootpw --iscrypted \$1\$af47895c\$hJobmVmm6/dV2P61LGClc/
timezone Asia/Shanghai
authconfig --enableshadow --passalgo=sha512
#partioning
#LVM Config
part /boot --fstype=ext4 --size=200
part pv.008002 --grow --size=200
volgroup vg_root --pesize=4096 pv.008002
logvol / --grow --fstype=ext4 --name=root_lv --vgname=vg_root --size=18224
logvol swap --name=swap_lv --vgname=vg_root --size=2048
# Normal Config
#part /boot --size=200 --fstype=ext4  
#part swap --size=1024 --fstype=swap
#part / --grow  --fstype=ext4 --size=200
#bootloader
bootloader --location=mbr --driveorder=sda --append="rhgb quiet"
#network config
network --bootproto=dhcp --device=eth0 --onboot=yes --noipv6
#clearpart
clearpart --all --initlabel
#init disk
zerombr
firewall --disabled
selinux --disabled
#http install
url --url=$tree
#reboot system on install successful
reboot
#package
%packages
@core
@server-policy
@workstation-policy
vim
gcc
gcc-c++
lrzsz
wget
%end
#post script
%post
/etc/init.d/NetworkManager stop
chkconfig NetworkManager off

cat > /root/.vimrc <<EOF
set nu
set nohlsearch
set ai
syntax on
set tabstop=4
set shiftwidth=4
set softtabstop=4
EOF
%end


说明：ks文件中的所有$都需要使用\进行转义

6. 检查ks文件是否正确
[root@vm02 kickstarts]# cobbler validateks
task started: 2016-10-09_123707_validateks
task started (id=Kickstart Validation, time=Sun Oct  9 12:37:07 2016)
----------------------------
osversion: rhel6
checking url: http://172.17.100.2/cblr/svc/op/ks/profile/CentOS6.5-x86_64
running: /usr/bin/ksvalidator -v "rhel6" "http://172.17.100.2/cblr/svc/op/ks/profile/CentOS6.5-x86_64"
received on stdout: 
received on stderr: 
*** all kickstarts seem to be ok ***
*** TASK COMPLETE ***
[root@vm02 kickstarts]# 


6. 同步
[root@vm02 kickstarts]# cobbler sync

7. 安装系统测试
```
![cobbler安装界面1](https://github.com/felix1115/Docs/blob/master/Images/cobbler-2.png)
![cobbler安装界面2](https://github.com/felix1115/Docs/blob/master/Images/cobbler-3.png)


