[cobbler����](http://cobbler.github.io)

[cobbler����](http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/noarch/)

[libyaml����](http://pkgs.repoforge.org/libyaml/)

# Cobbler��װ
## �������ʲ�������
```
1. Cobbler�������б�
[root@vm02 cobbler]# ls -l
total 1136
-rw-r--r-- 1 root root 539348 Apr 27 18:51 cobbler-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 206468 Apr 27 18:51 cobbler-web-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 122684 Apr 27 18:51 koan-2.6.6-23.2.noarch.rpm
-rw-r--r-- 1 root root 109420 Apr 26 21:27 libyaml-0.1.4-1.el6.rf.x86_64.rpm
-rw-r--r-- 1 root root  12516 Apr 26 21:27 libyaml-devel-0.1.4-1.el6.rf.x86_64.rpm
-rw-r--r-- 1 root root 160544 Apr 26 21:17 PyYAML-3.10-3.el6.x86_64.rpm
[root@vm02 cobbler]# 

2. ��װ������
[root@vm02 cobbler]# yum install -y httpd dhcp pykickstart rsync tftp-server

3. ��װcobbler
[root@vm02 cobbler]# yum localinstall -y libyaml-* PyYAML-3.10-3.el6.x86_64.rpm cobbler-2.6.6-23.2.noarch.rpm 

```

## �������Է�������
```
1. ��װepel
[root@vm02 cobbler]# rpm -Uvh http://mirrors.opencas.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
Retrieving http://mirrors.opencas.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
warning: /var/tmp/rpm-tmp.7uH9WZ: Header V3 RSA/SHA256 Signature, key ID 0608b895: NOKEY
Preparing...                ########################################### [100%]
   1:epel-release           ########################################### [100%]
[root@vm02 cobbler]# 

2. ��װcobbler
[root@vm02 cobbler]# yum install -y cobbler
```

# Cobbler����ļ�˵��
```
�����ļ�:/etc/cobbler/
-rw-r--r-- 1 root root  2946 Jan 23 16:41 dhcp.template            # DHCP���������ģ�塣
-rw-r--r-- 1 root root   385 Jan 23 16:41 dnsmasq.template         # DNS����dnsmasq������ģ�塣
-rw-r--r-- 1 root root  2014 Jan 23 16:41 import_rsync_whitelist
drwxr-xr-x 2 root root  4096 Apr 26 21:29 iso                      # isoģ�������ļ���Ŀ¼
drwxr-xr-x 2 root root  4096 Apr 26 21:29 ldap
-rw-r--r-- 1 root root  3076 Jan 23 16:41 modules.conf             # cobbler��ģ�������ļ�
-rw-r--r-- 1 root root    43 Jan 23 16:41 mongodb.conf
-rw-r--r-- 1 root root   680 Oct 16  2015 named.template           # DNS����named����ģ�塣
drwxr-xr-x 2 root root  4096 Apr 26 21:29 power                    # ��Դ�������ļ�Ŀ¼��
drwxr-xr-x 2 root root  4096 Apr 26 21:29 pxe                      # pxeģ���ļ�Ŀ¼��
drwxr-xr-x 2 root root  4096 Apr 26 21:29 reporting
-rw-r--r-- 1 root root   368 Jan 23 16:41 rsync.exclude
-rw-r--r-- 1 root root  1073 Oct 16  2015 rsync.template           # rsync���������ģ�塣
-rw-r--r-- 1 root root   754 Oct 16  2015 secondary.template       # ��DNS����named������ģ�塣
-rw-r--r-- 1 root root 19648 Jan 23 21:57 settings                 # cobbler���������ļ�����ʽ��YAML��
-rw-r--r-- 1 root root 19648 Jan 23 21:57 settings.orig
-rw-r--r-- 1 root root   740 Oct 16  2015 tftpd.template           # TFTP���������ģ�塣
-rw-r--r-- 1 root root   848 Jan 23 16:41 users.conf               # web������Ȩ�����ļ� 
-rw-r--r-- 1 root root    49 Jan 23 16:41 users.digest             # ����web���ʵ��û������������ļ���
-rw-r--r-- 1 root root   117 Jan 23 21:57 version

cobbler������Ŀ¼:/var/lib/cobbler/
drwxr-xr-x 10 root   root  4096 Apr 26 21:29 config              # �����ļ�
drwxr-xr-x  3 root   root  4096 Apr 26 21:29 kickstarts          # Ĭ�ϴ��kickstart�ļ���Ŀ¼
drwxr-xr-x  2 root   root  4096 Jan 23 21:57 loaders             # ��Ÿ�����������

cobbler�ľ���:/var/www/cobbler/
drwxr-xr-x 2 root root 4096 Jan 23 21:57 images                  # �����ϵͳ���������ļ���
drwxr-xr-x 3 root root 4096 Apr 26 21:29 ks_mirror               # �����ϵͳ�����б�
drwxr-xr-x 2 root root 4096 Jan 23 21:57 repo_mirror             # yumԴ�洢Ŀ¼
```

# cobbler��Ʒ�ʽ
![cobbler��Ʒ�ʽ](https://github.com/felix1115/Docs/blob/master/Images/cobbler-1.png)

* Distribution
```
���а档��ʾһ������ϵͳ���������ں˺�initrd�Լ��ں˲������������ݡ�
```

* Profile
```
�����ļ�������һ��distribution��һ��kickstart�ļ��Լ�repostory�������������ض����ں˲������������ݡ�
```

* System
```
ϵͳ����ʾҪ���õĻ���������һ�������ļ���һ�����񡣻�����IP��ַ��MAC��ַ����Դ����ȡ�
```

* Repository
```
�洢�⡣����һ��yum��rsync�洢��ľ�����Ϣ��
```

# ��װCobbler
˵����
DHCP��������vm01,172.17.100.1
TFTP��������vm02,172.17.100.2
HTTP��������vm02,172.17.100.2
Cobbler��������vm02,172.17.100.2

## ���cobbler����
```
���cobbler check

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


** ������ʾ�޸������ļ�/etc/cobbler/setting **

* server
ָ��cobbler�������ĵ�ַ��

* next_server
ָ��TFTP�������ĵ�ַ��

* ��ֹѭ��ͨ��PXE��װϵͳ
��pxe_just_once:0�޸�Ϊpxe_just_once:1

** ÿһ���޸Ķ���Ҫ����cobblerd����ִ��cobbler syncȻ��ִ��cobbler check **


[root@vm02 ~]# cobbler check
The following are potential configuration items that you may want to fix:

1 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
2 : change 'disable' to 'no' in /etc/xinetd.d/rsync
3 : debmirror package is not installed, it will be required to manage debian deployments and repositories
4 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
5 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

Restart cobblerd and then run 'cobbler sync' to apply changes.
[root@vm02 ~]# 


* ��ȡboot-loader
����������Է��ʻ�����������ʹ��cobbler get-loaders����ӹ�������boot loader��
����������ܷ��ʻ����������԰�װsyslinux�����pxelinux.0��menu.c32�ļ����Ƶ�/var/lib/cobbler/loadersĿ¼�¡�
[root@vm02 ~]# cp -a /usr/share/syslinux/{pxelinux.0,menu.c32} /var/lib/cobbler/loaders/
[root@vm02 ~]# 

* �޸�/etc/xinetd.d/rsync��yes��Ϊno
[root@vm02 ~]# sed -i '/disable/s/yes/no/' /etc/xinetd.d/rsync
[root@vm02 ~]# 

* �޸��»���root�û�������
˵���������и�slat��ʹ��openssl rand -hex����������Ϊ123456
[root@vm02 ~]# openssl passwd -1 -salt $(openssl rand -hex 4) '123456'
$1$e089ff93$GEEqtB6CpKjyGxSWVGBfv/
[root@vm02 ~]#
�������������ַ�������ӵ�/etc/cobbler/setting��default_password_crypted�ֶΡ�


������֮������cobblerd��ִ��cobbler sync��Ȼ����ִ��cobbler check��

```

## DHCP����������
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

## TFTP����������
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

## ����distribution
```
[root@vm02 ~]# cobbler import --path=/images/ --name=CentOS6.5x64 --arch=x86_64

˵����
--path��ָ��iso�����ļ��Ĺ���·��
--name��ָ���÷��а�����ơ�
--arch��ָ����װԴ�����͡�������x86��ia64��x86_64

ʹ�ø�ָ���cobbler�Ὣ�����е������ļ��������/var/www/cobbler/ks_mirror�µ�--name��ָ����Ŀ¼��.

* �鿴distribution�б�
[root@vm02 ~]# cobbler distro list
   CentOS6.5x64-x86_64
[root@vm02 ~]# 


* ������distribution
[root@vm02 ~]# cobbler distro rename --name CentOS6.5x64-x86_64 --newname CentOS6.5-x86_64
[root@vm02 ~]#

* �鿴distribution����ϸ��Ϣ
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

������Կ���initrd��kernel�Լ�kickstart����Ϣ��
```

## ָ��kickstart�ļ�
cobblerĬ�ϵ�kickstart�ļ�λ��/var/lib/cobbler/kickstartsĿ¼�¡�
```
1. ��׼���õ�ks�ļ����Ƶ���Ŀ¼�¡�
[root@vm02 kickstart]# cp -a centosminiks.cfg /var/lib/cobbler/kickstarts/
[root@vm02 kickstart]# 

2. �鿴profile����ϸ��Ϣ
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

3. ��ks�ļ���profile����
[root@vm02 kickstarts]# cobbler profile edit --name CentOS6.5x64-x86_64 --kickstart /var/lib/cobbler/kickstarts/centosminiks.cfg 
[root@vm02 kickstarts]# 

4. �ٴβ鿴profile����Ӧ��kickstart
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

5. ks�ļ�����
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


˵����ks�ļ��е�����$����Ҫʹ��\����ת��

6. ���ks�ļ��Ƿ���ȷ
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


6. ͬ��
[root@vm02 kickstarts]# cobbler sync

7. ��װϵͳ����
```
![cobbler��װ����1](https://github.com/felix1115/Docs/blob/master/Images/cobbler-2.png)
![cobbler��װ����2](https://github.com/felix1115/Docs/blob/master/Images/cobbler-3.png)


