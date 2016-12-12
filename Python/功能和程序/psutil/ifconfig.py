#!/usr/bin/env python
#coding: utf-8

import psutil
import socket


af_net = {
	socket.AF_INET: 'IPv4',
	socket.AF_INET6: 'IPv6',
	psutil.AF_LINK: 'MAC'
	}

def interface_info(interface):
    interface_dict = psutil.net_if_addrs()
    for addr in interface_dict[interface]:
        if af_net.get(addr.family) == 'IPv4':
            print "\t%-12s: %s" % ('IPv4 Address', addr.address)
            print "\t%-12s: %s" % ('IPv4 Netmask', addr.netmask)
        elif af_net.get(addr.family) == 'MAC':
            print "\t%-12s: %s" % ('MAC Address', addr.address)


if __name__ == '__main__':
    for interface in psutil.net_if_addrs():
        print '%s:' % interface
        interface_info(interface)
        print


