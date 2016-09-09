#!/bin/bash

NSENTER=nsenter

if ! $(which $NSENTER &> /dev/null); then
	echo
	echo -e "\033[31m[Error]\033[m Can not find command: nsenter"
	echo
	exit 1
fi

USAGE() {
	echo
	echo "$(basename $0)"
	echo -e "\t--help\t:show help"
	echo -e "\t--pid\t:show pid about container_id or container_name"
	echo -e "\t--enter\t:enter the container that you give"
	echo
}


GET_CPID() {
	if ! $(docker inspect --format "{{.State.Pid}}" $1 &> /dev/null); then
		echo
		echo -e "\033[31m[Error]\033[m No such CONTAINER ID or CONTAINER NAME"
		echo
		exit 4
	else
		CPID=$(docker inspect --format "{{.State.Pid}}" $1)
	fi
}

ENTER_CONTAINER() {
	nsenter --target $CPID --mount --uts --ipc --net --pid
}

case $1 in
	--pid)
		if [ -z $2 ]; then
			echo 
			echo -e "\033[31m[Error]\033[m Please assign a container"
			echo 
		else
			GET_CPID $2
			if [ $CPID -eq 0 ];then
				echo
				echo -e "\033[33m[Warning]\033[m Container $2 is stopped"
				echo
			else
				echo
				echo "Container $2 PID: $CPID"
				echo
			fi
		fi
		;;
	--enter)
		if [ -z $2 ]; then
			echo 
			echo -e "\033[31m[Error]\033[m Please assign a container and must be running"
			echo 
		else
			GET_CPID $2
			if [ $CPID -eq 0 ];then
				echo
				echo -e "\033[33m[Warning]\033[m Container $2 is stopped"
				echo
			else
				ENTER_CONTAINER
			fi
		fi
		;;
	--help)
		USAGE
		;;
	*)
		USAGE
		;;
esac
