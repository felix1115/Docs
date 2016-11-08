# ulimit配置
```
1G内存的服务器大概可以打开约10w个文件描述符。
Linux系统默认的打开的文件数是1024，在生产环境中，这个值设置的太小，如果超过该值，则会显示too many open files，

方法1：修改/etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000

方法2：修改/etc/profile文件
ulimit -n 65535
以上两种方法设置完以后，用户重新登录下就可以了，不需要重启系统。

方法3：临时设置（只会对当前设置有效）
[root@vm3 tcmalloc]# ulimit -SHn 1000000
[root@vm3 tcmalloc]#
```

# main区块设置
```
user <user> [group]：指定nginx worker进程的拥有者和所述组。如果省略了group，则默认的的group和user相同。如user  www www

pid：指定nginx pid文件的存储位置。如pid /var/run/nginx.pid，如果指定的路径相对路径，则相对于nginx的prefix。

daemon on|off：默认值为on。指定nginx是否已daemon的方式运行。通常不需要修改。

master_process on|off：默认值为on。on表示启动一个master进程和多个worker进程。off表示只启动master进程，不启动worker进程。

worker_priority <number>：指定worker进程的优先级。默认值为0，范围是-20到19，值越小，优先级越高。

worker_processes <number>：指定启动worker进程的数量。默认值为1. 通常设置为和CPU核心数一致即可。获取CPU核心数：cat /proc/cpuinfo  | grep processor | wc -l

worker_cpu_affinity <cpumask>：设置CPU和worker进程的亲和力。将worker进程绑定到CPU上。
	示例：
	worker_processes 4;
	worker_cpu_affinity 0001 0010 0100 1000;
	规则设定：
	（1）cpu有多少个核，就有几位数，1代表内核开启，0代表内核关闭
	（2）worker_processes最多开启8个，8个以上性能就不会再提升了，而且稳定性会变的更低，因此8个进程够用了
		worker_processes 8;
		worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
		
		2核CPU，开启8进程：
		worker_processes  8;  
		worker_cpu_affinity 01 10 01 10 01 10 01 10;
		
		8核CPU，开启2进程：
		worker_processes  2;
		worker_cpu_affinity 10101010 01010101;
		说明：10101010表示开启了第2,4,6,8内核，01010101表示开始了1,3,5,7内核

worker_rlimit_nofile <number>：指定一个worker进程可以打开的文件描述符数量。worker_connections不能超过该值。

error_log file|stderr|syslog:server-address[,parameter-value] [debug | info | notice | warn | error | crit | alert | emerg]：指定error log的存储位置。可以用在main、http、mail、stream、server和location区块中。如果没有指定日志等级，则默认的日志等级为error。
		
```

* main区块配置示例
```
user  www www;
worker_processes  4;
worker_cpu_affinity 0001 0010 0100  1000;

worker_rlimit_nofile 1000000;

error_log  logs/error.log  notice;

pid        /var/run/nginx.pid;
google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;

```

# events区块设置
```
use：指定处理请求的方式。常用的方式有：select、poll、kqueue（适用于FreeBSD4.1+，OpenBSD 2.9+，MasOS X,NetBSD 2.0）、epoll（适用于Linux2.6+以上的内核）、/dev/poll（Solaris 7 11/99+，HP/UX 11.22+）、eventport（Solaris 10

multi_accept on|off：默认值为off。on表示一个worker进程一次接收多个请求，off表示一个worker进程一次只接收一个请求。

accept_mutex on|off：默认值为on。
	当设置为on时，多个worker进程将会按照顺序接收新的连接，但是只有一个worker进程会被唤醒，其他的worker进程将会继续保持睡眠状态。
	当设置为off时，所有的worker进程将会被通知，但是只有一个worker进程可以获得这个连接，其他的worker进程会重新进入休眠状态。这称为“惊群问题”。
	如果网站访问量比较大，可以关闭它。
	
worker_connections <number>：默认值为512.指定一个worker进程能同时处理的连接数。
	* 通过worker_processes和worker_connections能够计算出最大客户端连接数：
    max_clients=worker_processes * worker_connections
    * 在反向代理环境中，最大客户端连接数:
    max_clients=worker_processes * worker_connections/4
    原因：默认情况下，一个浏览器会对服务器打开两个连接，Nginx使用来自同一个池中的FDS（文件描述符）来连接上游服务器。
    
	最终的结论：http 1.1协议下，由于浏览器默认使用两个并发连接,因此计算方法：
    * nginx作为http服务器的时候；
    max_clients = worker_processes * worker_connections/2
    
	* nginx作为反向代理服务器的时候：
    max_clients = worker_processes * worker_connections/4
    
	* clients与用户数：
	同一时间的clients(客户端数)和用户数还是有区别的，当一个用户请求发送一个连接时这两个是相等的，但是当一个用户默认发送多个连接请求的时候，clients数就是用户数*默认发送的连接并发数了。
	
debug_connection <address>|<cidr>|unix: 没有默认值。为指定的客户端开启debug log，其他的客户端将会使用error_log的设置。需要在编译时开启--with-debug选项。如：
    debug_connection 127.0.0.1;
    debug_connection 172.17.100.0/24;
    debug_connection localhost;
```

* event区块配置示例
```
events {
    use epoll;
    accept_mutex off;
    multi_accept on;
    worker_connections  200000;
}
```

# http区块配置

> http区块包括一个或多个server区块，server区块可以包括一个或多个location区块。


注意：以下参数如果没有特殊说明，则可用于http、server和location段中。

* client_body_buffer_size 
```
默认值为8K(32bit)或16K(64bit).设置用于读取客户端请求体的缓存大小。如果客户端的请求体大于所设置的缓存大小，则整个请求体或部分请求体会被写入到临时文件中(client_body_temp_path)。
```

* client_body_temp_path
```
语法格式：client_body_temp_path <path> [level1 [level2 [level3]]]
作用：指定存储客户端请求体的目录。最多为3级子目录结构。
```

* client_body_timeout
```
默认为60s。指定读取客户端请求体的超时时间。只会在两个成功的读操作期间才会设置这个参数，而不是整个请求体传输期间。如果在这个时间段内客户端没有发送任何内容，则服务器会发送408(Request Timeout)错误给客户端。
```

* client_header_buffer_size
```
默认为1K.用在http和server段。设置用于读取客户端请求头的缓存大小。
```

* large_client_header_buffers
```
用在http和server段中。
语法格式：large_client_header_buffers <number> <size>
默认值为：large_client_header_buffers 4 8k
作用：指定用于读取大的客户端请求头的缓存大小。指定number个size大小的缓存。

如果客户端请求行的大小超过一个buffer(size)的大小，则会返回414(Request-URI Too Large)错误给客户端。
如果客户端请求头的大小超过一个buffer(size)的大小，则会返回400(Bad Request)错误给客户端。
```

* clent_header_timeout
```
用在http和server段。
默认值60s。用于定义读取客户端请求头的超时时间。如果客户端在这个时间段内没有发送整个请求头，则服务器会发送408(Request Timeout)错误给客户端。
```

* client_max_body_size
```
默认是1m。
设置允许的客户端请求体的最大大小，该大小在请求头的Content-Length字段中。如果请求体超过该大小，则会发送413(Request Entity Too Large)错误给客户端。
设置为0，则表示关闭客户端请求体大小检查。
```

* default_type
```
默认值为：text/plain
指定响应时，默认的MIME类型。
```

* etag
```
默认为on。
作用：是否为静态资源在response header中添加ETag字段。
```

* if_modified_since
```
默认值为exact。
作用：指定如何比较文件的修改时间和请求头的If-Modified-Since字段的时间。

off：请求头中的If-Modified-Since字段会被忽略。
exact：文件的修改时间和If-Modified-Since字段必须完全匹配。
before：文件的修改时间要小于或等于If-Modified-Since字段的时间。


If-Modified-Since是标准的HTTP请求头标签，在发送HTTP请求时，把浏览器端缓存页面的最后修改时间一起发到服务器去，服务器会把这个时间与服务器上实际文件的最后修改时间进行比较。
如果时间一致，那么返回HTTP状态码304（不返回文件内容），客户端接到之后，就直接把本地缓存文件显示到浏览器中。
如果时间不一致，就返回HTTP状态码200和新的文件内容，客户端接到之后，会丢弃旧文件，把新文件缓存起来，并显示到浏览器中。

如果想要客户端每一次请求都不使用缓存，则可以将etag设置为off，if_modified_since设置为off。
```

* keepalive_disable
```
作用：对指定的浏览器关闭Keepalive。默认值为keepalive_disable msie6
语法格式：keepalive_disable none | browser ...;
browser表示要禁用keepalive的浏览器类型，可以指定多个。
none：表示所有的浏览器都开启keepalive。

```

* keepalive_requests
```
默认值为100.
指定一个http长连接中允许发送的最大请求数。
```

* keepalive_timeout
```
语法格式：keepalive_timeout <timeout> [header_timeout]
默认值是75s。
作用：指定来自同一个客户端的两个连续的HTTP请求之间的超时时间。
第一个参数指定了两个连续的http请求之间的超时时间，超过该时间后，服务器将会主动关闭连接。
第二个参数指定了在响应头中增加"Keep-Alive: timeout=time"中的time值。这个头可以让一些浏览器主动关闭连接。
```

* limit_rate
```
默认值为0.表示关闭速率限制。
作用：限制传输速率。单位是bytes/s，这个是单个请求的传输速率。如果是多个请求，则传输速率为请求数乘以限制速率。
```

* limit_rate_after
```
默认值为0.
作用：指定传输多少数据量时，才开始进行速率限制。
```

* listen
```
用于server段中。
指定监听的地址和(或)端口。
如：listen 80或者是listen 172.17.100.3:80
```

* server_name
```
用于server段中。
语法格式：server_name <name> [name] ...
作用：设置虚拟主机的名字。
第一个名字将会成为主的服务器名称。
如：
server_name  www.felix.com felix.com
server_name *.felix.com
server_name .felix.com
```
* resolver
```
语法格式：resolver address ... [valid=time]
作用：指定用于解析upstream中的主机名到IP地址的一个或多个DNS服务器。
如resolver 172.17.100.1:53，如果没有指定端口，则默认为53端口。
valid表示nginx可以缓存多长时间。
```

* resolver_timeout
```
默认为30s。指定名称解析的超时时间
```


* root
```
指定请求的根目录。默认值为root html。
```

* server_tokens
```
默认值为on。
作用：在错误信息或者是响应头Server字段中是否显示nginx的版本信息

on：表示显示版本信息
off：表示不显示版本信息。
string：表示用string替换。在1.9.13及其以后的版本可用。
```

* sendfile
```
默认为off。
作用：是否启用sendfile调用。sendfile在内核中完成文件的复制，可以提高nginx的性能。一般设置为on
```

* tcp_nopush
```
默认值为off。
只有当sendfile设置为on时，该选项才有作用。作用是：应用程序产生的数据包不会立马发送出去，等到积累到一定的量时，才会一次性发送出去，可以有效的解决网络拥塞。

当sendfile设置为on时，该选项也最好设置为on。
```

* tcp_nodelay
```
默认值为on。
作用：无延迟的发送应用程序产生的数据。而不是等待积累到一定的量时在发送。

tcp_nodelay和tcp_nopush是互斥的。


通常下列设置，可以提高性能：
sendfile 	on;
tcp_nopush 	on;
tcp_nodelay	off;
```

* types
```
语法格式：
	types {
		mime-type filename-extensions;
		...
	}
作用：映射文件名扩展到指定的MIME类型。文件名扩展是不区分大小写的。

示例：
types {
	application/octet-stream bin exe dll;
	application/octet-stream deb;
	application/octet-stream dmg;
}
```

* internal
```
只能用于location段中。
作用：指定给出的location只能用于内部的请求，对于外部的请求，则直接返回404(Not Found)。

如下的请求表示内部请求：
1. 被error_page、index、random_index、try_files这些指令重定向的请求。
2. 被rewrite指令重写的请求。
```

* error_page
```
语法格式：error_page <code> ... [=[response]] <uri>;
作用：为指定的一个或多个错误代码显示指定的URI。URI可以包含变量。
这个将会产生一个内部的重定向到指定的URI，并且将客户端的请求方法改为GET(除了GET和HEAD方法之外的所有方法)。

code：表示响应状态码。
response：表示改变响应状态码为指定的响应状态码。
uri：相对于站点根目录root的路径。不是物理路径。

示例：
error_page 404             /404.html;
error_page 500 502 503 504 /50x.html;


* 改变响应状态码
	可以用=response改变响应状态码
	示例：error_page 404 =200 /test.html;

* 重定向到指定的URL
	示例：error_page 404 http://www.felix.com;
	这种情况下，将会产生一个302(临时重定向)的状态码给客户端。
	error_page 404 =301 http://www.felix.com;
	这样就会产生一个301(永久重定向)的状态码给客户端。

* 传递error_page到命名的location
	location / {
		error_page 404 = @fallback;
	}
	location @fallback {
		proxy_pass http://backend;
	}
```

* alias
```
用于location区块中。

作用：实现URI和文件系统路径之间的映射。会将用户的请求的目录替换为alias所定义的目录。
```

* index
```
用于设置nginx的默认首页文件。处理以“/”结尾的请求。查找顺序为index所定义的顺序。如果找到，则不会查找下一个。
```

# location
* location说明
```
用于server和location段中。
语法格式如下：
location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }


location分为两种：普通location和正则location。
=、^~、@以及无任何前缀的都属于普通location。
~：表示的是正则location。区分大小写。
~*：表示的是正则location。不区分大小写。

```

* location匹配顺序
```
location的匹配顺序：先匹配普通的location，再匹配正则location。

* 普通location的匹配顺序：最大前缀匹配。和出现在配置文件中的先后顺序无关。
	示例:
	location /prefix 和location /prefix/test，如果用户请求为/prefix/test/a.html，则两个location都满足，根据最大前缀匹配，则会匹配/prefix/test这个。

* 普通location根据最大前缀匹配出结果后，还要根据正则location进行继续匹配。
说明：如果继续搜索的正则location也有匹配上的，则正则location会覆盖普通location的最大前缀匹配。如果正则location没有匹配上，则以普通location的最大前缀匹配为结果。

* 正则location的匹配顺序：根据在配置文件中出现的先后顺序匹配的。并且只要匹配到一条正则location后，就不再考虑后面的正则location了。

* 通常情况是，匹配完了普通location后，还要检测正则location，但是可以告诉Nginx，匹配到了普通location后，就不要继续匹配正则location了。要做到这一点，需要在普通location前面加上“^~”符号即可。

* 除了上面说的^~可以阻止继续搜索正则location外，还可以使用“=”来阻止继续搜索正则location。“=”和“^~”的区别在于：^~依然遵守最大前缀匹配规则，而=则强调的是严格匹配。

* 另一种可以阻止继续搜索正则location外，还有一种方式，就是：普通location的最大前缀匹配恰好就是严格精确匹配。这样也会停止继续搜索正则location。
```

# gzip相关配置
* gzip
```
作用：是否对response的内容启用gzip压缩功能。
on：表示启用。
off：表示不启用。
默认为off。
```

* gzip_buffers
```
语法格式：gzip_buffers <number> <size>
作用：指定number个size大小的缓存用于压缩response。
默认值：gzip_buffers 32 4k|16 8k;
```

* gzip_comp_level
```
作用：指定压缩等级。默认为1。范围是1到9
```

* gzip_disable
```
语法格式：gzip_disable <regexp>
作用：使用正则表达式对客户端请求头的User-Agent字段进行匹配，如果匹配到，则对响应内容不启用gzip压缩功能。
如：gzip_disable "MSIE [4-6]\."，将会匹配到MSIE 4.*到MSIE 6.*，但是不能匹配到MSIE 6.0; ... SV1
```

* gzip_min_length
```
作用：指定将会被压缩的响应内容的最小长度。根据响应头的Content-Length字段。默认是20个字节。
```

* gzip_http_version
```
作用：指定需要被压缩的HTTP的最小版本。有1.0和1.1两个值。默认是1.1
```

* gzip_types
```
语法格式：gzip_types mime-type ...;
默认值：gzip_types text/html;

作用：对指定的MIME类型进行压缩。*将会匹配所有的MIME类型。text/html总会被压缩。
```

* gzip_vary
```
默认值是off。
作用：在HTTP响应头中增加"Vary: Accept-Encoding"字段。

Vary的作用：告诉代理服务器缓存两种版本的资源：压缩和非压缩，这有助于避免一些公共代理不能正确地检测Content-Encoding标头的问题。
代理服务器会为不同的Accept-Encoding存储的内容类型是不一样的。支持Accept-Encoding，则存储的是gzip或deflate格式，不支持Accept-Encoding则存储的是网页源码。

该选项一般需要开启。gzip_vary on;
```

* gzip_proxied
```
默认值为off。

Nginx作为反向代理的时候启用，根据某些请求和应答来决定是否在对代理请求的应答启用gzip压缩，是否压缩取决于请求头中的“Via”字段，指令中可以同时指定多个不同的参数，意义如下：
off - 为所有的代理请求关闭压缩功能
expired - 启用压缩，如果header头中包含 "Expires" 头信息
no-cache - 启用压缩，如果header头中包含 "Cache-Control:no-cache" 头信息
no-store - 启用压缩，如果header头中包含 "Cache-Control:no-store" 头信息
private - 启用压缩，如果header头中包含 "Cache-Control:private" 头信息
no_last_modified - 启用压缩,如果header头中不包含 "Last-Modified" 头信息
no_etag - 启用压缩 ,如果header头中不包含 "ETag" 头信息
auth - 启用压缩 , 如果header头中包含 "Authorization" 头信息
any - 无条件启用压缩
```

* gzip配置示例
```
gzip  on; 
gzip_buffers 64 8k;     
gzip_comp_level 6;
gzip_min_length 10k;
gzip_disable "MSIE [4-6]\.";
gzip_types text/plain text/css text/xml application/javascript;
gzip_http_version 1.1;
gzip_vary on; 
```

# log
* access_log
```
语法格式：
access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;

作用：指定用户访问的日志记录位置。
off：表示关闭日志记录功能。
path：指定日志存储位置。记录到syslog的写法如下：
	error_log syslog:server=172.17.100.1 debug
	access_log syslog:server=172.17.100.1:12345,facility=local7,tag=nginx,serverity=info combined
format：指定记录日志时使用的log_format
if：将满足指定条件的信息记录下来。如果if后面的条件值为0或者是空的字符串，则不会被记录。
```

* log_format
```
用于http段中。

语法格式：log_format <name> <string> ...
name：表示被access_log引用的名字。
string：表示要引用的变量名。
	$bytes_sent：发送到客户端的字节数。包括响应头。
	$body_bytes_sent：发送到客户端的字节数。不包括响应头。
	$content_length：请求头中的Content-Length字段。
	$content_type：请求头中Content-Type字段。
	$connection：客户端的连接序列号。
	$connection_requests：通过该连接发送的当前请求数。
	$request_length：客户端发送的HTTP请求的长度(包括请求行、请求头、请求体)。
	$request_time：表示处理请求所花费的时间(单位是秒，可以显示到毫秒级)。这个时间表示的是从读取客户端发来的请求的第一个字节开始，到最后一个字节发送到客户端后的日志写入所花费的总时间。
	$status：响应状态码。
	$time_iso8601：使用ISO 8601的标准格式表示的本地时间。2016-11-03T13:00:01+08:00
	$time_local：通用日志格式表示的本地时间。03/Nov/2016:13:00:01 +0800
	$document_root：当前请求的root或alias指令的值。
	$document_uri；用户请求的URI。
	$host：用户访问的主机。顺序如下：请求行的主机名、请求头的Host字段、匹配请求的server name。
	$hostname：主机名。
	$https：如果使用ssl模式，则为on，否则为空。
	$nginx_version：nginx的版本。
	$query_string：查询字符串。
	$remote_addr：客户端地址
	$remote_port：客户端端口
	$remote_user：基本身份认证的用户名
	$request：完整的原始请求行的内容。请求行包括：请求方法、请求的URL、HTTP协议版本。
	$request_body：请求体
	$request_uri：完整的请求的URI。
	$request_method：请求方法。
	$scheme：请求的scheme。如http、https
	$server_addr：接收请求的服务器的地址。
	$server_port：接收请求的服务器的端口。
	$server_name：接收请求的服务器的名称。
	$server_protocol：请求的协议。如HTTP/1.0、HTTP/1.1、HTTP/2.0
	$http_<name>：name表示的是任意的请求头字段名称。其中name是小写的，用下划线来代替请求头中的破折号。如http_user_agent
	
```

* Nginx所有变量列表
[Nginx变量列表](http://nginx.org/en/docs/varindex.html)


* log配置示例
```
log_format common '[$time_iso8601] $remote_addr $remote_user "$request" $body_bytes_sent $status "$http_referer" "$http_user_agent"';
access_log  logs/access.log  common;
```

# 访问控制

> 用于http、server、location段中。


* allow
```
语法格式：allow <address> | <cidr> | all;
address：表示的是一个IP地址。如172.17.100.1
cidr：表示的是一个CIDR地址块。如172.17.100.0/24
all：表示的是所有地址。

示例：
allow 172.17.100.1;
allow 172.17.100.0/24;
allow all;
```

* deny
```
deny <address> | <cidr> | all;
address：表示的是一个IP地址。如172.17.100.1
cidr：表示的是一个CIDR地址块。如172.17.100.0/24
all：表示的是所有地址。

示例：
deny 172.17.100.1;
deny 172.17.100.0/24;
deny all;
```

* allow和deny的规则
```
allow和deny根据出现在配置中的顺序进行匹配，如果匹配就跳出，如果都没有匹配则允许。
```

* satisfy
```
语法格式：satisfy all | any;

默认为all。

all：表示必须通过认证和allow才允许访问。(两者同时满足)
any：表示只要满足认证或者是allow就可以。(满足其一即可)

```

* 设置黑白名单
```
指定可以访问服务器的白名单设置

http {
	...
	include whitelist.conf;
}


cat whitelist.conf

allow 172.17.100.0/24;
allow 192.168.1.0/24;
deny all;
```

# 认证

> 用于http、server、location段中。


* auth_basic
```
语法格式：auth_basic <string> | off
默认：off

off：表示不使用认证。
string：表示认证的realm，可以包含变量。

```

* auth_basic_user_file
```
作用：指定存放用户认证信息的文件名。文件名可以包含变量。
该文件的格式如下：
# comment
name1:password1
name2:password2:comment
name3:password3


可以直接用apache的htpasswd命令生成该文件。
```

* htpasswd
```
Usage:
        htpasswd [-cmdpsD] passwordfile username
        htpasswd -b[cmdpsD] passwordfile username password
        htpasswd -n[mdps] username
        htpasswd -nb[mdps] username password
 -c  Create a new file.
 -n  Don't update file; display results on stdout.
 -m  Force MD5 encryption of the password.
 -d  Force CRYPT encryption of the password (default).
 -p  Do not encrypt the password (plaintext).
 -s  Force SHA encryption of the password.
 -b  Use the password from the command line rather than prompting for it.
 -D  Delete the specified user.
说明：
-c：创建一个新的密码文件。用于第一次使用。
-n：不更新文件，只是显示结果。
-m：使用md5加密。
-d：使用CRYPT加密。默认方式。
-p：不加密。明文存放。
-s：使用SHA加密。
-b：从命令行中获取密码，而不是从交互式的提示中获取。
-d：删除指定的用户。


示例：
[root@vm3 auth]# htpasswd -c /usr/local/source/nginx18/auth/users nginx_test01
New password: 
Re-type new password: 
Adding password for user nginx_test01
[root@vm3 auth]# cat users 
nginx_test01:iExwE35H1j7oA
[root@vm3 auth]# 
```

* 配置示例
```
location /felix {
	root html;
	index index.html; 

	allow 172.17.100.1;
	deny all;
	satisfy any;

	auth_basic "need auth";
	auth_basic_user_file ../auth/users;
}

```

# AutoIndex

> 用于http、server和location段中。如果没有找到index指定所定义的文件，则列出目录下的内容。


* autoindex
```
语法：autoindex on|off
默认值：off
作用：是否启动autoindex功能。
```

* autoindex_exact_size 
```
语法：autoindex_exact_size on|off
默认值：on
作用：是否显示文件的准确大小，而不是使用KB/MB/GB。
```

* autoindex_format
```
语法格式：autoindex_format html|xml|json|jsonp
默认值：html
作用：指定目录显示格式。
```

* autoindex_localtime
```
语法格式：autoindex_localtime on|off
默认值：off
作用：是否以本地时间显示。
```

* 配置示例
```
autoindex on;
autoindex_format html;
autoindex_exact_size on;
autoindex_localtime on;
```

# stub_status
* 配置示例
```
说明：在编译时，需要启用--with-http_stub_status_module

location /status {
	stub_status;
	allow 172.17.100.0/24;
	deny all;
}
```

* 输出介绍
````
Active connections: 1338 
server accepts handled requests
 15910 15910 15138 
Reading: 0 Writing: 528 Waiting: 810 


Active Connections：当前活动的客户端的连接数。包括Waiting状态的连接。
accepts：总共接收的客户端连接数。
handled：已经处理的客户端的连接数。通常情况下，该数值和accepts的值相等，除非超过了资源限制，如worker_connections的限制。
requests：总的客户端的请求数。
Reading：当前nginx正在读取请求头的连接数。
Writing：当前nginx正在准备响应数据包给客户端的连接数。
Waiting：表示正在等待下一个请求到来的空闲客户端连接数。通常这个值等于：active - reading - writing
```