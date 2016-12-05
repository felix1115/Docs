# ipvsadm的安装
## 查看当前系统的内核是否支持ipvs
```
使用modprobe -l | grep ipvs，如果有输出，则当前内核已经支持了ipvs，否则需要重新编译内核。

[root@vm05 ~]# modprobe -l | grep ipvs
kernel/net/netfilter/ipvs/ip_vs.ko
kernel/net/netfilter/ipvs/ip_vs_rr.ko
kernel/net/netfilter/ipvs/ip_vs_wrr.ko
kernel/net/netfilter/ipvs/ip_vs_lc.ko
kernel/net/netfilter/ipvs/ip_vs_wlc.ko
kernel/net/netfilter/ipvs/ip_vs_lblc.ko
kernel/net/netfilter/ipvs/ip_vs_lblcr.ko
kernel/net/netfilter/ipvs/ip_vs_dh.ko
kernel/net/netfilter/ipvs/ip_vs_sh.ko
kernel/net/netfilter/ipvs/ip_vs_sed.ko
kernel/net/netfilter/ipvs/ip_vs_nq.ko
kernel/net/netfilter/ipvs/ip_vs_ftp.ko
kernel/net/netfilter/ipvs/ip_vs_pe_sip.ko
[root@vm05 ~]#
```

## rpm包安装
```
[root@vm05 ~]# yum install -y ipvsadm

[root@vm05 ~]# rpm -q ipvsadm
ipvsadm-1.26-4.el6.x86_64
[root@vm05 ~]#
```

## 源码包安装
```
[root@vm05 ipvsadm-1.26]# yum install -y gcc gcc-c++ libnl* popt* 
[root@vm05 ~]# tar -zxf ipvsadm-1.26.tar.gz
[root@vm05 ~]# cd ipvsadm-1.26
[root@vm05 ipvsadm-1.26]# make
[root@vm05 ipvsadm-1.26]# make install
```

# ipvsadm的使用
