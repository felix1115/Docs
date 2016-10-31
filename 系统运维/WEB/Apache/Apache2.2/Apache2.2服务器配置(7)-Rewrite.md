# ������ʽ����
* ê��
```
^��ê������
$��ê����β
\<��ê������
\>��ê����β
\b��ê�����ʱ߽硣Ҳ������Ϊê�����׺ʹ�β�á�
```

* ����
```
*��ǰһ���ַ�����0�λ��Ρ�
?��ǰһ���ַ�����0�λ�1�Ρ�
+��ǰһ���ַ�����1�λ��Ρ�
{n}��ǰһ���ַ�����n�Ρ�
{n,}��ǰһ���ַ�����n�����ϡ�
{n,m}��ǰһ���ַ�����n��m�Ρ�
```

* ����ͷ�Χ
```
.��ƥ�����ⵥ���ַ���
.*��ƥ�����ⳤ�ȵ������ַ���
(a|b)��ƥ��a��b
(...)�����顣
[abc]����Χ��ƥ��a��b��c
[^abc]����Χ���ų�a��b��c
[a-z]����Χ��ƥ��a-z
[A-Z]����Χ��ƥ��A-Z
[a-zA-Z]����Χ��ƥ��a-zA-Z��
[0-9]����Χ��ƥ��0��9��
```

* ת���ַ�
```
\���������ַ�����ת�塣
```

* ����ת����ַ�
```
^   $   [   .   *    +   ?   (  )   {    \    |    >    <
```

* �����ַ�
```
\n�����С�
\t��ˮƽ�Ʊ����
\v�������Ʊ����
```

* ��������
```
$1�����õ�һ������
$2�����õڶ�������
$n�����õ�n������
```

* POSIX
```
[:upper:]�����еĴ�д��ĸ��A-Z
[:lower:]�����е�Сд��ĸ��a-z
[:alpha:]�����е���ĸ��������д��ĸ��Сд��ĸ��
[:digit:]�����֡�0-9
[:alnum:]�����е���ĸ�����֡�
[:blank:]���ո���Ʊ����
[:space:]���հ��ַ���
[:punct:]�������š�
[:graph:]���ɴ�ӡ�ַ���
[:print:]���ɴ�ӡ�ַ��Ϳո�
```

# Rewrite
## Rewrite����
* ������������Rewrite

> ������rewrite����ʱ����httpd.conf�����õ�rewrite���ᱻVirtualHost�̳У����VirtualHost��Ҫʹ��httpd.conf�е�rewrite��������Ҫ��VirtualHost������������

```
<VirtualHost *:80>
    RewriteEngine On
    RewriteOptions Inherit
</VirtualHost>
```

* Rewrite�������
```
1. RewriteEngine
���ã��Ƿ�����Rewrite���ܡ�
���ã�RewriteEngine on
���ã�RewriteEngine off
˵���������������Ҫ����Rewrite���ܣ���ÿһ�������������涼Ҫ����RewriteEngine on

2. RewriteLogLevel
���ã���Rewrite��Ϣд�뵽��־�ļ���log�ȼ���Ĭ��Ϊ0�����ʾ�ر�Rewrite��־���ܡ������9���߸������֣����ʾ��¼���е�Rewrite��Ϊ��log�ļ���
ע�⣺���ʹ�õ�ֵ����2�����Ӱ�������ܡ������Ҫ����debug���ܣ�����Խ������õ�ֵ����2.

3. RewriteLog
���ã���¼Rewrite��ص���Ϣ��ָ�����ļ���

Rewrite��־�ļ��ĸ�ʽ
-----------------------------------------------------------------------------------------------------------------
		Description											Example
-----------------------------------------------------------------------------------------------------------------
Remote host IP address							192.168.200.166
-----------------------------------------------------------------------------------------------------------------
Remote login name								Will usually be ��-��
-----------------------------------------------------------------------------------------------------------------
HTTP user auth name								Username, or ��-�� if no auth
-----------------------------------------------------------------------------------------------------------------
Date and time of request						[28/Aug/2009:13:09:09 �C0400]
-----------------------------------------------------------------------------------------------------------------
Virtualhost and virtualhost ID					[www.example.com/sid#84a650]
-----------------------------------------------------------------------------------------------------------------
Request ID, and whether it��s a subrequest		[rid#9f0e58/subreq]
-----------------------------------------------------------------------------------------------------------------
Log entry severity level						(2)
-----------------------------------------------------------------------------------------------------------------
Text error message								forcing proxy-throughput with http://127.0.0.1:8080/index.html
-----------------------------------------------------------------------------------------------------------------

```

* RewriteCond

> �﷨��ʽ��RewriteCond <TestString> <CondPattern> [FLAGS]
> ����RewriteRule��Ч������������һ��RewriteRuleָ��֮ǰ������һ������RewriteCond��RewriteRule��Ч�������ǣ�Ҫ����RewriteCond�������TestString��CondPattern֮���ƥ�䣬ͬʱ��Ҫ������RewriteCond֮����߼���ϵ��

```
1. TestString
��ʾҪ�������ݡ�������������Ϣ��
	* ������������
	* RewriteRule�ĺ������ã����÷�����$N��N�ķ�Χ��0-9��
	* RewriteCond�ĺ������ã����÷�����%N��N�ķ�Χ��0-9�����õ�ǰ����RewriteCond�����������ϵ������еķ��鲿�֡�
	* %{ENV:variable}�����ݻ��������������á�
	
2. CondPattern
��ʾTestString��Ҫƥ������ݡ���һ��������ʽ��
����һЩ������£�
	'-d'������TestString�Ƿ�Ϊһ�����ڵ�Ŀ¼
	'-f'������TestString�Ƿ�Ϊһ�����ڵ��ļ�
	'-s'������TestString�Ƿ�Ϊһ�����ڵķǿ��ļ�
	'-l'������TestString�Ƿ�Ϊһ�����ڵķ�������
	'-x'������TestString�Ƿ�Ϊһ�����ڵġ����п�ִ��Ȩ�޵��ļ���

	˵��������������������ǰ��ʹ��'!'���������ȡ����
	
3. FLAGS
���ŷָ���һ�����б�
NC�����Դ�Сд����ʾTestString��CondPattern�ıȽ��Ǻ��Դ�Сд�ġ�Ҳ����˵A-Z��a-z��һ���ġ�
OR����ʾ����RewriteCond֮����ж�����ΪOR,������Ĭ�ϵ�AND��
```
![RewriteCond����ʾ��](https://github.com/felix1115/Docs/blob/master/Images/rewrite-1.png)

* RewriteRule

![RewriteRule�﷨](https://github.com/felix1115/Docs/blob/master/Images/rewrite-2.png)


```
1. Pattern
��ʾʹ��������ʽƥ��������URL·����

ƥ��ĺ���
* Rewriteʹ�������������У�Pattern��ʾƥ�������host��port֮��query string֮ǰ��URL���磺/app1/index.html
* Rewriteʹ����Directory��.htaccess�У�Pattern��ʾȥ��ǰ����"/"֮����ļ�ϵͳ·������app/index.html������index.html�����������Rewriteָ���������λ�á�

���Ҫ��ʹ��.htaccess������Rewrite����Ҫ��Ŀ¼������FollowSymLinks,����.htaccess������RewriteEngin On��

2. Substitution 
�����滻��Patternƥ���URL��
Substitution �������������ݣ�
	* �ļ�ϵͳ·����ָ����Դ���ļ�ϵͳ�е�λ�á�
	* URL·����rewrite���������ָ����·���ĵ�һ�����жϸ�·���������DocumentRoot��URL·�������ļ�ϵͳ·��������û�ָ����·��(��/www/index.html)�ĵ�һ����(/www)�����ڸ��ļ�ϵͳ�ϣ���Ϊ�ļ�ϵͳ·��������ΪURL·����
	* ����URL����http://www.felix.com/index.html ����������£�rewriteģ�齫��������������Ƿ�͵�ǰ��������ƥ�䣬���ƥ�䣬��Э���������������������ʣ�µĲ��ֽ�����Ϊһ��URL·��������Ļ�������ִ���ⲿ�ض���
	* -����ʾ����ִ���κ��滻��

	���������������������ǣ�
	* $N����������RewriteRule��Pattern��
	* %N�������������һ����RewriteCondƥ���Pattern��
	* ��������������% {SERVER_NAME}
	
3. FLAGS
	* C���ñ��ʹ�øù����������Ĺ��������ӣ����ù���ִ��ʧ��ʱ�������Ĺ��򽫲���ִ�С�
	* F������403 Forbidden״̬�롣
	* G������410 GONE״̬�롣
	* L������ֹͣ��д������������Ӧ��������д����������������ֹ��ǰ�ѱ���д��URL����̹����ٴ���д����ͬ��break
	* N������ִ����д����(�ӵ�һ���������¿�ʼ)����ʱ�ٴν��д����URL�Ѿ�����ԭʼ��URL�ˣ����Ǿ����һ����д���������URL����ͬ��continue��ע�⣺��Ҫ������ѭ��
	* NC�����Դ�Сд��
	* NE���˱����ֹmod_rewrite����д���Ӧ�ó����URIת����� һ������£������ַ�('%', '$', ';'��)�ᱻת��Ϊ��ֵ��ʮ�����Ʊ���('%25', '%24', '%3B'��)���˱�ǿ�����ֹ������ת�壬������ٷֺŵȷ��ų����������
	* NS���ڵ�ǰ������һ���ڲ�������ʱ���˱��ǿ����д������������д����
	* R[=code]��ǿ���ⲿ�ض������û��ָ��code����Ϊ302.
	* E=VAR:VAL  ���û���������ֵ��
```

# Apache����������
```
* HTTP_USER_AGENT
�����û���ʹ�õ��������Ϣ���磺User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36

* HTTP_REFERER
���ӵ���ǰҳ���ǰһҳ��URL��ַ���磺Referer:http://172.17.100.3/mac.html

* HTTP_HOST
��ǰ����� Host: ͷ��Ϣ�����ݡ��磺Host:172.17.100.3

* HTTP_ACCEPT
��ǰ����� Accept: ͷ��Ϣ�����ݡ��磺Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8

* DOCUMENT_ROOT
��ǰ���нű����ڵ��ĵ���Ŀ¼���磺/usr/local/source/apache22/htdocs

* SERVER_ADMIN
��ֵָ����Apache�����������ļ��е�SERVER_ADMIN����������ű�������һ�����������ϣ����ֵ���Ǹ�����������ֵ���磺admin@felix.com

* SERVER_NAME
���ؿͻ��˵�ǰ���ʵ�IP��ַ������������ͻ���ʹ��IP��ַ���ʣ���SERVER_NAME��IP��ַ��������������ʣ������������磺www.felix.com

* SERVER_ADDR
���ط�������IP��ַ���磺172.17.100.3

* SERVER_PORT
���ط�������ʹ�õĶ˿ںš���80

* SERVER_PROTOCOL
����ҳ��ʱͨ��Э������ƺͰ汾�����磬��HTTP/1.1����

* SERVER_SOFTWARE
��������ʶ���ִ�������Ӧ����ʱ��ͷ��Ϣ�и����� ��Server: Apache

* REMOTE_ADDR
���������ǰҳ���û���IP��ַ����172.17.100.254

* REMOTE_HOST
���������ǰҳ���û��������������������������ڸ��û���REMOTE_ADDR������޷������������Ϊ�ͻ��˵�IP��ַ���籾�ز��Է���127.0.0.1

* REMOTE_PORT
�û����ӵ�������ʱ��ʹ�õĶ˿ڡ�

* REQUEST_METHOD
����ҳ��ʱ�����󷽷������磺"GET"/"POST"/"HEAD"/"PUT"

* SCRIPT_FILENAME
CGI�ű�������·�����磺SCRIPT_FILENAME = /usr/local/source/apache22/cgi-bin/test-cgi

* SCRIPT_NAME
CGI�ű������ơ��磺SCRIPT_NAME = /cgi-bin/test-cgi

* QUERY_STRING
��ѯ�ַ���(URL �е�һ���ʺ� ? ֮�������)

* AUTH_TYPE
ʹ��HTTP��֤ʱ����ʹ�õ���֤���͡�

* THE_REQUEST
����HTTP�����URI���֡�

* REQUEST_URI
���ʴ�ҳ�������URI�����磬��/index.html��

* REQUEST_FILENAME
��ǰ��������ļ��ľ���·��������Apache�У�ʡ����DOCUEMENT_ROOT�������·��Ϊ��/usr/local/source/apache22/htdocs/index.html����SCRIPT_FILENAMEΪ/index.html

* HTTPS
�������ʹ�� SSL/TLS ģʽ, ��ֵΪon , ����ֵΪoff, ��������Ƚϰ�ȫ, ��ʹδ���� mod_ssl ģ��ʱ.

```

# HTTP Rewrite����
## 80�ض���443
```
���ã�httpd-test.conf
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

�����������ã�httpd-ssl.conf
RewriteEngine On
RewriteOptions Inherit

```

## ͼƬ������
```
RewriteEngine On
RewriteCond %{HTTP_REFERER} !^(http|https)://www.felix.com [NC] 
RewriteRule \.(jpg|jpeg|png)$ https://www.felix.com/error.jpg
```