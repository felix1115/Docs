#!/bin/bash

NGINX_CACHE_DIR="/usr/local/source/nginx/cache"

CSI=$(echo -e "\033[")
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CYELLOW="${CSI}1;33m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CWARNING="$CYELLOW"
CEND="${CSI}0m"

HELP=0
FILE=0
DEL=0
SHOW=0

help() {
    echo
    echo "Usage: $0 [-h] | [-s] | -d <url> | -f <url_purge_file>"
    echo
    echo -e "\t -h: Show help"
    echo -e "\t -s: Show all key in Cache Directory: $NGINX_CACHE_DIR"
    echo -e "\t -d: Specify one url you want to delete"
    echo -e "\t -f: Specify the uri file name. e.g: $0 -s > /tmp/urls"
    echo
}

deleteKey() {
	key=$(grep -ra "$URL\$" $NGINX_CACHE_DIR | awk -F':' '{print $1}')
	if [ x"$key" == 'x' ]; then
		echo "${CWARNING}No Such Key: $URL${CEND}"
		exit 6
	else
		rm -f $key &> /dev/null
		retval=$?
		if [ $retval -eq 0 ]; then
			echo "Delete Key: $key ${CSUCCESS}Successful${CEND}"
			exit 0
		else
			echo "Delete Key: $key ${CFAILURE}Failed${CEND}"
			exit 7
		fi
	fi
}

deleteKeyFromFile() {
	while read line
	do
		if $(echo $line | grep -E '^#|^$' &> /dev/null); then
			continue
		else
			URL=$line
			key=$(grep -ra "$URL\$" $NGINX_CACHE_DIR | awk -F':' '{print $1}')
			if [ x"$key" == 'x' ]; then
				echo "${CWARNING}No Such Key: $URL${CEND}"
				continue
			else
				rm -f $key &> /dev/null
				retval=$?
				if [ $retval -eq 0 ]; then
					echo "Delete Key: $key ${CSUCCESS}Successful${CEND}"
					continue
				else
					echo "Delete Key: $key ${CFAILURE}Failed${CEND}"
					continue
				fi
			fi
		fi
	done < $1
}

while getopts "d:f:hs" options
do
    case $options in
        'd')
            DELURL=$OPTARG
            DEL=1
            ;;
        'f')
            FILENAME=$OPTARG
            FILE=1
            ;;
        'h')
            HELP=1
            ;;
		's')
			SHOW=1
			;;
    esac
done

# show help
if [ $HELP -eq 1 ]; then
    help
    exit 0
fi

# Show all key in cache directory
if [ "$SHOW" -eq 1 ]; then
	count=0
	allKeys=$(grep -ra 'KEY:' $NGINX_CACHE_DIR | awk -F 'KEY: ' '{print $NF}')
	if [ x"$allKeys" == 'x' ]; then
		echo "${CWARNING}No any keys${CEND}"
	else
		echo
		echo "####################################################"
		for i in $allKeys
		do
			echo "$i"
			let count++
		done
		echo "####################################################"
		echo
		echo "## Total: $count"
		echo
	fi

	exit 0
fi

# check nginx cache directory
if [ ! -d $NGINX_CACHE_DIR ]; then
    echo "${CFAILURE}Can not find Nginx Cache Directory: $NGINX_CACHE_DIR ${CEND}"
    exit 2
fi

if [ $DEL -eq 1 ]; then
	URL="$DELURL"
	deleteKey
elif [ $DEL -eq 0 ] && [ $FILE -eq 1 ]; then
	deleteKeyFromFile $FILENAME
else
    help
fi