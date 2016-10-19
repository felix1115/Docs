# Directory和DirectoryMatch
* Directory的配置
```
<Directory  /path/to/somewhere> </Directory>
作用：定义目录的访问权限。在Directory中所定义的所有指令将会应用到该目录、子目录及其里面的内容。可以用在Server config和virtual host中。

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

* Allow和Deny的地址格式
```
1. Allow from 10.1.1.1
2. Allow from 10 172.20 192.168.1
3. Allow from 172.17.100.0/255.255.255.0
4. Allow from 172.17.100.0/24
5. Allow from all

SetEnvIf User-Agent ^KnockKnock/2\.0 let_me_in
6. Allow from env=let_me_in

```

* 通配符和正则表达式
```
1. 通配符
	?：匹配任意单个字符。
	*：匹配任意长度的任意字符。
	[]：匹配范围。
	注意：上述这些都不能匹配'/'
	
	示例：
	<Directory /*/public_html>，将不能匹配/home/user/public_html，因为*不能匹配"/",可以用<Directory /home/*/public_html>

2. 正则表达式
说明：如果Directory要使用正则表达式，可以用两种方式：
方式1：<Directory ~ "/path/to/somewhere">
方式2：<DirectoryMatch "/path/to/somewhere">

^：匹配开头。
$：匹配结尾。
^$：匹配空白。
{n}：前一个字符出现N次。
{n,}：前一个字符出现N次以上。
{n,m}：前一个字符出现N到M次。
.：匹配任意单个字符
*：前一个字符出现0到多次。
.*：匹配任意长度的任意字符。
?：前一个字符出现0次或1次。
[]：匹配范围
```

```
如果有多个(非正则表达式)<Directory>配置段符合包含某文档的目录(或其父目录)，那么指令将以短目录优先的规则进行应用。并包含.htaccess文件中的指令。比如说在
<Directory />
	AllowOverride None
</Directory>

<Directory "/home">
	AllowOverride FileInfo
</Directory>

当访问文档/home/web/dir/doc.html的步骤如下：
    * 应用指令AllowOverride None(禁用.htaccess文件)。因为要访问的文档首先匹配了"/"(短目录优先)。
    * 应用指令AllowOverride FileInfo(针对/home目录)。
    * 按顺序应用所有/home/.htaccess 、/home/web/.htaccess 、/home/web/dir/.htaccess中的FileInfo组指令。
	
使用正则表达式配置的Directory或者是DirectoryMatch将在所有普通Directory匹配完之后予以考虑。所有的使用正则表达式配置的Directory将根据它们出现在配置文件中的顺序进行应用。比如说，以下配置：
<Directory ~ abc$>
	# ......
</Directory>
使用正则表达式配置的Directory将在所有普通的<Directory>和.htaccess文件应用之后才予以考虑。所以使用正则表达式配置的Directory将匹配/home/abc/public_html/abc并予以应用。

请注意：Apache对<Directory />的默认访问权限为"Allow from All"。这意味着Apache将允许任何通过URL映射的文件。我们建议您将这个配置做如下屏蔽：
<Directory />
	Order Deny,Allow
	Deny from All
</Directory>
然后在您想要使之被访问的目录中覆盖此配置。
```

* 总结
```
1. 先使用常规的Directory进行匹配。Directory和.htaccess同时处理。匹配顺序按照：从短到长的方式进行匹配。.htaccess可以覆盖Directory的配置
2. 然后使用正则表达式配置的Directory进行匹配。匹配顺序按照：出现在配置文件中的顺序进行匹配。
```

# Files和FilesMatch
* Files和FilesMatch说明
```
作用：匹配文件名。可以用在server config、virtual host、directory和.htaccess中。
Files段根据出现在配置文件中的顺序被处理。在Directory和.htaccess之后，在Location之前。Files可以嵌套在Directory中。 
Files可以使用通配符：？匹配任意单个字符，*匹配任意长度的任意字符。

示例：
说明：
Files不能用正则表达式。Files ~和FilesMatch可以使用正则表达式。

    <Files "test.html">
        Order Allow,Deny
        Allow from 172.17.100.0/24
    </Files>
	
    <FilesMatch "\.(jpg|png|gif)$">
        Order Allow,Deny
        Deny from all 
    </FilesMatch>
```

* 总结
```
1. Files和FilesMatch同时处理。
```

# Location和LocationMatch
* Location和LocationMatch的说明
```
作用：匹配用户访问的URL。可以用在server config和virtual host中。 
Location处理是根据在配置文件中出现的顺序，在Directory、.htaccess和Files之后。

示例：
<Location /private1> 
	# ...
</Location>
注：这种方式可以访问/private1、/private1/、/private1/file.txt，但是不能访问/private1other
<Location /private2/> 
	# ...
</Location>
注：这种方式可以访问/private2/、/private2/file.txt，但是不能访问/private2other和/private2
```

* 总结
```
1. Location和LocationMatch同时处理。
```

# 总结
```
1. 先匹配Directory以及.htaccess同时处理。.htaccess可以覆盖Directory的配置。Directory的匹配顺序按照从短到长的方式进行。
2. 在匹配Directory ~和DirectoryMatch，他们的匹配方式按照出现在配置文件的先后顺序进行。
3. 匹配Files和FilesMatch以及Files ~，他们按照出现在配置文件中的顺序被同时处理。
4. 最后匹配Location和LocationMatch以及Location ~，他们按照出现在配置文件中的顺序被同时处理。
```