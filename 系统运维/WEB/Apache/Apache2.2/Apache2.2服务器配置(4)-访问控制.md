# .htaccess�ļ�

>���ļ���AccessFileName���塣�ṩ�˻���

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
![Basic��֤](https://github.com/felix1115/Docs/blob/master/images/apapache22-1.png)


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