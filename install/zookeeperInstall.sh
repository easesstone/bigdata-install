#!/bin/bash
################################################################################
## Copyright:         HZGOSUN Tech. Co, BigData
## Filename:          zookeeperInstall.sh
## Description:       安装 zookeeper
## Version:           1.0
## zookeeper.version: 3.5.1-alpha
## Author:            qiaokaifeng
## Created:           2017-10-23
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
LOG_FILE=${LOG_DIR}/zookeeperInstall.log
## ZOOKEEPER 安装包目录
ZOOKEEPER_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## ZOOKEEPER_INSTALL_HOME zookeeper 安装目录
ZOOKEEPER_INSTALL_HOME=${INSTALL_HOME}/Zookeeper
## ZOOKEEPER_HOME  zookeeper 根目录
ZOOKEEPER_HOME=${INSTALL_HOME}/Zookeeper/zookeeper

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

## 打印当前时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 解压zookeeper安装包
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo “解压zookeeper tar 包中，请稍候.......”  | tee -a $LOG_FILE
tar -xf ${ZOOKEEPER_SOURCE_DIR}/zookeeper.tar.gz -C ${ZOOKEEPER_SOURCE_DIR}
if [ $? == 0 ];then
    echo "解压缩zookeeper 安装包成功......"  | tee -a $LOG_FILE
else
    echo “解压zookeeper 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
fi

## 临时目录
i=0

for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "创建临时安装目录${insName}，请稍等...... "  | tee -a $LOG_FILE
    mkdir ${ZOOKEEPER_SOURCE_DIR}/$insName
    sleep 2s
    echo "正在拷贝安装包到${insName}临时安装目录,请稍等......"  | tee -a $LOG_FILE
    cp -R ${ZOOKEEPER_SOURCE_DIR}/zookeeper ${ZOOKEEPER_SOURCE_DIR}/$insName
    i=$(($i+1))
    echo "server.${i}=${insName}:2888:3888" >> ${ZOOKEEPER_SOURCE_DIR}/$1/zookeeper/conf/zoo.cfg
    echo "$i" >> ${ZOOKEEPER_SOURCE_DIR}/$insName/zookeeper/data/myid
    sleep 2s
    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "修改zookeeper logs目录 in ${insName}目录，请稍等...... "  | tee -a $LOG_FILE
    sed -i "s;zookeeper_logs;${ZOOKEEPER_HOME};g"  ${ZOOKEEPER_SOURCE_DIR}/$insName/zookeeper/bin/zkEnv.sh
done

## 临时分发配置文件

for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "临时分发配置文件到 {$insName}目录...... "  | tee -a $LOG_FILE
    yes|cp ${ZOOKEEPER_SOURCE_DIR}/$1/zookeeper/conf/zoo.cfg ${ZOOKEEPER_SOURCE_DIR}/$insName/zookeeper/conf/
done

## 分发zookeeper到每个节点
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "准备将zookeeper分发到节点$insName："  | tee -a $LOG_FILE
    ssh $insName "mkdir -p  ${ZOOKEEPER_INSTALL_HOME}"    > /dev/null
    rsync -rvl  ${ZOOKEEPER_SOURCE_DIR}/$insName/ $insName:${ZOOKEEPER_INSTALL_HOME}  > /dev/null
    zookeeper_x=$(chmod -R 755 ${ZOOKEEPER_HOME})
    echo "ssh root@$insName ${zookeeper_x}"    | tee -a $LOG_FILE
        if [ $? == 0 ];then
        echo "rsync zookeeper to the ${ZOOKEEPER_INSTALL_HOME} done !!!"  | tee -a $LOG_FILE
    else
        echo "rsync zookeeper to the ${ZOOKEEPER_INSTALL_HOME} failed !!!"  | tee -a $LOG_FILE
    fi
done

## 修改zookeeper data目录
    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "修改zookeeper data目录 ，请稍等...... "  | tee -a $LOG_FILE
    sed -i "s;zookeeper;${ZOOKEEPER_HOME};g" ${ZOOKEEPER_HOME}/conf/zoo.cfg
    scp -r ${ZOOKEEPER_HOME}/conf/zoo.cfg root@$(sed -n '2p' ${CONF_DIR}/hostnamelists.properties):${ZOOKEEPER_HOME}/conf/
    scp -r ${ZOOKEEPER_HOME}/conf/zoo.cfg root@$(sed -n '3p' ${CONF_DIR}/hostnamelists.properties):${ZOOKEEPER_HOME}/conf/

## 删除临时目录
for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "删除临时目录${insName}...... "  | tee -a $LOG_FILE
    rm -rf ${ZOOKEEPER_SOURCE_DIR}/$insName
done

set +x
