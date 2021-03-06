# Redis复制
* 复制介绍
```
复制功能：当一台服务器上的数据更新后，自动的将更新的数据同步到其他服务器上。

在复制的概念中，数据库分为两种：主服务器(Master)和从服务器(Slave)。
主服务器：可以进行读写操作。当写操作导致数据变化时，会自动将数据同步给从服务器。
从服务器：一般是只读的，并接受主服务器同步过来的数据。

一个主服务器可以拥有多个从服务器，而一个从服务器只能有一个主服务器。
```

* 配置
```
1. 在从服务器的配置文件中指定主服务器的地址和端口。
slaveof 172.17.100.3 6379

2. 如果主服务器启用认证的话(主服务器配置了requirepass)，则从服务器需要配置masterauth
masterauth <master-password>
```

* 测试
```
1. 查看当前服务器的角色。ROLE
1.1 在主服务器上查看
127.0.0.1:6379> ROLE
1) "master"
2) (integer) 85
3) 1) 1) "172.17.100.4"
      2) "6379"
      3) "71"
127.0.0.1:6379>
说明：
master表示当前是主服务器。
第三行表示的是从服务器的地址、端口等信息。

1.2 在从服务器上查看
127.0.0.1:6379> ROLE
1) "slave"
2) "172.17.100.3"
3) (integer) 6379
4) "connected"
5) (integer) 435
127.0.0.1:6379>

说明：slave表示是从服务器。下面的是主服务器的地址和端口以及是否已经连接。

2. 查看replication段的信息。INFO replication
2.1 主服务器端查看
127.0.0.1:6379> INFO replication
# Replication
role:master
connected_slaves:1
slave0:ip=172.17.100.4,port=6379,state=online,offset=533,lag=0
master_repl_offset:533
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:532
127.0.0.1:6379>

2.2 从服务器端查看
127.0.0.1:6379> INFO replication
# Replication
role:slave
master_host:172.17.100.3
master_port:6379
master_link_status:up
master_last_io_seconds_ago:9
master_sync_in_progress:0
slave_repl_offset:589
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
127.0.0.1:6379>

3. 增加数据测试
3.1 主服务器增加数据
127.0.0.1:6379> keys *
(empty list or set)
127.0.0.1:6379> SET username 'felix.zhang'
OK
127.0.0.1:6379>

3.2 从服务器查看数据
127.0.0.1:6379> KEYS *
1) "username"
127.0.0.1:6379> get username
"felix.zhang"
127.0.0.1:6379>

3.3 从服务器增加数据
127.0.0.1:6379> set password 'slave.test'
(error) READONLY You can't write against a read only slave.
127.0.0.1:6379>
从服务器端无法写入数据，是只读实例。
```

* 其他内容
```
默认情况下，slave-read-only为yes，表示从服务器为只读的。可以将其设置为no，使从服务器为可写。
但是对从服务器的任何更改都不会同步给任何其他服务器，并且一旦主服务器中更新了对应的数据就会覆盖从服务器中的改动，所以通常的场景下不应该设置从服务器可写。

从服务器可以用SLAVEOF NO ONE命令来使当前服务器停止接收其他服务器的同步并转换为主服务器。

```

* 主从互换的方法
```
1. 作为从服务器的方法
方法1：启动服务时指定 # redis-server --port 6379 --slaveof 172.17.100.3 6379
方法2：配置文件中指定 slaveof 172.17.100.3 6379
方法3：运行时指定 127.0.0.1:6379> SLAVEOF 172.17.100.3 6379

对于方法3，如果该服务器已经是其他主服务器的从服务器了，则该命令会停止和原来的服务器的同步转而和新的服务器同步。

SLAVEOF后面指定的是主服务器的地址。

2. 作为主服务器
运行时指定 127.0.0.1:6379> SLAVEOF NO ONE
```


# Redis复制的原理
* 复制初始化
```
复制初始化：
1. 从服务器启动后，会向主服务器发送SYNC命令(Redis 2.8以后发送PSYNC代替SYNC，以实现增量复制)。
2. 主服务器收到SYNC命令后，会开始在后台保存快照(RDB持久化过程)，并将保存快照期间接收到的命令缓存起来。
3. 当快照完成后，redis主服务器会将所有的缓存命令和快照文件发送给从服务器。
4. 从服务器收到后，会载入快照文件并执行收到的缓存的命令。

说明：
在从服务器同步数据的过程中，并不会阻塞，从服务器依然可以处理客户端发来的命令。
默认情况下，从服务器会用同步前的数据对命令进行相应。
可以配置slave-serve-stale-data参数为no来使从服务器在同步完成前对所有命令(除了INFO和SLAVEOF)都回复错误："SYNC with master in progress"

复制初始化结束后，主服务器每当收到写命令时就会将命令以异步的方式发送给从服务器，从而保证主从服务器数据一致。
```

* 断开重连
```
当主从服务器之间的连接断开重连后：
1. Redis 2.6以及之前的版本会重新进行复制初始化过程(即主服务器重新保存快照并将快照传给从服务器)。
可能从服务器仅仅只有几条命令没有收到。
主服务器也必须要将数据库里面的所有数据重新传给从服务器。
这就使得从服务器断开重连后数据恢复效率很低。

2. 在Redis 2.8版本的一个重要改进就是断开重连能够支持有条件的增量数据传输(增量复制)。
当从服务器重新连接上主服务器后，主服务器只需要将短线期间执行的命令传送给从服务器，从而提高redis复制的实用性。
```


* 乐观复制
```
乐观复制：optimistic replication，容忍在一定时间内主从服务器的数据是不同的，但是数据会最终同步。
```

>redis主从服务器之间复制数据采用异步方式，意味着，主服务器执行完客户端端请求的命令会立即将命令在主服务器的执行结果返回给客户端，并异步的将命令同步给从服务器，而不会等待从服务器接收到该命令后在返回给客户端。这一特性保证了在启用复制后，不会影响主服务器的性能。但是，另一方面也会产生一个主从数据库数据不一致的时间窗口，当主服务器执行了一条写命令后，主数据库的数据已经发生了变动，然而在主服务器将该命令传送给从服务器之前，如果两个服务器之间的网络连接断开了，主从服务器之间的数据是不一样的。从这个角度来看，主服务器是无法得知某个命令最终同步给了多少个从服务器的，不过redis提供了两个配置选项来限制只有当数据至少同步给指定数量的从服务器时，主数据库才是可写的：
>
>min-slaves-to-write 3
>min-slaves-max-lag 10
>
>说明：
>min-slaves-to-write：表示只有当3个或3个以上的从服务器连接到主服务器时，主数据库才是可写的，否则会返回错误，如：(error) NOREPLICAS Not enough good slaves to write
>
>min-slaves-max-lag：表示允许从数据库最长失去连接的时间。如果从服务器最后与主服务器联系(发送REPLCONF ACK命令)的时间(INFO replication中的lag值)小于这个值，则认为从服务器还与主服务器保持连接。
>


* 增量复制
```
1. 从服务器会存储主服务器的run_id(可以用INFO server查看)，每一个redis实例都会有一个唯一的run id，实例重启后，会自动生成一个新的run id。
2. 在复制同步阶段，主服务器每将一个命令传送给从服务器时，都会同时把该命令存放到一个积压队列(backlog)中，并记录下当前积压队列中存放的命令的偏移量范围。
3. 同时，从服务器接收到主服务器传来的命令时，也会记录下该命令的偏移量。

repl-backlog-size：指定backlog的大小，默认是1MB。积压队列越大，允许从服务器断线的时间就越长。
repl-backlog-ttl：当所有的从服务器与主服务器断开连接后，经过多久时间主服务器可以释放积压队列的内存空间。默认是1小时。0表示永远不释放。
```

