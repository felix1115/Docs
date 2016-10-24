[OpenSSL](https://www.openssl.org/source/)

[HTTPD](http://httpd.apache.org/download.cgi)

[apr和apr-util](http://apr.apache.org/download.cgi)


# Apache2.4源码安装

* 软件依赖
```
Apache2.4依赖于：openssl-1.0.1j.tar.gz、apr-1.5.1.tar.bz2、apr-util-1.5.4.tar.bz2、pcre－devel
```

* 安装pcre和pcre-devel
```
# 源码安装pcre
[root@vm3 apache]# unzip pcre-8.10.zip
[root@vm3 apache]# cd pcre-8.10
[root@vm3 pcre-8.10]# ./configure --prefix=/usr/local/source/pcre
[root@vm3 pcre-8.10]# make
[root@vm3 pcre-8.10]# make install

# 安装pcre-devel
[root@vm3 pcre-8.10]# yum install -y pcre-devel
```

* 安装apr和apr-utils
```
# 安装apr


# 安装apr
[root@vm3 apache]# tar -zxf apr-1.5.2.tar.gz 
[root@vm3 apache]# cd apr-1.5.2
[root@vm3 apr-1.5.2]# ./configure --prefix=/usr/local/source/apr
[root@vm3 apr-1.5.2]# make
[root@vm3 apr-1.5.2]# make install

# 安装apr-utils
[root@vm3 apache]# tar -zxf apr-util-1.5.4.tar.gz 
[root@vm3 apache]# cd apr-util-1.5.4    
[root@vm3 apr-util-1.5.4]# ./configure --prefix=/usr/local/source/apr-utils --with-apr=/usr/local/source/apr
[root@vm3 apr-util-1.5.4]# make
[root@vm3 apr-util-1.5.4]# make install

说明：--with-apr指定apr的安装目录
```

* 安装openssl
```
# 安装
[root@vm3 ~]# tar -zxf openssl-1.0.2j.tar.gz 
[root@vm3 ~]# cd openssl-1.0.2j
[root@vm3 openssl-1.0.2j]# ./config -fPIC --prefix=/usr/local/source/openssl102j enable-shared
[root@vm3 openssl-1.0.2j]# make
[root@vm3 openssl-1.0.2j]# make install

说明：如果没有enable-shared，在httpd编译时会报错

# 创建链接
[root@vm3 ~]# openssl version
OpenSSL 1.0.1e-fips 11 Feb 2013
[root@vm3 ~]# which openssl
/usr/bin/openssl
[root@vm3 ~]# mv /usr/bin/openssl /usr/bin/openssl.bak
[root@vm3 ~]# ln -s /usr/local/source/openssl102j/bin/openssl /usr/bin/openssl
[root@vm3 ~]# 
[root@vm3 ~]# openssl version
OpenSSL 1.0.2j  26 Sep 2016
[root@vm3 ~]# 

```

* 安装Apache 2.4.17
```
[root@vm3 apache]# tar -zxf httpd-2.4.17.tar.gz 
[root@vm3 apache]# cd httpd-2.4.17
[root@vm3 httpd-2.4.17]# ./configure --prefix=/usr/local/source/apache24 --enable-so --enable-module=all --enable-mpms-shared=all --with-mpm=worker --with-zlib --with-pcre=/usr/local/source/pcre --with-apr=/usr/local/source/apr --with-apr-util=/usr/local/source/apr-utils --with-ssl=/usr/local/source/openssl102j
[root@vm3 httpd-2.4.17]# make
[root@vm3 httpd-2.4.17]# make install

说明：
--prefix：安装目录
--sysconfdir:配置文件目录
--enable-so：开启DSO（动态共享对象）。动态装载模块
--enable-ssl：https的功能
--enable-rewrite：地址重写
--enable-cgi：CGI脚本功能
--enable-deflate：提供对内容的压缩传输编码支持。
--enable-expires：激活允许通过配置文件控制HTTP的“Expires：”和“Cache-Control：”头内容，即对网站图片、js、css等内容，提供在客户端游览器缓存的设置。这是apache调优的一个重要选项之一。
--enable-headers：提供允许对HTTP请求头的控制
--with-zlib：压缩功能的函数库
--with-pcre：perl库软件的安装目录
--enable-modules=most：编译常用的模块
--enable-modules=all：编译所有的模块
--enable-mpms-shared=all：支持动态加载MPM模块。
--with-mpm=worker：设置默认启用的MPM模式为worker
```

* 载入SSL模块报错解决
```
错误提示：
[root@vm3 bin]# ./httpd -k start
httpd: Syntax error on line 129 of /usr/local/source/apache24/conf/httpd.conf: Cannot load modules/mod_ssl.so into server: libssl.so.1.0.0: cannot open shared object file: No such file or directory
[root@vm3 bin]# 


解决方法：
[root@vm3 ~]# cp -a /usr/local/source/openssl102j/lib/libssl.so.1.0.0 /usr/lib64/
[root@vm3 ~]# cp -a /usr/local/source/openssl102j/lib/libcrypto.so.1.0.0 /usr/lib64/
[root@vm3 ~]# 


再次启动测试：
[root@vm3 ~]# /usr/local/source/apache24/bin/httpd -k start         
[root@vm3 ~]# netstat -tunlp | grep httpd
tcp        0      0 :::80                       :::*                        LISTEN      34207/httpd         
[root@vm3 ~]# 
```

* 创建运行Apache的用户和组
```
[root@vm3 ~]# groupadd -r www
[root@vm3 ~]# useradd -r -g www -s /sbin/nologin www
[root@vm3 ~]#
```
