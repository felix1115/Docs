# ��ȡ�ͻ�����ʵIP��ַ
## mod_rpafģ��

> ��ģ��apache2.2֧�֣�apache2.4��֧�֡�


* ��װmod_rpaf
```
[root@vm3 ~]# tar -zxf mod_rpaf-0.6.tar.gz 
[root@vm3 ~]# cd mod_rpaf-0.6
[root@vm3 mod_rpaf-0.6]#      
[root@vm3 mod_rpaf-0.6]# /usr/local/source/apache22/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c

----------------------------------------------------------------------
chmod 755 /usr/local/source/apache22/modules/mod_rpaf-2.0.so
[root@vm3 mod_rpaf-0.6]# 

[root@vm3 mod_rpaf-0.6]# ls -l /usr/local/source/apache22/modules/mod_rpaf-2.0.so 
-rwxr-xr-x 1 root root 29609 Oct 24 08:25 /usr/local/source/apache22/modules/mod_rpaf-2.0.so
[root@vm3 mod_rpaf-0.6]# 
```

* ��־�ļ�����
```
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" TEST
```

* ����mod_rpafģ��
```
vim httpd.conf

LoadModule rpaf_module  modules/mod_rpaf-2.0.so
```

* ����mod_rpaf
```
<IfModule rpaf_module>
	RPAFenable On
	RPAFsethostname On
	RPAFproxy_ips 127.0.0.1
	RPAFheader X-Forwarded-For
</IfModule>

˵����
RPAFproxy_ips��ָ�������������IP��ַ���м�����Ӽ�����
```

## mod_remoteipģ��

> ��ģ����Apache2.4���Դ�ģ�飬Apache2.2Ҳ֧�ָ�ģ�顣�Ƽ�ʹ��

* Apache2.2��װmod_remoteip
```
[root@vm3 ~]# wget https://github.com/ttkzw/mod_remoteip-httpd22/blob/master/mod_remoteip.c
[root@vm3 ~]# /usr/local/source/apache22/bin/apxs -i -c -n mod_remoteip.so mod_remoteip.c
```

* Apache2.2 �޸������ļ�
```
vim /usr/local/source/apache22/conf/httpd.conf
Include conf/extra/httpd-remoteip.conf

vim /usr/local/source/apache22/conf/extra/httpd-remoteip.conf

LoadModule remoteip_module modules/mod_remoteip.so

RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1


��־���ã�
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" TEST
```

* Apache2.4�����ļ�
```
���ڸ�ģ����Apache2.4�Դ�ģ�飬ֻ��Ҫ�޸���־�ļ����ɡ�

LogFormat "%h %a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

��LogFormat������%a���ɡ�
```