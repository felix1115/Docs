[TOC]
# 安装qrencode

-  **安装libpng**
```
[root@control qrencode-3.4.4]# yum install -y libpng libpng-devel
```

- **安装qrencode**
```bash
[root@control opt]# tar -jxf qrencode-3.4.4.tar.bz2 
[root@control opt]# cd qrencode-3.4.4
[root@control qrencode-3.4.4]# ./configure --prefix=/usr/local/source/qrencode
[root@control qrencode-3.4.4]# make
[root@control qrencode-3.4.4]# make install
```

# qrencode的使用

- **语法格式**
```
Usage: qrencode [OPTION]... [STRING]
OPTIONS：
-o：输出的二维码文件名。如test.png。需要以.png结尾。-表示输出到控制台。
-s：指定图片大小。默认为3个像素。
-t：指定产生的图片类型。默认为PNG。可以是PNG/ANSI/ANSI256/ASCIIi/UTF8等。如果需要输出到控制台，可以用ANSI、ANSI256等

STRING：可以是text、url等
```

- **根据URL生成二维码图片**
```
[root@control bin]# ./qrencode -o test.png 'http://www.baidu.com'
[root@control bin]# 
```

- **从标准输入产生二维码**
```
[root@control ~]# echo "Hello World" | /usr/local/source/qrencode/bin/qrencode -o - -t ANSI 
```

![在命令行终端下生成二维码示例](http://img.blog.csdn.net/20160523180040896)
