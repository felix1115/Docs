# 模板设置
* 说明
```
1. 通过使用vim编辑器打开指定的文件增加模板功能是通过修改/etc/vimrc文件实现的。
2. 通过autocmd来实现。

autocmd BufNewFile *.sh 0r /usr/share/vim/vimfiles/template.sh
autocmd BufNewFile *.py 0r /usr/share/vim/vimfiles/template.py

说明：
autocmd：固定语法。
BufNewFile：表示开始编辑尚不存在的文件。
*.sh和*.py：表示以sh和py结尾的文件。
0r：固定语法
/usr/share/vim/vimfiles/template.sh：这个表示模板文件
```

* 为以sh结尾的文件增加相关信息
```
1. vim /etc/vimrc
autocmd BufNewFile *.sh 0r /usr/share/vim/vimfiles/template.sh

2. 创建模板文件
[root@vm01 vimfiles]# pwd
/usr/share/vim/vimfiles
[root@vm01 vimfiles]# cat template.sh
#!/bin/bash
# Author: Felix
# E-Mail: 573713035@qq.com
# Version: 1.0
[root@vm01 vimfiles]#
```

* 为以py结尾的文件增加相关信息
```
1. vim /etc/vimrc
autocmd BufNewFile *.sh 0r /usr/share/vim/vimfiles/template.py

2. 创建模板文件
[root@vm01 vimfiles]# pwd
/usr/share/vim/vimfiles
[root@vm01 vimfiles]# cat template.py
#!/bin/env python2.7
# coding: utf-8
# Author: felix
# E-mail: 573713035@qq.com
# Version: 1.0
[root@vm01 vimfiles]#
```
