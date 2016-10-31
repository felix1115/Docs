# 正则表达式介绍
* 锚定
```
^：锚定行首
$：锚定行尾
\<：锚定词首
\>：锚定词尾
\b：锚定单词边界。也可以作为锚定词首和词尾用。
```

* 次数
```
*：前一个字符出现0次或多次。
?：前一个字符出现0次或1次。
+：前一个字符出现1次或多次。
{n}：前一个字符出现n次。
{n,}：前一个字符出现n次以上。
{n,m}：前一个字符出现n到m次。
```

* 分组和范围
```
.：匹配任意单个字符。
.*：匹配任意长度的任意字符。
(a|b)：匹配a或b
(...)：分组。
[abc]：范围。匹配a或b或c
[^abc]：范围。排除a或b或c
[a-z]：范围。匹配a-z
[A-Z]：范围。匹配A-Z
[a-zA-Z]：范围。匹配a-zA-Z。
[0-9]：范围。匹配0到9。
```

* 转义字符
```
\：对特殊字符进行转义。
```

* 必须转义的字符
```
^   $   [   .   *    +   ?   (  )   {    \    |    >    <
```

* 特殊字符
```
\n：换行。
\t：水平制表符。
\v：纵向制表符。
```

* 后向引用
```
$1：引用第一个分组
$2：引用第二个分组
$n：引用第n个分组
```

* POSIX
```
[:upper:]：所有的大写字母。A-Z
[:lower:]：所有的小写字母。a-z
[:alpha:]：所有的字母，包括大写字母和小写字母。
[:digit:]：数字。0-9
[:alnum:]：所有的字母和数字。
[:blank:]：空格和制表符。
[:space:]：空白字符。
[:punct:]：标点符号。
[:graph:]：可打印字符。
[:print:]：可打印字符和空格。
```

# Rewrite
## Rewrite介绍
* 虚拟主机启用Rewrite

> 在设置rewrite规则时，在httpd.conf中设置的rewrite不会被VirtualHost继承，如果VirtualHost需要使用httpd.conf中的rewrite规则，则需要在VirtualHost中做如下设置

```
<VirtualHost *:80>
    RewriteEngine On
    RewriteOptions Inherit
</VirtualHost>
```

* Rewrite相关命令
```
1. RewriteEngine
作用：是否启用Rewrite功能。
启用：RewriteEngine on
禁用：RewriteEngine off
说明：如果虚拟主机要配置Rewrite功能，则每一个虚拟主机里面都要配置RewriteEngine on

2. RewriteLogLevel
作用：将Rewrite信息写入到日志文件的log等级。默认为0，则表示关闭Rewrite日志功能。如果是9或者更高数字，则表示记录所有的Rewrite行为到log文件。
注意：如果使用的值超过2，则会影响其性能。如果需要开启debug功能，则可以将其设置的值超过2.

3. RewriteLog
作用：记录Rewrite相关的信息到指定的文件。

Rewrite日志文件的格式
-----------------------------------------------------------------------------------------------------------------
		Description											Example
-----------------------------------------------------------------------------------------------------------------
Remote host IP address							192.168.200.166
-----------------------------------------------------------------------------------------------------------------
Remote login name								Will usually be “-“
-----------------------------------------------------------------------------------------------------------------
HTTP user auth name								Username, or “-” if no auth
-----------------------------------------------------------------------------------------------------------------
Date and time of request						[28/Aug/2009:13:09:09 –0400]
-----------------------------------------------------------------------------------------------------------------
Virtualhost and virtualhost ID					[www.example.com/sid#84a650]
-----------------------------------------------------------------------------------------------------------------
Request ID, and whether it’s a subrequest		[rid#9f0e58/subreq]
-----------------------------------------------------------------------------------------------------------------
Log entry severity level						(2)
-----------------------------------------------------------------------------------------------------------------
Text error message								forcing proxy-throughput with http://127.0.0.1:8080/index.html
-----------------------------------------------------------------------------------------------------------------

```

* RewriteCond

> 语法格式：RewriteCond <TestString> <CondPattern> [FLAGS]
> 定义RewriteRule生效的条件。即在一个RewriteRule指令之前可以有一个或多个RewriteCond。RewriteRule生效的条件是：要满足RewriteCond所定义的TestString和CondPattern之间的匹配，同时还要满足多个RewriteCond之间的逻辑关系。

```
1. TestString
表示要检测的内容。可以是如下信息：
	* 服务器变量。
	* RewriteRule的后向引用，引用方法是$N。N的范围是0-9。
	* RewriteCond的后向引用，引用方法是%N。N的范围是0-9。引用当前若干RewriteCond条件中最后符合的条件中的分组部分。
	* %{ENV:variable}。根据环境变量进行设置。
	
2. CondPattern
表示TestString需要匹配的内容。是一个正则表达式。
还有一些检测如下：
	'-d'：测试TestString是否为一个存在的目录
	'-f'：测试TestString是否为一个存在的文件
	'-s'：测试TestString是否为一个存在的非空文件
	'-l'：测试TestString是否为一个存在的符号链接
	'-x'：测试TestString是否为一个存在的、具有可执行权限的文件。

	说明：可以在上述条件的前面使用'!'，对其进行取反。
	
3. FLAGS
逗号分隔的一组标记列表。
NC：忽略大小写。表示TestString和CondPattern的比较是忽略大小写的。也就是说A-Z和a-z是一样的。
OR：表示各个RewriteCond之间的判断条件为OR,而不是默认的AND。
```
![RewriteCond配置示例](https://github.com/felix1115/Docs/blob/master/Images/rewrite-1.png)

* RewriteRule

![RewriteRule语法](https://github.com/felix1115/Docs/blob/master/Images/rewrite-2.png)


```
1. Pattern
表示使用正则表达式匹配的请求的URL路径。

匹配的含义
* Rewrite使用在虚拟主机中：Pattern表示匹配的是在host和port之后，query string之前的URL。如：/app1/index.html
* Rewrite使用在Directory和.htaccess中：Pattern表示去掉前导的"/"之后的文件系统路径。如app/index.html或者是index.html，这个依赖于Rewrite指令所定义的位置。

如果要想使用.htaccess中配置Rewrite，需要在目录中启用FollowSymLinks,并在.htaccess中启用RewriteEngin On。

2. Substitution 
用于替换被Pattern匹配的URL。
Substitution 可以是如下内容：
	* 文件系统路径。指定资源在文件系统中的位置。
	* URL路径。rewrite将会根据所指定的路径的第一部分判断该路径是相对于DocumentRoot的URL路径还是文件系统路径。如果用户指定的路径(如/www/index.html)的第一部分(/www)存在于根文件系统上，则为文件系统路径，否则为URL路径。
	* 绝对URL。如http://www.felix.com/index.html 在这种情况下，rewrite模块将会检查这个主机名是否和当前的主机名匹配，如果匹配，则协议和主机名将会剥离出来，剩下的部分将会作为一个URL路径。否则的话，将会执行外部重定向。
	* -。表示不会执行任何替换。

	除了上述几个，还可以是：
	* $N：后向引用RewriteRule的Pattern。
	* %N：后向引用最后一个被RewriteCond匹配的Pattern。
	* 服务器变量。如% {SERVER_NAME}
	
3. FLAGS
	* C：该标记使得该规则和其下面的规则相链接，当该规则执行失败时，其后面的规则将不会执行。
	* F：返回403 Forbidden状态码。
	* G：返回410 GONE状态码。
	* L：立即停止重写操作，并不再应用其他重写规则。这个标记用于阻止当前已被重写的URL被后继规则再次重写。等同于break
	* N：重新执行重写操作(从第一个规则重新开始)。此时再次进行处理的URL已经不是原始的URL了，而是经最后一个重写规则处理过的URL。等同于continue。注意：不要制造死循环
	* NC：忽略大小写。
	* NE：此标记阻止mod_rewrite对重写结果应用常规的URI转义规则。 一般情况下，特殊字符('%', '$', ';'等)会被转义为等值的十六进制编码('%25', '%24', '%3B'等)。此标记可以阻止这样的转义，以允许百分号等符号出现在输出中
	* NS：在当前请求是一个内部子请求时，此标记强制重写引擎跳过该重写规则。
	* R[=code]：强制外部重定向。如果没有指定code，则为302.
	* E=VAR:VAL  设置环境变量的值。
```

# Apache服务器变量
```
* HTTP_USER_AGENT
返回用户所使用的浏览器信息。如：User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36

* HTTP_REFERER
链接到当前页面的前一页的URL地址。如：Referer:http://172.17.100.3/mac.html

* HTTP_HOST
当前请求的 Host: 头信息的内容。如：Host:172.17.100.3

* HTTP_ACCEPT
当前请求的 Accept: 头信息的内容。如：Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8

* DOCUMENT_ROOT
当前运行脚本所在的文档根目录。如：/usr/local/source/apache22/htdocs

* SERVER_ADMIN
该值指明了Apache服务器配置文件中的SERVER_ADMIN参数。如果脚本运行在一个虚拟主机上，则该值是那个虚拟主机的值。如：admin@felix.com

* SERVER_NAME
返回客户端当前访问的IP地址或域名。如果客户端使用IP地址访问，则SERVER_NAME是IP地址，如果用域名访问，则是域名。如：www.felix.com

* SERVER_ADDR
返回服务器的IP地址。如：172.17.100.3

* SERVER_PORT
返回服务器所使用的端口号。如80

* SERVER_PROTOCOL
请求页面时通信协议的名称和版本。例如，“HTTP/1.1”。

* SERVER_SOFTWARE
服务器标识的字串，在响应请求时的头信息中给出。 如Server: Apache

* REMOTE_ADDR
正在浏览当前页面用户的IP地址。如172.17.100.254

* REMOTE_HOST
正在浏览当前页面用户的主机名。反向域名解析基于该用户的REMOTE_ADDR，如果无法反向解析，则为客户端的IP地址。如本地测试返回127.0.0.1

* REMOTE_PORT
用户连接到服务器时所使用的端口。

* REQUEST_METHOD
访问页面时的请求方法。例如："GET"/"POST"/"HEAD"/"PUT"

* SCRIPT_FILENAME
CGI脚本的完整路径。如：SCRIPT_FILENAME = /usr/local/source/apache22/cgi-bin/test-cgi

* SCRIPT_NAME
CGI脚本的名称。如：SCRIPT_NAME = /cgi-bin/test-cgi

* QUERY_STRING
查询字符串(URL 中第一个问号 ? 之后的内容)

* AUTH_TYPE
使用HTTP认证时，所使用的认证类型。

* THE_REQUEST
整个HTTP请求的URI部分。

* REQUEST_URI
访问此页面所需的URI。例如，“/index.html”

* REQUEST_FILENAME
当前所请求的文件的绝对路径名。在Apache中，省略了DOCUEMENT_ROOT。如绝对路径为：/usr/local/source/apache22/htdocs/index.html，则SCRIPT_FILENAME为/index.html

* HTTPS
如果连接使用 SSL/TLS 模式, 则值为on , 否则值为off, 这个参数比较安全, 即使未载入 mod_ssl 模块时.

```

# HTTP Rewrite测试
## 80重定向到443
```
配置：httpd-test.conf
RewriteEngine on
RewriteLogLevel 2
RewriteLog	"logs/rewrite.log"

# port 80 + felix.com or www.felix.com
RewriteCond %{SERVER_PORT} 80
RewriteCond %{SERVER_NAME} (www.)?felix\.com
RewriteRule ^/(.*) https://www.felix.com/$1 [R=301]

# port 80 + host ip (172.17.100.3)
RewriteCond %{SERVER_PORT} 80 [OR]
RewriteCond %{SERVER_PORT} 443
RewriteCond %{SERVER_NAME} 172\.17\.100\.3
RewriteRule ^/(.*) https://www.felix.com/$1 [R=301]

虚拟主机配置：httpd-ssl.conf
RewriteEngine On
RewriteOptions Inherit

```

## 图片防盗链
```
RewriteEngine On
RewriteCond %{HTTP_REFERER} !^(http|https)://www.felix.com [NC] 
RewriteRule \.(jpg|jpeg|png)$ https://www.felix.com/error.jpg
```