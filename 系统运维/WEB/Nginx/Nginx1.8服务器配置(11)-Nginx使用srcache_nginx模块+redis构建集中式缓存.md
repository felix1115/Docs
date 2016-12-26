# 需要的模块
```
ngx_devel_kit-master.zip
ngx_http_redis-0.3.8.tar.gz
redis2-nginx-module-master.zip
set-misc-nginx-module-master.zip
srcache-nginx-module-master.zip
echo-nginx-module-master.zip
```

* 下载地址

[ngx_devel_kit](https://github.com/simpl/ngx_devel_kit)

[ngx_http_redis](http://people.FreeBSD.org/~osa/ngx_http_redis-0.3.8.tar.gz.)

[redis2-nginx-module](https://github.com/openresty/redis2-nginx-module)

[memc-nginx-module](https://github.com/openresty/memc-nginx-module)

[set-misc-nginx-module](https://github.com/openresty/set-misc-nginx-module)

[srcache-nginx-module](https://github.com/openresty/srcache-nginx-module)

[echo-nginx-module](https://github.com/openresty/echo-nginx-module)


# 编译安装Nginx
* 模块解压
```
[root@vm03 opt]# unzip ngx_devel_kit-master.zip
[root@vm03 opt]# unzip srcache-nginx-module-master.zip
[root@vm03 opt]# tar -zxf ngx_http_redis-0.3.8.tar.gz
[root@vm03 opt]# unzip set-misc-nginx-module-master.zip
[root@vm03 opt]# unzip redis2-nginx-module-master.zip
[root@vm03 opt]# unzip echo-nginx-module-master.zip
```

* 编译安装Nginx
```
[root@vm03 ~]# tar -zxf nginx-1.10.2.tar.gz
[root@vm03 ~]# cd nginx-1.10.2
[root@vm03 nginx-1.10.2]# ./configure --prefix=/usr/local/source/nginx --with-http_ssl_module --with-http_stub_status_module --with-google_perftools_module \
> --add-module=/opt/ngx_devel_kit-master \
> --add-module=/opt/ngx_http_redis-0.3.8 \
> --add-module=/opt/redis2-nginx-module-master \
> --add-module=/opt/set-misc-nginx-module-master \
> --add-module=/opt/srcache-nginx-module-master
> --add-module=/opt/echo-nginx-module-master
[root@vm03 nginx-1.10.2]# make
[root@vm03 nginx-1.10.2]# make install
```

# redis安装和配置
```
这里省略。。。。

127.0.0.1:6379> ROLE
1) "master"
2) (integer) 13959
3) 1) 1) "172.17.100.1"
      2) "6379"
      3) "13959"
   2) 1) "172.17.100.4"
      2) "6379"
      3) "13959"
   3) 1) "172.17.100.2"
      2) "6379"
      3) "13959"
127.0.0.1:6379>

redis信息：
Master：172.17.100.3
Slave1： 172.17.100.4
Slave2： 172.17.100.1
Slave3： 172.17.100.2
```

# 模块参数讲解
## srcache-nginx-module
* srcache_fetch
```
用于http/server/location/location if段中。

语法：srcache_fetch <method> <uri> <args>
作用：发起一个Nginx子请求查询缓存。
1. 如果子请求返回的状态码不是200，则没有命中缓存。
接下来将会被ngx_http_proxy_module、ngx_http_fastcgi_module模块和其他模块处理。
2. 如果子请求返回的状态码是200，则表示命中缓存。
该模块将该子请求的响应作为当前主请求的响应直接发送给客户端。

注意：该指令将会在ngx_http_access_module运行以后才执行，因此ngx_http_access_module的allow和deny将会在该指令以前执行。
```

* srcache_fetch_skip
```
语法：srcache_fetch_skip <flag>
默认值：srcache_fetch_skip 0
作用：flag支持nginx的变量。当flag不为空并且也不等于0时，fetch进程将会无条件跳过。不会查找缓存。
```

* srcache_store
```
语法：srcache_store <method> <uri> <args>
作用：产生一个Nginx的子请求，用于保存当前主请求的响应到后端缓存中。该子请求的状态码将会被忽略。

response status line、response headers、response body将会保存到缓存中，下列特殊的response headers字段不会被保存到缓存中：
* Connection
* Keep-Alive
* Proxy-Authenticate
* Proxy-Authorization
* TE
* Trailers
* Transfer-Encoding
* Upgrade
* Set-Cookie

注意：虽然响应数据会立即发送，但是必须等待srcache_store子请求完成，nginx的主请求才会完成。
```

* srcache_store_max_size
```
语法：srcache_store_max_size <size>
默认值：srcache_store_max_size 0
作用：当response body的大小超过该size，该模块不会将response body存储到缓存中。
当后端缓存服务器对存储数据的大小有限制时，该选项比较有用。

memcache的字符串的最大长度是1MB，redis字符串的最大长度是512MB

0 表示不作限制检查。
```

* srcache_store_skip
```
语法：srcache_store_skip <flag>
默认值：srcache_store_skip 0
作用：flag支持nginx的变量。当flag不为空并且也等于0时，store进程将会无条件跳过。不会存储到缓存中。
```

* srcache_store_statuses
```
语法：srcache_store_statuses <status1> <status2> ...
默认值：srcache_store_statuses 200 301 302
作用：定义什么样的响应状态码才会被缓存。
默认是200、301和302，其他的状态码将跳过srcache_store。
```

* srcache_store_ranges
```
语法：srcache_store_ranges on|off
默认值：srcache_store_ranges off
作用：当设置为on时，srcache_store也可以存储被ngx_http_range_filter_module模块产生的206(部分内容响应)到缓存中。
如果启用的话，需要在cache key中指定$http_range。

如：
location / {
     set $key "$uri$args$http_range";
     srcache_fetch GET /memc $key;
     srcache_store PUT /memc $key;
}
```

* srcache_header_buffer_size
```
语法：srcache_header_buffer_size <size>
默认值：srcache_header_buffer_size 4k|8k
作用：指定srcache_store存储的response header的header buffer的大小。默认是页面大小。
```

* srcache_store_hide_header
```
语法：srcache_store_hide_header <header>
作用：默认情况下，该模块缓存除下列response header之外的所有response header：
Connection
Keep-Alive
Proxy-Authenticate
Proxy-Authorization
TE
Trailers
Transfer-Encoding
Upgrade
Set-Cookie

如果不想缓存其他的响应头，则可以使用该命令(忽略大小写)。
如：srcache_store_hide_header last-modified;

该指令在一个location可以配置多次。
```

* srcache_store_pass_header
```
语法：srcache_store_pass_header <header>
作用：默认情况下，该模块缓存除下列response header之外的所有response header：
Connection
Keep-Alive
Proxy-Authenticate
Proxy-Authorization
TE
Trailers
Transfer-Encoding
Upgrade
Set-Cookie

可以用该命令强制其存储指定的response header，在一个location中可以配置多次该指令。
```

* srcache_methods
```
用于http、server和location段中。

语法：srcache_methods <method>
默认值：srcache_methods GET HEAD
作用：指定srcache_fetch和srcache_store所允许使用的HTTP请求方式。
如果HTTP方式没有在这里面列出，则完全跳过cache。

允许的HTTP方式如下：GET/HEAD/POST/PUT/DELETE。GET和HEAD总是包括在该列表中，不管有没有定义。

注意：HEAD请求会被srcache_store跳过，因为对HEAD请求的响应不包括response body。
```

* srcache_ignore_content_encoding
```
语法：srcache_ignore_content_encoding on|off
默认值：srcache_ignore_content_encoding off
作用：当设置为off时，在response header中的Content-Encoding如果非空，在srcache_store不会将整个响应头存储到缓存中，并且在nginx的error.log中会产生一条错误信息。

如果设置为on，则会忽略response header中的Content-Encoding字段。

通常情况下，推荐后端服务器关闭gzip/deflate，在nginx.conf中配置：
proxy_set_header  Accept-Encoding  "";
```

* srcache_request_cache_control
```
语法：srcache_request_cache_control on|off
默认值：srcache_request_cache_control off
作用：当设置为on时，请求头中的Cache-Control 和 Pragma字段将会按照如下方式处理：
1. srcache_fetch：当请求头中有Cache-Control: no-cache 和/或 Pragma: no-cache时，将不会查找缓存。
2. srcache_store：当请求头中有Cache-Control: no-store时，不会存储到缓存中。
```

* srcache_response_cache_control
```
语法：srcache_response_cache_control on|off
默认值：srcache_response_cache_control on
作用：当设置为on时，response header中的Cache-Control和Expires字段将会按照如下方式处理：
1. Cache-Control: private 将会跳过srcache_store
2. Cache-Control: no-store 将会跳过srcache_store
3. Cache-Control: no-cache 将会跳过srcache_store
4. Cache-Control: max-age=0 将会跳过srcache_store
5. Expires: <date-no-more-recently-than-now> 将会跳过srcache_store
```

* srcache_default_expire
```
语法：srcache_default_expire <time>
默认值：srcache_default_expire 60s
作用：如果在response header中既没有指定Cache-Control: max-age=N,也没有指定Expires时，将会指定一个默认的过期时间。
默认过期时间是变量$srcache_expire的值。

该参数的默认单位是秒，也可以指定如下值：
s：秒
ms：毫秒
y：年
M：月
w：周
d：天
h：小时
m：分钟

如：srcache_default_expire 30m;
该时间必须小于597小时。0表示永远不过期。
```

* srcache_max_expire
```
语法：srcache_max_expire <time>
默认值：srcache_max_expire 0
作用：指定最大过期时间。该指令设置的时间优先于其他过期时间的计算。
最大过期时间的值是$srcache_expire的值。
```

* 变量
```
1. $srcache_expire
该值的计算方式如下：
* 当response header中指定了Cache-Control: max-age=N，则N的值将会作为该变量的值。
* 如果response header中指定了Expires，则该变量的值为:Expires的时间戳减去当前时间戳。
* 如果response header中既没有Cache-Control也没有Expires，则使用srcache_default_expire的值作为该变量的值。

如果上述算法计算得到的值大于srcache_default_expire的值，则最终srcache_expire变量的值是srcache_default_expire的值。

2. $srcache_fetch_status
该变量指定是否从缓存中获取数据。状态有：HIT、MISS、BYPASS

3. $srcache_store_status
该变量指定后端响应是否存储到了缓存中。状态有：STORE、BYPASS
```

* 注意事项
```
1. 在某些系统上，如果启用了aio或sendifle，可能会使srcache_store停止工作。因此需要在启用了srcache_store的location中禁用aio或sendfile。
2. 推荐关闭后端服务器的gzip压缩，使用nginx的gzip模块做这个工作。如果使用了nginx的proxy模块，则推荐使用如下方式：
proxy_set_header  Accept-Encoding  "";
3. 在使用srcache模块的location中，不要使用rewrite模块的if指令。
可以用nginx的map模块或nginx的lua模块，结合srcache_store_skip和srcache_fetch_skip指令。
```


## set-misc-nginx-modules
* 说明
```
该模块是对http rewrite模块的扩展。
```

* set_if_empty
```
用于location和location if段中

语法1：set_if_empty $dst <src>
语法2：set_if_empty $dst
作用：如果变量$dst的值为空，则将其设置为src.
```

* set_unescape_uri
```
语法1：set_unescape_uri <$dst> <src>
语法2：set_unescape_uri <$dst>
作用：将src的值赋值给变量$dst.该命令不会对src进行转义。

示例：
Nginx的参数：$arg_PARAMETER会保存原始的URI的参数值.
使用set_unescape_uri则表示不对其进行转义。

location /hello {
    default_type text/html;
    set $test $arg_test;
    set_unescape_uri $test;
    echo $test;
}
当访问的的是/hello?test=hello+world时，返回的将是hello world，如果不使用set_unescape_uri时，将返回hello+world
```

* set_escape_uri
```
语法1：set_escape_uri <$dst> <src>
语法2：set_escape_uri <$dst>
作用：对uri进行转义，并将其赋值给$dst
```

* set_encode_base32
```
语法1：set_encode_base32 <$dst> <src>
语法2：set_encode_base32 <$dst>
作用：对src使用base32进行编码。
```

* set_base32_padding
```
语法：set_base32_padding on|off
默认值：on
作用：是否对使用base32编码的字符在其右边使用‘=’进行填充。
```

* set_decode_base32
```
语法1：set_decode_base32 <$dst> <src>
语法2：set_decode_base32 <$dst>
作用：使用base32进行解码。
```

* set_encode_base64
```
语法1：set_encode_base64 <$dst> <src>
语法2：set_encode_base64 <$dst>
作用：使用base64进行编码
```

* set_decode_base64
```
语法1：set_decode_base64 <$dst> <src>
语法2：set_decode_base64 <$dst>
作用：使用base64进行解码
```

* set_encode_hex和set_decode_hex
```
语法1：set_encode_hex $dst <src> | set_decode_hex $dst <src>
语法2：set_encode_hex $dst | set_decode_hex $dst
作用：使用16进制进行编码和解码
```

* set_md5和set_sha1
```
语法1：set_md5 $dst <src> | set_sha1 $dst <src>
语法2：set_md5 $dst | set_sha1 $dst
作用：使用md5和sha1的方式进行编码。
```

## ngx_http_redis
* redis_pass
```
用于http/server/location段中

语法：redis_pass [name:port]
作用：后端redis服务器的地址和端口。
```

* redis_bind
```
语法：redis_bind [addr]
作用：连接redis服务器的源地址。
```

* redis_connect_timeout
```
语法：redis_connect_timeout [time]
默认值：redis_connect_timeout 60000;
作用：连接redis服务器的超时时间。单位是毫秒。1s=1000ms
```

* redis_read_timeout
```
语法：redis_read_timeout [time]
默认值：redis_read_timeout 60000;
作用：从redis读取数据的超时时间。单位是毫秒。
```

* redis_send_timeout
```
语法：redis_send_timeout [time]
默认值：redis_send_timeout 60000
作用：发送数据到redis的超时时间。单位是毫秒。
```

* redis_buffer_size
```
语法：redis_buffer_size [size]
默认值：redis_buffer_size 4096|8192
作用：接收和发送数据的buffer大小。单位是字节。
```

* redis_next_upstream
```
语法：redis_next_upstream [error timeout invalid_response not_found off]
默认值：redis_next_upstream error timeout
作用：redis_pass指定的是upstream，什么条件下应该将请求转发到其他的upstream中的redis服务器。
```

* 变量
```
1. $redis_key：redis的key。
2. $redis_db：redis的database号。该模块对于0.3.4版本，需要该参数，对于0.3.4以上的版本，不是强制性的，默认是0.
```

## redis2-nginx-module
* 说明
```
该模块几乎实现了redis2.0协议。nginx对redis的访问实现了非阻塞模式。

如果要使用redis的get命令，可以用ngx_http_redis模块。因为它返回的是解析后的内容，而不是原始内容。
```

* redis2_query
```
用于location 和location if段中。
语法：redis2_query <cmd> <arg1> <arg2> ...
作用：类似于redis-cli的方式使用该命令。

示例：
location = /pipelined {
     redis2_query set hello world;
     redis2_query get hello;

     redis2_pass 127.0.0.1:$TEST_NGINX_REDIS_PORT;
 }
```

* redis2_pass
```
语法1: redis2_pass <upstream_name>
语法2: redis2_pass <host>:<port>
作用：指定redis服务器的地址。
```

* redis2_connect_timeout
```
语法：redis2_connect_timeout <time>
默认值：redis2_connect_timeout 60s
作用：连接redis服务器的超时时间。默认单位是秒。单位可以是：s、ms、y、M(month)、d、h、m(minutes)
```

* redis2_send_timeout
```
语法：redis2_send_timeout <time>
默认值：redis2_send_timeout 60s
作用：发送TCP请求到redis服务器的超时时间。默认单位是秒。
```

* redis2_read_timeout
```
语法：redis2_read_timeout <time>
默认值：redis2_read_timeout 60s
作用：从redis服务器读取TCP响应的超时时间。默认单位是秒。
```

* redis2_buffer_size
```
语法：redis2_buffer_size <size>
默认值:redis2_buffer_size 4k|8k
作用：用于读取redis响应的buffer大小。
```

* redis2_next_upstream
```
语法：redis2_next_upstream [ error | timeout | invalid_response | off ]
默认值：redis2_next_upstream error timeout
作用：定义什么情况下，才会将redis请求转发到其他的redis服务器。
```


# Nginx配置
```
        location / {
                set $key $host$request_uri$is_args$args;
                set_escape_uri $escaped_key $key;

                srcache_fetch GET /redis $key;
                srcache_store PUT /redis2 key=$escaped_key&exptime=$srcache_expire;
                srcache_default_expire 1h;

                add_header X-Cache-From $srcache_fetch_status;
                add_header X-Cache-Store $srcache_store_status;
                add_header X-Key $key;
                add_header X-Expire $srcache_expire;
                proxy_pass http://www;
        }

         location = /redis {
                internal;
                set_md5 $redis_key $args;
                redis_pass redis;
        }

        location = /redis2 {
                internal;

                set_unescape_uri $exptime $arg_exptime;
                set_unescape_uri $key $arg_key;
                set_md5 $key;

                redis2_query set $key $echo_request_body;
                redis2_query expire $key $exptime;
                redis2_pass redis;
        }

说明：
1. location /redis：这个location的作用是到redis中获取$redis_key的值。
2. location /redis2：这个location的作用是通过redis2_query设置key和expire
3. 这里之所用用了两个redis模块，是因为ngx_http_redis模块get显示的更友好。

```