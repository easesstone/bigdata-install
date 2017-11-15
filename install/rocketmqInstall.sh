#!/bin/bash
################################################################################
## Copyright:     HZGOSUN Tech. Co, BigData
## Filename:      rocketmqInstall.sh
## Description:   安装 rocket
## Version:       1.0
## RocketMQ.Version: 4.1.0 
## Author:        caodabao
## Created:       2017-11-10
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
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/rocketmqInstall.log
## rocketmq 安装包目录
ROCKETMQ_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## ROCKETMQ_INSTALL_HOME rocketmq 安装目录
ROCKETMQ_INSTALL_HOME=${INSTALL_HOME}/RocketMQ
## ROCKETMQ_HOME  rocketmq 根目录
ROCKETMQ_HOME=${INSTALL_HOME}/RocketMQ/rocketmq
## NameServer 节点IP
NameServer_IP=$(sed -n '2p' ${CONF_DIR}/server_ip.properties)


mkdir -p ${ROCKETMQ_INSTALL_HOME}
mkdir -p ${LOG_DIR} 


echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

echo “解压rocketmq zip 包中，请稍候.......”  | tee -a $LOG_FILE
	unzip ${ROCKETMQ_SOURCE_DIR}/rocketmq.zip  -d ${ROCKETMQ_SOURCE_DIR} > /dev/null
if [ $? == 0 ];then
    echo "解压缩rocketmq 安装包成功......"  | tee -a $LOG_FILE
	mv ${ROCKETMQ_SOURCE_DIR}/rocketmq-all-4.1.0-incubating ${ROCKETMQ_SOURCE_DIR}/rocketmq
else
    echo “解压rocketmq 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
	exit 1
fi

for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将ROCKETMQ分发到节点$insName："  | tee -a $LOG_FILE
    ssh root@$insName "mkdir -p  ${ROCKETMQ_INSTALL_HOME}"    
    echo "rocketmq 分发中,请稍候......"  | tee -a $LOG_FILE
    rsync -rvl $ROCKETMQ_SOURCE_DIR/rocketmq $insName:${ROCKETMQ_INSTALL_HOME}   > /dev/null
    ssh root@${insName} "chmod -R 755 ${ROCKETMQ_HOME}"  
    ssh root@${insName}  "echo '#ROCKETMQ_HOME'>>/etc/profile ;echo export ROCKETMQ_HOME=$ROCKETMQ_HOME >> /etc/profile"
    ssh root@${insName} 'echo export PATH=\$ROCKETMQ_HOME/bin:\$PATH  >> /etc/profile; echo "">> /etc/profile' 
    ssh root@${insName} "echo export NAMESRV_ADDR="${NameServer_IP}:9876"  >> /etc/profile; echo "">> /etc/profile"
done

set +x	
