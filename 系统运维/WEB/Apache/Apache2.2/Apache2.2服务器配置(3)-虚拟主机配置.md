# ����IP����������
* ����Ŀ¼��index.html
```
[root@vm3 htdocs]# pwd
/usr/local/source/apache22/htdocs
[root@vm3 htdocs]# mkdir {server1,server2}
[root@vm3 htdocs]# echo "Server 1" > server1/index.html
[root@vm3 htdocs]# echo "Server 2" > server2/index.html
[root@vm3 htdocs]# 
```

* ���IP��ַ
```
[root@vm3 htdocs]# ifconfig eth0:0 172.17.100.33 netmask 255.255.255.0 up
[root@vm3 htdocs]# 
```

* ������������
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

* ����
```
[root@vm01 ~]# curl 172.17.100.3
Server 1
[root@vm01 ~]# curl 172.17.100.33
Server 2
[root@vm01 ~]# 
```

# ���ڶ˿ڵ���������
* ���ü����˿�
```
Listen 80
Listen 8080
```

* ������������
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

* ����
```
[root@vm01 ~]# curl 172.17.100.3
Server 1
[root@vm01 ~]# curl 172.17.100.3:80
Server 1
[root@vm01 ~]# curl 172.17.100.3:8080
Server 2
[root@vm01 ~]# 
```

# ������������������
* ����NameVirtualHost

>����������������������Ҫ����NameVirtualHost����ʽΪNameVirtualHost IP[:Port]
ע�⣺���NameVirtualHost IP:Port��Ҫ���������������е�VirtualHost�ϸ�ƥ�䡣

```
NameVirtualHost *:80
```

* ������������
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

* ����������������hosts�ļ�
```
[root@vm01 ~]# echo "172.17.100.3 server1.felix.com" >> /etc/hosts
[root@vm01 ~]# echo "172.17.100.3 server2.felix.com" >> /etc/hosts
[root@vm01 ~]# 
```

* ����
```
[root@vm01 ~]# curl server1.felix.com
Server 1
[root@vm01 ~]# curl server2.felix.com
Server 2
[root@vm01 ~]# 
```