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

* ����ʾ��


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