#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    rocketmqStart.sh
## Description: 启动rocket集群的脚本.
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
## RocketMQ根目录
ROCKETMQ_HOME=${INSTALL_HOME}/RocketMQ/rocketmq
##NameServer的ip地址
NameServer_IP=$(sed -n '2p' ${CONF_DIR}/server_ip.properties)

echo -e 'build logdir.....'
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    ssh root@${hostname} "mkdir -p $LOG_DIR"
done

ssh root@$(sed -n '2p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; nohup ${ROCKETMQ_HOME}/bin/mqnamesrv -n ${NameServer_IP}:9876 > ${LOG_FILE} 2>&1 &"
if [ $? -eq 0 ];then
    echo  -e 'NameServer start success \n'
else 
    echo  -e 'NameServer start failed \n'
fi

ssh root@$(sed -n '4p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; nohup ${ROCKETMQ_HOME}/bin/mqbroker -n ${NameServer_IP}:9876 -c ${ROCKETMQ_HOME}/conf/2m-noslave/broker-a.properties > ${LOG_FILE} 2>&1 & "
if [ $? -eq 0 ];then
    echo  -e 'Broker1 start success \n'
else 
    echo  -e 'Broker1 start failed \n'
fi

ssh root@$(sed -n '6p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; nohup ${ROCKETMQ_HOME}/bin/mqbroker -n ${NameServer_IP}:9876 -c ${ROCKETMQ_HOME}/conf/2m-noslave/broker-b.properties > ${LOG_FILE} 2>&1 & "
if [ $? -eq 0 ];then
    echo  -e 'Broker2 start success \n'
else 
    echo  -e 'Broker2 start failed \n'
fi

line1=$(sed -n '8p' ${CONF_DIR}/server_ip.properties)
if [ ! -z "${line1}" ];then
    ssh root@$(sed -n '8p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; nohup ${ROCKETMQ_HOME}/bin/mqbroker -n ${NameServer_IP}:9876 -c ${ROCKETMQ_HOME}/conf/2m-noslave/broker-c.properties > ${LOG_FILE} 2>&1 & "
    if [ $? -eq 0 ];then
        echo  -e 'Broker3 start success \n'
    else
        echo  -e 'Broker3 start failed \n'
    fi
fi

line2=$(sed -n '10p' ${CONF_DIR}/server_ip.properties)
if [ ! -z "${line2}" ];then
    ssh root@$(sed -n '10p' ${CONF_DIR}/server_ip.properties) "source /etc/profile; nohup ${ROCKETMQ_HOME}/bin/mqbroker -n ${NameServer_IP}:9876 -c ${ROCKETMQ_HOME}/conf/2m-noslave/broker-d.properties > ${LOG_FILE} 2>&1 & "
    if [ $? -eq 0 ];then
        echo  -e 'Broker4 start success \n'
    else
        echo  -e 'Broker4 start failed \n'
    fi
fi

