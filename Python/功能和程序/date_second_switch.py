#!/usr/bin/env python
# coding: utf-8


import time


def date_to_seconds(date, format):
    return time.mktime(time.strptime(date, format))


def seconds_to_date(seconds):
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(seconds))
