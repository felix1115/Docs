# awk介绍
```
awk是一款强大的文本分析工具，awk是把要处理的文件逐行读入，以空格作为默认的输入分隔符将每行进行切片处理，然后在对切开的各个字段进行处理，处理完成后开始读取下一行接着进行处理。

使用方法：
awk 选项 'PATTERN{ACTION} PATTERN{ACTION} PATTERN{ACTION} ...' filename

说明：
* awk中的PATTERN和ACTION对可以有多个。其中PATTER和ACTION只能省略其中之一。
    如果没有指定PATTERN，则ACTION应用的所有的记录上。
    如果没有指定ACTION，则输出所有被PATTERN匹配的整个记录
* 如果ACTION中的statement多余一条，则以分号(;)隔开他们。
* PATTERN使用的是扩展的正则表达式语法，并且GLOB也是可以使用的。


PTTERN可以是如下其中之一：
* BEGIN
* END
* /regular expression/
* relational expression
* pattern && pattern
* pattern || pattern
* pattern ? pattern : pattern
* (pattern)
* ! pattern
* pattern, pattern

1. awk将输入数据划分为记录（RS为记录分隔符变量）
Start of File --> Record 1 --> RS --> Record 3 --> RS --> Record N --> RS --> EOF

2. awk将记录划分为字段
$0：表示整个记录
$1：表示被FS变量分隔的第一个字段。
$N：表示第N个字段。
$NF：表示最后一个字段。
$(NF-1)：表示倒数第2个字段。

常用选项：
-F：指定输入字段分隔符。默认为空格。
-f：指定awk脚本文件的位置。
-v variable=value：定义变量。variable为变量名称，value为变量初始值。

```

# awk printf
```
%c：ASCII码。以ASCII码形式显示。
%d，%i：数字。
%f：浮点数。
%o：无符号八进制。
%u：无符号十进制。
%x，%X：无符号十六进制。
%s：字符串。
%%：百分号。

显示方式：
-：左对齐。默认是右对齐。
+：正数前面显示+，负数前面显示-。
#[.#]：第一个#表示显示宽度，第二个#表示小数点后保留位数。

\t：水平制表符。
\n：换行
```

# awk运算符
```
算术运算符：+、-、*、/、%、**(幂运算)
赋值运算符：=、+=、-=、*=、/=、%=、++、--、**=
关系运算符：>、<、==、>=、<=、!=
逻辑运算符：||、&&、!
匹配运算符：~表示匹配PATTERN，!~表示不匹配PATTERN。
数组成员关系操作符：in
三目运算符：a?b:c，如表示式a为真则返回b，否则返回c。
```

# awk的内置变量
```
ARGC：命令行参数个数。
ARGV：命令行参数组成的数组。数组的索引从0到ARGC-1。
ARGIND：当前正在被处理的文件的ARGV的索引。
ENVIRON：包含当前环境变量值的数组。如ENVIRON["HOME"]表示的是HOME环境变量的值。
FILENAME：当前正在处理的文件的文件名。
FNR：当前文件的记录数。
FS：输入字段分隔符。
OFS：输出字段分隔符。
RS：输入行分隔符。默认为换行(\n)。如果RS为空，则以空白行为分隔符。
ORS：输出行分隔符。
NR：当前处理的记录总数。
NF：当前行的字段总数。
IGNORECASE：如果为非0，则执行忽略大小写匹配。否则不执行忽略大小写。
```

# awk内置函数
```
index(s,t)：返回字符串t首次出现在字符串s中位置，索引从1开始。
length(s)：返回字符串s的长度。

示例1：
[root@vm1 tmp]# awk -F: '/^root/ {print $0}' passwd
root:x:0:0:root:/root:/bin/bash
[root@vm1 tmp]# awk -F: '/^root/ {print length($1)}' passwd
4
[root@vm1 tmp]# awk -F: '/^root/ {print index($0,0)}' passwd
8
[root@vm1 tmp]#

systime(): 返回当前时间距离1970-1-1所经过的秒数。
示例：
[root@vm1 tmp]# awk 'BEGIN {print systime()}'
1469935800
[root@vm1 tmp]#

system(command): 执行shell命令。

示例：
[root@vm1 scripts]# awk 'BEGIN {system("ls -l")}'
总用量 32
-rw-r--r-- 1 root root     0 7月  31 12:52 check_date.sh
-rwxr-xr-x 1 root root  2238 7月  31 14:32 date_seconds_interconvertaion.sh
-rwxr-xr-x 1 root root  9010 7月  31 09:54 disk_tool.sh
-rwxr-xr-x 1 root root 10162 7月  30 16:55 host-info.sh
-rw-r--r-- 1 root root   375 7月  31 00:07 test
[root@vm1 scripts]#

```

# awk的流程控制
## BEGIN和END
```
BEGIN和END是awk中两个特殊的表达式，可以用于PATTERN中。
BEGIN：表示在读取文件之前执行的内容。
END：表示在文件处理完成之后所执行的内容。

BEGIN和END之后列出的内容都要方法{ }中，作为ACTION。

示例：
[root@vm1 scripts]# cat test.awk
#!/bin/awk

BEGIN {print "===================="; count=0};
{count++}
END {print "Total Users:",count; print "===================="};
[root@vm1 scripts]#
[root@vm1 scripts]# awk -f test.awk /etc/passwd
====================
Total Users: 20
====================
[root@vm1 scripts]#

```

## if条件判断
```
单分之if语法格式
{
    if (expression) {
        satement; statement; ...
    }
}

双分支if语法格式
{
    if（expression) {
        statement; statement; ...
    } else {
        statement; statement; ...
    }
}

多分支if语法格式
{
    if（expression) {
        statement; statement; ...
    } else if (expression) {
        statement; statement; ...
    } else if (expression) {
        statement; statement; ...
    } else {
        statement; statement; ...
    }
}


```

## switch判断
```
{
    switch (expression) { 
        case VALUE or /REGEXP/: 
            statement1;
        case VALUE or /REGEXP/:
            statement2;
        ... 
        default:
            statement;
    }
}
```

## 循环
```
1. while循环
语法格式
{
    while (expression) {
        statement; statement; ...
    }
}

示例：awk执行数学计算，不需要输入文件，只需要BEGIN即可。
[root@vm1 scripts]# awk 'BEGIN {sum=0;i=1; while (i<=100) {sum+=i;i++}; print sum }'
5050
[root@vm1 scripts]#

2. do...while循环
语法格式
{
    do {
        statement; statement; ...
    } while (expression)
}

示例：使用do...while循环计算从1加到100的和
[root@vm1 scripts]# awk 'BEGIN {sum=0;i=0; do {sum+=i;i++} while (i<=100); print sum}'
5050
[root@vm1 scripts]#

3. for循环
语法格式
{
    for (expr1; expr2; expr3) {
        statement; statement; ...
    }
}

示例：
[root@vm1 scripts]# awk 'BEGIN { sum=0; for (i=0; i<=100; i++) {sum+=i}; print sum}'
5050
[root@vm1 scripts]#


4. break、continue、exit
break：终止循环。
continue：终止此次循环，继续下次循环。
exit：退出程序。

示例：计算从1加到100的偶数之和
[root@vm1 scripts]# awk 'BEGIN { sum=0; for (i=0; i<=100; i++) { if (i%2==0) {sum+=i} else {continue}}; print sum}'
2550
[root@vm1 scripts]#

5. for用户循环数组元素
语法格式
{
    for (item in arrayname) {
        statement; statement;...
    }
}

示例：
[root@vm1 scripts]# awk -F':' '{user[$1]=$3} END {for (item in user) {print item"="user[item]}}' /etc/passwd
vcsa=69
gopher=13
bin=1
apache=48
uucp=10
mail=8
sync=5
saslauth=499
sshd=74
ftp=14
operator=11
shutdown=6
adm=3
games=12
daemon=2
postfix=89
nobody=99
halt=7
root=0
lp=4
[root@vm1 scripts]#

删除数组中的某个元素：delete array[index]
删除数组：delete array
说明：需要注意的是，如果某数据组元素事先不存在，那么在引用时，awk会自动创建此元素并初始化为空串。  

```

## 函数
```
定义函数的语法格式
function name(parameter1,parameter2,parameter3,...) {
    statement;
    statement;
    return expression;
}

调用函数
function-name(parameter1,parameter2,...)

```


# 示例
```
1. 统计各个状态的连接数
[root@oa01 ~]# netstat -tna | head -n -2 | awk 'NR>=3 {state[$NF]++} END {for (i in state) {printf "%-8s\t%s\n",i,state[i]}}'
LISTEN      5
CLOSE_WAIT  1
ESTABLISHED 5
TIME_WAIT   2
[root@oa01 ~]# 

[root@oa01 ~]# ss -tna4 | awk 'NR>=2 {state[$1]++} END {for(i in state) {printf "%-8s\t%s\n",i,state[i]}}'
LISTEN      5
CLOSE-WAIT  1
ESTAB       6
TIME-WAIT   2
[root@oa01 ~]# 


2. 格式化显示磁盘使用率大于%n的磁盘
[root@infragw01 ~]# df -h | awk -F% '/^\/dev/ {print $1,$2}' | awk 'BEGIN {none="NONE";number=0;print "\n\tFileSystem\t\tTotalSize\tUsedSize\tAvailSize\tUsedPercent\tMountPoint";PrintLine()} function PrintLine() {print "-----------------------------------------------------------------------------------------------------------"}  {if ($(NF-1)>=50) {printf "%-24s\t%-8s\t%-8s\t%-8s\t%8s%\t%-8s\n",$1,$2,$3,$4,$5,$6;number++}} END {if (number==0) {printf "%55s\n",none;PrintLine()} else {PrintLine()}}'

    FileSystem      TotalSize   UsedSize    AvailSize   UsedPercent MountPoint
-----------------------------------------------------------------------------------------------------------
/dev/xvda1                  20G         15G         3.8G              80%   /       
-----------------------------------------------------------------------------------------------------------
[root@infragw01 ~]# 

3. 获取内存利用率
计算方法：
剩余内存：free+buffer+cache
使用内存：total - (free+buffer+cache)

CentOS 6和Ubuntu 14系统：
[root@vm10 ~]# free | awk -F: '{print $2}' | awk 'NR==2 {total=$1;free=$3+$(NF-1)+$NF;} END {printf "MemoryUsage:%.2f%\n",(1-free/total)*100}'
MemoryUsage:36.94%
[root@vm10 ~]# 

CentOS 7和Ubuntu 16系统：
root@bjofficedevtest02:~# free | awk -F: '{print $2}' | awk ' NR==2 {total=$1;free=$3+$(NF-1);} END {printf "MemoryUsage:%.2f%\n",(1-free/total)*100}'
MemoryUsage:23.93%
root@bjofficedevtest02:~# 

4. 统计一个或多个文档的总行数、总单词数以及总字符数(不包括空格，只统计我们能够看到的字符)

[root@vm10 ~]# awk 'BEGIN {lines=0;words=0;chars=0} {lines=NR;words+=NF;char=1;while (char<=NF) {chars+=length($char);char++}} END {printf "Lines: %s\nWords: %s\nChars: %s\n",lines,words,chars}' test
Lines: 4
Words: 32
Chars: 120
[root@vm10 ~]# 

5. 查看设备的运行时间
root@bjofficedevtest02:~# uptime | awk -F, '{print $1}' | awk '{for (i=3;i<=NF;i++) {printf "%s ",$i} {printf "\n"} }'
20 days 
root@bjofficedevtest02:~# 

6. 对web访问的log进行统计
作用：统计访问次数最多的前10个IP地址。
[root@kakaooa01 nginx]# awk '{ip[$1]++} END {for (i in ip) {printf "IP: %-15s Count: %s\n",i,ip[i]}}' access.log | sort -r -k 4 -n | head -n 10
IP: 59.108.60.18    Count: 643
IP: 113.108.67.23   Count: 4
IP: 180.153.205.253 Count: 3
IP: 101.226.102.97  Count: 3
IP: 101.226.65.105  Count: 2
IP: 101.226.51.227  Count: 2
IP: 101.226.33.240  Count: 2
IP: 101.226.33.227  Count: 2
IP: 101.226.33.224  Count: 2
IP: 101.226.33.204  Count: 2
[root@kakaooa01 nginx]# 


7. 对用户访问的资源进行统计
# awk '{print $7}' access.log.1 | awk -F? '{resources[$1]++} END {for (i in resources) {printf "Resource: %-70s\tCount: %s\n",i,resources[i]}}' | sort -r -k 4 | head -n 10

```