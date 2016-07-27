[TOC]

# rsync介绍
传统的数据备份方式有cp和wget以及ssh等方式，cp要求源数据和目标数据都必须在本地，而wget和ssh则是通过网络进行备份，每次都是全备，无法实现数据的增量备份，因此浪费网络带宽和时间。
rsync：remote sync，是类UNIX系统下的一个工具，可以实现数据的本地镜像和远程备份。
rsync是基于C/S模式的，因此分为客户端和服务器端的配置。第一次同步时 rsync会复制全部内容，但在下一次只传输修改过的文件。rsync 在传输数据的过程中可以进行压缩及解压缩操作，因此可以使用更少的带宽。

Rsync 支持大多数的类 Unix 系统，无论是 Linux 、 Solaris 还是 BSD 上都经过了良好的测试。此外，它在 windows 平台下也有相应的版本，比较知名的有 cwRsync 和 Sync2NAS 。

rsync 的基本特点如下：
1. 可以镜像保存整个目录树和文件系统；
2. 可以很容易做到保持原来文件的权限、时间、软硬链接等；
3. 无须特殊权限即可安装和执行；
4. 优化的流程，文件传输效率高；
5. 可以使用SSH对传输的数据进行加密，保证了数据的安全；
6. 支持匿名传输。

# rsync的安装和模式介绍
## rsync的安装
* rpm包安装
```bash
[root@vm1 ~]# yum install -y rsync
```

* 源码安装
```bash
[root@vm2 ~]# file rsync-3.1.1.tar.gz 
rsync-3.1.1.tar.gz: POSIX tar archive (GNU)
[root@vm2 ~]# tar -xf rsync-3.1.1.tar.gz 
[root@vm2 ~]# cd rsync-3.1.1
[root@vm2 rsync-3.1.1]# ./configure
[root@vm2 rsync-3.1.1]# make
[root@vm2 rsync-3.1.1]# make install

```

## rsync的选项
```text
-v, --verbose 详细模式输出
-q, --quiet 精简输出模式
-c, --checksum 打开校验开关，强制对文件传输进行校验
-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
-r, --recursive 对子目录以递归模式处理
-R, --relative 使用相对路径信息
-b, --backup 创建备份，也就是对于目标已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
   --backup-dir=DIR 将备份文件(如~filename)存放在哪个目录下。
   --suffix=SUFFIX 定义备份文件前缀
-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
-l, --links 保留软链结
-L, --copy-links 像对待常规文件一样处理软链结
   --copy-unsafe-links 仅仅拷贝指向SRC路径目录树以外的链结
   --safe-links 忽略指向SRC路径目录树以内的链结
-H, --hard-links 保留硬链结
-p, --perms 保持文件权限
-o, --owner 保持文件属主信息
-g, --group 保持文件属组信息
-D, --devices 保持设备文件和特殊文件信息
-t, --times 保持文件时间信息
-S, --sparse 对稀疏文件进行特殊处理以节省DST的空间
-n, --dry-run显示哪些文件将被传输
-W, --whole-file 拷贝文件，不进行增量检测
-X：保留文件的扩展属性（SUID/SGID/SBIT）
-A:保留文件的ACL属性信息。
-x, --one-file-system 不要跨越文件系统边界
-B, --block-size=SIZE 检验算法使用的块尺寸，默认是700字节
-e：指定使用rsh、ssh方式进行数据同步，默认为ssh
    --rsync-path=PATH 指定远程服务器上的rsync命令所在路径信息
-C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
--existing 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件
--delete 删除那些DST中有而SRC中没有的文件，删除的是DST中的文件，是以SRC为基准的。
--delete-excluded 同样删除接收端那些被该选项指定排除的文件
--delete-after 传输结束以后再删除
--ignore-errors 即使出现IO错误也进行删除
--max-delete=NUM 最多删除NUM个文件
--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输，支持断点续传。
--min-size：传输文件的最小大小。单位是K/M/G
--max-size：传输文件的最大大小。单位是K/M/G
--force 强制删除目录，即使不为空
--numeric-ids 不将数字的用户和组ID匹配为用户名和组名
--timeout=TIME IP超时时间，单位为秒
-I, --ignore-times 不跳过那些有同样的时间和长度的文件
--size-only 当决定是否要备份文件时，仅仅察看文件大小而不考虑文件时间
--modify-window=NUM 决定文件是否时间相同时使用的时间戳窗口，默认为0
-T --temp-dir=DIR 在DIR中创建临时文件
--compare-dest=DIR 同样比较DIR中的文件来决定是否需要备份
-P 等同于 --partial
-z, --compress 对备份的文件在传输时进行压缩处理
    --compress-level=NUM：指定压缩等级
--exclude=PATTERN 指定排除不需要传输的文件模式
--include=PATTERN 指定需要传输的文件模式
--exclude-from=FILE 排除FILE文件中指定模式的文件
--include-from=FILE 不排除FILE文件指定模式匹配的文件
--version 打印版本信息
--blocking-io 对远程shell使用阻塞IO
--stats 给出某些文件的传输状态
-h：以人类可读的方式显示传输信息。
--progress 在传输时显示传输过程
--log-format=formAT 指定日志文件格式
--password-file=FILE 从FILE中得到密码.password文件的权限不能被其他用户读。

DAEMON模式的选项：
--daemon：以daemon的方式启动
--address：绑定到特定的接口地址
--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
--port=PORT 指定其他的rsync服务端口
--bwlimit=KBPS 限制I/O带宽，KBytes per second
常用的选项为： avz --delete --progress
```


## rsync的模式介绍

### 本地shell模式
本地shell模式类似于cp命令，可以在系统内部实现数据复制。

语法格式
```text
rsync [OPTION]... SRC [SRC]... DEST
```

示例：
```
[root@vm1 tmp]# rsync -avz /etc/hosts /tmp/
sending incremental file list
hosts

sent 124 bytes  received 31 bytes  103.33 bytes/sec
total size is 158  speedup is 1.02
[root@vm1 tmp]# ls -l /tmp/
total 4
-rw-r--r-- 1 root root 158 Jan 12  2010 hosts
[root@vm1 tmp]# 

```

### 远程shell模式
远程shell模式是在不同的服务器之间传输数据。

语法格式
```
Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
```

示例1： 将数据push到远端服务器上
```bash
[root@vm1 tmp]# rsync -avz /etc/hosts root@172.17.100.2:/tmp/
root@172.17.100.2's password: 
Permission denied, please try again.
root@172.17.100.2's password: 
sending incremental file list
hosts

sent 124 bytes  received 31 bytes  16.32 bytes/sec
total size is 158  speedup is 1.02
[root@vm1 tmp]# 

[root@vm2 tmp]# ls -l
total 4
-rw-r--r-- 1 root root 158 Jan 12  2010 hosts
[root@vm2 tmp]# 

```

示例2： 从远端服务器上pull数据
```bash
[root@vm1 tmp]# ls -l
total 0
[root@vm1 tmp]# rsync -avz root@172.17.100.2:/etc/issue /tmp/
root@172.17.100.2's password: 
receiving incremental file list
issue

sent 42 bytes  received 129 bytes  48.86 bytes/sec
total size is 47  speedup is 0.27
[root@vm1 tmp]# ls -l
total 4
-rw-r--r-- 1 root root 47 Nov 27  2013 issue
[root@vm1 tmp]# 
```

### 列表模式
列表模式实现的是类似于ls的功能，可以查看本地或远程服务器上的文件或目录。

示例1：列出本地目录下的文件
```bash
[root@vm1 tmp]# rsync /tmp/
dr-xr-x---        4096 2016/06/12 14:01:21 .
-rw-r--r--          47 2013/11/27 19:53:33 issue
[root@vm1 tmp]# 

```

示例2：列出远程服务器上的文件
```bash
[root@vm1 tmp]# rsync root@172.17.100.2:/tmp/
root@172.17.100.2's password: 
drwxrwxrwt        4096 2016/06/12 13:59:34 .
-rw-r--r--         158 2010/01/12 21:28:22 hosts
drwxrwxrwt        4096 2016/06/12 13:50:21 .ICE-unix
[root@vm1 tmp]# 
```

### daemon模式
语法格式
```bash
Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
      rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
      rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST
```

注意：
1. 这里的user指的是连接rsync服务器指定模块的用户名。
2. 如果没有SRC和DEST的话，则表示列出模块下的内容。


# rsync服务器配置(Daemon模式)
说明：
1. rsync的配置文件为rsyncd.conf，可以使用--config选项指定要使用的配置文件。默认情况下，并没有提供该配置文件，需要手动创建。
2. 该配置文件由两部分组成，模块和参数。
3. 模块的格式：[Module]
4. 参数的格式：属性 = 值
5. 以#开头的表示注释。值的部分可以是yes、no、0、1、true或false。

## 参数
motd file：指定motd（message of the day）的位置。当客户端每一次连接时都会显示该文件中的内容，没有默认值。
pid file：指定rsync的pid文件存储位置。
lock file：指定rsync的lock文件存储位置。
log file：指定rsync的log文件存储位置。
port：指定rsync监听的端口。默认为873.
address：指定rsync监听的地址。address = 0.0.0.0表示监听在本机上的所有地址。
syslog facility：指定rsync将log发送到syslog时的log级别。


##模块选项如下(G/M表示也可以用于全局)
comment：指定模块的描述信息。（G/M）
path：指定模块所映射的目录路径
max connections：模块所允许的最大连接数。如果是0则表示没有限制，如果是负值则表示关闭该模块。（G/M）。如果用于全局，则表示所有模块的最大连接数。
log file：指定存放日志信息的文件名。（G/M）
lock file：指定lock文件的位置，确保不会达到最大连接数。默认为/var/run/rsyncd.lock。（G/M）
read only：是否允许客户端上传。yes表示不允许上传，no表示允许上传。默认为yes。如果设置为yes，则表示只能下载。
write only：是否允许客户端下载。yes表示不允许客户端下载，no允许客户端下载。默认为no。如果设置为yes，表示只能上传。
list：是否允许客户端列出该模块下的内容。yes允许，no不允许。
uid：username或user ID。指定该模块传输文件时（上传或下载），守护进程应该具有的UID权限，默认为nobody。当以root权限启动服务时，uid和gid则表示修改上传的文件的uid和gid。
gid：groupname或group ID。指定该模块传输文件时（上传或下载），守护进程应该具有的GID权限，默认为nobody。
exclude：指定多个文件或目录(相对路径)不被同步,并将其添加到 exclude 列表中.多个文件(目录)用空格分隔.作用等同于在客户端命令中使用--exclude来指定模式.
include：该选项针对于exclude,即同步exclude中的哪个文件(目录),并将其添加到include列表中，覆盖了exclude指定的文件或目录。多个文件(目录)用空格分隔.作用等同于在客户端命令中使用--include来指定模式.
exclude from：和exclude的作用一样，只不过是exclude是将排除的文件或目录作为value的，而exclude from则是将排除的文件和目录写在文件中的，一行一个文件或目录。
include from：和include的作用一样，将包括的文件写在文件中。

incoming chmod：修改服务器收到的文件的权限。如：incoming chmod = D2775,F664。（D表示目录，F表示文件）
outcoming chmod：修改服务器发送的文件的权限。
auth users与secrets file：这两个选项只能组合使用
auth users指定由空格或逗号分隔的用户名列表,只有这些用户才允许连接该模块,这里的用户和系统用户没有任何关系，用户名和口令以明文方式存放在 secrets file 参数指定的文件中，格式为username:password，常用的文件名为：/etc/rsyncd.secrets，password不能超过8个字符。
注意：secrets file文件的权限只能是启动rsyncd服务的用户具有rw权限，其他用户不能具有任何权限，即600.
示例：
auth users = joe:deny @guest:deny admin:rw @rsync:ro susan joe sam
说明：用户joe以及在guest组中的任何用户将不能访问指定的模块。admin用户将具有rw的权限（会忽略read only和write only的设置），rsync组中的用户将具有ro的权限，以及susan、joe和sam将会获取read only和write only的设置的权限。
timeout：通过该选项可以覆盖客户指定的IP超时时间。通过该选项可以确保rsync服务器不会永远等待一个崩溃的客户端。超时单位为秒，0表示没有超时定义，这也是默认值。对于匿名rsync服务器来说，一个理想的数字是600。
strict modes：指定是否检测口令文件的权限.若为 yes 则口令文件只能被 rsync 服务器运行身份的用户访问,其他任何用户不可以访问该文件，默认为yes。也就是该文件的权限为600或400。
hosts allow：用一个主机列表指定哪些主机客户允许连接该模块.不匹配主机列表的主机将被拒绝.也就是说如果指定hosts allow那么不在hosts allow指定中的主机都将都拒绝.
hosts deny：用一个主机列表指定哪些主机不能连接rsync模块.如果hosts allow和hosts deny同时指定一台主机,则以hosts allow为准.hosts allow和hosts deny的格式可以是x.x.x.x或x.x.x.x/n 或x.x.x.x/x.x.x.x或*的形式，也可以是主机名，要求能够被解析。
ignore errors ：可以忽略一些无关的IO错误
use chroot(G/M)：若为 true,则 rsync 在传输文件之前首先 chroot 到 path 参数所指定的目录下.这样做的原因是实现额外的安全防护,但是缺点是需要 root 权限,并且不能备份指向 path 外部的符号连接所指向的目录文件。
transfer logging：该选项开启则记录下载和上传操作。如果不配置该选项，则即使配置了log format时，也不会生效。
log format通过该选项用户在使用transfer logging可以自己定制日志文件的字段.
其格式是一个包含格式定义符的字符串,但要注意log format使用要在transfer logging选项开启的时候才可以.
常用的如下：
%o表示服务端提供什么操作,比如是接收send还是发送recv
%a表示客户端的IP地址.
%m表示服务端的模块名称
%P表示服务端模块指定的路径.
%t 当前时间
%u 认证的用户名(匿名时是null)
%b 实际传输的字节数
%f表示同步的文件.
%l表示同步文件的大小.
如：log format = [op]:%o [ip]:%a [module]:%m [path]:%P [file]:%f [size]:%l

## 配置示例
```bash
创建配置文件
[root@vm1 ~]# mkdir /etc/rsync
[root@vm1 ~]# touch /etc/rsync/rsyncd.conf
[root@vm1 ~]# 

配置文件的内容：
[root@vm1 ~]# cat /etc/rsync/rsyncd.conf
## rsyncd config file in daemon mode
pid file = /var/run/rsyncd.pid
lock file = /var/lock/subsys/rsyncd.lock
log file = /var/log/rsyncd.log
port = 873
address = 0.0.0.0
uid = root
gid = root
transfer logging = yes
log format = [time]:%t [op]:%o [ip]:%a [module]:%m [path]:%P [user]:%u [file]:%f [size]:%l
use chroot = no

[backup]
comment = Data Backup
path = /data/backup
hosts allow = 172.17.100.0/24
hosts deny = *
read only = no
write only = no
list = yes
auth users = felix
strict modes = yes
secrets file = /etc/rsync/rsyncd.pass
ignore errors
[root@vm1 ~]# 

创建secret file，并修改权限为600：
[root@vm1 ~]# cat /etc/rsync/rsyncd.pass 
felix:123456
[root@vm1 ~]# 
[root@vm1 ~]# ls -l /etc/rsync/rsyncd.pass
-rw-r--r-- 1 root root 43 Jun 12 14:41 /etc/rsync/rsyncd.pass
[root@vm1 ~]# chmod 600 /etc/rsync/rsyncd.pass
[root@vm1 ~]# 
```

## 启动服务和停止服务
```bash
启动服务
[root@vm1 ~]# rsync --daemon --config /etc/rsync/rsyncd.conf 
[root@vm1 ~]# ps aux | grep rsync
root      1588  0.0  0.2 107620   668 ?        Ss   14:44   0:00 rsync --daemon --config /etc/rsync/rsyncd.conf
root      1590  0.0  0.3 103244   856 pts/0    S+   14:44   0:00 grep rsync
[root@vm1 ~]# netstat -tunlp | grep rsync
tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN      1588/rsync          
[root@vm1 ~]# 


停止服务：kill $(cat /var/run/rsyncd.pid)
[root@vm1 backup]# ps aux | grep rsync
root      1263  0.0  0.2 107620   672 ?        Ss   15:10   0:00 rsync --daemon --config /etc/rsync/rsyncd.conf
root      1369  0.0  0.3 103244   856 pts/0    S+   15:21   0:00 grep rsync
[root@vm1 backup]# kill $(cat /var/run/rsyncd.pid)
[root@vm1 backup]# ps aux | grep rsync
root      1372  0.0  0.3 103244   856 pts/0    S+   15:21   0:00 grep rsync
[root@vm1 backup]# 

停止服务：pkill rsync

```

## 客户端配置
```bash
[root@vm2 tmp]# mkdir /etc/rsync
[root@vm2 tmp]# touch /etc/rsync/rsync.pass
[root@vm2 tmp]# vim /etc/rsync/rsync.pass
[root@vm2 tmp]# chmod 600 /etc/rsync/rsync.pass
[root@vm2 tmp]# cat /etc/rsync/rsync.pass
123456
[root@vm2 tmp]# 
```

## 列出服务器端的模块
```bash
[root@vm2 tmp]# rsync -avz root@172.17.100.1::
backup         	Data Backup
[root@vm2 tmp]# 
```

## pull和push
push（上传到服务器）
```bash
[root@vm2 tmp]# rsync -avz /etc/issue felix@172.17.100.1::backup 
Password: 
sending incremental file list
issue

sent 129 bytes  received 34 bytes  65.20 bytes/sec
total size is 47  speedup is 0.29
[root@vm2 tmp]#
```

pull（从服务器上下载）
```bash
[root@vm2 tmp]# rsync -avz --progress --password-file=/etc/rsync/rsync.pass felix@172.17.100.1::backup/issue /tmp/
receiving incremental file list
issue
             47 100%   45.90kB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 76 bytes  received 185 bytes  522.00 bytes/sec
total size is 47  speedup is 0.18
[root@vm2 tmp]# ls -l
total 4
-rw-r--r-- 1 root root 47 Nov 27  2013 issue
[root@vm2 tmp]# 
```

# rsync的启停脚本
```bash
#!/bin/bash
PID=/var/run/rsyncd.pid
LOCK=/var/lock/subsys/rsyncd.lock
CONF=/etc/rsync/rsyncd.conf
RSYNC=/usr/bin/rsync
prog=rsync
#chkconfig: 35 80 20

. /etc/init.d/functions

start() {
    netstat -tunlp | grep rsync > /dev/null
    RETVAL=$?
    if [ $RETVAL -eq 0 ];then
        echo "rsyncd is running......"
    else
        if [ -s $PID ];then
            kill -9 $(cat $PID) > /dev/null
            rm -rf $PID > /dev/null
        else
            echo -n $"Starting $prog:"
            daemon $RSYNC --daemon --config=$CONF
            RETAVL=$?
            echo
            [ $RETVAL -eq 0 ] && touch $LOCK
            return $RETVAL
        fi
    fi
}
stop() {
#   netstat -tunlp | grep rsync > /dev/null
    echo -n "Stop $prog:"
    killproc $prog
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && rm -rf $LOCK 
    return $RETVAL
}
case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status $prog
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: /etc/init.d/rsyncd start | restart | stop | status"
        ;;
esac
```

## 设置开机自动启动
```bash
[root@vm1 backup]# chmod +x /etc/init.d/rsyncd
[root@vm1 backup]# chkconfig --add rsyncd
[root@vm1 backup]# chkconfig rsyncd on
[root@vm1 backup]# chkconfig --list rsyncd
rsyncd         	0:off	1:off	2:on	3:on	4:on	5:on	6:off
[root@vm1 backup]# 
```