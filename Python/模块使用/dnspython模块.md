# 安装dnspython

[dnspython官网](http://www.dnspython.org/)

* 安装dnspython
```
[root@vm01 ~]# unzip dnspython-1.15.0.zip
[root@vm01 ~]#  cd dnspython-1.15.0
[root@vm01 dnspython-1.15.0]# python2.7 setup.py install
...
Finished processing dependencies for dnspython==1.15.0
[root@vm01 dnspython-1.15.0]#
```

# dnspython的使用
* 说明

>dnspython模块提供了大量的DNS处理方法，常用的是域名查询。dnspython提供了一个DNS解析器类----resolver，使用该类的query方法查询域名。
>


* 导入模块
```
In [2]: import dns.resolver

In [3]:
```

* query方法的使用
```
格式：query(qname, rdtype=1, rdclass=1, tcp=False, source=None, raise_on_no_answer=True, source_port=0)

qname：查询名称。如：www.baidu.com
rdtype：查询类型，也就是资源记录类型。如A、PTR、NS、SOA、MX、CNAME
rdclass：查询类，也就是网络类型。如IN、CH、HS。默认是IN
tcp：是否使用tcp协议进行查询。默认为False。
source：指定查询所使用的源地址。
source_port：指定查询所使用的源端口。
raise_on_no_answer：当查询没有响应时，是否引发异常。


返回值：调用该方法后，会返回一个dns.resolver.Answer的实例。
```

# 查询示例
* 查询A记录
```
[root@vm01 dnspython]# more rr_a.py
#!/usr/bin/env python2.7
#coding: utf-8

import dns.resolver

output_format = '%s: %-15s'

domain = raw_input('query domain: ').strip()
answers = dns.resolver.query(domain, 'A')
for rdata in answers:
    print ' result '.center(30, '-')
    print output_format % (domain, rdata.address)
    print ''.center(30, '-')
[root@vm01 dnspython]#

示例：
query domain: ntp2.felix.com
----------- result -----------
ntp2.felix.com: 172.17.100.2
------------------------------
[root@vm01 dnspython]#
```

* 查询NS记录
```
[root@vm01 dnspython]# more rr_ns.py
#!/usr/bin/env python2.7
#coding: utf-8

import dns.resolver

output_format = '%s: %-15s'
ns_list = []
domain = raw_input('query domain: ').strip()
answers = dns.resolver.query(domain, 'NS')
for rdata in answers:
    ns_list.append(rdata.to_text())


print ' NS Record '.center(30, '-')

for ns in ns_list:
    a = dns.resolver.query(ns, 'A')
    for rdata in a:
        print output_format % (ns, rdata.address)

print ''.center(30, '-')
[root@vm01 dnspython]#


示例：
[root@vm01 dnspython]# ./rr_ns.py
query domain: felix.com
--------- NS Record ----------
ns2.felix.com.: 172.17.100.2
ns1.felix.com.: 172.17.100.1
------------------------------
[root@vm01 dnspython]#
```

* 查询CNAME记录
```
[root@vm01 dnspython]# more rr_cname.py
#!/usr/bin/env python2.7
#coding: utf-8

import dns.resolver

output_format = '%s: %-15s'
domain = raw_input('query domain: ').strip()
answers = dns.resolver.query(domain, 'CNAME')
print ' CNAME Record '.center(30, '-')
for rdata in answers:
    print output_format % (domain, rdata.to_text())

print ''.center(30, '-')



[root@vm01 dnspython]#

示例：
[root@vm01 dnspython]# ./rr_cname.py
query domain: felix.com
-------- CNAME Record --------
felix.com: www.felix.com.
------------------------------
[root@vm01 dnspython]#
```

* 查询MX记录
```
[root@vm01 dnspython]# more rr_mx.py
#!/usr/bin/env python2.7
#coding: utf-8

import dns.resolver

# mx_dict format: {'mail.felix.com': [10, '172.17.100.1']}
# mail.felix.com is mail name
# 10 is preference
# 172.17.100.1 is address of mail.felix.com
mx_dict = {}

domain = raw_input('query domain: ').strip()
answers = dns.resolver.query(domain, 'MX')
for rdata in answers:
    mx_dict[rdata.exchange] = [rdata.preference]

for mx in mx_dict:
    a = dns.resolver.query(mx, 'A')
    for rdata in a:
        mx_dict[mx].append(rdata.address)

# output result
for key, value in mx_dict.items():
    print "Mail: %s, Preference: %s, Address: %s" % (key, value[0], value[1])
[root@vm01 dnspython]#

示例：
[root@vm01 dnspython]# ./rr_mx.py
query domain: felix.com
Mail: mail1.felix.com., Preference: 10, Address: 172.17.100.3
Mail: mail2.felix.com., Preference: 20, Address: 172.17.100.4
[root@vm01 dnspython]#
```