# ��װlibgd
* yum����װ
```
[root@vm3 nginx-1.8.1]# yum install -y gd gd-devel
```

* Դ�����װ
```
1. ��װ���������
[root@vm3 jpeg-6b]# yum install -y libtool libtool-ltdl-devel zlib zlib-devel

2. ��װjpeg��
[root@vm3 ~]# tar -zxf jpegsrc.v9b.tar.gz 
[root@vm3 ~]# cd jpeg-9b/
[root@vm3 jpeg-9b]# ./configure --enable-shared
[root@vm3 jpeg-9b]# make
[root@vm3 jpeg-9b]# make install

3. ��װlibpng
[root@vm3 ~]# tar -zxf libpng-1.6.26.tar.gz 
[root@vm3 ~]# cd libpng-1.6.26
[root@vm3 libpng-1.6.26]# cd scripts
[root@vm3 scripts]# mv makefile.linux ../makefile
[root@vm3 scripts]# cd .. 
[root@vm3 libpng-1.6.26]# make
[root@vm3 libpng-1.6.26]# make install

4. ��װfreetype
[root@vm3 ~]# tar -zxf freetype-2.7.tar.gz 
[root@vm3 ~]# cd freetype-2.7
[root@vm3 freetype-2.7]# ./configure 
[root@vm3 freetype-2.7]# make
[root@vm3 freetype-2.7]# make install

5. ��װlibgd
[root@vm3 ~]# tar -zxf libgd-2.2.2.tar.gz
[root@vm3 ~]# cd libgd-2.2.2
[root@vm3 libgd-2.2.2]# ./configure --with-zlib --with-png=/usr/local --with-jpeg
[root@vm3 libgd-2.2.2]# make
[root@vm3 libgd-2.2.2]# make install
���������£�
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

# ���밲װNginx
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

# image filter
* image_filter
```
����location���С�image_filter����ָ�������
�﷨��ʽ
	image_filter off;
	image_filter test;
	image_filter size;
	image_filter rotate 90 | 180 | 270;
	image_filter resize <width> <height>;
	image_filter crop <width> <height>;
Ĭ��ֵ��image_filter off;
���ã�����ͼƬ��ת�����͡�

off����ָ����location�йر�ͼƬ�����ܡ�
test��ȷ����Ӧ��ͼƬ��JPEG��GIF��PNG������webP��ʽ�������򷵻�415(Unsupported Media Type)������롣
size��ʹ��JSON��ʽ���ͼƬ��Ϣ�������ʽ�磺{ "img" : { "width": 1920, "height": 1080, "type": "jpeg" } }���������������������£�{}
rotate 90|180|270��������ʱ����תָ���ĽǶȡ��Ƕȿ���ʹ�ñ��������Ǳ�����ֵֻ����90��180��270����ָ����Ե���ʹ�ã�Ҳ���Ժ�resize��cropһ��ʹ�á�
resize <width> <height>������ָ���Ŀ�Ⱥ͸߶ȼ�СͼƬ�����ֻ���������һ��ά�ȣ�����һ��ά������Ϊ"-"��������������򷵻�415���������rotateһ��ʹ�ã����ȼ���ͼƬ�Ĵ�С��Ȼ������ת����һ���ᰴ�����Ƕ���ı������٣�����ͼƬ��������ʾ��
crop <width> <height>���ʵ�������ͼƬ�Ŀ�Ⱥ͸߶ȡ����ֻ���������һ��ά�ȣ�����һ��ά������Ϊ"-"��������������򷵻�415���������rotateһ��ʹ�ã�������ת����ü�����ȫ�������Ƕ���ĸ�ʽ��ʾ��ͼƬ�п��ܻ���ʾ��������
```

* image_filter_buffer
```
����http��server��location���С�
Ĭ��ֵ��image_filter_buffer 1M;
���ã�ָ�����ڶ�ȡͼƬ�Ļ����С���������ô�Сʱ��������415 (Unsupported Media Type)����
```

* image_filter_interlace
```
����http��server��location���С�
Ĭ��ֵ��off
���ã�������������յ�ͼƬ���ὥ��ʽ������JPEG��ʽ��ͼƬ�����յ�ͼƬ��ʽΪ����ʽ��JPEG��ʽ��
```

* image_filter_jpeg_quality
```
����http��server��location���С�
Ĭ��ֵ��image_filter_jpeg_quality 75;
���ã�����ת�����JPEGͼƬ������Ҫ��ֵ�ķ�Χ��1��100. ��С��ֵ��ζ�Žϲ��ͼƬ�����ͽ��ٵ����ݴ��䡣����Ƽ�Ϊ95.
```

* image_filter_sharpen
```
����http��server��location���С�
Ĭ��ֵ��image_filter_sharpen 0;
���ã�����������ͼ��������ȡ���Ȱٷֱȿ��Գ���100����ֵ�������񻯡�����ֵ���԰�������
```

* image_filter_transparency
```
����http��server��location���С�
Ĭ��ֵ��image_filter_transparency on;
���ã�����GIF��PNG��ͼƬ���ڽ���ת��ʱ���Ƿ���͸���ȡ�
```

# ����ʾ��

> ��������ͼ��http://172.17.100.3/1.jpg!500!300
> ����ԭͼ:http://172.17.100.3/1.jpg


```
location ~ \.(jpg|jpeg|png|gif)!(\d+)!(\d+) {
	set $w $2;
	set $h $3;
	
	rewrite (.*)\.(jpg|jpeg|gif|png)!(\d+)!(\d+) $1.$2 break;
	image_filter_buffer 10M;
	image_filter resize $w $h;
}

location ~ \.(jpg|jpeg|png|gif)$ {
	valid_referers none blocked server_names
		*.kakaogift.cn *.kakaogift.com;

	if ($invalid_referer) {
		rewrite (.*)\.(jpg|gif|jpeg|png)$ /logo.png break;
	}
}

```

# ʹ��Nginx�ĵ�����ͼƬ����ģ��

[Github��ַ](https://github.com/3078825/ngx_image_thumb)


* ˵��
```
1. ��ģ��ͬʱ֧��Nginx��Tengine
2. ֧��ͼƬ���ԡ�֧������ˮӡ��ͼƬˮӡ��
3. ֧���Զ������塢�ļ���С��ˮӡ͸���ȡ�ˮӡλ�á�
4. �ж�ԭͼ�Ƿ����ָ���ߴ�ʱ�Ŵ����ȵȡ�
```

* ������
```
[root@vm3 ~]# yum install -y libcurl libcurl-devel libpcre-devel libgd2-devel
```

* ��װ��ģ��
```
1. ����ģ�����Nginx��Tengine��Դ����Ŀ¼��
[root@vm3 ~]#  wget https://github.com/3078825/nginx-image/archive/master.zip

2. ��װ��ģ��(--add-module)
[root@vm3 nginx]# tar -zxf nginx-1.8.1.tar.gz
[root@vm3 nginx]# cd nginx-1.8.1
[root@vm3 nginx]# wget https://github.com/3078825/nginx-image/archive/master.zip
[root@vm3 nginx]# unzip master.zip
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-google_perftools_module --add-module=./ngx_image_thumb-master
[root@vm3 nginx]# make
[root@vm3 nginx]# make install
```

* ����ͼƬ������
```
1. ������Ŀ¼����
location / {
   root html;
   #�����������
   image on;
   image_output on;
}

2. ��ָ��Ŀ¼����
location /upload {
   root html; 
   image on;
   image_output on;
}
```

* ����ѡ��˵��
```
image on/off �Ƿ�������ͼ����,Ĭ�Ϲر�

image_backend on/off �Ƿ���������񣬵������ù���ʱ������Ŀ¼�����ڵ�ͼƬ���ж�ԭͼ�������Զ��Ӿ����������ַ����ԭͼ

image_backend_server �����������ַ

image_output on/off �Ƿ�����ͼƬ��ֱ�Ӵ������� Ĭ��off

image_jpeg_quality 75 ����JPEGͼƬ������ Ĭ��ֵ75

image_water on/off �Ƿ���ˮӡ����

image_water_type 0/1 ˮӡ���� 0:ͼƬˮӡ 1:����ˮӡ

image_water_min 300 300 ͼƬ��� 300 �߶� 300 ����������ˮӡ

image_water_pos 0-9 ˮӡλ�� Ĭ��ֵ9 0Ϊ���λ��,1Ϊ���˾���,2Ϊ���˾���,3Ϊ���˾���,4Ϊ�в�����,5Ϊ�в�����,6Ϊ�в�����,7Ϊ�׶˾���,8Ϊ�׶˾���,9Ϊ�׶˾���

image_water_file ˮӡ�ļ�(jpg/png/gif),����·���������·����ˮӡͼƬ

image_water_transparent ˮӡ͸����,Ĭ��20������ԽС��͸����ԽԽ�͡�100��ʾ��͸����

image_water_text ˮӡ���� "Power By Vampire"

image_water_font_size ˮӡ��С Ĭ�� 5

image_water_font ����ˮӡ�����ļ�·��

image_water_color ˮӡ������ɫ,Ĭ�� #000000
```

* ����˵��
```
����������nginx ���ʵ�ַΪ http://127.0.0.1/,����nginx��վ��Ŀ¼����һ�� test.jpg ��ͼƬ

ͨ������http://127.0.0.1/test.jpg!c300x200.jpg ���� ����/��� test.jpg 300x200 ������ͼ

���� c ������ͼƬ����ͼ�Ĳ����� 300 ����������ͼ�� ��� 200 ����������ͼ�� �߶�

һ�������������ֲ�ͬ���͵�����ͼ��

֧�� jpeg / png / gif (Gif���ɺ��ɾ�̬ͼƬ)

C �����������߱�����ͼƬ�߶� 10% ����ʼ��ȡͼƬ��Ȼ������/�Ŵ�ָ���ߴ磨 ͼƬ����ͼ��С��������Ŀ�� ��

M �����������߱������н�ͼͼƬ��Ȼ������/�Ŵ�ָ���ߴ磨 ͼƬ����ͼ��С��������Ŀ�� ��

T �����������߱�������������/�Ŵ�ָ���ߴ磨 ͼƬ����ͼ��С����С������Ŀ�� )

W �����������߱�������/�Ŵ�ָ���ߴ磬�հ״�����ɫ������ɫ�� ͼƬ����ͼ��С��������Ŀ�� ��
```