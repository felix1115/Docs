# 查看httpd是否支持SSL
```
[root@vm3 ~]# /usr/local/source/apache22/bin/httpd -M | grep ssl
 ssl_module (shared)
Syntax OK
[root@vm3 ~]# 
```

* 不重新编译apache的情况下支持SSL
```
需要进入到httpd的源码下的modules/ssl目录下
[root@vm3 ssl]# pwd
/opt/httpd-2.2.31/modules/ssl
[root@vm3 ssl]# /usr/local/source/apache22/bin/apxs -i -c -a -D HAVE_OPENSSL=1 -I /usr/include/openssl -lcrypto -lssl -ldl *.c

apxs命令参数说明：
-i：此选项表示需要执行安装操作，以安装一个或多个动态共享对象到服务器的modules目录中。
-a：此选项自动增加一个LoadModule行到httpd.conf文件中，以激活此模块，或者，如果此行已经存在，则启用之。
-A：与 -a 选项类似，但是它增加的LoadModule命令有一个井号前缀(#)，即此模块已经准备就绪但尚未启用。
-c：此选项表示需要执行编译操作。它首先会编译C源程序(.c)files为对应的目标代码文件(.o)，然后连接这些目标代码和files中其余的目标代码文件(.o和.a)，以生成动态共享对象dso file 。如果没有指定 -o 选项，则此输出文件名由files中的第一个文件名推测得到，也就是默认为mod_name.so

```

* rpm包安装的httpd
```
[root@vm01 conf]# yum install -y mod_ssl

[root@vm01 conf]# httpd -M | grep ssl
 ssl_module (shared)
Syntax OK
[root@vm01 conf]# 
```

# HTTPD的HTTPS配置
```
Listen 443

<VirtualHost _default_:443>
	DocumentRoot "/usr/local/source/apache22"
	ServerName www.felix.com:443
	ServerAdmin admin@felix.com
	ErrorLog "/usr/local/source/apache22/logs/error_log"
	TransferLog "/usr/local/source/apache22/logs/access_log"
	SSLEngine on
	SSLCertificateKeyFile "/usr/local/source/apache22/ssl/apache22-key.pem"
	SSLCertificateFile "/usr/local/source/apache22/ssl/apache22-felix_com.crt"
</VirtualHost>
```

# Linux客户端测试
* 指定cacert
```
[root@vm01 CA]# curl --head --cacert /etc/pki/CA/cacert.pem https://www.felix.com
HTTP/1.1 200 OK
Date: Fri, 14 Oct 2016 03:12:45 GMT
Server: Apache
Last-Modified: Thu, 13 Oct 2016 06:08:41 GMT
ETag: "e368b-2f42-53eb8f0f76f61"
Accept-Ranges: bytes
Content-Length: 12098
Content-Type: text/html

[root@vm01 CA]# 
```

* 添加CA证书到ca-bundle.crt文件中
```
[root@vm01 CA]# cat cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt 
[root@vm01 CA]# curl --head https://www.felix.com
HTTP/1.1 200 OK
Date: Fri, 14 Oct 2016 03:36:10 GMT
Server: Apache
Last-Modified: Thu, 13 Oct 2016 06:08:41 GMT
ETag: "e368b-2f42-53eb8f0f76f61"
Accept-Ranges: bytes
Content-Length: 12098
Content-Type: text/html

[root@vm01 CA]# 

```