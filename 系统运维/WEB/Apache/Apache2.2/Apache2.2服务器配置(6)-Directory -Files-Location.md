# Directory��DirectoryMatch
* Directory������
```
<Directory  /path/to/somewhere> </Directory>
���ã�����Ŀ¼�ķ���Ȩ�ޡ���Directory�������������ָ���Ӧ�õ���Ŀ¼����Ŀ¼������������ݡ���������Server config��virtual host�С�

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

* Allow��Deny�ĵ�ַ��ʽ
```
1. Allow from 10.1.1.1
2. Allow from 10 172.20 192.168.1
3. Allow from 172.17.100.0/255.255.255.0
4. Allow from 172.17.100.0/24
5. Allow from all

SetEnvIf User-Agent ^KnockKnock/2\.0 let_me_in
6. Allow from env=let_me_in

```

* ͨ�����������ʽ
```
1. ͨ���
	?��ƥ�����ⵥ���ַ���
	*��ƥ�����ⳤ�ȵ������ַ���
	[]��ƥ�䷶Χ��
	ע�⣺������Щ������ƥ��'/'
	
	ʾ����
	<Directory /*/public_html>��������ƥ��/home/user/public_html����Ϊ*����ƥ��"/",������<Directory /home/*/public_html>

2. ������ʽ
˵�������DirectoryҪʹ��������ʽ�����������ַ�ʽ��
��ʽ1��<Directory ~ "/path/to/somewhere">
��ʽ2��<DirectoryMatch "/path/to/somewhere">

^��ƥ�俪ͷ��
$��ƥ���β��
^$��ƥ��հס�
{n}��ǰһ���ַ�����N�Ρ�
{n,}��ǰһ���ַ�����N�����ϡ�
{n,m}��ǰһ���ַ�����N��M�Ρ�
.��ƥ�����ⵥ���ַ�
*��ǰһ���ַ�����0����Ρ�
.*��ƥ�����ⳤ�ȵ������ַ���
?��ǰһ���ַ�����0�λ�1�Ρ�
[]��ƥ�䷶Χ
```

```
����ж��(��������ʽ)<Directory>���öη��ϰ���ĳ�ĵ���Ŀ¼(���丸Ŀ¼)����ôָ��Զ�Ŀ¼���ȵĹ������Ӧ�á�������.htaccess�ļ��е�ָ�����˵��
<Directory />
	AllowOverride None
</Directory>

<Directory "/home">
	AllowOverride FileInfo
</Directory>

�������ĵ�/home/web/dir/doc.html�Ĳ������£�
    * Ӧ��ָ��AllowOverride None(����.htaccess�ļ�)����ΪҪ���ʵ��ĵ�����ƥ����"/"(��Ŀ¼����)��
    * Ӧ��ָ��AllowOverride FileInfo(���/homeĿ¼)��
    * ��˳��Ӧ������/home/.htaccess ��/home/web/.htaccess ��/home/web/dir/.htaccess�е�FileInfo��ָ�
	
ʹ��������ʽ���õ�Directory������DirectoryMatch����������ͨDirectoryƥ����֮�����Կ��ǡ����е�ʹ��������ʽ���õ�Directory���������ǳ����������ļ��е�˳�����Ӧ�á�����˵���������ã�
<Directory ~ abc$>
	# ......
</Directory>
ʹ��������ʽ���õ�Directory����������ͨ��<Directory>��.htaccess�ļ�Ӧ��֮������Կ��ǡ�����ʹ��������ʽ���õ�Directory��ƥ��/home/abc/public_html/abc������Ӧ�á�

��ע�⣺Apache��<Directory />��Ĭ�Ϸ���Ȩ��Ϊ"Allow from All"������ζ��Apache�������κ�ͨ��URLӳ����ļ������ǽ�����������������������Σ�
<Directory />
	Order Deny,Allow
	Deny from All
</Directory>
Ȼ��������Ҫʹ֮�����ʵ�Ŀ¼�и��Ǵ����á�
```

* �ܽ�
```
1. ��ʹ�ó����Directory����ƥ�䡣Directory��.htaccessͬʱ����ƥ��˳���գ��Ӷ̵����ķ�ʽ����ƥ�䡣.htaccess���Ը���Directory������
2. Ȼ��ʹ��������ʽ���õ�Directory����ƥ�䡣ƥ��˳���գ������������ļ��е�˳�����ƥ�䡣
```

# Files��FilesMatch
* Files��FilesMatch˵��
```
���ã�ƥ���ļ�������������server config��virtual host��directory��.htaccess�С�
Files�θ��ݳ����������ļ��е�˳�򱻴�����Directory��.htaccess֮����Location֮ǰ��Files����Ƕ����Directory�С� 
Files����ʹ��ͨ�������ƥ�����ⵥ���ַ���*ƥ�����ⳤ�ȵ������ַ���

ʾ����
˵����
Files������������ʽ��Files ~��FilesMatch����ʹ��������ʽ��

    <Files "test.html">
        Order Allow,Deny
        Allow from 172.17.100.0/24
    </Files>
	
    <FilesMatch "\.(jpg|png|gif)$">
        Order Allow,Deny
        Deny from all 
    </FilesMatch>
```

* �ܽ�
```
1. Files��FilesMatchͬʱ����
```

# Location��LocationMatch
* Location��LocationMatch��˵��
```
���ã�ƥ���û����ʵ�URL����������server config��virtual host�С� 
Location�����Ǹ����������ļ��г��ֵ�˳����Directory��.htaccess��Files֮��

ʾ����
<Location /private1> 
	# ...
</Location>
ע�����ַ�ʽ���Է���/private1��/private1/��/private1/file.txt�����ǲ��ܷ���/private1other
<Location /private2/> 
	# ...
</Location>
ע�����ַ�ʽ���Է���/private2/��/private2/file.txt�����ǲ��ܷ���/private2other��/private2
```

* �ܽ�
```
1. Location��LocationMatchͬʱ����
```

# �ܽ�
```
1. ��ƥ��Directory�Լ�.htaccessͬʱ����.htaccess���Ը���Directory�����á�Directory��ƥ��˳���մӶ̵����ķ�ʽ���С�
2. ��ƥ��Directory ~��DirectoryMatch�����ǵ�ƥ�䷽ʽ���ճ����������ļ����Ⱥ�˳����С�
3. ƥ��Files��FilesMatch�Լ�Files ~�����ǰ��ճ����������ļ��е�˳��ͬʱ����
4. ���ƥ��Location��LocationMatch�Լ�Location ~�����ǰ��ճ����������ļ��е�˳��ͬʱ����
```