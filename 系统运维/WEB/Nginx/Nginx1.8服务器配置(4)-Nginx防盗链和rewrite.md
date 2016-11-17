# Nginx防盗链

> Nginx的防盗链主要使用的是referer模块。


* valid_referers
```
语法：
valid_referers none | blocked | server_names | <string> ...

说明：当在HTTP请求头中有Referer字段，则变量$invalid_referer将会设置为空字符串，否则$invalid_referer将会设置为1. 匹配时不区分大小写

none：表示请求头中没有Referer字段。
blocked：表示请求头中有Referer字段，但是该字段的值已经被防火墙或者是代理服务器删除了，不是以"http://"或者是"https://"开头
server_names：请求头的Referer字段包含其中一个server name。
string：表示任意的字符串。可以是一个server name或者是server name和URI的结合，可以使用在server name的开头和结尾可以使用*。并且不会检查Referer字段的服务器的端口号。
    也可以使用正则表达式进行匹配，如果要使用正则表达式，则第一个符号必须是"~"，并且表达式匹配的内容应该是"http://"或者是"https://"以后的内容。
```

* 配置示例
```
location ~ \.(png|jpg|jpeg|gif)$ {
    valid_referers none blocked server_names
            *.kakaogift.cn  *.kakaogift.com;

    if ($invalid_referer) {
        return 403;
    }   
} 
```

# Rewrite
* rewrite模块所提供的指令的处理顺序
```
1. rewrite模块所提供的指令，在server段中，根据出现的先后顺序执行。
2. 下列情况被重复执行：
    2.1 根据请求的URI搜索location
    2.2 在location内部，rewrite模块所提供的指令被顺序的执行。
    2.3 如果请求的URI被重写，则重复此过程。但是重写最多不超过10次，否则会出现500(Internal server error)
```

* break
```
用于server、location、if段中。
作用：停止处理后续的rewrite模块所提供的指令，但是非rewrite模块所提供的指令会继续处理。
```

* rewrite_log
```
用于http、server、location、if段中。
默认值：rewrite_log off;
作用：是否启用rewrite log功能。rewrite的log会写入到error_log中，日志等级为notice。
```

* set
```
用于server、location、if段中。
语法格式：set $variable value
作用：为指定的variable设置值。value可以包含文本、变量或者是两者的组合。

示例：
set $rewrite 1;
```

* if
```
用于server和location段中。
语法格式：if (condition) { ... }
作用：如果指定的condition为真，则执行大括号中的指令。

condition可能的情况如下：
1. condition是一个变量。如果变量的值为空字符串或者是0，则为假。if ($invalid_referer) { ... }
2. 将变量和字符串使用"="或"!="进行比较。 if ($flag = "f") { ... }
3. 使用正则表达式进行匹配
    ~：表示匹配，区分大小写。
    ~*：表示匹配，不区分大小写。
    !~：表示不匹配，区分大小写。
    !~*：表示不匹配，不区分大小写。
4. 检查文件是否存在。-f和!-f
5. 检查目录是否存在。-d和!-d
6. 检查文件、目录或符号链接是否存在。-e和!-e
7. 检查文件是否可执行。-x和!-x
```

* return
```
用于server、location、if段中。
语法格式：
return code [text];
return code URL;
return URL;

作用：停止处理，并且返回指定的错误代码给客户端。

1. 如果code是301、302、303、307，则后面使用的是URL。
2. 如果是其他的code，则后面可以使用text。这个text表示的是response body的内容。
3. URL和text都可以包含变量。
4. 如果使用的是第二种return方式，则url参数可以是一个URI（/index.html形式的）或者是以http、https开头的一个完整URL。
5. 如果使用的是第三种return方式，则url参数必须是以http或https开头的URL。默认的response code是302.
```

* rewrite
```
用于server、location、if段中。
语法格式：rewrite regex replacement [flag];

如果请求的URI匹配了regex，则URI会被replacement进行替换。如果replacement以http://或者https://开头，则会停止处理，并返回给客户端。
rewrite会根据出现在配置文件中的先后顺序执行。

可选的flag可以是如下之一：
1. last：停止处理当前的Rewrite指令集，并且使用新的URI重新搜索location。一次请求。
2. break：停止处理当前的Rewrite指令集，但是不会使用新的URI搜索location。等同于break指令。一次请求。
3. redirect：返回一个302临时重定向的响应码给客户端。客户端会使用新的URI重新请求。会产生多个请求。
4. permanent：返回一个301永久重定向的响应码给客户端。客户端会使用新的URI重新请求。会产生多次请求。

```