[指令参考](http://httpd.apache.org/docs/2.2/mod/directives.html)

[核心模块](http://httpd.apache.org/docs/2.2/en/mod/core.html)

# 基本配置

* ServerRoot
```
作用：指定服务器的配置文件、error文件和log文件的顶层目录。不要以"/"结尾。如ServerRoot "/usr/local/source/apache22"
```

* Listen
```
作用：指定服务器监听的地址和端口。
示例：
Listen 80：服务器监听在所有接口的80端口。
Listen 172.17.100.3:80  服务器监听在172.17.100.3这个接口的80端口。

* 指定多个Listen
Listen 80
Listen 8080
表示的是服务器将会在80和8080端口接收客户端发来的请求。
```

* User和Group
```
User：指定响应用户请求的子进程的用户ID或用户名。
Group：指定响应用户请求的子进程的组ID或组名。
```

* ServerAdmin
```
作用：指定Apache返回错误信息中所包含的管理员邮箱。
如：ServerAdmin admin@felix.com
```

* ServerName
```
作用：服务器用于识别自己的主机名和端口。如果没有配置此选项，则Apache会尝试对IP进行反向解析来推断FQDN，推荐手动指定。
如：ServerName www.felix.com:80
```

* ServerTokens
```
作用：指定服务器端发送的响应头(Reponse Header)中的Server的内容。
OS：返回Apache的主版本号、次版本号、编译版本号、操作系统。如：Server: Apache/2.2.31 (Unix)
Prod：返回Apache的版本名称。如：Server: Apache
Major：返回Apache的主版本号。如：Server: Apache/2
Minor：返回Apache的主版本号、次版本号。如：Server: Apache/2.2
Minimal：返回Apache的主版本号、次版本号、编译版本号。如：Server: Apache/2.2.31
Full：返回最详细的信息。如：Server: Apache/2.2.31 (Unix) mod_ssl/2.2.31 OpenSSL/1.0.1e-fips DAV/2

最佳设置方法：
ServerTokens Prod
ServerSignature Off
说明：如果将ServerSignature设置为Off，在浏览器中不会显示，但是使用curl --head还是会显示相关信息。
```

* ServerSignature
```
作用：配置Apache在生成错误页时文档的页脚信息。
Off：不生成任何页脚信息。
On：生成ServerTokens相关的信息。
Email：生成ServerTokens相关的信息时，使用ServerAdmin的值在服务器IP地址上增加一个mailto:的链接。

注意：不同的版本中，设置的值不同。有的版本为Off|On|EMail，有的为off|on|email。
```

* PidFile
```
作用：指定httpd用于存储服务进程ID的文件。如果该文件不是以"/"开始，则为存储位置相对于S
erverRoot，如果以"/"开始，则为绝对路径。

如：
<IfModule !mpm_netware_module>
    PidFile "/var/run/httpd/httpd.pid"
</IfModule>
```

* TimeOut
```
作用：在通信期间，Apache用于等待发送和接收数据的时间。默认为300s

```

* KeepAlive
```
作用：开启或关闭HTTP的持久性连接。是否在一个TCP连接中传输多个HTTP请求。默认为On

On：表示开启KeepAlive功能。允许在同一个TCP连接中发送多个HTTP请求(每一个资源都是一个请求)。
Off：表示关闭KleepAive功能。每一个HTTP请求都需要建立一个TCP连接。
```

* MaxKeepAliveRequests
```
作用：在一个HTTP的持久性连接中允许传输的HTTP请求数，当传输的HTTP请求数大于该值时，将会断开连接。默认为100

如果设置为0，则传输的HTTP请求数没有限制。

该值建议设置的大些。
```

* KeepAliveTimeout
```
作用：在一个HTTP持久性连接中，在关闭连接之前等待来自同一个客户端的下一个请求的时间。当收到一个请求时，TimeOut所设置的值将会开始生效。
默认为5s。

该值设置的越大，与空闲客户端保持连接的进程数就越多。
```

* AccessFileName
```
作用：指定分布式配置文件的文件名称。默认为AccessFileName .htaccess。可以指定多个文件。

当启用该功能时，Apache在处理请求的时候，服务器将会在文档路径的每一个目录下查找第一个存在的配置文件。如果要关闭该功能可以用AllowOverride None。

如：
AccessFileName .acl

当用户访问/usr/local/web/index.html时，服务将会依次查找/.acl, /usr/.acl, /usr/local/.acl 和 /usr/local/web/.acl，最后才会返回index.html。

```

* DocumentRoot
```
作用：指定网页文档所在的目录。
如： DocumentRoot "/usr/local/source/apache22/htdocs"
```

* DirectoryIndex
```
作用：当用户请求的是一个目录的时候，默认的显示的文件名。从左到右依次查找。
如：
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
```

* LoadModule和LoiadFle
```
LoadModule: 载入模块。格式为：LoadModule module module_path
LoadFile: 载入库文件。格式为：LoadFile filename [filename] ... 
```

* Include
```
将某些配置文件也包含进来，作为HTTP的配置文件的一部分。
如：Include conf/extra/httpd-mpm.conf
```

* LogLevel
```
作用：指定要记录在error_log中的消息级别。
可用的值有：debug/info/notice/warn/error/crit/alert/emerg。

```

* ErrorLog
```
作用：指定错误消息记录的位置。如果以"/"开始，则为绝对路径，否则为相对于ServerRoot的相对路径。
如：
ErrorLog "logs/error_log"

```
