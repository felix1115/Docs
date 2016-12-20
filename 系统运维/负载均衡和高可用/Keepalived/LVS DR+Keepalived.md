# LVS + Keeaplived配置
* 拓扑

![lvs_keepalived](https://github.com/felix1115/Docs/blob/master/Images/lvs-03.png)

## Keepalived配置
* Master端配置

```
[root@vm05 keepalived]#  more /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id LVS_PROD

   lvs_flush
   vrrp_garp_master_repeat 2
   vrrp_garp_master_delay 3
   vrrp_garp_interval 0.005

   vrrp_strict true

   lvs_sync_daemon eth0 LVS_APP_01 id 1
   vrrp_iptables

   vrrp_gna_interval 0
}

vrrp_instance LVS_APP_01 {
    state BACKUP
    interface eth0
    dont_track_primary
    virtual_router_id 1
    priority 100
    nopreempt
    advert_int 1
    strict_mode true
    authentication {
        auth_type PASS
        auth_pass felix
    }
    virtual_ipaddress {
        172.17.100.100 broadcast 172.17.100.100 dev eth0 label eth0:1
    }
}

virtual_server 172.17.100.100 80 {
    delay_loop 3
    lb_algo rr
    lb_kind DR
    persistence_timeout 0
    protocol TCP
    alpha

    real_server 172.17.100.1 80 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            delay_before_retry 2
        }
    }

    real_server 172.17.100.2 80 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            delay_before_retry 3
        }
    }

}

[root@vm05 keepalived]#
```

* slave端配置
```
[root@vm06 keepalived]# more /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id LVS_PROD

   lvs_flush
   vrrp_garp_master_repeat 2
   vrrp_garp_master_delay 3
   vrrp_garp_interval 0.005

   vrrp_strict true

   lvs_sync_daemon eth0 LVS_APP_01 id 1
   vrrp_iptables

   vrrp_gna_interval 0
}

vrrp_instance LVS_APP_01 {
    state BACKUP
    interface eth0
    dont_track_primary
    nopreempt
    virtual_router_id 1
    priority 90
    advert_int 1
    strict_mode true
    authentication {
        auth_type PASS
        auth_pass felix
    }

    virtual_ipaddress {
        172.17.100.100 broadcast 172.17.100.100 dev eth0 label eth0:1
    }
}

virtual_server 172.17.100.100 80 {
    delay_loop 3
    lb_algo rr
    lb_kind DR
    persistence_timeout 0
    protocol TCP
    alpha

    real_server 172.17.100.1 80 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            delay_before_retry 2
        }
    }

    real_server 172.17.100.2 80 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            delay_before_retry 3
        }
    }

}
[root@vm06 keepalived]#
```

# RS端配置
* 路由条目
```
[root@vm01 ~]#
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
172.17.100.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     1002   0        0 eth0
0.0.0.0         172.17.100.253  0.0.0.0         UG    0      0        0 eth0
[root@vm01 ~]#
```

* arp_ignore和arp_announce
```
[root@vm01 ~]# echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
[root@vm01 ~]# echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
[root@vm01 ~]# echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
[root@vm01 ~]# echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
[root@vm01 ~]#
```

* VIP配置
```
[root@vm01 ~]# ifconfig lo:0 172.17.100.100 netmask 255.255.255.255 up
[root@vm01 ~]#
```

# 测试
```
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 01</h1>
[root@vm11 ~]# curl http://www.felix.com
<h1>Nginx Backend Server 02</h1>
[root@vm11 ~]#
```

# RS端脚本
```
[root@vm01 ~]# more realserver.sh
#!/bin/bash
# description: RealServer script
# processname: realserver.sh

# disable selinux and iptables
setenforce 0 &> /dev/null
iptables -F &> /dev/null

VIP='172.17.100.100'
LOCK=/var/lock/subsys/realserver

. /etc/rc.d/init.d/functions

start() {
    ifconfig lo:0 $VIP netmask 255.255.255.255 broadcast $VIP up &> /dev/null
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
    touch $LOCK
}

stop() {
    ifconfig lo:0 down &> /dev/null
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
    rm -f $LOCK
}

status() {
    LO_IP=$(ifconfig lo:0 | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}')
    if [ -f $LOCK ] && [ "$LO_IP" == "$VIP" ]; then
        return 0
    else
        return 1
    fi
}

case $1 in
start)
    $1
    status
    retval=$?
    if [ $retval -eq 0 ]; then
        echo "[DR] RealServer Start OK"
    else
        echo "[DR] RealServer Start Failed"
    fi
    ;;
stop)
    $1
    status
    retval=$?
    if [ $retval -eq 1 ]; then
        echo "[DR] RealServer Stop OK"
    else
        echo "[DR] RealServer Stop Failed"
    fi
    ;;
status)
    $1
    status
    retval=$?
    if [ $retval -eq 0 ]; then
        echo "[DR] RealServer is running"
    else
        echo "[DR] RealServer is stopped"
    fi
    ;;
*)
    echo "Usage: $0 start|stop|status"
    ;;
esac

exit 0

[root@vm01 ~]#
```