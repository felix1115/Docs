# PHP的安装

[PHP安装文档](https://github.com/felix1115/Docs/blob/master/%E7%B3%BB%E7%BB%9F%E8%BF%90%E7%BB%B4/WEB/PHP/PHP5.6%E9%83%A8%E7%BD%B2(1)-%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85.md)

# FastCGI模块

> 以下指令如果没有特别说明，则用于http、server和location段中。

* fastcgi_bind
```
语法格式：fastcgi_bind <address> [transparent] | off
作用：指定一个本地用于连接FastCGI服务器的地址和可选的端口。address可以包含变量。

off：让系统自动分配地址和端口。
transparent：在Nginx 1.11版本中可用。允许指定一个非本地地址用于连接FastCGI服务器，如来自真实的客户端地址。
transparent配置示例：
fastcgi_bind $remote_addr transparent
```

* fastcgi_buffer_size
```
默认值：fastcgi_buffer_size 4k|8k;
作用：指定用于读取从FastCGI服务器收到的响应的第一部分(响应头)的缓存大小。
```

* fastcgi_buffering
```
默认值：fastcgi_buffering on;
作用：是否允许对从FastCGI服务器收到的响应进行缓存。
on：表示Nginx会尽可能快的从FastCGI服务器接收响应，并将其保存在fastcgi_buffer_size和fastcgi_buffers中。如果整个响应比较大(大于上述两个参数所设置的值)，则响应的一部分或全部会被保存在fastcgi_temp_path所设置的临时文件中。
off：如果关闭该功能，则从FastCGI服务器收到的响应会同步发送到客户端。Nginx不会试图去读取从FastCGI服务器收到的整个响应。Nginx一次可以从FastCGI服务器收到的响应的最大数据大小是通过fastcgi_busy_buffers_size所指定。
```

* fastcgi_buffers
```
语法格式：fastcgi_buffers <number> <size>
默认值：fastcgi_buffers 8 4k|8k;
作用：为单个连接设置number个size大小的缓存用于读取从FastCGI服务器收到的响应。
```

* fastcgi_busy_buffers_size
```
默认值：fastcgi_busy_buyffers_size 8k|16k;
作用：在没有读到全部响应的情况下，写缓冲到达一定大小时，nginx一定会向客户端发送响应，直到缓冲小于此值。这条指令用来设置此值。 同时，剩余的缓冲区可以用于接收响应，如果需要，一部分内容将缓冲到临时文件。该大小默认是fastcgi_buffer_size和fastcgi_buffers指令设置单块缓冲大小的两倍。
```

* fastcgi_connect_timeout
```
默认值：fastcgi_connect_timeout 60s;
作用：指定和FastCGI服务器建立连接的超时时间。不能超过75s。
```

* fastcgi_hide_header
```
语法格式：fastcgi_hide_header <field>
作用：默认情况下，对于从FastCGI服务器收到的响应，nginx不会将字段Status和X-Accel-...发送到客户端。该指令可以设置不会发送到客户端的一些额外的字段。
```

* fastcgi_ignore_client_abort
```
默认值：fastcgi_ignore_client_abort off;
作用：当客户端不想等待响应时主动关闭连接，Nginx是否要关闭和FastCGI服务器的连接。

on：表示当客户端关闭连接时，Nginx不会关闭和FastCGI服务器的连接，而是等待FastCGI发送响应。
off：表示当客户端关闭连接时，Nginx也会关闭和FastCGI服务器的连接，不等待从FastCGI发来的响应。
```

* fastcgi_ignore_headers
```
语法格式：fastcgi_ignore_headers <field> ...
作用：忽略从FastCGI服务器发来的响应中的某些字段。
下列的字段可以忽略：“X-Accel-Redirect”, “X-Accel-Expires”, “X-Accel-Limit-Rate” (1.1.6), “X-Accel-Buffering” (1.1.6), 
“X-Accel-Charset” (1.1.6), “Expires”, “Cache-Control”, “Set-Cookie” (0.8.44), and “Vary” (1.7.7)
```

* fastcgi_pass_header
```
语法格式：fastcgi_pass_header <field>
作用：允许传递fastcgi_hide_header中默认禁止的字段到客户端。
```

* fastcgi_index
```
语法格式：fastcgi_index <name>
作用：当请求的URI以“/”结尾时，将会添加到该URI的文件名。
该值是变量$fastcgi_script_name的值。

示例：
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;

注意：
1. 如果用户请求的是/page.php，则SCRIPT_FILENAME的值是：/home/www/scripts/php/page.php
2. 如果用户的请求以/结尾，则SCRIPT_FILENAME的值是：/home/www/scripts/php/index.php
```

* fastcgi_intercept_errors
```
默认值：fastcgi_intercept_errors off;
作用：当FastCGI服务器发来的响应码大于或等于300时，是否要传递到客户端，或者是被拦截，并且重定向到Nginx使用error_page指令处理。

on：表示拦截。
off：表示不拦截。
```

* fastcgi_keep_conn
```
默认值：fastcgi_keep_conn off;
作用：默认情况下，FastCGI服务器在发送完响应后，会理解关闭连接。当该指令设置为on时，Nginx将会告诉FastCGI服务器，将该连接处于打开状态。
当upstream中keepalive指令设置时，该指令要设置为on。
```

* fastcgi_limit_rate
```
默认值：fastcgi_limit_rate 0;
作用：限制Nginx从FastCGI服务器读取响应的速率。0表示没有限制。单位是bytes/s
注意：该限制是针对每一个请求的，如果Nginx到FastCGI服务器同时开启2个连接，则整个速率为2倍。需要fastcgi_buffering设置为on
```

* fastcgi_max_temp_file_size
```
默认值：fastcgi_max_temp_file_size 1024m;
作用：当fastcgi_buffering开启时，从FastCGI收到的响应会被保存到fastcgi_buffer_size和fastcgi_buffers中，如果响应太大，上述两个指令所指定的值存不下，则会将部分响应存放在临时文件中，该指令指定了临时文件的最大大小。
```

* fastcgi_temp_file_write_size
```
语法格式：fastcgi_temp_file_write_size <size>
默认值：fastcgi_temp_file_write_size 8k|16k;
作用：指定将从FastCGI服务器发来的响应写入到临时文件时，一次可用写入的大小。默认值fastcgi_buffers和fastcgi_buffer_size所指定的buffer的两倍。
```

* fastcgi_temp_path
```
语法格式：fastcgi_temp_path <path> [level1 [level2 [level3]]];
默认值：fastcgi_temp_path fastcgi_temp
作用：定义一个目录用于存储从FastCGI服务器收到的数据到临时文件中。
```

* fastcgi_next_upstream
```
语法格式
        fastcgi_next_upstream error | timeout | invalid_header | http_500 | http_503 | http_403 | http_404 | non_idempotent | off ...;
默认值：fastcgi_next_upstream error timeout;
作用：指定什么情况下， 请求会被传递到下一台服务器。

error：和FastCGI服务器建立连接出现错误、传递请求到服务器出现错误或者是读取响应头出现错误。
timeout：和和FastCGI服务器建立连接超时、传递请求到服务器超时或者是读取响应头超时。
invalid_header：FastCGI服务器返回了空的或者是无效的响应。
http_500：服务区返回500响应码。
http_503：服务区返回503响应码。
http_403：服务区返回403响应码。
http_404：服务区返回404响应码。
off：不传递请求到下一台服务器。
non_idempotent：通常情况下，当请求已经传递到FastCGI服务器时，对于非幂等的请求(POST/LOCK/PATCH)，当出现错误时是不会传递到下一台FastCGI服务器的。启用该选项，则告诉Nginx要重试该请求。

注意：传递请求到下一台服务器，仅仅发生在还没有向客户端发送任何响应。如果在发送响应期间出现error或timeout，则传递请求到下一台服务器是不可能的。

不成功的尝试(不管在该选项中有没有指定)：error、timeout、invalid_header
不成功的尝试(需要在该选项中指定)：http_500、http_503
http_403和http_404不会考虑成不成功的尝试。
```

* fastcgi_next_upstream_timeout
```
默认值：fastcgi_next_upstream_timeout 0;
作用：限制请求传递到下一台服务器的时间。0表示关闭该限制。
```

* fastcgi_next_upstream_tries
```
默认值：fastcgi_next_upstream_tries 0;
作用: 限制将请求传递到下一个服务器的尝试次数。0表示关闭该限制。
```

* fastcgi_pass
```
用于location和if in location段中。
语法格式：fastcgi_pass <address>
作用：设置fastcgi服务器的地址。可用指定域名或IP地址以及端口。

示例:
fastcgi_pass localhost:9000;
```

* fastcgi_read_timeout
```
默认值：fastcgi_read_timeout 60s;
作用：指定从FastCGI服务器读取响应的超时时间。

这个时间表示的是两个成功的读操作期间，而不是整个响应的传输时间。如果在该时间内，FastCGI服务器没有发送任何东西，则关闭连接。
```

* fastcgi_send_timeout
```
默认值：fastcgi_send_timeout 60s;
作用：指定发送请求到FastCGI服务器的超时时间。

这个时间表示的是两个成功的写操作期间，而不是整个请求的传输时间。如果在该时间内，FastCGI服务器没有收到任何内容，则关闭该连接。
```

* fastcgi_pass_request_headers
```
默认值：fastcgi_pass_request_headers on;
作用：是否将原始请求的请求头字段都发送到FastCGI服务器。
```

* fastcgi_pass_request_body
```
默认值：fastcgi_pass_request_body on;
作用：是否将原始请求的请求体都发送到FastCGI服务器。
```

* fastcgi_request_buffering
```
默认值：fastcgi_request_buffering on;
作用：是否为客户端的请求体启用缓存功能。

on：表示在将请求发送到FastCGI服务器之前，会读取从客户端发来的整个请求体。
off：表示当Nginx从客户端收到请求体时会立即发送到FastCGI服务器。在这种情况下，如果Nginx已经发送请求体，如果出现错误，则不会发送到下一台服务器。
```

* fastcgi_param
```
说明：HTTP请求头字段会作为参数传递到FastCGI服务器。

语法格式：fastcgi_param <parameter> <value> [if_not_empty]
作用：指定应该传递到FastCGI服务器的参数(parameter)。

if_not_empty：当value的为非空时，parameter才会传递到FastCGI服务器，否则不会传递。
value可以包含文件、变量或者是两者的组合。

示例1：PHP的最小设置
fastcgi_param SCRIPT_FILENAME /home/www/scripts/php$fastcgi_script_name;
fastcgi_param QUERY_STRING    $query_string;

示例2：if_not_empty
fastcgi_param HTTPS           $https if_not_empty;

示例3：处理POST请求的脚本，下面的3个参数是必须的。
fastcgi_param REQUEST_METHOD  $request_method;
fastcgi_param CONTENT_TYPE    $content_type;
fastcgi_param CONTENT_LENGTH  $content_length;
```

* fastcgi_split_path_info
```
语法格式：fastcgi_split_path_info <regex>
作用：定义一个正则表达式为$fastcgi_path_info变量捕获一个值。

这个正则表达式应该会捕获两个内容：第一个成为变量$fastcgi_script_name的值，第二个成为变量$fastcgi_path_info的值。

示例：
location ~ ^(.+\.php)(.*)$ {
    fastcgi_split_path_info       ^(.+\.php)(.*)$;
    fastcgi_param SCRIPT_FILENAME /path/to/php$fastcgi_script_name;
    fastcgi_param PATH_INFO       $fastcgi_path_info;

当用户请求的是/show.php/article/0001，SCRIPT_FILENAME的值为:/path/to/php/show.php, PATH_INFO的值为：/article/0001
```

# 内建变量
```
1. $fastcgi_script_name：为模块内建变量。表示请求的URI。如果URI以"/"结尾，则请求的URI为"/"和fastcgi_index指令的值之和。

2. $fastcgi_path_info：为模块内建变量。这个变量的值是fastcgi_split_path_info捕获的第二个值。该变量可以用于设置PATH_INFO参数。
```

# 其他变量
```
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;#脚本文件请求的路径  
fastcgi_param  QUERY_STRING       $query_string; #请求的参数;如?app=123  
fastcgi_param  REQUEST_METHOD     $request_method; #请求的动作(GET,POST)  
fastcgi_param  CONTENT_TYPE       $content_type; #请求头中的Content-Type字段  
fastcgi_param  CONTENT_LENGTH     $content_length; #请求头中的Content-length字段。  
  
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name; #脚本名称   
fastcgi_param  REQUEST_URI        $request_uri; #请求的地址不带参数  
fastcgi_param  DOCUMENT_URI       $document_uri; #与$uri相同。   
fastcgi_param  DOCUMENT_ROOT      $document_root; #网站的根目录。在server配置中root指令中指定的值   
fastcgi_param  SERVER_PROTOCOL    $server_protocol; #请求使用的协议，通常是HTTP/1.0或HTTP/1.1。    
  
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;#cgi 版本  
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;#nginx 版本号，可修改、隐藏  
  
fastcgi_param  REMOTE_ADDR        $remote_addr; #客户端IP  
fastcgi_param  REMOTE_PORT        $remote_port; #客户端端口  
fastcgi_param  SERVER_ADDR        $server_addr; #服务器IP地址  
fastcgi_param  SERVER_PORT        $server_port; #服务器端口  
fastcgi_param  SERVER_NAME        $server_name; #服务器名，域名在server配置中指定的server_name  
  
#fastcgi_param  PATH_INFO           $path_info;#可自定义变量  
  
# PHP only, required if PHP was built with --enable-force-cgi-redirect  
#fastcgi_param  REDIRECT_STATUS    200;  
  
在php可打印出上面的服务环境变量  
如：echo $_SERVER['REMOTE_ADDR']  

```

# 配置示例
```
http {
    upstream php {
        server 172.17.100.5:9000;

        keepalive 32;
    }
}

server {
        location ~ \.php$ {
            root "/web";
            fastcgi_pass    php;
            fastcgi_index   index.php;
            fastcgi_keep_conn on; 
            include         fastcgi.conf;
        } 
}

注意：
1. 推荐使用include fastcgi.conf
2. 指定root。告诉Nginx ，PHP脚本文件的位置。
```