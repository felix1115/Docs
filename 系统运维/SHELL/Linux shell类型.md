# Shell类型
## 登录shell(需要密码)
```text
1. 正常通过某一个终端来登录，需要输入用户名和密码。
2. 使用su - username
3. 使用su -l username
```

## 非登录shell(不需要密码)
```text
1. su username
2. 图形终端下打开终端窗口
3. 自动执行的shell脚本
```

# BASH的配置文件
## 全局配置
```text
 /etc/profile
 /etc/profile.d/*.sh
 /etc/bashrc

编辑以上3个配置文件中的任何一个，对所有的用户都生效。
```


## 个人配置
```text
使用的配置文件位于用户家目录下的如下两个文件：
~/.bash_profile
~/.bashrc

上述的两个文件只对当前用户生效。

如果全局配置和个人配置导致冲突，则以个人配置的优先。
```


# 文件读取顺序
```
profile类的文件作用：
    定义环境变量。
    运行命令或脚本。

bashrc类的文件的作用：
    定义本地变量
    定义命令别名

登录shell读取配置文件的顺序：
/etc/profile --> /etc/profile.d/*.sh --> ~/.bash_profile --> ~/.bashrc --> /etc/bashrc

非登录shell读取配置文件的顺序：
~/.bashrc --> /etc/bashrc --> /etc/profile.d/*.sh
```