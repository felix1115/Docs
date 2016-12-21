# Redis列表
* 说明
```
列表类型可以存储一个有序的字符串列表。列表类型内部是使用双向链表实现的，所以向列表两端添加元素的时间复杂度为O(1)。
```

* 向列表两端增加元素
```
1. 向列表左端增加元素。LPUSH <key> <value> [value ...]。返回值表示增加后的列表的长度。
127.0.0.1:6379> LPUSH numbers 1
(integer) 1
127.0.0.1:6379> LPUSH numbers 2 3
(integer) 3
127.0.0.1:6379>

2. 向列表右端增加元素。RPUSH <key> <value> [value ...]。返回值表示增加后的列表的长度。
127.0.0.1:6379> RPUSH numbers 4
(integer) 4
127.0.0.1:6379> LRANGE numbers 0 4
1) "3"
2) "2"
3) "1"
4) "4"
127.0.0.1:6379>

```

* 从列表两端弹出元素
```
返回值是弹出的元素值。

1. 从列表左端弹出元素。LPOP <key>
127.0.0.1:6379> LPOP numbers
"3"
127.0.0.1:6379>

2. 从列表右端弹出元素。RPOP <key>
127.0.0.1:6379> RPOP numbers
"4"
127.0.0.1:6379>
```

* 获取列表中元素的个数
```
命令：LLEN

127.0.0.1:6379> LLEN numbers
(integer) 2
127.0.0.1:6379>
```

* 获取列表范围
```
命令：LRANGE <key> <start> <stop>，获取从start到stop之间的内容，包含start和stop，索引从0开始。最后一个元素为-1，倒数第二个为-2。

127.0.0.1:6379> LRANGE numbers 0 3
1) "8"
2) "7"
3) "6"
4) "5"
127.0.0.1:6379> LRANGE numbers -3 -1
1) "4"
2) "2"
3) "1"
127.0.0.1:6379>

获取所有元素：LRANGE numbers 0 -1
127.0.0.1:6379> LRANGE numbers 0 -1
1) "8"
2) "7"
3) "6"
4) "5"
5) "4"
6) "2"
7) "1"
127.0.0.1:6379>

```

* 从列表中移除指定的元素
```
命令：LREM <key> <count> <value>，作用：从列表key中删除前count个值为value的元素。返回的是值是实际删除的元素的个数。
1. 当count大于0，LREM会从列表左端删除前count个值为value的元素。
2. 当count小于0，LREM会从列表右端删除前count个值为value的元素。
3. 当count等于0，LREM会删除所有值为value的元素。
```

* 获取和设置指定索引处的值
```
1. 获取指定索引处的值。
命令：LINDEX <key> <index>

127.0.0.1:6379> LRANGE numbers 0 -1
1) "4"
2) "2"
3) "1"
127.0.0.1:6379> LINDEX numbers 0
"4"
127.0.0.1:6379> LINDEX numbers -2
"2"
127.0.0.1:6379>

2. 设置指定索引处的值。
命令：LSET <key> <index> <value>
127.0.0.1:6379> LRANGE numbers 0 -1
1) "4"
2) "2"
3) "1"
127.0.0.1:6379> LSET numbers -1 10
OK
127.0.0.1:6379> LINDEX numbers -1
"10"
127.0.0.1:6379>
```

* 只保留指定片段
```
命令：LTRIM <key> <start> <end>
作用：删除指定范围之外的所有元素。保留指定范围内的元素。

127.0.0.1:6379> LRANGE number 0 -1
 1) "9"
 2) "8"
 3) "7"
 4) "6"
 5) "5"
 6) "4"
 7) "3"
 8) "2"
 9) "1"
10) "0"
127.0.0.1:6379> LTRIM number 5 -1
OK
127.0.0.1:6379> LRANGE number 0 -1
1) "4"
2) "3"
3) "2"
4) "1"
5) "0"
127.0.0.1:6379>
```

* 向列表中插入元素
```
命令：LINSERT <key> BEFORE|AFTER <pivot> <value>
说明：LINSERT会从列表从左到右的方式查找元素pivot，然后决定是在其前面BEFORE还是后面AFTER插入元素。返回值是插入后的列表元素个数。否则返回-1

127.0.0.1:6379> LRANGE number 0 -1
1) "4"
2) "3"
3) "2"
127.0.0.1:6379> LINSERT number after 10 10
(integer) -1
127.0.0.1:6379> LRANGE number 0 -1
1) "4"
2) "3"
3) "2"
127.0.0.1:6379> LINSERT number after 3 10
(integer) 4
127.0.0.1:6379> LRANGE number 0 -1
1) "4"
2) "3"
3) "10"
4) "2"
127.0.0.1:6379>
```

* 将元素从一个列表转移到另一个列表
```
命令：RPOPLPUSH <source> <destination>

127.0.0.1:6379> LRANGE number 0 -1
1) "4"
2) "3"
3) "10"
4) "2"
127.0.0.1:6379> RPOPLPUSH number numbers
"2"
127.0.0.1:6379> LRANGE numbers 0 -1
1) "2"
127.0.0.1:6379> RPOPLPUSH number numbers
"10"
127.0.0.1:6379> RPOPLPUSH number numbers
"3"
127.0.0.1:6379> RPOPLPUSH number numbers
"4"
127.0.0.1:6379> RPOPLPUSH number numbers
(nil)
127.0.0.1:6379> LRANGE numbers 0 -1
1) "4"
2) "3"
3) "10"
4) "2"
127.0.0.1:6379> LRANGE number 0 -1
(empty list or set)
127.0.0.1:6379>
```

# Reids集合
* 说明
```
1. 集合中没有重复的元素。
2. 集合是没有顺序的。
3. 一个集合类型可以存储2的32次方减1个字符串。
```

* 增加、删除元素
```
1. 增加元素。SADD <key> <member> [member ...]
该命令会向集合中增加一个或多个元素，如果key不存在，则会自动创建。返回值表示成功加入的元素的个数。

127.0.0.1:6379> SADD letters a b c d
(integer) 4
127.0.0.1:6379> SADD letters a e
(integer) 1
127.0.0.1:6379>

2. 删除元素。SREM <key> <member> [member ...]
SREM从集合中删除一个或多个元素，返回值是成功删除的元素个数。

127.0.0.1:6379> SREM letters a f
(integer) 1
127.0.0.1:6379>
```

* 获取集合中的所有元素和判断元素是否在集合中
```
1. 获取集合中的所有元素。SMEMBERS <key>

127.0.0.1:6379> SMEMBERS letters
1) "e"
2) "c"
3) "d"
4) "b"
127.0.0.1:6379>

2. 判断元素是否在集合中。SISMEMBER <key> <member>。在里面返回1，否则返回0.
127.0.0.1:6379> SISMEMBER letters a
(integer) 0
127.0.0.1:6379> SISMEMBER letters b
(integer) 1
127.0.0.1:6379> SISMEMBER letters c
(integer) 1
127.0.0.1:6379>
```

* 集合运算
```
1. 交集。SINTER <key> [<key> ...]
127.0.0.1:6379> SADD s1 a b c d e f g
(integer) 7
127.0.0.1:6379> SADD s2 c d e f g h i
(integer) 7
127.0.0.1:6379> SADD s3 b c k
(integer) 3
127.0.0.1:6379>
127.0.0.1:6379> SINTER s1 s3
1) "b"
2) "c"
127.0.0.1:6379> SINTER s1 s2
1) "c"
2) "d"
3) "e"
4) "g"
5) "f"
127.0.0.1:6379>

2. 并集。SUNION <key> [<key> ...]
127.0.0.1:6379> SUNION s1 s3
1) "c"
2) "d"
3) "e"
4) "g"
5) "b"
6) "k"
7) "f"
8) "a"
127.0.0.1:6379>

3. 差集。SDIFF <key> [<key> ...]
127.0.0.1:6379> SDIFF s1 s3
1) "e"
2) "d"
3) "f"
4) "g"
5) "a"
127.0.0.1:6379> SDIFF s3 s1
1) "k"
127.0.0.1:6379>
```

* 获取集合中元素个数
```
127.0.0.1:6379> SCARD s1
(integer) 7
127.0.0.1:6379> SCARD s3
(integer) 3
127.0.0.1:6379>
```

* 进行集合运算并将结果保存
```
语法：
SINTERSTORE <DESTINATION_KEY> <KEY1> [<KEY2> ...]
SUNIONSTORE <DESTINATION_KEY> <KEY1> [<KEY2> ...]
SDIFFSTORE <DESTINATION_KEY> <KEY1> [<KEY2> ...]

127.0.0.1:6379> SINTERSTORE s1.3 s1 s3
(integer) 2
127.0.0.1:6379> SMEMBERS s1.3
1) "b"
2) "c"
127.0.0.1:6379>
```

* 随机获取集合中的元素
```
语法：SRANDMEMBERS <KEY> [COUNT]。count表示随机获取几个元素
说明：
1. 如果count为正数，则随机获取count个不同元素。如果count大于集合中的元素个数，则返回集合中的所有元素。
2. 如果count为负数，则随机从集合中获取count个元素，这些元素可能相同。

127.0.0.1:6379> SRANDMEMBER s1 -2
1) "e"
2) "f"
127.0.0.1:6379> SRANDMEMBER s1 -2
1) "f"
2) "f"
127.0.0.1:6379>

127.0.0.1:6379> SRANDMEMBER s1
"b"
127.0.0.1:6379> SRANDMEMBER s1 2
1) "b"
2) "g"
127.0.0.1:6379> SRANDMEMBER s1 2
1) "e"
2) "a"
127.0.0.1:6379> SRANDMEMBER s1 2
1) "b"
2) "g"
127.0.0.1:6379>
```

* 从集合中删除元素
```
命令：SPOP <key>。由于集合是无序的，因此该命令是从集合中随机弹出一个元素。返回值是弹出的元素。

127.0.0.1:6379> SPOP s1
"g"
127.0.0.1:6379> SPOP s1
"a"
127.0.0.1:6379> SPOP s1
"b"
127.0.0.1:6379>
```

# Redis有序集合
* 说明
```
1. 有序集合在集合类型的基础上为每一个元素都关联了一个分数。
2. 集合中的每个元素不能相同，但是分数却可以相同。
```

* 增加元素
```
语法：ZADD <KEY> <SCORE> <MEMBER> [SCORE MEMBER ....]
说明：SCORE不仅可以是整数，也可以是浮点数。

127.0.0.1:6379> ZADD zs1 70 yuwen 80 shuxue 90 yingyu
(integer) 3
127.0.0.1:6379>

如果发现输入有误，可以直接修改：
127.0.0.1:6379> ZADD zs1 75 shuxue
(integer) 0
127.0.0.1:6379>
```

* 获得元素的分数
```
命令：ZSCORE <KEY> <MEMBER>

127.0.0.1:6379> ZSCORE zs1 yingyu
"90"
127.0.0.1:6379>
```

* 获取元素
```
ZRANGE <KEY> <START> <STOP> [WITHSCORES]        从小到大
ZREVRANGE <KEY> <START> <STOP> [WITHSCORES]     从大到小

说明：
1. ZRANGE按照元素分数从小到大的顺序返回索引从start到stop之间的所有元素(包括元素的两端)
2. 如果加上WITHSCORES,则显示的是"元素1 分数1 元素2 分数2...."
3. 如果分数相同，则按照字典顺序返回。(0 < 9 < A < Z < a < z)

127.0.0.1:6379> ZRANGE zs1 0 -1
1) "yuwen"
2) "shuxue"
3) "yingyu"
127.0.0.1:6379> ZRANGE zs1 0 1
1) "yuwen"
2) "shuxue"
127.0.0.1:6379> ZRANGE zs1 0 -1 WITHSCORES
1) "yuwen"
2) "70"
3) "shuxue"
4) "75"
5) "yingyu"
6) "90"
127.0.0.1:6379>
```

* 获得指定分数范围内的元素
```
命令：
ZRANGEBYSCORE <key> <min> <max> [WITHSCORES] [LIMIT <offset> <count>]
ZREVRANGEBYSCORE <key> <min> <max> [WITHSCORES] [LIMIT <offset> <count>]
说明：
1. 返回分数在min和max之间的元素。(包括min和max)
2. 如果不希望不包括端点值，则可以在分数前面加上"("
3. WITHSCORES表示也显示分数。
4. LIMIT则表示从OFFSET开始，显示count个。
5. min和max还支持无穷大，-inf和+inf分别表示负无穷大和正无穷大。


127.0.0.1:6379> ZRANGEBYSCORE zs1 70 90
1) "yuwen"
2) "shuxue"
3) "yingyu"
127.0.0.1:6379> ZRANGEBYSCORE zs1 (70 90
1) "shuxue"
2) "yingyu"
127.0.0.1:6379> ZRANGEBYSCORE zs1 (70 +inf
1) "shuxue"
2) "yingyu"
127.0.0.1:6379>
```

* 增加某个元素的分数
```
命令：ZINCRBY <key> <increment> <member>
如果increment是负数，则减少。

127.0.0.1:6379> ZINCRBY zs1 10 shuxue
"85"
127.0.0.1:6379>
```

* 获得集合中元素的个数
```
命令：ZCARD <KEY>

127.0.0.1:6379> ZCARD zs1
(integer) 3
127.0.0.1:6379>
```

* 获得指定分数范围内的元素个数
```
命令：ZCOUNT <KEY> <MIN> <MAX>

127.0.0.1:6379> ZCOUNT zs1 70 90
(integer) 3
127.0.0.1:6379> ZCOUNT zs1 (70 90
(integer) 2
127.0.0.1:6379> ZCOUNT zs1 (70 (90
(integer) 1
127.0.0.1:6379>
```

* 删除一个或多个元素
```
命令：ZREM <key> <member> [member ...]
返回值是成功删除的元素的个数。

127.0.0.1:6379> ZREM zs1 yuwen shu
(integer) 1
127.0.0.1:6379>
```

* 按照排名范围删除元素
```
命令：ZREMRANGEBYANK <KEY> <START> <STOP>
说明：start和stop表示索引

127.0.0.1:6379> ZRANGE test 0 -1
1) "a"
2) "b"
3) "c"
4) "d"
5) "e"
6) "f"
7) "g"
127.0.0.1:6379> ZREMRANGEBYRANK test 0 2
(integer) 3
127.0.0.1:6379> ZRANGE test 0 -1
1) "d"
2) "e"
3) "f"
4) "g"
127.0.0.1:6379>
```

* 按照分数范围删除元素
```
命令：ZREMRANGEBYSCORE <key> <min> <max>

127.0.0.1:6379> ZRANGE test 0 -1
1) "d"
2) "e"
3) "f"
4) "g"
127.0.0.1:6379> ZREMRANGEBYSCORE test 2 5
(integer) 2
127.0.0.1:6379> ZRANGE test 0 -1
1) "f"
2) "g"
127.0.0.1:6379>
```
