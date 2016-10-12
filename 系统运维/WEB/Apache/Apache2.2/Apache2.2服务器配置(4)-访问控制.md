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

* 配置示例


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