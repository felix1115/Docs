# SSH免密码登录
## 密钥对无密码
```
方式1：使用默认的id_rsa
步骤1：产生密钥对
[root@vmgw ~]# ssh-keygen -t rsa -b 2048 -P ''
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
86:83:24:2d:fc:3b:90:1b:7c:49:f9:3b:c3:65:83:2a root@vmgw.felix.com
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
| . . .           |
|  + =            |
| . B + o         |
|  = = = S        |
|   = + * .       |
|  E + =          |
|   . . o         |
|                 |
+-----------------+
[root@vmgw ~]# 

选项说明：
-t：指定密钥类型。
-b：指定密钥长度。
-P：指定密钥密码。如果不指定，则-P ''即可。
-f：指定密钥对文件。默认为id_rsa。

步骤2：查看产生的密钥对
[root@vmgw ~]# ls -l .ssh/
total 8
-rw------- 1 root root 1675 Aug 30 07:59 id_rsa
-rw-r--r-- 1 root root  401 Aug 30 07:59 id_rsa.pub
[root@vmgw ~]# 
说明：.pub为公钥，另一个为私钥。

步骤2：将公钥复制到需要连接的目标主机
命令：ssh-copy-id
选项：
    -i：指定identity_file名称，如果没有指定则默认为id_rsa.pub
说明：使用该命令后会自动的将identity_file文件复制到目标机器上，并添加到.ssh/authorized_keys文件中。如果不使用该命令的话，使用scp方式将该文件复制到目标机器上，并使用cat 追加到.ssh/authorized_keys文件中也行。

示例：
[root@vmgw ~]# ssh-copy-id root@172.17.100.10
The authenticity of host '172.17.100.10 (172.17.100.10)' can't be established.
RSA key fingerprint is ea:83:16:38:05:24:3e:3b:f7:34:ed:82:31:d9:e0:16.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.17.100.10' (RSA) to the list of known hosts.
root@172.17.100.10's password: 
Now try logging into the machine, with "ssh 'root@172.17.100.10'", and check in:

  .ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.

[root@vmgw ~]# 

步骤3：测试
[root@vmgw ~]# ssh 172.17.100.10
Last login: Tue Aug 30 10:25:54 2016 from 172.17.100.254
[root@vm10 ~]# 


方式2：使用用户自己指定的rsa key。
步骤1：使用-f选项指定密钥对文件名称。
[root@vmgw ~]# ssh-keygen -t rsa -f .ssh/felix_rsa -b 2048 -P ''
Generating public/private rsa key pair.
Your identification has been saved in .ssh/felix_rsa.
Your public key has been saved in .ssh/felix_rsa.pub.
The key fingerprint is:
04:0d:25:d8:a0:b0:91:b8:40:5d:c2:e8:c1:a0:b8:2e root@vmgw.felix.com
The key's randomart image is:
+--[ RSA 2048]----+
|Oo+.o=++.        |
|*B +o .o.        |
|*.o     .        |
|.o     .         |
|.       S        |
|.                |
|E.               |
|.                |
|                 |
+-----------------+
[root@vmgw ~]# 

查看产生的密钥
[root@vmgw ~]# ls -l .ssh/
total 8
-rw------- 1 root root 1675 Aug 30 08:02 felix_rsa
-rw-r--r-- 1 root root  401 Aug 30 08:02 felix_rsa.pub
[root@vmgw ~]# 

步骤2：将公钥复制到需要连接的目标主机上
[root@vmgw ~]# ssh-copy-id -i /root/.ssh/felix_rsa.pub root@172.17.100.10
root@172.17.100.10's password: 
Now try logging into the machine, with "ssh 'root@172.17.100.10'", and check in:

  .ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.

[root@vmgw ~]# 


步骤3：测试
[root@vmgw ~]# ssh -i .ssh/felix_rsa root@172.17.100.10
Last login: Tue Aug 30 10:56:21 2016 from 172.17.100.254
[root@vm10 ~]# 
说明：在使用ssh连接目标主机时，如果没有指定-i选项，则默认的私钥文件为id_rsa。

```

## 密钥对有密码
```
步骤1：产生密钥对，并指定密码
[root@vmgw ~]# ssh-keygen -t rsa -b 2048 -P 'felix'
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
dc:81:77:d8:19:80:d8:c6:c1:c2:a9:af:9c:d0:ad:fd root@vmgw.felix.com
The key's randomart image is:
+--[ RSA 2048]----+
|     . *.o...    |
|      = *. o o   |
|     . o. + +    |
|    .  . o o     |
|   . o  S .      |
|  . . o          |
|   o =           |
|    = .          |
|       .E        |
+-----------------+
[root@vmgw ~]# 


步骤2：将公钥复制到目标主机上
[root@vmgw ~]# ssh-copy-id root@172.17.100.10
root@172.17.100.10's password: 
Now try logging into the machine, with "ssh 'root@172.17.100.10'", and check in:

  .ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.

[root@vmgw ~]# 


步骤3：连接测试
[root@vmgw ~]# ssh 172.17.100.10
Enter passphrase for key '/root/.ssh/id_rsa': 
Last login: Tue Aug 30 11:04:28 2016 from 172.17.100.253
[root@vm10 ~]# 

说明：需要输入密钥对密码才行。

步骤4:启动ssh-agent，并使用ssh-add添加私钥，然后测试
[root@vmgw ~]# ssh-agent 
SSH_AUTH_SOCK=/tmp/ssh-RvZIap1646/agent.1646; export SSH_AUTH_SOCK;
SSH_AGENT_PID=1647; export SSH_AGENT_PID;
echo Agent pid 1647;
[root@vmgw ~]# ssh-add 
Could not open a connection to your authentication agent.
[root@vmgw ~]# 

说明：Could not open a connection to your authentication agent.表示的是ssh-agent启动错误。

解决方法：eval $(ssh-agent)
[root@vmgw ~]# eval $(ssh-agent)
Agent pid 1863
[root@vmgw ~]# ssh-add .ssh/id_rsa
Enter passphrase for .ssh/id_rsa: 
Identity added: .ssh/id_rsa (.ssh/id_rsa)
[root@vmgw ~]# 
[root@vmgw ~]# ssh 172.17.100.10
Last login: Tue Aug 30 11:29:43 2016 from 172.17.100.253
[root@vm10 ~]# 


ssh-add命令使用: ssh-add 选项 文件
说明: 选项和文件均为可选，如果没有指定文件，则默认为~/.ssh/id_rsa、~/.ssh/id_dsa和~/.ssh/identity.
选项：
-L：列出公钥。
-l：列出指纹。
-d：删除指定的身份信息，后面跟上公钥。
-D：删除所有的身份信息。

示例1：
[root@infragw01 ~]# ssh-add -d .ssh/ecgwrsa.pub 
Identity removed: .ssh/ecgwrsa.pub (.ssh/ecgwrsa.pub)
[root@infragw01 ~]#

```

# ssh在目标主机上执行命令
```
语法格式：ssh user@host command
[root@vmgw ~]# ssh 172.17.100.10 ifconfig eth0 | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}'
172.17.100.10
[root@vmgw ~]# 

```

# ssh直接连接目标机器不用先连接跳板机
```
配置文件：
1. ~/.ssh/config(优先)
2. /etc/ssh/ssh_config

方法1:
felix@u01:~$ ssh -t root@172.17.200.1 ssh root@172.17.100.10
root@172.17.200.1's password: 
Enter passphrase for key '/root/.ssh/id_rsa': 
Last login: Tue Aug 30 11:55:10 2016 from 172.17.100.253
[root@vm10 ~]# 

说明：-t表示强制分配一个伪终端。

方法2：配置~/.ssh/config文件
配置示例：
felix@u01:~$ cat .ssh/config 
Host *
    User root
    Port 22

Host vmgw
    HostName 172.17.200.1

Host vm10 172.17.100.10
    HostName 172.17.100.10
    ProxyCommand ssh vmgw -W %h:%p

felix@u01:~$ 


说明：
    Host：设置主机别名，*表示匹配所有的主机, ?匹配单个主机, []匹配范围。多个主机别名之间使用空格隔开。
    User：指定连接时使用的用户名。
    Port：指定连接的端口。
    HostName：设置要连接的主机的主机名或者是IP地址。
    Compression：指定是否使用压缩。可以设置为yes或no，默认为no。
    CompressionLevel：指定压缩等级。范围是1-9，默认为6.
    BindAddress：使用指定的地址作为源地址。当机器上有多个地址时，使用这个选项很有效。
    IdentityFile：指定identity文件的位置，默认的是~/.ssh/id_rsa。使用这个选项可以针对不同的机器使用不同的identity文件。如果在配置文件中指定了多个identity文件，则将会按照顺序尝试。%d：代表本地用户家目录，%u：本地用户的用户名，%l：本地用户主机名，%h：远程用户的主机名，%r：远程用户的用户名。
    ProxyCommand：指定连接到服务器时所使用的命令。%h：表示要连接的HostName，%p：表示要连接的端口。

示例：
felix@u01:~/.ssh$ cat config 
Host *
    User root
    Port 22

Host vmgw
    HostName 172.17.200.1
    IdentityFile %d/.ssh/%u@%l
felix@u01:~/.ssh$ 

```