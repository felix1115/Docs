# ��װPPTP
## RPM����װpptp
```
[root@vm01 ~]# yum install -y ppp
[root@vm01 ~]# yum localinstall -y pptpd-1.3.4-1.el6.x86_64.rpm 

[root@vm01 ~]#  pptpd --version
pptpd v1.3.4
[root@vm01 ~]# pppd --version
pppd version 2.4.5
[root@vm01 ~]# 

```

## Դ�밲װ������PPTP
```
* ��װPPTP 1.3.4��
[root@vm01 ~]# tar -zxf pptpd-1.3.4.tar.gz 
[root@vm01 ~]# cd pptpd-1.3.4
[root@vm01 pptpd-1.3.4]# ./configure --prefix=/usr/local/source/pptpd-1.3.4
[root@vm01 pptpd-1.3.4]# make
[root@vm01 pptpd-1.3.4]# make install


* ���������ļ���vpnuser����
[root@vm01 pptpd-1.3.4]# mkdir /usr/local/source/pptpd-1.3.4/etc
[root@vm01 pptpd-1.3.4]# cp samples/* /usr/local/source/pptpd-1.3.4/etc
[root@vm01 pptpd-1.3.4]# cp tools/vpnuser /usr/local/source/pptpd-1.3.4/sbin/
[root@vm01 pptpd-1.3.4]# 


* �޸Ĺ���vpnuser�е�config������ָ��chap-secrets��λ��
[root@vm01 sbin]# grep 'config=' vpnuser  
config="/etc/ppp/chap-secrets"
[root@vm01 sbin]# 

```



# ����PPTP
* �������ļ���/etc/pptpd.conf
* ѡ�������ļ���/etc/ppp/options.pptpd
* �û���Ϣ�����ļ���/etc/ppp/chap-secrets

## ����ip_forward
```
[root@vm01 ppp]# echo 1 > /proc/sys/net/ipv4/ip_forward 
[root@vm01 ppp]# 

```

## ����ip_greģ��
```
˵������ʱ�����ʾGRE��ش�����Ϣ����Ҫ����ip_greģ�顣
[root@vm01 ppp]# modprobe ip_gre
[root@vm01 ppp]# lsmod | grep gre
ip_gre                  9575  0 
ip_tunnel              12693  1 ip_gre
[root@vm01 ppp]# 

```

## pptpd.conf
```
ѡ��˵����

ppp /usr/sbin/pppd: ָ��pppd�����·���������Ĭ��·����
option /etc/ppp/options.pptpd: ָ��ѡ�������ļ���·����
debug #����debugģʽ�����е������д�뵽��־�ļ���
stimeout 10��ctrl connections(��������)�ĳ�ʱʱ�䡣
logwtmp��ʹ��wtmp(last����ʹ�õ��ļ�)�ļ���¼�ͻ��˵����ӺͶϿ���Ϣ��
delegate����pptpd���������е�IP��ַ��pppd������Ļ�������radius����IP��ַ��Ĭ�Ϲرա�
connections 100������pptpd���Խ��ܵ����ͻ�����������Ĭ��Ϊ100
localip��ָ��VPN��������IP��ַ�����������delegateѡ���localip��remoteip�ᱻ���ԡ�
remoteip��ָ�������VPN Client��ip��ַ���ַ�Ρ�
```

```
[root@vm01 ~]# grep -vE '^#|^$' /etc/pptpd.conf 
ppp /usr/sbin/pppd
option /etc/ppp/options.pptpd
debug
stimeout 10
connections 100
localip 172.17.100.1
remoteip 172.17.100.180-200
[root@vm01 ~]# 
```

## options.pptpd
```
ѡ��˵����
name pptpd��ָ������ϵͳ������֤�ĳ������ƣ����Ҫ��/etc/ppp/chap-secrets�ĵڶ����ֶ�һ�¡�
ms-dns 172.17.100.1��ָ����Microsoft Client�������DNS��������ַ��
ms-dns 172.17.100.2��ָ����Microsoft Client����Ĵ�DNS��������ַ��
proxyarp����������arp
refuse-pap���ܾ�pap�����֤���������Ҫ����ע��
refuse-chap���ܾ�chap�����֤���������Ҫ����ע��
refuse-mschap���ܾ�mschap�����֤���������Ҫ����ע��
require-mschap-v2����Ҫʹ��ʹ��mschap-v2�����֤������
require-mppe-128����Ҫʹ��128λMPPE����
nologfd��ע�͸�ѡ�ʹ��logfileָ����־�ļ���λ�á�Ĭ�ϼ�¼��/var/log/messages�С�
logfile /var/log/pptpd.log��ָ����־�ļ��Ĵ洢λ�á�

```

```
˵��������������chap��mschap��֤��

[root@vm01 ~]# grep -vE '^#|^$' /etc/ppp/options.pptpd 
name pptpd
refuse-pap
require-mschap-v2
require-mppe-128
ms-dns 172.17.100.1
ms-dns 172.17.100.2
proxyarp
logfile /var/log/pptpd.log
lock
nobsdcomp 
novj
novjccomp
[root@vm01 ~]# 
```

## chap-secrets
```
˵�������ļ�ָ����ʹ��chap��֤ʱ�û�����֤��Ϣ��
�ļ���ʽΪ��  client    server    secret   IP Address

client���ͻ����û���
server����options.pptpd�ж����name��
secret���ͻ�������
IP Address��������ͻ��˵�IP��ַ�����������Ǿ�̬Ip��ַ��ַ������붯̬�����ַ��������*

ʾ����
frame   pptpd   frame123   172.17.100.180
```

# vpnuser�����ʹ��
```
vpnuser������ӡ�ɾ�����鿴VPN�û���Ϣ��

�鿴��vpnuser show
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
[root@vm01 ~]# 


���VPN�û���vpnuser add
[root@vm01 ~]# vpnuser add test test123
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
test	*	test123	*
[root@vm01 ~]# 


ɾ��VPN�û���vpnuser del
[root@vm01 ~]# vpnuser del test
[root@vm01 ~]# vpnuser show
User	Server	Passwd	IPnumber
---------------------------------
# Secrets for authentication using CHAP
# client	server	secret			IP addresses
frame	pptpd	frame123	*
[root@vm01 ~]# 

```

# iptables����
```
pptpdĬ�ϼ�����TCP��1723�˿ڡ�

����TCP 1723��
[root@vm01 ~]# netstat -tunlp | grep pptpd
tcp        0      0 0.0.0.0:1723                0.0.0.0:*                   LISTEN      6041/pptpd          
[root@vm01 ~]# 


�������ģ��ʹiptables֧��PPTP��͸��
[root@vmgw ~]# modprobe nf_nat_pptp
[root@vmgw ~]# modprobe nf_conntrack_pptp
[root@vmgw ~]# modprobe nf_conntrack_proto_gre
[root@vmgw ~]# modprobe nf_nat_proto_gre
[root@vmgw ~]# 

������ֱ�Ӽ���ip_nat_pptpģ�飺
[root@vmgw ~]# modprobe ip_nat_pptp
[root@vmgw ~]# 



���ÿ����Զ�����ģ�飺
[root@vmgw ~]# cat /etc/sysconfig/iptables-config | grep '\<IPTABLES_MODULES\>'
IPTABLES_MODULES="ip_nat_pptp"
[root@vmgw ~]# 

```

```
[root@vmgw ~]# iptables -t nat -A PREROUTING -i eth0 -p tcp -d 172.17.200.1 --dport 1723 -j DNAT --to-dest 172.17.100.1:1723
[root@vmgw ~]# modprobe ip_nat_pptp
[root@vmgw ~]# 
[root@vmgw ~]# /etc/init.d/iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
[root@vmgw ~]# 
```


## Linux�ͻ��˲���
## CentOS��Ϊ�ͻ���
```
[root@vm3 ~]# yum install -y pptp-setup

�������ӣ�
[root@vm3 ~]# pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start

˵����
--create:��ʾ����һ��VPN���ӣ�testΪ�������ƣ����������
--server:ָ��VPN�������ĵ�ַ��
--username:VPN�û���
--password:VPN���롣
--encrypt:����
--start:������֮������������ӡ����ֻ�Ǵ������ӵĻ�������û��--start���������ͨ��pppd call test�������ӡ�

ɾ�����ӣ�testΪ�������ơ�
[root@vm3 ~]# pptpsetup --delete test

�Ͽ�VPN��pkill pppd


ʾ����
[root@vm3 ~]# pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start
Using interface ppp0
Connect: ppp0 <--> /dev/pts/2
CHAP authentication succeeded
MPPE 128-bit stateless compression enabled
local  IP address 172.17.100.180
remote IP address 172.17.100.1
[root@vm3 ~]# 


[root@vm3 ~]# ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 b)  TX bytes:66 (66.0 b)

[root@vm3 ~]# 


�Ͽ����ӣ�
[root@vm3 ~]# pkill pppd
[root@vm3 ~]# ifconfig ppp0
ppp0: error fetching interface information: Device not found
[root@vm3 ~]# 

�������ӣ�
[root@vm3 ~]# pppd call test
[root@vm3 ~]# ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 b)  TX bytes:66 (66.0 b)

[root@vm3 ~]# 


ɾ�����ӣ�
[root@vm3 ~]# pptpsetup --delete test
[root@vm3 ~]# 

```

## Ubuntu��Ϊ�ͻ���
```
��װpptp-setup
felix@u01:~$ sudo apt-get install -y pptp-setup


�������ӣ�
felix@u01:~$ sudo pptpsetup --create test --server 172.17.100.1 --username frame --password frame123 --encrypt --start
Using interface ppp0
Connect: ppp0 <--> /dev/pts/0
CHAP authentication succeeded
MPPE 128-bit stateless compression enabled
local  IP address 172.17.100.180
remote IP address 172.17.100.1
felix@u01:~$ 
felix@u01:~$ sudo ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 B)  TX bytes:66 (66.0 B)

felix@u01:~$ 


ֹͣVPN��poff test
felix@u01:~$ sudo poff test
felix@u01:~$ 
felix@u01:~$ sudo ifconfig ppp0
ppp0: error fetching interface information: Device not found
felix@u01:~$ 

�������ӣ�pon test
felix@u01:~$ sudo pon test
felix@u01:~$ sudo ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:172.17.100.180  P-t-P:172.17.100.1  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1496  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:60 (60.0 B)  TX bytes:66 (66.0 B)

felix@u01:~$ 


ɾ�����ӣ�
felix@u01:~$ sudo pptpsetup --delete test
felix@u01:~$ 

```

# pptpd�ű�
```
#!/bin/bash

# chkconfig: - 85 15
# description: PPTP server
# processname: pptpd


PROGRAM='/usr/local/source/pptpd-1.3.4'
CONFIG=$PROGRAM/etc/pptpd.conf
PPTPD=$PROGRAM/sbin/pptpd

# Source function library.
. /etc/rc.d/init.d/functions

# Source function library.
. /etc/rc.d/init.d/functions

case "$1" in
  start)
        echo -n "Starting pptpd: "
        if [ -f /var/lock/subsys/pptpd ] ; then
                echo
                exit 1
        fi
        daemon $PPTPD -c $CONFIG
        echo
        touch /var/lock/subsys/pptpd
        ;;
  stop)
        echo -n "Shutting down pptpd: "
        killproc pptpd
        echo
        rm -f /var/lock/subsys/pptpd
        ;;
  status)
        status pptpd
        ;;
  reload|restart)
        $0 stop
        $0 start
        echo "Warning: a pptpd restart does not terminate existing "
        echo "connections, so new connections may be assigned the same IP "
        echo "address and cause unexpected results.  Use restart-kill to "
        echo "destroy existing connections during a restart."
        ;;
  restart-kill)
        $0 stop
        ps -ef | grep pptpd | grep -v grep | grep -v rc.d | awk '{print $2}' | uniq | xargs kill 1> /dev/null 2>&1
        $0 start
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|restart-kill|status}"
        exit 1
esac

exit 0

```

# ����һЩ����
```
˵������Щ����λ��/usr/share/doc/ppp-x.x.x/scripts�С�
pon������VPN���ӡ�
poff���ر�VPN����
plog���鿴VPN������־��
```