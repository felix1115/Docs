# 哨兵介绍
* 哨兵的作用
```
哨兵：监控redis实例的运行状态。包括如下两个功能：
1. 监控一个集群中的主服务器和从服务器是否正常运行。
2. 当主服务器出现故障时自动将从服务器转换为主服务器。不需要人工干预切换。

哨兵是一个独立的进程。

在一个一主多从的redis集群中，可以用多个哨兵进行监控任务以保证系统运行足够稳定。
哨兵不仅会同时监控主服务器和从服务器，同时哨兵之间也会互相监控。

一个哨兵可以监控多个集群。

强烈推荐使用sentinel 2(redis 2.8及其以上版本)，sentinel 1有很多bug。
```

* sentinel与masters之前的网络连接
```
1. 创建与被监视的master的网络连接后，sentinel成为该master的客户端，它会向master发送命令，并从master的响应中获取master的信息。
2. 对于每个被监视的master，sentinel会向其创建两个异步的网络连接。
    2.1 命令连接。这个连接专门用于向master发送命令，并接收命令返回。
    2.2 订阅连接。专门订阅master服务的__sentinel__:hello频道。

[root@vm03 ~]# netstat -tunlap | grep redis
tcp        0      0 0.0.0.0:26379               0.0.0.0:*                   LISTEN      2035/redis-sentinel
tcp        0      0 172.17.100.3:59446          172.17.100.1:6379           ESTABLISHED 2035/redis-sentinel
tcp        0      0 172.17.100.3:37711          172.17.100.1:6379           ESTABLISHED 2035/redis-sentinel
[root@vm03 ~]#
```

* 获取master信息
```
sentinel以每10s一次的频率向master发送INFO命令，通过INFO的回复来分析master的信息。
master的回复主要包含了两部分信息：一部分是master自身的信息，一部分是连接到master的所有slave的信息。
所以sentinel可以自动发送所有连接到master的slave服务器。
```

* 获取slave信息
```
1. 当sentinel发现master有新的slave服务器时，会创建到该slave服务器的命令连接和订阅连接。
2. 创建命令连接后，sentinel会以10s一次的频率向从服务器发送INFO命令，并从回复中提取如下信息：
    从服务器的ID
    从服务器的角色
    从服务器所属的主服务器的IP和端口
    从服务器的连接状态
    从服务器的优先级
    从服务器的复制偏移量等信息
```

* 向被监视的服务器发送询问命令
```
sentinel会以每2s一次的频率向所有被监视的服务器(master和slave)发送自己的信息，命令格式如下：
publish ___sentinel___:hello s_ip s_port s_runid s_epoch m_name m_ip m_port m_epoch

参数意义：
s_ip：sentinel的ip地址。
s_port：sentinel的端口。
s_runid：sentinel的run_id。
s_epoch：sentinel的配置版本。
m_name：主服务器的名字。
m_ip：主服务器的ip地址。
m_port：主服务器的端口。
m_epoch：主服务器的配置版本。
```

* 接收被监视服务器的频道信息
```
sentinel与被监视的服务器建立连接后，sentinel通过命令连接发送信息到频道，并且通过订阅连接从频道中接收信息。

对于同一个服务的多个sentinel，一个sentinel发送的信息，会被其他sentinel收到，当sentinel通过__sentinel__:hello频道发现新的sentinel时，会与新的sentinel建立命令连接(不会建立订阅连接).
```

* sdown和odown
```
1. sdown
sdown：subjective down，主观下线。
单个哨兵认为某个服务器已经下线(可能是接收不到订阅，或者是之间的网络不通等原因导致)。

sentinel会以每秒一次的频率向所有与其建立了命令连接的实例(master、slave和sentinel)发送PING命令，通过判断PING回复是有效回复还是无效回复来判断实例是否在线。

sentinel配置文件中的down-after-milliseconds设置了判断主观下线的时间。如果sentinel在该时间内没有收到有效回复，则sentinel认为该实例已经下线(主观认为),修改其flags状态为SRI_S_DOWN。

如果多个sentinel监视同一个服务，有可能存在多个sentinel的down-after-milliseconds配置不同，在生产环境中要注意。

2. odown
odown：objective down，客观下线。

当sentinel监视的某个服务器主观下线后，sentinel会询问其他监视该服务器的sentinel，看他们是否认为该服务器已经主观下线。
当该服务器为master时，接收到足够数量(quorum)的sentinel判断为主观下线后，即认为该服务器客观下线，并对其做故障转移操作。

sentinel通过发送SENTINEL is-master-down-by-addr ip port current_epoch runid, 
(ip表示认为主观下线的服务器的IP地址，port表示主观下线的服务器的端口，current_epoch表示sentinel的配置版本，runid如果是*则表示检测服务器下线状态，如果是sentinel的runid，则表示用来选举领头sentinel)来询问其他sentinel是否同意该服务器下线。

一个sentinel收到另一个sentinel发来的is-master-down-by-addr后，提取参数，根据ip和端口，判断该服务器是否主观下线，并且回复is-master-down-by-addr，回复包含3个参数：
    down_state：1表示已下线，0表示未下线。
    leader_runid：领头sentinel的runid
    leader_epoch：领头sentinel的配置版本。

sentinel收到回复后，根据所配置的quorum，达到这个值就认为该服务器客观下线。
```

* 选举领头sentinel
```
一个redis服务器被判断为客观下线时，多个监视该服务器的sentinel协商，选举一个领头sentinel，对该redis服务器进行故障转移操作。

故障恢复需要由领头sentinel来完成。

选举领头sentinel的规则：
1. 所有的sentinel都有公平被选举成为领头的资格。
2. 所有的sentinel都有且只有一次将某个sentinel选举成为领头的机会(在一轮选举中)，一旦选举某个sentinel成为领头，不能更改。
3. sentinel设置领头sentinel是先到先得，一旦当前sentinel设置了领头sentinel，以后要求设置sentinel为领头的请求都将被拒绝。
4. 每个发现master下线的sentinel，都要要求其他sentinel将自己设置成为领头。
5. 当一个sentinel(源sentinel)向另一个sentinel(目标sentinel)发送is-master-down-by-addr信息时，如果runid参数不是*，而是sentinel的runid，就表示源sentinel要求目标sentinel选举其成为领头。
6. 源sentinel会检查目标sentinel对其要求设置成为领头的回复，如果回复的is-master-down-by-addr消息的leader_runid和leader_epoch为源sentinel，表示目标sentinel同意将源sentinel设置成领头。
7. 如果某个sentinel被半数以上的sentinel设置成领头，那么该sentinel成为领头。
8. 如果在限定时间内，没有选举出领头sentinel，则暂停一段时间，在进行下一轮选举。
```

* 故障恢复
```
A. 从下线的主服务器的所有从服务器里面挑选一个从服务器，将其转为主服务器
领头哨兵按照如下的规则从slave服务器列表中选出新的主服务器：
1. 删除列表中处于下线状态的从服务器。
2. 删除最近5s没有回复过领头哨兵INFO信息的从服务器。
3. 删除与已下线的主服务器断开连接超过down-after-milliseconds * 10毫秒的从服务器，这样就能保证从的数据比较新。
4. 领头sentinel从剩下的从服务器列表中选择优先级高的，如果优先级一样，选择偏移量最大的(偏移量大说明复制的数据比较新)，如果偏移量一样，选择runid最小的从服务器。

B. 已下线的主服务器的所有从服务器改为复制新的主服务器
挑选出新的主服务器后，领头sentinel向原主服务器的从服务器发送SLAVEOF 新的主服务器 的命令，让从服务器复制新的主服务器。

C. 将已下线的主服务器设置成新的主服务器的从服务器，当其恢复正常时，复制新的主服务器，变成新的主服务器的从服务器
当已经下线的主服务器重新上线时，sentinel会向其发送SLAVEOF命令，让其成为新的主服务器的从服务器。

```

* 总结
```
sentinel和master建立完命令连接和订阅连接后，会定期执行下面3个步骤：
1. 每10s一次向maste和slave发送INFO消息(通过命令连接)
2. 每2s一次向master和slave通过命令连接发送sentinel本身的信息到__sentinel__:hello频道，并通过订阅连接从该频道接收信息。
3. 每1s一次向master、slave和其他sentinel发送PING命令，判断是否已经下线。

sentinel会与所有的master和slave建立命令连接和订阅连接。
sentinel与sentinel之间只会建立命令连接，用于发送PING。


选举领头哨兵：
1. 首先发现master客观下线的sentinel会要求其他sentinel选举自己成为领头sentinel。
2. 如果其他的sentinel没有选过其他sentinel为领头哨兵，则选择发送请求的sentinel为领头sentinel。
3. 如果已经选举了其他sentinel为领头sentinel，则拒绝其成为领头哨兵。
4. 如果有超过半数的哨兵都认为自己是领头哨兵，则该哨兵将成为领头哨兵。
5. 如果在一个时间段内，没有选举出领头哨兵，则暂停一段时间，再进行下一轮选举。


故障恢复主服务器的选举：
1. 从所有在线的从服务器中选择一个优先级较高的服务器成为主服务器。
2. 如果优先级相同，则选择偏移量较大的成为主服务器。
3. 如果偏移量相同，则选择runid最小的成为主服务器。

当选举成为主服务器的从服务器以后，sentinel发送SLAVEOF NO ONE命令将从服务器转为主服务器。
同时会向其他的从服务器发送SLAVEOF命令将其它从服务器转换为新选定的主服务器的从服务器。
当已下线的主服务器上线后，sentinel会向其发送SLAVEOF命令将其转换为新的主服务器的从服务器。
```

* 哨兵的注意事项
```
1. 设置quorum为N/2+1(N为哨兵的数量)
2. 一个集群中的哨兵的数量最好为奇数个。方便选举出领头哨兵。
```

# 配置

![redis哨兵配置示例](https://github.com/felix1115/Docs/blob/master/Images/redis-1.png)

* 查看主从服务器的复制状态
```
1. master的复制状态
127.0.0.1:6379> INFO replication
# Replication
role:master
connected_slaves:3
slave0:ip=172.17.100.1,port=6379,state=online,offset=1639,lag=1
slave1:ip=172.17.100.2,port=6379,state=online,offset=1639,lag=0
slave2:ip=172.17.100.4,port=6379,state=online,offset=1639,lag=0
master_repl_offset:1639
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:1638
127.0.0.1:6379>

显示有3个SLAVE，分别是172.17.100.1、172.17.100.2和172.17.100.3

2. 查看slave01：172.17.100.1的复制状态
127.0.0.1:6379> INFO replication
# Replication
role:slave
master_host:redis-master01.felix.com
master_port:6379
master_link_status:up
master_last_io_seconds_ago:7
master_sync_in_progress:0
slave_repl_offset:1765
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
127.0.0.1:6379>

这里的mater指向了redis-master01.felix.com，解析后的地址就是172.17.100.3

slave02和slave03的信息和slave01差不多。

```

* 建立一个配置文件sentinel.conf
```
# sentinel monitor <master-name> <ip> <redis-port> <quorum>
bind 0.0.0.0
port 26379
sentinel monitor mymaster 172.17.100.3 6379 2
# sentinel auth-pass <master-name> <password>
说明：
bind：指定哨兵监听的地址。默认是监听在127.0.0.1上面的
port：指定哨兵监听的端口。默认是26379
sentinel monitor：指定哨兵监控的Master redis服务器的信息。
    mymaster表示要监听的主服务器的名称。自己定义，由大小写字母、数字和"._-"组成。
    172.17.100.3：表示主redis服务器的地址。
    6379：表示主redis服务器的端口。
    2：表示最低通过票数。quorum表示执行故障恢复步骤前至少需要几个哨兵节点同意。

    不需要指定slave redis的信息，哨兵会自动发现所有复制该主redis服务器的所有slave 服务器。

如果master redis服务器和slave redis服务器启用了认证，则哨兵需要做如下配置：
# sentinel auth-pass <master-name> <password>
注意：master和slave需要配置相同的密码，不能使用不同的密码。

# sentinel down-after-milliseconds <master-name> <milliseconds>
认为master或者其他的slave和sentinel处于S_DOWN状态的时间。单位是毫秒。


```

* 启动哨兵
```
[root@vm03 redis]# redis-sentinel /etc/redis/sentinel.conf
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 3.2.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in sentinel mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 26379
 |    `-._   `._    /     _.-'    |     PID: 2020
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

2020:X 27 Dec 16:00:41.507 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
2020:X 27 Dec 16:00:41.508 # Sentinel ID is 0481ec8e01ad1f20634b813c4288c40657c9ffae
2020:X 27 Dec 16:00:41.508 # +monitor master mymaster 172.17.100.3 6379 quorum 2
2020:X 27 Dec 16:00:41.509 * +slave slave 172.17.100.1:6379 172.17.100.1 6379 @ mymaster 172.17.100.3 6379
2020:X 27 Dec 16:00:41.510 * +slave slave 172.17.100.2:6379 172.17.100.2 6379 @ mymaster 172.17.100.3 6379

说明：
1. +monitor表示监控的主redis服务器、端口以及quorum
2. +slave表示新发现了从服务器。
```


* 
