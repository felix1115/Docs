# time模块
* time.clock()
```
作用：计算程序耗时。单位是秒。
当第一次调用时，返回的是程序运行的实际时间。
当第二次调用以后，返回的是自第一次调用到这次调用的时间间隔。

示例：
[root@vm01 time]# more time01.py
#!/usr/bin/env python2.7
import time

time1 = time.clock()
a = []
for i in xrange(10000000):
    a.append(i)

time2 = time.clock()
print "%s seconds" % (time2 - time1)
[root@vm01 time]#

输出：
[root@vm01 time]# ./time01.py
1.18 seconds
[root@vm01 time]#
```

* time.time()
```
作用：返回一个自从Epoch所经过的秒数。浮点型
```

* time.localtime()
```
作用：将从Epoch所经过的秒数，转换为时间元组。如果没有指定秒数，则返回当前时间所转换的时间元组。返回的是本地时间。

时间元组：
tm_year=2016, tm_mon=12, tm_mday=14, tm_hour=12, tm_min=14, tm_sec=26, tm_wday=2, tm_yday=349, tm_isdst=0
```

* time.gmtime()
```
作用：将接受的秒数，作为一个时间元组返回。返回的是UTC时间。如果没有指定秒数，则将当前时间转换为时间元组。

In [48]: time.gmtime()
Out[48]: time.struct_time(tm_year=2016, tm_mon=12, tm_mday=14, tm_hour=4, tm_min=30, tm_sec=10, tm_wday=2, tm_yday=349, tm_isdst=0)

In [49]:
```

* time.sleep()
```
语法：time.sleep(seconds)
作用：延迟指定的秒数后执行。seconds可以是浮点数，精确到毫秒
```

* time.asctime()
```
语法：time.asctime([t])
作用：接受一个时间元组，并且以可读的形式返回。t是9个元组组成的一个时间元组。

时间元组可以通过gmtime()或者是localtime返回的时间值。
如果没有跟上任何参数，则返回当前时间。

In [49]: time.asctime(time.gmtime())
Out[49]: 'Wed Dec 14 04:30:31 2016'

In [50]: time.asctime(time.localtime())
Out[50]: 'Wed Dec 14 12:30:37 2016'

In [51]:

```

* time.ctime()
```
语法：time.ctime(seconds)
作用：将一个秒数，转换为可读形式的本地时间。

In [61]: time.ctime(100)
Out[61]: 'Thu Jan  1 08:01:40 1970'

In [62]: time.ctime()
Out[62]: 'Wed Dec 14 12:33:10 2016'

In [63]: time.asctime()
Out[63]: 'Wed Dec 14 12:33:19 2016'

In [64]: time.asctime(time.localtime())
Out[64]: 'Wed Dec 14 12:33:27 2016'

In [65]:
```

* time.strftime()
```
语法：time.strftime(format, [t])
作用：将一个时间元组转换为指定的形式。

In [100]: time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
Out[100]: '2016-12-14 13:53:36'

In [101]:
```

* time.strptime()
```
语法：time.strptime(string[, format])
作用：将给定的时间字符串，以指定的格式，将其转换为时间元组。

In [115]: time.strptime('24/Nov/2016:16:46:58', '%d/%b/%Y:%H:%M:%S')
Out[115]: time.struct_time(tm_year=2016, tm_mon=11, tm_mday=24, tm_hour=16, tm_min=46, tm_sec=58, tm_wday=3, tm_yday=329, tm_isdst=-1)

In [116]:
```

* time.mktime()
```
语法：time.mktime(tuple)
作用：将给定的时间元组转换为距离Epoch所经过的秒数。

In [120]: time.mktime(time.strptime('24/Nov/2016:16:46:58', '%d/%b/%Y:%H:%M:%S'))
Out[120]: 1479977218.0

In [121]:
```

* 总结
```
1. time.time()：返回当前时间距离Epoch所经过的秒数。
2. time.clock()：计算程序执行的耗时。
3. time.strftime(format[, tuple])：将一个时间元组转换为指定的格式。
4. time.strptime(string, format)：将一个时间字符串按照给定的格式，转换为时间元组。
5. time.localtime([seconds])：将距离Epoch所经过的秒数转换为时间元组。
6. time.gmtime([seconds])：将距离Epoch所经过的秒数转换为时间元组。UTC时间
7. time.mktime(tuple)：将一个时间元组转换为距离Epoch所经过的秒数。


示例1：时间转换成秒数
In [131]: time.mktime(time.strptime('2016-11-11 11:11:11', '%Y-%m-%d %H:%M:%S'))
Out[131]: 1478833871.0

In [132]:

示例2：秒数转换为时间
In [133]: time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(1478833871.0))
Out[133]: '2016-11-11 11:11:11'

In [134]:
```
