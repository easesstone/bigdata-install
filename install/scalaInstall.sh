#!/bin/bash
################################################################################
## Copyright:    HZGOSUN Tech. Co, BigData
## Filename:     scalaInstall.sh
## Description:  安装scala。
## Version:      1.0
## Scala.Version:2.11.8
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
## 日记目录
LOG_DIR=${ROOT_HOME}/logs
## scala 安装日记
LOG_FILE=${LOG_DIR}/scalaInstall.log
##  scala 安装包目录
SCALA_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## SCALA_INSTALL_HOME scala 安装目录
SCALA_INSTALL_HOME=${INSTALL_HOME}/Scala
## JAVA_HOME  jdk 根目录
SCALA_HOME=${INSTALL_HOME}/Scala/scala

#mkdir -p ${SCALA_INSTALL_HOME}
sleep 2s

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

echo “解压scala tar 包中，请稍候.......”  | tee -a $LOG_FILE
tar -xf ${SCALA_SOURCE_DIR}/scala.tgz -C $SCALA_SOURCE_DIR
if [ $? == 0 ];then
    echo "解压缩scala 安装包成功......"  | tee -a $LOG_FILE
else
    echo “解压scala 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
    exit 1
fi

for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将Scala分发到节点$insName："  | tee -a $LOG_FILE
    ssh root@$insName "mkdir -p  ${SCALA_INSTALL_HOME}"
    echo "scala 分发中,请稍候......"  | tee -a $LOG_FILE
    rsync -rvl $SCALA_SOURCE_DIR/scala $insName:${SCALA_INSTALL_HOME}   > /dev/null
    ssh root@${insName} "chmod -R 755 ${SCALA_HOME}"
    ssh root@${insName}  "echo '#SCALA_HOME'>>/etc/profile ;echo export SCALA_HOME=$SCALA_HOME >> /etc/profile"
    ssh root@${insName} 'echo export PATH=\$SCALA_HOME/bin:\$PATH  >> /etc/profile; echo "">> /etc/profile'
    echo "最终的scala 版本如下:"    | tee -a $LOG_FILE
    ssh root@${insName}  'source /etc/profile; scala -version'     | tee -a $LOG_FILE
done

set +x

