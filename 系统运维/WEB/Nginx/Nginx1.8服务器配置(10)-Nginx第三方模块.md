# nginx_upstream_check_module模块

[Github地址](https://github.com/yaoweibin/nginx_upstream_check_module)

# 安装该模块
* 下载该模块
```
[root@vm3 ~]# wget -O nginx_upstream_check_module.zip https://codeload.github.com/yaoweibin/nginx_upstream_check_module/zip/master
```

* 打补丁并重新编译安装Nginx
```
[root@vm3 nginx]# unzip nginx_upstream_check_module-master.zip 
[root@vm3 nginx]# tar -zxf nginx-1.8.1.tar.gz
[root@vm3 nginx]# mv nginx_upstream_check_module-master nginx-1.8.1
[root@vm3 nginx]# cd nginx-1.8.1
[root@vm3 nginx-1.8.1]# patch -p1 < /root/nginx/nginx-1.8.1/nginx_upstream_check_module-master/check_1.7.5+.patch 
[root@vm3 nginx-1.8.1]# ./configure --prefix=/usr/local/source/nginx18 --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_stub_status_module --add-module=nginx_upstream_check_module-master
[root@vm3 nginx-1.8.1]# make
[root@vm3 nginx-1.8.1]# make install
```

# health check模块的使用
* check
```
用于upstream中。
语法格式
    check interval=milliseconds [fall=count] [rise=count]
    [timeout=milliseconds] [default_down=true|false]
    [type=tcp|http|ssl_hello|mysql|ajp|fastcgi]
默认值：interval=30000 fall=5 rise=2 timeout=1000 default_down=true type=tcp
作用：为upstream中的服务器启用健康检查功能。
interval：检查请求的间隔。
fall：fall_count，当检查失败fall_count次以后，标记该服务器down。
rise：rise_count，当检查成功rise_count次以后，标记该服务器up。
timeout：检查请求的超时时间。
default_down：设置后端服务器的初始状态。默认是down
port：指定后端服务器的检查端口。默认端口是0，表示和原始后端服务器的端口一致。
type：健康检查时所使用的协议。
    tcp：使用TCP协议。完成TCP的三次握手。
    ssl_hello：发送客户端的ssl_hello
    数据包，收到服务器端的ssl_hello数据包。
    http：发送http请求数据包，根据收到的响应数据包进行分析，判断后端服务器是否存活。这个选项等同于check_http_send指令。
    mysql：向mysql服务器连接，通过接收服务器的greeting包来判断后端是否存活。
    ajp：发送AJP Cping数据包，收到AJP Cpong数据包。
    fastcgi：发送fastcgi请求，根据收到的响应分析后端服务器是否存活。
```

* check_http_send
```
用于upstream中。
语法格式：check_http_send <http_packet>
默认值：check_http_send "GET / HTTP/1.0\r\n\r\n"
作用：发送HTTP请求到后端服务器，根据收到的响应检查后端服务器是否正常。

如果检查类型指定了http，则使用这种方式检查后端服务器。

注意；
1. 如果项目访问地址是http://ip/name的方式，则check_http_send "GET /name HTTP/1.0\r\n\r\n";
2. 针对长连接进行检查的：check_http_send "GET /name HTTP/1.0\r\nConnection: keep-alive\r\n\r\n"
3. 针对多虚拟主机的检查：check_http_send "GET / HTTP/1.0\r\nHost: www.felix.com\r\n\r\n";
```

* check_http_expect_alive
```
用于upstream中。
语法格式：check_http_expect_alive [ http_2xx | http_3xx | http_4xx |
    http_5xx ]
默认值：check_http_expect_alive http_2xx http_3xx;
作用：认为后端服务器返回的响应是OK的响应状态码。
```

* check_keepalive_requests
```
用于upstream中。
语法格式：check_keepalive_requests <number>
默认值：check_keepalive_requests 1;
作用：表示在一个连接中发送的请求数。默认值1，表示在发送完一个请求后立即关闭连接。
```

* check_fastcgi_param
```
用于upstream中。
语法格式：check_fastcgi_params <parameter> <value>
作用：发送fastcgi头部用于检查后端服务器。

当check type指定为fastcgi时，类似于指定下面的参数：
check_fastcgi_param "REQUEST_METHOD" "GET";
check_fastcgi_param "REQUEST_URI" "/";
check_fastcgi_param "SCRIPT_FILENAME" "index.php";
```

* check_shm_size
```
用于http段中。
语法格式：check_shm_size <size>
默认值：check_shm_size 1M;
作用：指定用于健康检查时所使用的共享内存大小。如果要检查的服务器很多，需要增大该值。
```

* check_status
```
用于location段中。
语法格式：check_status [html|csv|json]
默认值：没有默认值
作用：以指定的格式显示健康检查的结果。默认是html格式。

假设location为status，指定显示格式：
/status?format=html
/status?format=csv
/status?format=json

显示指定状态的服务器：
/status?format=html&status=down
/status?format=csv&status=up
```

* 配置示例
```
upstream backend {
    server 172.17.100.1:8080;
    server 172.17.100.2;

    check interval=2000 rise=2 fall=2 timeout=1000 type=http;
    check_keepalive_requests 10000;

    keepalive 32;
}

location /health_status {
    access_log off;
    check_status html;
    allow 172.17.100.0/24;
    deny all;
}
```

![health_check status](https://github.com/felix1115/Docs/blob/master/Images/nginx_hc-1.png)


# ngx_cache_purge模块

[下载地址](http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz)

* 编译安装Nginx
```
[root@vm03 ~]# tar -zxf ngx_cache_purge-2.3.tar.gz
[root@vm03 ~]#
[root@vm03 ~]# cd nginx-1.10.2
[root@vm03 nginx-1.10.2]# ./configure --prefix=/usr/local/source/nginx --with-http_ssl_module --with-http_stub_status_module --with-google_perftools_module --add-module=../ngx_cache_purge-2.3

```

* 配置示例
```
location ~ /purge(/.*) {
    allow 172.17.100.0/24;
    deny all;
    proxy_cache_purge   cache01 $scheme://$host$1$is_args$args;
}

说明：
1. purge后面的内容为要删除的URI
2. proxy_cache_purge后面的cache01为proxy_cache_path所定义的cache名称。
3. cache01后面的$scheme://$host$1$is_args$args，这个内容为proxy_cache_key所定义的内容，只是将$request_uri换成了$1。
```

* 测试
![nginx url purge结果](https://github.com/felix1115/Docs/blob/master/Images/nginx_url_purge.png)






