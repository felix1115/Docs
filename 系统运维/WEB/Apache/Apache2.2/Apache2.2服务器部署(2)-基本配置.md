[ָ��ο�](http://httpd.apache.org/docs/2.2/mod/directives.html)

[����ģ��](http://httpd.apache.org/docs/2.2/en/mod/core.html)

# ��������

* ServerRoot
```
���ã�ָ���������������ļ���error�ļ���log�ļ��Ķ���Ŀ¼����Ҫ��"/"��β����ServerRoot "/usr/local/source/apache22"
```

* Listen
```
���ã�ָ�������������ĵ�ַ�Ͷ˿ڡ�
ʾ����
Listen 80�����������������нӿڵ�80�˿ڡ�
Listen 172.17.100.3:80  ������������172.17.100.3����ӿڵ�80�˿ڡ�

* ָ�����Listen
Listen 80
Listen 8080
��ʾ���Ƿ�����������80��8080�˿ڽ��տͻ��˷���������
```

* User��Group
```
User��ָ����Ӧ�û�������ӽ��̵��û�ID���û�����
Group��ָ����Ӧ�û�������ӽ��̵���ID��������
```

* ServerAdmin
```
���ã�ָ��Apache���ش�����Ϣ���������Ĺ���Ա���䡣
�磺ServerAdmin admin@felix.com
```

* ServerName
```
���ã�����������ʶ���Լ����������Ͷ˿ڡ����û�����ô�ѡ���Apache�᳢�Զ�IP���з���������ƶ�FQDN���Ƽ��ֶ�ָ����
�磺ServerName www.felix.com:80
```

* ServerTokens
```
���ã�ָ���������˷��͵���Ӧͷ(Reponse Header)�е�Server�����ݡ�
OS������Apache�����汾�š��ΰ汾�š�����汾�š�����ϵͳ���磺Server: Apache/2.2.31 (Unix)
Prod������Apache�İ汾���ơ��磺Server: Apache
Major������Apache�����汾�š��磺Server: Apache/2
Minor������Apache�����汾�š��ΰ汾�š��磺Server: Apache/2.2
Minimal������Apache�����汾�š��ΰ汾�š�����汾�š��磺Server: Apache/2.2.31
Full����������ϸ����Ϣ���磺Server: Apache/2.2.31 (Unix) mod_ssl/2.2.31 OpenSSL/1.0.1e-fips DAV/2

������÷�����
ServerTokens Prod
ServerSignature Off
˵���������ServerSignature����ΪOff����������в�����ʾ������ʹ��curl --head���ǻ���ʾ�����Ϣ��
```

* ServerSignature
```
���ã�����Apache�����ɴ���ҳʱ�ĵ���ҳ����Ϣ��
Off���������κ�ҳ����Ϣ��
On������ServerTokens��ص���Ϣ��
Email������ServerTokens��ص���Ϣʱ��ʹ��ServerAdmin��ֵ�ڷ�����IP��ַ������һ��mailto:�����ӡ�

ע�⣺��ͬ�İ汾�У����õ�ֵ��ͬ���еİ汾ΪOff|On|EMail���е�Ϊoff|on|email��
```

* PidFile
```
���ã�ָ��httpd���ڴ洢�������ID���ļ���������ļ�������"/"��ʼ����Ϊ�洢λ�������S
erverRoot�������"/"��ʼ����Ϊ����·����

�磺
<IfModule !mpm_netware_module>
    PidFile "/var/run/httpd/httpd.pid"
</IfModule>
```

* TimeOut
```
���ã���ͨ���ڼ䣬Apache���ڵȴ����ͺͽ������ݵ�ʱ�䡣Ĭ��Ϊ300s
```

* KeepAlive
```
���ã�������ر�HTTP�ĳ־������ӡ��Ƿ���һ��TCP�����д�����HTTP����Ĭ��ΪOn

On����ʾ����KeepAlive���ܡ�������ͬһ��TCP�����з��Ͷ��HTTP����(ÿһ����Դ����һ������)��
Off����ʾ�ر�KleepAive���ܡ�ÿһ��HTTP������Ҫ����һ��TCP���ӡ�
```

* MaxKeepAliveRequests
```
���ã���һ��HTTP�ĳ־����������������HTTP���������������HTTP���������ڸ�ֵʱ������Ͽ����ӡ�Ĭ��Ϊ100

�������Ϊ0�������HTTP������û�����ơ�

��ֵ�������õĴ�Щ��
```

* KeepAliveTimeout
```
���ã���һ��HTTP�־��������У��ڹر�����֮ǰ�ȴ�����ͬһ���ͻ��˵���һ�������ʱ�䡣���յ�һ������ʱ��TimeOut�����õ�ֵ���Ὺʼ��Ч��
Ĭ��Ϊ5s��

��ֵ���õ�Խ������пͻ��˱������ӵĽ�������Խ�ࡣ
```

* AccessFileName
```
���ã�ָ���ֲ�ʽ�����ļ����ļ����ơ�Ĭ��ΪAccessFileName .htaccess������ָ������ļ���

�����øù���ʱ��Apache�ڴ��������ʱ�򣬷������������ĵ�·����ÿһ��Ŀ¼�²��ҵ�һ�����ڵ������ļ������Ҫ�رոù��ܿ�����AllowOverride None��

�磺
AccessFileName .acl

���û�����/usr/local/web/index.htmlʱ�����񽫻����β���/.acl, /usr/.acl, /usr/local/.acl �� /usr/local/web/.acl�����Ż᷵��index.html��
```

* DocumentRoot
```
���ã�ָ����ҳ�ĵ����ڵ�Ŀ¼��
�磺 DocumentRoot "/usr/local/source/apache22/htdocs"
```

* DirectoryIndex
```
���ã����û��������һ��Ŀ¼��ʱ��Ĭ�ϵ���ʾ���ļ��������������β��ҡ�
�磺
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
```

* LoadModule��LoiadFle
```
LoadModule: ����ģ�顣��ʽΪ��LoadModule module module_path
LoadFile: ������ļ�����ʽΪ��LoadFile filename [filename] ... 
```

* Include
```
��ĳЩ�����ļ�Ҳ������������ΪHTTP�������ļ���һ���֡�
�磺Include conf/extra/httpd-mpm.conf
```

* LogLevel
```
���ã�ָ��Ҫ��¼��error_log�е���Ϣ����

���õ�ֵ�У�debug/info/notice/warn/error/crit/alert/emerg��
```

* ErrorLog
```
���ã�ָ��������Ϣ��¼��λ�á������"/"��ʼ����Ϊ����·��������Ϊ�����ServerRoot�����·����

�磺
ErrorLog "logs/error_log"

ע�������������������ErrorLog�������������е�log���¼����ָ����λ�ã�������ȫ��ָ����λ�ã���������������û��ָ��ErrorLog��
```

* LogFormat
```
���ã������û�������־����־�����ʽ��

�磺
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

˵����
\n������
\t���Ʊ��
%%����ʾ�ٷֺ�(%)
%a��Զ�̿ͻ��˵�IP��ַ��
%A�����ط������˵�IP��ַ��
%b����������Ӧ���ֽ�����������HTTPͷ������Ϊ"-"ʱ�����ʾû�з������ݡ�
%B����������Ӧ���ֽ�����������HTTPͷ�������û���ֽڷ��ͣ�����ʾΪ0.
%D���������������ѵ�ʱ�䣬��λΪ΢�롣1s=1000ms, 1ms=1000us
%f���ͻ���������ļ�������ʾ���Ƿ��������������ļ�·�����磺/usr/local/source/apache22/htdocs/index.html
%h��Զ�̿ͻ���������ַ��
%{Foobar}i���ڷ��͵��������˵�����ͷ�е�Foobar�����ݡ���%{User-Agent}i
%H�������Э�顣
%k����ͬһ�������д������������
%l��Զ���û��ĵ�½�������û�У�����ʾ"-"
%m���ͻ�����ʹ�õ�����ʽ����GET/POST/PUT/DELETE��
%{Foobar}n����������ģ���note Foobar������
%p����������������ı�׼�˿ڡ�
%P������������������ӽ���PID��
%q����ѯ�ַ�����
%r������ĵ�һ�����ݡ�
%R������response�Ĵ������(Handler)
%s������״̬�������ڲ��ض��������%s��ʾ����ԭʼ�����״̬��%>s���ʾ������������״̬��
%t�����������ʱ�䡣
%{format}t���Զ�����������ʱ��ĸ�ʽ����%{%Y-%m-%d %H:%M:%S}t��
%T����������������ѵ�ʱ�䣬��λ���롣
%{UNIT}T���������������ѵ�ʱ�䡣UNIT������ms(����)��us(΢��)��s(��)
%u��Զ����֤���û�����
%U���ͻ��������URL·�������������κε�query string��
%v���������˴��������ServerName��
%X���������Ӧ(response)��ʱ�������״̬��X����ʾ����Ӧ���֮ǰ�������ӡ�+����ʾ����Ӧ�������Ժ����ӿ���ʹ��KeepAlive��-����ʾ��Ӧ�����Ժ����ӱ��رա�

��Ҫʹ��mod_logioģ��
%I���������յ����ֽ������������������ͷ��
%O�����������͵��ֽ�����������Ӧͷ��


combined�������һ�����ƣ�����CustomLog�����á�
```

* CustomLog
```
ָ���û��ķ�����־�洢λ�á�
```

* Alias

>��Ҫmod_aliasģ���֧�֡�

```
���ã�ӳ��URL�������ļ�ϵͳ�����ָ�������ĵ��洢�ڱ����ļ�ϵͳ������λ�ö�����DocumentRoot��ָ����λ�á�
�﷨��Alias <URL-PATH> <file-path | directory-path> 
ע�⣺���URL-PATH��"/"��β����file-path������directory-pathҲҪ��"/"��β����֮��Ȼ������Ҫƥ�䡣 

ʾ����
Alias /image  /data/www/image
Alias /image/ /data/www/image/

����ʾ��
1. ��conf/extra/Ŀ¼���½�һ��httpd-test.conf�ļ�
[root@vm3 conf]# more extra/httpd-test.conf
Alias /test/	/data/test/

<Directory "/data/test">
	AllowOverride None
	Options None
	Order allow,deny
	Allow from all
</Directory>
[root@vm3 conf]# 

2. �����ļ���httpd.conf��Include����
[root@vm3 conf]# grep 'httpd-test' httpd.conf 
Include conf/extra/httpd-test.conf
[root@vm3 conf]# 

3. ��/data/testĿ¼�´�������ҳ��
[root@vm3 conf]# cat /data/test/index.html 
<h1>Test Page</h1>
[root@vm3 conf]# 

4. ����
[root@vm01 ~]# curl www.felix.com/test/
<h1>Test Page</h1>
[root@vm01 ~]# 

```

* AliasMatch
```
���ã�ʹ��������ʽӳ��URL�������ļ�ϵͳ��
�﷨��AliasMatch <URL-PATH-REGEXP> <file-path | directory-path> 
ע�⣺��URL-PATH�����û��ʹ��������ʽ������Ҫʹ��AliasMatch���п��ܻ�����ض���������࣬�����޷����ʡ�

����ʾ���� 

1. ��conf/extra/Ŀ¼���½�һ��httpd-test.conf�ļ�
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

2. �����ļ���httpd.conf��Include����
[root@vm3 conf]# grep 'httpd-test' httpd.conf 
Include conf/extra/httpd-test.conf
[root@vm3 conf]# 

3. /dataĿ¼�ṹ
[root@vm3 images]# tree /data/
/data/
������ test
    ������ images
    ��?? ������ jpg
    ��?? ��?? ������ 1.jpg
    ��?? ������ png
    ��??     ������ 1.png
    ������ index.html

4 directories, 3 files
[root@vm3 images]#

4. ����
��LogFormat������[Filename]:%f������鿴��־����������
LogFormat "%h %l %u %t \"%r\" %>s %b [Filename]:%f" common

������־���£�
172.17.100.254 - - [12/Oct/2016:10:28:20 +0800] "GET /test/1.png HTTP/1.1" 304 - [Filename]:/data/test/images/png/1.png
172.17.100.254 - - [12/Oct/2016:10:28:27 +0800] "GET /test/1.jpg HTTP/1.1" 200 2762 [Filename]:/data/test/images/jpg/1.jpg

```

* ScriptAlias
```
���ã�ӳ��URL�������ļ�ϵͳ�����ҽ�Ŀ����ΪCGI�ű���ִ�С�
�﷨��ScriptAlias <url-path> <file-path | directory-path>

ʾ����
ScriptAlias /cgi-bin/ /web/cgi-bin/
<Directory /web/cgi-bin >
	SetHandler cgi-script
	Options ExecCGI
</Directory>
```

* ScriptAliasMatch
```
���ã�ʹ��������ʽӳ��URL�������ļ�ϵͳ�����ҽ�Ŀ����ΪCGI�ű���ִ�С�
�﷨��ScriptAliasMatch <url-path-regexp> <file-path | directory-path>

ʾ����
ScriptAliasMatch ^/cgi-bin(.*) /usr/local/apache/cgi-bin$1
```

* Redirect
```
���ã�����һ���ⲿ���ض���Ҫ��ͻ��˻�ȡһ����ͬ��URL��
�﷨��Redirect [status]  URL-PATH  URL

status���������²��֣�
permanent�������ض���301����ͬ�ڣ�RedirectPermanent ָ��
temp����ʱ�ض���302��Ĭ�ϵġ���ͬ��RedirectTempָ�
seeother������һ��see other״̬,��������Դ�Ѿ����滻��303
gone������һ��410״̬�롣��������Դ���������Ƴ���

ʾ����
Redirect /service http://foo2.example.com/service
Redirect permanent /service http://foo2.example.com/service
Redirect temp /service http://foo2.example.com/service
Redirect 301 /service http://foo2.example.com/service
RedirectPermanent /service http://foo2.example.com/service
```

* ErrorDocument
```
���ã�����������ʱ�����ݴ�����뷵���ض�����Ϣ��
��ʽ��ErrorDocument <3-digit-number-error-code> <document>
˵����
3-digit-number-error-code����ʾ����3λ���ִ�����롣��403��404��500�ȡ�
document����ʾ���صĴ�����Ϣ���������ı���Ϣ(ʹ����������������"page not found")�����ص�URLҳ��(/index.html)���ⲿ��URLҳ��(��http://x.x.x.x/index.html)

ʾ��1����ʾ�ı���Ϣ
ErrorDocument 404 "<h1><i>Page Not Found!!!</i></h1>"

ʾ��2������URL
ErrorDocument 403 /index.html

ʾ��3���ⲿURL
ErrorDocument 500 http://x.x.x.x/index.html
```

# mod_deflateģ��
```
���ã�����Gzip��ѹ�������

1. ����ģ��
LoadModule deflate_module modules/mod_deflate.so

2. ����ѹ�����
SetOutputFilter DEFLATE

�ر�ѹ�������
SetOutputFilter INFLATE

3. ��������ѡ��
DeflateCompressionLevel <1-9>��ָ��ѹ���ȼ�������ԽС��ѹ����Խ�
DeflateBufferSize 8096��ָ��zlibһ�ο���ѹ�������ݴ�С����λΪ�ֽڡ�Ĭ��Ϊ8096�ֽڡ�
DeflateMemLevel <1-9>��ָ��zlib�ڽ���ѹ��ʱ����ʹ�ö��ٵ��ڴ档Ĭ��Ϊ9.
AddOutputFilterByType��ָ��zlib����ѹ�����������͡�
DeflateFilterNote������־�ļ��м�¼ѹ����ص���Ϣ����ʽΪ��DeflateFilterNote [type] <notename>
	type���£�
	Input�������������ֽ����洢��note�С�
	Output������������ֽ����洢��note�С�
	Ratio����ѹ����(output/input * 100)�洢��note�С�


����ʾ����
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

# mod_expiresģ��
```
���ã������ļ��Ļ���ʱ��

1. ����ģ��
LoadModule expires_module modules/mod_expires.so

2. ���û��湦��
ExpiresActive On

�رջ��湦��
ExpiresActive Off

3. ����ָ��MIME���͵��ļ��Ĺ���ʱ��
�﷨��ʽ��ExpiresByType <MIME-Type> <code>seconds
code�����У�A��ʾ�Կͻ��˷��ʸ����͵��ĵ���ʱ����Ϊbase time��M��ʾ���ļ����޸�ʱ����Ϊbase time��

�磺
ExpiresByType text/html	M604800  ��ʾ����HTML�ĵ����������޸�ʱ����604800��(һ��)���ڡ�

4. ���������ĵ���Ĭ�Ϲ���ʱ��
�﷨��ʽ��ExpiresDefault <code>seconds
code�����У�A��ʾ�Կͻ��˷��ʸ����͵��ĵ���ʱ����Ϊbase time��M��ʾ���ļ����޸�ʱ����Ϊbase time��
˵������ָ�������õ�ʱ����Ա�ExpiresByType�����ǡ�

Ҳ����ʹ�����·������ã�
ExpiresDefault "base [plus num type] [num type] ..."
ExpiresByType type/encoding "base [plus num type] [num type] ..."
base�����ǣ�access��now��modification
num����һ��������
type��������years/months/weeks/days/hours/minutes/seconds
ʾ����
ExpiresDefault "access plus 1 month"
ExpiresByType text/html "access plus 1 month 15 days 2 hours"
ExpiresByType image/gif "modification plus 5 hours 3 minutes


����ʾ��1��
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

����ʾ��2��
<IfModule expires_module>
	<FilesMatch \.(jpg|png|jpe?g|html|css|js|xml)$>
		ExpiresActive On
		ExpiresDefault A604800
	</FilesMatch>
</IfModule>
```