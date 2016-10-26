# ˵��
��Apache��PHP����ʱ��һ��Ҫ��װlibiconv�⡣libiconv��Ϊ��Ҫ��ת����Ӧ�ó����ṩ��һ��iconv�����ʵ��һ���ַ����뵽��һ���ַ������ת�������������Խ�UTF8����ת����GB18030���룬������Ҳ�С�

php��apache����ʱһ��Ҫ��װlibiconv�⣬������makeʱϵͳ�ᱨ��

# ��װlibiconv
```
[root@vm01 php]# tar -zxf libiconv-1.14.tar.gz 
[root@vm01 php]# cd libiconv-1.14
[root@vm01 libiconv-1.14]# ./configure 
[root@vm01 libiconv-1.14]# make
[root@vm01 libiconv-1.14]# make install
```

libiconv�ⰲװ��Ϻ󣬽����/usr/local/lib����뵽/etc/ld.so.conf.d/libiconv.conf�ļ��У�Ȼ��ʹ��/sbin/ldconfigʹ����Ч��
```
[root@vm01 php]# echo "/usr/local/lib" > /etc/ld.so.conf.d/libiconv.conf
[root@vm01 php]# cat /etc/ld.so.conf.d/libiconv.conf
/usr/local/lib
[root@vm01 php]# 
[root@vm01 php]# ldconfig 
[root@vm01 php]# 
```

# ��װPHP 5.6
* ��װ������
```
[root@vm01 php]# yum install -y libxml2 libxml2-devel bzip2 bzip2-devel
```

* ��װPHP 5.6
```
[root@vm3 php]# tar -jxf php-5.6.16.tar.bz2 
[root@vm3 php]# cd php-5.6.16
[root@vm3 php-5.6.16]# ./configure --prefix=/usr/local/source/php56 --enable-mysqlnd --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-openssl=/usr/local/source/openssl102j --enable-mbstring --enable-fpm --with-bz2 --with-apxs2=/usr/local/source/apache22/bin/apxs --with-iconv-dir=/usr/local
[root@vm3 php-5.6.16]# make ZEND_EXTRA_LIBS='-liconv'
[root@vm3 php-5.6.16]# make test
[root@vm3 php-5.6.16]# make install

����ѡ��˵����
--prefix=/usr/local/source/php56��ָ��PHP�İ�װ·����
--enable-mysqlnd����ȷ����mysqlnd���������Ȱ�װmysql��ֱ��ʹ�ñ���mysql������
--with-mysql=mysqlnd������PHP֧��MySQL���ܡ����ʹ��PHP5.3���ϰ汾��Ϊ������MySQL���ݿ⣬����ָ��mysqlnd�������ڱ����Ͳ���Ҫ�Ȱ�װMySQL��MySQL�������ˡ�mysqlnd��php 5.3��ʼ���ã����Ա���ʱ�󶨵����������ú;����MySQL�ͻ��˿���γ�������������PHP 5.4��ʼ������Ĭ�������ˡ�
--with-pdo-mysql=mysqlnd��ʹ�ñ��ص�MySQL����
--with-mysqli=mysqlnd��ʹ�ñ��ص�MySQL����
--with-openssl��ָ��openssl�İ�װλ�á��������Դ�밲װ�����Ժ��������
--enable-mbstring����ʾ����mbstringģ�顣mbstringģ�����Ҫ�������ڼ���ת�����룬�ṩ��Ӧ�Ķ��ֽڲ������ַ���������Ŀǰphp�ڲ��ı���ֻ֧��ISO-8859-*��EUC-JP��UTF-8�������ı����������û�취��php��������ȷ��ʾ�ģ���������Ҫ����mbstringģ�顣
--enable-fpm������php��fastcgi���ܣ�������php-fpm���ܡ�
--with-bz2������bzip2��ѹ�����ܡ�
--with-apxs2=/usr/local/source/apache22/bin/apxs��ָ��PHP����Apache��apxsָ���λ�á���PHP��ΪDSO�����http�С����PHP�ǵ�����װ������ָ�����ѡ�
--with-iconv-dir=/usr/local��ָ��iconv�İ�װλ�á�
```