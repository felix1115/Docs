# Telegraf介绍
```
Telegraf是一个用于收集和报告metric的服务插件。
可以收集系统的各种metric，以及从第三方的API获取metric，甚至可以从statsd和Kafka获取各种metric。
并且可以通过输出插件将metric发送到各种数据存储，如influxDB、graphite、openTSDB、Datadog、Kafka、MQTT、NSQ等等。
```

* Telegraf的特点
```
1. 采用GO语言编写，没有其他外部依赖。
2. 内存占用小。
3. 基于插件的，可以很容易的添加一些input和output插件。
```

# 安装Telegraf
```
注意：需要NTP同步时间


下载地址：https://portal.influxdata.com/downloads#telegraf

[root@vm07 ~]# yum localinstall -y telegraf-1.2.1.x86_64.rpm

[root@vm07 ~]# chkconfig telegraf on
[root@vm07 ~]#
```

# telegraf的使用
```
config：输出完整的telegraf配置到标准输出。
version：显示telegraf的版本信息。

--config：要载入的telegraf的配置文件。
--test：收集一次metric，并输出到标准输出，然后退出。
--config-directory：包含有*.conf配置文件的目录。
--input-filter：需要开启的输入插件。多个插件使用:(冒号)隔开。如cpu:mem:disk
--output-filter：需要开启 的输出插件。多个插件使用:(冒号)隔开。
--usage：显示插件的使用方法，如telegraf --usage cpu
--quiet：安静模式
```

## 示例
```
1. 产生一个telegraf配置文件
telegraf config > telegraf.conf

2. 产生一个含有指定输入插件和指定输出插件的配置文件
telegraf --input-filter cpu --output-filter influxdb config

3. 测试在配置文件中定义的所有插件
telegraf --config telegraf.conf --test

4. 运行在telegraf配置文件中定义的所有插件
telegraf --config telegraf.conf

5. 运行指定的输入插件和输出插件
telegraf --config telegraf.conf --input-filter cpu:mem --output-filter influxdb

6. 测试插件的输出内容
[root@vm07 ~]# telegraf --input-filter cpu:mem --test
2017/02/20 09:57:52 I! Using config file: /etc/telegraf/telegraf.conf
* Plugin: inputs.mem, Collection 1
> mem,host=vm07.felix.com free=731623424i,cached=95502336i,buffered=14024704i,active=131391488i,used_percent=18.19474652835871,total=1028235264i,available=841150464i,used=187084800i,inactive=81907712i,available_percent=81.8052534716413 1487555872000000000
* Plugin: inputs.cpu, Collection 1
[root@vm07 ~]#
```