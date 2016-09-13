#!/bin/bash
# Author: felix.zhang
# Date: 2016-03-21
# Function: show the basic information of the ecses


ResultFile="$HOME/$(date +%F-%H-%M-%S)-ecs_result"

usage() {
    echo -e "Usage: $0 [-v|--version] | [-H|--hosts] <instance_name> [instance_name] [...] | [-f instances file]"
    echo
    echo -e "Command Summary:"
    echo -e "\t-v|--version\t\tshow version"
    echo -e "\t-h|--help\t\tThis help text"
    echo -e "\t-H|--hosts\t\tecs instance name,can use multiple of instances. e.g. -H instance1 instance2 instance3"
    echo -e "\t-f|--file\t\tread the instance from file, and save the result to $ResultFile"
    echo -e "\t-c|--connect\t\tConnect to this ECS. Only one instance can use. e.g. -c -H instance"
    echo
}

instance() {
    for InstanceName in $Hosts
    do

        InstanceId=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].InstanceId | awk -F'\"' '{print $2}')

        if [ -z ${InstanceId} ];then
            echo -e "\033[31mNo ECS in hangzhou: $InstanceName\033[m" 
            continue
        fi

        Status=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Status | awk -F'\"' '{print $2}')

        Cpu=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Cpu | awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        Memory=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Memory | awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        NatIpAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].VpcAttributes.[NatIpAddress] | awk -F'\"' '{print $2}')

        PrivateIpAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].VpcAttributes.PrivateIpAddress.IpAddress | awk -F'\"' '{print $2}')

        EipAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].EipAddress.IpAddress | awk -F'\"' '{print $2}')

        if [ -z ${EipAddress} ];then
            EipAddress="Null"
        fi

        Bandwidth=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].EipAddress.Bandwidth| awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        if [ -z ${Bandwidth} ];then
            Bandwidth="Null"
        fi

        echo "======================================"
        echo -e "$InstanceName"
        echo
        echo -e "\033[32mInstance ID: \033[m"$InstanceId

        if [ $Status != "Running" ];then
            echo -e "\033[31mStatus: \033[m"$Status
        else echo -e "\033[32mStatus: \033[m"$Status
        fi

        echo -e "\033[32mCpu: \033[m"$Cpu
        echo -e "\033[32mMemory: \033[m"$Memory

        #Disk
        NumLine=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId $InstanceId --filter Disks.Disk[*].[Device,Size] | wc -l)
        DiskNums=$(($NumLine / 4))
        DiskSeq=$(($DiskNums - 1))

        for DiskNum in $(seq 0 $DiskSeq)
        do
            DiskTag=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].Device | awk -F'\"' '{print $2}')

            DiskId=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].DiskId | awk -F'\"' '{print $2}')

            DiskSize=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].Size)

            echo -e "\033[32mDiskName[$DiskNum]: \033[m"$DiskTag
            echo -e "\033[32mDiskId[$DiskNum]: \033[m"$DiskId
            echo -e "\033[32mDiskSize[$DiskNum]: \033[m"${DiskSize}GB

        done

        echo -e "\033[32mNat Ip: \033[m"$NatIpAddress
        echo -e "\033[32mPrivate Ip: \033[m"$PrivateIpAddress
        echo -e "\033[32mEIP: \033[m"$EipAddress

        if [ $Bandwidth == "Null" ];then
            echo -e "\033[32mBandwidth: \033[m"${Bandwidth}
        else
            echo -e "\033[32mBandwidth: \033[m"${Bandwidth}Mbps
        fi

        echo "======================================"
        echo

        shift 1

    done

 #   exit 0
}



fileinstance() {
    for InstanceName in $Hosts
    do

        InstanceId=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].InstanceId | awk -F'\"' '{print $2}')

        if [ -z ${InstanceId} ];then
            echo -e "\033[31mNo ECS in hangzhou: $InstanceName\033[m" >> $ResultFile
            continue
        fi

        Status=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Status | awk -F'\"' '{print $2}')

        Cpu=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Cpu | awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        Memory=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].Memory | awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        NatIpAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].VpcAttributes.[NatIpAddress] | awk -F'\"' '{print $2}')

        PrivateIpAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].VpcAttributes.PrivateIpAddress.IpAddress | awk -F'\"' '{print $2}')

        EipAddress=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].EipAddress.IpAddress | awk -F'\"' '{print $2}')

        if [ -z ${EipAddress} ];then
            EipAddress="Null"
        fi

        Bandwidth=$(aliyuncli ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName $InstanceName --filter Instances.Instance[*].EipAddress.Bandwidth| awk -F'['  '{print $1}' | awk -F ']' '{print $1}')

        if [ -z ${Bandwidth} ];then
            Bandwidth="Null"
        fi

        
        echo "======================================" >> $ResultFile
        echo  "$InstanceName" >> $ResultFile
        echo >> $ResultFile
        echo  "Instance ID: "$InstanceId >> $ResultFile

        if [ $Status != "Running" ];then
            echo "Status: "$Status >> $ResultFile
        else
            echo "Status: "$Status >> $ResultFile
        fi

        echo "Cpu: "$Cpu  >> $ResultFile
        echo "Memory: "$Memory  >> $ResultFile

        #Disk
        NumLine=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId $InstanceId --filter Disks.Disk[*].[Device,Size] | wc -l)
        DiskNums=$(($NumLine / 4))
        DiskSeq=$(($DiskNums - 1))

        for DiskNum in $(seq 0 $DiskSeq)
        do
            DiskTag=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].Device | awk -F'\"' '{print $2}')

            DiskId=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].DiskId | awk -F'\"' '{print $2}')

            DiskSize=$(aliyuncli ecs DescribeDisks ---RegionId 'cn-hangzhou' --InstanceId ${InstanceId} --filter Disks.Disk[$DiskNum].Size)

            echo "DiskName[$DiskNum]: "$DiskTag  >> $ResultFile
            echo "DiskId[$DiskNum]: "$DiskId >> $ResultFile
            echo "DiskSize[$DiskNum]: "${DiskSize}GB  >> $ResultFile

        done

        echo "Nat Ip: "$NatIpAddress  >> $ResultFile
        echo "Private Ip: "$PrivateIpAddress >> $ResultFile
        echo "EIP: "$EipAddress  >> $ResultFile

        if [ $Bandwidth == "Null" ];then
            echo  "Bandwidth: "${Bandwidth}  >> $ResultFile
        else
            echo  "Bandwidth: "${Bandwidth}Mbps  >> $ResultFile
        fi

        echo "======================================"  >> $ResultFile
        echo  >> $ResultFile

        shift 1

    done

    exit 0

}


if [ $# -lt 1 ];then
    usage
    exit 5
fi

case $1 in 
-h|--help)
    usage
    exit 0
    ;;
-v|--version)
    echo "Version: 1.5"
    exit 0
    ;;
-f|--file)
    File=1
    Filename=$2
    if [ -z $Filename ];then
        echo -e "\033[31mSyntax error\033[m"
        usage
        exit 0
    fi
    ;;
-H|--hosts)
    shift 1
    Hosts=$@
    HostLength=$(echo ${#Hosts})
    if [ $HostLength -eq 0 ];then
        echo -e "\033[31mSyntax error\033[m"
        usage
        exit 0
    else
        instance
        exit 0
    fi
    ;;
-c|--connect)
    Connect=1
    shift 1
    if [ $1 != "-H" ];then
        echo -e "\033[31mSyntax error\033[m"
        usage
        exit 10
    elif [ -z $2 ];then
        echo -e "\033[31mSyntax error\033[m"
        usage
        exit 11
    else
        Hosts=$2
        instance
        EcsIp=$(echo $PrivateIpAddress)
        [ -z $EcsIp ] && exit 12
        ssh -i ~/.ssh/kakaorsa $EcsIp
        exit 0
    fi
    ;;

*)
    usage
    exit 0
    ;;
esac


if [ -f $Filename ];then
    echo > $ResultFile
    Hosts=$(cat $Filename)
    fileinstance
else
    echo -e "\033[31mCan not find file: $Filename"
    exit 6
fi
