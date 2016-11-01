# ulimit配置
```
1G内存的服务器大概可以打开约10w个文件描述符。
Linux系统默认的打开的文件数是1024，在生产环境中，这个值设置的太小，如果超过该值，则会显示too many open files，

方法1：修改/etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000

方法2：修改/etc/profile文件
ulimit -n 65535
以上两种方法设置完以后，用户重新登录下就可以了，不需要重启系统。

方法3：临时设置（只会对当前设置有效）
[root@vm3 tcmalloc]# ulimit -SHn 1000000
[root@vm3 tcmalloc]#
```

# main区块设置
```
user <user> [group]：指定nginx worker进程的拥有者和所述组。如果省略了group，则默认的的group和user相同。如user  www www

pid：指定nginx pid文件的存储位置。如pid /var/run/nginx.pid，如果指定的路径相对路径，则相对于nginx的prefix。

daemon on|off：默认值为on。指定nginx是否已daemon的方式运行。通常不需要修改。

master_process on|off：默认值为on。on表示启动一个master进程和多个worker进程。off表示只启动master进程，不启动worker进程。

worker_priority <number>：指定worker进程的优先级。默认值为0，范围是-20到19，值越小，优先级越高。

worker_processes <number>：指定启动worker进程的数量。默认值为1. 通常设置为和CPU核心数一致即可。获取CPU核心数：cat /proc/cpuinfo  | grep processor | wc -l

worker_cpu_affinity <cpumask>：设置CPU和worker进程的亲和力。将worker进程绑定到CPU上。
	示例：
	worker_processes 4;
	worker_cpu_affinity 0001 0010 0100 1000;
	规则设定：
	（1）cpu有多少个核，就有几位数，1代表内核开启，0代表内核关闭
	（2）worker_processes最多开启8个，8个以上性能就不会再提升了，而且稳定性会变的更低，因此8个进程够用了
		worker_processes 8;
		worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
		
		2核CPU，开启8进程：
		worker_processes  8;  
		worker_cpu_affinity 01 10 01 10 01 10 01 10;
		
		8核CPU，开启2进程：
		worker_processes  2;
		worker_cpu_affinity 10101010 01010101;
		说明：10101010表示开启了第2,4,6,8内核，01010101表示开始了1,3,5,7内核

worker_rlimit_nofile <number>：指定一个worker进程可以打开的文件描述符数量。worker_connections不能超过该值。

error_log file|stderr|syslog:server-address[,parameter-value] [debug | info | notice | warn | error | crit | alert | emerg]：指定error log的存储位置。可以用在main、http、mail、stream、server和location区块中。如果没有指定日志等级，则默认的日志等级为error。
		
```

# events区块设置
```
use：指定处理请求的方式。常用的方式有：select、poll、kqueue（适用于FreeBSD4.1+，OpenBSD 2.9+，MasOS X,NetBSD 2.0）、epoll（适用于Linux2.6+以上的内核）、/dev/poll（Solaris 7 11/99+，HP/UX 11.22+）、eventport（Solaris 10

multi_accept on|off：默认值为off。on表示一个worker进程一次接收多个请求，off表示一个worker进程一次只接收一个请求。

accept_mutex on|off：默认值为on。
	当设置为on时，多个worker进程将会按照顺序接收新的连接，但是只有一个worker进程会被唤醒，其他的worker进程将会继续保持睡眠状态。
	当设置为off时，所有的worker进程将会被通知，但是只有一个worker进程可以获得这个连接，其他的worker进程会重新进入休眠状态。这称为“惊群问题”。
	如果网站访问量比较大，可以关闭它。
	
worker_connections <number>：默认值为512.指定一个worker进程能同时处理的连接数。
	* 通过worker_processes和worker_connections能够计算出最大客户端连接数：
    max_clients=worker_processes * worker_connections
    * 在反向代理环境中，最大客户端连接数:
    max_clients=worker_processes * worker_connections/4
    原因：默认情况下，一个浏览器会对服务器打开两个连接，Nginx使用来自同一个池中的FDS（文件描述符）来连接上游服务器。
    
	最终的结论：http 1.1协议下，由于浏览器默认使用两个并发连接,因此计算方法：
    * nginx作为http服务器的时候；
    max_clients = worker_processes * worker_connections/2
    
	* nginx作为反向代理服务器的时候：
    max_clients = worker_processes * worker_connections/4
    
	* clients与用户数：
	同一时间的clients(客户端数)和用户数还是有区别的，当一个用户请求发送一个连接时这两个是相等的，但是当一个用户默认发送多个连接请求的时候，clients数就是用户数*默认发送的连接并发数了。
	
debug_connection <address>|<cidr>|unix: 没有默认值。为指定的客户端开启debug log，其他的客户端将会使用error_log的设置。需要在编译时开启--with-debug选项。如：
    debug_connection 127.0.0.1;
    debug_connection 172.17.100.0/24;
    debug_connection localhost;
```

# http区块配置
```

```

