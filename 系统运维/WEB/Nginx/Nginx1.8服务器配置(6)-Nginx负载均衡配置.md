# nginx upstream
* upstream
```
用于http段中。
语法格式：upstream <name> { ... }
作用：定义服务器组。name可以随便指定。

示例:
upstream backend {
    server backend1.example.com weight=5;
    server 127.0.0.1:8080       max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend3;

    server backup1.example.com  backup;
}
```

* server
```
用于upstream段中。

语法格式：server address [parameters];
作用：指定服务器的地址和参数。
说明：address可以是IP地址，也可以是域名，以及一个可选的端口号。如：server 172.17.100.1:8080。如果没有指定端口，则默认为80端口。如果域名解析出来多个IP地址，则表示一次定义了多个server。

参数如下：
weight=<number>：设置服务器的权重。默认为1.
max_conns=<number>：限制后端服务器同时活动的最大连接数。默认值为0，表示没有限制。如果服务器组没有使用共享内存(zone)的话，则这个参数表示的是每个worker进程的限制。
max_fails=<number>：默认值为1.表示的是如果某台服务器在fail_timeout所指定的时间内出现max_fails次访问失败，则在fail_timeout时间内认为该服务器不可用。如果为0，则表示关闭该功能。可以通过指令proxy_next_upstream、 fastcgi_next_upstream和 memcached_next_upstream来配置什么是失败的尝试。 默认配置时，http_404状态不被认为是失败的尝试。
fail_timeout=<time>：默认为10s。表示服务器在该时间段内失败max_fails次后，服务器将不可用的时间。
backup：标记服务器作为备份服务器。当所有的主服务器不可用时，才会使用标记为backup的服务器。
down：标记服务器永久不可用。
resolve：监视服务器的域名所对应的IP地址的改变，当服务器的域名改变时，将会自动的修改upstream的配置，不需要重启nginx。需要在http块中配置resolver指定解析的DNS服务器。
```

* zone
```
用于upstream段中。1.9.0版本可用。
语法格式：zone <name> [size]
作用：定义用于在多个worker进程之间共享组的配置信息和运行状态信息的共享内存的名称和大小。几个组可以共享同一个zone，在这种情况下， 需要一次性指定足够的size。
```

* keepalive
```
用于upstream段中。用于代理服务器到后端服务器的长连接。http段中的keepalive表示的是客户端到web服务器之间的长连接。
语法：keepalive <connections>
作用：为从代理服务器到后端服务器的连接激活缓存。connections参数表示为每一个worker进程保留在缓存中的最大空闲的到后端服务器的连接数。如果超过该值，则最近最少使用的连接将会被关闭。

注意：
1. 对于HTTP服务器，应该设置proxy_http_version为1.1，并且将Connection头字段清空。
2. 对于FastCGI服务器，需要设置fastcgi_keep_conn为on。

配置示例1: HTTP服务器
upstream http_backend {
    server 127.0.0.1:8080;

    keepalive 16;
}

server {
    ...

    location /http/ {
        proxy_pass http://http_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
}

配置示例2：FastCGI服务器
upstream fastcgi_backend {
    server 127.0.0.1:9000;

    keepalive 8;
}

server {
    ...

    location /fastcgi/ {
        fastcgi_pass fastcgi_backend;
        fastcgi_keep_conn on;
        ...
    }
}
```

# 负载均衡算法
* 默认轮询
```
如果没有指定任何负载均衡算法，则默认为轮询。
根据服务器所配置的weight，分配请求到后端服务器。
```

* ip_hash
```
用于upstream段中。

作用：基于客户端IP地址的方式将请求分发到后端服务器的负载均衡算法。IPv4地址的前三个字节或整个IPv6地址将会作为hash key。
说明：这种负载均衡算法，可以确保来自同一个客户端的请求总是被分发到同一个后端服务器，除非后端服务器不可用。当后端服务器不可用时，客户端的请求将会分发到其他服务器。

注意：如果需要临时的移除某台服务器，需要把服务器标记为down。
```

* least_conn
```
用于upstream段中。需要nginx版本在1.3.1及其以上或者是1.2.2

作用：将用户的请求分发到具有最少活动连接数的后端服务器上，同时也会考虑服务器的权重值。如果有多个这样的服务器，将会采用加权轮询的方式。
```

* least_time
```
用于upstream段中。需要nginx版本在1.7.10
语法格式：least_time header | last_byte
作用：将客户端的请求发送到具有最少平均响应时间和最少活动连接数的后端服务器，同时也会考虑后端服务器的权重。如果有多个这样的服务器，将会采用加权轮询的方式。

header：表示接收响应头的所花费的时间。
last_byte：表示接收完整响应内容所花费的时间。
```

# nginx proxy

> ngx_http_proxy_module允许传递请求到其他服务器。


* proxy_bind
```
用于http、server、location段中。
语法：proxy_bind <address[:port]> | off
作用：指定代理服务器连接被代理服务器(后端服务器)所使用的地址和可选的端口(需要1.11.2版本)。
off：表示取消从前一个配置级别继承的proxy_bind配置，并且让系统自动分配一个本地的IP地址和端口。
```

* proxy_buffer_size
```
用于http、server、location段中。
默认值：proxy_buffer_size 4k|8k
作用：设置用于读取从后端服务器收到的响应的第一部分的缓存大小，这部分通常包括一个小的response header。通常情况这个大小等于一个内存页。

查看内存页大小：getconf PAGESIZE
```

* proxy_buffering
```
用于http、server、location段中。
默认值：proxy_buffering on
作用：是否对后端服务器的响应进行缓存。

当启用时，nginx将会尽可能快的接收从后端服务器发来的响应，并且将其保存在proxy_buffer_size和proxy_buffers指令所设置的缓存中。
如果整个响应超过buffer的大小，则它的一部分会保存在磁盘上的临时文件中。该临时文件由proxy_max_temp_file_size和proxy_temp_file_write_size指令定义。

如果禁用，当nginx收到响应时会立即同步到客户端
```

* proxy_buffers
```
用于http、server、location段中。
默认值：proxy_buffers 8 4k|8k;
语法：proxy_buffers <number> <size>
作用：为每一个连接设置number个size大小的缓存用于读取从后端服务器发来的响应。通常size大小为一个内存页。
```

* proxy_busy_buffers_size
```
用于http、server、location段中。
默认值：proxy_busy_buffers_size 8k|16k
作用：当启用proxy_buffering时，在没有读到全部响应的情况下，写缓冲到达一定大小时，nginx一定会向客户端发送响应，直到缓冲小于此值。这条指令用来设置此值。 同时，剩余的缓冲区可以用于接收响应，如果需要，一部分内容将缓冲到临时文件。该大小默认是proxy_buffer_size和proxy_buffers指令设置单块缓冲大小的两倍。
```

* proxy_temp_file_write_size
```
默认值：proxy_temp_file_write_size 8k|16k
作用：指定一次可以写入到临时文件的数据大小。
```

* proxy_max_temp_file_size
```
默认值：proxy_max_temp_file_size 1024m;
作用：当proxy_buffering设置为on时，整个响应的大小大于proxy_buffer_size和proxy_buffers的大小，则响应的一部分会被保存到临时文件中，这个指令是设置临时文件的最大大小。
```

* proxy_temp_path
```
Syntax:	proxy_temp_path path [level1 [level2 [level3]]];
Default: proxy_temp_path proxy_temp;

作用：指定一个目录用于存储从后端服务器接收的临时数据文件。
```

* proxy_connect_timeout
```
默认值：proxy_connect_timeout 60s;
作用：代理服务器和后端服务器建立连接的超时时间。不能超过75s。
```

* proxy_http_version
```
默认值：proxy_http_version 1.0
作用：设置代理时，所使用的HTTP协议版本。默认是1.0，当使用keepalive时，推荐用1.1
```

* proxy_ignore_client_abort
```
默认值：off
作用：当客户端主动关闭连接时，代理服务器和后端服务器的连接是否应该关闭。

此时在请求过程中如果客户端端主动关闭请求或者客户端网络断掉，那么 Nginx 会记录 499，同时 request_time 是 「后端已经处理」的时间，而 upstream_response_time 为 "-"

如果使用了 proxy_ignore_client_abort on ;那么客户端主动断掉连接之后，Nginx 会等待后端处理完(或者超时)，然后记录 [后端的返回信息」到日志。所以如果后端返回200，就记录 200，如果后端返回5XX ，那么就记录5XX 。
如果超时(默认60s，可以用 proxy_read_timeout 设置)，Nginx会主动断开连接，记录504。
```

* proxy_next_upstream
```
语法格式：proxy_next_upstream error | timeout | invalid_header | http_500 | http_502 | http_503 | http_504 | http_403 | http_404 | non_idempotent | off ...;
默认值：proxy_next_upstream error timeout;

作用：指定在什么情况下，才会将请求转发到下一台服务器。

error：指的是 和后端服务器建立连接错误、发送请求到后端服务器出现错误、从后端服务器读取response header发生错误
timeout：指的是 和后端服务器建立连接超时、发送请求到后端服务器出现超时、从后端服务器读取response header出现超时
invalid_header：后端服务器返回一个空的或者是无效的响应。
http_500：后端服务器返回了500的响应状态码。
http_502：后端服务器返回了502的响应状态码。
http_503：后端服务器返回了503的响应状态码。
http_504：后端服务器返回了504的响应状态码。
http_403：后端服务器返回了403的响应状态码。
http_404：后端服务器返回了404的响应状态码。
non_idempotent：通常情况下，当一个请求采用非幂等的方式(POST/LOCK/PATCH)已经发送到后端服务器的话，这个非幂等的请求不会传递到其他的后端服务器，当启用这个选项后，将会明确的告诉Nginx要重试这个请求。
off：不会将请求到下一台后端服务器。
```

* proxy_pass
```
用于location、if in location和limit_except段中
语法格式：proxy_pass <URL>

作用：设置location映射到的后端服务器的协议、地址以及一个可选的URI。地址可以是域名、IP地址以及一个可选的端口。
如：proxy_pass http://localhost:8000/uri/;

1. 如果proxy_pass指令指定了URI，当请求转发到此服务器时，被location匹配到的请求的URI将会被proxy_pass指令后所指定的URI进行替换。
	示例：当用户访问的是URI是name时，将会显示127.0.0.1/remote/下的内容。地址栏中不会有显示。
	location /name/ {
		proxy_pass http://127.0.0.1/remote/;
	}

2. 如果proxy_pass指令后面没有指定URI，则请求会以客户端发送的形式发送到后端服务器。
3. 当location使用正则表达式指定时，proxy_pass指令后面不要使用URI。
```

* proxy_pass_request_body
```
默认值：on
作用：是否将原始的请求体传递到后端服务器。
```

* proxy_pass_request_headers
```
默认值：on
作用：是否将原始请求中的请求头传递到后端服务器。
```

* proxy_read_timeout
```
默认值：proxy_read_timeout 60s;
作用：从后端服务器读取响应的超时时间。这个时间是指两个连续的读操作之间的时间，而不是传输整个响应的超时时间。
如果在这个时间段内，后端服务器没有传输任何内容，连接将会关闭。
```
* proxy_send_timeout
```
默认值: proxy_send_timeout 60s;
作用：代理服务器发送请求到后端服务器的超时时间。如果后端服务器在该时间段内没有收到任何内容，将关闭连接。
```

* proxy_set_header
```
语法格式：proxy_set_header field value;
作用：允许在发送到后端服务器的请求头中重新定义或者增加字段。
value可以包含文本、变量或者是两者的组合。
如果value为空的字符串，则该字段不会传递到后端服务器。如：proxy_set_header Accept-Encoding "";
```

* 变量
```
1. $proxy_host：proxy_pass指令中指定的后端服务器的地址。
2. $proxy_port：proxy_pass指令中指令的后端服务器的端口或者是协议的默认端口。
3. $proxy_add_x_forwarded_for：如果客户端的请求头中存在X-Forwarded-For字段，则新的X-Forwarded-For字段值为：原有的X-Forwarded-For字段的值和$remote_addr的值结合，他们之间使用逗号分隔。如果客户端的请求头中没有X-Forwarded-For字段，则$proxy_add_x_forwarded_for等同于$remote_addr。
```