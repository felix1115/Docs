# Nginx SSL

> 需要在编译时，指定--with-http_ssl_module，并且需要openssl库的支持。以下参数如没有特殊指定，则用于http和server段中。


* ssl
```
默认为off。
on：开启HTTPS
off：关闭HTTPS

推荐在listen中使用ssl。如：listen 443 ssl
```

* ssl_buffer_size
```
默认值：ssl_buffer_size 16k;
作用：指定用于发送数据的缓存大小。
```

* ssl_certificate
```
作用：指定一个PEM格式的服务器证书文件的位置。
```

* ssl_certificate_key
```
作用：指定一个PEM格式的服务器私钥文件的位置。
```

* ssl_ciphers
```
默认值：ssl_ciphers HIGH:!aNULL:!MD5
作用：指定使用的ciphers。可以用openssl ciphers命令查看。
配置示例：
ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:!ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:!RC4-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!CBC:!EDH:!kEDH:!PSK:!SRP:!kECDH;
```

* ssl_protocols
```
默认值：ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
作用：指定ssl所使用的协议。有效的值有：SSLv2 、SSLv3、TLSv1、TLSv1.1、TLSv1.2。应该只设置ssl_protocols TLSv1 TLSv1.1 TLSv1.2

只有当OpenSSL的版本高于1.0.1才可以使用TLSv1.1和TLSv1.2
```

* ssl_prefer_server_ciphers 
```
默认值：ssl_prefer_server_ciphers off
作用：当使用SSLv3和TLS时，服务器端的ciphers是否可以覆盖客户端的ciphers。当使用TLS时，要指定为on。
```

* ssl_session_cache
```
语法格式：ssl_session_cache off | none | [builtin[:size]] [shared:name:size];
默认值：ssl_session_cache none;
作用：指定存储session参数的缓存类型和值。

off：session cache被严格禁止。nginx会明确的告诉客户端session不会被重用。
none：session cache通常不会被允许使用。nginx会告诉客户端session可能会被重用，但是nginx通常不会将session参数存储在缓存中。
builtin:<size>：表示使用OpenSSL内建的cache，但是该cache只能被一个worker进程使用。size指定可以存储多少个session。如果没有指定size，则等于20480个session。使用内建的cache会引起内存碎片。
shared:<name>:<size> 在所有worker进程之间共享的cache。size的大小为bytes。1M的cache可以存储大概4000个session。每一个共享的cache都有一个名字，同一个名字的cache可以用于多个虚拟主机。

配置示例：
ssl_session_cache shared:gift:10m;
```

* ssl_session_timeout
```
默认值：ssl_session_timeout 5m;
作用：客户端可以重用session参数的时间。在该事件范围内，客户端可以重用session参数。
```

# 为了减少CPU负载的推荐做法
1. 设置worker进程的数量和CPU核心数。
2. 开启keepalive
3. 开启shared session cache
4. 关闭内建的session cache
5. 增加session lifetime(默认5分钟)

# 配置示例
```
server {
    listen 443 ssl;
    server_name www.felix.com felix.com;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_certificate ssl/apache22-felix_com.crt;
    ssl_certificate_key ssl/apache22-key.pem;
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-RC4-SHA:!ECDHE-RSA-RC4-SHA:ECDH-ECDSA-RC4-SHA:ECDH-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:!RC4-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!CBC:!EDH:!kEDH:!PSK:!SRP:!kECDH;
    ssl_prefer_server_ciphers on; 

    ssl_session_cache shared:gift:10m;
    ssl_session_timeout 10m;

    location / { 
        root html;
        index index.html;
    }   
}
```