
# initctl介绍
```
在SystemV这个版本的unix中，系统启动首先是启动init进程。这个进程会按照runlevle启动/etc/rc[0-6].d 目录下的脚本。这里rc后面的数字就是runlevel。
举个例子，在图形界面打开以前，runlevel=5；如果系统启动了图形界面，那么runlevel就进入到6.那么/etc/rc6.d里面的脚本就会被一个一个的执行。这些脚本其实都是到/etc/init.d/下的脚本的软链接。

SystemV的启动顺序是一个一个的执行，这不可避免的带来串行的时间开销。于是有了System V init 的改进版 “upstart”. 
initctl就是upstart提供的一个命令。upstart 的一个优化就是使用的事件驱动，这样启动服务A的时候，不用等待A的结束就可以启动服务B了。在upstart的概念里，我们把服务称作JOB。

使用命令：initctl start JOB来启动JOB
启动的JOB以init进程为父进程。当JOB的进程被杀死后，init进程会自动重新启动JOB。这就是 initctl start JOB 和 service JOB start 的主要区别。
```

# initctl的使用
```
语法：initctl [OPTION]...  COMMAND [OPTION]...  ARG...

COMMAND：
    start JOB [KEY=VALUE]... ：start一个JOB，KEY=VALUE表示要传递给JOB的环境变量。可以传递多个。
    stop JOB [KEY=VALUE]... : stop 一个JOB
    restart JOB：restart一个JOB
    status JOB：查看一个JOB的状态。
    reload JOB：发送SIGHUP信号，重新载入配置文件。
    list：查看JOB列表。
    reload-configuration：重新载入init的配置文件。


```


# 创建JOB
```
创建一个JOB，需要在/etc/init/目录下，创建一个以.conf结尾的文件，如myjob.conf，这myjob就是我们的JOB。该文件不具有x权限。
JOB分为3中：Task(任务作业)、Services(服务作业)、Abstact Job(抽象作业)
Task：只运行一次，不会被respawn
Services：长期运行


0. job的状态：
    waiting: 初始状态。
　　starting: 作业开始启动。
　　pre-start: 运行pre-start配置节。
　　spawned: 运行script或exec节。
　　post-start: 运行post-start节。
　　running: 运行完post-start节之后的临时状态，表示作业正在运行(但可能没有关联的PID)。
　　pre-stop:运行pre-stop节。
　　stopping:运行完pre-stop节之后的临时状态。
　　killed: 作业要被终止。
　　post-stop: 运行post-stop节。
　　作业的状态可通过inictl status命令输出的中status域来显示给用户。



1. Documentation相关：
* description <DESCRIPTION>
作用：定义JOB的秒数信息。如description "This is a test job"

* author <AUTHOR>
作用：定义JOB的作者。如author "felix.zhang <felix.zhang@kakaocorp.com>"

* version <VERSION>
作用：定义JOB的版本信息。如version "1.1"

* emits <EVENT> ...
作用：定义JOB可以产生的事件。

* usage <USAGE>
作用：定义JOB的使用方法。当执行initctl start|stop|status失败时，要显示的帮助信息。

2， Process相关
使用job主要是定义被init dameon所运行的services或tasks。每一个job在其生命周期的不同阶段都可以有一个或多个不同的process运行，成为主进程。
主进程可以用exec或者是script定义，二者选其一。

* exec <COMMAND> [ARG] ...
作用：使用exec执行一个COMMAND，并且可以传递一个或多个ARG给该COMMAND，COMMAND要求具有x权限。ARG可以使用双引号和$，将其传给SHELL
如：exec /usr/sbin/acpid -c $EVENTSDIR -s $SOCKET

* script ... end script
作用：在script中间所定义的内容将会作为一个shell脚本被运行，使用sh执行，并且总是使用-e选项，在该脚本中的任何命令执行失败，都会终止该脚本。
注意：script和end script都要单独一行。
如：
script
    . /etc/sysconfig/init
    for tty in $(echo $ACTIVE_CONSOLES) ; do
        [ "$RUNLEVEL" = "5" -a "$tty" = "$X_TTY" ] && continue
        initctl start tty TTY=$tty
    done
end script

* 另外几个exec和script的格式
pre-start exec|script...：该process将会在job的starting事件完成以后，主程序运行以前执行。主要用于准备一些环境。
post-start exec|script ...：该process将会在job的started事件发出以前，在主进程已经spawned以后执行。
pre-stop exec|script ...：该process将会在job的stopping事件发出以前，并且在主程序被killed以前执行。
post-stop exec|script ...：该process将会在主程序已经被killed以后，在stopped事件发生以前执行。

3. 事件定义
* start on EVENT [[KEY=]VALUE]... [and|or...]
作用：EVENT表示事件的名字，多个EVENT可以用and或者or组合，and表示全部事件都发生，or表示其中之一发生即可。JOB的启动还可以依赖于特定的条件，可以用KEY=VALUE表示额外的条件。
一般是某个环境变量(KEY)和特定的值(VALUE)进程比较。如果只有一个变量，或者变量的顺序已知，则KEY可以省略。也可用KEY!=VALUE

* stop on EVENT [[KEY=]VALUE]... [and|or...]
作用：停止JOB。

4. 定义环境变量
env KEY=VALUE
export KEY：导出JOB的环境变量的值到starting、started、stopping、stopped事件中

5. Services、Task、respawn

* task
作用：将该job标记为一个task。

* respawn
作用：当service或者task不正常停止时，自动重启。不正常停止：任何情况的service stopping或者是stop命令，都是不正常的。具有退出状态码为0的task可以阻止respawn

*  respawn limit COUNT INTERVAL
作用：默认的COUNT是10，INTERVAL是5。表示在是如果一个job在INTERVAL秒内respawn的次数超过COUNT次，则该job会停止运行。不适用与restart(initctl restart)命令。

* normal exit STATUS|SIGNAL...
作用：当job收到其中之一的退出状态码或者是信号时，不会respawn。
如：normal exit 0 1 TERM HUP

```