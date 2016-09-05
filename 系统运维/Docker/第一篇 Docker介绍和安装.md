# Docker介绍
## Docker介绍
Docker的目标：Build,Ship,Run any app,anywhere. 一次封装，到处运行。

Docker是基于Go语言实现的一个开源项目，实现轻量级的操作系统虚拟化解决方案。Docker的基础是Linux容器(LinuX Container,LXC)技术。

下图展示了Docker和传统虚拟化方式的不同之处。Docker是在操作系统层面上实现虚拟化，直接使用本地主机的操作系统。而传统虚拟化则是在硬件层面上实现虚拟化，APP运行在Guest OS上。 

![docker与传统虚拟化之间的区别](https://github.com/felix1115/Docs/blob/master/Images/docker-1.png)

## Docker好处
* Docker容器的启动在秒级实现，比传统的VM要快得多。
* Docker可以充分利用硬件资源，在一台主机上可以同时运行上千个容器。
* Docker容器是内核级别的虚拟化，不需要Hypervisor的支持。
* 在不同的云平台之间迁移和扩展很容易。Docker容器几乎可以在任意的平台上运行，包括物理机、虚拟机、公有云、私有云、个人电脑和服务器等，可以方便的把应用从一个平台迁移到另一个平台。

## Docker的基本概念
### 镜像(Image)
镜像是用于创建容器的基础。
Docker镜像是只读的，每一个镜像都由一系列的层(layer)组成，docker使用Union File System(UFS)将这些层组合在一起形成一个单一的镜像.UFS允许单独的文件系统中的文件和目录(称为分支)进行透明的覆盖，形成一个连贯的文件系统。
之所以称docker为轻量级的虚拟化解决方案也和这些层有关系。当对docker镜像改动时，将会在原有层的基础上再创建一个新的层，而不是替换整个镜像或者是完全的重建。只是新的层被添加或者更新，并且在分发的时候也不是分发整个镜像，而是更新新的层。

### 容器(Container)
Docker容器是使用Docker镜像来创建的，是运行应用的实例。
Docker容器类似于目录，里面包含了要运行的应用所需要的东西，如二进制程序和库文件。
Docker容器可以被启动、停止、删除等。每个容器都是相互隔离的，保证平台的安全。
镜像本身是只读的，容器在启动的时候，Docker会使用UFS在镜像的最上层创建一层可读写层，镜像本身保持不变。

### 仓库(Repository)
注册服务器：是存放Docker仓库的地方，里面存放着多个仓库。
仓库：是存放docker镜像的地方。仓库分为共有仓库和私有仓库。


# 安装Docker
```
系统需求：Docker目前只能安装在64位的平台上，并且内核版本不低于3.10。 实际上内核越新越好，过低的内核版本容易造成功能的不稳定。
```

## CentOS系统安装Docker(yum方式)
* 查看内核版本，最低内核版本为3.10
```
[root@docker01 ~]# uname -r
3.10.0-327.el7.x86_64
[root@docker01 ~]# 
```

* 更新软件包到最新
```
[root@docker01 ~]# yum update
```

* 添加docker的yum repo
```
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

* 安装docker
```
[root@docker01 ~]# yum install -y docker-engine
```

* 启动服务并设置开机自动启动
```
[root@docker01 ~]# systemctl start docker
[root@docker01 ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
[root@docker01 ~]# systemctl list-unit-files | grep docker
docker.service                              enabled 
[root@docker01 ~]# 
```

* 让普通用户也可以用使用docker，不需要执行sudo
```
1. 创建docker组
[root@docker01 ~]# groupadd docker
groupadd: group 'docker' already exists
[root@docker01 ~]# 

2. 将普通用户加入到docker组中
[root@docker01 ~]# gpasswd -a felix docker
Adding user felix to group docker
[root@docker01 ~]# 

3. 测试
[felix@docker01 ~]$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker Hub account:
 https://hub.docker.com

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

[felix@docker01 ~]$ 

```

## Ubuntu系统安装Docker
* 查看内核版本
```
felix@u01:~$ uname -r
4.2.0-27-generic
felix@u01:~$ 
```

* 更新软件包并安装apt-transport-https和ca-certificates
```
felix@u01:~$ sudo apt-get update
felix@u01:~$ sudo apt-get install -y apt-transport-https ca-certificates
```

* 添加新的GPG key
```
felix@u01:~$ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```

* 获取操作系统的代号，添加APT源
代号说明：12.04(LTS)的代号为precise，14.04(LTS)代号为trusty，15.04代号为vivid，15.10代号为wily，16.04(LTS)的代号为xenial
```
felix@u01:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.4 LTS
Release:    14.04
Codename:   trusty
felix@u01:~$ 


12.04(LTS)：deb https://apt.dockerproject.org/repo ubuntu-precise main
14.04(LTS): deb https://apt.dockerproject.org/repo ubuntu-trusty main
15.10: deb https://apt.dockerproject.org/repo ubuntu-wily main
16.04(LTS): deb https://apt.dockerproject.org/repo ubuntu-xenial main


felix@u01:~$ sudo su - root
root@u01:~# echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
root@u01:~# cat /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-trusty main
root@u01:~# 

```

* 更新apt软件包索引
```
felix@u01:~$ sudo apt-get update
```

* 验证docker-engine来自于正确的apt源
```
felix@u01:~$ sudo apt-cache policy docker-engine
```

* 使用aufs存储

```
对于ubuntu trustly 14.04、ubuntu vivid 15.04、ubuntu wily 15.04和xenial，推荐安装linux-image-extra-*内核软件包，该软件包允许使用aufs存储


felix@u01:~$ sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

```

* 安装docker
```
felix@u01:~$ sudo apt-get install -y docker-engine
```

* 启动服务并设置开机自动启动
```
felix@u01:~$ sudo service docker start
docker start/running, process 23955
felix@u01:~$ sudo sysv-rc-conf docker on
felix@u01:~$ sudo sysv-rc-conf --list docker
docker       2:on   3:on    4:on    5:on
felix@u01:~$ 

```

* 让普通用户不需要使用sudo也能执行docker
```
1. 创建docker组
felix@u01:~$ sudo groupadd docker
groupadd: group 'docker' already exists
felix@u01:~$ 

2. 将用户加入到docker组里面
felix@u01:~$ sudo gpasswd -a felix docker
Adding user felix to group docker
felix@u01:~$ 

3. 测试
需要logout，然后再重新登录。

felix@u01:~$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker Hub account:
 https://hub.docker.com

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

felix@u01:~$ 

```
注：如果报错，需要检查DOCKER_HOST变量是否存在，如果存在，删除它。

# 指定docker使用的DNS服务器地址

WARNING: Local (127.0.0.1) DNS resolver found in resolv.conf and containers
can't use it. Using default external servers : [8.8.8.8 8.8.4.4]

当出现上述警告时，表示docker不能使用本地的DNS服务器，使用了默认的外部服务器。
```
文件：/etc/default/docker 

指定DNS服务器地址：
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"
```


# 卸载docker
## CentOS系统卸载docker
```
1. 查询是否已经安装docker
[root@docker01 ~]# yum list installed | grep docker
docker-engine.x86_64               1.12.1-1.el7.centos               @dockerrepo
docker-engine-selinux.noarch       1.12.1-1.el7.centos               @dockerrepo
[root@docker01 ~]# 

2. 删除docker软件包
[root@docker01 ~]# yum remove docker-engine-selinux docker-engine

这个不会删除images、containers、volumes和用户创建的配置文件。
3. 删除images、containers、volumes
[root@docker01 ~]# rm -rf /var/lib/docker

```

## Ubuntu系统卸载docker
```
1. 删除软件包
felix@u01:~$ sudo apt-get purge docker-engine

2. 删除images、containers、volumes
felix@u01:~$ rm -rf /var/lib/docker
```






