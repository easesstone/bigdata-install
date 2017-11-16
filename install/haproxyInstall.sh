#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    haproxyInstall.sh
## Description: 安装配置Haproxy代理
##              实现自动化的脚本
## Version:     1.0
## Author:      pengcong
## Created:     2017-11-8 
################################################################################

#set -x
 
cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 日记目录
LOG_DIR=$(sed -n '8p' ${CONF_DIR}/install_home.properties)/haproxy
## haproxy 安装日记
LOG_FILE=${LOG_DIR}/haproxyInstall.log
##  haproxy 安装包目录
HAPROXY_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## HAPROXY_INSTALL_HOME HAPROXY 安装目录
HAPROXY_INSTALL_HOME=${INSTALL_HOME}/HAPrxoy
## HAPROXY_HOME  HAPROXY 根目录
HAPROXY_HOME=${HAPROXY_INSTALL_HOME}/haproxy
## HAPROXY_LOG_DIR HAPROXY 日志目录
HAPROXY_LOG_DIR=${HAPROXY_HOME}/logs
## HAPROXY_LOG_FILE HAPROXY 日志文件
HAPROXY_LOG_FILE=${HAPROXY_LOG_DIR}/haproxy.log
## HAPROXY_INIT 开机启动脚本
HAPROXY_INIT=/etc/ini.d/haproxy
##HAPROXY_CFG haproxy 配置文件
HAPROXY_CFG=${HAPROXY_HOME}/haproxy.cfg


#####################################################################
# 函数名: intstall_ha_cfg
# 描述: haproxy配置文件haproxy.cfg设置，启动脚本时请按实际情况修改
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function install_ha_cfg()
{ 
echo " 
###########全局配置#########

global
    log         127.0.0.1 local1                 ##[日志输出配置，所有日志都记录在本机，通过local1输出
    chroot      ${HAPROXY_HOME}
    pidfile     ${HAPROXY_HOME}/haproxy.pid
    maxconn     4000                             ##最大连接数
    user        root                             ##运行haproxy的用户
    group       root                             ##运行haproxy的用户所在的组
    daemon                                       ##以后台形式运行harpoxy

stats socket ${HAPROXY_HOME}/stats

########默认配置############

defaults
    mode                    tcp                  ##默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK
    log                     global
    option                  tcplog               ##日志类别,采用tcplog
    option                  dontlognull          ##不记录健康检查日志信息
    option                  abortonclose         ##当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接
    option                  redispatch           ##当serverId对应的服务器挂掉后，强制定向到其他健康的服务器，以后将不支持
    retries                 3                    ##3次连接失败就认为是服务器不可用，也可以通过后面设置
    timeout queue           1m                   ##默认队列超时时间
    timeout connect         10s                  ##连接超时
    timeout client          1m                   ##客户端超时
    timeout server          1m                   ##服务器超时
    timeout check           10s                  ##心跳检测超时
    maxconn                 3000                 ##默认的最大连接数
    
########服务器节点配置########
listen ftp
    bind 0.0.0.0:2121                            ##设置haproxy监控的服务器和端口号，0.0.0.0默认全网段
    mode tcp                                     ##http的7层模式
    #balance roundrobin  
    balance source                               ##设置默认负载均衡方式，类似于nginx的ip_hash
    #server <name> <address>[:port] [param*]
    #[param*]为后端设定参数
    #weight num权重 默认为1，最大值为256，0表示不参与负载均衡
    #check启用后端执行健康检测
    #inter num 健康状态检测时间间隔
    server s1 172.18.18.113:2121 weight 1 maxconn 10000 check inter 10s 
    #server s2 172.18.18.112:2121 weight 1 maxconn 10000 check inter 10s  
    server s3 172.18.18.114:2121 weight 1 maxconn 10000 check inter 10s  

########统计页面配置########
listen admin_stats  
    bind 0.0.0.0:8099                            ##统计页面监听地址
    stats enable
    mode http 
    option httplog 
    maxconn 10  
    stats refresh 10s                            ##页面刷新时间
    stats uri /stats                             ##统计页面url，可通过http://ip:8099/stats访问配置文件
" > "$HAPROXY_CFG" 
}
 
#####################################################################
# 函数名:install_ha_init 
# 描述: 将haproxy服务添加到开机启动
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function install_ha_init ()
{
    if [ ! -e "$HAPROXY_INIT" ]; then
        cp ${ROOT_HOME}/service/haproxy-control.sh /etc/init.d/haproxys
        sed -i "s#HAPROXY_DIR=#HAPROXY_DIR=${HAPROXY_HOME}#g" /etc/init.d/haproxys
        chmod +x /etc/init.d/haproxys
        chkconfig --add haproxys
        chkconfig haproxys on
    else
        echo "File haproxy already there !" | tee -a $LOG_FILE
    fi
}
 
#####################################################################
# 函数名: main
# 描述: 模块功能main 入口，即程序入口, 用来安装Haproxy。
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    if [ ! -e "$HAPROXY_HOME" ]; then 
        mkdir -p ${HAPROXY_HOME}
        cd ${HAPROXY_SOURCE_DIR} 
        tar zxf haproxy*.tar.gz
        cd haproxy*/ 
        make TARGET=linux26 ARCH=x86_64 PREFIX=${HAPROXY_HOME} && make install PREFIX=${HAPROXY_HOME} && mkdir ${HAPROXY_HOME}/{html,logs,conf} 
        ! grep 'haproxy' /etc/rsyslog.conf && echo 'local1.*            ${HAPROXY_HOME}/log/haproxy.log' >> /etc/rsyslog.conf
        sed -ir 's/SYSLOGD_OPTIONS="-m 0"/SYSLOGD_OPTIONS="-r -m 0"/g' /etc/sysconfig/rsyslog 
        install_ha_cfg
        install_ha_init
        rm -rf haproxy-*/
    else
        echo -e "haproxy is already exists!" | tee -a $LOG_FILE
    fi
}

# 主程序入口
main

set +x
