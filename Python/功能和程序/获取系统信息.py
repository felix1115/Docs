#!/bin/env python

import platform

def sysInfo():
	distribution = ' '.join(platform.linux_distribution())
	machine = platform.machine()
	nodeName = platform.node()
	release = platform.release()

	return [distribution, machine, nodeName, release]