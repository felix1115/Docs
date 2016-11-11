# curl��ʹ��
* �鿴��Ӧͷ
```
�鿴��Ӧͷ��--head �� -I

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

* ���ص����ļ�
```
1. �������׼���
[root@vm3 ~]# curl http://www.felix.com

2. ���浽ָ�����ļ�
-o�����浽��������ָ�����ļ���
-O��ʹ��URL��Ĭ�ϵ��ļ���

���浽test.html��
[root@vm3 tmp]# curl -o test.html http://www.felix.com/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0   702k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]# 


ʹ��Ĭ�ϵ��ļ���(index.html)
[root@vm3 tmp]# curl -O http://www.felix.com/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  4327k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]# 

3. ʹ������ض���
[root@vm3 tmp]# curl http://www.felix.com/index.html > a.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  1842k      0 --:--:-- --:--:-- --:--:--     0
[root@vm3 tmp]#
```

* ͬʱ���ض���ļ�
```
�﷨��ʽ��
	curl -O URL1 -O URL2 ...
	curl -o URL1 -o URL2 ...

[root@vm3 tmp]# curl -o test1.html http://www.felix.com/index.html -o test2.html http://www.felix.com/hello/index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12098  100 12098    0     0  1478k      0 --:--:-- --:--:-- --:--:--     0
  0    21    0    21    0     0    170      0 --:--:-- --:--:-- --:--:--   170
[root@vm3 tmp]# 
```

* ʹ���ض���
```
Ĭ������£�curl������ض������������ٴ�����ʹ��-Lѡ�����curl���ض���������ٴη���HTTP Location header����

ʾ����
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

ʹ��-Lѡ��鿴��
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

* �ϵ�����
```
��ʹ��curl���ش��ļ�ʱ��������ֶϿ����ӵ����������ʹ��"-C -"�ķ�ʽ���жϵ�������

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

* ʹ��#��Ϊ������
```
[root@vm3 tmp]# curl -# -O http://www.felix.com/download/download_test
######################################################################## 100.0%
[root@vm3 tmp]# 

```

* curl��������
```
ʹ��--limit-rate�������١���λ������K/M/G/k/m/g


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

* curl�û���������Ȩ
```
ָ���û��������룺curl -u username:password URL
ָ���û�����curl -u username URL
��FTP����������ָ���ļ���curl -u username:password -O ftp://ftp.felix.com/test.css
�г�FTP��������ָ��Ŀ¼�µ�����Ŀ¼���ļ���curl -u username:password -O ftp://ftp.felix.com/test/
```

* �ϴ��ļ���FTP������
```
# ��myfile.txt�ļ��ϴ���������
curl -u ftpuser:ftppass -T myfile.txt ftp://ftp.testserver.com

# ͬʱ�ϴ�����ļ�
curl -u ftpuser:ftppass -T "{file1,file2}" ftp://ftp.testserver.com

# �ӱ�׼�����ȡ���ݱ��浽������ָ�����ļ���
curl -u ftpuser:ftppass -T - ftp://ftp.testserver.com/myfile_1.txt
```

* curlʹ�ô���
```
ʹ��-xѡ��Ϊcurl��Ӵ�����

# ָ�����������Ͷ˿�
curl -x proxysever.test.com:3128 http://google.co.in
```

* ʹ��POST��ʽ�ύ����
```
ʹ��-d����--dataѡ�

curl --data "param1=value1&param2=value" https://api.github.com
```

* ָ��User-Agent
```
-A������--user-agent

[root@vm3 tmp]# curl -A "Test" http://www.felix.com/

```

* ָ��Referer
```
-e������--referer

[root@vm3 tmp]# curl -e "http://www.baidu.com" http://www.felix.com/

```

* curl����https
```
1. ʹ��-k��--insecure
curl -k https://www.felix.com

2. ʹ��--cacertָ��ca
curl --cacert zhongjica.cert https://www.felix.com
```