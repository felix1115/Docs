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

```
