[TOC]
# FTP介绍
FTP（File Transfer Protocol）文件传输协议，是一个用于在客户端和服务器之间进行文件传输的协议，默认情况下，采用的是明文的方式进行数据的传输，也可以通过使用SSL对其传输的数据进行加密，称为FTPS。FTP和HTTP协议都是文件传输协议，都运行在TCP层之上的应用层协议，而FTP采用的是两个并行的TCP连接，一个是控制连接，一个是数据连接。

- 控制连接用于在客户端和服务器之间发送控制信息，如用户名和密码以及一些控制指令的传输。
- 数据连接用于数据的传输。由于FTP采用的是TCP作为其传输层协议，因此在发送数据之前需要完成TCP的三次握手。

FTP有两种工作模式，一个是主动模式（Active），一个是被动模式（Passive）。

## FTP主动模式(Active)

在FTP的主动模式下，先建立控制连接，然后在建立数据连接。具体过程如下：
1. 首先客户端使用一个大于1024的随机端口（如port AA）连接到服务器的21端口，需要完成TCP的三次握手。
2. FTP服务器的21端口主要在控制连接用于命令的下达，如果有数据进行传输时，就不使用这个端口了。当客户端有数据传输需求时，客户端会通过控制连接使用port command告诉服务器端要采用Active方式进行数据传输，以及自己用于数据传输时所使用的端口（如port BB），并等待服务器的连接。
3. FTP服务器主动的使用20号端口连接至客户端通告的端口（port BB），这时就建立了两条连接，一个是用于命令发送的控制连接，一个是用于数据发送的数据连接。

所谓的主动模式，就是在数据连接时，由FTP服务器主动的连接到FTP客户端。

在主动模式下，服务器和客户端所使用的端口号如下：

-  服务器端
控制连接：使用的端口号是21
数据连接：使用的端口号是20
- 客户端：
控制连接：使用的端口是随机端口
数据连接：使用的端口是随机端口

**在主动模式下存在的问题**
当客户端和服务器端采用的是NAT方式，并且经过防火墙时，在主动模式下会发生如下情况:

1. 当客户端使用一个随机端口（Port AA）连接至FTP服务器的21号端口建立控制连接时，由于防火墙端的NAT会主动的记录由内部送往外部的信息，因此命令连接可以正常的建立。
2. 当客户端使用port command通过控制连接告诉服务器采用主动模式进行数据连接的建立以及客户端用于数据连接的端口号（Port BB）。
3. 服务器端主动的使用20号端口连接至客户端的Port BB，当到达防火墙时，由于Port BB在防火墙上并没有相应的信息记录，因此防火墙会阻止此连接的建立。该连接建立失败。

**解决方法**

- 方法1：使用FTP的被动模式。
在主动模式下，数据连接的建立是FTP服务器主动的连接FTP客户端，因此在被动模式下，就是FTP客户端主动的连接FTP服务器了。

- 方法2：使用iptables所提供的FTP侦测模块。
使用modprobe加载ip_conntrack_ftp和ip_nat_ftp等模块，这几个模块会主动的分析目标端口是21的连接，所以可以得到port BB的端口信息，如果是FTP服务器的主动连接，则可以将数据包发送到正确的客户端。
```bash
[root@control ~]# modprobe  ip_nat_ftp
[root@control ~]# modprobe  ip_conntrack_ftp
[root@control  ~]# lsmod | grep ftp
nf_nat_ftp3507  0
nf_conntrack_ftp12913  1 nf_nat_ftp
nf_nat22759  2 nf_nat_ftp,iptable_nat
nf_conntrack79453  7 nf_nat_ftp,nf_conntrack_ftp,iptable_nat,nf_nat,nf_conntrack_ipv4,nf_conntrack_ipv6,xt_state
[root@control ~]#
```


## FTP被动模式(Passive)
同样的，在被动模式下，也是先建立控制连接，然后在建立数据连接。

**建立过程**
1. 客户端使用一个随机端口（Port AA）连接到FTP服务器的21号端口，完成TCP的三次握手，建立控制连接。
2.  当两端需要数据发送时，客户端通过控制连接发送一个PASV command命令给服务器，要求采用被动模式进行数据传输。
3. 服务器端随机选择一个端口告诉客户端，自己进行数据连接时所使用的端口号，等待客户端的连接。
4. 客户端随机选择一个大于1024的端口（Port BB）连接到FTP服务器的随机端口，用于数据传输。
因此，在被动模式下，在数据传输阶段，是客户端主动的连接服务器。

在被动模式下，服务器和客户端所使用的端口号如下：

- 服务器端
控制连接：使用的端口号是21
数据连接：使用的端口是随机端口
- 客户端
控制连接：使用的端口是随机端口
数据连接：使用的端口是随机端口


#VSFTP的安装和配置
## VSFTPD的安装
```bash
[root@control ~]# yum install -y vsftpd
```

## VSFTPD配置文件参数说明

- 配置文件：/etc/vsftpd/vsftpd.conf
  配置文件每一次修改都需要重启vsftpd服务。/etc/init.d.vsftp restart

- 配置文件的语法：以#开头的表示注释，对大小写敏感。格式为：参数=value
 
**常用参数配置：（可以用man vsftpd.conf查看帮助）**

- 匿名用户相关的参数
	anonymous_enable=YES|NO：是否允许匿名用户登录。
	
	anon_upload_enable=YES|NO：是否允许匿名用户上传文件。
	
	anon_mkdir_write_enable=YES|NO：是否允许匿名用户在FTP服务器上创建目录。
	
	anon_other_write_enable=YES|NO：是否允许匿名用户执行创建目录之外的写操作，如删除、重命名等。
	
	allow_anon_ssl=YES|NO：是否允许匿名用户使用SSL连接。需要ssl_enable设置为YES。
	
	anon_umask：匿名用户上传文件的umask值。
	
	anon_root：指定匿名用户登录时会被引导到的家目录。默认为/var/ftp
	
	anon_max_rate：匿名用户的最大传输速率。单位是bytes/s
	
	chown_uploads=YES|NO：是否改变匿名用户上传文件的拥有者。
	
	chown_username=who：将匿名用户上传文件的拥有者改为who。当然需要允许匿名用户（anonymous_enable=YES）以及允许匿名用户上传（anon_upload_enable=YES）.


- 本地用户相关的参数
	local_enable=YES|NO：是否允许本地用户登录。
	
	local_root：指定非匿名用户登录时会引导到的目录。
	
	local_max_rate：本地用户的最大传输速率。单位是bytes/s
	
	write_enable=YES|NO：是否允许非匿名用户上传文件。
	
	download_enable=YES|NO：是否允许用户下载文件。
	
	local_umask：本地用户上传文件的umask值，如local_umask=022，则到服务器上查看该文件的权限为777-022或者是666-022。

- 用户权限控制相关的参数
	userlist_file：指定存放被允许或禁止登录的用户列表文件，默认为/etc/vsftpd/user_list。
	
	userlist_enable=YES|NO：是否启用userlist_file的功能。当为YES时，在userlist_file文件中指定的用户尝试登录系统时，在输入密码之前就被拒绝登录了。
	
	userlist_deny=YES|NO：当为yes时，表示拒绝userlist_file文件中的用户登录，当为no时则表示允许该文件中的用户登录。默认值为YES。
	注意：ftpusers文件和user_list文件都可以用来限制不能登录ftp服务器的用户，ftpusers这个文件中的用户是不允许登录的，一般不进行修改，而user_list中文件默认也是不允许登录的，可以控制能否登录。如果在ftpusers和user_list中都存在用户，一个不允许，一个允许，以ftpusers文件优先。


- chroot相关的参数
	chroot_local_user=YES|NO：本地用户是否被chroot，限制在自己的家目录里面。yes表示本地用户会被chroot到自己的家目录里面，no表示本地用户不会被chroot到自己的家目录里面。默认为NO
	
	chroot_list_file：指定chroot file的文件名。
	
	chroot_list_enable=YES|NO：是否启用chroot_list_file的功能。当chroot_local_user=YES时，且chroot_list_enable也为yes时，表示chroot_list_file里面所指定的用户不会被chroot。当该选项为no时，则会被chroot到自己的家目录。默认为NO。

	chroot通常设置为如下方式。第一二两条不用修改，第三条chroot_local_user如果为YES，则chroot_list文件里面的用户不会被chroot，如果为NO，则在该文件里面的用户会被chroot。
	chroot_list_file=/etc/vsftpd/chroot_list
	chroot_list_enable=YES
	chroot_local_user=YES

- ASCII和超时相关的参数
	ascii_upload_enable=YES|NO：上传文件时是否允许使用ascii传输模式
	
	ascii_download_enable=YES|NO：下载文件时是否允许使用ascii传输模式。
	
	idle_session_timeout：指定会话超时时间。客户端连接到了FTP服务器，但是未操作。单位为秒。
	
	data_connection_timeout：指定数据传输超时时间，单位为秒。
	
	deny_file：不允许上传的文件类型。如deny_file={*.exe,*.dll}
	
	pam_service_name=vsftpd：指定vsftpd使用的pam模块的配置文件名称。该配置文件默认在/etc/pam.d目录下。

默认的/etc/pam.d/vsftpd的内容如下：
```bash
[root@server1 vsftpd]# more /etc/pam.d/vsftpd 
#%PAM-1.0
session    optional     pam_keyinit.so    force revoke
auth       required     pam_listfile.so item=user  sense=deny  file=/etc/vsftpd/ftpusers onerr=succeed
auth       required     pam_shells.so
auth       include      password-auth
account    include      password-auth
session    required     pam_loginuid.so
session    include      password-auth
[root@server1 vsftpd]#
注释：item指定允许或拒绝的对象类型，可以是user、group。
sense：指定是允许allow或拒绝deny。
file：指定文件名
```

- 其他相关参数的配置
	listen_address：指定vsftpd服务器监听的地址
	
	listen_port：指定vsftpd服务器的监听端口。默认为21端口
	
	max_clients：vsftpd允许的最大连接数。
	
	max_per_ip：vsftpd允许同一个ip的最大连接数。
	
	use_localtime=YES|NO:是否在显示目录列表时使用本地时间。
	
	ftp_banner：登录到FTP服务器时的欢迎信息。
	
	banner_file：banner信息存放的位置。
	
	dirmessage_enable=YES|NO:当用户首次切换到某一个目录时，会显示该目录下的.message里面的内容。
	
	banner_fail:当用户连接失败时，显示该文件里面的内容。如banner_fail=/etc/vsftpd/errorinfo。该参数可以用在vsftpd由xinetd管理的时候，可用。
	
	xferlog_enable=YES|NO：是否允许用户上传或下载文件时记录日志。
	
	xferlog_file：指定存放上传或下载信息的日志文件名。
	
	xferlog_std_format=YES|NO：是否使用标准格式记录日志。YES表示使用xferlog_file，NO使用vsftpd_log_file
	
	nopriv_user：指定vsftpd服务的运行账户，默认为ftp。
	
	connect_from_port_20=YES|NO:是否使用20端口传输数据。
	
	pasv_min_port和pasv_max_port：设置用于被动模式下，服务器所启用的用于数据传输的端口范围。
	
	delete_failed_uploads：当上传文件失败时，删除失败的文件。
	
	pasv_enable：是否允许pasv模式。默认为yes
	
	port_enable：是否允许主动模式，默认为yes
	
	listen=YES：开启ipv4的支持
	
	tcp_wrappers=YES|NO：是否允许tcp_wrappers管理。
	
	connect_timeout：在主动模式下，客户端连接服务器的端口时的最大超时时间。默认为60s

- 虚拟用户相关的参数
	guest_enable=YES:允许虚拟用户登录
	
	guest_username=vuser：指定虚拟用户映射的本地用户，这里为vuser用户。
	
	virtual_use_local_privs=YES：虚拟用户使用本地用户权限。设置为YES时，虚拟用户使用与本地用户相同权限，设置为NO时，虚拟用户使用与匿名用户相同权限(必须开启)，如果为YES，则创建文件时的权限依赖于local_umask，如果为NO，则依赖于anon_umask，该值默认为077.
	
	pasv_address：指定使用被动模式时使用的回复客户端的IP地址。默认是listen_address指定的地址。


-  FTPS相关的参数
	ssl_enable=YES   //启用SSL的支持
	ssl_sslv2=NO    //让vsftpd不支持SSLv2，能不支持，就最好不要支持
	ssl_sslv3=YES    //让vsftpd支持SSLv3
	ssl_tlsv1=YES     //让vsftpd支持tls加密方式v1
	force_local_logins_ssl=YES  //强制本地用户登录时，使用SSL加密。
	force_local_data_ssl=YES  //强制本地用户在进行数据传输时使用ssl加密。NO表示可以选择加密，也可以选择不加密
	rsa_cert_file=/etc/vsftpd/ssl/vsftpd.pem   //指定服务器端的证书存放路径
	rsa_private_key_file：指定vsftpd的私钥存放位置。
	allow_anon_ssl=NO：对于匿名用户不支持SSL。
	force_anon_data_ssl=NO：匿名用户的数据传输不支持SSL
	force_anon_logins_ssl=NO：匿名用户的登录不使用SSL
	ssl_ciphers=HIGH
	



## 配置示例
### 上传目录创建以及权限设置
```bash
本地用户启用了chroot和user_list功能，只允许在user_list中的用户登录。

目录说明：
anonymous目录是匿名用户的家目录，也就是根目录。这个目录对于其他用户来说不能有写权限（不能设置为757这种），否则连接时会报错。
vusers目录是虚拟用户和本地用户的家目录。
uploads是文件上传的目录。

创建目录：
[root@control ~]# mkdir -p /data/ftp/{anonymous,vusers}/uploads
[root@control ~]# tree /data
/data
└── ftp
    ├── anonymous
    │  └── uploads
    └── vusers
        └── uploads

5 directories, 0 files
[root@control ~]# 

修改匿名用户上传目录的权限：
[root@control ~]# chmod 757 /data/ftp/anonymous/uploads
[root@control ~]# ls -ld /data/ftp/anonymous/uploads
drwxr-xrwx 2 root root 4096 May 27 08:49 /data/ftp/anonymous/uploads
[root@control ~]# 

修改本地用户上传目录的权限：
[root@control vsftpd]# chmod 757 /data/ftp/vusers/uploads
[root@control vsftpd]# ls -ld /data/ftp/vusers/uploads
drwxr-xrwx 3 root root 4096 May 27 09:54 /data/ftp/vusers/uploads
[root@control vsftpd]# 


chroot的设置规则是ftptest01会被chroot，ftptest02不会被chroot.
```

### 匿名用户和本地用户登录配置示例
- **配置文件**
```bash
[root@control vsftpd]# cat /etc/vsftpd/vsftpd.conf
## anonymous config
anonymous_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_umask=002
anon_root=/data/ftp/anonymous
anon_max_rate=512000
chown_uploads=NO


## Local user config
local_enable=YES
write_enable=YES
download_enable=YES
local_root=/data/ftp/vusers
local_umask=022
local_max_rate=5120000

## Local user access control
userlist_enable=YES
userlist_file=/etc/vsftpd/user_list
userlist_deny=NO

## chroot config
chroot_list_file=/etc/vsftpd/chroot_list
chroot_list_enable=YES
chroot_local_user=YES

## other config
dirmessage_enable=YES
xferlog_enable=YES
xferlog_file=/var/log/xferlog
xferlog_std_format=YES
connect_from_port_20=YES
idle_session_timeout=600

ftpd_banner=test FTP Server

listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
[root@control vsftpd]# 

```

- **重启服务**
```bash
[root@control ~]# /etc/init.d/vsftpd restart
Shutting down vsftpd:                                      [  OK  ]
Starting vsftpd for vsftpd:                                [  OK  ]
[root@control ~]# 
```

- **匿名用户上传文件、删除文件、创建目录等操作**

```bash
# 登录ftp服务器
[root@vm1 ~]# lftp anonymous@ftp.test.com
Password: 
lftp anonymous@ftp.test.com:~> dir   
drwxr-xrwx    2 0        0            4096 May 27 01:14 uploads
lftp anonymous@ftp.test.com:/> cd uploads/
lftp anonymous@ftp.test.com:/uploads> dir

#创建目录test1
lftp anonymous@ftp.test.com:/uploads> mkdir test1
mkdir ok, `test1' created

#上传文件
lftp anonymous@ftp.test.com:/uploads> put /etc/hosts
158 bytes transferred
lftp anonymous@ftp.test.com:/uploads> dir
-rw-rw-r--    1 14       50            158 May 27 01:15 hosts
drwxrwxr-x    2 14       50           4096 May 27 01:14 test1

#创建目录test2
lftp anonymous@ftp.test.com:/uploads> mkdir test2
mkdir ok, `test2' created
lftp anonymous@ftp.test.com:/uploads> dir
-rw-rw-r--    1 14       50            158 May 27 01:15 hosts
drwxrwxr-x    2 14       50           4096 May 27 01:14 test1
drwxrwxr-x    2 14       50           4096 May 27 01:15 test2

#重命名test2为test_rename
lftp anonymous@ftp.test.com:/uploads> mv test2 test_rename
rename successful
lftp anonymous@ftp.test.com:/uploads> dir
-rw-rw-r--    1 14       50            158 May 27 01:15 hosts
drwxrwxr-x    2 14       50           4096 May 27 01:14 test1
drwxrwxr-x    2 14       50           4096 May 27 01:15 test_rename

#删除目录test_rename
lftp anonymous@ftp.test.com:/uploads> rmdir test_rename/
rmdir ok, `test_rename/' removed
lftp anonymous@ftp.test.com:/uploads> dir
-rw-rw-r--    1 14       50            158 May 27 01:15 hosts
drwxrwxr-x    2 14       50           4096 May 27 01:14 test1
lftp anonymous@ftp.test.com:/uploads> 

#删除文件hosts
lftp anonymous@ftp.test.com:/uploads> rm hosts 
rm ok, `hosts' removed
lftp anonymous@ftp.test.com:/uploads> dir
drwxrwxr-x    2 14       50           4096 May 27 01:14 test1
lftp anonymous@ftp.test.com:/uploads> 

```

- **本地用户上传文件、创建目录等操作**

```bash
#创建本地用户并设置密码
[root@control ~]# useradd -s /sbin/nologin ftptest01
[root@control ~]# useradd -s /sbin/nologin ftptest02 
[root@control ~]# echo 'ftptest01' | passwd --stdin ftptest01
Changing password for user ftptest01.
passwd: all authentication tokens updated successfully.
[root@control ~]# echo 'ftptest02' | passwd --stdin ftptest02
Changing password for user ftptest02.
passwd: all authentication tokens updated successfully.
[root@control ~]# 


#备份user_list文件，并添加ftptest01和ftptest02用户，也要添加anonymous，否则匿名用户无法登录
[root@control vsftpd]# cp -a user_list user_list.bak
[root@control vsftpd]# echo 'anonymous' > user_list
[root@control vsftpd]# echo 'ftptest01' > user_list
[root@control vsftpd]# echo 'ftptest02' >> user_list
[root@control vsftpd]# cat user_list
anonymous
ftptest01
ftptest02
[root@control vsftpd]# 

#chroot_list文件内容
[root@control vsftpd]# cat chroot_list 
ftptest01
[root@control vsftpd]# 


#登录并测试
[root@vm1 ~]# lftp ftptest01:ftptest01@ftp.test.com
lftp ftptest01@ftp.test.com:~> dir
drwxr-xrwx    2 0        0            4096 May 27 01:58 uploads
lftp ftptest01@ftp.test.com:/> cd uploads/
lftp ftptest01@ftp.test.com:/uploads> mkdir ftptest01
mkdir ok, `ftptest01' created
lftp ftptest01@ftp.test.com:/uploads> cd ftptest01/
lftp ftptest01@ftp.test.com:/uploads/ftptest01> put /etc/hosts
158 bytes transferred
lftp ftptest01@ftp.test.com:/uploads/ftptest01> dir
-rw-r--r--    1 502      502           158 May 27 01:59 hosts
lftp ftptest01@ftp.test.com:/uploads/ftptest01> 


测试chroot：
[root@vm1 ~]# lftp ftptest01:ftptest01@ftp.test.com
lftp ftptest01@ftp.test.com:~> dir
drwxr-xrwx    3 0        0            4096 May 27 01:59 uploads
lftp ftptest01@ftp.test.com:/> cd /tmp
cd: Access failed: 550 Failed to change directory. (/tmp)
lftp ftptest01@ftp.test.com:/> 
lftp ftptest01@ftp.test.com:/> exit
[root@vm1 ~]# 
[root@vm1 ~]# lftp ftptest02:ftptest02@ftp.test.com
lftp ftptest02@ftp.test.com:~> dir
drwxr-xrwx    3 0        0            4096 May 27 01:59 uploads
lftp ftptest02@ftp.test.com:~> cd /tmp/
lftp ftptest02@ftp.test.com:/tmp> dir
drwxr-xr-x    3 0        0            4096 May 23 05:31 pear
-rw-r--r--    1 0        0              34 May 25 03:44 test
-rw-------    1 0        0             212 May 24 23:45 yum_save_tx-2016-05-25-07-456R7YPG.yumtx
lftp ftptest02@ftp.test.com:/tmp> 

```

# 虚拟用户
注意：如果采用虚拟用户登录的话，则本地用户就无法登录，匿名用户不影响。

## 虚拟用户存储在本地数据文件中
```bash
步骤1：安装db4-utils软件，该软件是将一个文件转换成数据库文件
[root@control vsftpd]# yum install -y db4-utils

步骤2：创建本地映射用户，并修改其家目录权限
[root@control vsftpd]# useradd -s /sbin/nologin vuser
[root@control vsftpd]# echo 'vuser' | passwd --stdin vuser
Changing password for user vuser.
passwd: all authentication tokens updated successfully.
[root@control vsftpd]# 

 
步骤3：修改vsftpd.conf，允许虚拟用户登录
guest_enable=YES:允许虚拟用户登录
guest_username=vuser：指定虚拟用户映射的本地用户，这里为vuser用户。
virtual_use_local_privs=YES：让虚拟用户具有本地用户的权限。
 
步骤4： 创建一个文件，用于保存用户名和密码，该文件中的用户为虚拟用户。格式为:
username1
username1’s password
username2
username’s  password
……
 
[root@control vsftpd]# touch vuserdb
[root@control vsftpd]# vim vuserdb 
[root@control vsftpd]# cat vuserdb
ftpvuser01
ftpvuser01
ftpvuser02
ftpvuser02
[root@control vsftpd]# 

  
步骤5：将该文件转换为数据库
指令：db_load -T -t hash  -f  <虚拟用户文件的位置>  <虚拟数据库文件的位置>

[root@control vsftpd]# db_load -T -t hash -f vuserdb vuserdb.db
[root@control vsftpd]# 
注：数据库文件的名称得加上一个扩展名，否则用户无法登陆。在pam文件中，不需要加扩展名。
 
步骤6：在/etc/pam.d/目录下创建一个文件，内容如下
32位系统：
auth required /lib/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
account required /lib/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
64位系统：
auth required /lib64/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
account required /lib64/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
注释：db后面的文件为虚拟用户的数据库文件所在的路径。不需要加扩展名哦，否则会报错。

[root@control vsftpd]# cat /etc/pam.d/vsftpd_vuserfile
auth required /lib64/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
account required /lib64/security/pam_userdb.so  db=/etc/vsftpd/vuserdb
[root@control vsftpd]# 


步骤7：修改pam服务名
pam_service_name=vsftp_virtuser
如果是直接在原有的PAM模块vsftpd的基础上修改的话，则这一步可以省略，如果不是，则这一步要进行修改，并将原来的pam_service_name=vsftpd注释掉  
 
步骤9：添加user_list文件（如果需要） 
需要将所有的虚拟用户添加到该文件中（如果user_list文件中的用户是只允许指定的用户登录） 
[root@control vsftpd]# cat user_list
anonymous
ftptest01
ftptest02

ftpvuser01
ftpvuser02
[root@control vsftpd]# 

步骤9：重启服务
[root@control vsftpd]# /etc/init.d/vsftpd restart
Shutting down vsftpd:                                      [  OK  ]
Starting vsftpd for vsftpd:                                [  OK  ]
[root@control vsftpd]# 
 
 
步骤10：虚拟用户登录测试 
[root@vm1 ~]# lftp ftpvuser01:ftpvuser01@ftp.test.com
lftp ftpvuser01@ftp.test.com:~> dir
drwxr-xrwx    3 0        0            4096 May 27 03:24 uploads
lftp ftpvuser01@ftp.test.com:/> cd uploads/
lftp ftpvuser01@ftp.test.com:/uploads> dir
drwxr-xr-x    2 502      502          4096 May 27 01:59 ftptest01
lftp ftpvuser01@ftp.test.com:/uploads> mkdir ftpvuser01
mkdir ok, `ftpvuser01' created
lftp ftpvuser01@ftp.test.com:/uploads> dir
drwxr-xr-x    2 502      502          4096 May 27 01:59 ftptest01
drwxr-xr-x    2 504      504          4096 May 27 03:24 ftpvuser01
lftp ftpvuser01@ftp.test.com:/uploads> cd ftpvuser01/
lftp ftpvuser01@ftp.test.com:/uploads/ftpvuser01> dir
lftp ftpvuser01@ftp.test.com:/uploads/ftpvuser01> put /etc/hosts
158 bytes transferred
lftp ftpvuser01@ftp.test.com:/uploads/ftpvuser01> dir
-rw-r--r--    1 504      504           158 May 27 03:24 hosts
lftp ftpvuser01@ftp.test.com:/uploads/ftpvuser01> 

```

说明：当采用这种方法时，如果用户变更不频繁的话，配置起来也挺方便的。如果用户变化比较频繁，则比较麻烦，可以使用mysql的方式。


## 虚拟用户使用MySQL数据库
```bash
步骤1：安装MySQL数据库，并设置开机自动启动
[root@control ~]# yum install -y mysql mysql-server
[root@control ~]# /etc/init.d/mysqld start
Starting mysqld:                                           [  OK  ]
[root@control ~]# chkconfig mysqld on

 
步骤2：修改MySQL的密码，如果采用的是其他的rpm包安装，则初始密码存放在/root/.mysql_secret中
[root@control ~]# mysqladmin -u root -h localhost password 'mysql' -p
Enter password: 
[root@control ~]# 

修改密码：
mysqladmin -u <username> -h <hostname|hostip> password 'new-password' -p
说明：-u指定要修改的用户名  -h指定主机名或IP地址  -p 指定旧密码。
 
步骤3：登录数据库，创建数据库、表以及虚拟用户并授权
mysql> create database vsftp;
Query OK, 1 row affected (0.05 sec)

mysql> use vsftp;
Database changed
mysql> use vsftp;
Database changed
mysql> create table vuser (
    -> username varchar(30),
    -> password varchar(41)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> insert into vuser (username,password) values ('ftpmysqlvuser01',password('ftpmysqlvuser01'));
Query OK, 1 row affected (0.00 sec)

mysql> insert into vuser (username,password) values ('ftpmysqlvuser02',password('ftpmysqlvuser02'));
Query OK, 1 row affected (0.00 sec)

mysql> 


mysql> select * from vuser;
+-----------------+-------------------------------------------+
| username        | password                                  |
+-----------------+-------------------------------------------+
| ftpmysqlvuser02 | *5C76519A80B2A011338A3AD5662FB2F62DC7E493 |
| ftpmysqlvuser01 | *4EC48B48B259CC08FFC677E3D6BED06AAAFB73D1 |
+-----------------+-------------------------------------------+
2 rows in set (0.00 sec)

mysql> 

 
mysql> grant select on vsftp.vuser to 'vsftp'@'localhost' identified by 'ftpvuser';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> 


步骤4：测试该用户是否可以登录
[root@control ~]# mysql -u vsftp -h localhost -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 5.1.71 Source distribution

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| vsftp              |
+--------------------+
2 rows in set (0.00 sec)

mysql> 

 
可以正常登录OK……

步骤5：创建本地映射用户，并修改其家目录权限
[root@control ~]# useradd -s /sbin/nologin vuser
[root@control ~]# echo 'vuser' | passwd --stdin vuser
Changing password for user vuser.
passwd: all authentication tokens updated successfully.
[root@control ~]# 

 
步骤6：修改vsftpd.conf，允许虚拟用户登录
guest_enable=YES:允许虚拟用户登录
guest_username=vuser：指定虚拟用户映射的本地用户，这里为vuser用户。
virtual_use_local_privs=YES：让虚拟用户具有本地用户的权限。
 
步骤7：安装基于PAM认证的MySQL模块（pam_mysql-0.7RC1.tar.gz）
[root@control opt]# yum install -y pam-devel mysql-devel
[root@control opt]# tar -zxvf pam_mysql-0.7RC1.tar.gz 
[root@control opt]# cd pam_mysql-0.7RC1
[root@control pam_mysql-0.7RC1]# ./configure && make && make install

 
步骤8：在/etc/pam.d目录下创建PAM认证模块
[root@control ~]# cat /etc/pam.d/vsftpd_vusermysql
auth required /lib/security/pam_mysql.so user=vsftp passwd=ftpvuser host=localhost \
                                        db=vsftp table=vuser usercolumn=username passwdcolumn=password crypt=2
account required /lib/security/pam_mysql.so user=vsftp passwd=ftpvuser host=localhost \
                                        db=vsftp table=vuser usercolumn=username passwdcolumn=password crypt=2
[root@control ~]# 


说明：
/lib/security/pam_mysql.so为安装的pam_mysql库文件的位置，这里要确认是在lib下，还是在lib64下。
user：指定登录数据库的用户。
passwd：指定用户所对应的密码
host：指定mysql服务器的地址。如果是本地，则为localhost
db：存放虚拟用户的数据库名称
table：存放虚拟用户的表名称
usercolumn：指定存放用户名的字段。
passwdcolumn：指定存放密码的字段。
crypt：指定密码字段是以什么方式存储在数据库中的。crypt=0，则表示以明文的方式保存的，crypt=1则表示crypt()函数加密保存密码，crypt=2则表示以password()函数加密保存密码，crypt=3则表示以md5的方式保存密码的。
 
步骤9：修改vsftpd.conf，指定pam_service_name
pam_service_name=vsftpd_vusermysql

步骤10：如果有需要，请修改user_list文件内容，将虚拟用户增加到该文件
[root@control vsftpd]# cat user_list
anonymous
ftptest01
ftptest02

ftpvuser01
ftpvuser02

ftpmysqlvuser01
ftpmysqlvuser02
[root@control vsftpd]# 
 
步骤11：重启vsftpd服务，并测试 
[root@vm1 ~]# lftp ftpmysqlvuser01:ftpmysqlvuser01@ftp.test.com
lftp ftpmysqlvuser01@ftp.test.com:~> dir
drwxr-xrwx    4 0        0            4096 May 27 03:24 uploads
lftp ftpmysqlvuser01@ftp.test.com:/> cd uploads/
lftp ftpmysqlvuser01@ftp.test.com:/uploads> ls
drwxr-xr-x    2 502      502          4096 May 27 01:59 ftptest01
drwxr-xr-x    2 504      504          4096 May 27 03:24 ftpvuser01
lftp ftpmysqlvuser01@ftp.test.com:/uploads> mkdir ftpvusermysql01
mkdir ok, `ftpvusermysql01' created
lftp ftpmysqlvuser01@ftp.test.com:/uploads> cd ftpvusermysql01/
lftp ftpmysqlvuser01@ftp.test.com:/uploads/ftpvusermysql01> put /etc/hosts
158 bytes transferred                             
lftp ftpmysqlvuser01@ftp.test.com:/uploads/ftpvusermysql01> dir
-rw-r--r--    1 504      504           158 May 27 05:01 hosts
lftp ftpmysqlvuser01@ftp.test.com:/uploads/ftpvusermysql01> 

注意事项：
1. 在使用MySQL对数据加密时，使用password函数加密，因为pam_mysql好像不支持md5。没测试成功。
2. MySQL的password函数产生密钥的长度为41位。可以在mysql中使用select length(password('123'))这种方式测试。

```

# FTPS配置
## 产生证书
产生证书最简单的方式：
步骤：
进入到/etc/pki/tls/certs/目录，然后使用make vsftpd.pem产生一个vsftpd的证书。
生成证书后，将此证书复制或移动到/etc/vsftpd/的目录下。
注意：
make vsftpd.pem，这个文件必须以.pem结尾。

```bash
[root@control vsftpd]# cd /etc/pki/tls/certs/
[root@control certs]# 
[root@control certs]# make vsftpd.pem
umask 77 ; \
	PEM1=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
	PEM2=`/bin/mktemp /tmp/openssl.XXXXXX` ; \
	/usr/bin/openssl req -utf8 -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 -set_serial 0 ; \
	cat $PEM1 >  vsftpd.pem ; \
	echo ""    >> vsftpd.pem ; \
	cat $PEM2 >> vsftpd.pem ; \
	rm -f $PEM1 $PEM2
Generating a 2048 bit RSA private key
......+++
.............................................+++
writing new private key to '/tmp/openssl.PqFoRZ'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Beijing
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:test 
Organizational Unit Name (eg, section) []:test
Common Name (eg, your name or your server's hostname) []:ftp.test.com
Email Address []:test@test.com
[root@control certs]#

[root@control certs]# mv vsftpd.pem /etc/vsftpd/
[root@control certs]# cd /etc/vsftpd/
[root@control vsftpd]# 

```

## 修改配置文件
```bash
# SSL
ssl_enable=YES
ssl_sslv2=NO
ssl_sslv3=YES
ssl_tlsv1=YES
force_local_logins_ssl=YES
force_local_data_ssl=YES
rsa_cert_file=/etc/vsftpd/vsftpd.pem
#rsa_private_key_file
allow_anon_ssl=NO
force_anon_data_ssl=NO
force_anon_logins_ssl=NO
ssl_ciphers=HIGH
```

##测试
![ftps配置](http://img.blog.csdn.net/20160527155637921)
![证书信息](http://img.blog.csdn.net/20160527155915424)



# 其他可能会碰到的问题
## FTP登录慢的问题

修改vsftpd.conf配置文件，修改reverse_lookup_enable将默认的YES设置为NO，并重启vsftpd服务


## 使用FTPS时FileZilla报错

使用FileZilla测试的时候，如果出现如下错误：GnuTLS error -12: A TLS fatal alert has been received时，解决方法如下：
Filezilla最新版本认为vsftpd默认的加密算法"DES-CBC3-SHA"不够安全而拒绝连接导致的。有两种办法解决该问题，一是降级你的Filezilla客户端版本到3.5.3以下，二是更改服务器端vsftpd的配置。增加属性：ssl_ciphers=HIGH

## FTPS跨iptables NAT时无法访问

增加pasv_address，地址为公网地址，外部用户使用被动模式，内部用户使用主动模式即可。