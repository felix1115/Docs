# 变量操作
```text
1. 命令行中启动的脚本会继承当前shell的环境变量。
2. 系统自动执行的脚本（非命令行启动）就需要用户自己定义各环境变量。
```

## 变量大小写转换
```bash
## 定义一个变量，格式: 变量名=变量值。这种方式定义的变量为本地变量，作用域为整个bash进程。
[root@vm10 ~]# a=framE

## 定义一个局部变量。格式：local 变量名=变量值。 这种方式定义的变量为局部变量，作用域为当前代码段。local只能用在函数中。
[root@vm10 tmp]# cat 1.sh
#!/bin/bash
name=felix

function test() {
    echo $name
    local name=zhang
    echo $name
}

test
echo $name
[root@vm10 tmp]# sh 1.sh
felix
zhang
felix
[root@vm10 tmp]#


## 让变量在子shell也有效。格式：export 变量名=变量值。这种方式定义的变量为环境变量，作用域为当前shell及子shell。
```bash
[root@vm10 tmp]# name=felix
[root@vm10 tmp]# echo ${name}
felix
[root@vm10 tmp]# bash
[root@vm10 tmp]# echo ${name}

[root@vm10 tmp]# exit
exit
[root@vm10 tmp]# export name=felix
[root@vm10 tmp]# echo ${name}
felix
[root@vm10 tmp]# bash
[root@vm10 tmp]# echo ${name}
felix
[root@vm10 tmp]#
```
## 取消变量设置
```bash
[root@vm10 tmp]# unset name
[root@vm10 tmp]# echo ${name}

[root@vm10 tmp]#

```

## 查看变量的内容。格式： echo $variable 或 echo ${variable}
```bash
[root@vm10 ~]# echo $a
framE
[root@vm10 ~]# echo ${a}
framE
[root@vm10 ~]#
```
## 变量的首字母大写。格式：echo ${variable^}
```bash
[root@vm10 ~]# echo ${a^}
FramE
[root@vm10 ~]#
```
## 变量的所有字母大写。格式：echo ${variable^^}
```bash
[root@vm10 ~]# echo ${a^^}
FRAME
[root@vm10 ~]#
```
## 变量的首字母小写。格式：echo ${variable,}
```bash
[root@vm10 ~]# a=FramE
[root@vm10 ~]# echo ${a}
FramE
[root@vm10 ~]#
[root@vm10 ~]# echo ${a,}
framE
[root@vm10 ~]#
```
## 变量的所有字母小写。格式：echo ${variable,, }
```bash
[root@vm10 ~]# a=FramE
[root@vm10 ~]# echo ${a,,}
frame
[root@vm10 ~]#
```
## 变量的首字母大小写转换。格式:echo ${variable~}
```bash
[root@vm10 ~]# echo ${a}
FramE
[root@vm10 ~]# echo ${a~}
framE
[root@vm10 ~]#
```
## 变量的所有字母大小写转换。格式：echo ${variable~~}
```bash
[root@vm10 ~]# echo ${a}
FramE
[root@vm10 ~]# echo ${a~~}
fRAMe
[root@vm10 ~]#
```
## 总结

^：首字母大写
^^：所有字母大写
,：首字母小写
,,：所有字母小写
~：首字母大小写切换
~~：所有字母大小写切换
```

## 移除匹配的字符串
```bash
[root@vm10 network-scripts]# filename=$(pwd)
[root@vm10 network-scripts]# echo $filename
/etc/sysconfig/network-scripts
[root@vm10 network-scripts]#

## 从前往后删除，删除到最短的匹配内容。格式：echo ${variable#}
[root@vm10 network-scripts]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 network-scripts]# echo ${filename#*/}
etc/sysconfig/network-scripts
[root@vm10 network-scripts]#

## 从前往后删除，删除到最长的匹配内容。格式：echo ${variable##}
[root@vm10 network-scripts]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 network-scripts]# echo ${filename##*/}
network-scripts
[root@vm10 network-scripts]#

## 从后往前删除，删除到最短的匹配内容。格式：echo ${variable%}
[root@vm10 network-scripts]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 network-scripts]# echo ${filename%/*}
/etc/sysconfig
[root@vm10 network-scripts]# echo ${filename%%/*}

[root@vm10 network-scripts]#
## 从后往前删除，删除到最长的匹配内容：格式：echo ${variable%%}
[root@vm10 network-scripts]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 network-scripts]# echo ${filename%%/*}

[root@vm10 network-scripts]#
```

## 查找与替换
```bash
## 将第一次匹配到的内容进行替换。格式：echo ${variable/match/value}
[root@vm10 ~]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 ~]# echo ${filename/s/S}
/etc/Sysconfig/network-scripts
[root@vm10 ~]#

## 将所有匹配到的内容进行替换。格式：echo ${variable//match/value}
[root@vm10 ~]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 ~]# echo ${filename//s/S}
/etc/SySconfig/network-ScriptS
[root@vm10 ~]#

## 总结
/match/value：将第一次出现的match替换成value
//match/value：将所有的match替换成value
```

## 其他变量的操作
```bash
## 获取变量内容的长度。格式：echo ${#variable}
[root@vm10 ~]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 ~]# echo ${#filename}
30
[root@vm10 ~]#

## 变量的切片操作。格式： echo ${variable:offset:lenght}。offset表示偏移值，从0开始，如果省略，默认为0。length表示要截取的字符串长度，如果length没有指定，则默认到结尾。
[root@vm10 ~]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 ~]# echo ${filename::4}
/etc
[root@vm10 ~]#

[root@vm10 ~]# echo ${filename}
/etc/sysconfig/network-scripts
[root@vm10 ~]# echo ${filename:5:9}
sysconfig
[root@vm10 ~]#

[root@vm10 tmp]# filename=$(pwd)
[root@vm10 tmp]# echo ${filename}
/tmp
[root@vm10 tmp]# echo ${filename:2}
mp
[root@vm10 tmp]#

```


## 特殊变量
```bash
$?：命令的退出状态码。0表示true，非0表示false。
$#：命令行的参数个数。
$*：命令行的参数列表。所有的参数作为一个整体，一个字符串。
$@：命令行的参数列表。每一个参数都是独立的字符串。
$$：脚本的进程ID（PID）。
```

## 位置变量
```bash
$0：脚本名称
$1：第一个参数
$2：第二个参数
${10}：第十个参数。
shift number：位置变量的偏移数。如果省略number，则偏移一个，否则偏移number个。
```

## 特殊的变量替换
```
${var-string}：当变量var没有设置(未定义该变量)，则返回string的内容，否则返回原值。
$(var:-string)：当变量var没有设置(未定义该变量)，或者是变量的内容为空，则返回string的内容，否则返回原值。
${var+string}：当变量var没有设置(未定义该变量)，则返回空值，如果有设置(包括空值)，则返回string的内容。
${var:+string}：当变量var没有设置(未定义该变量)，或者变量值为空，则返回空值，当var的内容不为空，则返回string的内容。
${var=string}：当变量var没有定义时，则将string的内容赋值给var。
${var:=string}：当变量var没有定义或者为空时，则将string的内容赋值给var。

-：表示没有定义变量时，返回string。
+：表示定义了变量时，返回string。
=：表示变量赋值。
:：冒号表示包括空值的情况。
```

# 算数运算
## 方法1：let
```bash
[root@vm10 tmp]# a=10
[root@vm10 tmp]# b=15
[root@vm10 tmp]# let c=$a*$b
[root@vm10 tmp]# echo $c
150
[root@vm10 tmp]#
```

## 方法2：$[算数表达式]
```bash
[root@vm10 tmp]# a=10
[root@vm10 tmp]# b=15
[root@vm10 tmp]# echo $c
25
[root@vm10 tmp]#
```

## 方法3：$((算数表达式))
```bash
[root@vm10 tmp]# a=10
[root@vm10 tmp]# b=15
[root@vm10 tmp]# echo $(($a-$b))
-5
[root@vm10 tmp]#
```

## 方法4：$(expr 算术表达式)或者是`expr 算数表达式`
```text
说明：各个操作数和操作符之间需要有空格。
```
```bash
[root@vm10 tmp]# a=10
[root@vm10 tmp]# b=15
[root@vm10 tmp]# echo `expr $a - $b`
-5
[root@vm10 tmp]#
```

## 方法5：((expression))
```bash
[root@vm10 tmp]# a=10
[root@vm10 tmp]# ((a--))
[root@vm10 tmp]# echo $a
9
[root@vm10 tmp]# ((a--))
[root@vm10 tmp]# echo $a
8
[root@vm10 tmp]# 

```


# 条件测试
## 条件测试方法
```bash
[ expression ]
[[ expression ]]
test expression
注：中括号左右两边要有空格。
```

## 整数判断
```bash
格式：[ $A 判断类型  $B ]
-eq：测试$A是否等于$B
-ne：测试$A是否不等于$B
-gt：测试$A是否大于$B
-lt：测试$A是否小于$B
-ge：测试$A是否大于等于$B
-le：测试$A是否小于等于$B
```

## 文件测试
```bash
-e FILE：测试文件FILE是否存在。
-f FILE：测试文件FILE是否为普通文件。
-d FILE：测试指定路径是否为目录。
-r FILE：测试指定文件对当前用户来说是否可读。
-w FILE：测试指定文件对当前用户来说是否可写。
-x FILE：测试指定文件对当前用户来说是否可执行。
-b FILE：测试指定文件是否为块设备文件。
-c FILE：测试指定文件是否为字符设备文件。
-h FILE: 测试指定文件是否为链接文件。
-L FILE：测试指定文件是否为链接文件。
-p FILE: 测试指定文件是否为管道文件。
-s FILE: 测试指定文件存在且大小大于0。
-S FILE: 测试指定文件是否为Socket文件。
-u FILE: 测试指定文件是否设置了SUID位。
-g FILE: 测试指定文件是否设置了SGID位。
-k FILE: 测试指定文件是否设置了SBIT位。
file1 -nt file2：file1比file2新时返回真
file1 -ot file2：file1比file2旧时返回真
```

## 字符串判断
```bash
==：判断两个字符串是否相等。等号两端需要有空格。字符串可以用引号，也可以不用引号。
!=：判断两个字符串是否不相等。
>：判断字符串1是否大于字符串2。
<：判断字符串1是否小于字符串2。
-n "string"：判断一个字符串是否为非空。非空为真，空为假。
-z "string"：判断一个字符串是否为空。空为真，非空为假。
```

## 逻辑判断
```bash
格式：A 逻辑判断 B
逻辑与：&&。如果A为真，则执行B。如果A为假，则不执行B。
逻辑或：||。如果A为真，则不执行B。如果A为假，则执行B。
逻辑非：!。格式为：！A，如果A为真，则! A为假，如果A为假，则！A为真。
```

## 条件判断使用正则表达式
```
语法格式为：[[ expression ]]
匹配运算符：=~
```

```bash
[root@vm10 tmp]# cat 1.sh 
#!/bin/bash

DATE_FORMAT="^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$"

read -p "Please input a date [Format: 1970-1-1]: " date
if [[ $date =~ $DATE_FORMAT ]];then
    echo "Ok"
else
    echo "Invalid Date Format"
fi
[root@vm10 tmp]# 

[root@vm10 tmp]# sh 1.sh 
Please input a date [Format: 1970-1-1]: 20161111
Invalid Date Format
[root@vm10 tmp]# sh 1.sh 
Please input a date [Format: 1970-1-1]: 2016-08-15
Ok
[root@vm10 tmp]# sh 1.sh 
Please input a date [Format: 1970-1-1]: 2016-8-15
Ok
[root@vm10 tmp]# sh 1.sh 
Please input a date [Format: 1970-1-1]: 2016-8-5
Ok
[root@vm10 tmp]#

```

# if判断
## 单分支if语句
```text
if 判断条件; then
    statement1
    statement2
    ...
fi
```

## 双分支if语句
```text
if 判断条件; then
    statement1
    statement2
else
    statement3
    statement4
fi
```

## 多分支if语句
```text
if 判断条件; then
    statement1
    statement2
    ...
elif 判断条件; then
    statement3
    statement4
    ...
elif 判断条件; then
    statement5
    statement6

...

else
    statement7
    ...
fi
```

## 组合条件
```text
-a：逻辑与
-o：逻辑或
!：非
```

# case
```text
case 值 in
value1)
    statement1
    ;;
value2)
    statement2
    ;;
...

*)
    statementN
    ;;
esac

```

# 循环
## for循环
### 语法1
```text
for 变量 in 循环列表
do
    循环体
done
```

### 语法2
```text
for ((初始值; 结束条件; 变化值))
do
    循环体
done
```

### 生成列表的方法
```text
方法1：
{a..b}：表示从a到b，默认步长为1。
{a..b..c}：表示从a到b，并以c为步长。

方法2：
seq [OPTION]... LAST
seq [OPTION]... FIRST LAST
seq [OPTION]... FIRST INCREMENT LAST
```

## while循环
```text
while CONDITION
do
    statement
    ……
done
说明：while是当CONDITION成立的时候就执行循环，当条件不成立时，退出循环。
```

```text
while死循环的方式

方法1：
while true
do
    statement
    ...
done

方法2：
while :
do
    statement
    ...
done
```


## until循环
```text
until CONDITION
do
    statement
    ……
done
说明：until是当CONDITION不成立的时候就执行循环，当条件成立时，退出循环。
```

## break和continue
```text
break：终止循环。
continue：终止此次循环，进行下一次循环。不会执行continue后面的语句。
```

# 函数
## 方法1
```text
function function-name() {
    函数体
}
```

## 方法2：
```text
function-name() {
    函数体
}
```

## 调用函数
```text
function-name
```

# 退出程序和退出函数
```text
退出程序：exit [number]   
退出函数：return [number]
number表示0-255.
```

