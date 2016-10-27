#!/bin/bash

# Function: auto deploy gift
# Author: felix.zhang
# Date: 2016-10-17

# PATH and LANG
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# Color
CSI=$(echo -e "\033[")
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CEND="${CSI}0m"


# Version
version=1.1

# Identify
auto=/root/.ssh/auto

# Command
aliyuncli=/usr/bin/aliyuncli
slb="${aliyuncli} slb"
ecs="${aliyuncli} ecs"

# Function Variables
COPY=0
BACKUP=0
STARTSERVICE=0

# ECS Servers
WEB="giftweb01 giftweb02"
ID="giftid01 giftid02"
SHOPPING="giftshop01 giftshop02"
SERVICES="giftserv01 giftserv02"
PAY="giftimgp001"
IMGPROCESS="giftimgp01"
MESSAGE="giftmess01"
PROMOTION="giftprom01"

# SLB ID
web_intra='lbbp1hpx2n24t07c2s5o'
web_extra='lbbp12r855567a41y495'
service_intra='lbbp1g4929h1n39vj8l5'
service_extra='lbbp15r2s9u7isx6lv1z'
shopping_intra='lbbp135ug97509r746rk'
shopping_extra='lbbp119a6n7htz0619h3'
id_intra='lbbp1iq084erjlfvr2js'
id_extra='lbbp142s8rkgn1xxaef9'

# Check Result
PROJECT_RESULT=0
SCP_RESULT=0
BACKUP_RESULT=0
UNZIP_RESULT=0
# SLB_INTRA_RESULT=0
# SLB_EXTRA_RESULT=0
# STARTSERVICE_RESULT=0


help() {
    echo
    echo "Usage: $0 [-v|--version] | [-h|--help] | [-cp package-name] | [-bp package-name]" 
    echo -e "\t-v|--version: show version"
    echo -e "\t-h|--help: show help"
	echo -e "\t-ap: copy & backup & SLB & Start Services on destination hosts. e.g: -ap /root/style-web-0.5.27.zip"
    echo -e "\t-bp: backup the project. e.g: -bp /root/style-web-0.5.27.zip"
    echo -e "\t-cp: copy the package to destination hosts. e.g: -cp /root/style-web-0.5.27.zip"
    echo

    exit 0
}

ecsip() {
	$ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName "$1" --filter Instances.Instance[*].VpcAttributes.PrivateIpAddress.IpAddress | awk -F'\"' '{print $2}' | grep -v '^$'
}

ecsid() {
	$ecs DescribeInstances --RegionId 'cn-hangzhou' --InstanceName "$1" --filter Instances.Instance[*].InstanceId | awk -F'\"' '{print $2}' | grep -v '^$'
}

project() {
    project_middle_name="$(echo $package | awk -F'/' '{print $NF}' | awk -F'-' '{print $2}')"
    project_name="$(echo $package | awk -F'/' '{print $NF}' | awk -F'-' '{print $1"-"$2}')"
    project_version=$(echo $package |  awk -F'/' '{print $NF}' | awk -F'-' '{print $3}' | awk -F'.zip' '{print $1}')
    project_dirname=$(echo $package | awk -F'/' '{print $NF}' | awk -F'.zip' '{print $1}')
    project_package=$(echo $package | awk -F'/' '{print $NF}')
}

backup() {
    case $project_name in
	    'style-web')
			for i in $WEB
			do
				web_ip=$(ecsip $i)
				if [ -z $web_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				web_backup=/root/style-web-backup
				web_deploy=/home/deploy

				ssh -i $auto root@"$web_ip" "mkdir $web_backup" &> /dev/null
				echo "backup project to" $web_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$web_ip" "ls $web_deploy/$project_name-*.zip"
				echo -n "Backup: $web_ip "
				ssh -i $auto root@"$web_ip" "cp -a $web_deploy/$project_name-*.zip $web_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done

			return $BACKUP_RESULT
			;;
	    'style-id')
			for i in $ID
			do
				id_ip=$(ecsip $i)
				if [ -z $id_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				id_backup=/root/style-id-backup
				id_deploy=/home/deploy

				ssh -i $auto root@"$id_ip" "mkdir $id_backup" &> /dev/null
				echo "backup project to" $id_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$id_ip" "ls $id_deploy/$project_name-*.zip"
				echo -n "Backup: $id_ip "
				ssh -i $auto root@"$id_ip" "cp -a $id_deploy/$project_name-*.zip $id_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			;;
	    'style-services')
			for i in $SERVICES
			do
				service_ip=$(ecsip $i)
				if [ -z $service_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				service_backup=/root/style-service-backup
				service_deploy=/home/deploy

				ssh -i $auto root@"$service_ip" "mkdir $service_backup" &> /dev/null
				echo "backup project to" $service_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$service_ip" "ls $service_deploy/$project_name-*.zip"
				echo -n "Backup: $service_ip "
				ssh -i $auto root@"$service_ip" "cp -a $service_deploy/$project_name-*.zip $service_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			
			;;
	    'style-shopping')
			for i in $SHOPPING
			do
				shopping_ip=$(ecsip $i)
				if [ -z $shopping_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				shopping_backup=/root/style-shopping-backup
				shopping_deploy=/home/deploy

				ssh -i $auto root@"$shopping_ip" "mkdir $shopping_backup" &> /dev/null
				echo "backup project to" $shopping_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$shopping_ip" "ls $shopping_deploy/$project_name-*.zip"
				echo -n "Backup: $shopping_ip "
				ssh -i $auto root@"$shopping_ip" "cp -a $shopping_deploy/$project_name-*.zip $shopping_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			;;
	    'style-pay')
			for i in $PAY
			do
				pay_ip=$(ecsip $i)
				if [ -z $pay_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				pay_backup=/root/style-pay-backup
				pay_deploy=/home/pay

				ssh -i $auto root@"$pay_ip" "mkdir $pay_backup" &> /dev/null
				echo "backup project to" $pay_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$pay_ip" "ls $pay_deploy/$project_name-*.zip"
				echo -n "Backup: $pay01ip "
				ssh -i $auto root@"$pay_ip" "cp -a $pay_deploy/$project_name-*.zip $pay_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			
			;;
	    'style-imgprocess')
			for i in $IMGPROCESS
			do
				imgprocess_ip=$(ecsip $i)
				if [ -z $imgprocess_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				imgprocess_backup=/root/style-imgprocess-backup
				imgprocess_deploy=/home/deploy

				ssh -i $auto root@"$imgprocess_ip" "mkdir $imgprocess_backup" &> /dev/null
				echo "backup project to" $imgprocess_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$imgprocess_ip" "ls $imgprocess_deploy/$project_name-*.zip"
				echo -n "Backup: $imgprocess_ip "
				ssh -i $auto root@"$imgprocess_ip" "cp -a $imgprocess_deploy/$project_name-*.zip $imgprocess_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			;;
	    'style-promotion')
			for i in $PROMOTION
			do
				promotion_ip=$(ecsip $i)
				if [ -z $promotion_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
			
				promotion_backup=/root/style-promotion-backup
				promotion_deploy=/home/deploy

				ssh -i $auto root@"$promotion_ip" "mkdir $promotion_backup" &> /dev/null
				echo "backup project to" $promotion_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$promotion_ip" "ls $promotion_deploy/$project_name-*.zip"
				echo -n "Backup: $promotion_ip "
				ssh -i $auto root@"$promotion_ip" "cp -a $promotion_deploy/$project_name-*.zip $promotion_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			;;
	    'style-message')
			for i in $MESSAGE
			do
				message_ip=$(ecsip $i)
				if [ -z $message_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi

				message_backup=/root/style-message-backup
				message_deploy=/home/message

				ssh -i $auto root@"$message_ip" "mkdir $message_backup" &> /dev/null
				echo "backup project to" $message_backup
				echo "[ ${CSUCCESS}Backup list ${CEND} ]"
				ssh -i $auto root@"$message_ip" "ls $message_deploy/$project_name-*.zip"
				echo -n "Backup: $message_ip "
				ssh -i $auto root@"$message_ip" "cp -a $message_deploy/$project_name-*.zip $message_backup"
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let BACKUP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $BACKUP_RESULT
			;;
    esac
}

scp_package() {
    case $project_name in
	    'style-web')
			for i in $WEB
			do
				web_ip=$(ecsip $i)
				if [ -z $web_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				web_deploy=/home/deploy

				echo -n "scp $package to" $web_ip
				scp -i $auto $package root@"$web_ip":$web_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
	    'style-id')
			for i in $ID
			do
				id_ip=$(ecsip $i)
				if [ -z $id_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				id_deploy=/home/deploy

				echo -n "scp $package to" $id_ip
				scp -i $auto $package root@"$id_ip":${id_deploy} &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT

			;;
        'style-services')
			for i in $SERVICES
			do
				service_ip=$(ecsip $i)
				if [ -z $service_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				service_deploy=/home/deploy

				echo -n "scp $package to" $service_ip
				scp -i $auto $package root@"$service_ip":$service_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
		'style-shopping')
			for i in $SHOPPING
			do
				shopping_ip=$(ecsip $i)
				if [ -z $shopping_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				shopping_deploy=/home/deploy

				echo -n "scp $package to" $shopping_ip
				scp -i $auto $package root@"$shopping_ip":$shopping_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
        'style-pay')
			for i in $PAY
			do
				pay_ip=$(ecsip $i)
				if [ -z $pay_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				pay_deploy=/home/pay

				echo -n "scp $package to" $pay_ip
				scp -i $auto $package root@"$pay_ip":$pay_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
		'style-imgprocess')
			for i in $IMGPROCESS
			do
				imgprocess_ip=$(ecsip $i)
				if [ -z $imgprocess_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				imgprocess_deploy=/home/deploy

				echo -n "scp $package to" $imgprocess_ip
				scp -i $auto $package root@"$imgprocess_ip":$imgprocess_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
		'style-promotion')
			for i in $PROMOTION
			do
				promotion_ip=$(ecsip $i)
				if [ -z $promotion_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				promotion_deploy=/home/deploy

				echo -n "scp $package to" $promotion_ip
				scp -i $auto $package root@"$promotion_ip":$promotion_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
		'style-message')
			for i in $MESSAGE
			do
				message_ip=$(ecsip $i)
				if [ -z $message_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 4
				fi
				message_deploy=/home/message

				echo -n "scp $package to" $message_ip
				scp -i $auto $package root@"$message_ip":$message_deploy &> /dev/null
				if [ $? -eq 0 ]; then
					echo "${CSUCCESS} Success${CEND}"
					let SCP_RESULT+=1
				else
					echo "${CFAILURE} Failure${CEND}"
				fi
			done
			return $SCP_RESULT
			;;
    esac
}

unzipPackage() {
	case $project_name in
		'style-web')
			for i in $WEB
			do
				web_ip=$(ecsip $i)
				if [ -z $web_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				web_deploy=/home/deploy

				echo -n "Unzip $project_package to $web_deploy"
				ssh -i $auto root@"$web_ip" "unzip -o -q -d $web_deploy $web_deploy/$project_package"
				if $(ssh -i $auto root@"$web_ip" "ls -d $web_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-id')
			for i in $ID
			do
				id_ip=$(ecsip $i)
				if [ -z $id_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				id_deploy=/home/deploy

				echo -n "Unzip $project_package to $id_deploy"
				ssh -i $auto root@"$id_ip" "unzip -o -q -d $id_deploy $id_deploy/$project_package"
				if $(ssh -i $auto root@"$id_ip" "ls -d $id_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-services')
			for i in $SERVICES
			do
				service_ip=$(ecsip $i)
				if [ -z $service_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				service_deploy=/home/deploy

				echo -n "Unzip $project_package to $service_deploy"
				ssh -i $auto root@"$service_ip" "unzip -o -q -d $service_deploy $service_deploy/$project_package"
				if $(ssh -i $auto root@"$service_ip" "ls -d $service_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-shopping')
			for i in $SHOPPING
			do
				shopping_ip=$(ecsip $i)
				if [ -z $shopping_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				shopping_deploy=/home/deploy

				echo -n "Unzip $project_package to $shopping_deploy"
				ssh -i $auto root@"$shopping_ip" "unzip -o -q -d $shopping_deploy $shopping_deploy/$project_package"
				if $(ssh -i $auto root@"$shopping_ip" "ls -d $shopping_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-pay')
			for i in $PAY
			do
				pay_ip=$(ecsip $i)
				if [ -z $pay_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				pay_deploy=/home/pay

				echo -n "Unzip $project_package to $pay_deploy"
				ssh -i $auto root@"$pay_ip" "unzip -o -q -d $pay_deploy $pay_deploy/$project_package"
				if $(ssh -i $auto root@"$pay_ip" "ls -d $pay_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-imgprocess')
			for i in $IMGPROCESS
			do
				imgprocess_ip=$(ecsip $i)
				if [ -z $imgprocess_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				imgprocess_deploy=/home/deploy

				echo -n "Unzip $project_package to $imgprocess_deploy"
				ssh -i $auto root@"$imgprocess_ip" "unzip -o -q -d $imgprocess_deploy $imgprocess_deploy/$project_package"
				if $(ssh -i $auto root@"$imgprocess_ip" "ls -d $imgprocess_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-promotion')
			for i in $PROMOTION
			do
				promotion_ip=$(ecsip $i)
				if [ -z $promotion_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				promotion_deploy=/home/deploy

				echo -n "Unzip $project_package to $promotion_deploy"
				ssh -i $auto root@"$promotion_ip" "unzip -o -q -d $promotion_deploy $promotion_deploy/$project_package"
				if $(ssh -i $auto root@"$promotion_ip" "ls -d $promotion_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
		'style-message')
			for i in $MESSAGE
			do
				message_ip=$(ecsip $i)
				if [ -z $message_ip ]; then
					echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
					exit 3
				fi
				message_deploy=/home/message

				echo -n "Unzip $project_package to $message_deploy"
				ssh -i $auto root@"$message_ip" "unzip -o -q -d $message_deploy $message_deploy/$project_package"
				if $(ssh -i $auto root@"$message_ip" "ls -d $message_deploy/$project_dirname" &> /dev/nul); then
					echo "${CSUCCESS} Success${CEND}"
					let UNZIP_RESULT+=1
				else
					echo "${CFAILURE} Fail${CEND}"
				fi
			done
			return $UNZIP_RESULT
			;;
	esac
}

startService() {
	case $project_name in
		'style-web')
			echo -ne "start ${CSUCCESS}web${CEND} service on" $1
			web_ip=$(ecsip $1)
			if [ -z $web_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$web_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$web_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
		'style-id')
			echo -ne "start ${CSUCCESS}id${CEND} service on" $1
			id_ip=$(ecsip $1)
			if [ -z $id_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$id_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$id_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
		'style-shopping')
			echo -ne "start ${CSUCCESS}shopping${CEND} service on" $1
			shopping_ip=$(ecsip $1)
			if [ -z $shopping_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$shopping_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$shopping_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
		'style-services')
			echo -ne "start ${CSUCCESS}api${CEND} service on" $1
			service_ip=$(ecsip $1)
			if [ -z $service_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$service_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$service_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;

		'style-pay')
			echo -ne "start ${CSUCCESS}pay${CEND} service on" $1
			pay_ip=$(ecsip $1)
			if [ -z $pay_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$pay_ip" "su - pay -c 'sh /home/pay/run.sh'"
			if [ $(ssh -i $auto root@"$pay_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;

		'style-imgprocess')
			echo -ne "start ${CSUCCESS}img process${CEND} service on" $1
			imgprocess_ip=$(ecsip $1)
			if [ -z $imgprocess_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$imgprocess_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$imgprocess_ip" "ss -tunlp | grep java | grep -E '3008' | wc -l") -eq 1 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
		'style-message')
			echo -ne "start ${CSUCCESS}message${CEND} service on" $1
			message_ip=$(ecsip $1)
			if [ -z $message_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$message_ip" "su - message -c 'sh /home/message/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$message_ip" "ss -tunlp | grep java | grep -E '9007' | wc -l") -eq 1 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
		'style-promotion')
			echo -ne "start ${CSUCCESS}promotion${CEND} service on" $1
			promotion_ip=$(ecsip $1)
			if [ -z $promotion_ip ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 13
			fi
			ssh -i $auto root@"$promotion_ip" "su - deploy -c 'sh /home/deploy/run.sh' &> /dev/null"
			if [ $(ssh -i $auto root@"$promotion_ip" "ss -tunlp | grep java | grep -E '9000|9001' | wc -l") -eq 2 ]; then
				echo "${CSUCCESS} Success${CEND}"
				return 0
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			;;
	esac
}

setWeightTo0() {
	case $project_name in
		'style-web')
			web_id=$(ecsid $1)
			if [ -z $web_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 6
			fi

			# Remove ecs from intra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $web_intra --BackendServers "[{'ServerId': \"$web_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $web_intra --filter BackendServers.BackendServer | grep -A1 "$web_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi

			sleep 5

			# remvoe ecs from extra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $web_extra --BackendServers "[{'ServerId': \"$web_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $web_extra --filter BackendServers.BackendServer | grep -A1 "$web_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;
		'style-id')
			id_id=$(ecsid $1)
			if [ -z $id_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 6
			fi

			# Remove ecs from intra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $id_intra --BackendServers "[{'ServerId': \"$id_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $id_intra --filter BackendServers.BackendServer | grep -A1 "$id_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi

			sleep 5

			# remvoe ecs from extra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $id_extra --BackendServers "[{'ServerId': \"$id_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $id_extra --filter BackendServers.BackendServer | grep -A1 "$id_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;
		'style-shopping')
			shopping_id=$(ecsid $1)
			if [ -z $shopping_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 6
			fi

			# Remove ecs from intra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_intra --BackendServers "[{'ServerId': \"$shopping_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_intra --filter BackendServers.BackendServer | grep -A1 "$shopping_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# remvoe ecs from extra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_extra --BackendServers "[{'ServerId': \"$shopping_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_extra --filter BackendServers.BackendServer | grep -A1 "$shopping_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;
		'style-services')
			service_id=$(ecsid $1)
			if [ -z $service_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 6
			fi

			# Remove ecs from intra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $service_intra --BackendServers "[{'ServerId': \"$service_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $service_intra --filter BackendServers.BackendServer | grep -A1 "$service_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# remvoe ecs from extra slb
			echo -n "Remove [${CSUCCESS}$1${CEND}] from extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $service_extra --BackendServers "[{'ServerId': \"$service_id\", 'Weight': '0'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $service_extra --filter BackendServers.BackendServer | grep -A1 "$service_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 0 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;
	esac
}

setWeightTo100() {
	case $project_name in
		'style-web')
			web_id=$(ecsid $1)
			if [ -z $web_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 7
			fi

			# Add ecs to intra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $web_intra --BackendServers "[{'ServerId': \"$web_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $web_intra --filter BackendServers.BackendServer | grep -A1 "$web_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# Add ecs to extra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $web_extra --BackendServers "[{'ServerId': \"$web_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $web_extra --filter BackendServers.BackendServer | grep -A1 "$web_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;

		'style-id')
			id_id=$(ecsid $1)
			if [ -z $id_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 7
			fi
			# Add ecs to intra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $id_intra --BackendServers "[{'ServerId': \"$id_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $id_intra --filter BackendServers.BackendServer | grep -A1 "$id_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# Add ecs to extra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $id_extra --BackendServers "[{'ServerId': \"$id_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $id_extra --filter BackendServers.BackendServer | grep -A1 "$id_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;

		'style-shopping')
			shopping_id=$(ecsid $1)
			if [ -z $shopping_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 7
			fi
			# Add ecs to intra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_intra --BackendServers "[{'ServerId': \"$shopping_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_intra --filter BackendServers.BackendServer | grep -A1 "$shopping_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# Add ecs to extra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_extra --BackendServers "[{'ServerId': \"$shopping_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $shopping_extra --filter BackendServers.BackendServer | grep -A1 "$shopping_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;

		'style-services')
			service_id=$(ecsid $1)
			if [ -z $service_id ]; then
				echo "${CFAILURE}Call Aliyun API Failure, Quit${CEND}"
				exit 7
			fi
			# Add ecs to intra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to intra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $service_intra --BackendServers "[{'ServerId': \"$service_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $service_intra --filter BackendServers.BackendServer | grep -A1 "$service_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 1
			fi
			sleep 5
			# Add ecs to extra slb
			echo -n "Add [${CSUCCESS}$1${CEND}] to extra slb"
			$slb SetBackendServers --RegionId 'cn-hangzhou' --LoadBalancerId $service_extra --BackendServers "[{'ServerId': \"$service_id\", 'Weight': '100'}]" &> /dev/null
			if [ $($slb DescribeLoadBalancerAttribute --RegionId 'cn-hangzhou' --LoadBalancerId $service_extra --filter BackendServers.BackendServer | grep -A1 "$service_id" | tail -n 1 | awk -F': ' '{print $2}') -eq 100 ]; then
				echo "${CSUCCESS} Success${CEND}"
			else
				echo "${CFAILURE} Fail${CEND}"
				return 2
			fi
			;;
	esac
}

case $1 in
-v | --version)
	echo "Version: $version"
	;;
-h|--help)
	help
	;;
'-cp')
	if [ -z "$2" ]; then
		echo
		echo "Syntax Error"
		help
	else
		if $(echo "$2" | grep '\.zip$' &> /dev/null); then
			package=$2
			COPY=1
		else
			echo "package name error"
			help
		fi
	fi
	;;
'-bp')
	if [ -z "$2" ]; then
		echo
		echo "Syntax Error"
		help
	else
		if $(echo "$2" | grep '\.zip$' &> /dev/null); then
			package=$2
			BACKUP=1
		else
			echo "package name error"
			help
		fi
	fi
	;;
'-ap')
	if [ -z "$2" ]; then
		echo
		echo "Syntax Error"
		help
	else
		if $(echo "$2" | grep '\.zip$' &> /dev/null); then
			package=$2
			BACKUP=1
			COPY=1
			STARTSERVICE=1
		else
			echo "package name error"
			help
		fi
	fi
	;;
*)
	help
	;;
esac


if [ $COPY -eq 1 ] && [ $BACKUP -eq 1 ] && [ $STARTSERVICE -eq 1 ]; then
	project
	echo "================================= Step 1: SCP Package ================================="
	scp_package
	result=$?
	if [ $result -ne 1 ] && [ $result -ne 2 ]; then
		echo "${CFAILURE}SCP FAILURE, QUIT.${CEND}"
		exit 10
	fi
	echo "================================= Step 2: Backup Package ================================="
	backup
	result=$?
	if [ $result -ne 1 ] && [ $result -ne 2 ]; then
		echo "${CFAILURE}BACKUP FAILURE, QUIT.${CEND}"
		exit 11
	fi

	echo "================================= Step 3: Unzip Package ================================="
	unzipPackage
	result=$?
	if [ $result -ne 1 ] && [ $result -ne 2 ]; then
		echo "${CFAILURE}Unzip FAILURE, QUIT.${CEND}"
		exit 16
	fi


	if [ $project_name == 'style-web' ]; then
		echo "============================ Step 4: Setting SLB & Start Service ============================="
		
		for i in $WEB
		do
			setWeightTo0 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Remove $i from SLB FAILURE, QUIT.${CEND}"
				exit 12
			fi

			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 14
			fi

			setWeightTo100 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Add $i to SLB FAILURE, QUIT.${CEND}"
				exit 15
			fi
			sleep 20
		done

	elif [ $project_name == 'style-id' ]; then
		echo "============================ Step 4: Setting SLB & Start Service ============================="
		
		for i in $ID
		do
			setWeightTo0 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Remove $i from SLB FAILURE, QUIT.${CEND}"
				exit 12
			fi

			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 14
			fi

			setWeightTo100 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Add $i to SLB FAILURE, QUIT.${CEND}"
				exit 15
			fi
			sleep 20
		done
	elif [ $project_name == 'style-shopping' ]; then
		echo "============================ Step 4: Setting SLB & Start Service ============================="
		
		for i in $SHOPPING
		do
			setWeightTo0 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Remove $i from SLB FAILURE, QUIT.${CEND}"
				exit 12
			fi

			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 14
			fi

			setWeightTo100 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Add $i to SLB FAILURE, QUIT.${CEND}"
				exit 15
			fi
			sleep 20
		done
	elif [ $project_name == 'style-services' ]; then
		echo "============================ Step 4: Setting SLB & Start Service ============================="
		
		for i in $SERVICES
		do
			setWeightTo0 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Remove $i from SLB FAILURE, QUIT.${CEND}"
				exit 12
			fi

			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 14
			fi

			setWeightTo100 $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Add $i to SLB FAILURE, QUIT.${CEND}"
				exit 15
			fi
			sleep 20
		done
	elif [ $project_name == 'style-pay' ]; then
		echo "================================= Step 4: Start Service =================================="
		for i in $PAY
		do
			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 17
			fi
		done
	elif [ $project_name == 'style-imgprocess' ]; then
		echo "================================= Step 4: Start Service =================================="
		for i in $IMGPROCESS
		do
			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 18
			fi
		done

	elif [ $project_name == 'style-message' ]; then
		echo "================================= Step 4: Start Service =================================="
		for i in $MESSAGE
		do
			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 19
			fi
		done

	elif [ $project_name == 'style-promotion' ]; then
		echo "================================= Step 4: Start Service =================================="
		for i in $PROMOTION
		do
			startService $i
			result=$?
			if [ $result -ne 0 ]; then
				echo "${CFAILURE}Start Service $i FAILURE, QUIT.${CEND}"
				exit 20
			fi
		done
	fi

elif [ $BACKUP -eq 1 ] && [ $COPY -eq 0 ] && [ $STARTSERVICE -eq 0 ]; then
	project
	backup
elif [ $COPY -eq 1 ] && [ $BACKUP -eq 0 ] && [ $STARTSERVICE -eq 0 ]; then
	project
	scp_package
fi

