[cobbler����](http://cobbler.github.io)
[cobbler����](http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/noarch/)
[libyaml����](http://pkgs.repoforge.org/libyaml/)

# Cobbler��װ
## �������ʲ�������
```
1. ��Ҫʹ�õ������
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

3. ��װCobbler
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

