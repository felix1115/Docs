#!/usr/bin/env python2.7
# coding: utf-8

import psutil


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
    output_format = "%-17s %8s %8s %8s %5s%% %9s  %s"
    print output_format % ("Device", "Total", "Used", "Free", "Use", "Type", "Mount On")

    disk_part = psutil.disk_partitions(all=False)

    for part in disk_part:
        usage = psutil.disk_usage(part.mountpoint)
        if not part.device or not usage.total:
            continue

        print output_format % (
            part.device,
            bytes2human(usage.total),
            bytes2human(usage.used),
            bytes2human(usage.free),
            usage.percent,
            part.fstype,
            part.mountpoint)


if __name__ == '__main__':
    main()