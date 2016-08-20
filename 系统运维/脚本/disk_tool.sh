#!/bin/bash

# Author: felix.zhang
# Date: 2016-08-19
# QQ: 573713035
# Function: Check empty disk and auto partition, mount, increase lvm, decrease lvm

# 定义环境变量
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# 定义颜色输出
CSI=$(echo -e "\033[")
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CQUESTION="$CMAGENTA"
CWARNING="$CYELLOW"
CMSG="$CCYAN"
CEND="${CSI}0m"

# 检测当前用户是否为root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root user to run this script${CEND}"; exit 1; }

# 定义需要使用到的文件
PTABLE=/proc/partitions

# 定义临时文件并初始化
tmpFilePartitions=/tmp/.$(basename $0)-partitions.txt
tmpFilePV=/tmp/.$(basename $0)-pv.txt

> $tmpFilePartitions 
> $tmpFilePV

# 定义功能函数
function CheckEmptyDisks() {
    local emptyDiskNumbers=0
    # Check Partitions
    cat $PTABLE | tail -n +3 | awk '{print $4}'| grep -vE '^(dm|ram|sr|fd)' > $tmpFilePartitions
    # Check Disk
    allDisks=$(fdisk -l | grep '^Disk /' | grep -vE 'mapper|ram' | awk -F':' '{print $1}' | awk '{print $2}' | awk -F'/' '{print $3}')

    # Check PV
    pvs | tail -n +2 | awk '{print $1}' | awk -F'/' '{print $3}' > $tmpFilePV
    
    for disk in $(echo $allDisks)
    do
        # 让内核重读分区信息
        partx -a $disk &> /dev/null

        # 开始检测空的磁盘
        if $(cat $tmpFilePartitions | grep "$disk[[:digit:]]\+" &> /dev/null); then
            continue
        elif $(cat $tmpFilePV | grep "\<$disk\>" &> /dev/null); then
            continue
        else
            emptyDisks[$emptyDiskNumbers]=$disk
            let emptyDiskNumbers++
        fi
    done
}

function DeleteTmpFile() {
    rm -rf  $tmpFilePartitions
}

function Step1() {
    # step 1
    echo
    echo "${CMSG}Step 1: Scanning emtpy disks...${CEND}"
    sleep 1

    if [ ${#emptyDisks[@]} -eq 0 ]; then
        echo
        echo "${CFAILURE}Can not find empty disk...${CEND}"
        echo "Quit"
        echo
        exit 2
    else
        echo "========================================="
        echo -e "|     ${CSUCCESS}Serial\t${CEND}|\t${CSUCCESS}DiskName${CEND}\t|"
        for serial in $(seq 1 ${#emptyDisks[@]})
        do
            let serial--
            echo '-----------------------------------------'
            echo -e "|\t$((${serial}+1))\t|\t${emptyDisks[$serial]}\t\t|"
        done
        echo "========================================="
    fi
    sleep 1
}

function Step2ToStep3() {
    # step 2
    echo 
    echo "${CMSG}Step 2: Select operation type [LVM or Ordinary Partition]${CEND}"
    sleep .5
    while :
    do
        echo "================================="
        echo -e "|     ${CSUCCESS}Serial\t${CEND}|    ${CSUCCESS}Type${CEND}\t|"
        echo '---------------------------------'
        echo -e "|\t1\t|    Ordinary   |"
        echo '---------------------------------'
        echo -e "|\t2\t|    LVM\t|"
        echo "================================="
        echo -ne "${CQUESTION}Please select the serial number [1 or 2]${CEND} "
        read choice
        case $choice in
        1)
            echo
            echo -e "    ${CSUCCESS}Operation Mode: Ordinary Partition${CEND}"
            Step3_Ordinary
            break
            ;;
        2)
            echo
            echo -e "    ${CSUCCESS}Operation Mode: LVM Partition${CEND}"
            Step3_LVM
            break
            ;;
        *)
            echo
            echo "${CWARNING}Warning: invalid choice, please try again...${CEND}"
            echo
            continue
            ;;
        esac
    done
    sleep 1
}

function Step3_Ordinary() {
    # step 3 Ordinary Mode
    echo 
    echo "${CMSG}Step 3: [Ordinary Partition] Select the disk name you want to operation${CEND}"
    while :
    do
        echo
        echo '===================================================================='
        echo -e "    ${CSUCCESS}Tips: [Ordinary Partition] Allows you to select only one disk${CEND}"
        echo '===================================================================='
        echo
        echo -ne "${CQUESTION}Please enter the disk name you want to operation: [${emptyDisks[@]}]${CEND} "
        read choice
        # 将用户的输入转换为小写
        choice=${choice,,}
        # 判断用于输入disk个数，将其转换为数组，判断数组长度
        local paraNumber=($(echo ${choice}))
        if [ $(echo ${#paraNumber[@]}) -ne 1 ]; then
            echo
            echo "${CWARNING}Warning: invalid choice, Please try again${CEND}"
            echo
            continue
        else
            for disk in ${emptyDisks[*]}
            do
                # 这个errorCount主要用于控制在用户输入正确时退出最外层循环的
                local errorCount=0
                if [ $choice == $disk ];then
                    break
                else
                    let errorCount++
                fi
            done
            
        fi

        if [ $errorCount -ne 0 ];then
            echo
            echo "${CWARNING}Warning: invalid choice, Please try again${CEND}"
            echo
            continue
        else
            echo "Your select disk is: $choice"
            break
        fi
    done
    sleep 1
}

function Step3_LVM() {
    # step 3 LVM Mode
    echo 
    echo "${CMSG}Step 3: [LVM Partition] Select the disk name you want to operation${CEND}"
    echo
    echo '=========================================================================='
    echo -e "    ${CSUCCESS}Tips: [LVM Partition] Allows you to select one disk or multi disks${CEND}"
    echo '=========================================================================='
    echo
    local diskNumber=1
    while [ ${#emptyDisks[@]} -ge $diskNumber ]
    do
        echo -ne "${CQUESTION}Please enter the disk name you want to operation [Disk $diskNumber]: [${emptyDisks[@]}]${CEND} "
        read choice
        # 将用户的输入转换为小写
        choice=${choice,,}

        if [ -z $choice ]; then
            echo
            echo "${CWARNING}Warning: invalid choice, Please try again${CEND}"
            echo
            continue
        else
            for disk in ${emptyDisks[*]}
            do
                # 这个errorCount主要用于控制在用户输入正确时退出最外层循环的
                local errorCount=0
            
                if [ $choice == $disk ];then
                    let diskNumber++
                    break
                else
                    let errorCount++
                fi
            done
            

            if [ $errorCount -ne 0 ];then
                echo
                echo "${CWARNING}Warning: invalid choice, Please try again${CEND}"
                echo
                continue
            fi
        fi


    done
        
    
        echo "Your select disk is: $choice"
        break

    sleep 1
}

function Main() {
    CheckEmptyDisks
    Step1
    Step2ToStep3

    DeleteTmpFile
}

Main

