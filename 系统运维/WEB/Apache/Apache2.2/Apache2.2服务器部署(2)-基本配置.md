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

注：如果虚拟主机中配置ErrorLog，则虚拟主机中的log会记录在其指定的位置，而不是全局指定的位置，除非虚拟主机中没有指定ErrorLog。
```

* LogFormat
```
作用：定义用户访问日志的日志输出格式。

如：
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

说明：
\n：换行
\t：制表符
%%：表示百分号(%)
%a：远程客户端的IP地址。
%A：本地服务器端的IP地址。
%b：服务器响应的字节数，不包括HTTP头部。当为"-"时，则表示没有发送数据。
%B：服务器响应的字节数，不包括HTTP头部。如果没有字节发送，则显示为0.
%D：处理请求所花费的时间，单位为微秒。1s=1000ms, 1ms=1000us
%f：客户端请求的文件名。显示的是服务器端完整的文件路径。如：/usr/local/source/apache22/htdocs/index.html
%h：远程客户端主机地址。
%{Foobar}i：在发送到服务器端的请求头中的Foobar的内容。如%{User-Agent}i
%H：请求的协议。
%k：在同一个连接中处理的请求数。
%l：远程用户的登陆名。如果没有，则显示"-"
%m：客户端所使用的请求方式。如GET/POST/PUT/DELETE等
%{Foobar}n：来自其他模块的note Foobar的内容
%p：服务器处理请求的标准端口。
%P：服务器处理请求的子进程PID。
%q：查询字符串。
%r：请求的第一行内容。
%R：生成response的处理程序(Handler)
%s：请求状态。对于内部重定向的请求，%s表示的是原始请求的状态，%>s则表示的是最后请求的状态。
%t：接收请求的时间。
%{format}t：自定义接收请求的时间的格式。如%{%Y-%m-%d %H:%M:%S}t。
%T：处理请求的所花费的时间，单位是秒。
%{UNIT}T：处理请求所花费的时间。UNIT可以是ms(毫秒)，us(微秒)，s(秒)
%u：远程认证的用户名。
%U：客户端请求的URL路径名，不包括任何的query string。
%v：服务器端处理请求的ServerName。
%X：当完成响应(response)的时候的连接状态。X：表示在响应完成之前放弃连接。+：表示在响应被发送以后，连接可能使用KeepAlive。-：表示响应发送以后，连接被关闭。

需要使用mod_logio模块
%I：服务器收到的字节数，包括请求和请求头。
%O：服务器发送的字节数，包括响应头。


combined：这个是一个名称，用于CustomLog的引用。
```

* CustomLog
```
指定用户的访问日志存储位置。
```

* Alias

>需要mod_alias模块的支持。

```
作用：映射URL到本地文件系统。这个指令允许文档存储在本地文件系统的其他位置而不是DocumentRoot所指定的位置。
语法：Alias <URL-PATH> <file-path | directory-path> 
注意：如果URL-PATH以"/"结尾，则file-path或者是directory-path也要以"/"结尾，反之亦然，两者要匹配。 

示例：
Alias /image  /data/www/image
Alias /image/ /data/www/image/

配置示例
1. 在conf/extra/目录下新建一个httpd-test.conf文件
[root@vm3 conf]# more extra/httpd-test.conf
Alias /test/	/data/test/

<Directory "/data/test">
	AllowOverride None
	Options None
	Order allow,deny
	Allow from all
</Directory>
[root@vm3 conf]# 

2. 将该文件在httpd.conf中Include进来
[root@vm3 conf]# grep 'httpd-test' httpd.conf 
Include conf/extra/httpd-test.conf
[root@vm3 conf]# 

3. 在/data/test目录下创建测试页面
[root@vm3 conf]# cat /data/test/index.html 
<h1>Test Page</h1>
[root@vm3 conf]# 

4. 测试
[root@vm01 ~]# curl www.felix.com/test/
<h1>Test Page</h1>
[root@vm01 ~]# 

```

* AliasMatch
```
作用：使用正则表达式映射URL到本地文件系统。
语法：AliasMatch <URL-PATH-REGEXP> <file-path | directory-path> 
注意：在URL-PATH中如果没有使用正则表达式，则不需要使用AliasMatch，有可能会造成重定向次数过多，导致无法访问。

配置示例： 

1. 在conf/extra/目录下新建一个httpd-test.conf文件
[root@vm3 conf]# cat extra/httpd-test.conf 
AliasMatch /test/(.*)\.jpg$	/data/test/images/jpg/$1.jpg
AliasMatch /test/(.*)\.png$	/data/test/images/png/$1.png

<Directory "/data/test/images/*">
	AllowOverride None
	Options None
	Order allow,deny
	Allow from all
</Directory>
[root@vm3 conf]# 

2. 将该文件在httpd.conf中Include进来
[root@vm3 conf]# grep 'httpd-test' httpd.conf 
Include conf/extra/httpd-test.conf
[root@vm3 conf]# 

3. /data目录结构
[root@vm3 images]# tree /data/
/data/
└── test
    ├── images
    │?? ├── jpg
    │?? │?? └── 1.jpg
    │?? └── png
    │??     └── 1.png
    └── index.html

4 directories, 3 files
[root@vm3 images]#

4. 测试
在LogFormat中增加[Filename]:%f，方便查看日志，设置如下
LogFormat "%h %l %u %t \"%r\" %>s %b [Filename]:%f" common

访问日志如下：
172.17.100.254 - - [12/Oct/2016:10:28:20 +0800] "GET /test/1.png HTTP/1.1" 304 - [Filename]:/data/test/images/png/1.png
172.17.100.254 - - [12/Oct/2016:10:28:27 +0800] "GET /test/1.jpg HTTP/1.1" 200 2762 [Filename]:/data/test/images/jpg/1.jpg

```

* ScriptAlias
```
作用：映射URL到本地文件系统，并且将目标作为CGI脚本来执行。
语法：ScriptAlias <url-path> <file-path | directory-path>

示例：
ScriptAlias /cgi-bin/ /web/cgi-bin/
<Directory /web/cgi-bin >
	SetHandler cgi-script
	Options ExecCGI
</Directory>
```

* ScriptAliasMatch
```
作用：使用正则表达式映射URL到本地文件系统，并且将目标作为CGI脚本来执行。
语法：ScriptAliasMatch <url-path-regexp> <file-path | directory-path>

示例：
ScriptAliasMatch ^/cgi-bin(.*) /usr/local/apache/cgi-bin$1
```

* Redirect
```
作用：发送一个外部的重定向，要求客户端获取一个不同的URL。
语法：Redirect [status]  URL-PATH  URL

status可以是如下部分：
permanent：永久重定向。301。等同于：RedirectPermanent 指令
temp：临时重定向。302，默认的。等同于RedirectTemp指令。
seeother：返回一个see other状态,表明该资源已经被替换。303
gone：返回一个410状态码。表明该资源被永久性移除。

示例：
Redirect /service http://foo2.example.com/service
Redirect permanent /service http://foo2.example.com/service
Redirect temp /service http://foo2.example.com/service
Redirect 301 /service http://foo2.example.com/service
RedirectPermanent /service http://foo2.example.com/service
```

* ErrorDocument
```
作用：当遇到错误时，根据错误代码返回特定的信息。
格式：ErrorDocument <3-digit-number-error-code> <document>
说明：
3-digit-number-error-code：表示的是3位数字错误代码。如403、404、500等。
document：表示返回的错误信息。可以是文本信息(使用引号引起来。如"page not found")、本地的URL页面(/index.html)、外部的URL页面(如http://x.x.x.x/index.html)

示例1：显示文本信息
ErrorDocument 404 "<h1><i>Page Not Found!!!</i></h1>"

示例2：本地URL
ErrorDocument 403 /index.html

示例3：外部URL
ErrorDocument 500 http://x.x.x.x/index.html
```

# mod_deflate模块
```
作用：启用Gzip的压缩输出。

1. 载入模块
LoadModule deflate_module modules/mod_deflate.so

2. 启用压缩输出
SetOutputFilter DEFLATE

关闭压缩输出：
SetOutputFilter INFLATE

3. 其他配置选项
DeflateCompressionLevel <1-9>：指定压缩等级。数字越小，压缩比越差。
DeflateBufferSize 8096：指定zlib一次可以压缩的数据大小。单位为字节。默认为8096字节。
DeflateMemLevel <1-9>：指定zlib在进行压缩时可以使用多少的内存。默认为9.
AddOutputFilterByType：指定zlib可以压缩的数据类型。
DeflateFilterNote：在日志文件中记录压缩相关的信息。格式为：DeflateFilterNote [type] <notename>
	type如下：
	Input：将输入流的字节数存储在note中。
	Output：将输出流的字节数存储在note中。
	Ratio：将压缩比(output/input * 100)存储在note中。


配置示例：
LoadModule deflate_module modules/mod_deflate.so
<IfModule deflate_module>
	SetOutputFilter DEFLATE
	AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/x-javascript
	DeflateCompressionLevel 6
	DeflateBufferSize 8096
	DeflateMemLevel 9
	DeflateFilterNote Input instream
	DeflateFilterNote Output outstream
	DeflateFilterNote Ratio ratio

	LogFormat '"%r" %{outstream}n/%{instream}n (%{ratio}n%%)' deflate
	CustomLog logs/deflate_log deflate
</IfModule>

```

# mod_expires模块
```
作用：设置文件的缓存时间

1. 载入模块
LoadModule expires_module modules/mod_expires.so

2. 启用缓存功能
ExpiresActive On

关闭缓存功能
ExpiresActive Off

3. 设置指定MIME类型的文件的过期时间
语法格式：ExpiresByType <MIME-Type> <code>seconds
code类型有：A表示以客户端访问该类型的文档的时间作为base time。M表示以文件的修改时间作为base time。

如：
ExpiresByType text/html	M604800  表示的是HTML文档将会在其修改时间后的604800秒(一周)过期。

4. 设置所有文档的默认过期时间
语法格式：ExpiresDefault <code>seconds
code类型有：A表示以客户端访问该类型的文档的时间作为base time。M表示以文件的修改时间作为base time。
说明：该指定所设置的时间可以被ExpiresByType所覆盖。

也可以使用如下方法设置：
ExpiresDefault "base [plus num type] [num type] ..."
ExpiresByType type/encoding "base [plus num type] [num type] ..."
base可以是：access、now、modification
num：是一个整数。
type：可以是years/months/weeks/days/hours/minutes/seconds
示例：
ExpiresDefault "access plus 1 month"
ExpiresByType text/html "access plus 1 month 15 days 2 hours"
ExpiresByType image/gif "modification plus 5 hours 3 minutes


配置示例1：
LoadModule expires_module modules/mod_expires.so
<IfModule expires_module>
	ExpiresActive On
	ExpiresByType text/html	M259200
	ExpiresByType text/css  M259200
	ExpiresByType text/plain  M259200
	ExpiresByType text/xml  M259200
	ExpiresByType text/javascript  M259200
	ExpiresByType application/javascript  M259200
	ExpiresByType application/x-javascript  M259200
	ExpiresDefault M86400
</IfModule>

配置示例2：
<IfModule expires_module>
	<FilesMatch \.(jpg|png|jpe?g|html|css|js|xml)$>
		ExpiresActive On
		ExpiresDefault A604800
	</FilesMatch>
</IfModule>
```