#!/bin/bash

# Date: 2016-08-16
# Author: Felix.zhang
# Function: Obtain some informations about current host. e.g: hostname/ip/gateway/dns/system version/kernel/cpu/memory/disk

# 定义环境变量
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# 定义输出颜色
CSI=$(echo -e "\033[")
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CFAILURE="$CRED"
CEND="${CSI}0m"

# 检测当前用户是否为root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root user to run this script${CEND}"; exit 1; }

# 判断用户是否有安装dmidecode和ifconfig软件
if ! $(which dmidecode &> /dev/null); then
    echo
    echo "${CFAILURE}Error: Please install dmidecode package.${CEND}"
    echo "${CGREEN}Command: yum install -y dmidecode${CEND}"
    echo
    exit 2
elif ! $(which ifconfig &> /dev/null); then
    echo
    echo "${CFAILURE}Error: Please install ifconfig package.${CEND}"
    echo "${CGREEN}Command: yum install -y net-tools${CEND}"
    echo
    exit 3
fi

# 定义脚本需要使用的文件
ISSUE=/etc/issue
RELEASE=/etc/redhat-release
CPUINFO=/proc/cpuinfo
MEMORYINFO=/proc/meminfo
DNSINFO=/etc/resolv.conf

# 定义临时文件并初始化
tmpFileDisk="/tmp/.$(basename $0)-disk.txt"
tmpFileNetwork="/tmp/.$(basename $0)-network.txt"
tmpFileDns="/tmp/.$(basename $0)-dns.txt"
> $tmpFileDisk
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

function Hostname() {
    hostname=$(hostname)    
}


function Cpu() {
    # 获取CPU核心数
    cpuNumber=$(cat $CPUINFO | grep 'processor' | wc -l)    
    # 根据CPU核心数决定输出是Core还是Cores
    if [ $cpuNumber -ge 2 ]; then
        core='Cores'
    else
        core='Core'
    fi

    # 获取CPU是AMD还是Intel
    if $(cat $CPUINFO | grep 'vendor_id' | grep 'Intel' &> /dev/null); then
        cpuVendor='Intel'
    elif $(cat $CPUINFO | grep 'vendor_id' | grep 'AMD' &> /dev/null); then 
        cpuVendor='AMD'
    else
        cpuVendor='Unknown'
    fi

    cpuModel=$(cat $CPUINFO | grep 'model name' | awk -F':' '{print $2}')
    cpuType=$(echo $cpuModel | awk '{print $3}')
    if [ $cpuType == 'CPU' ]; then
        cpuType=$(echo $cpuModel | awk '{print $4}')
    fi
    cpuHz=$(echo $cpuModel | awk '{print $NF}')
    cpuInfo="$cpuNumber $core $cpuVendor $cpuType $cpuHz"
}

function Platform() {
    if $(dmidecode | grep 'Product Name' | head -n 1 | awk -F':' '{print $2}' | grep 'VMware' &> /dev/null); then
        platform='VMware'
    elif $(dmidecode | grep 'Product Name' | head -n 1 | awk -F':' '{print $2}' | grep 'HVM domU' &> /dev/null); then
        platform='XEN'
    else
        platform='Unknown'
    fi
}

function Memory() {
    local enabledMemory=$(dmidecode --type memory | grep 'Enabled Size' | grep -v 'Not' | awk -F':' '{print $2}' | awk '{print $1,$2}' | awk '{print $1}')
    for memory in $(echo $enabledMemory)
    do
        let totalMemoryMB+=$memory
    done
    totalMemoryMB="$totalMemoryMB MB"
}


function Kernel() {
    kernelVersion=$(uname -r)    
    matchRule1="x86$"
    matchRule2="x86_64$"
    if [[ $kernelVersion =~ $matchRule1 ]] || [[ $kernelVersion =~ $matchRule2 ]]; then
        kernelVersion=$(echo ${kernelVersion%.*})
    fi
    hardwarePlatform=$(uname -i)
    kernelInfo="$kernelVersion $hardwarePlatform"
}

function DiskInfo() {
    diskNumber=$(fdisk -l | grep '^Disk /' | grep -vE 'mapper|ram' | wc -l)
    fdisk -l | grep '^Disk /' | grep -vE 'mapper|ram' > $tmpFileDisk
    local diskInitNumber=1
    while read item
    do
        diskName=$(echo $item | awk '{print $2}' | awk -F':' '{print $1}' |  awk -F'/' '{print $3}')
        #diskSize=$(echo $item | awk '{print $3,$4}' | awk -F',' '{print $1}')
        diskSize=$(($(cat /sys/block/$diskName/size)/2/1024/1024))
        if [ $diskInitNumber -eq 1 ]; then
            diskInfo="$diskName $diskSize"
            diskInitNumber=2
        else
            diskInfo=$diskInfo:"$diskName $diskSize"
        fi
    done < $tmpFileDisk
}

function Network() {
    local interfaceMatchRule="^lo"
    for interface in $(ifconfig | awk 'BEGIN {RS=""} {print $1}' | awk -F':' '{print $1}')
    do
        if [[ $interface =~ $interfaceMatchRule ]];then
            continue
        else
            # centos 6和centos 7的输出格式不同，需要特殊对待
            local convertReleaseToMin=$(echo ${release,,})
            local versionFirstChar=$(echo ${version::1})
            if [ $convertReleaseToMin == 'centos' ] || [ $convertReleaseToMin == 'redhat' ] && [ $(echo ${version::1}) -gt 6  ]; then
                ip=$(ifconfig $interface | grep '\<inet\>' | awk '{print $2}')
                netmask=$(ifconfig $interface | grep '\<inet\>' | awk '{print $4}')
            else
                ip=$(ifconfig $interface | grep '\<inet\>' | awk -F':' '{print $2}' | awk '{print $1}')
                netmask=$(ifconfig $interface | grep 'inet addr' | awk -F':' '{print $4}')
            fi
        fi
        if [ -z $ip ]; then
            continue
        else
            echo "$interface $ip/$netmask"  >> $tmpFileNetwork
        fi
    done
    gateway=$(route -n | grep '^0.0.0.0' | awk '{print $2}')
}

function Dns() {
    dns=''
    initDnsNumber=1
    dnsNumber=$(cat $DNSINFO | grep '^nameserver' | wc -l)
    cat $DNSINFO | grep '^nameserver' | awk '{print $2}' > $tmpFileDns
}


# 根据传入的字符串长度，决定输出格式 
function Length() {
    local result
    if [ $1 -lt 8 ]; then
        shift 1
        echo -e "$*\t\t\t\t|"
    elif [ $1 -ge 8 -a $1 -lt 16 ]; then
        shift 1
        echo -e "$@\t\t\t|"
    elif [ $1 -ge 16 -a $1 -lt 24 ]; then
        shift 1
        echo -e "$@\t\t|"
    elif [ $1 -ge 24 -a $1 -lt 32 ]; then
        shift 1
        echo -e "$@\t|"
    else
        shift 1
        result=$(echo $@ | awk -F'.' '{print $1}')
        if [ $(echo ${#result}) -ge 32 ]; then
            result=$(echo ${result::24})
            Length $(echo ${#result}) $result
        else
            Length $(echo ${#result}) $result
        fi
    fi
}


Hostname
SystemVersion
Cpu
Memory
Platform
Kernel
DiskInfo
Network
Dns

echo
echo '-----------------------------------------------------------------'
echo -e "|\t${CGREEN}Key\t\t${CEND}|\t${CGREEN}Value\t\t\t\t${CEND}|"
echo '-----------------------------------------------------------------'

echo -ne "|\tHostname\t|\t"
Length $(echo ${#hostname}) $hostname

echo '-----------------------------------------------------------------'
echo -e "|\tSystemVersion\t|\t$SystemVersion\t\t\t|"
echo '-----------------------------------------------------------------'
echo -e "|\tPlatform\t|\t$platform\t\t\t\t|"
echo '-----------------------------------------------------------------'

echo -ne "|\tKernel\t\t|\t"
Length $(echo ${#kernelInfo}) $kernelInfo

echo '-----------------------------------------------------------------'
echo -ne "|\tCPU\t\t|\t"
Length $(echo ${#cpuInfo}) $cpuInfo
echo '-----------------------------------------------------------------'

echo -ne "|\tMemory\t\t|\t"
Length $(echo ${#totalMemoryMB}) $totalMemoryMB

echo '-----------------------------------------------------------------'

if [ $diskNumber -gt 1 ]; then
    Disk='Disks'
else
    Disk='Disk'
fi

echo -ne "|\t$Disk\t\t|\t"
initNumber=1
echo $diskInfo | sed 's@:@\n@g' | while read item
do
    if [ $initNumber -eq 1 ]; then
        #echo -e "$item\t\t\t|"
        echo -e "$item GB\t\t\t|"
        let initNumber++
    else
        echo -ne "|\t\t\t|\t"
        echo -e "$item GB\t\t\t|"
        #echo -e "$item\t\t\t|"
    fi
done

echo '-----------------------------------------------------------------'

initNetworkNumber=0
fileNetworkNumber=$(wc -l $tmpFileNetwork | awk '{print $1}')
cat $tmpFileNetwork | while read item
do
    let initNetworkNumber++
    interface=$(echo $item | awk '{print $1}')
    ipNetmask=$(echo $item | awk '{print $2}')
    echo -ne "|\t"
    if [ ${#interface} -lt 8 ]; then
        echo -ne "${interface}\t\t|"
    elif [ ${#interface} -ge 8 -a ${#interface} -lt 16 ]; then
        echo -ne "${interface}\t|"
	fi

	echo -ne "\t"
    Length $(echo ${#ipNetmask}) $ipNetmask

    if [ $fileNetworkNumber -gt 1 -a $initNetworkNumber -ne $fileNetworkNumber ];then
        echo '-----------------------------------------------------------------'
    fi
done
if [ ! -z $gateway ]; then
    echo '-----------------------------------------------------------------'
    echo -e "|\tGateway\t\t|\t$gateway\t\t\t|"
fi

echo '-----------------------------------------------------------------'

echo -ne "|\tDNS\t\t|\t"

if [ -s $tmpFileDns ]; then
    cat $tmpFileDns | while read item
    do
        if [ $dnsNumber -gt 1 ]; then
            echo -e "$item\t\t\t|"
            let dnsNumber--
            echo -ne "|\t\t\t|\t"
        else
            echo -e "$item\t\t\t|"
        fi
    done
else
    echo -e "None\t\t\t\t|"
fi

echo '-----------------------------------------------------------------'
echo

# 删除临时文件
rm -rf $tmpFileDisk
rm -rf $tmpFileNetwork
rm -rf $tmpFileDns
