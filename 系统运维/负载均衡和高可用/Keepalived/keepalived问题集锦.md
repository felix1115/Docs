# keepalived问题集锦
* Keepalived_healthcheckers[1525]: IPVS: Protocol not available
* Keepalived_healthcheckers[1504]: IPVS: Service not defined
```
说明：产生上述两种问题的可能原因是ip_vs模块以及ip_vs_rr/ip_vs_wrr这种负载均衡算法的模块没有家在导致。

解决方法：/etc/sysconfig/modules/ipvs.modules

[root@vm05 ~]# touch /etc/sysconfig/modules/ipvs.modules
[root@vm05 ~]# chmod +x /etc/sysconfig/modules/ipvs.modules
[root@vm05 ~]#
[root@vm05 ~]# more /etc/sysconfig/modules/ipvs.modules
#!/bin/bash

modules_list='
ip_vs_rr
ip_vs_wrr
ip_vs_lc
ip_vs_wlc
'
for m in $modules_list
do
    /sbin/modinfo -F filename $m > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        /sbin/modprobe $m
    fi
done
[root@vm05 ~]#

解释：
1. 之所使用使用/etc/sysconfig/modules这个目录下新建一个文件，是因为在系统初始化时(/etc/rc.sysint)会执行该目录下的所有的*.modules文件，且文件必须具有可执行权限。
2. 使用modinfo -F filename则表示查看模块的filename字段的内容。
3. 之所以不用rc.local文件，是因为该文件是最后才会执行的，如果程序在启动时就加载了某些模块，则这样配置无法正常工作。
```
