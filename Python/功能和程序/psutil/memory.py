#!/usr/bin/env python
# coding: utf-8

import platform
import psutil

dist = platform.linux_distribution()[1].split('.')[0]
output_format = '%-8s %8s %8s %8s %8s %8s%%'
print output_format % ('', 'Total', 'Used', 'Free', 'Avail', 'Percent')

def bytes2human(n):
    symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
    prefix = {}

    for i, s in enumerate(symbols, 1):
        prefix[s] = 1 << (i * 10)

    for s in reversed(symbols):
        if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)

    return '%sB' % n


def main():
    # memory info
    mem = psutil.virtual_memory()
    mem_total = mem.total
    mem_free = mem.free
    mem_avail = mem.available
    mem_percent = mem.percent

    # swap info
    swap = psutil.swap_memory()
    swap_total = swap.total
    swap_used = swap.used
    swap_free = swap.free
    swap_percent = swap.percent
    swap_avail = swap_free

    if dist == '6':
        mem_used = mem_total - mem_free
    else:
        mem_used = mem.used

    print output_format % (
        'Mem: ',
        bytes2human(mem_total),
        bytes2human(mem_used),
        bytes2human(mem_free),
        bytes2human(mem_avail),
        mem_percent
    )

    print output_format % (
        'Swap: ',
        bytes2human(swap_total),
        bytes2human(swap_used),
        bytes2human(swap_free),
        bytes2human(swap_avail),
        swap_percent
    )

if __name__ == '__main__':
    main()
