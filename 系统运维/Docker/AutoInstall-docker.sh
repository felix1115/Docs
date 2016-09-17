#!/bin/bash

# Author: Felix.zhang
# QQ: 573713035
# Date: 2016-09-16
# Function: Auto install docker daemon

# 定义环境变量
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# 定义输出颜色
CSI=$(echo -e "\033[")
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CFAILURE="$CRED"
CEND="${CSI}0m"

# 定义docker内核版本要求
dockerMajorKernel=3
dockerMinorKernel=10
dockerRepoUrl="https://yum.dockerproject.org"

# 检测当前用户是否为root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root user to run this script${CEND}"; exit 1; }

# 配置文件
ISSUE=/etc/issue
RELEASE=/etc/redhat-release

# 检查系统类型和版本
SystemVersion() {
    local releaseMatchRule="^[0-9]"
    local releaseVersion
    if [ -s $RELEASE ]; then
        releaseVersion=$(cat $RELEASE | head -n 1)
        release=$(echo $releaseVersion | awk '{print $1}')
        for i in $(echo $releaseVersion)
        do
            if [[ $i =~ $releaseMatchRule ]]; then
                version=$i
            else
                continue
            fi
        done
        if [ -z $version ]; then
            version='Unknown'
        fi
        SystemVersion="$release $version"
    elif [ -s $ISSUE ]; then
        releaseVersion=$(cat $ISSUE | head -n 1)
        release=$(echo $releaseVersion | awk '{print $1}')
        local convertReleaseToMin=$(echo ${release,,})
        case $convertReleaseToMin in
            'centos'|'redhat')
                version=$(echo $releaseVersion | awk '{print $3}')
                ;;
            'ubuntu')
                version=$(echo $releaseVersion | awk '{print $2}')
                ;;
        esac
        SystemVersion="$release $version"
    else
        SystemVersion=Unknown
    fi
}


# Check Kernel Version
KernelVersionCheck() {
	local kernelMajor=$(uname -r | awk -F'.' '{print $1}')
	local kernelMinor=$(uname -r | awk -F'.' '{print $2}')
	local kernelArch=$(uname -m)
	if [ $kernelMajor -gt $dockerMajorKernel ]; then
		kernelVersionCheckResult=1
	elif [ $kernelMajor -eq $dockerMajorKernel ] && [ $kernelMinor -ge $dockerMinorKernel ]; then
		kernelVersionCheckResult=1
	else
		kernelVersionCheckResult=2
	fi

	if [ $kernelArch == "x86_64" ]; then
		kernelArchResult=1
	else
		kernelArchResult=2
	fi
}

# 检查到docker repo的网络连接
DockerRepoNetwork() {
	curl --connect-timeout 10 --head $dockerRepoUrl &> /dev/null
	if [ $? -eq 0 ]; then
		dockerRepoNetworkResult=1
	else
		dockerRepoNetworkResult=2
	fi
}

# 执行函数
SystemVersion
KernelVersionCheck
DockerRepoNetwork


# 判断内核版本和操作系统是否为64bit
if [ $kernelVersionCheckResult -eq 2 ]; then
	echo "${CFAILURE}Your kernel not support docker, please check your kernel version greate than 3.10${CEND}"
	exit 1
elif [ $kernelArchResult -eq 2 ]; then
	echo "${CFAILURE}Your system architecture not support docker, please check your kernel architecture${CEND}"
	exit 2
fi

# 判断网络连接
if [ $dockerRepoNetworkResult -eq 2 ]; then
	echo "${CFAILURE}Can not connect to docker repo, please check your network setting.${CEND}"
	exit 3
fi