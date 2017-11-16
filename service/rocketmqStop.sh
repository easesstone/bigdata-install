#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    rocketmqStop.sh
## Description: 停止rocket集群的脚本.
## Version:     1.0
## Author:      caodabao
## Created:     2017-11-10
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
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/rocketmqStart.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## ROCKETMQ_HOME  rocketmq 根目录
ROCKETMQ_HOME=${INSTALL_HOME}/RocketMQ/rocketmq


ssh root@$(sed -n '2p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; sh ${ROCKETMQ_HOME}/bin/mqshutdown namesrv"
    if [ $? -eq 0 ];then
        echo  -e 'NameServer stop success \n'
    else 
        echo  -e 'NameServer stop failed \n'
    fi

ssh root@$(sed -n '4p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; sh ${ROCKETMQ_HOME}/bin/mqshutdown broker"
    if [ $? -eq 0 ];then
        echo  -e 'Broker1 stop success \n'
    else 
        echo  -e 'Broker1 stop failed \n'
    fi

ssh root@$(sed -n '6p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; sh ${ROCKETMQ_HOME}/bin/mqshutdown broker"
    if [ $? -eq 0 ];then
        echo  -e 'Broker2 stop success \n'
    else 
        echo  -e 'Broker2 stop failed \n'
    fi

line1=$(sed -n '8p' ${CONF_DIR}/server_ip.properties)
if [ ! -z "${line1}" ];then
    ssh root@$(sed -n '8p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; sh ${ROCKETMQ_HOME}/bin/mqshutdown broker "
    if [ $? -eq 0 ];then
        echo  -e 'Broker3 stop success \n'
    else
        echo  -e 'Broker3 stop failed \n'
    fi
fi

line2=$(sed -n '10p' ${CONF_DIR}/server_ip.properties)
if [ ! -z "${line2}" ];then
    ssh root@$(sed -n '10p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; sh ${ROCKETMQ_HOME}/bin/mqshutdown broker"
    if [ $? -eq 0 ];then
        echo  -e 'Broker4 stop success \n'
    else
        echo  -e 'Broker4 stop failed \n'
    fi
fi

