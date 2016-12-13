# LVS-DR模式需要解决的问题
* 说明

> 在LVS DR和TUN模式下，用户的访问请求到达RS后，RS将处理结果直接返回给客户端，不经过前端的Director Server，因此每一个RS上就需要有VIP的地址，这样数据才能够直接返回给客户端。
> 通常情况下，是在lo:0口配置VIP的地址。
> 
> 



# LVS-DR模式配置
* 拓扑图

![LVS-DR](https://github.com/felix1115/Docs/blob/master/Images/lvs02.png)

* 
