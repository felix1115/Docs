# 基于IP的虚拟主机
* 创建目录和index.html
```
[root@vm3 htdocs]# pwd
/usr/local/source/apache22/htdocs
[root@vm3 htdocs]# mkdir {server1,server2}
[root@vm3 htdocs]# echo "Server 1" > server1/index.html
[root@vm3 htdocs]# echo "Server 2" > server2/index.html
[root@vm3 htdocs]# 
```

* 添加IP地址
```
[root@vm3 htdocs]# ifconfig eth0:0 172.17.100.33 netmask 255.255.255.0 up
[root@vm3 htdocs]# 
```

* 配置虚拟主机
```
#NameVirtualHost *:80
<VirtualHost 172.17.100.3:80>
	ServerAdmin admin@felix.com
	DocumentRoot "/usr/local/source/apache22/htdocs/server1"
	ServerName server1.felix.com
	ServerAlias server1.felix.com
</VirtualHost>
<VirtualHost 172.17.100.33:80>
	ServerAdmin admin@felix.com
	DocumentRoot "/usr/local/source/apache22/htdocs/server2"
	ServerName server2.felix.com
	ServerAlias server2.felix.com
</VirtualHost>
```

* 测试
```
[root@vm01 ~]# curl 172.17.100.3
Server 1
[root@vm01 ~]# curl 172.17.100.33
Server 2
[root@vm01 ~]# 
```

# 基于端口的虚拟主机
* 配置监听端口
```
Listen 80
Listen 8080
```

* 配置虚拟主机
```
<VirtualHost 172.17.100.3:80>
	ServerAdmin admin@felix.cm
	DocumentRoot "/usr/local/source/apache22/htdocs/server1"
	ServerName server1.felix.com
	ServerAlias server1.felix.com
</VirtualHost>
<VirtualHost 172.17.100.3:8080>
	ServerAdmin admin@felix.com
	DocumentRoot "/usr/local/source/apache22/htdocs/server2"
	ServerName server2.felix.com
	ServerAlias server2.felix.com
</VirtualHost>

```

* 测试
```
[root@vm01 ~]# curl 172.17.100.3
Server 1
[root@vm01 ~]# curl 172.17.100.3:80
Server 1
[root@vm01 ~]# curl 172.17.100.3:8080
Server 2
[root@vm01 ~]# 
```

# 基于域名的虚拟主机
* 启用NameVirtualHost

>基于域名的虚拟主机，需要设置NameVirtualHost。格式为NameVirtualHost IP[:Port]
注意：这个NameVirtualHost IP:Port需要和虚拟主机配置中的VirtualHost严格匹配。

```
NameVirtualHost *:80
```

* 虚拟主机配置
```
NameVirtualHost *:80
<VirtualHost *:80>
	ServerAdmin admin@felix.cm
	DocumentRoot "/usr/local/source/apache22/htdocs/server1"
	ServerName server1.felix.com
	ServerAlias server1.felix.com
</VirtualHost>
<VirtualHost *:80>
	ServerAdmin admin@felix.com
	DocumentRoot "/usr/local/source/apache22/htdocs/server2"
	ServerName server2.felix.com
	ServerAlias server2.felix.com
</VirtualHost>
```

* 设置域名解析或者hosts文件
```
[root@vm01 ~]# echo "172.17.100.3 server1.felix.com" >> /etc/hosts
[root@vm01 ~]# echo "172.17.100.3 server2.felix.com" >> /etc/hosts
[root@vm01 ~]# 
```

* 测试
```
[root@vm01 ~]# curl server1.felix.com
Server 1
[root@vm01 ~]# curl server2.felix.com
Server 2
[root@vm01 ~]# 
```