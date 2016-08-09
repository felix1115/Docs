# sed
```text
sed称之为流编辑器或者是行编辑器。

sed处理过程：sed从源文件中读取一行，并将其放在临时缓冲区中，这个缓冲区称为模式空间，接着使用sed命令对模式空间进行来处理，处理完成后，将模式空间中的内容显示到屏幕，接着处理下一行，直到文件末尾。sed在处理时，并没有直接修改源文件的内容。除非使用-i选项或者是输出重定向。
```

# sed语法格式
```text
sed [options] 'AddressCommand' file ...

options:
-n：静默模式，不显示模式空间中的内容，默认显示模式空间中的内容。常和p命令一起使用。
-i：直接修改源文件的内容。
-e 'AddressCommand' -e 'AddressCommand'：同时执行多个操作。等同于‘;’
-f：指定sed脚本文件的路径。
-r：默认情况下，sed只支持基本的正则表达式，如果要使用扩展表达式，需要用-r选项。
```

```text
Address格式

1.StartLine,EndLine
    如：1,100：表示的是从第一行到第100行。
        $：表示的是最后一行。
2./RegEXP/  正则表达式。
    如：/^root/以root开头的行。
3./pattern1/,/pattern2/
    表示的是从第一次被pattern1模式匹配的行开始，到第一次配patter2匹配的行结束，中间的所有行。
4.LineNumber
    表示的一个指定的行号。
5.StartLine,+N
    表示的是从startline行开始，向后的N行，总共N+1行，包括当前行和后面的N行。
6. first~step
    表示从first行开始，每隔step行。如1~2，则表示每隔两行，及显示奇数行。2~2，则表示偶数行。

```

```text
Command格式

a\：在匹配行的后面插入文本。
i\：在匹配行的上面插入文本。
c\：把匹配的行修改成指定的文本。
d\：删除匹配的行。

p：显示匹配的行。
q：退出sed。
!：表示取反操作。

r file：读取文件内容添加到匹配行的后面。
R file：读取文件中的一行内容添加到匹配行的后面。
w file：将匹配的内容写入到指定的文件中。（覆盖写）

=：打印当前被模式匹配的行的号码。

n：读取下一个输入行，用下一个命令处理新的行而不是用第一个命令。

s；对匹配的内容进行替换。语法格式：s/pattern/string/flags
说明：如果没有指定flags，则只执行第一次匹配的内容
    pattern：可以使用正则表达式执行模式匹配。
    string：表示要替换的内容，不能是正则表达式。
    flags：表示的是标记。标记有：
        g：表示全局替换，替换所有匹配的内容。
        i：表示忽略大小写。
        p：表示打印匹配的内容。
        w file：表示把被模式匹配的内容写入到指定的文件中。
        y：把一个字符翻译成为另外的字符，但是不用于正则表达式。
        格式为：y/被变换的字符序列/变换的字符序列/
        &：表示已匹配字符串标记。
        \1：后向引用。
        number：为数字，表示替换第几次出现的。如2，表示替换第二次出现的。
        说明：flags可以使用多个。

    /：表示的是定界符。定界符也可以是其他的形式，如#、%等。

sed '表达式1;表达式2'：使用分号组合多个表达式。

sed表达式可以使用单引号，如果表达式里面要包含变量，则要使用双引号。

{ }: 表示的是在指定的行上执行命令块。各个命令之间用分号隔开。如{d;p;n}
```

# sed示例
```bash
示例1：-n选项和p命令。只显示那些发生匹配的行
[root@vm10 tmp]# cat hosts  | sed -n '/^127/p'
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
[root@vm10 tmp]# 

示例2：s命令，替换
默认：替换第一次匹配的。
[root@vm10 tmp]# cat hosts  | sed 's/localhost/LOCALHOST/'
127.0.0.1   LOCALHOST localhost.localdomain localhost4 localhost4.localdomain4
::1         LOCALHOST localhost.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]#

指定数字，替换第2次和第三次匹配的。 
[root@vm10 tmp]# cat hosts  | sed 's/localhost/LOCALHOST/2'
127.0.0.1   localhost LOCALHOST.localdomain localhost4 localhost4.localdomain4
::1         localhost LOCALHOST.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]# cat hosts  | sed 's/localhost/LOCALHOST/3'
127.0.0.1   localhost localhost.localdomain LOCALHOST4 localhost4.localdomain4
::1         localhost localhost.localdomain LOCALHOST6 localhost6.localdomain6
[root@vm10 tmp]# 

指定3g，替换第n次以后出现的。
[root@vm10 tmp]# cat hosts  | sed 's/localhost/LOCALHOST/3g'
127.0.0.1   localhost localhost.localdomain LOCALHOST4 LOCALHOST4.localdomain4
::1         localhost localhost.localdomain LOCALHOST6 LOCALHOST6.localdomain6
[root@vm10 tmp]# 


示例3：d命令。
[root@vm10 tmp]# cat /etc/issue
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@vm10 tmp]# 

删除第二行
[root@vm10 tmp]# cat /etc/issue | sed '2d'
CentOS release 6.5 (Final)

删除从第二行到最后一行
[root@vm10 tmp]# cat /etc/issue | sed '2,$d'
CentOS release 6.5 (Final)
[root@vm10 tmp]# 

删除空白行
[root@vm10 tmp]# cat /etc/issue | sed '/^$/d'
CentOS release 6.5 (Final)
Kernel \r on an \m
[root@vm10 tmp]# 


删除匹配指定模式的行
[root@vm10 tmp]# cat hosts 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]# cat hosts  | sed '/^127/d'
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]# 

示例4：已匹配字符串标记&
[root@vm10 tmp]# echo 'This is a test line' | sed 's#\w\+#[&]#g'
[This] [is] [a] [test] [line]
[root@vm10 tmp]# 

说明：\w表示正则表达式，匹配每一个单词。+，表示前一个字符出现1次或多次。#表示定界符。

示例5：后向引用
[root@vm10 tmp]# cat /etc/issue
CentOS release 6.5 (Final)
Kernel \r on an \m

[root@vm10 tmp]# 

[root@vm10 tmp]# cat /etc/issue | sed -n 's#CentOS release \([0-9]\.[0-9]\) (Final)#\1#p'
6.5
[root@vm10 tmp]# 

示例6：表达式内部包含变量
[root@vm10 tmp]# host=localhost
[root@vm10 tmp]# 
[root@vm10 tmp]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]# 
[root@vm10 tmp]# cat /etc/hosts | sed "s/^127.0.0.1/$host/g"
localhost   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
[root@vm10 tmp]# 


示例7：打印奇数行和偶数行。
奇数行：1~2p, 或者是p;n
偶数行：2~2p, 或者是n;p

方法1：
[root@vm10 tmp]# cat /etc/issue -n
     1  CentOS release 6.5 (Final)
     2  Kernel \r on an \m
     3  
[root@vm10 tmp]# 
[root@vm10 tmp]# cat /etc/issue -n | sed -n '1~2p'
     1  CentOS release 6.5 (Final)
     3  
[root@vm10 tmp]# cat /etc/issue -n | sed -n '2~2p'
     2  Kernel \r on an \m
[root@vm10 tmp]# 

方法2：
[root@vm10 tmp]# cat -n /etc/issue | sed -n 'p;n'
     1  CentOS release 6.5 (Final)
     3  
[root@vm10 tmp]# cat -n /etc/issue | sed -n 'n;p'
     2  Kernel \r on an \m
[root@vm10 tmp]# 


示例8：给文件添加或删除注释
添加注释：sed 's/^/# /'

[root@vm10 tmp]# cat /etc/issue | sed 's/^/# /'
# CentOS release 6.5 (Final)
# Kernel \r on an \m
# 
[root@vm10 tmp]#

删除注释：sed '1s/^# //'
[root@vm10 tmp]# head -n 2 /etc/inittab  | sed '1s/^# //'
inittab is only used by upstart for the default runlevel.
#
[root@vm10 tmp]# 

```