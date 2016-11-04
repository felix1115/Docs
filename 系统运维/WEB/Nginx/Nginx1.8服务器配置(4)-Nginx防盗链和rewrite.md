# Nginx防盗链

> Nginx的防盗链主要使用的是referer模块。


* valid_referers
```
语法：
valid_referers none | blocked | server_names | <string> ...

说明：当在HTTP请求头中有Referer字段，则变量$invalid_referer将会设置为空字符串，否则$invalid_referer将会设置为1. 匹配时不区分大小写

none：表示请求头中没有Referer字段。
blocked：表示请求头中有Referer字段，但是该字段的值已经被防火墙或者是代理服务器删除了，不是以"http://"或者是"https://"开头
server_names：请求头的Referer字段包含其中一个server name。
string：表示任意的字符串。可以是一个server name或者是server name和URI的结合，可以使用在server name的开头和结尾可以使用*。并且不会检查Referer字段的服务器的端口号。
	也可以使用正则表达式进行匹配，如果要使用正则表达式，则第一个符号必须是"~"，并且表达式匹配的内容应该是"http://"或者是"https://"以后的内容。
```

* 配置示例
```
location ~ \.(png|jpg|jpeg|gif)$ {
	valid_referers none blocked server_names
			*.kakaogift.cn  *.kakaogift.com;

	if ($invalid_referer) {
		return 403;
	}   
} 
```