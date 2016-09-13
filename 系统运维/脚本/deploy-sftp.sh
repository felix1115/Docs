#!/bin/bash
# Author: Felix.zhang
# QQ: 573713035
# Date: 2016-09-12
# Function: Deploy SFTP Server

SSHD_CONFIG=/etc/ssh/sshd_config
SFTP_DATA=/data/test
SFTP_GROUP=sftp
UPLOAD=upload


[ -d $SFTP_DATA ] || mkdir -p $SFTP_DATA

if [ $(sed -n '/^Subsystem.*sftp-server$/p' $SSHD_CONFIG | wc -l) -ne 0 ]; then
	sed -i '/^Subsystem.*sftp-server$/s/^/#/' $SSHD_CONFIG
fi

if [ $(sed -n '/^Subsystem.*internal-sftp$/p' /etc/ssh/sshd_config | wc -l) -ne 0 ]; then
	echo
	echo -e  "\033[33m[Warning] The server may has been configed lsftp, please check it\033[m"
	echo
	echo '-----------------------------------------'
	grep -A10 '^Subsystem' $SSHD_CONFIG
	echo '-----------------------------------------'
	echo
	exit 1
else
	cat >> $SSHD_CONFIG <<-EOF
Subsystem sftp internal-sftp
    Match Group $SFTP_GROUP
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp
    ChrootDirectory $SFTP_DATA/%u

EOF

fi


while :
do
	echo -en "\033[32m[Username]: \033[m"
	read username
	if [ -z $username ]; then
		echo -e "\033[33m[Warning] Username can not null , please try again\033[m"
		continue
	else
		if $(awk -F: '{print $1}' /etc/passwd | grep "$username" &> /dev/null); then
			echo -en "\033[33m[Warning] $username is exist, please use other username.\033[m"
			echo
			continue
		fi

		while :
		do
			echo -en "\033[32m[Password $username]: \033[m"
			read -s password
			echo
			if [ -z $password ]; then
				echo -e "\033[33m[Warning] Password can not null , please try again\033[m"
				continue
			else
				echo -en "\033[32m[Confirm Password $username]: \033[m"
			    read -s confirmpassword
				echo
				if [ $confirmpassword != $password ]; then
					echo -e "\033[33m[Warning] Password mismatch, please try again\033[m"
					continue
				else
					break
				fi
			fi
		done

		# Create user/ set password and make directory
		useradd -M -g $SFTP_GROUP -s /sbin/nologin  $username &> /dev/null
		if [ $? -ne 0 ]; then
			echo -e "\033[31mCreate username $username fail, please check it\033[m"
			break
		else
			echo "$pasword" | password --stdin $username &> /dev/null
			mkdir -p $SFTP_DATA/$username/$UPLOAD
			chown $username:$SFTP_GROUP $SFTP_DATA/$username/$UPLOAD
			chmod 750 $SFTP_DATA/$username/$UPLOAD

			echo -e "\033[32mCreate User $username Successful.\033[m"
		fi
	fi

	read -p "Continue? [yes|no] " continue
	if [ -z $continue ] || [ $continue == 'no' ] || [ $continue == 'n' ];then
		echo "Quit"
        /etc/init.d/sshd reload &> /dev/null
		break
	elif [ $continue == 'yes' ] || [ $continue == 'y' ];then
		continue
	else
		echo "Unknown Input , Quit"
        /etc/init.d/sshd reload &> /dev/null
		break
	fi
done

