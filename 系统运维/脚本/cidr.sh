#!/bin/bash
# Version: 1.0

number=32
dir="/root/cidr"
file="$dir/ip.txt"
chinanet="$dir/chinanet"
unicom="$dir/unicom"
other="$dir/other"

mkdir $dir &> /dev/null

> $file
> $chinanet
> $unicom
> $other

if ! $(which whois &> /dev/null); then
	yum install -y jwhois
fi

# Download file 
wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest -O $file

grep 'apnic|CN|ipv4' $file | awk -F'|' '{print $4,$5}' | while read cidr count
do
	pow=0
	while :
	do
		if [ $(echo "2^${pow}" | bc) -eq $count ]; then
			let mask=$number-$pow
			netname=$(whois $cidr@whois.apnic.net | grep 'netname' | awk -F':|[[:space:]]+' '{print $3}' | awk -F'-' '{print $1}')
			case $netname in
				'CHINANET')
					echo $cidr/$mask >> $chinanet
					;;
				'UNICOM')
					echo $cidr/$mask >> $chinanet
					;;
				*)
					echo $cidr/$mask >> $chinanet
					;;
			esac
			break
		else
			let pow++
		fi
	done
done
