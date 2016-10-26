# PHP安装
[PHP安装](https://github.com/felix1115/Docs/blob/master/%E7%B3%BB%E7%BB%9F%E8%BF%90%E7%BB%B4/WEB/PHP/PHP5.6%E9%83%A8%E7%BD%B2(1)-%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85.md)

# 配置HTTPD
```
1. 查看PHP模块
[root@vm3 apache22]# ls -l modules/libphp5.so 
-rwxr-xr-x 1 root root 31953008 Oct 26 13:03 modules/libphp5.so
[root@vm3 apache22]# 

2. 载入php模块
vim /usr/local/source/apache22/conf/httpd.conf

LoadModule php5_module        modules/libphp5.so

3. DirectoryIndex中增加index.php

<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>

4. 增加测试页
[root@vm3 htdocs]# cat index.php 
<?php
	phpinfo();
?>
[root@vm3 htdocs]#

5. 重启httpd
[root@vm3 htdocs]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 htdocs]#

6. 测试
[root@vm3 htdocs]# curl --head 172.17.100.3
HTTP/1.1 200 OK
Date: Wed, 26 Oct 2016 05:41:20 GMT
Server: Apache
X-Powered-By: PHP/5.6.16
Cache-Control: max-age=259200
Expires: Sat, 29 Oct 2016 05:41:20 GMT
Vary: Accept-Encoding
Content-Type: text/html; charset=UTF-8

[root@vm3 htdocs]# 

```

* 报错解决
```
[root@vm3 htdocs]# /etc/init.d/httpd graceful
httpd: Syntax error on line 167 of /usr/local/apache2/conf/httpd.conf: Cannot load modules/libphp5.so into server: /usr/local/apache2/modules/libphp5.so: undefined symbol: libiconv
[root@vm3 htdocs]#

解决方法：找到libiconv.so这个库文件，并在httpd.conf中使用LoadFile载入。
[root@vm3 htdocs]# ls -l /usr/local/lib/libiconv.*
-rw-r--r-- 1 root root     912 Nov 27 13:09 /usr/local/lib/libiconv.la
lrwxrwxrwx 1 root root      17 Nov 27 13:09 /usr/local/lib/libiconv.so -> libiconv.so.2.5.1
lrwxrwxrwx 1 root root      17 Nov 27 13:09 /usr/local/lib/libiconv.so.2 -> libiconv.so.2.5.1
-rw-r--r-- 1 root root 1308844 Nov 27 13:09 /usr/local/lib/libiconv.so.2.5.1
[root@vm3 htdocs]#
LoadFile /usr/local/lib/libiconv.so.2.5.1
LoadModule php5_module        modules/libphp5.so
```