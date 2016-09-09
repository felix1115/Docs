```
˵�������û�ֻ��ͨ��SFTP�ķ�ʽ���ӵ������������ϴ������أ�����ʹ��SSH��ʽ��½����������
```

# ���ò���
1. ���OpenSSH�İ汾
```
�汾�������4.8p1

[root@control ~]# ssh -V
OpenSSH_5.3p1, OpenSSL 1.0.1e-fips 11 Feb 2013
[root@control ~]# 
```

2. �޸�/etc/ssh/sshd_config�ļ�
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

˵����%u��ʾ�û����û���
```

3. �����û�����

* ����sftp��
```
[root@control ~]# groupadd sftp
[root@control ~]# 
```

* �����û������뵽sftp��
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

* ����Ŀ¼���޸�Ȩ��

```
˵������������chroot��chroot��ָ����Ŀ¼��ӵ���ű�����root���������û����鲻�ܾ���дȨ�ޣ���˱���Ҫ��chrootĿ¼�´���һ��Ŀ¼�����ļ����ϴ���

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

* ����SSH���񲢲���
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


SSH���ԣ�
[root@vm1 ~]# ssh user01@172.17.100.250
user01@172.17.100.250's password: 
This service allows sftp connections only.
Connection to 172.17.100.250 closed.
[root@vm1 ~]# 

```