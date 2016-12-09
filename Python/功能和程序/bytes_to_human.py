#!/usr/bin/env python
#coding: utf-8
#作用：将字节转换成人类可读的方式显示

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
