# 安装libgd
* yum包安装
```
[root@vm3 nginx-1.8.1]# yum install -y gd gd-devel
```

* 源码包安装
```
1. 安装依赖软件包
[root@vm3 jpeg-6b]# yum install -y libtool libtool-ltdl-devel zlib zlib-devel

2. 安装jpeg库
[root@vm3 ~]# tar -zxf jpegsrc.v9b.tar.gz 
[root@vm3 ~]# cd jpeg-9b/
[root@vm3 jpeg-9b]# ./configure --enable-shared
[root@vm3 jpeg-9b]# make
[root@vm3 jpeg-9b]# make install

3. 安装libpng
[root@vm3 ~]# tar -zxf libpng-1.6.26.tar.gz 
[root@vm3 ~]# cd libpng-1.6.26
[root@vm3 libpng-1.6.26]# cd scripts
[root@vm3 scripts]# mv makefile.linux ../makefile
[root@vm3 scripts]# cd .. 
[root@vm3 libpng-1.6.26]# make
[root@vm3 libpng-1.6.26]# make install

4. 安装freetype
[root@vm3 ~]# tar -zxf freetype-2.7.tar.gz 
[root@vm3 ~]# cd freetype-2.7
[root@vm3 freetype-2.7]# ./configure 
[root@vm3 freetype-2.7]# make
[root@vm3 freetype-2.7]# make install

5. 安装libgd
[root@vm3 ~]# tar -zxf libgd-2.2.2.tar.gz
[root@vm3 ~]# cd libgd-2.2.2
[root@vm3 libgd-2.2.2]# ./configure --with-zlib --with-png=/usr/local --with-jpeg
[root@vm3 libgd-2.2.2]# make
[root@vm3 libgd-2.2.2]# make install
编译结果如下：
** Configuration summary for libgd 2.2.2:

   Support for Zlib:                 yes
   Support for PNG library:          yes
   Support for JPEG library:         yes
   Support for WebP library:         no
   Support for TIFF library:         no
   Support for Freetype 2.x library: no
   Support for Fontconfig library:   no
   Support for Xpm library:          no
   Support for liq library:          no
   Support for pthreads:             yes
   
```

# 编译安装Nginx
```
[root@vm3 nginx]# tar -zxf nginx-1.8.1.tar.gz 
[root@vm3 nginx]# cd nginx-1.8.1
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-google_perftools_module --with-http_image_filter_module
[root@vm3 nginx-1.8.1]# make
[root@vm3 nginx-1.8.1]# make install
[root@vm3 nginx-1.8.1]# cp -a /usr/local/lib/libgd.* /usr/lib64/

[root@vm3 nginx-1.8.1]# /usr/local/source/nginx18/sbin/nginx -v
nginx version: nginx/1.8.1
[root@vm3 nginx-1.8.1]#
```