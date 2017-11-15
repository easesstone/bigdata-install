#!/bin/bash
################################################################################
## Copyright:    HZGOSUN Tech. Co, BigData
## Filename:     hiveInstall.sh
## Description:  安装 hive
## Version:      1.0
## Hive.Version: 2.3.0 
## Author:       qiaokaifeng
## Created:      2017-10-24
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
LOG_FILE=${LOG_DIR}/hiveInstall.log
## hive 安装包目录
HIVE_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## HIVE_INSTALL_HOME hive 安装目录
HIVE_INSTALL_HOME=${INSTALL_HOME}/Hive
## HIVE_HOME  hive 根目录
HIVE_HOME=${INSTALL_HOME}/Hive/hive

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

## 打印当前时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 解压hive安装包
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo “解压hive tar 包中，请稍候.......”  | tee -a $LOG_FILE
tar -xf ${HIVE_SOURCE_DIR}/hive.tar.gz -C ${HIVE_SOURCE_DIR}
if [ $? == 0 ];then
    echo "解压缩hive 安装包成功......"  | tee -a $LOG_FILE
else
    echo “解压hive 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
fi

## hive home目录
	mkdir -p ${HIVE_INSTALL_HOME}
    scp -r -q -p ${HIVE_SOURCE_DIR}/hive $(sed -n '1p' ${CONF_DIR}/hostnamelists.properties):${HIVE_INSTALL_HOME}  | tee -a $LOG_FILE
    chmod -R 755 ${HIVE_HOME}
    sed -i "s;127.0.0.1;$(sed -n '1p' ${CONF_DIR}/hostnamelists.properties);g" ${HIVE_HOME}/conf/hive-site.xml
    sed -i "s;INSTALL_HOME;${INSTALL_HOME};g" ${HIVE_HOME}/conf/hive-env.sh

## 配置zookeeper集群地址
hazk=''
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    hazk="${hazk}${insName}:2181,"
done

    sed -i "s;hazkadd;${hazk%?};g"  ${HIVE_HOME}/conf/hive-site.xml
    

## 配置hive matestore集群地址
hith=''
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    hith="${hith}thrift://${insName}:9083,"
done
    sed -i "s;hithadd;${hith%?};g"  ${HIVE_HOME}/conf/hive-site.xml
	sleep 2s
    rsync -rvl ${HIVE_HOME} $(sed -n '2p' ${CONF_DIR}/hostnamelists.properties):${HIVE_INSTALL_HOME}  > /dev/null
	sleep 2s
	ssh root@$(sed -n '2p' ${CONF_DIR}/hostnamelists.properties) "chmod -R 755 ${HIVE_HOME}"
	sleep 2s
    rsync -rvl ${HIVE_HOME} $(sed -n '3p' ${CONF_DIR}/hostnamelists.properties):${HIVE_INSTALL_HOME}  > /dev/null
	sleep 2s
    ssh root@$(sed -n '3p' ${CONF_DIR}/hostnamelists.properties) "chmod -R 755 ${HIVE_HOME}"
	
## 修改hiveserver2 UI地址
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "修改hiveserver2 UI地址 in {$insName}目录...... "  | tee -a $LOG_FILE
    ssh root@$insName "sed -i 's;hostname;$insName;g' ${HIVE_HOME}/conf/hive-site.xml"
	
done
    echo "hive 文件分发完成，安装完成......"  | tee  -a  $LOG_FILE
set +x
