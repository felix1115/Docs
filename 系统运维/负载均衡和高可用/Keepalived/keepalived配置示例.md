# Keepalived配置示例
```
[root@vm05 keepalived]# more keepalived.conf
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