```
说明：让用户只能通过SFTP的方式连接到服务器进行上传和下载，不能使用SSH方式登陆到服务器。
```

# 配置步骤
1. 检查OpenSSH的版本
```
版本必须大于4.8p1

[root@control ~]# ssh -V
OpenSSH_5.3p1, OpenSSL 1.0.1e-fips 11 Feb 2013
[root@control ~]# 
```

2. 修改/etc/ssh/sshd_config文件
```
# override default of no subsystems
#Subsystem	sftp	/usr/libexec/openssh/sftp-server

Subsystem sftp internal-sftp
Match Group sftp
    ChrootDirectory /data/sftp/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
[root@control ~]# 

说明：%u表示用户的用户名
```

3. 创建用户和组

* 创建sftp组
```
[root@control ~]# groupadd sftp
[root@control ~]# 
```

* 创建用户并加入到sftp组
```
[root@control ~]# useradd -s /sbin/nologin -M -d /data/sftp/user01 -G sftp user01
[root@control ~]# passwd user01
Changing password for user user01.
New password: 
BAD PASSWORD: it is based on a dictionary word
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@control ~]# 
```

* 创建目录并修改权限

```
说明：当启用了chroot后，chroot所指定的目录的拥有着必须是root，且其他用户和组不能具有写权限，因此必须要在chroot目录下创建一个目录用于文件的上传。

[root@control ~]# mkdir -p /data/sftp/user01/upload
[root@control ~]# 
[root@control ~]# chown user01:sftp /data/sftp/user01/upload
[root@control ~]# chmod 750 /data/sftp/user01/upload
[root@control ~]# 
[root@control ~]# ls -ld /data/sftp/user01
drwxr-xr-x 3 root root 4096 Sep  9 11:04 /data/sftp/user01
[root@control ~]# ls -ld /data/sftp/user01/upload/
drwxr-x--- 2 user01 sftp 4096 Sep  9 11:04 /data/sftp/user01/upload/
[root@control ~]# 

```

* 重启SSH服务并测试
```
[root@control ~]# /etc/init.d/sshd restart
Stopping sshd:                                             [  OK  ]
Starting sshd:                                             [  OK  ]
[root@control ~]# 

[root@vm1 ~]# sftp user01@172.17.100.250
Connecting to 172.17.100.250...
user01@172.17.100.250's password: 
sftp> dir
upload  
sftp> cd upload
sftp> pwd
Remote working directory: /upload
sftp> put /etc/issue
Uploading /etc/issue to /upload/issue
/etc/issue                                                                                                                                                                      100%   47     0.1KB/s   00:00      
sftp> ls -l
-rw-r--r--    1 505      506            47 Sep  9 03:51 issue
sftp> cd /etc
Couldn't canonicalise: No such file or directory
sftp> 


SSH测试：
[root@vm1 ~]# ssh user01@172.17.100.250
user01@172.17.100.250's password: 
This service allows sftp connections only.
Connection to 172.17.100.250 closed.
[root@vm1 ~]# 

```