# Nginx SSL

> ��Ҫ�ڱ���ʱ��ָ��--with-http_ssl_module��������Ҫopenssl���֧�֡����²�����û������ָ����������http��server���С�


* ssl
```
Ĭ��Ϊoff��
on������HTTPS
off���ر�HTTPS

�Ƽ���listen��ʹ��ssl���磺listen 443 ssl
```

* ssl_buffer_size
```
Ĭ��ֵ��ssl_buffer_size 16k;
���ã�ָ�����ڷ������ݵĻ����С��
```

* ssl_certificate
```
���ã�ָ��һ��PEM��ʽ�ķ�����֤���ļ���λ�á�
```

* ssl_certificate_key
```
���ã�ָ��һ��PEM��ʽ�ķ�����˽Կ�ļ���λ�á�
```

* ssl_ciphers
```
Ĭ��ֵ��ssl_ciphers HIGH:!aNULL:!MD5
���ã�ָ��ʹ�õ�ciphers��������openssl ciphers����鿴��
����ʾ����
ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:!ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:!RC4-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!CBC:!EDH:!kEDH:!PSK:!SRP:!kECDH;
```

* ssl_protocols
```
Ĭ��ֵ��ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
���ã�ָ��ssl��ʹ�õ�Э�顣��Ч��ֵ�У�SSLv2 ��SSLv3��TLSv1��TLSv1.1��TLSv1.2��Ӧ��ֻ����ssl_protocols TLSv1 TLSv1.1 TLSv1.2

ֻ�е�OpenSSL�İ汾����1.0.1�ſ���ʹ��TLSv1.1��TLSv1.2
```

* ssl_prefer_server_ciphers 
```
Ĭ��ֵ��ssl_prefer_server_ciphers off
���ã���ʹ��SSLv3��TLSʱ���������˵�ciphers�Ƿ���Ը��ǿͻ��˵�ciphers����ʹ��TLSʱ��Ҫָ��Ϊon��
```

* ssl_session_cache
```
�﷨��ʽ��ssl_session_cache off | none | [builtin[:size]] [shared:name:size];
Ĭ��ֵ��ssl_session_cache none;
���ã�ָ���洢session�����Ļ������ͺ�ֵ��

off��session cache���ϸ��ֹ��nginx����ȷ�ĸ��߿ͻ���session���ᱻ���á�
none��session cacheͨ�����ᱻ����ʹ�á�nginx����߿ͻ���session���ܻᱻ���ã�����nginxͨ�����Ὣsession�����洢�ڻ����С�
builtin:<size>����ʾʹ��OpenSSL�ڽ���cache�����Ǹ�cacheֻ�ܱ�һ��worker����ʹ�á�sizeָ�����Դ洢���ٸ�session�����û��ָ��size�������20480��session��ʹ���ڽ���cache�������ڴ���Ƭ��
shared:<name>:<size> ������worker����֮�乲���cache��size�Ĵ�СΪbytes��1M��cache���Դ洢���4000��session��ÿһ�������cache����һ�����֣�ͬһ�����ֵ�cache�������ڶ������������

����ʾ����
ssl_session_cache shared:gift:10m;
```

* ssl_session_timeout
```
Ĭ��ֵ��ssl_session_timeout 5m;
���ã��ͻ��˿�������session������ʱ�䡣�ڸ��¼���Χ�ڣ��ͻ��˿�������session������
```

# Ϊ�˼���CPU���ص��Ƽ�����
1. ����worker���̵�������CPU��������
2. ����keepalive
3. ����shared session cache
4. �ر��ڽ���session cache
5. ����session lifetime(Ĭ��5����)

# ����ʾ��
```
server {
    listen 443 ssl;
    server_name www.felix.com felix.com;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_certificate ssl/apache22-felix_com.crt;
    ssl_certificate_key ssl/apache22-key.pem;
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:!ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:!RC4-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!CBC:!EDH:!kEDH:!PSK:!SRP:!kECDH;
    ssl_prefer_server_ciphers on; 

    ssl_session_cache shared:gift:10m;
    ssl_session_timeout 10m;

    location / { 
        root html;
        index index.html;
    }   
}
```