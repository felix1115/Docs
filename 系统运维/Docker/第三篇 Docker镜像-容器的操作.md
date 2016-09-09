# Docker镜像
* 搜索镜像 docker search
    选项：
    --limit：指定最大输出结果。默认为25个。
    --no-trunc：不截断输出。
```
felix@u01:~$ docker search --limit 5 centos
NAME                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
centos                    The official build of CentOS.                   2608      [OK]       
nimmis/java-centos        This is docker images of CentOS 7 with dif...   14                   [OK]
nathonfowlie/centos-jre   Latest CentOS image with the JRE pre-insta...   3                    [OK]
blacklabelops/centos      CentOS Base Image! Built and Updates Daily!     1                    [OK]
darksheer/centos          Base Centos Image -- Updated hourly             1                    [OK]
felix@u01:~$ 

输出说明：
NAME：镜像名称。格式为username/image-name，如果username为空，则为Docker官方镜像。
DESCRIPTION：镜像描述。
STARS：镜像星级，受欢迎程度。
OFFICIAL：是否为官方镜像。官方镜像由Docker公司创建和维护。
AUTOMATED：是否为自动构建。允许用户验证镜像的来源和内容。
```

* 下载镜像 docker pull
    语法格式：docker pull [OPTIONS] NAME[:TAG|@DIGEST]
    说明：如果TAG省略，则为latest。如果NAME中没有指定Registory，则默认为Docker Hub
```
felix@u01:~$ docker pull centos
Using default tag: latest
latest: Pulling from library/centos
3d8673bd162a: Pull complete 
Digest: sha256:a66ffcb73930584413de83311ca11a4cb4938c9b2521d331026dad970c19adf4
Status: Downloaded newer image for centos:latest
felix@u01:~$ 
```

* 查看本地所有镜像 docker images
```
felix@u01:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              bd3d4369aebc        9 days ago          126.6 MB
felix@u01:~$ 

输出说明：
REPOSITORY：镜像来自于哪个仓库。
TAG：镜像标签。
IMAGE ID：镜像ID，唯一的标识一个镜像。
CREATED：镜像的创建时间。
SIZE：镜像的大小。
```

* 给镜像打标签 docker tag
```
felix@u01:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              bd3d4369aebc        9 days ago          126.6 MB
ubuntu              14.04               4a725d3b3b1c        9 days ago          188 MB
centos              latest              970633036444        5 weeks ago         196.7 MB
felix@u01:~$ 
felix@u01:~$ docker tag centos:latest felix-test:latest
felix@u01:~$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              bd3d4369aebc        9 days ago          126.6 MB
ubuntu              14.04               4a725d3b3b1c        9 days ago          188 MB
centos              latest              970633036444        5 weeks ago         196.7 MB
felix-test          latest              970633036444        5 weeks ago         196.7 MB
felix@u01:~$ 

说明：当为镜像打tag时，他们的IMAGE ID是相同的。
```

* 删除一个或多个镜像 docker rmi
    选项：
    -f：强制删除
```
felix@u01:~$ docker rmi felix-test
Untagged: felix-test:latest
felix@u01:~$

felix@u01:~$ docker rmi centos
Untagged: centos:latest
Untagged: centos@sha256:a66ffcb73930584413de83311ca11a4cb4938c9b2521d331026dad970c19adf4
Deleted: sha256:97063303644439d9cea259b0e5f4b468633c90d88bf526acc67e5ae0a6e9427c
Deleted: sha256:f59b7e59ceaafc8c2c7e340f5831b7e4cf36203e3aeb59317942b9dec9557ac5
felix@u01:~$ 


说明：
1. 当同一个镜像拥有多个标签的时候，docker rmi只是删除了该镜像的指定标签而已，并不影响镜像文件。
2. 当镜像没有标签的时候，docker rmi将会删除镜像文件本身。
3. 当使用docker rmi跟上镜像ID时，会先尝试删除该镜像的所有标签，然后删除镜像文件本身。
4. 当有使用该镜像创建的容器时，docker rmi是无法删除该镜像的。可以使用-f参数强制删除。
```

* 保存镜像到本地 docker save
    选项：
    -o：指定要保存到的文件名。是一个tar归档文件。
```
felix@u01:~$ docker save -o ubuntu-latest.tar ubuntu:latest
felix@u01:~$ 

felix@u01:~$ file ubuntu-latest.tar
ubuntu-latest: POSIX tar archive
felix@u01:~$ 
```

* 恢复本地镜像到仓库 docker load
    选项：
    -i：指定docker save保存的文件名。
    -q：安静模式。
```
方法1：
felix@u01:~$ docker load -i ubuntu-latest.tar 
c8a75145fcc4: Loading layer [==================================================>] 132.3 MB/132.3 MB
c6f2b330b60c: Loading layer [==================================================>] 15.87 kB/15.87 kB
055757a19384: Loading layer [==================================================>] 9.728 kB/9.728 kB
48373480614b: Loading layer [==================================================>] 4.608 kB/4.608 kB
0cad5e07ba33: Loading layer [==================================================>] 3.072 kB/3.072 kB
Loaded image: ubuntu:latest [========>                                          ]    512 B/3.072 kB
felix@u01:~$ 

方法2：
felix@u01:~$ docker load < ubuntu-latest.tar 
```

* 上传镜像 docker push
```
1. 登录
命令：docker login  选项  服务器
选项：
    -u：指定用户名。
    -p：指定密码。
服务器：如果没有指定，则默认为hub.docker.com

felix@u01:~$ docker login -u felix1115
Password: 
Login Succeeded
felix@u01:~$ 

如果要退出，可以用docker logout。
命令：docker logout 服务器

2. 修改镜像tag
felix@u01:~$ docker tag ubuntu:14.04 felix1115/ubuntu:test

3. push镜像到服务器
felix@u01:~$ docker push felix1115/ubuntu:test 
The push refers to a repository [docker.io/felix1115/ubuntu]
ffb6ddc7582a: Pushed 
344f56a35ff9: Pushed 
530d731d21e1: Pushed 
24fe29584c04: Pushed 
102fca64f924: Pushing [>                                                  ] 2.135 MB/187.8 MB
102fca64f924: Preparing 
felix@u01:~$ 

```

# Docker容器
* 创建容器 docker create
```
语法格式：docker create 选项  IMAGE  命令  参数
常用选项：
    -t：分配一个伪终端。
    -i：使用交互式模式，保持STDIN为打开状态。
    -h：为容器指定主机名。
    -v：挂载数据卷到容器。

felix@u01:~$ docker create -t ubuntu:latest 
431336b42a0a0c42aca695284645c04c20cee131fcc1f62453f9cd411383d64e
felix@u01:~$

说明：使用docker create 命令创建的容器默认处于stop状态。可以用docker start命令来启动它。脾气
```

* 启动一个处于停止状态的容器 docker start
```
选项：
-i：进入交互式模式，附加容器的STDIN到本地。
-a：附加容器的STDOUT、STDERR并转发信号。
```

* 停止一个处于运行状态的容器 docker stop
```
docker stop可以停止一个或多个容器。
选项：
-t：在发送SIGKILL信号之前等待的秒数。默认为10s。

docker stop首先会向容器发送SIGTERM(15号信号)信号，默认等待10s后，在发送SIGKILL信号(9号信号)。

felix@u01:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
d74f03e05c65        ubuntu              "/bin/bash"         9 seconds ago       Up 4 seconds                            dreamy_saha
felix@u01:~$ docker stop -t 1 d7
d7
felix@u01:~$ docker ps 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
felix@u01:~$ 

```

* 创建并运行容器 docker run
```
docker run的工作机制：
1. 首先会检查本地是否存在指定的镜像，如果不存在就从仓库下载。
2. 利用镜像创建并启动一个容器。
3. 分配一个文件系统，并在只读的镜像层上面创建一个可读写层。
4. 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去，并从地址池配置一个IP地址给容器。
5. 执行用户指定的应用程序。
6. 应用程序执行完毕后，容器终止。

常用选项：
-t：为容器分配一个伪终端。
-i：交互式模式，使STDIN保持打开状态。
-d：在后台运行容器。
--name：为容器指定一个名称，默认是随机产生。
-v：为容器创建数据卷。
-p：映射容器端口为指定端口。
-P：映射容器端口为随机端口。
--rm：容器退出后删除容器。
-h，--hostname：为容器指定一个主机名。
--ip：为容器分配一个IP地址。

示例：
felix@u01:~$ docker run --name felix -t -i -h d1 ubuntu /bin/bash
root@d1:/# 

```
* 列出容器 docker ps
```
选项：
-a：列出所有容器。默认是列出运行的容器。
-l：列出最后创建的容器。
-q：只显示容器的ID。
-s：显示容器的总的文件大小(包括镜像的大小)


felix@u01:~$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                       PORTS               NAMES
0c16d54adc84        ubuntu              "/bin/bash"         4 minutes ago       Exited (127) 4 minutes ago                       felix
felix@u01:~$ 

说明：
CONTAINER ID：容器的ID。
IMAGE：容器使用的IMAGE。
COMMAND：执行的命令。
CREATE：容器创建的时间。
STATUS：容器的状态信息。
PORTS：容器的端口映射信息。
NAMES：容器的名称。

docker容器里面运行的应用的进程的PID是1，也就是主进程，如果该主进程退出了，容器也就没有存在的必要了。容器是为应用而生。

```

* 进入容器 docker attach
```
如果一个容器以-d的方式运行的话，无法看到容器的信息，如果需要进入到容器进行操作的话，可以有很多方式，如docker attach，docker exec、nsenter等。

docker attach不是很方便，当进入到容器时，如果要退出容器，当按ctrl+c或者是exit的时候，就会退出容器。容器处于Exit状态。

felix@u01:~$ docker ps 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
fd0f69ead3ea        centos              "/bin/bash"         22 minutes ago      Up 8 minutes                            felix
felix@u01:~$ docker attach felix
[root@fd0f69ead3ea /]# ls
anaconda-post.log  bin  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
[root@fd0f69ead3ea /]# exit
exit
felix@u01:~$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
fd0f69ead3ea        centos              "/bin/bash"         22 minutes ago      Exited (0) 5 seconds ago                       felix
felix@u01:~$ 

```

* 在容器内部执行命令 docker exec
```
docker exec可以直接在运行的容器内部运行命令，而不需要进入容器。

选项：
-i：进入交互式模式。
-t：分配一个伪终端。
-d：在background模式下运行命令。

示例：
felix@u01:~$ docker exec felix ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 08:17 ?        00:00:00 /bin/bash
root        40     0  0 08:19 ?        00:00:00 ps -ef
felix@u01:~$ 
```

* nsenter
```
1. 安装nsenter
felix@u01:~$ wget https://www.kernel.org/pub/linux/utils/util-linux/v2.28/util-linux-2.28.tar.xz
felix@u01:~$ tar -Jxf util-linux-2.28.tar.xz 
felix@u01:~$ cd util-linux-2.28/
felix@u01:~/util-linux-2.28$ sudo cp nsenter /usr/local/bin/
felix@u01:~/util-linux-2.28$ 

2. 获取容器的PID
felix@u01:~$ docker inspect --format "{{.State.Pid}}" myapp
7413
felix@u01:~$ 

3. 连接到容器
felix@u01:~$ sudo nsenter --target 7413 --mount --uts --ipc --net --pid
root@88693aaa5937:/# 

```

* 删除容器 docker rm
```
docker rm可以删除一个或多个容器。
选项：
-f：强制删除一个运行中的容器。
-l：删除指定的link。link用于容器间通信。
-v：删除和容器关联的数据卷。

felix@u01:~$ docker rm myapp
myapp
felix@u01:~$
```