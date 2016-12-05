# LVS介绍
* 提高服务器响应能力的方法
```
1. scale on。纵向扩展。
    是在原有服务器的基础上进行升级或换一台性能更高的服务器。无法从根本上解决问题。
2. scale out。
    横向扩展。采用多台服务器并发的处理客户端的请求。优点：成本低，扩展架构比较简单。
```

* 集群 
集群（cluster）：通俗地讲就是按照某种组织方式将多台服务器组织起来完成某种特定任务的这样一种架构。
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
Director：负责接收客户端的请求，并将请求按照某种算法分发到后台真正提供服务的服务器上。即可以基于硬件(如F5)来实现，也可以基于软件来实现。基于软件实现又分为四层交换：基于IP地址和端口组合起来对服务做重定向（LVS）。七层交换：通常指的是反向代理（proxy），如Squid、Nginx等
```

* LVS：Linux Virtual Server，Linux虚拟服务。
```
类似于iptables架构，在内核中有一段代码用于实时监听数据包来源的请求，当数据包达到端口时，做一次重定向，这一系列的工作在内核中实现。在内核中实现数据包请求处理的代码叫做ipvs。ipvs仅提供了功能框架，还需要手动定义客户端对哪个服务的请求，而这种定义需要通过写规则来实现，这个和iptable类似，而写ipvs的规则的工具是ipvsadm。
```

![lvs的体系架构](https://github.com/felix1115/Docs/blob/master/Images/lvs-1.png)


LVS的体系结构由前端的负载均衡器或调度器(Director)，中间的服务器集群，以及后端的共享存储组成。

1. Load Balancer层：位于整个集群系统的最前端，由一台或者多台负载调度器（Director Server）组成，LVS模块就安装在Director Server上，而Director的主要作用类似于一个路由器，它含有完成LVS功能所设定的路由表，通过这些路由表把用户的请求分发给Server Array层的应用服务器（Real Server）上。同时，在Director Server上还要安装对Real Server服务的监控模块Ldirectord，此模块用于监测各个Real Server服务的健康状况。在Real Server不可用时把它从LVS路由表中剔除，恢复时重新加入。

2. Server Array层：由一组实际运行应用服务的机器组成，Real Server可以是WEB服务器、MAIL服务器、FTP服务器、DNS服务器、视频服务器中的一个或者多个，每个Real Server之间通过高速的LAN或分布在各地的WAN相连接。在实际的应用中，Director Server也可以同时兼任Real Server的角色。

3. Shared Storage层：是为所有Real Server提供共享存储空间和内容一致性的存储区域。在物理上，一般有磁盘阵列设备组成，为了提供内容的一致性，一般可以通过NFS网络文件系统共享数据，但是NFS在繁忙的业务系统中，性能并不是很好，此时可以采用集群文件系统，例如Red hat的GFS文件系统，oracle提供的OCFS2文件系统等。
从整个LVS结构可以看出，Director Server是整个LVS的核心，目前，用于Director Server的操作系统只能是Linux和FreeBSD，linux2.6内核不用任何设置就可以支持LVS功能，而FreeBSD作为Director Server的应用还不是很多，性能也不是很好。
对于Real Server，几乎可以是所有的系统平台，Linux、windows、Solaris、AIX、BSD系列都能很好的支持。

# LVS模式
## LVS-NAT

## LVS-DR

## LVS-TUN


# LVS调度算法
