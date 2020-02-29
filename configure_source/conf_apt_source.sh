#!/bin/bash
#AUTHOR:anqixiang
#MODIFY:

if [ `whoami` != "root" ];then
    echo "This script must be runing as root!!!"
    exit 71
fi

export LC_ALL=en_US.UTF-8
current_dir=$(cd `dirname $0` && pwd)   #当前工作目录

cecho(){
    echo -e "\033[$1m$2\033[0m"
}

######################功能函数######################
#配置本地apt源
Conf_Apt(){
    apt_path=/debs
    [ ! -f ${current_dir}/archives/Packages.gz ] && cecho 31 "${current_dir}没有有效源" && exit 71
    mkdir ${apt_path}
    cp -rp ${current_dir}/archives ${apt_path}/
    [ ! -f /etc/apt/sources.list.save ] &&  cp /etc/apt/sources.list{,.bak}
    tee /etc/apt/sources.list << EOF
deb file:${apt_path} archives/
EOF
     apt-get update --allow-insecure-repositories &>/dev/null
     apt-get install -f &>/dev/null   
}

#配置ubuntu14.04网络源
Conf_Ubuntu14.04(){
    [ ! -f /etc/apt/sources.list.save ] &&  cp /etc/apt/sources.list{,.bak}
    tee /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
EOF
    apt-get update
}

#配置ubuntu16.04网络源
Conf_Ubuntu16.04(){
    [ ! -f /etc/apt/sources.list.save ] &&  cp /etc/apt/sources.list{,.bak}
    tee /etc/apt/sources.list << EOF
deb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties
deb http://archive.canonical.com/ubuntu xenial partner
deb-src http://archive.canonical.com/ubuntu xenial partner
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse    
EOF
    apt-get update
}

#配置ubuntu18.04网络源
Conf_Ubuntu18.04(){
    [ ! -f /etc/apt/sources.list.save ] &&  cp /etc/apt/sources.list{,.bak}
    tee /etc/apt/sources.list << EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
EOF
    apt-get update
}

#打印脚本说明
Print(){
    cat  << EOF
#################################################################################
#1、AUTHOR:anqixiang
#2、DATE:2020-01-11
#3、功能：为ubuntu系统配置本地apt源和网络apt源
#4、注意事项：配置本地apt源需确保该脚本的同级目录下有正确的离线apt源
#5、制作离线apt源可参考：https://blog.csdn.net/anqixiang/article/details/100018413
#################################################################################
EOF
}

#系统版本
System_Version(){
    cat << EOF
1.ubuntu14.04
2.ubuntu16.04
3.ubuntu18.04
EOF
}

#主函数
main(){
    Print
    cecho 32 "开始执行......"
    echo "1.本地源"
    echo "2.网络源"
    read -p  "请选择:" choice
    case ${choice} in
    1)
	Conf_Apt;;
    2)
	System_Version
	read -p "请选择系统版本:" choice
	case ${choice} in
	1)
	    Conf_Ubuntu14.04;;
	2)
	    Conf_Ubuntu16.04;;
	3)
	    Conf_Ubuntu18.04;;
	*)
	    cecho 31 "Invalid option!"
        esac
	;;	    
    *)
	cecho 31 "Invalid option!"
    esac		
}
main
