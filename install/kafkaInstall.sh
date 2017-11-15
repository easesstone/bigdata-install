#!/bin/bash
################################################################################
## Copyright:     HZGOSUN Tech. Co, BigData
## Filename:      kafkaInstall.sh
## Description:   安装 kafka
## Version:       1.0
## Kafka.Version: 0.11.0.1 
## Author:        qiaokaifeng
## Created:       2017-10-24
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
LOG_FILE=${LOG_DIR}/kafkaInstall.log
## kafka 安装包目录
KAFKA_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## KAFKA_INSTALL_HOME kafka 安装目录
KAFKA_INSTALL_HOME=${INSTALL_HOME}/Kafka
## KAFKA_HOME  kafka 根目录
KAFKA_HOME=${INSTALL_HOME}/Kafka/kafka

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

## 打印当前时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 解压kafka安装包
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo “解压kafka tar 包中，请稍候.......”  | tee -a $LOG_FILE
tar -xf ${KAFKA_SOURCE_DIR}/kafka.tgz -C ${KAFKA_SOURCE_DIR}
if [ $? == 0 ];then
    echo "解压缩kafka 安装包成功......"  | tee -a $LOG_FILE
else
    echo “解压kafka 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
fi

    mkdir -p ${KAFKA_SOURCE_DIR}/tmp
    cp -r ${KAFKA_SOURCE_DIR}/kafka ${KAFKA_SOURCE_DIR}/tmp
    sed -i "s;KAFKA_HOME;${KAFKA_HOME};g"  ${KAFKA_SOURCE_DIR}/tmp/kafka/config/server.properties
kfkpro=''
for kfk in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    kfkpro="$kfkpro$kfk:2181,"
done
    sed -i "s;zookeeperCON;${kfkpro%?};g"  ${KAFKA_SOURCE_DIR}/tmp/kafka/config/server.properties

#临时目录。
i=0
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo “创建临时分发目录：.......”  | tee -a $LOG_FILE
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    mkdir -p ${KAFKA_SOURCE_DIR}/$insName
    echo -n -e "正在创建${insName}的临时分发目录,请稍等......\n"
    cp -R ${KAFKA_SOURCE_DIR}/tmp/kafka ${KAFKA_SOURCE_DIR}/$insName
    i=$(($i+1))
    sed -i "s;brokerNum;$i;g"  ${KAFKA_SOURCE_DIR}/$insName/kafka/config/server.properties
done
	
## 分发到每个节点
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo "准备将kafka发到节点$insName"
    ssh root@$insName "mkdir -p ${KAFKA_INSTALL_HOME}"
    rsync -rvl ${KAFKA_SOURCE_DIR}/$insName/kafka $insName:${KAFKA_INSTALL_HOME}  > /dev/null
    ssh root@$insName "chmod -R 755 ${KAFKA_HOME}"

done
#修改配置文件hostname
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo "准备修改kafka${insName}的conf文件"
    ssh root@$insName "sed -i 's;hostname;$insName;g' ${KAFKA_HOME}/config/server.properties"

done
    sed -i "s;host1;$(sed -n '1p' ${CONF_DIR}/hostnamelists.properties);g" ${KAFKA_HOME}/config/producer.properties
    sed -i "s;host2;$(sed -n '2p' ${CONF_DIR}/hostnamelists.properties);g" ${KAFKA_HOME}/config/producer.properties
    sed -i "s;host3;$(sed -n '3p' ${CONF_DIR}/hostnamelists.properties);g" ${KAFKA_HOME}/config/producer.properties
	
    rsync -rvl 	${KAFKA_HOME}/config/producer.properties $(sed -n '2p' ${CONF_DIR}/hostnamelists.properties):${KAFKA_HOME}/config > /dev/null
    rsync -rvl 	${KAFKA_HOME}/config/producer.properties $(sed -n '3p' ${CONF_DIR}/hostnamelists.properties):${KAFKA_HOME}/config > /dev/null

## 删除临时存放目录
    rm -rf ${KAFKA_SOURCE_DIR}/tmp
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    rm -rf ${KAFKA_SOURCE_DIR}/$insName
done
    echo "kafka 文件分发完成，安装完成......"  | tee  -a  $LOG_FILE
set +x
