#!/bin/bash
# Author: Felix.zhang
# QQ: 573713035
# Date: 2016-09-16
# Function: Auto install docker daemon

# define the path variable
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LANG=en_US.UTF-8

# define colors
CSI=$(echo -e "\033[")
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CFAILURE="$CRED"
CEND="${CSI}0m"

# Docker variable
dockerMajorKernel=3
dockerMinorKernel=10
dockerRepoUrl="https://yum.dockerproject.org"
DOCKER_DAEMON=dockerd
DOCKER_ENGINE=docker-engine

# Configuration File
ISSUE=/etc/issue
RELEASE=/etc/redhat-release

# check the system type
SystemVersion() {
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


# Check Kernel Version
KernelVersionCheck() {
	local kernelMajor=$(uname -r | awk -F'.' '{print $1}')
	local kernelMinor=$(uname -r | awk -F'.' '{print $2}')
	local kernelArch=$(uname -m)
	if [ $kernelMajor -gt $dockerMajorKernel ]; then
		kernelVersionCheckResult=1
	elif [ $kernelMajor -eq $dockerMajorKernel ] && [ $kernelMinor -ge $dockerMinorKernel ]; then
		kernelVersionCheckResult=1
	else
		kernelVersionCheckResult=2
	fi

	if [ $kernelArch == "x86_64" ]; then
		kernelArchResult=1
	else
		kernelArchResult=2
	fi
}

# check the network connect
DockerRepoNetwork() {
	curl --connect-timeout 10 --head $dockerRepoUrl &> /dev/null
	if [ $? -eq 0 ]; then
		dockerRepoNetworkResult=1
	else
		dockerRepoNetworkResult=2
	fi
}

# check the current user role
CurrentUserRole() {
if [ $(id -u) -eq 0 ]; then
	currentUserRoleResult=1
else
	currentUserRoleResult=2
fi

}

# check the docker daemon is or not installed
CheckDockerDaemon() {
	convertRelaseToMin=$(echo ${release,,})
	if $(which $DOCKER_DAEMON &> /dev/null); then
		dockerDaemonResult=1
	elif [ "$convertRelaseToMin" == "centos" ] || [ "$convertRelaseToMin" == "redhat" ]; then
		if $(rpm -q $DOCKER_ENGINE &> /dev/null); then
			dockerDaemonResult=1
		else
			dockerDaemonResult=2
		fi
	elif [ "$convertRelaseToMin" == "ubuntu" ]; then
		if $(apt list $DOCKER_ENGINE | grep installed &> /dev/null); then
			dockerDaemonResult=1
		else
			dockerDaemonResult=2
		fi
	fi
}

# Add docker repo
CR6() { 
	yum upate

	cat > /etc/yum.repos.d/docker.repo <<-EOF
	[dockerrepo]
	name=Docker Repository
	baseurl=https://yum.dockerproject.org/repo/main/centos/6/
	enabled=1
	gpgcheck=1
	gpgkey=https://yum.dockerproject.org/gpg
	EOF

	yum install -y docker-engine
}

CR7() {
	yum upate

	cat > /etc/yum.repos.d/docker.repo <<-EOF
	[dockerrepo]
	name=Docker Repository
	baseurl=https://yum.dockerproject.org/repo/main/centos/7/
	enabled=1
	gpgcheck=1
	gpgkey=https://yum.dockerproject.org/gpg
	EOF

	yum install -y docker-engine
}

UInstallPackage() {
	apt-get update
	apt-get install -y apt-transport-https ca-certificates linux-image-extra-$(uname -r) linux-image-extra-virtual sysv-rc-conf
	#apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
}


U12() {
	apt-get update
	apt-get install -y apt-transport-https ca-certificates
	echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" > /etc/apt/sources.list.d/docker.list

	apt-get install -y --force-yes docker-engine
}

U14() {
	UInstallPackage
	echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list

	apt-get install -y --force-yes docker-engine
}

U15() {
	UInstallPackage
	echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list

	apt-get install -y --force-yes docker-engine
}

U16() {
	UInstallPackage
	echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
	
	apt-get install -y --force-yes docker-engine
}

# auto start docker-engine when reboo
AutoStartDocker() {
	convertRelease=$(echo ${release,,})
	majorVersion=$(echo $version | awk -F'.' '{print $1}')
	if [ "$convertRelease" == 'centos' ] || [ "$convertRelease" == 'redhat' ]; then
		if [ $majorVersion -eq 6 ]; then
			chkconfig docker on
		elif [ $majorVersion -eq 7 ]; then
			systemctl enable docker
		fi
	elif [ $convertRelease == 'ubuntu' ]; then
		sysv-rc-conf docker on
	fi
}

InstallDockerDaemon() {
	convertRelease=$(echo ${release,,})
	majorVersion=$(echo $version | awk -F'.' '{print $1}')
	if [ "$convertRelease" == 'centos' ] || [ "$convertRelease" == 'redhat' ]; then
		if [ $majorVersion -eq 6 ]; then
			CR6
		elif [ $majorVersion -eq 7 ]; then
			CR7
		else
			echo "${CFAILURE}Only support CentOS 6/7 or RedHat 6/7${CEND}"
			exit 5
		fi
	elif [ "$convertRelease" == 'ubuntu' ]; then
		if [ $majorVersion -eq 12 ]; then
			U12
		elif [ $majorVersion -eq 14 ]; then
			U14
		elif [ $majorVersion -eq 15 ]; then
			U15
		elif [ $majorVersion -eq 16 ]; then
			U16
		else
			echo "${CFAILURE}Only support Ubuntu 12.04 14.04 15.10 16.04${CEND}"
			exit 6
		fi
	else
		echo "${CFAILURE}Only support CentOS 6/7 or RedHat 6/7 or Ubuntu 12.04 14.04 15.10 16.04${CEND}"
		exit 7
	fi

	AutoStartDocker
}
# exec function
SystemVersion
KernelVersionCheck
DockerRepoNetwork
CurrentUserRole
CheckDockerDaemon

# check os release and version, only support CentOS/RedHat/Ubuntu
if [ -z "$release" ] || [ -z "$version" ] || [ "$SystemVersion" == "Unknown" ]; then
	echo "${CFAILURE}Unknown OS, Only support CentOS/RedHat/Ubuntu${CEND}"
	exit 1
fi

# check kernel version and os arch is or not 64bit
if [ $kernelVersionCheckResult -eq 2 ]; then
	echo "${CFAILURE}Your kernel not support docker, please check your kernel version greate than 3.10${CEND}"
	exit 2
elif [ $kernelArchResult -eq 2 ]; then
	echo "${CFAILURE}Your system architecture not support docker, please check your kernel architecture${CEND}"
	exit 3
fi

# check the host is or not connect internet
if [ $dockerRepoNetworkResult -eq 2 ]; then
	echo "${CFAILURE}Can not connect to docker repo, please check your network setting.${CEND}"
	exit 4
fi

# check the docker daemon is or not installed
if [ $dockerDaemonResult -eq 1 ]; then
	echo "${CGREEN}Docker may has been installed , please check it.${CEND}"
	echo "Quit"
	exit 0
fi

# install docker daemon
if [ $currentUserRoleResult -eq 1 ]; then
	InstallDockerDaemon
elif [ $currentUserRoleResult -eq 2 ]; then
	sudo bash $0
fi
