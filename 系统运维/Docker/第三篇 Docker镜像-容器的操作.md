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

felix@u01:~$ docker create ubuntu:latest 
431336b42a0a0c42aca695284645c04c20cee131fcc1f62453f9cd411383d64e
felix@u01:~$

说明：使用docker create 命令创建的容器默认处于stop状态。可以用docker start命令来启动它。脾气
```

