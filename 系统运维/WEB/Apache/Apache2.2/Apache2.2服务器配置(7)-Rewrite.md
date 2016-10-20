# 正则表达式介绍
* 锚定
```
^：锚定行首
$：锚定行尾
\<：锚定词首
\>：锚定词尾
\b：锚定单词边界。也可以作为锚定词首和词尾用。
```

* 次数
```
*：前一个字符出现0次或多次。
?：前一个字符出现0次或1次。
+：前一个字符出现1次或多次。
{n}：前一个字符出现n次。
{n,}：前一个字符出现n次以上。
{n,m}：前一个字符出现n到m次。
```

* 分组和范围
```
.：匹配任意单个字符。
.*：匹配任意长度的任意字符。
(a|b)：匹配a或b
(...)：分组。
[abc]：范围。匹配a或b或c
[^abc]：范围。排除a或b或c
[a-z]：范围。匹配a-z
[A-Z]：范围。匹配A-Z
[a-zA-Z]：范围。匹配a-zA-Z。
[0-9]：范围。匹配0到9。
```

* 转义字符
```
\：对特殊字符进行转义。
```

* 必须转义的字符
```
^   $   [   .   *    +   ?   (  )   {    \    |    >    <
```

* 特殊字符
```
\n：换行。
\t：水平制表符。
\v：纵向制表符。
```

* 后向引用
```
$1：引用第一个分组
$2：引用第二个分组
$n：引用第n个分组
```

* POSIX
```
[:upper:]：所有的大写字母。A-Z
[:lower:]：所有的小写字母。a-z
[:alpha:]：所有的字母，包括大写字母和小写字母。
[:digit:]：数字。0-9
[:alnum:]：所有的字母和数字。
[:blank:]：空格和制表符。
[:space:]：空白字符。
[:punct:]：标点符号。
[:graph:]：可打印字符。
[:print:]：可打印字符和空格。
```

# Rewrite
## Rewrite介绍
* 虚拟主机启用Rewrite

> 在设置rewrite规则时，在httpd.conf中设置的rewrite不会被VirtualHost继承，如果VirtualHost需要使用httpd.conf中的rewrite规则，则需要在VirtualHost中做如下设置

```
<VirtualHost *:80>
    RewriteEngine On
    RewriteOptions Inherit
</VirtualHost>
```

* Rewrite相关命令
```
1. RewriteEngine
作用：是否启用Rewrite功能。
启用：RewriteEngine on
禁用：RewriteEngine off
说明：如果虚拟主机要配置Rewrite功能，则每一个虚拟主机里面都要配置RewriteEngine on

2. RewriteLogLevel
作用：将Rewrite信息写入到日志文件的log等级。默认为0，则表示关闭Rewrite日志功能。如果是9或者更高数字，则表示记录所有的Rewrite行为到log文件。
注意：如果使用的值超过2，则会影响其性能。如果需要开启debug功能，则可以将其设置的值超过2.

3. RewriteLog
作用：记录Rewrite相关的信息到指定的文件。

Rewrite日志文件的格式
-----------------------------------------------------------------------------------------------------------------
		Description											Example
-----------------------------------------------------------------------------------------------------------------
Remote host IP address							192.168.200.166
-----------------------------------------------------------------------------------------------------------------
Remote login name								Will usually be “-“
-----------------------------------------------------------------------------------------------------------------
HTTP user auth name								Username, or “-” if no auth
-----------------------------------------------------------------------------------------------------------------
Date and time of request						[28/Aug/2009:13:09:09 –0400]
-----------------------------------------------------------------------------------------------------------------
Virtualhost and virtualhost ID					[www.example.com/sid#84a650]
-----------------------------------------------------------------------------------------------------------------
Request ID, and whether it’s a subrequest		[rid#9f0e58/subreq]
-----------------------------------------------------------------------------------------------------------------
Log entry severity level						(2)
-----------------------------------------------------------------------------------------------------------------
Text error message								forcing proxy-throughput with http://127.0.0.1:8080/index.html
-----------------------------------------------------------------------------------------------------------------

```

* RewriteCond

> 语法格式：RewriteCond <TestString> <CondPattern> [FLAGS]
> 定义RewriteRule生效的条件。即在一个RewriteRule指令之前可以有一个或多个RewriteCond。RewriteRule生效的条件是：要满足RewriteCond所定义的TestString和CondPattern之间的匹配，同时还要满足多个RewriteCond之间的逻辑关系。

```
1. TestString
表示要检测的内容。可以是如下信息：
	* 服务器变量。
	* RewriteRule的后向引用，引用方法是$N。N的范围是0-9。
	* RewriteCond的后向引用，引用方法是%N。N的范围是0-9。
	
2. CondPattern
表示TestString需要匹配的内容。是一个正则表达式。
还有一些检测如下：
	'-d'：测试TestString是否为一个存在的目录
	'-f'：测试TestString是否为一个存在的文件
	'-s'：测试TestString是否为一个存在的非空文件
	'-l'：测试TestString是否为一个存在的符号链接
	'-x'：测试TestString是否为一个存在的、具有可执行权限的文件。

	说明：可以在上述条件的前面使用'!'，对其进行取反。
	
3. FLAGS
逗号分隔的一组标记列表。
NC：忽略大小写。表示TestString和CondPattern的比较是忽略大小写的。也就是说A-Z和a-z是一样的。
OR：表示各个RewriteCond之间的判断条件为OR,而不是默认的AND。
```
![RewriteCond配置示例](https://github.com/felix1115/Docs/blob/master/Images/rewrite-1.png)

* RewriteRule