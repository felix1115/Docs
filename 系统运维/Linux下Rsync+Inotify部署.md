[TOC]

# Inotify介绍
inotify是一种强大的、细粒度的、异步的文件系统监控机制，在Linux内核2.6.13以后的版本中增加了对inotify的支持，通过使用Inotify可以监控文件系统中的添加、删除、移动、修改等等各种细微的事件，利用这个内核接口，通过使用诸如inotify-tools的第三方软件就可以监控文件系统中文件的各种细微的变化情况，通过使用inotify对文件系统中的各种细微事件的监控，当发生变化时，触发rsync的同步，从而实现数据的实时备份。

# Inotify-tools安装
由于inotify需要操作系统的内核达到2.6.13，因此可以使用uname –r查看操作系统的内核版本，如果内核版本低于2.6.13，需要对内核进行重新编译，加入inotify的功能。也可以使用如下方法判断，内核是否支持Inotify。

```bash
[root@vm2 ~]# uname -r
2.6.32-431.el6.x86_64
[root@vm2 ~]# 

[root@vm2 ~]# ls -l /proc/sys/fs/inotify/
total 0
-rw-r--r-- 1 root root 0 Jun 13 07:50 max_queued_events
-rw-r--r-- 1 root root 0 Jun 13 07:50 max_user_instances
-rw-r--r-- 1 root root 0 Jun 13 07:50 max_user_watches
[root@vm2 ~]# 
```

安装inotify-tools
```bash
[root@vm2 ~]# tar -zxvf inotify-tools-3.14.tar.gz 
[root@vm2 ~]# cd inotify-tools-3.14
[root@vm2 inotify-tools-3.14]# ./configure --prefix=/usr/local/source/inotify-tools
[root@vm2 inotify-tools-3.14]# make
[root@vm2 inotify-tools-3.14]# make install
```
安装完成后，在安装目录的bin目录下， 有两个可执行程序inotifywait和inotifywatch。
```bash
[root@vm2 ~]# ls -l /usr/local/source/inotify-tools/bin/
total 88
-rwxr-xr-x 1 root root 44271 Jun 13 07:56 inotifywait
-rwxr-xr-x 1 root root 41393 Jun 13 07:56 inotifywatch
[root@vm2 ~]# 
```
inotifywait：用于等待文件或目录上的特定事件，可以监控任何一组文件或目录，或者是监控整个目录树（目录、子目录、子目录的子目录等）。在shell脚本中使用的是inotifywait。
inotifywatch：用于收集被监视的文件系统的统计数据，包括每个inotify事件发生多少次等信息。


# inotify监控事件
inotify 可以监视的文件系统事件包括：
```text
access：文件被读取
modify：文件被修改。
attrib：文件属性被修改即元数据（Metadata），如执行chmod、chown、touch 等指令。
close_write：具有可写权限的文件被关闭。文件内容不一定修改。
close_nowrite：不可写文件被关闭，即只读文件被关闭。
open：文件被打开
moved_from：文件被移走。即文件从被监视的目录中移走。
moved_to，文件被移来。即文件被移动到被监视的目录下。
create：创建新文件
delete：文件被删除，如rm
delete_self：自删除，即一个可执行文件在执行时删除自己，删除后，文件不会被监控。
move_self：自移动。即一个可执行文件在执行时移动自己，移动后，该文件不会被监控。
unmount：被监控的文件或目录所在的文件系统被 umount，此后不会被监控。
close，文件被关闭，等同于(CLOSE_WRITE | CLOSE_NOWRITE)
move：文件被移动，等同于move_to和move_from
注：上面所说的文件也包括目录。
```

# inotifywait的常用参数
```
Inotifywait是一个监控等待事件，可以配合shell脚本使用它，下面是常用的一些参数：

-m， 即--monitor，表示始终保持事件监听状态，持续监控，而非监控到就退出监控。
-r， 即--recursive，表示递归查询目录。
-q， 即--quiet，表示打印出监控事件。
-e， 即--event，通过此参数可以指定要监控的事件，常用的事件有modify、delete、create、attrib等，如果省略，则监控所有的事件。
--exclude：不监视某个目录或文件。
--timefmt：指定时间格式，常用的为 '%y-%m-%d %H:%M'，等价于'%F %T'
--format：使用用户指定的格式输入，需要使用%T(使用tiemfmt指定的格式替换当前时间)，常用的有：%w(被监视的文件所在的目录)和%f（被监视的文件的名称）
因此在--timefmt和--format时，常用的格式如下：
--timefmt '%F %T' --format ‘%T %w%f’

```

# rsync inotify实时备份
rsync的配置参考另一篇博客：http://blog.csdn.net/xrwwuming/article/details/51648287

inotify的脚本配置
```bash
#!/bin/bash
#Author: Felix
#Date: 2016-06-13
#Description: backup to rsync server

INOTIFYWAIT="/usr/local/source/inotify-tools/bin/inotifywait"
EVENTS="-e create,delete,move,modify,attrib"
BACKUP="/backup/"
SECRETS_FILE="/etc/rsync/rsync.pass"
USER="felix"
HOST="rsync.felix.com"
MODULE="backup"
$INOTIFYWAIT -mrq --timefmt '%F %T' --format '%T %w%f' $EVENTS $BACKUP | while read line
do
        rsync -vzrogpt --delete --progress --password-file=$SECRETS_FILE $BACKUP $USER@$HOST::$MODULE &> /dev/null
done
```

创建/backup目录
```bash
[root@vm2 ~]# mkdir /backup
[root@vm2 ~]# ls -l /backup/
total 0
[root@vm2 ~]# 
```

说明：这里是将所有需要备份的内容放在/backup目录下面，在该目录下面的所有内容都会自动备份。


启动脚本
```bash
[root@vm2 ~]# sh /data/script/inotify.sh &
[1] 3682
[root@vm2 ~]# 
```


测试

```bash
[root@vm2 backup]# cp /etc/hosts .
[root@vm2 backup]# ls -l
total 4
-rw-r--r-- 1 root root 158 Jun 13 09:12 hosts
[root@vm2 backup]# 

[root@vm1 backup]# ls -l
total 4
-rw-r--r-- 1 root root 158 Jun 13 09:12 hosts
[root@vm1 backup]# 
```

# 同一台机器上的两个目录保持同步
脚本配置
```
#!/bin/bash
#Author: Felix
#Date: 2015-11-19
#Description: keep sync in local system directory

INOTIFYWAIT="/usr/local/source/inotify-tools/bin/inotifywait"
EVENTS="-e create,delete,move,modify,attrib"
SOURCE="/dir1/"
DEST="/dir2/"
$INOTIFYWAIT -mrq --timefmt '%F %T' --format '%T %w%f' $EVENTS $SOURCE | while read line
do
        rsync -vzrogpt --delete --progress $SOURCE $DEST &> /dev/null
done
```

创建测试目录
```bash
[root@vm2 script]# mkdir /dir1
[root@vm2 script]# mkdir /dir2
[root@vm2 script]# 
```

启动脚本
```bash
sh /data/script/inotify_local_dir.sh &
```

测试
```bash
[root@vm2 ~]# ls -l /dir1 /dir2
/dir1:
total 0

/dir2:
total 0
[root@vm2 ~]# cp /etc/hosts /dir1
[root@vm2 ~]# ls -l /dir1 /dir2
/dir1:
total 4
-rw-r--r-- 1 root root 158 Jun 13 09:21 hosts

/dir2:
total 4
-rw-r--r-- 1 root root 158 Jun 13 09:21 hosts
[root@vm2 ~]# cp -a /root /dir1/
[root@vm2 ~]# ls -l /dir1 /dir2
/dir1:
total 8
-rw-r--r--  1 root root  158 Jun 13 09:21 hosts
dr-xr-x---. 6 root root 4096 Jun 13 09:20 root

/dir2:
total 8
-rw-r--r-- 1 root root  158 Jun 13 09:21 hosts
dr-xr-x--- 6 root root 4096 Jun 13 09:20 root
[root@vm2 ~]#
```