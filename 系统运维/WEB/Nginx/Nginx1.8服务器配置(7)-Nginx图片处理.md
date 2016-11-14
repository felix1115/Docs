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

# image filter
* image_filter
```
用于location段中。image_filter可以指定多个。
语法格式
	image_filter off;
	image_filter test;
	image_filter size;
	image_filter rotate 90 | 180 | 270;
	image_filter resize <width> <height>;
	image_filter crop <width> <height>;
默认值：image_filter off;
作用：设置图片的转换类型。

off：在指定的location中关闭图片处理功能。
test：确保响应的图片是JPEG、GIF、PNG、或者webP格式。否则，则返回415(Unsupported Media Type)错误代码。
size：使用JSON格式输出图片信息。输出格式如：{ "img" : { "width": 1920, "height": 1080, "type": "jpeg" } }。如果产生错误，则输出如下：{}
rotate 90|180|270：按照逆时针旋转指定的角度。角度可以使用变量。但是变量的值只能是90、180、270。该指令可以单独使用，也可以和resize和crop一起使用。
resize <width> <height>：按照指定的宽度和高度减小图片。如果只想减少其中一个维度，则另一个维度设置为"-"。如果产生错误，则返回415错误。如果和rotate一起使用，则先减少图片的大小，然后在旋转。不一定会按照我们定义的比例减少，但是图片会完整显示。
crop <width> <height>：适当的缩减图片的宽度和高度。如果只想减少其中一个维度，则另一个维度设置为"-"。如果产生错误，则返回415错误。如果和rotate一起使用，则先旋转，后裁剪。完全按照我们定义的格式显示，图片有可能会显示不完整。
```

* image_filter_buffer
```
用于http、server、location段中。
默认值：image_filter_buffer 1M;
作用：指定用于读取图片的缓存大小。当超过该大小时，将返回415 (Unsupported Media Type)错误。
```

* image_filter_interlace
```
用于http、server、location段中。
默认值：off
作用：如果开启，最终的图片将会渐进式。对于JPEG格式的图片，最终的图片格式为渐进式的JPEG格式。
```

* image_filter_jpeg_quality
```
用于http、server、location段中。
默认值：image_filter_jpeg_quality 75;
作用：设置转换后的JPEG图片的质量要求。值的范围是1到100. 更小的值意味着较差的图片质量和较少的数据传输。最大推荐为95.
```

* image_filter_sharpen
```
用于http、server、location段中。
默认值：image_filter_sharpen 0;
作用：增加了最终图像的清晰度。锐度百分比可以超过100。零值将禁用锐化。参数值可以包含变量
```

* image_filter_transparency
```
用于http、server、location段中。
默认值：image_filter_transparency on;
作用：对于GIF或PNG的图片，在进行转换时，是否保留透明度。
```

# 配置示例

> 访问缩略图：http://172.17.100.3/1.jpg!500!300
> 访问原图:http://172.17.100.3/1.jpg


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

# 使用Nginx的第三方图片处理模块

[Github地址](https://github.com/3078825/ngx_image_thumb)


* 说明
```
1. 该模块同时支持Nginx和Tengine
2. 支持图片缩略、支持文字水印和图片水印。
3. 支持自定义字体、文件大小、水印透明度、水印位置。
4. 判断原图是否大于指定尺寸时才处理。等等。
```

* 依赖库
```
[root@vm3 ~]# yum install -y libcurl libcurl-devel libpcre-devel libgd2-devel
```

* 安装该模块
```
1. 将该模块放在Nginx或Tengine的源代码目录下
[root@vm3 ~]#  wget https://github.com/3078825/nginx-image/archive/master.zip

2. 安装该模块(--add-module)
[root@vm3 nginx]# tar -zxf nginx-1.8.1.tar.gz
[root@vm3 nginx]# cd nginx-1.8.1
[root@vm3 nginx]# wget https://github.com/3078825/nginx-image/archive/master.zip
[root@vm3 nginx]# unzip master.zip
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --with-google_perftools_module --add-module=./ngx_image_thumb-master
[root@vm3 nginx]# make
[root@vm3 nginx]# make install
```

* 开启图片处理功能
```
1. 整个根目录开启
location / {
   root html;
   #添加以下配置
   image on;
   image_output on;
}

2. 在指定目录开启
location /upload {
   root html; 
   image on;
   image_output on;
}
```

* 配置选项说明
```
image on/off 是否开启缩略图功能,默认关闭

image_backend on/off 是否开启镜像服务，当开启该功能时，请求目录不存在的图片（判断原图），将自动从镜像服务器地址下载原图

image_backend_server 镜像服务器地址

image_output on/off 是否不生成图片而直接处理后输出 默认off

image_jpeg_quality 75 生成JPEG图片的质量 默认值75

image_water on/off 是否开启水印功能

image_water_type 0/1 水印类型 0:图片水印 1:文字水印

image_water_min 300 300 图片宽度 300 高度 300 的情况才添加水印

image_water_pos 0-9 水印位置 默认值9 0为随机位置,1为顶端居左,2为顶端居中,3为顶端居右,4为中部居左,5为中部居中,6为中部居右,7为底端居左,8为底端居中,9为底端居右

image_water_file 水印文件(jpg/png/gif),绝对路径或者相对路径的水印图片

image_water_transparent 水印透明度,默认20。数字越小，透明度越越低。100表示不透明。

image_water_text 水印文字 "Power By Vampire"

image_water_font_size 水印大小 默认 5

image_water_font 文字水印字体文件路径

image_water_color 水印文字颜色,默认 #000000
```

* 调用说明
```
这里假设你的nginx 访问地址为 http://127.0.0.1/,并在nginx网站根目录存在一个 test.jpg 的图片

通过访问http://127.0.0.1/test.jpg!c300x200.jpg 将会 生成/输出 test.jpg 300x200 的缩略图

其中 c 是生成图片缩略图的参数， 300 是生成缩略图的 宽度 200 是生成缩略图的 高度

一共可以生成四种不同类型的缩略图。

支持 jpeg / png / gif (Gif生成后变成静态图片)

C 参数按请求宽高比例从图片高度 10% 处开始截取图片，然后缩放/放大到指定尺寸（ 图片缩略图大小等于请求的宽高 ）

M 参数按请求宽高比例居中截图图片，然后缩放/放大到指定尺寸（ 图片缩略图大小等于请求的宽高 ）

T 参数按请求宽高比例按比例缩放/放大到指定尺寸（ 图片缩略图大小可能小于请求的宽高 )

W 参数按请求宽高比例缩放/放大到指定尺寸，空白处填充白色背景颜色（ 图片缩略图大小等于请求的宽高 ）
```