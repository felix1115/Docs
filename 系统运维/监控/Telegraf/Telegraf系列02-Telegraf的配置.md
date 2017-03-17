
# Telegraf的配置
* 说明
```
配置文件的位置：/etc/telegraf/telegraf.conf

input：表示从哪里获取metric
output：表示将收到的metric发送到哪里。
```

## 产生一个配置文件
```
如果在/etc/telegraf目录下没有telegraf.conf，则可以采用如下方法产生一个配置文件

方法1：
[root@vm07 telegraf]# telegraf config > /etc/telegraf/telegraf.conf
[root@vm07 telegraf]#

方法2：在产生配置文件时使用--input-filter指定输入，使用--output-filter指定输出。
[root@vm07 telegraf]# telegraf --input-filter cpu:mem:swap:net --output-filter influxdb config > /etc/telegraf/telegraf.conf
[root@vm07 telegraf]#
```

## 环境变量
```
在配置文件中的任何地址都可以使用环境变量，环境变量以“$”开头。
注意：
1. 字符串类型的变量要使用双引号引起来。如"$str_var"
2. 数字和布尔型可以直接使用，不需要用双引号。如$INT_VAR, $BOOL_VAR
```

## global_tags
```
在该段中所定义的tag，格式是tag_key="tag_value"，会用于从该主机获得的所有的metric。

也就是说，从该主机获取的所有metric都会具有这里所指定的tag。
```

## agent
```
1. interval
作用：指定所有input插件收集数据的间隔。

2. round_interval
作用：是否启用轮询收集。默认是true。如果interval设置为10s，则在00/10/20等时间间隔都会收集数据。

3. metric_batch_size
作用：telegraf将会批量的将metric发送到output，该指令指定一次最多可以发送多个少个metric发送到output。

4. metric_buffer_limit
作用：当telegraf发送metric到output失败时，为每一个output最多缓存多少个metric，直到发送成功。如果buffer满的时候，最老的数据将会被删除。该值最少要是metric_batch_size的2倍。

5. collection_jitter
作用：每一个input插件在收集数据之前，随机延迟的一个时间范围。

6. flush_interval
作用：如果telegraf发送metric到output失败，则等待多长时间会再次发送。最大的flush_interva为flush_interval + flush_jitter

7. flush_jitter
作用：指定一个随机时间。

8. precision
作用：指定时间精度。就是时间精确范围。最大是1s。可以是ns、us、ms、s

9. debug
作用：是否启用debug模式。

10. quiet
作用：是否运行在安静模式，只会输出错误信息。

11. logfile
作用：指定日志文件的位置。如果为空，则为标准输出。

12. hostname
作用：指定telegraf的主机名。如果没有指定，则使用系统调用获取。

13. omit_hostname
作用：如果设置为true，则不设置host tag
```

## input配置
```
下面的参数适用于所有的输入。

1. interval
作用：收集metric的频率。如果没有指定，则使用全局的interval配置。

2. name_override
作用：覆盖默认的measurement。默认的measurement是input的名字。如input.cpu，则默认的measurement是cpu

3. name_prefix
作用：指定附加到measurement的前缀。

4. name_suffix
作用：指定附加到measurement的后缀

5. tags
作用：为input的measurement指定一些tag。格式是[input.cpu.tags]
```

## aggregator配置
```
下面的参数适用于所有的aggregator

1. period
作用：刷新和清除每一个聚合器的周期。发送的所有的metric如果超过该时间，则会被忽略。

2. delay
作用：每一个聚合器被刷新之前的延迟时间。该选项用于控制聚合器在从input插件收到数据之前所等待的时间。默认和收集数据的时间间隔一致。

3. drop_original
作用：如果为true，则原始的metric不会被聚合器发送到output插件，原始的metric会被drop掉。

4. name_override
作用：使用指定的measurement的名称覆盖掉默认的measurement名称。默认的是输出插件的名称。

5. name_prefix
作用：指定measurement的前缀。

6. name_suffix
作用：指定measurement的后缀。

7. tags
作用：应用到measurement的tag的名称。
```

## processor配置
```
1. order
作用：如果指定，则处理器将会顺序的执行，否则为随机的执行。
```

## measurement过滤
```
measurement过滤可以配置在input、output、processor、aggregator。

1. namepass
作用：用于过滤当前的input产生的metric，是由字符串组成的数组。在该数组中的每一个字符串都作为GLOB和measurement进行匹配，如果匹配，则发送相关field，否则，不发送。

2. namedrop
作用：用于过滤当前的input产生的metric，是由字符串组成的数组。在该数组中的每一个字符串都作为GLOB和measurement进行匹配，如果匹配，则不发送相关field，否则，发送。
和namepass相反

3. fieldpass
作用：用于过滤当前的input产生的metric，是由字符串组成的数组。在该数组中的每一个字符串都作为GLOB和字段名进行匹配，如果匹配，则发送该字段，否则不发送。
只能用于input插件，不能用于output插件。

4. fielddrop
作用：和fieldpass相反。
用于过滤当前的input产生的metric，是由字符串组成的数组。在该数组中的每一个字符串都作为GLOB和字段名进行匹配，如果匹配，则不发送该字段，否则发送。
只能用于input插件，不能用于output插件。

5. tagpass
作用：用于过滤当前的input产生的measurement的tag名称。由字符串组成的数组。在该数据中的每一个名称都做为GLOB名称和tag名称进行匹配，如果匹配，则该measurement不会发送，否则发送。

6. tagdrop
作用：和tagpass相反。
用于过滤当前的input产生的measurement的tag名称。由字符串组成的数组。在该数据中的每一个名称都做为GLOB名称和tag名称进行匹配，如果匹配，则该measurement会发送，否则不发送。

注意：tagpass和tagdrop必须定义在该插件参数的最后。

7. tagexclude
作用：从measurement中排除指定的tag。和tagdrop不同的是，tagdrop根据tag名称过滤掉一整个measurement，而tagexclude只会过滤掉匹配的tag，可以用在input和output插件中，推荐用在
input插件中。

8. taginclude
作用：只会在measurement中包含指定的tag，其他的tag将会drop掉。





特殊配置：tagpass和tagdrop
[[inputs.cpu]]
  percpu = true
  totalcpu = false
  fielddrop = ["cpu_time"]
  # Don't collect CPU data for cpu6 & cpu7
  [inputs.cpu.tagdrop]
    cpu = [ "cpu6", "cpu7" ]

[[inputs.disk]]
  [inputs.disk.tagpass]
    # tagpass conditions are OR, not AND.
    # If the (filesystem is ext4 or xfs) OR (the path is /opt or /home)
    # then the metric passes
    fstype = [ "ext4", "xfs" ]
    # Globs can also be used on the tag values
    path = [ "/opt", "/home*" ]

示例2：tags配置
[[inputs.cpu]]
  percpu = false
  totalcpu = true
  [inputs.cpu.tags]
    tag1 = "foo"
    tag2 = "bar"

```

## influxDB作为output的配置
```
[[outputs.influxdb]]

urls：指定influxDB的URL（HTTP API的地址）
database：收集的metric存储的database，如果不存在，则自动创建。其他的数据库需要手动创建
retention_policy：保留策略。空的字符串，则表示使用默认的RP。
write_consistency：用于influxDB集群，一致性写入。可以是any、one、quorum、all
timeout：写入数据的超时时间。默认是5s
username：连接数据库的用户名
password：连接数据库的密码。

influxDB配置示例：
> CREATE USER "telegraf" WITH PASSWORD 'telegraf123'
> CREATE DATABASE "telegraf"
> GRANT ALL PRIVILEGES ON "telegraf" TO "telegraf"
>
```