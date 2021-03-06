# LVS介绍
* 提高服务器响应能力的方法
```
1. scale on。纵向扩展。
    是在原有服务器的基础上进行升级或换一台性能更高的服务器。无法从根本上解决问题。
2. scale out。
    横向扩展。采用多台服务器并发的处理客户端的请求。优点：成本低，扩展架构比较简单。
```

* 集群 

集群(Cluster)：通俗地讲就是按照某种组织方式将多台服务器组织起来完成某种特定任务的这样一种架构。
```
三种集群类型
1. LB：Loader Balancing，负载均衡集群。
    将客户端的请求根据某种调度分配到多台服务器上，在一定程度上可以实现高可用的目的。
2. HA：High Availity，高可用集群。
    可以达到实时的响应客户端的请求，保证服务的7*24小时提供服务。
3. HP：High Performance，高性能集群。
    提供大量超级运算能力的集群。
```

* LB负载均衡框架
```
Director：负责接收客户端的请求，并将请求按照某种算法分发到后台真正提供服务的服务器上。既可以基于硬件(如F5)来实现，也可以基于软件来实现。
基于软件实现又分为四层交换和七层交换。
四层交换：基于IP地址和端口组合起来对服务做重定向（LVS）。
七层交换：通常指的是反向代理（proxy），如Squid、Nginx等
```

* LVS：Linux Virtual Server，Linux虚拟服务。
```
类似于iptables架构，在内核中有一段代码用于实时监听数据包来源的请求，当数据包达到端口时，做一次重定向，这一系列的工作在内核中实现。
在内核中实现数据包请求处理的代码叫做ipvs。
ipvs仅提供了功能框架，还需要手动定义客户端对哪个服务的请求，而这种定义需要通过写规则来实现，这个和iptable类似，而写ipvs的规则的工具是ipvsadm。
```

* LVS的体系架构图

![lvs的体系架构](https://github.com/felix1115/Docs/blob/master/Images/lvs-1.png)


LVS的体系结构由前端的负载均衡器或调度器(Director)，中间的服务器集群，以及后端的共享存储组成。

1. Load Balancer层：位于整个集群系统的最前端，由一台或者多台负载调度器（Director Server）组成，LVS模块就安装在Director Server上，而Director的主要作用类似于一个路由器，它含有完成LVS功能所设定的路由表，通过这些路由表把用户的请求分发给Server Array层的应用服务器（Real Server）上。同时，在Director Server上还要安装对Real Server服务的监控模块Ldirectord，此模块用于监测各个Real Server服务的健康状况。在Real Server不可用时把它从LVS路由表中剔除，恢复时重新加入。

2. Server Array层：由一组实际运行应用服务的机器组成，Real Server可以是WEB服务器、MAIL服务器、FTP服务器、DNS服务器、视频服务器中的一个或者多个，每个Real Server之间通过高速的LAN或分布在各地的WAN相连接。在实际的应用中，Director Server也可以同时兼任Real Server的角色。

3. Shared Storage层：是为所有Real Server提供共享存储空间和内容一致性的存储区域。在物理上，一般有磁盘阵列设备组成，为了提供内容的一致性，一般可以通过NFS网络文件系统共享数据，但是NFS在繁忙的业务系统中，性能并不是很好，此时可以采用集群文件系统，例如Red hat的GFS文件系统，oracle提供的OCFS2文件系统等。
从整个LVS结构可以看出，Director Server是整个LVS的核心，目前，用于Director Server的操作系统只能是Linux和FreeBSD，linux2.6内核不用任何设置就可以支持LVS功能，而FreeBSD作为Director Server的应用还不是很多，性能也不是很好。
对于Real Server，几乎可以是所有的系统平台，Linux、windows、Solaris、AIX、BSD系列都能很好的支持。

* lvs中的一些地址术语

![lvs的地址术语](https://github.com/felix1115/Docs/blob/master/Images/lvs-2.png)

```
Virtual IP(VIP)：Director用来向客户端提供服务的IP地址。
Real IP(RIP)：集群节点(后台真正提供服务的服务器)所使用的IP地址。
Director's IP(DIP)：Director用来和RIP进行联系的地址。
Client IP(CIP)：客户端的IP地址。
```

# LVS模式
## LVS-NAT

![lvs nat模式](https://github.com/felix1115/Docs/blob/master/Images/lvs-3.png)

* 地址转换过程分析
```
NAT：地址转换。请求和响应都要通过Director。

* 数据包走向分析
SIP：源IP地址。
DIP：目标IP地址。

1. 请求。
    客户端请求时：SIP(CIP) ---> DIP(VIP)
    经过Director后：SIP(CIP) ---> DIP(RIP)。Director会对目标IP地址做一次DNAT，将其转换成某一台Real Server的RIP地址。

    VIP转换成RIP。

2. 响应。
    Real Server响应时：SIP(RIP) ---> DIP(CIP)
    经过Director后：SIP(VIP) ---> DIP(CIP)。Director会对源IP地址做一次SNAT，将其转换成VIP的地址。

    RIP转换成VIP。

3. 总结
    进来的请求经过Director时，会做DNAT，将VIP地址转换成RIP地址。
    出去的响应经过Director时，会做SNAT，将RIP地址转换成VIP地址。
```

* 注意事项
```
1. Director和Real Server必须位于同一网段。
2. 所有的Real Server的网关地址必须指向Director的地址。
3. Director可以重定向端口，既前端使用标准端口，后端使用非标准端口。
4. 所有进出的流量都要经过Director，Director的压力较大，可能成为瓶颈。一般来说，最多10个Real Server
5. 一般情况下，Real Server的IP地址为私网地址，只用于集群内部节点之间通信。
6. 后端的Real Server的操作没有限制。

注意：
1. RIP和DIP(客户端访问的目标IP地址)不能位于同一网段，如果同一网段，则不成功。如果经过防火墙或路由器做NAT，则可以。
2. 如果有问题，需要在Director上面关闭发送ICMP重定向的功能。否则，在客户端响应的时候，可能直接会走真实的网关地址。
[root@vm05 conf]# echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
[root@vm05 conf]# echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
[root@vm05 conf]# echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
[root@vm05 conf]#

3. 如果是同一网段做测试，则需要删除网络路由
[root@vm02 ~]# route del -net 172.17.100.0 netmask 255.255.255.0 dev eth0
[root@vm02 ~]#
```

## LVS-DR

![LVS DR模式](https://github.com/felix1115/Docs/blob/master/Images/lvs-4.png)

* 数据包走向分析
```
DR：Directing Routing，直接路由。请求经过Director，响应不经过Director。

SIP：源IP地址。
DIP：目标IP地址。

1. 请求。
    客户端请求时：SIP(CIP) ---> DIP(VIP)
    经过Director后：SIP(CIP) ---> DIP(VIP)。

    说明：Director并不会修改客户端请求时的目标IP地址，而是将目标MAC地址修改成选择的一台Real Server的MAC地址。

2. 响应
    Real Server响应时：SIP(VIP) ---> DIP(CIP)
    不经过Director。

```

* 注意事项
```
1. 请求经过Director，响应不经过Director。
2. Director必须和Real Server位于同一网段。
3. Real Server不能以Director的IP地址作为网关，而是其真实的网关。
4. Director不能使用端口重映射，前后端必须是相同的端口。
5. Real Server不能是windows系统。
```


## LVS-TUN

![LVS TUN模式](https://github.com/felix1115/Docs/blob/master/Images/lvs-5.png)

* 说明
```
与DR的网络结构一样，但Director和Real Server可以在不同的网络当中，可以实现异地容灾的功能。DIP----->VIP 基于隧道来传输，在数据包外层额外封装S:DIP D :RIP 的地址。

1. RIP一定不能是私有地址；
2. Director只负责处理进来的数据包；
3. Real Server直接将数据包返回给客户端，所以Real Server默认网关不能是DIP，必须是公网上某个路由器的地址；
4. Director不能做端口重映射；
5. 只有支持隧道协议的操作系统才能作为Real Server。   
```

# LVS调度算法
```
固定调度算法：按照某种既定的算法，不考虑实时的连接数予以分配。
1. Round-robin(RR)轮询：当新请求到达时候，按照1:1的比例将请求分配到后端可用的Real Server。
2. Weighted round-robin(WRR)加权轮询：给每台Real Server分配一个权重，权重越大，分到的请求数越多。
3. Destination hashing(DH)目标地址散列：根据请求的目标IP地址作为hask key，访问同一个目标地址，将分配同一个Real server。
4. Source hashing(SH)源地址散列：根据源地址(客户端地址)作为hask key，来自同一个客户端的地址，将会分配到同一个Real Server，除非该RS不可用。

动态调度算法：通过检查服务器上当前连接的活动状态来重新决定下一步调度方式该如何实现。
5. Lease Connection(LC)最少连接：哪一个Real Server上的连接数少就将下一个连接请求定向到那台Real Server上去。 【算法：连接数=活动连接数*256+非活动连接数】
6. Weight Least-Connection(WLC)加权最少连接：在最少连接的基础上给每台Real Server分配一个权重。 【
【算法：连接数=（活动连接数*256+非活动连接数）÷权重】 一种比较理想的算法。
7. Shortest Expected Delay (SED)  最短期望延迟：不再考虑非活动连接数。
【算法：连接数=(活动连接数+1) *256 ÷权重】
8. Never Queue (NQ) 永不排队算法：对SED的改进，当新请求过来的时候不仅要取决于SED算法所得到的值，还要取决于Real Server上是否有活动连接。
9. Locality-Based Least-Connection  (LBLC) 基于本地状态的最少连接：在DH算法的基础上还要考虑服务器上的活动连接数。
10. Locality-Based Least-Connection  with  Replication  Scheduling  (LBLCR) 带复制的基于本地的最少连接：LBLC算法的改进
```