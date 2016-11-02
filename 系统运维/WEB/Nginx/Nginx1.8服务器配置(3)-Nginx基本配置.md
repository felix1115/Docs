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

```


