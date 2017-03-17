# mkpasswd的使用
```
依赖：需要安装expect软件包


1. 作用：产生一个随机密码。
2. 使用方法
-l：密码长度
-d：数字位数
-c：小写字母位数
-C：大写字母位数
-s：特殊字符位数。

示例：
[root@vm07 ~]# mkpasswd  -l 20 -d 5 -c 8 -C 4 -s 3
%'t3vw64M?oZ4yho3cIM
[root@vm07 ~]# mkpasswd  -l 20 -d 5 -c 8 -C 4 -s 3
8fT30!7VahF/wxx4]wwZ
[root@vm07 ~]#
```