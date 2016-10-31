# SetEnvIf和SetEnvIfNoCase
```
作用：根据客户端请求属性值设置环境变量。
语法：SetEnvIf attribute regex [!]env-variable[=value] [[!]env-variable[=value]] ...

说明：属性(attribute)可以是如下的内容:1)HTTP请求头字段。如Host、Accept-Language、Referer、User-Agent等。2)也可以是Remote_Host/Remote_Addr/Request_Method等

regex：表示的是正则表达式

SetEnvIfNoCase表示不区分大小写。
```


* 示例1：指定主机访问不记录到日志文件
```
vim httpd.conf

SetEnvIf REMOTE_ADDR "172\.17\.100\.254" dontlog

CustomLog "logs/access_log" common env=!dontlog
```

* 示例2：访问指定目录不记录到日志文件
```
vim httpd.conf

SetEnvIf REQUEST_URI "^/xcache(/.*)?" dontlog

CustomLog "logs/access_log" common env=!dontlog
```

* 示例3：只允许指定到主机访问目录，其他主机访问重定向
```
vim httpd.conf

SetEnvIf REMOTE_ADDR "172\.17\.100\.1" accept=1

<Directory "/usr/local/source/apache22/htdocs/test">
	Options None
	AllowOverride None
	Order Allow,Deny
	Allow from env=accept
</Directory>

RewriteEngine on
RewriteLogLevel 2
RewriteLog	"logs/rewrite.log"

RewriteCond %{ENV:accept} !1
RewriteRule ^/test(/.*)? /index.php [R=301]

```