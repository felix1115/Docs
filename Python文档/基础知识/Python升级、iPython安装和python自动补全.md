# Python升级（2.6.6升级到2.7.6）
+ 安装所需软件包
```bash
[root@vm1 ~]# yum install -y zlib zlib-devel bzip2 bzip2-devel bzip2-lib sqlite sqlite-devel ncurses-devel readline-devel patch
```
+ 查看当前python版本
```bash
[root@vm1 python]# python -V
Python 2.6.6
[root@vm1 python]#
```

+ 安装python 2.7.6
```bash
[root@vm1 python]# tar -zxf Python-2.7.6.tgz
[root@vm1 python]# cd Python-2.7.6
[root@vm1 Python-2.7.6]# ./configure
[root@vm1 Python-2.7.6]# make install
```
+ 建立软链接
```bash
[root@vm1 Python-2.7.6]# mv /usr/bin/python /usr/bin/python2.6.6
[root@vm1 Python-2.7.6]# ln -s /usr/local/bin/python2.7 /usr/bin/python
```

+ 查看当前Python版本
```bash
[root@vm1 ~]# python -V
Python 2.7.6
[root@vm1 ~]#
```

+ 解决升级Python后yum无法使用的情况（修改/usr/bin/yum，将第一行改为/usr/bin/python2.6.6）
```bash
[root@vm1 ~]# cp -a /usr/bin/yum{,.bak}
[root@vm1 ~]# sed -i 's%^#!/usr/bin/python$%#!/usr/bin/python2.6.6%' /usr/bin/yum
```

# 安装iPython
+ 安装traitlets
```bash
[root@vm1 python]# tar -zxf traitlets-4.2.2.tar.gz
[root@vm1 python]# cd traitlets-4.2.2
[root@vm1 traitlets-4.2.2]# python setup.py install
```

+ 安装setuptools
```bash
[root@vm1 python]# tar -zxf setuptools-18.7.1.tar.gz
[root@vm1 python]# cd setuptools-18.7.1
[root@vm1 setuptools-18.7.1]# python setup.py install
```

+ 安装ipython_Cgenutils
```bash
[root@vm1 python]# tar -zxf ipython_genutils-0.1.0.tar.gz
[root@vm1 python]# cd ipython_genutils-0.1.0
[root@vm1 ipython_genutils-0.1.0]# python setup.py install
```

+ 安装decorator
```bash
[root@vm1 python]# tar -zxf decorator-4.0.10.tar.gz
[root@vm1 python]# cd decorator-4.0.10
[root@vm1 decorator-4.0.10]# python setup.py install
```

+ 安装pygments
```bash
[root@vm1 python]# tar -zxf Pygments-2.1.3.tar.gz
[root@vm1 python]# cd Pygments-2.1.3
[root@vm1 Pygments-2.1.3]# python setup.py install
```

+ 安装pexpect
```bash
[root@vm1 python]# tar -zxf pexpect-4.2.0.tar.gz
[root@vm1 python]# cd pexpect-4.2.0
[root@vm1 pexpect-4.2.0]# python setup.py install
```

+ 安装ptyprocess
```bash
[root@vm1 python]# tar -zxf ptyprocess-0.5.1.tar.gz
tar: ptyprocess-0.5.1/setup.py: implausibly old time stamp 1970-01-01 08:00:00
tar: ptyprocess-0.5.1/PKG-INFO: implausibly old time stamp 1970-01-01 08:00:00
[root@vm1 python]# cd ptyprocess-0.5.1
[root@vm1 ptyprocess-0.5.1]# python setup.py install
```

+ 安装backports.shutil_get_terminal_size
```bash
[root@vm1 python]# tar -zxf backports.shutil_get_terminal_size-1.0.0.tar.gz
[root@vm1 python]# cd backports.shutil_get_terminal_size-1.0.0
[root@vm1 backports.shutil_get_terminal_size-1.0.0]# python setup.py install
```

+ 安装six
```bash
[root@vm1 python]# tar -zxf six-1.10.0.tar.gz
[root@vm1 python]# cd six-1.10.0
[root@vm1 six-1.10.0]# python setup.py install
```

+ 安装pathlib2
```bash
[root@vm1 python]# tar -zxf pathlib2-2.1.0.tar.gz
[root@vm1 python]# cd pathlib2-2.1.0
[root@vm1 pathlib2-2.1.0]# python setup.py install
```

+ 安装pickleshare
```bash
[root@vm1 python]# tar -zxf pickleshare-0.7.3.tar.gz
[root@vm1 python]# cd pickleshare-0.7.3
[root@vm1 pickleshare-0.7.3]# python setup.py install
```

+ 安装wcwidth
```bash
[root@vm1 python]# tar -zxf wcwidth-0.1.7.tar.gz
[root@vm1 python]# cd wcwidth-0.1.7
[root@vm1 wcwidth-0.1.7]# python setup.py install
```

+ 安装prompt_toolkit
```bash
[root@vm1 python]# tar -zxf prompt_toolkit-1.0.3.tar.gz
[root@vm1 python]# cd prompt_toolkit-1.0.3
[root@vm1 prompt_toolkit-1.0.3]# python setup.py install
```

+ 安装simplegeneric
```bash
[root@vm1 python]# unzip simplegeneric-0.8.1.zip
[root@vm1 python]# cd simplegeneric-0.8.1
[root@vm1 simplegeneric-0.8.1]# python setup.py install
```

+ 安装iPython
```bash
[root@vm1 python]# tar -zxf ipython-5.0.0.tar.gz
[root@vm1 python]# cd ipython-5.0.0
[root@vm1 ipython-5.0.0]# python setup.py install
```

+ 启动ipython
```bash
[root@vm1 ~]# ipython
Python 2.7.6 (default, Jul 26 2016, 06:07:52)
Type "copyright", "credits" or "license" for more information.
IPython 5.0.0 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.
In [1]:
```

# python自动补全
+ 安装readline
```bash
[root@vm1 ~]# tar -zxf readline-6.2.4.1.tar.gz
[root@vm1 ~]# cd readline-6.2.4.1
[root@vm1 readline-6.2.4.1]# python setup.py install
```

+ 创建.pythonstartup.py文件
```bash
[root@vm1 ~]# cat .pythonstartup.py
#!/usr/bin/env python
# python startup file
import sys
import readline
import rlcompleter
import atexit
import os
# tab completion
readline.parse_and_bind('tab: complete')
# history file
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
try:
    readline.read_history_file(histfile)
except IOError:
   pass
atexit.register(readline.write_history_file, histfile)
del os, histfile, readline, rlcompleter
[root@vm1 ~]#
```

+ 配置.bash_profile
```bash
export PYTHONSTARTUP="/root/.pythonstartup.py"
```

+ 使配置生效
```bash
[root@vm1 ~]# source .bash_profile
[root@vm1 ~]#
```

+ 测试
```python
[root@vm1 ~]# python
Python 2.7.6 (default, Jul 26 2016, 06:26:33)
[GCC 4.4.7 20120313 (Red Hat 4.4.7-4)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> a = range(5)
>>> a.
a.__add__(           a.__delslice__(      a.__getattribute__(  a.__iadd__(          a.__len__(           a.__reduce__(        a.__setattr__(       a.__subclasshook__(  a.insert(
a.__class__(         a.__doc__            a.__getitem__(       a.__imul__(          a.__lt__(            a.__reduce_ex__(     a.__setitem__(       a.append(            a.pop(
a.__contains__(      a.__eq__(            a.__getslice__(      a.__init__(          a.__mul__(           a.__repr__(          a.__setslice__(      a.count(             a.remove(
a.__delattr__(       a.__format__(        a.__gt__(            a.__iter__(          a.__ne__(            a.__reversed__(      a.__sizeof__(        a.extend(            a.reverse(
a.__delitem__(       a.__ge__(            a.__hash__           a.__le__(            a.__new__(           a.__rmul__(          a.__str__(           a.index(             a.sort(
>>> a.
```
