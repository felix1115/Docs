# Apache2.2源码安装
## 软件需求
* apr和apr-util
需要apr和apr-util的版本为1.2以上。

* openssl和openssl-devel
开启SSL/TLS，提供https支持。

* zlib和zlib-devel
提供压缩支持。

```
[root@vm3 ~]# yum install -y apr apr-util zlib zlib-devel openssl openssl-devel
```

## 编辑安装httpd 2.2.31
### 静态编译
>所谓的静态编译是指所有的模块都编译进httpd这个文件中。在编译时不需要指定--enable-mods-shared='module-name'，在modules目录中不会有module.so的文件。

```
[root@vm3 apache]# tar -jxf httpd-2.2.31.tar.bz2 
[root@vm3 apache]# cd httpd-2.2.31
[root@vm3 httpd-2.2.31]# ./configure --prefix=/usr/local/source/apache22 --enable-so --enable-ssl --enable-rewrite --enable-cgi --enable-deflate --enable-expires --enable-headers --with-zlib --with-mpm=worker --enable-modules=all
[root@vm3 httpd-2.2.31]# make
[root@vm3 httpd-2.2.31]# make install
```

查看载入的模块：httpd -M
```
[root@vm3 bin]# ./httpd -M
httpd: apr_sockaddr_info_get() failed for vm3.felix.com
httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
Loaded Modules:
 core_module (static)
 authn_file_module (static)
 authn_default_module (static)
 authz_host_module (static)
 authz_groupfile_module (static)
 authz_user_module (static)
 authz_default_module (static)
 auth_basic_module (static)
 include_module (static)
 filter_module (static)
 deflate_module (static)
 log_config_module (static)
 env_module (static)
 expires_module (static)
 headers_module (static)
 setenvif_module (static)
 version_module (static)
 ssl_module (static)
 mpm_worker_module (static)
 http_module (static)
 mime_module (static)
 status_module (static)
 autoindex_module (static)
 asis_module (static)
 cgid_module (static)
 cgi_module (static)
 negotiation_module (static)
 dir_module (static)
 actions_module (static)
 userdir_module (static)
 alias_module (static)
 rewrite_module (static)
 so_module (static)
Syntax OK
[root@vm3 bin]# 

```

### 动态编译(DSO)
>动态编译的模块是在编译时使用--enable-mods-shared='module-name'，会在modules目录下生成module.so的文件，在配置文件中需要使用loadmodule载入模块。
>--with-mpm=worker表示将MPM编译成一个静态模块。MPM模块可以是：prefork、worker、event。如果没有该选项，则默认为prefork模块。

```
[root@vm3 apache]# tar -jxf httpd-2.2.31.tar.bz2 
[root@vm3 apache]# cd httpd-2.2.31
[root@vm3 httpd-2.2.31]# ./configure --prefix=/usr/local/source/apache22 --enable-so --enable-ssl --enable-rewrite --enable-cgi --enable-deflate --enable-expires --enable-headers --with-zlib --with-mpm=worker --enable-mods-shared=all
[root@vm3 httpd-2.2.31]# make
[root@vm3 httpd-2.2.31]# make install
```

```
[root@vm3 bin]# ./httpd -M
httpd: apr_sockaddr_info_get() failed for vm3.felix.com
httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
Loaded Modules:
 core_module (static)
 mpm_worker_module (static)
 http_module (static)
 so_module (static)
 authn_file_module (shared)
 authn_dbm_module (shared)
 authn_anon_module (shared)
 authn_dbd_module (shared)
 authn_default_module (shared)
 authz_host_module (shared)
 authz_groupfile_module (shared)
 authz_user_module (shared)
 authz_dbm_module (shared)
 authz_owner_module (shared)
 authz_default_module (shared)
 auth_basic_module (shared)
 auth_digest_module (shared)
 dbd_module (shared)
 dumpio_module (shared)
 reqtimeout_module (shared)
 ext_filter_module (shared)
 include_module (shared)
 filter_module (shared)
 substitute_module (shared)
 deflate_module (shared)
 log_config_module (shared)
 log_forensic_module (shared)
 logio_module (shared)
 env_module (shared)
 mime_magic_module (shared)
 cern_meta_module (shared)
 expires_module (shared)
 headers_module (shared)
 ident_module (shared)
 usertrack_module (shared)
 unique_id_module (shared)
 setenvif_module (shared)
 version_module (shared)
 ssl_module (shared)
 mime_module (shared)
 dav_module (shared)
 status_module (shared)
 autoindex_module (shared)
 asis_module (shared)
 info_module (shared)
 cgid_module (shared)
 cgi_module (shared)
 dav_fs_module (shared)
 vhost_alias_module (shared)
 negotiation_module (shared)
 dir_module (shared)
 imagemap_module (shared)
 actions_module (shared)
 speling_module (shared)
 userdir_module (shared)
 alias_module (shared)
 rewrite_module (shared)
Syntax OK
[root@vm3 bin]# 

```

### 编译选项说明
```
--prefix：安装目录
--sysconfdir:配置文件目录
--enable-so：开启DSO（动态共享对象）的支持。动态装载模块
--enable-ssl：支持https的功能
--enable-rewrite：支持rewrite功能
--enable-cgi：支持CGI脚本功能
--enable-deflate：提供对内容的压缩传输编码支持，一般html，js，css等静态内容，使用此参数功能会大大提高传输速度，提升访问者访问体验。在生产环境中，这是apache调优的一个重要选项之一。
--enable-expires：激活允许通过配置文件控制HTTP的“Expires：”和“Cache-Control：”头内容，即对网站图片、js、css等内容，提供在客户端游览器缓存的设置。这是apache调优的一个重要选项之一。
--enable-headers：提供允许对HTTP请求头的控制
--with-zlib：压缩功能的函数库
--with-pcre：perl库软件的安装目录
--enable-modules=most：most表示编译常用的模块，all表示编译所有的模块
--with-mpm=worker：设置默认启用的MPM模式为worker
--enable-mods-shared=all：动态编译模块。
```

# MPM模块介绍
>MPM:Multi-Processing Modules，MPM用于绑定网络接口、接收请求、调度子进程处理请求等。

## prefork
>prefork采用预派生进程的方式处理用户请求，一个进程处理一个用户的请求。

```
# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxClients: maximum number of server processes allowed to start
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_prefork_module>
    ServerLimit           16       //服务允许可配置的进程的最大上限。该值在prefok MPM中的硬限制是200000，在worker和event MPM中硬限制是20000.修改该值时，使用restart服务不生效，但是MaxClients可以生效。
    StartServers          5        //在服务启动时创建的子进程数。
    MinSpareServers       5        //最小空闲进程数。空闲进程是指没有处理请求的进程。如果空闲的进程数小于该值时，父进程就会根据如下方法产生子进程。先一秒钟产生一个，等待一秒，然后在一秒钟产生两个，等待一秒，然后在一秒钟产生四个，等待一秒，直到一秒钟产生32.
    MaxSpareServers      10        //最大空闲进程数。空闲进程是指没有处理请求的进程。如果空闲的进程数大于该值，则父进程会kill掉多余的进程。如果该值小于或等于MinSpareServers，则Apache会自动的调整该值为MinSpareServers+1.
    MaxClients          150        //指定Apache可以同时处理的请求数，当同时处理的请求数多于该值时，多余的连接将会排队，直到某个请求处理结束。排队的连接最多可以达到ListenBackLog设定的值，LiostenBackLog默认值为511，该值指定了最大未处理的连接的队列长度。MaxCients默认值为256，如果要增加这个值，也需要增加ServerLimit。
    MaxRequestsPerChild   0        //每个子进程处理多少个请求后将会退出。每个子进程在处理了“MaxRequestsPerChild”个请求后将自动销毁。0意味着无限，即子进程永不销毁。虽然设为0可以使每个子进程处理更多的请求，但如果设成非零值也有两点重要的好处：可防止意外的内存泄漏；在服务器负载下降的时侯会自动减少子进程数。因此，可根据服务器的负载来调整这个值。当开启了KleepAive时，只有第一个请求会被计数，因此在KeepAlive中，该值的意思是：一个子进程处理多少个连接后将会退出。
</IfModule>

```

* prefork工作过程

>在httpd服务启动之后，初始启动5个工作进程（由StartServers定义），httpd根据需要自动调整工作进程的个数，最大允许启动250个工作进程（由MaxClients定义），也就是说当网站访问量大的时候，启动了大量工作进程，而在访问量变少时，不再需要这些工作进程了，httpd通过MinSpareServers和MaxSpareServers自动调节工作进程的数量。如果当前的空闲进程大于MaxSpareServer定义的最大空闲进程数，httpd将会杀死超额的工作进程；如果当前的空闲进程小于MinSpareServer定义的最小空闲进程数，httpd将会启动新的工作进程：启动1个进程，稍等一会儿，启动2个进程，稍等一会儿，启动4个进程，然后一直以指数方式启动进程，一直到每秒钟产生32个工作进程，它将停止启动进程，一直到当前进程能满足最小空闲进程（MinSpareServers)。一个工作进程在处理了最大请求数（MaxRequestPerChild)之后，将会被杀死，设置为0表示永不地期。


## worker
>worker MPM采用了混合多进程和多线程的方式，使用线程处理用户请求。

```
# worker MPM
# StartServers: initial number of server processes to start
# MaxClients: maximum number of simultaneous client connections
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_worker_module>
    ServerLimit          16    //服务器允许的可配置的进程的最大上限。默认为16. worker MPM硬限制是20000。如果MaxClients除以ThreadsPerChild大于16时，需要修改该值。
    StartServers         3     //服务启动时，默认启动的工作进程数
    MaxClients          400    //最多允许多少个客户端同时连接。该值是ServerLimit乘以ThreadsPerChild,因此如果要增加该值，则需要同时增加ServerLimit。
    MinSpareThreads      25    //最小空闲线程数
    MaxSpareThreads      75    //最大空闲线程数
    ThreadsPerChild      25    //每个工作进程可以产生的线程数
    MaxRequestsPerChild   0    //每个进程在生命周期内所允许服务的最大请求数。每个子进程在处理了“MaxRequestsPerChild”个请求后将自动销毁。0意味着无限，即子进程永不销毁。虽然设为0可以使每个子进程处理更多的请求，但如果设成非零值也有两点重要的好处：可防止意外的内存泄漏；在服务器负载下降的时侯会自动减少子进程数。因此，可根据服务器的负载来调整这个值。当开启了KleepAive时，只有第一个请求会被计数，因此在KeepAlive中，该值的意思是：一个子进程处理多少个连接后将会退出。
	Threadlimit  64    //指定一个进程产生线程的可配置的最大上限。默认为64.硬限制为20000.
</IfModule>
```

## event
>一个线程处理多个请求，基于worker MPM。配置和worker一致。如果要使用event MPM，则在编译时需要使用--with-mpm=event。



# Apache源码安装启动脚本


# apachectl和httpd的使用

```
[root@vm3 bin]# ./apachectl -h
Usage: /usr/local/source/apache22/bin/httpd [-D name] [-d directory] [-f file]
                                            [-C "directive"] [-c "directive"]
                                            [-k start|restart|graceful|graceful-stop|stop]
                                            [-v] [-V] [-h] [-l] [-L] [-t] [-T] [-S]
Options:
  -D name            : define a name for use in <IfDefine name> directives
  -d directory       : specify an alternate initial ServerRoot
  -f file            : specify an alternate ServerConfigFile
  -C "directive"     : process directive before reading config files
  -c "directive"     : process directive after reading config files
  -e level           : show startup errors of level (see LogLevel)
  -E file            : log startup errors to file
  -v                 : show version number
  -V                 : show compile settings
  -h                 : list available command line options (this page)
  -l                 : list compiled in modules
  -L                 : list available configuration directives
  -t -D DUMP_VHOSTS  : show parsed settings (currently only vhost settings)
  -S                 : a synonym for -t -D DUMP_VHOSTS
  -t -D DUMP_MODULES : show all loaded modules 
  -M                 : a synonym for -t -D DUMP_MODULES
  -t                 : run syntax check for config files
  -T                 : start without DocumentRoot(s) check
[root@vm3 bin]# 

说明：
-D：指定一个可用于<IfDefine name>指定中的name。
-d：指定ServerRoot的目录。
-f：指定服务配置文件。
-C：在读取配置文件之前处理指令。
-c：在读取配置文件之后处理指令。
-v：显示版本号。
-V：显示编译设置。
-h：列出可用的命令行选项。
-l：列出编译的模块。
-L：列出可用的配置指令。
-t -D DUMP_VHOSTS：分析虚拟主机的配置
-S：分析虚拟主机的配置
-t -D DUMP_MODULES：显示所有载入的模块。
-M：显示所有载入的模块。
-t：运行语法检查。
-T：启动服务，不进行DocumentRoot的检查。
-k start|stop|restart|graceful|graceful-stop：启停服务操作。

```

## 信号说明
* stop
>apachectl -k stop或httpd -k stop：发送的是SIGTERM(kill -15)信号。会通知父进程(httpd.pid文件里面的进程号)立即kill掉所有的子进程，待所有的子进程结束后，父进程也会退出。会终止所有的请求(包括正在处理的)，并且不会接收新的请求。


* restart
>apachectl -k restart或httpd -k restart：发送的是SIGHUP(kill -1)信号。会通知父进程终止所有的子进程，而父进程不会退出，然后父进程会重新读取配置文件，然后重新打开日志文件，最后父进程会spawns(fork and exec)一组新的子进程处理客户端的请求。

* graceful
>apachectl -k graceful或httpd -k graceful：表示的是优雅的重启。发送的是SIGUSR1(kill -10)信号给父进程。该信号会通知子进程处理完当前正在处理的请求后退出(如果子进程当前没有处理任何请求，则立即退出)，然后父进程会重新读取配置文件、重新打开日志文件，并产生新的子进程替代已经退出的子进程处理新的请求。
注意：如果配置文件有错误，则会引起httpd停止服务。

* graceful-stop
>apachectl -k graceful-stop或httpd -k graceful-stop：表示的是优雅的停止。发送的是SIGWINCH(kill -28)信号给父进程。该信号会通知子进程处理完当前正在处理的请求后退出(如果子进程当前没有处理任何请求，则立即退出)，然后父进程将会删除PID文件，并停止监听在任何端口上。父进程将会继续运行，并且监听正在处理请求的子进程，当所有的子进程处理完请求并且退出后或者是超过GracefulShutdownTimeout所指定的时间，父进程将会退出。如果超时，则剩下的子进程会收到SIGTERM信号，强制退出。


# 在不重新编译Apache的情况下支持其他模块
```
1：首先进入到Apache的源码包的modules目录下。
[root@vm02 modules]# pwd
/opt/httpd-2.2.31/modules
[root@vm02 modules]# 

2：进入到需要安装的模块目录
[root@vm02 modules]# cd proxy/
[root@vm02 proxy]# 

3：安装模块
[root@vm02 proxy]# /usr/local/source/apache22/bin/apxs -i -a -c mod_proxy.c 
说明：
-i：表示安装模块。
-a：表示启用模块。
-A：表示注释模块。
-c：此选项表示需要执行编译操作。它首先会编译C源程序(.c)files为对应的目标代码文件(.o)，然后连接这些目标代码和files中其余的目标代码文件(.o和.a)，以生成动态共享对象dso file 。如果没有指定 -o 选项，则此输出文件名由files中的第一个文件名推测得到，也就是默认为mod_name.so

```