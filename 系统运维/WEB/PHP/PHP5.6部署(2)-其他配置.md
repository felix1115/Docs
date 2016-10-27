# PHP��������ļ�
* php.ini
```
[root@vm3 php-5.6.16]# cp php.ini-production /usr/local/source/php56/lib/php.ini
[root@vm3 php-5.6.16]# 
```

* php-fpm.conf
```
[root@vm3 php-5.6.16]# cp /usr/local/source/php56/etc/php-fpm.conf.default /usr/local/source/php56/etc/php-fpm.conf
[root@vm3 php-5.6.16]# 
```

* Ϊphp-fpm�ṩ�����ű�
```
[root@vm3 php-5.6.16]# cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
[root@vm3 php-5.6.16]# chmod +x /etc/init.d/php-fpm
[root@vm3 php-5.6.16]# chkconfig --add php-fpm
[root@vm3 php-5.6.16]# chkconfig php-fpm on
[root@vm3 php-5.6.16]# 
```

# PHP��Xcache������
* ��װautoconf
```
[root@vm3 ~]# yum install -y autoconf
```

* ��װXcache
```
[root@vm3 php]# tar -zxf xcache-3.2.0.tar.gz 
[root@vm3 php]# cd xcache-3.2.0
[root@vm3 xcache-3.2.0]# /usr/local/source/php56/bin/phpize --clean
Cleaning..
[root@vm3 xcache-3.2.0]# /usr/local/source/php56/bin/phpize
Configuring for:
PHP Api Version:         20131106
Zend Module Api No:      20131226
Zend Extension Api No:   220131226
[root@vm3 xcache-3.2.0]# ./configure --enable-xcache --with-php-config=/usr/local/source/php56/bin/php-config 
[root@vm3 xcache-3.2.0]# make
[root@vm3 xcache-3.2.0]# make install
Installing shared extensions:     /usr/local/source/php56/lib/php/extensions/no-debug-zts-20131226/
[root@vm3 xcache-3.2.0]# 
```

* �༭php.ini��xcache����
```
[root@vm3 xcache-3.2.0]# cat xcache.ini >> /usr/local/source/php56/lib/php.ini

[root@vm3 xcache-3.2.0]# cat /usr/local/source/php56/lib/php.ini | grep '^extension'
extension = /usr/local/source/php56/lib/php/extensions/no-debug-zts-20131226/xcache.so
[root@vm3 xcache-3.2.0]# 
```

* ����php-fpm
```
[root@vm3 xcache-3.2.0]# /etc/init.d/php-fpm restart
Gracefully shutting down php-fpm . done
Starting php-fpm  done
[root@vm3 xcache-3.2.0]# 
```

* �鿴Xcache�Ĺ���״̬
```
1. ����Xcache��web����Ŀ¼��Apache��DocumentRoot��
[root@vm3 ~]# cd php/xcache-3.2.0
[root@vm3 xcache-3.2.0]# cp -a htdocs /usr/local/source/apache22/htdocs/xcache
[root@vm3 xcache-3.2.0]# 

2. �޸�php.ini�����ò鿴xcache״̬��Ϣ���û�������
xcache.admin.user = "admin"
xcache.admin.pass = "e10adc3949ba59abbe56e057f20f883e"

˵����������ʹ��md5sum��������ġ�echoһ��Ҫ����-nѡ������������Ľ���Ǵ���ġ�
[root@vm3 ~]# echo -n '123456' | md5sum 
e10adc3949ba59abbe56e057f20f883e  -
[root@vm3 ~]# 

3. httpd.conf����

<Directory "/usr/local/source/apache22/test">
    Options None
    AllowOverride None
    Order allow,deny
    Allow from all 
</Directory>

4. ��������
[root@vm3 xcache-3.2.0]# /etc/init.d/php-fpm restart
Gracefully shutting down php-fpm . done
Starting php-fpm  done
[root@vm3 xcache-3.2.0]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 xcache-3.2.0]# 

```