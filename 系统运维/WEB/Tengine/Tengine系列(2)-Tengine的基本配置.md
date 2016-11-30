注：Tengine完全兼容Nginx，可以根据Nginx配置Tengine，下面是Tengine一些值得注意的功能。

# 主功能
* worker_processes
```
用于core段中。
语法：worker_processes [number | auto]
作用：指定启动worker进程的个数。
number：表示启动number个worker进程。
auto：表示Tengine将自动启动和cpu数量相同的worker进程。

示例：
    worker_processes 8;
    worker_processes auto; 
```

* worker_cpu_affinity
```
用于core段中。
语法：worker_cpu_affinity [mask1 mask2 mask3 ... | auto | off]
作用：将worker进程和cpu绑定在一起。

auto：表示tengine将根据worker进程的数量自动配置cpu的绑定位图。绑定的书序是按照CPU编号从大到小。如果worker进程的数量大于cpu的数量，则剩下的worker进程将按照CPU编号从大到小的顺序从编号最大的CPU开始再次绑定。
off：tengine不会进行cpu绑定。

示例：CPU有8核
worker的数量是4，自动绑定位图：10000000 01000000 00100000 00010000
worker的数量是8，自动绑定位图：10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001
worker的数量是10，自动绑定位图是：10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001 10000000 01000000
```

* log_empty_request
```
用于http、server、location段中。
语法：log_empty_request on|off;
默认值：log_empty_request on;
作用：是否记录没有发送任何数据的请求到日志中。

off：Tengine将不会记录没有发送任何数据的访问日志。
on：Tengine会在访问日志里面记录一条400状态的日志。

示例：log_empty_request off;
```

* request_time_cache
```
用于http、server、location 段中。
语法：request_time_cache on|off
默认值：request_time_cache on;
作用：tengine是否使用时间缓存。

off：不使用时间缓存，$request_time，$request_time_msec，$request_time_usec将会得到更精确的时间。
```

* server_admin
```
用于http、server、location段中。
语法：server_admin <admin>
作用：设置网站管理员信息，当打开server_info的时候，在错误页面会显示该信息。

示例：server_admin admin@felix.com;
```

* server_info
```
用于http、server、location段中。
语法：server_info on|off
默认值：server_info on;
作用：在错误页面是否显示服务器信息。如果开启，会显示URL、服务器名称和出错时间，如果启用了server_admin，则还会显示server_admin的信息。
```

![server_info](https://github.com/felix1115/Docs/blob/master/tengine-1.png)

* server_tag
```
用于http、server和location段中。
语法：server_tag off|<customized_tag>
作用：自定义设置HTTP响应的server头。
off：表示禁止返回server头。
customized_tag：表示显示用户自定义的内容。

如果什么都不设置，就返回默认的Nginx标识。

示例：
server_tag off;
server_tag 'kakaows';
```

* reuse_port
```
用于events段中。
语法：reuse_port on|off;
默认值：reuse_port off;
作用：当打开reuse_port时，支持SO_REUSEPORT套接字参数。可以提高服务器性能。

示例：reuse_port on;
```

# 核心功能
* listen 443 ssl http2 spdy
```
用于server段中
语法：listen 443 ssl http2 spdy
作用：通过ALPN或NPN检查客户端是否支持HTTP v2和SPDY v3协议，并按照以下顺序选择处理SLL负载的协议：HTTP v2、SPDY v3、HTTP v1.x
```

* proxy_request_buffering
```
用于http、server、location段中
语法：proxy_request_buffering on|off;
默认值：proxy_request_buffering on;
作用：指定当上传请求体时是否要将请求体缓存到磁盘。

off：表示请求体不会保存到磁盘，只会保存到内存中。每当tengine接收到大于client_body_postpone_size的数据时，就发送这部分数据到后端服务器。

默认情况下，当请求体大于client_body_buffer_size，就会保存到磁盘。这会增加磁盘IO，对于上传应用来说，服务器的负载会明显增加。

注意：当设置为off且已经发出部分数据，tengine的重试机制就会失效。如果后端服务器返回异常响应，tengine就会直接返回500.此时$request_body，$request_body_file也会不可用，他们保存的可能是不完整的内容。

当tengine开启了spdy时，proxy_request_buffering off不会生效。
```

* fastcgi_request_buffering
```
用于http、server、location段中
语法：fastcgi_request_buffering on|off;
默认值：fastcgi_request_buffering on;
作用：和proxy_request_buffering功能一样。
```

* client_body_postpone_size
```
用于http、server、location段中
语法：client_body_postpone_size <size>
默认值：64k
作用：当proxy_request_buffering和fastcgi_request_buffering设置为off时，请求体不会保存到磁盘，而是保存到内存中，tengine每当接收到大于client_body_postpone_size大小的数据或者整个请求体都发送完毕，才会往后端服务器发送数据。这样可以减少与后端服务器建立连接的次数，并减少网络IO的次数。
```

* client_body_buffers
```
用于http、server和location段中。
语法：client_body_buffers <number> <size>
默认值：16 4k|8k
作用：当客户端的请求体不保存在磁盘上，而是保存在内存中时，申请number个size大小的缓存用于存储客户端请求体的内容。

注意：总缓存必须要大于client_body_postpone_size的大小。
```

* resolver
```
用于http、server、location段中。
语法：resolver address ... [valid=time] [ipv6=on|off];

当没有设置该指令时，tengine会自动读取/etc/resolv.conf配置文件里面的nameserver作为DNS服务器。
```

* gzip_clear_etag
```
用于http、server和location段中。
语法：gzip_clear_etag on|off;
默认值：on
作用：压缩的时候是否删除响应头中的ETag字段。
```

# 动态加载模块功能
* 说明
```
1. 这个模块主要用来运行时动态加载模块，而不用每次都重新编译Tengine
2. 如果想要编译官方模块为动态模块，在编译时要使用类似于--with-http_xxx_module这样的指令。如./configure --with-http_sub_module=shared
3. 如果只想安装官方模块为动态模块，而不安装nginx，则在configure后执行make dso_install命令。
4. 动态加载模块的个数限制为128个。
5. 只支持http模块。
6. 如果已经加载的动态模块有修改，则必须重启tengine才会生效。
7. 用在dso段中。
    dso {
        load ngx_http_lua_module.so;
        load ngx_http_memcached_module.so;
    }
```

* 添加第三方模块
```
使用sbin目录下的dso_tool工具。

# ./dso_tool --add-module=/home/dso/lua-nginx-module
```

* path
```
用于dso段中。
语法：path <path>
作用：指定动态模块的加载路径。
```

* load
```
用于dso段中。
语法：load [module_name] [module_path]
作用：在指定的路径中加载指定的模块。

1. 如果没有module_name，只有module_path，则module_name为module_path去掉.so后缀。
2. 如果没有module_path，只有module_name，则module_path是module_name加上.so后缀。
3. module_path的查找路径：
    3.1 module_path指定的绝对路径。
    3.2 相对于dso中的path所设置的路径。
    3.3 相对于默认的模块加载路径PREFIX/modules或者是configure中通过--dso-path设置的路径。
```


# concat模块
* 说明
```
1. 该模块主要是将多个请求合并成一个请求。减少请求的发送量。
2. 编译tengine，使其支持concat模块。
    方法1：编译其作为一个动态模块
    [root@vm03 tengine-2.1.2]# ./configure --prefix=/usr/local/source/tengine --with_google_perftools_module --with-http_concat_module=shared
    方法2：编译其作为静态模块
    [root@vm03 tengine-2.1.2]# ./configure --prefix=/usr/local/source/tengine --with_google_perftools_module --with-http_concat_module

3. 使用方法：
    3.1 请求参数需要使用2个问号(??)
    如：http://www.felix.com/??style1.css,style2.css,test/style3.css
    3.2 请求参数中某个位置包含一个问号，则问号后面的为版本号。这种方法也可以绕过缓存
    如：http://www.felix.com/??style1.css,style2.css,test/style3.css?v=102234
```

* concat
```
用于http、server和location段中。
语法：concat on|off
默认值：concat off;
作用：在指定的位置启用或禁用concat功能。

示例：
location /static/css {
    concat on;
    concat_max_files 20;
}
```

* concat_types
```
用于http、server、location段中。
语法：concat_types <MIMIE-Types> ...
默认值：concat_types: text/css application/x-javascript
作用：定义哪些MIME类型可以被合并。
```

* concat_unique
```
用于http、server、location段中。
语法：concat_unique on|off
默认值：concat_unique on
作用：是否只接受在concat_types中所定义的相同MIME类型的文件。

示例：
如果用户的请求是http://www.felix.com/??foo.css,bar/foobaz.js
如果concat_unique on，则返回400，如果设置为off，则合并两个文件。
```

* concat_max_files
```
用于http、server和location段中。
语法：concat_max_files <number>
默认值：concat_max_files 10
作用：定义最大能接受的文件数量。

如果超过最大数量，则会返回400(Bad Request)错误。
```

* concat_ignore_file_error
```
用于http、server和location段中。
用于http、server和location段中。
语法：concat_ignore_file_error on|off
默认值：concat_ignore_file_error off
作用：定义模块是否忽略文件不存在(404)或者没有权限(403)错误。
```

* concat_delimiter
```
用于http、server和location段中。
语法：concat_delimiter <string>
作用：定义在响应时文件之间的分隔符。

示例：
concat_delimiter "\n"：表示响应时会在多个请求的文件之间插入换行符。
```

* 配置示例
```
location /static {
    concat on;
    concat_max_files 20;
    concat_unique off;
    concat_types text/css application/x-javascript;
    concat_ignore_file_error off;
}
```

* HTML文件的配置
```
<link rel="stylesheet" href="??foo1.css,foo2.css,subdir/foo3.css?v=2345" />

<script src="??bar1.js,bar22.css,subdir/bar3.js?v=3245" />
```

# trim filter模块
* 说明
```
1. 该模块用于删除html、内嵌JavaScript和内嵌CSS中的注释以及重复的空白符。
2. 只能删除内嵌在HTML中的JS和CSS中的注释和重复的空白符，不能删除单独的JS和CSS的注释和重复的空白符。
```

* trim
```
用于http、server和location段中。
语法：trim on|off
默认值：trim off;
作用：删除html中的注释和重复的空白符(\n,\r,\t,'')。

注：对于pre、textarea、script、style和ie/ssi/esi注释等标签内的内容不作删除操作。

参数值可以包含变量。

示例：
set $flag "off";
if ($condition) {
    set $flag "on";
}
trim $flag;
```

* trim_js
```
用于http、server和location段中。
语法：trim_js on|off
默认值：trim_js off;
作用：删除html内嵌的js中的注释和重复的空白符。
注：对于非js代码的script标签内容不作删除操作。参数可以包含变量。
```

* trim_css
```
用于http、server和location段中。
语法：trim_css on|off
默认值：trim_css off;
作用：删除html内嵌的css中的注释和重复的空白符。
注：对于非css代码的style标签内容不作删除操作。参数可以包含变量。
```

* trim_types
```
用于http、server和location段中。
语法：trim_types <mime-types>
默认值：trim_types text/html;
作用：定义哪些MIME类型的响应可以被处理。

说明：目前只能够处理html格式的页面，js和css也只能针对html内嵌的代码，不支持处理单独的js和css文件。
```

* 配置示例
```
http {
    ...
    trim on;
    trim_js on;
    trim_css on;
}
```

* 关闭trim功能
```
请求中添加参数http_trim=off，将关闭trim功能。返回原始代码，方便调试。

格式：http://www.felix.com/test.html?http_trim=off
```

