# .htaccess文件

>该文件由AccessFileName定义。提供了基于

```

```

# 目录访问认证

* Directory的配置
```
<Directory  /path/to/somewhere> </Directory>
作用：定义目录的访问权限。在Directory中所定义的所有指令将会应用到该目录、子目录及其里面的内容。

Options：定义DocumentRoot的特性的。有如下特性：
    None：不启用任何特性。
    All：除了MultiViews之外的所有特性。
    ExecCGI：允许使用mod_cgi模块执行cgi脚本的权限。
    FollowSymLinks：默认设置，在目录中允许追踪符号链接，可以允许访问DocumentRoot外的文件。不安全。
    Indexes：允许列出索引。不安全，不应该允许Indexes。
    Includes：允许执行服务端包含（SSI）
    SymLinksIfOwnerMatch：只允许那些和符号连接具有相同的拥有者的文件或目录可以被访问。
    MultiViews：允许内容协商。
AllowOverride：在AllowOverride设置为 None 时，该目录及其子目录下的.htaccess 文件将被完全忽略，禁止读取.htaccess文件的内容。
当此指令设置为 All 时，所有具有“.htaccess” 作用域的指令都允许出现在 .htaccess 文件中。
Order：用于定义基于主机的访问控制顺序。如allow,deny或者是deny,allow。写在最后的一个为默认策略。
Allow from all：允许所有
Deny from all：拒绝所有
```

* Allow和Deny的顺序问题
```
不管Order配置的是Order allow,deny还是Order deny,allow  都遵循以下规则。
1. 当只匹配其中之一时，则按照所匹配的规则执行。如只匹配allow，则执行Allow，如果只匹配了Deny，则执行deny规则。
2. 如果都没有匹配时，则执行默认的规则。如果配置的是Order allow,deny则默认规则是deny。如果配置的是Order deny,allow则默认规则是allow。
3. 如果allow和deny都匹配时，则执行默认规则。 
```

* /path/to/somewhere的使用
	- 通配符
```


```

	- 正则表达式
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

![Basic认证](https://github.com/felix1115/Docs/blob/master/Images/apache22-1.png)


* 添加和删除用户
```
添加用户：
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd /usr/local/source/apache22/conf/.auth_config test02
New password: 
Re-type new password: 
Adding password for user test02
[root@vm3 apache22]#

删除用户：
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd -D /usr/local/source/apache22/conf/.auth_config test02
Deleting password for user test02
[root@vm3 apache22]# 
```

* 用户认证(Require group)

```
组文件格式：
groupname1: user1 user2 user3 ...
groupname2: user4 user5 user6 ...
...

```

```
httpd.conf配置：AuthUserFile和AuthGroupFile需要同时指定
<Directory "/tmp/download">
        Options Indexes
        AllowOverride AuthConfig
        AuthType Basic
        AuthName "Test Auth"
        AuthBasicProvider file
        AuthUserFile auth/.htpasswd
        AuthGroupFile auth/.htgroup
        Require group group1
        #Satisfy All
        Order deny,allow
        Deny from all
        Allow from 172.17.100.0/24
</Directory>

组文件配置
[root@vm2 www]# cat /usr/local/source/apache22/auth/.htgroup
group1: test1
group2: test2
[root@vm2 www]# 
```

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

* 产生密码文件htdigest
```
Usage: htdigest [-c] passwordfile realm username
The -c flag creates a new file.
说明：
-c：表示创建密码文件，第一次使用。如果密码文件已经存在了，则会先删除，在创建。
realm：用户名属于的领域。
```

* 配置示例
```
Alias /test	/data/test

<Directory "/data/test">
	AllowOverride AuthConfig
	Options None
	Order allow,deny
	Allow from all
	AuthType Digest
	AuthName "Test Auth"
	AuthUserFile "/usr/local/source/apache22/conf/.digest_auth_config"
	AuthBasicProvider file
	Require user test03
	Satisfy All
</Directory>
```

```
[root@vm3 apache22]# /usr/local/source/apache22/bin/htdigest -c /usr/local/source/apache22/conf/.digest_auth_config 'Test Auth' test03
Adding password for test03 in realm Test Auth.
New password: 
Re-type new password: 
[root@vm3 apache22]# cat /usr/local/source/apache22/conf/.digest_auth_config 
test03:Test Auth:a7e656c320ce56edaa56ce63fb663b6c
[root@vm3 apache22]# 
```

```
[root@vm3 apache22]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 apache22]# 
```

* 测试

![Digest认证](https://github.com/felix1115/Docs/blob/master/Images/apache22-2.png)

* 添加和删除用户
```
添加用户：
[root@vm3 apache22]# /usr/local/source/apache22/bin/htdigest /usr/local/source/apache22/conf/.digest_auth_config 'Test Auth' test04
Adding user test04 in realm Test Auth
New password: 
Re-type new password: 
[root@vm3 apache22]# cat /usr/local/source/apache22/conf/.digest_auth_config 
test03:Test Auth:a7e656c320ce56edaa56ce63fb663b6c
test04:Test Auth:69719387dfce3cbacaedf4491df928d4
[root@vm3 apache22]# 

删除用户：
1. 可以用htpasswd删除
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd -D /usr/local/source/apache22/conf/.digest_auth_config test04
Deleting password for user test04
[root@vm3 apache22]#

2. 使用sed删除
[root@vm3 apache22]# sed -i '/^\<test04\>/d' /usr/local/source/apache22/conf/.digest_auth_config
[root@vm3 apache22]#

```

# Apache使用MySQL数据库实现认证
* 所需软件
mod_auth_mysql

[下载链接](https://sourceforge.net/projects/modauthmysql/files/)

[参考链接](http://modauthmysql.sourceforge.net/)

* 补丁文件

>下面的补丁文件应该和mod_auth_mysql位于同一目录下。


```
Index: mod_auth_mysql-3.0.0/mod_auth_mysql.c
===================================================================
--- mod_auth_mysql-3.0.0.orig/mod_auth_mysql.c
+++ mod_auth_mysql-3.0.0/mod_auth_mysql.c
@@ -206,7 +206,7 @@
   #define SNPRINTF apr_snprintf
   #define PSTRDUP apr_pstrdup
   #define PSTRNDUP apr_pstrndup
-  #define STRCAT ap_pstrcat
+  #define STRCAT apr_pstrcat
   #define POOL apr_pool_t
   #include "http_request.h"   /* for ap_hook_(check_user_id | auth_checker)*/
   #include "ap_compat.h"
@@ -237,7 +237,7 @@
   #define SNPRINTF ap_snprintf
   #define PSTRDUP ap_pstrdup
   #define PSTRNDUP ap_pstrndup
-  #define STRCAT ap_pstrcat
+  #define STRCAT apr_pstrcat
   #define POOL pool
   #include <stdlib.h>
   #include "ap_sha1.h"
@@ -589,87 +589,87 @@ static void * create_mysql_auth_dir_conf
 static
 command_rec mysql_auth_cmds[] = {
	AP_INIT_TAKE1("AuthMySQLHost", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlhost),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlhost),
	OR_AUTHCFG, "mysql server host name"),
 
	AP_INIT_TAKE1("AuthMySQLPort", ap_set_int_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlport),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlport),
	OR_AUTHCFG, "mysql server port number"),
 
	AP_INIT_TAKE1("AuthMySQLSocket", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlsocket),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlsocket),
	OR_AUTHCFG, "mysql server socket path"),
 
	AP_INIT_TAKE1("AuthMySQLUser", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqluser),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqluser),
	OR_AUTHCFG, "mysql server user name"),
 
	AP_INIT_TAKE1("AuthMySQLPassword", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlpasswd),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlpasswd),
	OR_AUTHCFG, "mysql server user password"),
 
	AP_INIT_TAKE1("AuthMySQLDB", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlDB),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlDB),
	OR_AUTHCFG, "mysql database name"),
 
	AP_INIT_TAKE1("AuthMySQLUserTable", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlpwtable),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlpwtable),
	OR_AUTHCFG, "mysql user table name"),
 
	AP_INIT_TAKE1("AuthMySQLGroupTable", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlgrptable),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlgrptable),
	OR_AUTHCFG, "mysql group table name"),
 
	AP_INIT_TAKE1("AuthMySQLNameField", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlNameField),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlNameField),
	OR_AUTHCFG, "mysql User ID field name within User table"),
 
	AP_INIT_TAKE1("AuthMySQLGroupField", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlGroupField),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlGroupField),
	OR_AUTHCFG, "mysql Group field name within table"),
 
	AP_INIT_TAKE1("AuthMySQLGroupUserNameField", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlGroupUserNameField),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlGroupUserNameField),
	OR_AUTHCFG, "mysql User ID field name within Group table"),
 
	AP_INIT_TAKE1("AuthMySQLPasswordField", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlPasswordField),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlPasswordField),
	OR_AUTHCFG, "mysql Password field name within table"),
 
	AP_INIT_TAKE1("AuthMySQLPwEncryption", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlEncryptionField),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlEncryptionField),
	OR_AUTHCFG, "mysql password encryption method"),
 
	AP_INIT_TAKE1("AuthMySQLSaltField", ap_set_string_slot,
-	(void*) APR_XtOffsetOf(mysql_auth_config_rec, mysqlSaltField),
+	(void*) APR_OFFSETOF(mysql_auth_config_rec, mysqlSaltField),
	OR_AUTHCFG, "mysql salfe field name within table"),
 
 /*	AP_INIT_FLAG("AuthMySQLKeepAlive", ap_set_flag_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlKeepAlive),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlKeepAlive),
	OR_AUTHCFG, "mysql connection kept open across requests if On"),
 */
	AP_INIT_FLAG("AuthMySQLAuthoritative", ap_set_flag_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlAuthoritative),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlAuthoritative),
	OR_AUTHCFG, "mysql lookup is authoritative if On"),
 
	AP_INIT_FLAG("AuthMySQLNoPasswd", ap_set_flag_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlNoPasswd),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlNoPasswd),
	OR_AUTHCFG, "If On, only check if user exists; ignore password"),
 
	AP_INIT_FLAG("AuthMySQLEnable", ap_set_flag_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlEnable),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlEnable),
	OR_AUTHCFG, "enable mysql authorization"),
 
	AP_INIT_TAKE1("AuthMySQLUserCondition", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlUserCondition),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlUserCondition),
	OR_AUTHCFG, "condition to add to user where-clause"),
 
	AP_INIT_TAKE1("AuthMySQLGroupCondition", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlGroupCondition),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlGroupCondition),
	OR_AUTHCFG, "condition to add to group where-clause"),
 
	AP_INIT_TAKE1("AuthMySQLCharacterSet", ap_set_string_slot,
-	(void *) APR_XtOffsetOf(mysql_auth_config_rec, mysqlCharacterSet),
+	(void *) APR_OFFSETOF(mysql_auth_config_rec, mysqlCharacterSet),
	OR_AUTHCFG, "mysql character set to be used"),
 
   { NULL }

```

* 对mod_auth_mysql.c打补丁
```
[root@vm3 mod_auth_mysql-3.0.0]# yum install -y patch

[root@vm3 mod_auth_mysql-3.0.0]# patch < mod_auth_mysql_3.0.0_patch_apache2.2.diff 
patching file mod_auth_mysql.c
[root@vm3 mod_auth_mysql-3.0.0]# 
```

* 修改mod_auth_mysql.c(如果编译错误就不需要修改此步骤)

>找到908行，将remote_ip改为client_ip，保存即可。


* 编译mod_auth_mysql
```
[root@vm3 mod_auth_mysql-3.0.0]# /usr/local/source/apache22/bin/apxs -c -L /usr/lib64/mysql/ -I /usr/include/mysql/ -lmysqlclient -lm -lz mod_auth_mysql.c 

说明：
-L：指定libmysqlclient.so这个库文件所在的路径。
-I：指定mysql.h头文件所在的位置
```

* 安装mod_auth_mysql
```
[root@vm3 mod_auth_mysql-3.0.0]# /usr/local/source/apache22/bin/apxs -i mod_auth_mysql.la 

[root@vm3 mod_auth_mysql-3.0.0]# ls -l /usr/local/source/apache22/modules/mod_auth_mysql.so 
-rwxr-xr-x 1 root root 72138 Oct 12 13:25 /usr/local/source/apache22/modules/mod_auth_mysql.so
[root@vm3 mod_auth_mysql-3.0.0]# 
```

* 配置参数
```
Configuration Parameter		Option				Valid Values (1)(2)
-----------------------		------				------------
AuthMySQLHost				HOST				"localhost", host name or ip address
AuthMySQLPort				PORT				integer port number
AuthMySQLSocket				SOCKET				full path name of UNIX socket to use
AuthMySQLUser				USER				MySQL user id
AuthMySQLPassword			PASSWORD			MySQL password
AuthMySQLDB					DB					MySQL database
AuthMySQLPwTable			PWTABLE				MySQL table to use
AuthMySQlNameField			NAMEFIELD			MySQL column name
AuthMySQLPasswordField		PASSWORDFIELD		MySQL column name
AuthMySQLPwEncryption		ENCRYPTION (3)		"none", "crypt", "scrambled", "md5", "aes", "sha1"
AuthMySQLSaltField			SALT				"<>", <string> or MySQL column name
AuthMySQLKeepAlive			KEEPALIVE			"0", "1"
AuthMySQLAuthoritative		AUTHORITATIVE		"0", "1"
AuthMySQLNoPassword			NOPASSWORD			"0", "1"
AuthMySQLEnable				ENABLE				"0", "1"
AuthMySQLCharacterSet		CHARACTERSET		MySQL character set to use
```

* MySQL配置
```
1. 创建数据库
mysql> create database apache;
Query OK, 1 row affected (0.14 sec)

mysql> 

2. 创建表结构
说明：这里面password字段设置为128位，是要使用MD5加密的。
mysql> use apache
Database changed
mysql> create table apache22 (
    -> username varchar(30) NOT NULL,
    -> password char(128) NOT NULL,
    -> usergroup varchar(30),
    -> primary key (username)
    -> );
Query OK, 0 rows affected (0.12 sec)

mysql> 

3. 插入数据
mysql> insert into apache22 values ('mysql-test01', md5('test01'), 'test');
Query OK, 1 row affected (0.10 sec)

mysql> select * from apache22;
+--------------+----------------------------------+-----------+
| username     | password                         | usergroup |
+--------------+----------------------------------+-----------+
| mysql-test01 | 0e698a8ffc1a0af622c7b4db3cb750cc | test      |
+--------------+----------------------------------+-----------+
1 row in set (0.00 sec)

mysql> 


4. 创建用户并授权
mysql> grant all privileges on apache.* to 'apache'@'172.17.100.%' identified by 'apache';
Query OK, 0 rows affected (0.12 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> 

```

* 配置httpd
```
1. 载入模块
LoadModule mysql_auth_module modules/mod_auth_mysql.so

2. 配置目录认证
Alias /test	/data/test

<Directory "/data/test">
	AllowOverride AuthConfig
	Options None
	Order allow,deny
	Allow from all

	AuthType Basic
	AuthName "MySQL Auth"
	AuthUserFile /dev/null
	AuthBasicAuthoritative off
	AuthMySQLEnable On
	AuthMySQLHost 172.17.100.3
	AuthMySQLPort 3306
	AuthMySQLUser apache
	AuthMySQLPassword apache
	AuthMySQLDB apache
	AuthMySQLUserTable apache22
	AuthMySQLNameField username
	AuthMySQLPasswordField password
	AuthMySQLGroupField usergroup
	AuthMySQLPwEncryption md5
	Require valid-user
</Directory>

3. 重启服务
[root@vm3 conf]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 conf]# 

```

* 测试

![MySQL认证](https://github.com/felix1115/Docs/blob/master/Images/apache22-3.png)
