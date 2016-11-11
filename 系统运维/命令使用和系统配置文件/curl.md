# curl的使用
* 查看响应头
```
查看响应头：--head 或 -I

[root@vm3 tmp]# curl --head http://www.felix.com
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 11 Nov 2016 03:14:02 GMT
Content-Type: text/html; charset=UTF-8
Content-Length: 12098
Connection: keep-alive
Keep-Alive: timeout=10
Vary: Accept-Encoding
Last-Modified: Wed, 09 Nov 2016 09:35:53 GMT
ETag: "e12c2-2f42-540dafbb51c27"
Accept-Ranges: bytes

[root@vm3 tmp]# 
```

* 下载单个文件
```
1. 输出到标准输出
[root@vm3 ~]# curl http://www.felix.com

2. 保存到指定的文件
-o：保存到命令行中指定的文件中
-O：使用URL中默认的文件名

保存到test.html中
[root@vm3 tmp]# curl -o test.html http://www.felix.com/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0   702k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]# 


使用默认的文件名(index.html)
[root@vm3 tmp]# curl -O http://www.felix.com/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  4327k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]# 

3. 使用输出重定向
[root@vm3 tmp]# curl http://www.felix.com/index.html > a.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  1842k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]#
```

* 同时下载多个文件
```
语法格式：
	curl -O URL1 -O URL2 ...
	curl -o URL1 -o URL2 ...

[root@vm3 tmp]# curl -o test1.html http://www.felix.com/index.html -o test2.html http://www.felix.com/hello/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  1478k      0 --:--:-- --:--:-- --:--:--     0
  0    21    0    21    0     0    170      0 --:--:-- --:--:-- --:--:--   170
[root@vm3 tmp]# 
```

* 使用重定向
```
默认情况下，curl不会对重定向的请求进行再次请求，使用-L选项即可让curl对重定向的请求再次发送HTTP Location header请求。

示例：
[root@vm3 tmp]# curl --head http://www.felix.com/test/
HTTP/1.1 302 Moved Temporarily
Server: nginx
Date: Fri, 11 Nov 2016 03:13:24 GMT
Content-Type: text/html
Content-Length: 154
Connection: keep-alive
Keep-Alive: timeout=10
Location: http://172.17.100.1:8080/test/

[root@vm3 tmp]# 

使用-L选项查看：
[root@vm3 tmp]# curl --head -L http://www.felix.com/test/
HTTP/1.1 302 Moved Temporarily
Server: nginx
Date: Fri, 11 Nov 2016 03:15:30 GMT
Content-Type: text/html
Content-Length: 154
Connection: keep-alive
Keep-Alive: timeout=10
Location: http://172.17.100.1:8080/test/

HTTP/1.1 200 OK
Date: Fri, 11 Nov 2016 06:46:00 GMT
Server: Apache/2.2.15 (CentOS)
Last-Modified: Fri, 11 Nov 2016 03:47:59 GMT
ETag: "ff0da-15-540fe5b35bc2f"
Accept-Ranges: bytes
Content-Length: 21
Connection: close
Content-Type: text/html; charset=UTF-8

[root@vm3 tmp]# 
```

* 断点续传
```
当使用curl下载大文件时，如果出现断开连接的情况，可以使用"-C -"的方式进行断点续传。

[root@vm3 tmp]# curl -O http://www.felix.com/download/download_test
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 37 47.0M   37 17.7M    0     0  92.5M      0 --:--:-- --:--:-- --:--:-- 97.6M^C
[root@vm3 tmp]# du -sh download_test 
39M	download_test
[root@vm3 tmp]# curl -C - -O http://www.felix.com/download/download_test
** Resuming transfer from byte position 40333312
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 8839k  100 8839k    0     0  38.9M      0 --:--:-- --:--:-- --:--:-- 41.6M
[root@vm3 tmp]# du -sh download_test 
48M	download_test
[root@vm3 tmp]# 
```

* 使用#作为进度条
```
[root@vm3 tmp]# curl -# -O http://www.felix.com/download/download_test
######################################################################## 100.0%
[root@vm3 tmp]# 

```

* curl下载限速
```
使用--limit-rate进行限速。单位可以是K/M/G/k/m/g


[root@vm3 tmp]# curl -O http://www.felix.com/download/download_test
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
 37 47.0M   37 17.7M    0     0  92.5M      0 --:--:-- --:--:-- --:--:-- 97.6M^C
[root@vm3 tmp]# du -sh download_test 
39M	download_test
[root@vm3 tmp]# curl -C - -O http://www.felix.com/download/download_test
** Resuming transfer from byte position 40333312
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 8839k  100 8839k    0     0  38.9M      0 --:--:-- --:--:-- --:--:-- 41.6M
[root@vm3 tmp]# du -sh download_test 
48M	download_test
[root@vm3 tmp]# 
```

* curl用户名密码授权
```
指定用户名和密码：curl -u username:password URL
指定用户名：curl -u username URL
从FTP服务器下载指定文件：curl -u username:password -O ftp://ftp.felix.com/test.css
列出FTP服务器上指定目录下的所有目录和文件：curl -u username:password -O ftp://ftp.felix.com/test/
```

* 上传文件到FTP服务器
```
# 将myfile.txt文件上传到服务器
curl -u ftpuser:ftppass -T myfile.txt ftp://ftp.testserver.com

# 同时上传多个文件
curl -u ftpuser:ftppass -T "{file1,file2}" ftp://ftp.testserver.com

# 从标准输入获取内容保存到服务器指定的文件中
curl -u ftpuser:ftppass -T - ftp://ftp.testserver.com/myfile_1.txt
```

* curl使用代理
```
使用-x选项为curl添加代理功能

# 指定代理主机和端口
curl -x proxysever.test.com:3128 http://google.co.in
```

* 使用POST方式提交数据
```
使用-d或者--data选项。

curl --data "param1=value1&param2=value" https://api.github.com
```

* 指定User-Agent
```
-A或者是--user-agent

[root@vm3 tmp]# curl -A "Test" http://www.felix.com/

```

* 指定Referer
```
-e或者是--referer

[root@vm3 tmp]# curl -e "http://www.baidu.com" http://www.felix.com/

```

* curl访问https
```
1. 使用-k或--insecure
curl -k https://www.felix.com

2. 使用--cacert指定ca
curl --cacert zhongjica.cert https://www.felix.com
```