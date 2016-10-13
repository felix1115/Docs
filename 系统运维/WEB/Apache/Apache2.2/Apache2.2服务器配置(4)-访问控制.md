# .htaccess�ļ�

>���ļ���AccessFileName���塣�ṩ�˻���

```

```

# Ŀ¼������֤

* Directory������
```
<Directory  /path/to/somewhere> </Directory>
���ã�����Ŀ¼�ķ���Ȩ�ޡ���Directory�������������ָ���Ӧ�õ���Ŀ¼����Ŀ¼������������ݡ�

Options������DocumentRoot�����Եġ����������ԣ�
    None���������κ����ԡ�
    All������MultiViews֮����������ԡ�
    ExecCGI������ʹ��mod_cgiģ��ִ��cgi�ű���Ȩ�ޡ�
    FollowSymLinks��Ĭ�����ã���Ŀ¼������׷�ٷ������ӣ������������DocumentRoot����ļ�������ȫ��
    Indexes�������г�����������ȫ����Ӧ������Indexes��
    Includes������ִ�з���˰�����SSI��
    SymLinksIfOwnerMatch��ֻ������Щ�ͷ������Ӿ�����ͬ��ӵ���ߵ��ļ���Ŀ¼���Ա����ʡ�
    MultiViews����������Э�̡�
AllowOverride����AllowOverride����Ϊ None ʱ����Ŀ¼������Ŀ¼�µ�.htaccess �ļ�������ȫ���ԣ���ֹ��ȡ.htaccess�ļ������ݡ�
����ָ������Ϊ All ʱ�����о��С�.htaccess�� �������ָ���������� .htaccess �ļ��С�
Order�����ڶ�����������ķ��ʿ���˳����allow,deny������deny,allow��д������һ��ΪĬ�ϲ��ԡ�
Allow from all����������
Deny from all���ܾ�����
```

* Allow��Deny��˳������
```
����Order���õ���Order allow,deny����Order deny,allow  ����ѭ���¹���
1. ��ֻƥ������֮һʱ��������ƥ��Ĺ���ִ�С���ֻƥ��allow����ִ��Allow�����ֻƥ����Deny����ִ��deny����
2. �����û��ƥ��ʱ����ִ��Ĭ�ϵĹ���������õ���Order allow,deny��Ĭ�Ϲ�����deny��������õ���Order deny,allow��Ĭ�Ϲ�����allow��
3. ���allow��deny��ƥ��ʱ����ִ��Ĭ�Ϲ��� 
```

* /path/to/somewhere��ʹ��
	- ͨ���
```


```

	- ������ʽ
```

```

# �û�������֤

>AllowOverride������Ҫ����ΪAuthConfig

## Basic��֤(�û��������������ĵķ�ʽ����)
* ���ò�������
```
AuthType���û���֤���͡�Basic(mod_auth_basicģ��)��Digest(mod_auth_digestģ��)
AuthName����֤��realm����AuthName "Top Secret"
AuthUserFile��ָ�������û���֤��Ϣ���ļ����������Ǿ���·����Ҳ���������·���������ServerRoot��
AuthGroupFile��ָ��������������֤��Ϣ���ļ����������Ǿ���·����Ҳ���������·���������ServerRoot��
AuthBasicProvider��ָ����֤��Ϣ���ṩ��ʽ��Ĭ����file��������dbm��dbd��ldap�Լ�file��
Require��ѡ����֤�û���ʲô�����û����Է�����Դ��Require������û����Ը��϶�����û�֮��Ĺ�ϵ��or��
�磺
Require user <user1> [user2> ...   ����ָ�����û����ʡ�
Require group <group1> [group2] ...  ���������е��û����ʡ�
Require valid-user��������Ч���û����ʡ�
Satisfy��������All������Any��Ĭ����All�������ǣ����ͬʱ������Allow�������ķ��ʿ��ƣ���Require���û����ʿ��ƣ����������ΪAll�����ʾ�����Ǵ����������������������ȷ���û�����������С��������Any�����ʾ���������������������������ȷ���û������������붼���ԡ�
```

* ���������ļ�htpasswd
```
���������ļ�ʹ�õ���htpasswd���

�����÷�
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

����ʹ�ø�����ʱ����Ҫʹ��-cѡ��ǵ�һ��ʹ�ø�����ʱ����Ҫʹ��-cѡ�
```

* ����ʾ��
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

* ����

![Basic��֤](https://github.com/felix1115/Docs/blob/master/Images/apache22-1.png)


* ��Ӻ�ɾ���û�
```
����û���
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd /usr/local/source/apache22/conf/.auth_config test02
New password: 
Re-type new password: 
Adding password for user test02
[root@vm3 apache22]#

ɾ���û���
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd -D /usr/local/source/apache22/conf/.auth_config test02
Deleting password for user test02
[root@vm3 apache22]# 
```

* �û���֤(Require group)

```
���ļ���ʽ��
groupname1: user1 user2 user3 ...
groupname2: user4 user5 user6 ...
...

```

```
httpd.conf���ã�AuthUserFile��AuthGroupFile��Ҫͬʱָ��
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

���ļ�����
[root@vm2 www]# cat /usr/local/source/apache22/auth/.htgroup
group1: test1
group2: test2
[root@vm2 www]# 
```

## Digest��֤(�Ƽ����SSL)
* ���ò�������
```
AuthType��������֤����ΪDigest��
AuthName��������֤��realm��
AuthUserFile��ָ�������û���֤��Ϣ���ļ����������Ǿ���·����Ҳ���������·���������ServerRoot��
AuthGroupFile��ָ��������������֤��Ϣ���ļ����������Ǿ���·����Ҳ���������·���������ServerRoot��
AuthDigestProvider��ָ����֤��Ϣ���ṩ��ʽ��Ĭ����file��������dbm��dbd��ldap�Լ�file��
AuthDigestAlgorithm��ָ��������ս����Ӧ��Ϣʱ��ʹ�õ��㷨��Ĭ��ΪMD5.
AuthDigestDomain��ָ���ܱ����Ŀռ��URI�������Ǿ��Ե�URI��Ҳ��������Ե�URI��
Require��ѡ����֤�û���ʲô�����û����Է�����Դ��Require������û����Ը��϶�����û�֮��Ĺ�ϵ��or��
�磺
Require user <user1> [user2> ...   ����ָ�����û����ʡ�
Require group <group1> [group2] ...  ���������е��û����ʡ�
Require valid-user��������Ч���û����ʡ�
Satisfy��������All������Any��Ĭ����All�������ǣ����ͬʱ������Allow�������ķ��ʿ��ƣ���Require���û����ʿ��ƣ����������ΪAll�����ʾ�����Ǵ����������������������ȷ���û�����������С��������Any�����ʾ���������������������������ȷ���û������������붼���ԡ�
```

* ���������ļ�htdigest
```
Usage: htdigest [-c] passwordfile realm username
The -c flag creates a new file.
˵����
-c����ʾ���������ļ�����һ��ʹ�á���������ļ��Ѿ������ˣ������ɾ�����ڴ�����
realm���û������ڵ�����
```

* ����ʾ��
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

* ����

![Digest��֤](https://github.com/felix1115/Docs/blob/master/Images/apache22-2.png)

* ��Ӻ�ɾ���û�
```
����û���
[root@vm3 apache22]# /usr/local/source/apache22/bin/htdigest /usr/local/source/apache22/conf/.digest_auth_config 'Test Auth' test04
Adding user test04 in realm Test Auth
New password: 
Re-type new password: 
[root@vm3 apache22]# cat /usr/local/source/apache22/conf/.digest_auth_config 
test03:Test Auth:a7e656c320ce56edaa56ce63fb663b6c
test04:Test Auth:69719387dfce3cbacaedf4491df928d4
[root@vm3 apache22]# 

ɾ���û���
1. ������htpasswdɾ��
[root@vm3 apache22]# /usr/local/source/apache22/bin/htpasswd -D /usr/local/source/apache22/conf/.digest_auth_config test04
Deleting password for user test04
[root@vm3 apache22]#

2. ʹ��sedɾ��
[root@vm3 apache22]# sed -i '/^\<test04\>/d' /usr/local/source/apache22/conf/.digest_auth_config
[root@vm3 apache22]#

```

# Apacheʹ��MySQL���ݿ�ʵ����֤
* �������
mod_auth_mysql

[��������](https://sourceforge.net/projects/modauthmysql/files/)

[�ο�����](http://modauthmysql.sourceforge.net/)

* �����ļ�

>����Ĳ����ļ�Ӧ�ú�mod_auth_mysqlλ��ͬһĿ¼�¡�


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

* ��mod_auth_mysql.c�򲹶�
```
[root@vm3 mod_auth_mysql-3.0.0]# yum install -y patch

[root@vm3 mod_auth_mysql-3.0.0]# patch < mod_auth_mysql_3.0.0_patch_apache2.2.diff 
patching file mod_auth_mysql.c
[root@vm3 mod_auth_mysql-3.0.0]# 
```

* �޸�mod_auth_mysql.c(����������Ͳ���Ҫ�޸Ĵ˲���)

>�ҵ�908�У���remote_ip��Ϊclient_ip�����漴�ɡ�


* ����mod_auth_mysql
```
[root@vm3 mod_auth_mysql-3.0.0]# /usr/local/source/apache22/bin/apxs -c -L /usr/lib64/mysql/ -I /usr/include/mysql/ -lmysqlclient -lm -lz mod_auth_mysql.c 

˵����
-L��ָ��libmysqlclient.so������ļ����ڵ�·����
-I��ָ��mysql.hͷ�ļ����ڵ�λ��
```

* ��װmod_auth_mysql
```
[root@vm3 mod_auth_mysql-3.0.0]# /usr/local/source/apache22/bin/apxs -i mod_auth_mysql.la 

[root@vm3 mod_auth_mysql-3.0.0]# ls -l /usr/local/source/apache22/modules/mod_auth_mysql.so 
-rwxr-xr-x 1 root root 72138 Oct 12 13:25 /usr/local/source/apache22/modules/mod_auth_mysql.so
[root@vm3 mod_auth_mysql-3.0.0]# 
```

* ���ò���
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

* MySQL����
```
1. �������ݿ�
mysql> create database apache;
Query OK, 1 row affected (0.14 sec)

mysql> 

2. ������ṹ
˵����������password�ֶ�����Ϊ128λ����Ҫʹ��MD5���ܵġ�
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

3. ��������
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


4. �����û�����Ȩ
mysql> grant all privileges on apache.* to 'apache'@'172.17.100.%' identified by 'apache';
Query OK, 0 rows affected (0.12 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> 

```

* ����httpd
```
1. ����ģ��
LoadModule mysql_auth_module modules/mod_auth_mysql.so

2. ����Ŀ¼��֤
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

3. ��������
[root@vm3 conf]# /etc/init.d/httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@vm3 conf]# 

```

* ����

![MySQL��֤](https://github.com/felix1115/Docs/blob/master/Images/apache22-3.png)
