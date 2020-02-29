#!/bin/bash
#AUTHOR:anqixiang
#MODIFY:

if [ `whoami` != "root" ];then
    echo "This script must be runing as root!!!"
    exit 71
fi

export LC_ALL=en_US.UTF-8
current_dir=$(cd `dirname $0` && pwd)   #当前工作目录
nginx_path="/etc/nginx"	#或者为/usr/local/nginx

cecho(){
    echo -e "\033[$1m$2\033[0m"
}

######################功能函数######################
#配置Nginx主配置文件
Conf_Master(){
    [ ! -f ${nginx_path}/nginx.conf ] && cecho "Nginx路径错误,请修改脚本" && exit 71
    [ ! -f ${nginx_path}/nginx.conf.bak ] &&  cp ${nginx_path}/nginx.conf{,.bak}
    cat > ${nginx_path}/nginx.conf << EOF
user www-data;
worker_processes auto;
error_log off;
#pid  logs/nginx.pid;
events {
        worker_connections 30000;
        use epoll;
}

http {
	include mime.types;
        default_type application/octet-stream;
        sendfile on;
        tcp_nopush on;
        #tcp_nodelay on;
        keepalive_timeout 65;
        server_names_hash_bucket_size 64;
   	server_names_hash_max_size 2048;		
        server_tokens off;
        
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        #access_log /var/log/nginx/access.log;
        access_log off;
        #error_log /var/log/nginx/error.log;
        
        gzip on;
        gzip_disable "msie6";
	include /etc/nginx/conf.d/*.conf;
}
EOF
}

#配置反向代理
Conf_Proxy(){
    [ ! -d ${nginx_path}/conf.d ] && mkdir ${nginx_path}/conf.d
    #写反向代理配置文件
    cat > ${nginx_path}/proxy.conf << EOF
proxy_redirect off;
proxy_set_header Host \$host:\$server_port;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header REMOTE-HOST \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
client_max_body_size 1200m;
client_body_buffer_size 256k;
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
proxy_buffer_size 256k;
proxy_buffers 4 256k;
proxy_busy_buffers_size 256k;
proxy_temp_file_write_size 256k;
proxy_max_temp_file_size 500m;
EOF
    #配置server 
    cat > ${nginx_path}/conf.d/down.conf << EOF
server {
	listen ${listen_port};
	server_name localhost;
	client_max_body_size 500m;	#上传下载文件大小
	location / {
	    include ${nginx_path}/proxy.conf;
	    proxy_pass ${proxy_path};
	}
}
EOF
}

#打印脚本说明
Print(){
    cat  << EOF
#################################################################################
#1、AUTHOR:anqixiang
#2、DATE:2020-01-11
#3、功能：配置Nginx反向代理
#4、注意事项：nginx的默认路径为/etc/nginx,如果不是请修改"nginx_path"变量
#################################################################################
EOF
}

#主函数
main(){
    Print
    cecho 32 "开始执行......"
    echo "1.未配置${nginx_path}nginx.conf"
    echo "2.已配置${nginx_path}nginx.conf"
    read -p "请选择:" choice
    read -p "监听的端口:" listen_port
#    read -p "server_name:" server_name
    read -p "代理访问的地址:" proxy_path
    if [ "${choice}" -eq 1 ];then
	Conf_Master
	Conf_Proxy
    else
	Conf_Proxy
    fi
    cecho 96 "配置完成，请用nginx -t检查语法是否正确，如果正确，执行nginx -s reload使配置文件生效"
}
main
