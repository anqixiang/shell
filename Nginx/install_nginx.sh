#!/bin/bash
#AUTHOR:anqixiang
#FUNCTION:安装Nginx
#SYSTEM:Ubuntu16.04

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
#ubuntu在线安装
Online_Install_apt(){
    ping -c2 -w1 -i0.2 www.baidu.com &> /dev/null
    [ $? -ne 0 ] && cecho 31 "不能访问外网" && exit 71
    apt-get -y install nginx && cecho 96 "success!" && exit 0
    cecho 31 "fail!" && exit 71
}

#ubuntu离线安装
Offline_Install_apt(){
    deb_name="nginx_V1.10.3_ubuntu16.04.4.tgz"	#离线包名
    [ ! -f ${deb_name} ] && cecho 31 "${deb_name}不存在" && exit 71
    tar xvf ${deb_name}
    deb_path="${current_dir}/nginx_V1.10.3_ubuntu16.04.4"
    dpkg -i ${deb_path}/*.deb && rm -rf ${deb_path} && cecho 96 "success!" && exit 0
    cecho 31 "fail!" && exit 71
}

#打印脚本说明
Print(){
    cat  << EOF
#################################################################################
#1、AUTHOR:anqixiang
#2、DATE:2020-01-11
#3、功能：安装nginx
#4、注意事项：离线安装需确保该脚本的同级目录下有正确的离线包
#################################################################################
EOF
}

#系统版本
System_Version(){
    cat << EOF
1.ubuntu
2.CentOS/RedHat
EOF
}

#主函数
main(){
    Print
    cecho 32 "开始执行......"
    echo "1.离线安装"
    echo "2.在线安装"
    read -p  "请选择:" choice
    case ${choice} in
    1)
	System_Version
	read -p "请选择系统版本:" choice
	case ${choice} in
        1)
            Offline_Install_apt;;
        2)
            cecho 31 "暂不支持";;
        *)
            cecho 31 "Invalid option!"
        esac
	;;
    2)
	System_Version
        read -p "请选择系统版本:" choice
        case ${choice} in
        1)
            Online_Install_apt;;
        2)
            cecho 31 "暂不支持";;
        *)
            cecho 31 "Invalid option!"
        esac
        ;;
    *)
	cecho 31 "Invalid option!"
    esac		
}
main
