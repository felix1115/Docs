# 安装redis模块
```
pip2.7 install redis
```

# redis模块的使用
* 创建连接池
```
In [1]: import redis
In [4]: pool = redis.ConnectionPool(max_connections=1000, host='172.17.100.3', port=6379, db=0)

In [5]:
```

* 创建redis实例
```
In [6]: redis_instance = redis.Redis(connection_pool=pool)

In [7]:

或者是在没有创建连接池的情况下创建redis实例：
In [7]: r = redis.Redis(host='172.17.100.3', port=6379, db=0)

In [8]:
```

* 简单操作
```
In [11]: redis_instance.set('userName', 'felix.zhang')
Out[11]: True

In [12]: redis_instance.get('userName')
Out[12]: 'felix.zhang'

In [13]:
```

# pipeline
```
pipeline允许在一个请求中执行多个redis命令。
通过pipeline可以减少在客户端和服务器端来回传输的TCP包的时间，提高所要执行的一组命令的性能。

pipeline是基本的redis类的子类。
```

* 创建Pipeline实例
```
In [14]: pipe = redis_instance.pipeline()

In [15]:
```

* 通过pipeline执行命令
```
In [17]: pipe.set('name', 'felix.zhang')
Out[17]: Pipeline<ConnectionPool<Connection<host=172.17.100.3,port=6379,db=0>>>

In [18]: pipe.get('userName')
Out[18]: Pipeline<ConnectionPool<Connection<host=172.17.100.3,port=6379,db=0>>>

In [19]: pipe.execute()
Out[19]: [True, 'felix.zhang']

In [20]:

说明：
1. pipe.execute()：执行在当前pipeline中的所有命令。
2. 使用pipeline执行命令时，返回的也是pipeline对象。因此可以执行链式调用。
3. pipeline默认是开启事物的。
```

* pipeline的链式调用
```
In [32]: pipe.set('username', 'felix.zhang').hset('user:1','username', 'felix').hget('user:1','username').execute()
Out[32]: [True, 1L, 'felix']

In [33]:
```