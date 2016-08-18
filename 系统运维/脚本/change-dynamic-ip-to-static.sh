#!/bin/bash
# Author: felix.zhang
# Date: 2016-08-18
# QQ: 573713035
# Function: Convert dynamic ip address / gateway / dns / hostname information to static

# 定义环境变量
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# 定义输出颜色
CSI=$(echo -e "\033[")
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CFAILURE="$CRED"
CWARNING="$CYELLOW"

# 定义脚本需要使用的文件
ISSUE=/etc/issue
RELEASE=/etc/redhat-release
DNSINFO=/etc/resolv.conf
DISABLE_IPV6=/etc/modprobe.d/disable_ipv6.conf
SYSCTL=/etc/sysctl.conf
FILE_HOSTNAME_CU=/etc/hostname
FILE_HOSTNAME_C=/etc/sysconfig/network
FILE_NETWORK_CONFIG=/etc/sysconfig/network-scripts


# 检测当前用户是否为root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root user to run this script${CEND}"; exit 1; }

# 判断用户是否有安装dmidecode和ifconfig软件
if ! $(which ifconfig &> /dev/null); then
   echo
   echo "${CFAILURE}Error: Please install ifconfig package.${CEND}"
   echo "${CGREEN}Command: yum install -y net-tools${CEND}"
   echo
   exit 2
fi

# 定义临时文件
tmpFileNetwork="/tmp/.$(basename $0)-network.txt"
tmpFileDns="/tmp/.$(basename $0)-dns.txt"

> $tmpFileNetwork
> $tmpFileDns

function SystemVersion() {
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

function Network() {
    local interfaceMatchRule="^lo"
    for interface in $(ifconfig | awk 'BEGIN {RS=""} {print $1}' | awk -F':' '{print $1}')
    do
        if [[ $interface =~ $interfaceMatchRule ]]; then
            continue
        else
            # centos 6和centos 7的输出格式不同，需要特殊对待
            local convertReleaseToMin=$(echo ${release,,})
            local versionFirstChar=$(echo ${version::1})
            if [ $convertReleaseToMin == 'centos' ] || [ $convertReleaseToMin == 'redhat' ] && [ $(echo ${version::1}) -gt 6  ]; then
                ip=$(ifconfig $interface | grep '\<inet\>' | awk '{print $2}')
                netmask=$(ifconfig $interface | grep '\<inet\>' | awk '{print $4}')
                mac=$(ifconfig $interface | grep '\<ether\>' | awk '{print $2}')
            else
                ip=$(ifconfig $interface | grep '\<inet\>' | awk -F':' '{print $2}' | awk '{print $1}')
                netmask=$(ifconfig $interface | grep 'inet addr' | awk -F':' '{print $4}')
                mac=$(ifconfig $interface | grep '\<HWaddr\>' | awk '{print $NF}')
            fi
        fi

        if [ -z $ip ]; then
            continue
        else
            echo "$interface $ip $netmask $mac"  >> $tmpFileNetwork
        fi
    done

    gatewayInterface=$(route -n | grep '^0.0.0.0' | awk '{print $NF}')
    if [ ! -z $gatewayInterface ]; then
        gatewayAddress=$(route -n | grep '^0.0.0.0' | awk '{print $2}')
    fi

    cat $tmpFileNetwork | while read item
    do
        interface=$(echo $item | awk '{print $1}')
        ip=$(echo $item | awk '{print $2}')
        netmask=$(echo $item | awk '{print $3}')
        mac=$(echo $item | awk '{print $4}')
        networkConfigFile="$FILE_NETWORK_CONFIG/ifcfg-$interface"
        if [ $gatewayInterface == $interface ]; then
            cat > $networkConfigFile << EOF
DEVICE=$interface
BOOTPROTO=none
HWADDR=$mac
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
IPADDR=$ip
NETMASK=$netmask
GATEWAY=$gatewayAddress
USERCTL=no
IPV6INIT=no
PEERDNS=no
EOF
    else
        cat > $networkConfigFile << EOF
DEVICE=$interface
BOOTPROTO=none
HWADDR=$mac
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
IPADDR=$ip
NETMASK=$netmask
USERCTL=no
IPV6INIT=no
PEERDNS=no
EOF
    fi

    done

}

function Hostname() {
    hostname=$(hostname)

    if [ -f $FILE_HOSTNAME_CU ]; then
        echo $hostname > $FILE_HOSTNAME_CU
    else
        if $(grep '^HOSTNAME' $FILE_HOSTNAME_C &> /dev/null); then
            sed -i "/HOSTNAME/c HOSTNAME=$hostname" $FILE_HOSTNAME_C
        else
            sed -i "\$a HOSTNAME=$hostname" $FILE_HOSTNAME_C
        fi
    fi
}

function Dns() {
    cat $DNSINFO | grep -vE '^(#|;)' > $tmpFileDns    

    if [ -s $tmpFileDns ]; then
        cat $tmpFileDns > $DNSINFO
    fi
}

function DeleteTmpFile() {
   rm -rf $tmpFileNetwork
   rm -rf $tmpFileDns
}

function RestartNetowrk() {
    service network restart &> /dev/null
}

function AssignNewIp() {
    assignInterface=$1
    local setResult=0
    for interface in $(ifconfig | awk 'BEGIN {RS=""} {print $1}' | awk -F':' '{print $1}')
    do
        if [ $interface == $assignInterface ]; then
            sed -i "/BOOTPROTO/c BOOTPROTO=dhcp" $FILE_NETWORK_CONFIG/ifcfg-$assignInterface
            sed -i "/PEERDNS/c PEERDNS=yes" $FILE_NETWORK_CONFIG/ifcfg-$assignInterface
            if [ -f $FILE_HOSTNAME_CU ]; then
                > $FILE_HOSTNAME_CU
            else
                sed -i "/^HOSTNAME/d" $FILE_HOSTNAME_C
                hostname localhost
            fi
            setResult=1
        fi
    done
    
    if [ $setResult -ne 1 ]; then
        echo
        echo "${CFAILURE}Unknown interface $1${CEND}"
        echo
        exit 4
    fi
}

function PxeMachine() {
    SystemVersion
    Network
    Dns
    Hostname
    RestartNetowrk
    DeleteTmpFile
}

function ChangInfo() {
    AssignNewIp $1
    RestartNetowrk
    SystemVersion
    Network
    Dns
    Hostname
    DeleteTmpFile
    echo
    echo "${CWARNING}Hostname will take effect on next reboot${CEND}"
}

function Usage() {
    echo
    echo "${CWARNING}Usage: $0 --pxe | --change <interface_name>${CEND}"
    echo
}

if [ $# -eq 0 ] || [ $# -gt 2 ];then
    Usage
elif [ $# == 1 ] && [ $1 == '--pxe' ]; then
    PxeMachine
elif [ $# -eq 2 ] && [ $1 == '--change' ] && [ -n $2 ]; then
    ChangInfo $2
else
    Usage
fi
