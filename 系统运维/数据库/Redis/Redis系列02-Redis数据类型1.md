# Redis键
* 查看所有的键KEYS
```
命令：KEYS <key>
说明：key支持GLOB风格的通配符。
?：任一单个字符。
*：任意长度的任意字符。
[]：范围内的任意单个字符。
注意：生产环境上少用该命令。

示例：
127.0.0.1:6379> KEYS *
1) "name"
127.0.0.1:6379>

127.0.0.1:6379> KEYS nam?
1) "name"
127.0.0.1:6379>
```

* 判断键是否存在和键所对应的键值的数据类型
```
判断键是否存在：EXISTS。存在返回1，不存在返回0
127.0.0.1:6379> EXISTS name
(integer) 1
127.0.0.1:6379> EXISTS test
(integer) 0
127.0.0.1:6379>

查看键对应的键值的数据类型：TYPE
127.0.0.1:6379> TYPE name
string
127.0.0.1:6379>
```

* 键的过期时间
```
1. 为键设置过期时间。
EXPIRE <key> <seconds>
PEXPIRE <key> <milliseconds>

127.0.0.1:6379> EXPIRE name 300
(integer) 1
127.0.0.1:6379>

127.0.0.1:6379> PEXPIRE name 1000000
(integer) 1
127.0.0.1:6379> TTL name
(integer) 995
127.0.0.1:6379>

2. 查询键到期的剩余时间。 TTL <key>，返回单位是秒。如果一个键没有过期时间，则返回-1
127.0.0.1:6379> TTL name
(integer) 228
127.0.0.1:6379>

以毫秒为单位返回键的剩余时间。PTTL
127.0.0.1:6379> TTL name
(integer) 39
127.0.0.1:6379> PTTL name
(integer) 37628
127.0.0.1:6379>

3. 移除key的过期时间。 PERSIST
127.0.0.1:6379> EXPIRE name 600
(integer) 1
127.0.0.1:6379> TTL name
(integer) 596
127.0.0.1:6379> PERSIST name
(integer) 1
127.0.0.1:6379> TTL name
(integer) -1
127.0.0.1:6379>

```

* 重命名key
```
1. 不管new key存不存在都重命名。如果new key存在，则会覆盖new key。
命令：RENAME <old-key> <new-key>
127.0.0.1:6379> RENAME name test
OK
127.0.0.1:6379> get test
"felix"
127.0.0.1:6379>

2. 只有在new key不存在的情况下，才会进行重命名。返回值1表示重命名成功，0表示失败。
命令：RENAMENX <old-key> <new-key>
127.0.0.1:6379> set test 'test'
OK
127.0.0.1:6379> keys *
1) "test"
2) "name"
127.0.0.1:6379> RENAMENX name test
(integer) 0
127.0.0.1:6379> keys *
1) "test"
2) "name"
127.0.0.1:6379> RENAMENX name username
(integer) 1
127.0.0.1:6379> keys *
1) "username"
2) "test"
127.0.0.1:6379>
```

* 返回随机key
```
命令：RANDOMKEY
127.0.0.1:6379> RANDOMKEY
"username"
127.0.0.1:6379> RANDOMKEY
"test"
127.0.0.1:6379>
```

* 删除key
```
1. DEL可以删除一个或多个key。返回值表示删除key的个数。
127.0.0.1:6379> DEL test
(integer) 1
127.0.0.1:6379> DEL test
(integer) 0
127.0.0.1:6379>
```

* 返回key所对应的值得序列化版本
```
127.0.0.1:6379> DUMP test
"\x00\x06test01\a\x00\xe7h\x149A9,\xdb"
127.0.0.1:6379>
```


# Redis字符串
* 赋值和取值
```
1.赋值：SET <KEY> <VALUE>
127.0.0.1:6379> SET name 'felix'
OK
127.0.0.1:6379>

2. 取值：GET <KEY>
127.0.0.1:6379> GET name
"felix"
127.0.0.1:6379>
注意:当GET获取的key不存在时，返回(nil)
```

* 递增数字
```
注意：
1. 当key所对应的value是数字类型的字符串时，才能使用递增。否则会报错。返回的是递增后的值。
2. 如果递增的key不存在，则默认键值为0.

127.0.0.1:6379> GET number
(nil)
127.0.0.1:6379> INCR number
(integer) 1
127.0.0.1:6379> GET number
"1"
127.0.0.1:6379> INCR number
(integer) 2
127.0.0.1:6379> GET number
"2"
127.0.0.1:6379>

增加指定的整数：INCRBY <key> <INCREMENT>
127.0.0.1:6379> INCRBY number 3
(integer) 5
127.0.0.1:6379> GET number
"5"
127.0.0.1:6379> INCRBY number 3
(integer) 8
127.0.0.1:6379> GET number
"8"
127.0.0.1:6379>

增加指定的浮点数：INCRBYFLOAT <KEY> <float>
127.0.0.1:6379> INCRBYFLOAT number 3.5
"1.5"
127.0.0.1:6379> INCRBYFLOAT number 3.5
"5"
127.0.0.1:6379> INCRBYFLOAT number 3.5
"8.5"
127.0.0.1:6379>
```

* 递减数字
```
1. DECR <KEY>
127.0.0.1:6379> DECR number
(integer) 7
127.0.0.1:6379> DECR number
(integer) 6
127.0.0.1:6379>

2. 递减指定的整数。DECRBY <KEY> decrement
127.0.0.1:6379> DECRBY number 4
(integer) 2
127.0.0.1:6379> DECRBY number 4
(integer) -2
127.0.0.1:6379>
```

* 向键值得尾部追加值
```
1. 如果key不存在，则设置为value。返回的是字符串的总长度
127.0.0.1:6379> GET name
"felix"
127.0.0.1:6379> APPEND name '.zhang'
(integer) 11
127.0.0.1:6379> GET name
"felix.zhang"
127.0.0.1:6379>
```

* 获取字符串的长度
```
1. STRLEN返回键值得总长度，如果key不存在，则返回0.
127.0.0.1:6379> STRLEN name
(integer) 11
127.0.0.1:6379>
```

* 同时获得和设置多个键值
```
1. 获得多个键值。MGET <key1> [<key2> ...]
127.0.0.1:6379> MGET name test
1) "felix.zhang"
2) "test01"
127.0.0.1:6379>

2. 设置多个键值。MSET <key1> <value1> ...
127.0.0.1:6379> MSET user:1 'zhang' user:2 'wang' user:3 'li'
OK
127.0.0.1:6379> MGET user:1 user:2 user:3
1) "zhang"
2) "wang"
3) "li"
127.0.0.1:6379>
```

# Redis哈希
* 说明
```
redis以字典的形式存储数据，而hash(散列类型)的键值也是一种字典结构。其存储了字段和字段值的映射。

但是字段值只能是字符串，不支持其他数据类型。
```

* 赋值与取值
```
1. 赋值。HSET <key> <field> <value>
127.0.0.1:6379> HSET user:1 name 'felix.zhang'
(integer) 1
127.0.0.1:6379> TYPE user:1
hash
127.0.0.1:6379>

2. 取值。HGET <key> <field>
127.0.0.1:6379> HGET user:1 name
"felix.zhang"
127.0.0.1:6379>

3. 同时设置多个字段和值。HMSET <key> <field> <value> <field> <value> ...
127.0.0.1:6379> HMSET user:1 sex 'M' phone_number '18688888888' address 'Beijing changping'
OK
127.0.0.1:6379>

4. 同时获取多个字段的值。HMGET <key> <field> <field> ...
127.0.0.1:6379> HMGET user:1 name phone_number
1) "felix.zhang"
2) "18688888888"
127.0.0.1:6379>

5. 获取key的所有字段。HGETALL <key>
127.0.0.1:6379> HGETALL user:1
1) "name"
2) "felix.zhang"
3) "sex"
4) "M"
5) "phone_number"
6) "18688888888"
7) "address"
8) "Beijing changping"
127.0.0.1:6379>

注意：HSET不区分是插入操作还是更新操作，如果是插入，则返回值是1，如果是更新，则返回值是0。
```

* 判断字段是否存在
```
命令：HEXISTS <key> <field>   存在则返回1，不存在，则返回0

127.0.0.1:6379> HEXISTS user:1 sex
(integer) 1
127.0.0.1:6379> HEXISTS user:1 aihao
(integer) 0
127.0.0.1:6379>
```

* 获取字段值得长度
```
命令：HSTRLEN <key> <field>

127.0.0.1:6379> HGET user:1 name
"felix.zhang"
127.0.0.1:6379> HSTRLEN user:1 name
(integer) 11
127.0.0.1:6379> HSTRLEN user:1 fun
(integer) 0
127.0.0.1:6379>
```

* 当字段不存在时赋值
```
命令：HSETNX <key> <field> <value> 当字段存在时，不做任何操作，返回0，当字段不存在时，赋值，返回1.
127.0.0.1:6379> HSETNX user:1 name 'frame.zhang'
(integer) 0
127.0.0.1:6379> HSETNX user:1 fun 'IT'
(integer) 1
127.0.0.1:6379>
```

* 删除字段
```
命令：HDEL <key> <field> <field> ...   返回值是删除的字段数量。

127.0.0.1:6379> HDEL user:1 height
(integer) 1
127.0.0.1:6379> HDEL user:1 height
(integer) 0
127.0.0.1:6379>
```

* 获取所有的key和value
```
1. 获取所有key。HKEYS <key>
127.0.0.1:6379> HKEYS user:1
1) "name"
2) "sex"
3) "phone_number"
4) "address"
127.0.0.1:6379>

2. 获取所有value。 HVALS <key>
127.0.0.1:6379> HVALS user:1
1) "felix.zhang"
2) "M"
3) "18688888888"
4) "Beijing chaoyang"
127.0.0.1:6379>
```

* 获取字段长度
```
命令：HLEN <key>

127.0.0.1:6379> HLEN user:1
(integer) 4
127.0.0.1:6379> HKEYS user:1
1) "name"
2) "sex"
3) "phone_number"
4) "address"
127.0.0.1:6379>
```

* 字段值增加指定的值
```
1. 增加指定的整数。HINCRBY <key> <field> <number>
127.0.0.1:6379>
127.0.0.1:6379> HGET user:1 age
"28"
127.0.0.1:6379> HINCRBY user:1 age 1
(integer) 29
127.0.0.1:6379> HINCRBY user:1 age 1
(integer) 30
127.0.0.1:6379>

2. 增加指定浮点数。HINCRBYFLOAT <key> <field> <number>
127.0.0.1:6379> HSET user:1 salary '13000.00'
(integer) 1
127.0.0.1:6379> HGET user:1 salary
"13000.00"
127.0.0.1:6379> HINCRBYFLOAT user:1 salary '500.00'
"13500"
127.0.0.1:6379> HGET user:1 salary
"13500"
127.0.0.1:6379>

```


