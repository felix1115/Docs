# netfilter和iptables
```
Netfilter是Linux操作系统内核中的一个数据包处理模块，具有如下功能：
* 网络地址转换（NAT）
* 数据包内容修改
* 数据包过滤

Netfilter工作在内核工作，设置了5个钩子函数，分别是：PREROUTING、INPUT、OUTPUT、FORWARD、POSTROUTING，当数据包到达这些位置时将会对数据包进行处理。

iptables是一个工作在用户空间的工具，用于设置一些规则，并将所设置的规则发送到Netfilter的内核空间中。
```

# 表和链
```
1.raw表
作用：用于决定数据包是否被状态跟踪机制处理。
iptables包括一个模块，允许管理员使用连接跟踪（connection tracking）方法来检查和限制到内部网络中可用服务的连接。连接跟踪把所有的连接都保存在一个表格内，可以让管理根据一下状态来允许或拒绝连接：
    NEW：开始一个新的连接（重新连接或将连接重定向）
    ESTABLISHED：属于当前连接的一部分的分组。
    RELATED：该包和某个已经建立的连接相关联的新连接。
    INVALID：数据包不能被识别属于哪个连接或没有任何状态，不在连接跟踪表内的任何分组，一般都需要DROP掉。

使用的模块是iptable_raw

2个链：
    OUTPUT链：本机产生的数据包
    PREROUTING链：在数据包刚刚到达防火墙时对其进行处理。

说明：因为raw表的优先级最高，因此可以对收到的数据包在连接跟踪前进行处理。一但使用了RAW表,在某个链上,RAW表处理完后,将跳过NAT表和 ip_conntrack(nf_conntract)处理,即不再做地址转换和数据包的链接跟踪处理了.

2.mangle表
作用：主要用于修改数据包的TOS、TTL以及为数据包设置Mark标记，用来实现QoS和策略路由等应用。对应的内核模块是iptable_mangle

5个链：
    INPUT：处理进入本机的数据包
    RORWARD链：处理经过本机转发的数据包。
    OUTPUT链：处理本机生成的数据包。
    POSTROUTING链：修改即将出去的数据包。
    PREROUTING链：修改即将到来的数据包。

3.nat表
作用：主要用于修改数据包的IP地址、端口号等信息，用于实现网络地址转换NAT工作。
说明：属于一个流的数据包只会经过这个表一次。同一个数据流是指：如果一个数据包的大小超过了MTU的限制，则这个数据包会被拆分成多个数据包，并且在每一个数据包的头部信息中具有相同的ID号，标识属于同一个数据流。如果第一个包被允许做NAT或者MASQUERADE,则余下的包则会自动的做相同的动作，余下的包不会经过这个表。NAT表对应的内核模块是iptable_nat.

3个链：
    PREROUTING链：在数据包刚刚到达防火墙时修改它的目的地址。DNAT
    OUTPUT链：修改本机产生的数据包的目的地址。DNAT
    POSTROUTING链：在数据包离开防火墙之前改变其源地址。SNAT

4.filter表
作用：主要用于对数据包进行过滤，根据所设置的规则，可以决定如何对数据包进行处理。如DROP/REJECT/ACCEPT/REDIRECT/LOG等。filter表所使用的内核模块是iptable_filter

3个链：
    INPUT链：对那些目的地址是本机的数据包进行处理。
    FORWARD链：对那些不是本机产生的数据包且目的地也不是本机的数据包(经过本机转发的数据包)进行处理。
    OUTPUT链：对本机产生的数据包进行处理。


表之间的优先级：raw---mangle---nat---filter

数据包在各个表和链之间的处理流程：
数据包进入--->PREROUTING--->[ROUTE]--->FORWARD--->POSTROUTING--->数据包流出
               raw           |          mangle      ^
               mangle        |          filter      |  mangle
               nat           |                      |  nat
                             |                      |
                             |                      |
                             v                      |
                           INPUT                  OUTPUT
                             | mangle               ^  raw
                             | filter               |  mangle
                             |                      |  nat
                             v -----> local ----->  |  filter

```

# iptables动作
```
常用的动作如下：
ACCEPT：允许符合条件的数据包通过。
REJECT：拒绝符合条件的数据包通过，并且会向发送者返回拒绝原因。
DROP：拒绝符合条件的数据包通过，不会向发送者发送拒绝原因，直接丢弃。
LOG：日志功能，将符合条件的数据包记录在文件中，用于分析和查看。
SNAT：用于源地址转换。
DNAT：用于目标地址转换。
MASQUERADE：用于源地址转换，用于公网IP地址不固定的情况，如拨号上网。
REDIRECT：重定向，将数据包重定向到指定的地址或端口。
RETURN：使数据包返回指定的链。
MARK：设置Mark的值，用于防火墙标记。
```

# iptables语法
## iptables编写规则
```
-------------------------------------------------------------------------------
iptables  |   table 　｜  command  |    chain    |   Parameter 　|  target    |
-------------------------------------------------------------------------------
iptables  | -t filter | -A         |  INPUT      | -p tcp        |-j ACCEPT   |
          |    nat    | -D         |  OUTPUT     | -s            |   DROP     |
          |    raw    | -L         |  FORWARD    | -d            |   REJECT   |
          |    mangle | -F         |  PREROUTING | --sport       |   SNAT     |
          |           | -P         |  POSTROUTING| --dport       |   DNAT     |
          |           | -I         |             | --dports      |   MASQUERADE
          |           | -R         |             | -m tcp        |   LOG      |
          |           | -n         |             |    state      |            |
          |           |            |             |    multiport  |            |
-------------------------------------------------------------------------------

```
## COMMAND
```
-t table：指定要操作的表名。默认为filter表。
-A：添加一条规则。
-D：删除一条规则。
-I：插入一条规则。
-R：替换某条规则。
-N：创建用户自定义的链。
-X：删除用户自定义的链。如果没有指定链名，则删除所有用户自定义的链。
-E：重命名一个链。
-S：查看指定链的规则。如果没有跟上链名，则查看指定表的所有链的规则。
-P：设置默认策略。
-L：查看指定的表和链的规则。
-n：数字化输出。常和-L选项一起用。
--line：显示行号。
-v：显示详细信息。
-n：不进行
-F：删除指定表中的所有规则。
-Z：清空指定表的所有链的流量统计。
```

## PARAMETERS
```
1. 用于添加、删除、插入、替换
[!] -p：指定要检测的协议。可以是协议名，也可以是协议号，如tcp、udp、icmp或者是all等，也可以是6,17,1,0。需要位于/etc/protocols中。协议号为0，表示所有协议。!表示出了指定的取反。
[!] -s address[/mask][,...]：指定源IP地址或源网段，可以指定多个。
[!] -d address[/mask][,...]：指定目标IP地址或目标网段，可以指定多个。
[!] -i：指定数据包进来的接口。可以用在INPUT、FORWARD、PREROUTING链中。如果接口名以+结尾，则表示以该接口名开始的任何接口都匹配。如eth+，则匹配eth0，eth1等。
[!] -o：从指定的接口出去的数据包。可以用在OUTPUT、FORWARD、POSTROUTING链中。如果接口名以+结尾，则表示以该接口名开始的任何接口都匹配。如eth+，则匹配eth0，eth1等。
-j：使用指定的target对符合条件的数据包进行处理。

2. MATCH EXTENSION(需要使用-m选项)
comment：允许为规则添加注释信息，最多256个字符。
    --comment：指定注释内容。
    如：iptables -A INPUT -i eth0 -p tcp -s 172.17.100.0/24 -d 172.17.100.1 --dport 22 -m comment --comment "permit localnet hosts to port 22" -j ACCEPT

connlimit：限制一个客户端IP地址或客户端地址块允许到达服务器的并行连接数。
    [!] --connlimit-above n：判断已经存在的客户端的连接数是否已经达到上线n。
    --connlimit-mask prefix_length：客户端地址块的掩码长度。如果没有指定则默认为32.
    示例：限制172.17.100.254的SSH连接数最多为3个。当超过3个时，就拒绝连接。
    iptables -A INPUT -s 172.17.100.254/32 -d 172.17.100.10/32 -i eth0 -p tcp -m tcp --dport 22 -m connlimit ! --connlimit-above 3 --connlimit-mask 32 -j ACCEPT 
    或者是：
    iptables -A INPUT -s 172.17.100.254/32 -d 172.17.100.10/32 -i eth0 -p tcp -m tcp --dport 22 -m connlimit --connlimit-above 3 --connlimit-mask 32 -j REJECT

    示例2：限制一个地址块的HTTP 请求数为16.
    iptables -p tcp --syn --dport 80 -m connlimit --connlimit-above 16 --connlimit-mask 24 -j REJECT

iprange：匹配IP地址范围，用于配置多个IP地址。
    [!] --src-range from[-to]：匹配源IP地址范围。
    [!] --dst-range from[-to]：匹配目标IP地址范围。
    示例：
    iptables -A INPUT -p tcp -m iprange --dst-range 192.168.20.41-192.168.20.48 --dport 8000:10000 -j ACCEPT
    
limit：使用令牌桶对连接速率进行限制。
    --limit rate[/second|/minute|/hour|/day]: 指定时间内最大平均匹配速率。默认值是3/hour，也就是说每隔多长时间会产生一个令牌。
    --limit-burst number：最大初始匹配数据包数。默认是5.指定初始的令牌个数。

    注意：设置limit时要注意-m state的RELATED状态。如果设置了RELATED，则可能不会生效，需要设置raw表。
    如：iptabes -t raw -A PREROUTING -p icmp -j NOTRACK

mac：对MAC地址进行匹配。
    --mac-source：匹配源MAC地址。格式是：XX:XX:XX:XX:XX:XX,只能对进来的数据包作匹配，也只能用在PREROUTING/FORWARD/INPUT链中。
    示例：将IP和MAC绑定
    iptables -A INPUT -s 172.17.100.101/32 ! -p icmp -m mac --mac-source 00:0C:29:5C:71:14 -j DROP 

multiport：只能用于-p tcp和-p udp中，用于指定多个不连续的端口，最多15个。多个连续的端口使用port:port方式。
    --sports port[,port|,port:port]...：指定多个源端口。
    --dports port[,port|,port:port]...：指定多个目标端口。
    --ports port[,port|,port:port]...：匹配源端口或者目标端口在这个范围内的端口。

owner：针对本地产生的数据包的进程的owner和group进行限制，只能用于OUTPUT链和POSTROUTING链。
    --uid-owner username|uid | uid-uid：指定进程的UID或用户名。
    --gid-owner groupname|gid | gid-gid：指定进程的GID或组名。

state：根据连接跟踪状态进行匹配。
    --state：指定一个或多个state，state之间用逗号隔开。
    NEW：开始一个新的连接（重新连接或将连接重定向）
    ESTABLISHED：属于当前连接的一部分的分组。
    RELATED：该包和某个已经建立的连接相关联的新连接。
    INVALID：数据包不能被识别属于哪个连接或没有任何状态，不在连接跟踪表内的任何分组，一般都需要DROP掉。

string：对数据包的内容进行匹配。
    --algo：指定所使用的算法。
    --string pattern：使用pattern对要匹配的内容进行过滤。

    示例：限制用户都一些网站的访问
    iptables -A FORWARD -m string --algo bm --string "youtube.com" -j DROP


tcp：对tcp协议进行控制。可以不用直接使用-m tcp，只要指定了-p tcp即可。
    --sport port[:port]：指定源端口，或者是源端口范围。
    --dport port[:port]：指定目标端口，或者是目标端口范围。
    --tcp-flags mask comp：mask表示需要检查的标记，comp表示的是在mask中出现过且必须被设置的标记。多个标记使用逗号分隔。标记有：URG/ACK/PSH/RST/SYN/FIN/ALL/NONE
    --syn：只匹配TCP包中syn位被设置，而ACK/RST/FIN位没有设置的数据包。

udp：对udp协议进行控制。可以不用直接使用-m udp，只要指定了-p udp即可。
    --sport port[:port]：指定源端口，或者是源端口范围。
    --dport port[:port]：指定目标端口，或者是目标端口范围。

time：根据时间对数据包进行控制。所有的选项都是可选的，如果加上的话，则选项之间的关系是AND关系。
    --datestart YYYY[-MM[-DD[Thh[:mm[:ss]]]]]：指定起始时间。采用的是ISO 8601格式，T不可少。如果没有指定起始时间，则默认为1970-01-01T00:00:00
    --datestop YYYY[-MM[-DD[Thh[:mm[:ss]]]]]：指定结束时间。采用的是ISO 8601格式，T不可少。如果没有指定结束时间，则默认为2038-01-19T04:17:07
    --timestart hh:mm[:ss]:指定起始时间。范围为00:00:00 to 23:59:59
    --timestop hh:mm[:ss]：指定结束时间。范围为00:00:00 to 23:59:59
    --monthdays day[,day...]：指定一个月当中的某一天或某几天。范围是1-31。
    --weekdays day[,day...]：指定星期。Mon, Tue, Wed, Thu, Fri, Sat, Sun, 或者是数字1到7.

    说明：实测iptables 1.4.7版本的--datestart和--datestop设置后不能用，ubuntu下的iptables 1.4.21没问题，需要用UTC时间，可以用date -u查看。

    示例：
    root@u01:~# iptables -A INPUT -i eth0 -p tcp -s 172.17.100.10 -d 172.17.100.101 --dport 22 -m time --datestart 2016-08-26T11:21 --datestop 2016-08-26T11:24  -j DROP 
```

## target
```
SNAT：用于NAT表的POSTROUTING链。
    --to-source ipaddr[-ipaddr][:port[-port]]：指定要转换的地址或地址范围或端口范围。

DNAT：只能用于NAT表的PREROUTING和OUTPUT链中。
    --to-destination [ipaddr][:port]：指定要转换的IP地址和端口。

REDIRECT：用于nat表的PREROUTING和OUTPUT链。
    --to-ports：重定向到指定的端口。

LOG：记录log。
    --log-level：指定要记录的log等级。
    --log-prefix prefix：指定log前缀。
    --log-ip-options：记录IP信息。

MASQUERADE：用于地址转换，用于nat表的POSTROUTING链。用于公网IP地址不固定的情况。
    --to-ports port[-port]：指定要使用的源端口或范围。

NOTRACK：用于raw表。对于所有匹配的数据包不进行连接跟踪。

REJECT：用于INPUT、OUTPUT、FORWARD链，对匹配的数据包执行REJECT。
    --reject-with：指定拒绝原因。

DROP：直接DROP掉匹配的数据包。

```


# iptables版本升级
```
1. 查看当前iptables版本
[root@vm10 ~]# iptables -V
iptables v1.4.7
[root@vm10 ~]# 

2. 源码安装iptables1.4.21
[root@vm10 ~]# yum install -y gcc gcc-c++ glibc-devel kernel-headers bison bison-devel flex
[root@vm10 ~]# tar -jxf iptables-1.4.21.tar.bz2 
[root@vm10 ~]# cd iptables-1.4.21
[root@vm10 iptables-1.4.21]# ./configure --prefix=/usr/local/source/iptables1.4.21
[root@vm10 iptables-1.4.21]# make 
[root@vm10 iptables-1.4.21]# make install

3. 备份源文件
[root@vm10 sbin]# mv /sbin/iptables{,.bak}
[root@vm10 sbin]# ln -s /usr/local/source/iptables1.4.21/sbin/iptables /sbin/iptables
[root@vm10 sbin]# mv /sbin/iptables-save{,.bak}
[root@vm10 sbin]# ln -s /usr/local/source/iptables1.4.21/sbin/iptables-save /sbin/iptables-save
[root@vm10 sbin]# mv /sbin/iptables-restore{,.bak}
[root@vm10 sbin]# ln -s /usr/local/source/iptables1.4.21/sbin/iptables-restore /sbin/iptables-restore
[root@vm10 sbin]# 

查看版本：
[root@vm10 ~]# iptables -V
iptables v1.4.21
[root@vm10 ~]# 


4. 创建man文件
[root@vm10 man8]# cd /usr/share/man/man8
[root@vm10 man8]#
[root@vm10 man8]# mv iptables-1.4.7.8.gz iptables-1.4.7.8.gz.bak
[root@vm10 man8]# mv iptables-restore-1.4.7.8.gz iptables-restore-1.4.7.8.gz.bak
[root@vm10 man8]# mv iptables-save-1.4.7.8.gz iptables-save-1.4.7.8.gz.bak
[root@vm10 man8]#

[root@vm10 man8]# cat /etc/man.config | grep 'iptables'
MANPATH /usr/local/source/iptables1.4.21/share/man
[root@vm10 man8]# 
```

# iptables的备份和恢复
## 备份
```
iptables-save用于备份iptables。
选项：
-t：指定要备份的表。如果没有指定，则为所有可用的表。
-c：输出中包含流量统计信息。

备份示例：
[root@vm10 ~]# iptables-save > iptable_backup.txt

```

## 恢复
```
恢复iptables规则使用的是iptables-restore命令。
选项：
-c：恢复流量统计信息。
-n：不刷新以前的iptables内容。默认是刷新（也就是删除）所有的iptables里面的内容。

恢复示例：
[root@vm10 ~]# iptables-restore < iptable_backup.txt 
[root@vm10 ~]# 

```


# 配置示例
```
设置默认策略
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

设置state
iptables -A INPUT -m state --state INVALID DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

设置ICMP和SSH
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i eth0 -p tcp -s 172.17.100.0/24 -d 172.17.100.1 --dport 22 -j ACCEPT 

设置NAT
DNAT：iptables -t nat -A PREROUTING -p tcp -d 172.17.100.10 --dport 80 -j DNAT --to-destination 172.17.200.100:80
SNAT: iptables -t nat -A POSTROUTING -p tcp -s 172.17.100.0/24 -j SNAT  --to-source 172.17.100.10

```