# read介绍和示例
```text
read从标准输入(stdin，默认是键盘)，或者是从文件描述符(FD)读取一行内容，并且赋值给一个变量，如果所赋值的变量没有指定，则默认将输入的内容存储在REPLY变量中。
```

## 示例1: 从标准输入获取输入，并赋值给一个变量
```bash
[root@vm10 ~]# cat 1.sh
#!/bin/bash

echo -n 'Please enter your username: '
read name
echo "Your username is: $name"
[root@vm10 ~]#
[root@vm10 ~]# sh 1.sh
Please enter your username: felix
Your username is: felix
[root@vm10 ~]#
```


## 示例2: 从标准输入获取输入，没有赋值给一个变量
```bash
[root@vm10 ~]# cat 2.sh
#!/bin/bash

echo -n 'Please enter your username: '
read
echo "Your username is: $REPLY"
[root@vm10 ~]#
[root@vm10 ~]#
[root@vm10 ~]# sh 2.sh
Please enter your username: felix.zhang
Your username is: felix.zhang
[root@vm10 ~]#
```

## 示例3: 使用-p选项指定一个提示符
```bash
[root@vm10 ~]# cat 3.sh
#!/bin/bash

read -p 'Please enter your username: ' name

echo "Your username is: $name"
[root@vm10 ~]#
[root@vm10 ~]# sh 3.sh
Please enter your username: felix.zhang
Your username is: felix.zhang
[root@vm10 ~]#
```

## 示例4: 使用-t选项指定超时时间
```text
当使用read时，如果用户没有输入，则read会一直等待用户输入，可以使用-t选项指定一个超时时间，当超时后，read命令会返回一个非零退出状态。
```

```bash
[root@vm10 ~]# cat 4.sh
#!/bin/bash

if read -t 5 -p 'Please enter your name: ' name; then
    echo "Hello $name"
else
    echo
    echo 'Timeout'
fi
[root@vm10 ~]#
[root@vm10 ~]#
[root@vm10 ~]# sh 4.sh
Please enter your name:
Timeout
[root@vm10 ~]#
[root@vm10 ~]# sh 4.sh
Please enter your name: felix.zhang
Hello felix.zhang
[root@vm10 ~]#
```

## 示例5: 使用-s选项，输入数据不回显(不显示在显示器上)
```text
注意：当-s和-p选项一起使用时，-s要放在-p的前面。可以是-sp或者是-s -p
```

```bash
[root@vm10 ~]# cat 5.sh
#!/bin/bash

read -s -p 'Please enter your password: ' password

echo
echo "Your password is: "$password
[root@vm10 ~]#
[root@vm10 ~]# sh 5.sh
Please enter your password:
Your password is: felix.zhang
[root@vm10 ~]#
```

## 示例6: 使用-n选项读取指定数量的字符
```text
采用-n的方式读取n个字符后，不需要用户按回车，read读取到指定数量的字符后就将其传递给变量。
```

```bash
[root@vm10 ~]# cat 6.sh
#!/bin/bash

read -n1 -p 'Do you want to continue [y/n]? ' answer

case $answer in
    y|Y)
        echo
        echo 'You answer is: yes'
        ;;
    n|N)
        echo
        echo 'You answer is: no'
        ;;
    *)
        echo
        echo 'You answer is invalid'
        ;;
esac
[root@vm10 ~]#
[root@vm10 ~]# sh 6.sh
Do you want to continue [y/n]? y
You answer is: yes
[root@vm10 ~]# sh 6.sh
Do you want to continue [y/n]? n
You answer is: no
[root@vm10 ~]# sh 6.sh
Do you want to continue [y/n]? a
You answer is invalid
[root@vm10 ~]#
```

## 示例7: read读取文件(模拟cat -n)
```text
使用read读取文件中的内容时，一次会读取一行内容，当读取到文件的结束时，read会以非零的状态退出。
```

```bash
[root@vm10 ~]# cat 7.sh
#!/bin/bash

lineNumber=0
cat /etc/issue | while read line
do
    lineNumber=$[ $lineNumber + 1 ]
    echo -e "\t$lineNumber  $line"
done
[root@vm10 ~]#
[root@vm10 ~]# sh 7.sh
	1  CentOS release 6.5 (Final)
	2  Kernel r on an m
	3  
[root@vm10 ~]#
```
