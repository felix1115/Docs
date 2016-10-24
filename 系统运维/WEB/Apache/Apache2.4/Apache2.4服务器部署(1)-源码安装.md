[OpenSSL](https://www.openssl.org/source/)

[HTTPD](http://httpd.apache.org/download.cgi)

[apr��apr-util](http://apr.apache.org/download.cgi)


# Apache2.4Դ�밲װ

* �������
```
Apache2.4�����ڣ�openssl-1.0.1j.tar.gz��apr-1.5.1.tar.bz2��apr-util-1.5.4.tar.bz2��pcre��devel
```

* ��װpcre��pcre-devel
```
# Դ�밲װpcre
[root@vm3 apache]# unzip pcre-8.10.zip
[root@vm3 apache]# cd pcre-8.10
[root@vm3 pcre-8.10]# ./configure --prefix=/usr/local/source/pcre
[root@vm3 pcre-8.10]# make
[root@vm3 pcre-8.10]# make install

# ��װpcre-devel
[root@vm3 pcre-8.10]# yum install -y pcre-devel
```

* ��װapr��apr-utils
```
# ��װapr


# ��װapr
[root@vm3 apache]# tar -zxf apr-1.5.2.tar.gz 
[root@vm3 apache]# cd apr-1.5.2
[root@vm3 apr-1.5.2]# ./configure --prefix=/usr/local/source/apr
[root@vm3 apr-1.5.2]# make
[root@vm3 apr-1.5.2]# make install

# ��װapr-utils
[root@vm3 apache]# tar -zxf apr-util-1.5.4.tar.gz 
[root@vm3 apache]# cd apr-util-1.5.4    
[root@vm3 apr-util-1.5.4]# ./configure --prefix=/usr/local/source/apr-utils --with-apr=/usr/local/source/apr
[root@vm3 apr-util-1.5.4]# make
[root@vm3 apr-util-1.5.4]# make install

˵����--with-aprָ��apr�İ�װĿ¼
```

* ��װopenssl
```
# ��װ
[root@vm3 ~]# tar -zxf openssl-1.0.2j.tar.gz 
[root@vm3 ~]# cd openssl-1.0.2j
[root@vm3 openssl-1.0.2j]# ./config -fPIC --prefix=/usr/local/source/openssl102j enable-shared
[root@vm3 openssl-1.0.2j]# make
[root@vm3 openssl-1.0.2j]# make install

˵�������û��enable-shared����httpd����ʱ�ᱨ��

# ��������
[root@vm3 ~]# openssl version
OpenSSL 1.0.1e-fips 11 Feb 2013
[root@vm3 ~]# which openssl
/usr/bin/openssl
[root@vm3 ~]# mv /usr/bin/openssl /usr/bin/openssl.bak
[root@vm3 ~]# ln -s /usr/local/source/openssl102j/bin/openssl /usr/bin/openssl
[root@vm3 ~]# 
[root@vm3 ~]# openssl version
OpenSSL 1.0.2j  26 Sep 2016
[root@vm3 ~]# 

```

* ��װApache 2.4.17
```
[root@vm3 apache]# tar -zxf httpd-2.4.17.tar.gz 
[root@vm3 apache]# cd httpd-2.4.17
[root@vm3 httpd-2.4.17]# ./configure --prefix=/usr/local/source/apache24 --enable-so --enable-module=all --enable-mpms-shared=all --with-mpm=worker --with-zlib --with-pcre=/usr/local/source/pcre --with-apr=/usr/local/source/apr --with-apr-util=/usr/local/source/apr-utils --with-ssl=/usr/local/source/openssl102j
[root@vm3 httpd-2.4.17]# make
[root@vm3 httpd-2.4.17]# make install

˵����
--prefix����װĿ¼
--sysconfdir:�����ļ�Ŀ¼
--enable-so������DSO����̬������󣩡���̬װ��ģ��
--enable-ssl��https�Ĺ���
--enable-rewrite����ַ��д
--enable-cgi��CGI�ű�����
--enable-deflate���ṩ�����ݵ�ѹ���������֧�֡�
--enable-expires����������ͨ�������ļ�����HTTP�ġ�Expires�����͡�Cache-Control����ͷ���ݣ�������վͼƬ��js��css�����ݣ��ṩ�ڿͻ�����������������á�����apache���ŵ�һ����Ҫѡ��֮һ��
--enable-headers���ṩ�����HTTP����ͷ�Ŀ���
--with-zlib��ѹ�����ܵĺ�����
--with-pcre��perl������İ�װĿ¼
--enable-modules=most�����볣�õ�ģ��
--enable-modules=all���������е�ģ��
--enable-mpms-shared=all��֧�ֶ�̬����MPMģ�顣
--with-mpm=worker������Ĭ�����õ�MPMģʽΪworker
```

* ����SSLģ�鱨����
```
������ʾ��
[root@vm3 bin]# ./httpd -k start
httpd: Syntax error on line 129 of /usr/local/source/apache24/conf/httpd.conf: Cannot load modules/mod_ssl.so into server: libssl.so.1.0.0: cannot open shared object file: No such file or directory
[root@vm3 bin]# 


���������
[root@vm3 ~]# cp -a /usr/local/source/openssl102j/lib/libssl.so.1.0.0 /usr/lib64/
[root@vm3 ~]# cp -a /usr/local/source/openssl102j/lib/libcrypto.so.1.0.0 /usr/lib64/
[root@vm3 ~]# 


�ٴ��������ԣ�
[root@vm3 ~]# /usr/local/source/apache24/bin/httpd -k start         
[root@vm3 ~]# netstat -tunlp | grep httpd
tcp        0      0 :::80                       :::*                        LISTEN      34207/httpd         
[root@vm3 ~]# 
```

* ��������Apache���û�����
```
[root@vm3 ~]# groupadd -r www
[root@vm3 ~]# useradd -r -g www -s /sbin/nologin www
[root@vm3 ~]#
```
