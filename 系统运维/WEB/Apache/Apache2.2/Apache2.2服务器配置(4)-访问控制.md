# .htaccess文件

>该文件由AccessFileName定义。提供了基于

```

```


# 用户访问认证

>AllowOverride至少需要设置为AuthConfig

## Basic认证(用户名和密码以明文的方式发送)
* 配置参数介绍
```
AuthType：用户认证类型。Basic(mod_auth_basic模块)或Digest(mod_auth_digest模块)
AuthName：认证的realm。如AuthName "Top Secret"
AuthUserFile：指定包含用户认证信息的文件名。可以是绝对路径，也可以是相对路径（相对于ServerRoot）
AuthGroupFile：指定包含包含组认证信息的文件名。可以是绝对路径，也可以是相对路径（相对于ServerRoot）
AuthBasicProvider：指定认证信息的提供方式。默认是file。可以是dbm、dbd、ldap以及file。
Require：选择认证用户，什么样的用户可以访问资源。Require后面的用户可以跟上多个，用户之间的关系是or。
如：
Require user <user1> [user2> ...   允许指定的用户访问。
Require group <group1> [group2] ...  允许在组中的用户访问。
Require valid-user：允许有效的用户访问。
Satisfy：可以是All或者是Any。默认是All。作用是：如果同时启用了Allow（主机的访问控制）和Require（用户访问控制），如果设置为All，则表示必须是从允许的主机，并且输入正确的用户名和密码才行。而如果是Any，则表示来自允许的主机或者是输入了正确的用户名或者是密码都可以。
```

* 产生密码文件htpasswd
```
产生密码文件使用的是htpasswd命令。

命令用法
Usage:
        htpasswd [-cmdpsD] passwordfile username
        htpasswd -b[cmdpsD] passwordfile username password
        htpasswd -n[mdps] username
        htpasswd -nb[mdps] username password
 -c  Create a new file.
 -n  Don't update file; display results on stdout.
 -m  Force MD5 encryption of the password (default).
 -d  Force CRYPT encryption of the password.
 -p  Do not encrypt the password (plaintext).
 -s  Force SHA encryption of the password.
 -b  Use the password from the command line rather than prompting for it.
 -D  Delete the specified user.
On other systems than Windows, NetWare and TPF the '-p' flag will probably not work.
The SHA algorithm does not use a salt and is less secure than the MD5 algorithm.

初次使用该命令时，需要使用-c选项，非第一次使用该命令时，不要使用-c选项。
```

* 配置示例
```
Alias /test	/data/test

<Directory "/data/test">
	AllowOverride AuthConfig
	Options None
	Order allow,deny
	Allow from all
	AuthType Basic
	AuthName "Test Auth"
	AuthUserFile "/usr/local/source/apache22/conf/.auth_config"
	AuthBasicProvider file
	Require valid-user
	Satisfy All
</Directory>
```

```
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd -c /usr/local/source/apache22/conf/.auth_config test01
New password: 
Re-type new password: 
Adding password for user test01
[root@vm3 apache22]# 
```

```
[root@vm3 apache22]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 apache22]# 
```

* 测试
![Basic认证](https://github.com/felix1115/Docs/blob/master/images/apapache22-1.png)


## Digest认证(推荐结合SSL)
* 配置参数介绍
```
AuthType：设置认证类型为Digest。
AuthName：设置认证的realm。
AuthUserFile：指定包含用户认证信息的文件名。可以是绝对路径，也可以是相对路径（相对于ServerRoot）
AuthGroupFile：指定包含包含组认证信息的文件名。可以是绝对路径，也可以是相对路径（相对于ServerRoot）
AuthDigestProvider：指定认证信息的提供方式。默认是file。可以是dbm、dbd、ldap以及file。
AuthDigestAlgorithm：指定计算挑战和响应消息时所使用的算法。默认为MD5.
AuthDigestDomain：指定受保护的空间的URI。可以是绝对的URI，也可以是相对的URI。
Require：选择认证用户，什么样的用户可以访问资源。Require后面的用户可以跟上多个，用户之间的关系是or。
如：
Require user <user1> [user2> ...   允许指定的用户访问。
Require group <group1> [group2] ...  允许在组中的用户访问。
Require valid-user：允许有效的用户访问。
Satisfy：可以是All或者是Any。默认是All。作用是：如果同时启用了Allow（主机的访问控制）和Require（用户访问控制），如果设置为All，则表示必须是从允许的主机，并且输入正确的用户名和密码才行。而如果是Any，则表示来自允许的主机或者是输入了正确的用户名或者是密码都可以。
```