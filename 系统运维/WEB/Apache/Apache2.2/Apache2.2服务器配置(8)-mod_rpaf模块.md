# 获取客户端真实IP地址
## mod_rpaf模块

> 该模块apache2.2支持，apache2.4不支持。


* 安装mod_rpaf
```
[root@vm3 ~]# tar -zxf mod_rpaf-0.6.tar.gz 
[root@vm3 ~]# cd mod_rpaf-0.6
[root@vm3 mod_rpaf-0.6]#      
[root@vm3 mod_rpaf-0.6]# /usr/local/source/apache22/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c

----------------------------------------------------------------------
chmod 755 /usr/local/source/apache22/modules/mod_rpaf-2.0.so
[root@vm3 mod_rpaf-0.6]# 

[root@vm3 mod_rpaf-0.6]# ls -l /usr/local/source/apache22/modules/mod_rpaf-2.0.so 
-rwxr-xr-x 1 root root 29609 Oct 24 08:25 /usr/local/source/apache22/modules/mod_rpaf-2.0.so
[root@vm3 mod_rpaf-0.6]# 
```

* 日志文件配置
```
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" TEST
```

* 载入mod_rpaf模块
```
vim httpd.conf

LoadModule rpaf_module  modules/mod_rpaf-2.0.so
```

* 配置mod_rpaf
```
<IfModule rpaf_module>
	RPAFenable On
	RPAFsethostname On
	RPAFproxy_ips 127.0.0.1
	RPAFheader X-Forwarded-For
</IfModule>

说明：
RPAFproxy_ips：指定代理服务器的IP地址，有几个添加几个。
```

## mod_remoteip模块

> 该模块是Apache2.4的自带模块，Apache2.2也支持该模块。推荐使用

* Apache2.2安装mod_remoteip
```
[root@vm3 ~]# wget https://github.com/ttkzw/mod_remoteip-httpd22/blob/master/mod_remoteip.c
[root@vm3 ~]# /usr/local/source/apache22/bin/apxs -i -c -n mod_remoteip.so mod_remoteip.c
```

* Apache2.2 修改配置文件
```
vim /usr/local/source/apache22/conf/httpd.conf
Include conf/extra/httpd-remoteip.conf

vim /usr/local/source/apache22/conf/extra/httpd-remoteip.conf

LoadModule remoteip_module modules/mod_remoteip.so

RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1


日志配置：
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" TEST
```

* Apache2.4配置文件
```
由于该模块是Apache2.4自带模块，只需要修改日志文件即可。

LogFormat "%h %a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

在LogFormat中增加%a即可。
```