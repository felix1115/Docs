# 说明
在Apache与PHP集成时，一定要安装libiconv库。libiconv库为需要做转换的应用程序提供了一个iconv命令，以实现一个字符编码到另一个字符编码的转换，比如它可以将UTF8编码转换成GB18030编码，反过来也行。

php与apache集成时一定要安装libiconv库，否则在make时系统会报错。

# 安装libiconv
```
[root@vm01 php]# tar -zxf libiconv-1.14.tar.gz 
[root@vm01 php]# cd libiconv-1.14
[root@vm01 libiconv-1.14]# ./configure 
[root@vm01 libiconv-1.14]# make
[root@vm01 libiconv-1.14]# make install
```

libiconv库安装完毕后，建议把/usr/local/lib库加入到/etc/ld.so.conf.d/libiconv.conf文件中，然后使用/sbin/ldconfig使其生效。
```
[root@vm01 php]# echo "/usr/local/lib" > /etc/ld.so.conf.d/libiconv.conf
[root@vm01 php]# cat /etc/ld.so.conf.d/libiconv.conf
/usr/local/lib
[root@vm01 php]# 
[root@vm01 php]# ldconfig 
[root@vm01 php]# 
```

# 安装PHP 5.6
* 安装依赖包
```
[root@vm01 php]# yum install -y libxml2 libxml2-devel bzip2 bzip2-devel
```

* 安装PHP 5.6
```
[root@vm3 php]# tar -jxf php-5.6.16.tar.bz2 
[root@vm3 php]# cd php-5.6.16
[root@vm3 php-5.6.16]# ./configure --prefix=/usr/local/source/php56 --enable-mysqlnd --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-openssl=/usr/local/source/openssl102j --enable-mbstring --enable-fpm --with-bz2 --with-apxs2=/usr/local/source/apache22/bin/apxs --with-iconv-dir=/usr/local
[root@vm3 php-5.6.16]# make ZEND_EXTRA_LIBS='-liconv'
[root@vm3 php-5.6.16]# make test
[root@vm3 php-5.6.16]# make install

编译选项说明：
--prefix=/usr/local/source/php56：指定PHP的安装路径。
--enable-mysqlnd：明确启用mysqlnd。不用事先安装mysql，直接使用本地mysql驱动。
--with-mysql=mysqlnd：启用PHP支持MySQL功能。如果使用PHP5.3以上版本，为了链接MySQL数据库，可以指定mysqlnd，这样在本机就不需要先安装MySQL或MySQL开发包了。mysqlnd从php 5.3开始可用，可以编译时绑定到它（而不用和具体的MySQL客户端库绑定形成依赖），但从PHP 5.4开始它就是默认设置了。
--with-pdo-mysql=mysqlnd：使用本地的MySQL驱动
--with-mysqli=mysqlnd：使用本地的MySQL驱动
--with-openssl：指定openssl的安装位置。如果不是源码安装，可以忽略这个。
--enable-mbstring：表示启用mbstring模块。mbstring模块的主要作用在于检测和转换编码，提供对应的多字节操作的字符串函数。目前php内部的编码只支持ISO-8859-*、EUC-JP、UTF-8，其他的编码的语言是没办法在php程序上正确显示的，所以我们要启用mbstring模块。
--enable-fpm：开启php的fastcgi功能，即开启php-fpm功能。
--with-bz2：开启bzip2的压缩功能。
--with-apxs2=/usr/local/source/apache22/bin/apxs：指定PHP查找Apache的apxs指令的位置。将PHP作为DSO编译进http中。如果PHP是单独安装，则不用指定这个选项。
--with-iconv-dir=/usr/local：指定iconv的安装位置。
```