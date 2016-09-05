# Docker介绍
Docker的目标：Build,Ship,Run any app,anywhere. 一次封装，到处运行。

Docker是基于Go语言实现的一个开源项目，实现轻量级的操作系统虚拟化解决方案。Docker的基础是Linux容器(LinuX Container,LXC)技术。

下图展示了Docker和传统虚拟化方式的不同之处。Docker是在操作系统层面上实现虚拟化，直接使用本地主机的操作系统。而传统虚拟化则是在硬件层面上实现虚拟化，APP运行在Guest OS上。 

![docker与传统虚拟化之间的区别](https://github.com/felix1115/Docs/blob/master/Images/docker-1.png)

