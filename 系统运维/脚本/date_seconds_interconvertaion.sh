#!/bin/bash

# Author: felix.zhang
# Date: 2016-08-21
# QQ: 573713035
# Function: 将给定的秒数转换为日期或者是将给定的日期转换为秒数。注：该秒数为当前时间距离1970-1-1 00:00:00所经过的秒数

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

function Usage() {
	echo 
	echo -e "\033[32mCommand:\033[m"
	echo -e "\t$0 --date-to-seconds 'date' | --seconds-to-date 'seconds'"
	echo -e "\033[32mFormat:\033[m"
	echo -e "\tdate format: '1970-1-1 00:00:00'"
	echo -e "\tseconds format: $(date +%s)"
	echo
	echo -e "\033[31mNote: date and seconds must be use quotes\033[m"
	echo -e "\033[31mNote: please make sure that the machine is the right time\033[m"
	echo
}

function CheckDateTime() {
	local datetime_match_rule="^(([[:space:]]*)([1-9][0-9]{3})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])([[:space:]]{1,})([0-1][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])([[:space:]]*))$"

	if [ $# -ne 1 ]; then
		datetimeCheckResult=1
	else
		if [[ $1 =~ $datetime_match_rule ]]; then
			datetimeCheckResult=0
		else
			datetimeCheckResult=2
		fi
	fi
}

function CheckSeconds() {
	local seconds_match_rule="^(([[:space:]]*)([-]?[[:digit:]]{1,17})([[:space:]]*))$"

	if [ $# -ne 1 ]; then
		secondsCheckResult=1
	else
		if [[ $1 =~ $seconds_match_rule ]]; then
			secondsCheckResult=0
		else
			secondsCheckResult=2
		fi
	fi
}

function ToSeconds() {
	while :
	do
		CheckDateTime "$1"

		if [ $datetimeCheckResult -eq 1 -o $datetimeCheckResult -eq 2 ];then
			echo "Invalid date,Please try again"
			continue
		elif [ $datetimeCheckResult -eq 0 ]; then
			returnSeconds=$(date -d "$1" +%s)
			break
		fi
	done
	
}

function ToDate() {
	while :
	do
		CheckSeconds "$1"

		if [ $secondsCheckResult -eq 1 -o $secondsCheckResult -eq 2 ]; then
			echo "Invalid seconds,Please try again"
			continue
		elif [ $secondsCheckResult -eq 0 ]; then
			returnDate=$(date -d "$(($1-$(date +%s)))sec" +'%F %T')
			break
		fi
	done
}

[ $# -ne 2 ] && Usage && exit 4

case $1 in
--date-to-seconds)
	shift 1
	ToSeconds "$1"
	echo "Date:" $1
	echo "Seconds:" $returnSeconds
	;;
--seconds-to-date)
	shift 1
	ToDate "$1"
	echo "Seconds:" $1
	echo "Date:" $returnDate
	;;
*)
	Usage
	;;
esac
