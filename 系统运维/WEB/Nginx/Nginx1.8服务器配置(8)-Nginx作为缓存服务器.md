# 缓存介绍
## 缓存说明
一个使用缓存的站点，会监听客户端向服务器端发出的请求，并保存服务器端的响应，如静态的CSS、JS、HTML页面以及图片等，如果有其他的客户端访问同一个URL，则可以直接使用缓存的内容对客户端进行响应，而不用再次向源服务器发出请求。

## 缓存的种类
1. 浏览器缓存

* Expires
```
Expires是web服务器响应头中的字段，在响应HTTP请求时，告诉浏览器在Expires所指定的时间前可以直接从浏览器缓存获取数据，而无需再次请求。

HTTP响应头中Date字段表示消息发送的时间。

Expires是HTTP 1.0的规定，在HTTP 1.1中基本忽略。

如果Expires中日期比当前日期早，也不会缓存。
```

* Cache-Control
```
Cache-Control和Expires的作用一致，都是指明当前资源的有效期，控制浏览器是直接从浏览器缓存中取数据，还是重新发送请求道服务器端取数据。只不过Cache-Control的选择更多，设置更细致。如果同时设置的话，其优先级高于Expires。

Cache-Control的值可以是：public、private、no-cache、no- store、no-transform、must-revalidate、proxy-revalidate、max-age

私有缓存:单个浏览器。
公有缓存:公用的缓存服务器。如proxy、squid等

1. public。 响应会被缓存，并且在多用户间共享。正常情况, 如果要求 HTTP 认证,响应会自动设置为private.
2. private。响应只能够作为私有的缓存(e.g., 在一个浏览器中)，不能再用户间共享。
3. no-cache。响应不会被缓存,而是实时向服务器端请求资源。这一点很有用，这对保证HTTP认证能够严格地禁止缓存以保证安全性很有用（这是指页面与public结合使用的情况下）.既没有牺牲缓存的效率，又能保证安全。
4. no-store。在任何条件下，响应都不会被缓存，并且不会被写入到客户端的磁盘里，这也是基于安全考虑的某些敏感的响应才会使用这个。
5. max-age。指定资源最多可以被缓存多长时间。单位是秒。
    max-age>0，直接从浏览器缓存中获取数据。
    max-age<=0，向服务器发送http请求，确认该资源是否有修改。如果有修改，则服务器返回200，没有修改的话，则返回304
6. s-maxage：类似于max-age, 但是它只用于公共缓存。
7. must-revalidate：响应在特定条件下会被重用，以满足接下来的请求，但是它必须到服务器端去验证它是不是仍然是最新的。
```

* Last-Modified/If-Modified-Since
```
Last-Modified/If-Modified-Since要配合Cache-Control使用。

1. Last-Modified：表示这个响应资源的最后修改时间。web服务器在响应请求时，告诉浏览器资源的最后修改时间。
2. If-Modified-Since：当资源过期时（使用Cache-Control标识的max-age），发现资源具有Last-Modified声明，则再次向web服务器请求时带上头 If-Modified-Since，表示请求时间。web服务器收到请求后发现有头If-Modified-Since 则与被请求资源的最后修改时间进行比对。若最后修改时间较新，说明资源又被改动过，则响应整片资源内容（写在响应消息包体内），HTTP 200；若最后修改时间较旧，说明资源没有修改，则响应HTTP 304，告知浏览器继续使用所保存的cache。
```

* Etag/If-None-Match
```
Etag/If-None-Match也要配合Cache-Control使用。

1. Etag：web服务器响应请求时，告诉浏览器当前资源在服务器的唯一标识（生成规则由服务器端定义）。Apache中，ETag的值，默认是对文件的索引节（INode），大小（Size）和最后修改时间（MTime）进行Hash后得到的。
2. If-None-Match：当资源过期时（使用Cache-Control标识的max-age），发现资源具有Etage声明，则再次向web服务器请求时带上头If-None-Match （Etag的值）。web服务器收到请求后发现有头If-None-Match 则与被请求资源的相应校验串进行比对，决定返回200或304。
```

* 既生Last-Modified何生Etag？
```
你可能会觉得使用Last-Modified已经足以让浏览器知道本地的缓存副本是否足够新，为什么还需要Etag（实体标识）呢？HTTP1.1中Etag的出现主要是为了解决几个Last-Modified比较难解决的问题：

1. Last-Modified标注的最后修改只能精确到秒级，如果某些文件在1秒钟以内，被修改多次的话，它将不能准确标注文件的修改时间
2. 如果某些文件会被定期生成，但有时内容并没有任何变化，但Last-Modified却改变了，导致文件没法使用缓存
3. 有可能存在服务器没有准确获取文件修改时间，或者与代理服务器时间不一致等情形

Etag是服务器自动生成或者由开发者生成的对应资源在服务器端的唯一标识符，能够更加准确的控制缓存。Last-Modified与ETag是可以一起使用的，服务器会优先验证ETag，一致的情况下，才会继续比对Last-Modified，最后才决定是否返回304。
```


# Nginx作为反向代理的缓存服务器
* proxy_cache
```
用于http、server、location段中。
语法格式：proxy_cache <zone> | off
默认值：proxy_cache off
作用：定义一个用于缓存的共享内存区域。同一个zone可以用于多个地方。
off：表示关闭从前一个配置等级继承的配置。
```

* proxy_cache_key
```
用于http、server、location段中。
语法格式：proxy_cache_key <srting>
默认值：proxy_cache_key $scheme$proxy_host$request_uri;
作用：定义一个用于缓存的key。

cache key的计算：
[root@vm3 nginx18]# echo -n "httpbackend/index.html" | md5sum 
4268fed9113c314a33779cb473240a9b  -
[root@vm3 nginx18]#

说明：levels=2:2:2
红色表示一级目录结构。
黄色表示二级目录结构。
蓝色表示三级目录结构。
```

![Nginx缓存目录结构](https://github.com/felix1115/Docs/blob/master/Images/nginx_cache-1.png)



* proxy_cache_path
```
用于http段中。
语法格式：
    proxy_cache_path path [levels=levels] [use_temp_path=on|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time];

作用：为要缓存的内容指定一个路径和其他参数。将会对访问的内容使用MD5函数计算出来的结果作为缓存的key。

* levels表示缓存等级，从1到3，最多三级，每一个级别可以接受的值是1或者2.如levels=2:2:2.  

levels配置示例：proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;

说明：首先写入到缓存中的响应首先被写到临时文件中去，并对这个临时文件进行重命名。当Nginx 0.8.9版本开始，临时文件和缓存可以不在同一个文件系统，这时将会采用复制的方式在两个文件系统中复制数据，而不是直接重命名。还是推荐临时文件和缓存位于同一个文件系统。从1.7.10开始，临时文件的位置可以用use_temp_path进行设置，如果省略该参数或者设置为on，则proxy_temp_path指令指定的位置将会被使用，如果该值设置为off，则临时文件和缓存将会直接放在缓存目录下。

* keys_zone指定了所有活跃的key和相关数据信息存储的zone和内存大小。1M的zone可以存储大约8千个key。

* 删除缓存数据。inactive参数表示在该时间内，如果被缓存的数据没有被访问，则该数据将会从缓存中移除，而不管他们的新鲜度。默认是10分钟。如inactive=10m;

* 删除缓存数据。特殊的"cache manager"进程会监视所缓存的内容是否已经达到了max_size参数所设置的最大缓存大小。当超过该值时，将会采用迭代的方式将最近最少使用的数据删除。在一个迭代期间，最多不会删除manager_files所定义的文件个数(默认是100)。迭代周期被manager_threshold参数所定义(默认是200毫秒),在两个迭代间隔会暂停manager_sleep所定义的时间(默认是50毫秒)。

* 载入缓存数据。一分钟后，将会激活特殊的"cache loader"进程。该进程会从文件系统上载入以前的缓存数据到cache zone里面。加载也是在迭代中完成的，在一个迭代期间不会加载loader_files所定义的文件数(默认为100),迭代周期是使用load_threshold所定义(默认为200毫秒),在两个迭代间隔会暂停load_sleep所定义的时间(默认为50毫秒)。

下列功能出现在Nginx Plus产品中：
* purger=on|off：默认是off。当设置为on时，将会激活特殊的"cache purger"进程，将会采用迭代的方式对匹配proxy_cache_purge所定义的内容的cache key进行删除。

* purger_files=<number>：默认值是10.在一个迭代周期内，设置被扫描的条目数。

* purger_threshold=<number>：默认为50毫秒。设置迭代周期时间。

* purger_sleep=<number>：默认为50毫秒。设置迭代间隔。
```

* proxy_cache_purge
```
用在Nginx Plus版本中。可以通过第三方模块来实现。
用于http、server、location段中。
语法格式：proxy_cache_purge <string> ...
作用：定义清除缓存的条件。当所定义的string至少有一个值不为空并且也不为0时，匹配到的key将会移除。移除成功则会返回204(No Content)响应。
```

* proxy_cache_revalidate
```
用于http、server、location段中。
默认值：proxy_cache_revalidate off
作用：如果客户端的请求项已经被缓存过了，但是在缓存控制头部中定义为过期，那么NGINX就会在GET请求中包含If-Modified-Since和If-None-Match字段，发送至服务器端。这项配置可以节约带宽，因为对于NGINX已经缓存过的文件，服务器只会在该文件请求头中Last-Modified记录的时间内被修改时以及ETag变更时才将全部文件一起发送，否则，则发送304响应码。
```

* proxy_cache_bypass
```
用于http、server、location段中。
语法格式：proxy_cache_bypass <string> ...
作用：定义响应不会被缓存的条件。如果string参数中至少一个值不为空并且也不为0时，响应将不会被缓存。

示例：
proxy_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
proxy_cache_bypass $http_pragma    $http_authorization;
```

* proxy_cache_convert_head
```
用于http、server、location段中。在版本1.9.7及其以上版本可用。
默认值：proxy_cache_convert_head on;
作用：是否将head请求方式转为get请求方式。如果设置为off，则需要proxy_cache_key中增加$request_method.
```

* proxy_cache_lock
```
用于http、server、location段中。
默认值：proxy_cache_lock off;
作用：该选项被启用时，当多个客户端请求一个缓存中不存在的文件（或称之为一个MISS），只有这些请求中的第一个被允许发送至服务器。其他请求在第一个请求得到满意结果之后在缓存中得到文件或者是缓存锁被释放。如果不启用proxy_cache_lock，则所有在缓存中找不到文件的请求都会直接与服务器通信。
```

* proxy_cache_lock_timeout
```
用于http、server、location段中。
默认值：proxy_cache_lock_timeout 5s;
作用：为proxy_cache_lock设置一个时间。当该时间到期后，请求才会传递到后端服务器，但是响应不会被缓存。
```

* proxy_cache_lock_age
```
用于http、server、location段中。
默认值：proxy_cache_lock_age 5s;
作用：在指定的时间内，当最后一个请求传递到后端服务器没有构建缓存条目，可能会再次发送一个请求到后端服务器。
```

* proxy_cache_methods
```
用于http、server、location段中。
默认值：proxy_cache_methods GET HEAD;
作用：如果客户端的请求方法已经在该指令中列出，则相应会被缓存。GET和HEAD总是被添加到该指令中。
```

* proxy_cache_min_uses
```
用于http、server、location段中。
默认值：proxy_cache_min_uses 1
作用：设置多少个请求以后获取到的响应才会被缓存。
如设置为10，则10个请求以后获取的响应才会被缓存。
```

* proxy_cache_use_stale
```
用于http、server、location段中。
语法格式：
    proxy_cache_use_stale error | timeout | invalid_header | updating | http_500 | http_502 | http_503 | http_504 | http_403 | http_404 | off ...;
默认值：proxy_cache_use_stale off;
作用：当和后端服务器通信出现错误的情况下，在哪种情况下可以使用陈旧的缓存条目。这个指令的参数和proxy_next_upstream的参数意思一致。

updating：当缓存正在更新的时候，允许使用陈旧的缓存内容响应客户端。当正在更新缓存数据时，允许使用陈旧的缓存内容的目的是为了最小化的减少访问后端服务器的次数。

```

* proxy_cache_valid
```
用于http、server、location段中。
语法格式：proxy_cache_valid [code ...] <time>;
作用：为不同的响应码设置不同的缓存时间。

示例1：
proxy_cache_valid 200 302 10m;
proxy_cache_valid 404      1m;
为200和302的响应码缓存10分钟，为404的响应码缓存1分钟。

示例2：
proxy_cache_valid 5m;
只有200、301和302的响应码会被缓存5分钟。

示例3：
proxy_cache_valid 200 302 10m;
proxy_cache_valid 301      1h;
proxy_cache_valid any      1m;
为200和302的响应码缓存10分钟，301的状态码缓存1小时，其他任何响应码缓存1分钟。


也可以直接在响应头中指定缓存参数，直接设置缓存参数比使用该指令具有更高的优先级。
1. X-Accel-Expires：设置响应的缓存时间。单位是秒。0表示对响应关闭缓存。如果该值以@开始，则该时间是距离1970年1月1日所经过的秒数，也就是响应可以被缓存的最大时间。
2. 如果头部没有X-Accel-Expires字段，如果有Expires、Cache-Control字段也可以缓存。
3. 如果有Set-Cookie字段，则不会被缓存。
4. 如果有Vary字段，并且值为*，则不会被缓存。如果有Vary字段，并且是其他值，根据请求头中的字段值，也将会被缓存。
```

* proxy_no_cache
```
用于http、server、location段中。
语法格式：proxy_no_cache <string> ...
作用：定义响应不会被缓存的条件。如果string参数中至少一个值不为空并且也不为0时，响应将不会被缓存。

示例：
proxy_no_cache $cookie_nocache $arg_nocache$arg_comment;
proxy_no_cache $http_pragma    $http_authorization;
```