[cobbler官网](http://cobbler.github.io)
[cobbler下载](http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/noarch/)
[libyaml下载](http://pkgs.repoforge.org/libyaml/)

# Cobbler安装
## 机器访问不了外网
```
1. 需要使用的软件包
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

3. 安装Cobbler
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

