# docker访问方式介绍
```
Docker有两种访问方式：本地访问(Socket)和远程访问(IP)

Socket方式：-H fd://   
TCP方式：-H tcp://x.x.x.x:port

说明：如果只开启远程访问，则不能使用本地访问。如果只开启本地访问，则不能使用远程访问。
```

# docker同时开启本地和远程访问
## CentOS 7系统
```
[root@docker01 ~]# mkdir /etc/systemd/system/docker.service.d
[root@docker01 ~]# cd /etc/systemd/system/docker.service.d
[root@docker01 docker.service.d]# cat >> docker.conf << EOF
> [Service]
> ExecStart=
> ExecStart=/usr/bin/docker daemon -H unix://var/run/docker.sock -H tcp://0.0.0.0:5555
> EOF
[root@docker01 docker.service.d]# 
[root@docker01 docker.service.d]# cat docker.conf 
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H unix://var/run/docker.sock -H tcp://0.0.0.0:5555
[root@docker01 docker.service.d]# 


[root@docker01 docker.service.d]# systemctl daemon-reload
[root@docker01 docker.service.d]# systemctl restart docker
[root@docker01 docker.service.d]# 

[root@docker01 docker.service.d]# netstat -tunlp | grep docker
tcp6       0      0 :::5555                 :::*                    LISTEN      11222/dockerd       
[root@docker01 docker.service.d]# 

```

## Ubuntu系统
```
felix@u01:~$ cat /etc/default/docker | grep -vE '^#|^$'
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 -H unix://var/run/docker.sock -H 0.0.0.0:5555"
felix@u01:~$ 

felix@u01:~$ sudo restart docker
docker start/running, process 25252
felix@u01:~$

felix@u01:~$ sudo netstat -tunlp | grep 5555
tcp6       0      0 :::5555                 :::*                    LISTEN      25252/dockerd   
felix@u01:~$ 

```

# 本地访问和远程访问
```
1. 本地访问
[root@docker01 ~]# docker ps -l
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                   PORTS               NAMES
175e00a34adf        hello-world         "/hello"            2 hours ago         Exited (0) 2 hours ago                       tender_hawking
[root@docker01 ~]# 
[root@docker01 ~]# 

2. 远程访问
[root@docker01 ~]# docker -H 172.17.200.100:5555 ps -l
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                         PORTS               NAMES
d354c84e013f        hello-world         "/hello"            About an hour ago   Exited (0) About an hour ago                       berserk_agnesi
[root@docker01 ~]# 

```

