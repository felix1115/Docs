# Python自带模块的使用
## math模块
* 常用方法
```
1. 导入模块
In [1]: import math

In [2]:

2. math.pi方法
语法：math.pi
作用：返回pi的值

示例：
In [2]: math.pi
Out[2]: 3.141592653589793

In [3]:

3. math.pow方法
语法：math.pow(x,y)
作用：返回x的y次方

示例：
In [4]: math.pow(2,3)
Out[4]: 8.0

In [5]:

说明：math.pow(底数,指数)，这个方法的返回值是浮点型，pow方法的返回值是整型。

4. 自带pow方法
语法：pow(x, y[, z]) -> number
作用：计算x的y次方，如果有z，则在对z进行取余。

示例：
In [7]: pow(2,3)
Out[7]: 8

In [8]: pow(2,3,5)
Out[8]: 3

In [9]:

5. math.floor方法
作用：返回一个比给出的值小的最接近该值的浮点数。

示例：
In [18]: math.floor(3)
Out[18]: 3.0

In [19]: math.floor(3.99)
Out[19]: 3.0

In [20]:

6. math.sqrt方法
作用：返回一个数的平方根

示例：
In [31]: math.sqrt(16)
Out[31]: 4.0

In [32]: math.sqrt(4)
Out[32]: 2.0

In [33]: math.sqrt(2)
Out[33]: 1.4142135623730951

In [34]:
```

## random模块
* 常用方法
```
1. 导入模块
In [34]: import random

In [35]:

2. random.choice方法
语法：random.choice(seq)
作用：从一个给定的非空序列中随机选择一个元素。序列有：字符串、列表、元组

示例：
In [36]: random.choice('frame')
Out[36]: 'r'

In [37]: random.choice('frame')
Out[37]: 'a'

In [38]: random.choice('frame')
Out[38]: 'r'

In [39]:

3. random.random方法
语法：random.random()
作用：返回0到1之间的浮点数。包括0，不包括1.

示例：
In [93]: random.random()
Out[93]: 0.0928962250477311

In [94]: random.random()
Out[94]: 0.27448975909415363

In [95]:

4. random.randint方法
语法：random.randint(a,b)
作用：a和b为整数，返回a和b之间的随机整数。包括a和b

示例：
In [127]: random.randint(1,3)
Out[127]: 3

In [128]: random.randint(1,3)
Out[128]: 1

In [129]: random.randint(1,3)
Out[129]: 2

In [130]:

5. random.randrange
语法：random.randrange(start,stop=None,step=1)
说明：默认时step为1.
作用：返回从start到stop之间以step为步长的值，包括start，不包括stop

示例：
In [48]: random.randrange(0,5,2)
Out[48]: 4

In [49]: random.randrange(0,5,2)
Out[49]: 0

In [50]: random.randrange(0,5,2)
Out[50]: 2

In [51]:

6. 自带的range方法
语法：
    range(stop) -> list of integers
    range(start, stop[, step]) -> list of integers
作用：返回一个从start到stop之间以step为步长的列表。包括start，不包括stop。

示例：
In [52]: range(3)
Out[52]: [0, 1, 2]

In [53]: range(1,4)
Out[53]: [1, 2, 3]

In [54]: range(1,4,2)
Out[54]: [1, 3]

In [55]:
```