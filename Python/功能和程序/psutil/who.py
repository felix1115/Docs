#!/usr/bin/env python
#coding: utf-8

import psutil
import time


def who():
    output_format = '%-8s %-10s %-20s %-15s'
    print output_format % ("User", "Terminal", "Login Time", "Host")

    users = psutil.users()

    for u in users:
        print output_format % (
            u.name,
            u.terminal,
            time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(u.started)),
            u.host
        )


if __name__ == '__main__':
    who()
