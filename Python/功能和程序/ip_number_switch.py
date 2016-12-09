#!/usr/bin/env python
# coding: utf-8
# Author: felix
# E-mail: 573713035@qq.com
# Version: 1.0
# 
'''
实现ip地址和数字互转
'''

'''
ip convert to number
将ip地址使用逗号分隔成4个字段，并将每一个字段转换为8位二进制(不足补零)，并将这些二进制拼接起来，使用int函数将其转换为整数
'''

def ip_to_number(ip):
	return int(''.join(["{0:08b}".format(int(i)) for i in ip.split('.')]), 2)
	# return int(''.join(map('{0:08b}'.format, map(int, ip.split('.')))), 2)

'''
number convert to ip
将数字向右移动24位，得到前8位，并与0xFF按位与，取得第一个8位
将数字向右移动16位，得到前16位，并与0xFF按位与，得到第二个8位
将数字向右移动8位，得到前24位，并与0xFF按位与，得到第三个8位
将数字向右移动0位，得到前32位，并与0xFF按位与，得到第四个8位
'''

def number_to_ip(number):
	return '.'.join([str(number >> (i << 3) & 0xFF) for i in range(4)[::-1]])