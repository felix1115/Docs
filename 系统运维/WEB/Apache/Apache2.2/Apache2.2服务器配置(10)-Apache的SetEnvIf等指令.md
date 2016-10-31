# SetEnvIf��SetEnvIfNoCase
```
���ã����ݿͻ�����������ֵ���û���������
�﷨��SetEnvIf attribute regex [!]env-variable[=value] [[!]env-variable[=value]] ...

˵��������(attribute)���������µ�����:1)HTTP����ͷ�ֶΡ���Host��Accept-Language��Referer��User-Agent�ȡ�2)Ҳ������Remote_Host/Remote_Addr/Request_Method��

regex����ʾ����������ʽ

SetEnvIfNoCase��ʾ�����ִ�Сд��
```


* ʾ��1��ָ���������ʲ���¼����־�ļ�
```
vim httpd.conf

SetEnvIf REMOTE_ADDR "172\.17\.100\.254" dontlog

CustomLog "logs/access_log" common env=!dontlog
```

* ʾ��2������ָ��Ŀ¼����¼����־�ļ�
```
vim httpd.conf

SetEnvIf REQUEST_URI "^/xcache(/.*)?" dontlog

CustomLog "logs/access_log" common env=!dontlog
```

* ʾ��3��ֻ����ָ������������Ŀ¼���������������ض���
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