# Redis介绍
```
Redis称为：REmote DIctionary Server，远程字典服务器。
Redis以字典的方式存储数据，并且也允许其他应用通过TCP协议读写字典数据。

redis将数据存储在内存中，同时也支持将数据采用异步的方式存储在磁盘上(持久性存储)。
一个redis实例默认支持16个数据库，编号从0到15，默认选择的是0号数据库。

Redis支持如下几种数据类型：
1. 字符串。string
2. 哈希。hash
3. 列表。list
4. 集合。set
5. 有序集合。zset
```

# Redis安装
* redis安装 
```
版本：3.2.6

[root@vm03 ~]# tar -zxf redis-3.2.6.tar.gz
[root@vm03 ~]# cd redis-3.2.6
[root@vm03 redis-3.2.6]# make
[root@vm03 redis-3.2.6]# make install
```

* 命令说明
```
redis-server：redis服务器端程序，用于启动redis。
redis-cli：redis客户端程序。用于连接redis服务器。
redis-benchmark：redis性能测试工具。
redis-check-aof：AOF文件检查工具。
redis-check-rdb：RDB文件检查工具。
redis-sentinel：redis哨兵。
```

* 为redis提供配置文件
```
[root@vm03 redis-3.2.6]# pwd
/root/redis-3.2.6
[root@vm03 redis-3.2.6]# mkdir /etc/redis
[root@vm03 redis-3.2.6]# cp -a redis.conf sentinel.conf /etc/redis/
[root@vm03 redis-3.2.6]#
```

* 配置文件需要修改的部分
```
1. daemonize yes：是否以后台服务的方式运行。
2. pidfile /var/run/redis_6379.pid：PID文件的位置。
3. port 6379：监听端口
4. bind 127.0.0.1：监听的地址 
```

# redis启动脚本
* 复制utils/redis_init_script到/etc/init.d/redis
```
[root@vm03 redis-3.2.6]# pwd
/root/redis-3.2.6
[root@vm03 redis-3.2.6]# scp utils/redis_init_script /etc/init.d/redis
[root@vm03 redis-3.2.6]#

修改/etc/init.d/redis，增加如下内容，使其可以开机自动启动：
# chkconfig: 2345 84 16

[root@vm03 redis-3.2.6]# chkconfig --add redis
[root@vm03 redis-3.2.6]# chkconfig --level 35 redis on
[root@vm03 redis-3.2.6]#
```

* 启动脚本内容
```
注意：
1. 这里在原有脚本的基础上增加了status功能。
2. 增加了密码功能。防止服务器端配置了密码验证

#!/bin/sh
#
# chkconfig: 2345 84 16
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISPORT=6379
EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/redis.conf"
PROG=redis-server
PASSWORD=$(grep '^[[:blank:]]*requirepass' $CONF | awk '{print $2}')

. /etc/rc.d/init.d/functions

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
                if [ -z "$PASSWORD" ]; then
                    $CLIEXEC -p $REDISPORT shutdown
                else
                    $CLIEXEC -p $REDISPORT -a $PASSWORD shutdown
                fi

                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
    status)
        status $PROG
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac
```

# redis启用认证
```
在配置文件中配置如下信息：
protected-mode yes
requirepass felix
```

* 测试
```
[root@vm03 redis]# redis-cli -h 172.17.100.3 -p 6379
172.17.100.3:6379> ping
(error) NOAUTH Authentication required.
172.17.100.3:6379> AUTH felix
OK
172.17.100.3:6379> ping
PONG
172.17.100.3:6379>
```

# redis-cli的使用
```
-h：指定连接的主机。默认是127.0.0.1
-p：指定端口。默认是6379
-a：指定密码。
-n：指定database号。
-r：重复命令多少次。
-i：每个命令之间的间隔。单位是秒。
```

* 示例
```
[root@vm03 redis]# redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379>

[root@vm03 redis]# redis-cli -h 172.17.100.3 -p 6379
172.17.100.3:6379> ping
PONG
172.17.100.3:6379>
```