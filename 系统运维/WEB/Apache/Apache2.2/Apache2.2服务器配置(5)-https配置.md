# �鿴httpd�Ƿ�֧��SSL
```
[root@vm3 ~]# /usr/local/source/apache22/bin/httpd -M | grep ssl
 ssl_module (shared)
Syntax OK
[root@vm3 ~]# 
```

* �����±���apache�������֧��SSL
```
��Ҫ���뵽httpd��Դ���µ�modules/sslĿ¼��
[root@vm3 ssl]# pwd
/opt/httpd-2.2.31/modules/ssl
[root@vm3 ssl]# /usr/local/source/apache22/bin/apxs -i -c -a -D HAVE_OPENSSL=1 -I /usr/include/openssl -lcrypto -lssl -ldl *.c

apxs�������˵����
-i����ѡ���ʾ��Ҫִ�а�װ�������԰�װһ��������̬������󵽷�������modulesĿ¼�С�
-a����ѡ���Զ�����һ��LoadModule�е�httpd.conf�ļ��У��Լ����ģ�飬���ߣ���������Ѿ����ڣ�������֮��
-A���� -a ѡ�����ƣ����������ӵ�LoadModule������һ������ǰ׺(#)������ģ���Ѿ�׼����������δ���á�
-c����ѡ���ʾ��Ҫִ�б�������������Ȼ����CԴ����(.c)filesΪ��Ӧ��Ŀ������ļ�(.o)��Ȼ��������ЩĿ������files�������Ŀ������ļ�(.o��.a)�������ɶ�̬�������dso file �����û��ָ�� -o ѡ��������ļ�����files�еĵ�һ���ļ����Ʋ�õ���Ҳ����Ĭ��Ϊmod_name.so

```

* rpm����װ��httpd
```
[root@vm01 conf]# yum install -y mod_ssl

[root@vm01 conf]# httpd -M | grep ssl
 ssl_module (shared)
Syntax OK
[root@vm01 conf]# 
```

# HTTPD��HTTPS����
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

# Linux�ͻ��˲���
* ָ��cacert
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

* ���CA֤�鵽ca-bundle.crt�ļ���
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