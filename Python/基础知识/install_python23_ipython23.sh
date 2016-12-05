#!/bin/bash

# install python 2 and ipython2 or python3 and ipython3

CSI=$(echo -e "\033[")
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CYELLOW="${CSI}1;33m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CWARNING="$CYELLOW"
CEND="${CSI}0m"

check=0
ipython=0

PackageDependency='gcc gcc-c++ unzip zlib zlib-devel bzip2 bzip2-devel bzip2-lib sqlite sqlite-devel ncurses-devel readline-devel patch'
Ipython_Need_PackageName='
traitlets
setuptools
ipython_genutils
decorator
Pygments
pexpect
ptyprocess
backports.shutil_get_terminal_size
six
pathlib2
pickleshare
wcwidth
prompt_toolkit
simplegeneric
ipython
'

Ipython2_Need_PackageName='
traitlets
setuptools
ipython_genutils
decorator
Pygments
pexpect
ptyprocess
enum
backports.shutil_get_terminal_size
six
pathlib2
pickleshare
wcwidth
prompt_toolkit
simplegeneric
ipython
'

checkPythons() {
	Pythons=$(find / -name python* -type f -executable | grep -E '^/bin|^/usr/bin|^/sbin|^/usr/sbin|^/usr/local/bin|^/usr/local/sbin' | grep -v 'config$' | awk -F'/' '{print $NF}')
}

help() {
	echo
	echo "${CWARNING}Usage: $0 -p <python-file-name> [-i]${CEND}"
	echo -e "\t -p: python file name, please use absolutely path"
	echo -e "\t -i: install ipython. if omited, ipython is not be installed"
	echo "${CWARNING}Example: $0 -p Python-2.7.12.tgz -i${CEND}"
	exit 0
}

checkYum() {
	yum clean all &> /dev/null
	yum makecache &> /dev/null
	retval=$?
	if [ $retval -eq 0 ]; then
		return 0
	else
		return 1
	fi
}

checkIpythonPackages() {
	for p in $Ipython_Need_PackageName
	do
		for p1 in $(ls -rtd $PackageDirectory/${p}-*)
		do
			if [ -f "$p1" ]; then
				break
			else
				continue
			fi
			return 1
		done
	done
	return 0
}

checkFileType() {
	if $(echo $1 | grep '\.tar$' &> /dev/null); then
		return 1
	elif $(echo $1 | grep '\.zip$' &> /dev/null); then
		return 2
	elif $(echo $1 | grep '\.tar\.gz$' &> /dev/null); then
		return 3
	elif $(echo $1 | grep '\.tgz$' &> /dev/null); then
		return 3
	elif $(echo $1 | grep '\.tar\.xz$' &> /dev/null); then
		return 4
	elif $(echo $1 | grep '\.txz$' &> /dev/null); then
		return 4
	else
		return 5
	fi
}

unPackages() {
	PackageName=$1
	checkFileType $PackageName
	retval=$?
	cd $PackageDirectory
	if [ $retval -eq 1 ]; then
		tar -m -xf $PackageName -C $PackageDirectory
	elif [ $retval -eq 2 ]; then
		unzip -o -q -d $PackageDirectory $PackageName
	elif [ $retval -eq 3 ]; then
		tar -m -zxf $PackageName -C $PackageDirectory
	elif [ $retval -eq 4 ]; then
		tar -m -jxf $PackageName -C $PackageDirectory
	else
		echo "${CFAILURE}Unknown file type${CEND}"
		exit 17
	fi
	return 0
}

installPython() {
	unPackages $PythonName
	if [ -d "$PackageDirectory/$PythonVersion" ]; then
		cd $PackageDirectory/$PythonVersion
		./configure &> /dev/null
		make install &> /dev/null
	fi

	if $(which "python$PythonShortVersion" &> /dev/null); then
		return 0
	else
		return 1
	fi
}

installIpython() {
	for p in $Ipython_Need_PackageName
	do
		for p1 in $(ls -rtd $PackageDirectory/${p}-*)
		do
			if [ -d "$p1" ]; then
					cd $p1
					python$PythonShortVersion setup.py install &> /dev/null
					retval=$?
					if [ $retval -eq 0 ]; then
						echo "${CSUCCESS}install $p1 successful${CEND}"
					else
						echo "${CFAILURE}install $p1 failure${CEND}"
						exit 18
					fi
			else
				continue
			fi
		done
	done
}

# main program
if [ $# -ne 3 ] && [ $# -ne 2 ]; then
	help
fi


case $1 in
'-p')
	PythonPathName=$2
	if [ -z "$PythonPathName" ]; then
		echo "${CFAILURE}Please assign python package name ${CEND}"
		exit 12
	elif [ ! -f "$PythonPathName" ]; then
		echo "${CFAILURE}No such python package [$PythonPathName]${CEND}"
		exit 13
	else
		PackageDirectory=$(dirname $PythonPathName)
		PythonName=$(basename $PythonPathName)
		PythonVersion=$(echo ${PythonName%.*})
		PythonShortVersion=$(echo ${PythonVersion} | awk -F'-' '{print $2}' | awk -F'.' '{print $1"."$2}')
		PythonMasterVersion=$(echo ${PythonVersion} | awk -F'-' '{print $2}' | awk -F'.' '{print $1}')
		shift 2
	fi

	if [ -z "$1" ]; then
		ipython=0
	elif [ "$1" == '-i' ]; then
		ipython=1
	else
		ipython=0
	fi
	;;
'-i')
	ipython=1
	shift 1

	if [ -z "$1" ]; then
		echo "${CFAILURE}Please use -p options to assign python file name , use absulutely path${CEND}"
		exit 14
	elif [ "$1" == '-p' ]; then
		PythonPathName=$2
		if [ -z "$PythonPathName" ]; then
			echo "${CFAILURE}Please assign python package name ${CEND}"
			exit 12
		elif [ ! -f "$PythonPathName" ]; then
			echo "${CFAILURE}No such python package [$PythonPathName]${CEND}"
			exit 13
		else
			PackageDirectory=$(dirname $PythonPathName)
			PythonName=$(basename $PythonPathName)
			PythonVersion=$(echo ${PythonName%.*})
			PythonShortVersion=$(echo ${PythonVersion} | awk -F'-' '{print $2}' | awk -F'.' '{print $1"."$2}')
			PythonMasterVersion=$(echo ${PythonVersion} | awk -F'-' '{print $2}' | awk -F'.' '{print $1}')
		fi
	else
		help
	fi
	;;

*)
	help
	;;
esac

checkPythons
echo "${CSUCCESS}Installed python version: ${CEND}"
echo "=========================="
for v in $Pythons
do
	if [ "$v" == "python$PythonShortVersion" ]; then
		check=1
		echo " $v"
	else
		echo " $v"
	fi
done
echo "=========================="
echo
if [ $check -eq 1 ]; then
	echo "${CSUCCESS}Python $PythonShortVersion has been installed${CEND}"
	exit 0
fi
echo

# check yum repos and install package
checkYum
retval=$?
if [ $retval -eq 1 ]; then
	echo
	echo "${CFAILURE}Please check you yum repository! Quit${CEND}"
	exit 1
	echo
else
	yum install -y $PackageDependency &> /dev/null
fi

installPython
retval=$?
if [ $retval -eq 0 ]; then
	echo "${CSUCCESS}Python $PythonShortVersion install successful${CEND}"
	if [ $ipython -eq 0 ]; then
		echo "Quit"
		exit 0
	else
		if [ "$PythonMasterVersion" == '2' ]; then
			Ipython_Need_PackageName="$Ipython2_Need_PackageName"
		else
			Ipython_Need_PackageName="$Ipython_Need_PackageName"
		fi
		checkIpythonPackages
		retval=$?
		if [ $retval -eq 1 ]; then
			echo "${CFAILURE}No Package [$p] in [$PackageDirectory]${CEND} directory, Quit"
			exit 2
		else
			for p in $Ipython_Need_PackageName
			do
				for p1 in $(ls -rtd $PackageDirectory/${p}-*)
				do
					if [ -f "$p1" ]; then
						unPackages $p1
					else
						continue
					fi
				done
			done
		fi

		installIpython
	fi
else
	echo "${CFAILURE}Python $PythonShortVersion install failure${CEND}"
	exit 16
fi