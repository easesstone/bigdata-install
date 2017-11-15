#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    mysqlInstall.sh
## Description: 安装并启动mysql。
##              实现自动化的脚本
## Version:     1.0
## Author:      lidiliang
## Created:     2017-10-23
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
## jdk 安装日记
LOG_FILE=${LOG_DIR}/jdkInstall.log
##  jdk 安装包目录
JDK_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## JAVA_INSTALL_HOME jdk 安装目录
JAVA_INSTALL_HOME=${INSTALL_HOME}/JDK
## JAVA_HOME  jdk 根目录
JAVA_HOME=${INSTALL_HOME}/JDK/jdk

mkdir -p ${JAVA_INSTALL_HOME}
mkdir -p ${LOG_DIR} 


echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

echo “解压jdk tar 包中，请稍候.......”  | tee -a $LOG_FILE
tar -xf ${JDK_SOURCE_DIR}/jdk.tar.gz -C $JDK_SOURCE_DIR
if [ $? == 0 ];then
    echo "解压缩jdk 安装包成功......"  | tee -a $LOG_FILE 
else 
    echo “解压jdk 安装包失败。请检查安装包是否损坏，或者重新安装.”  | tee -a $LOG_FILE
    exit 1
fi

for insName in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将JDK分发到节点$insName："  | tee -a $LOG_FILE
    ssh root@$insName "source /etc/profile; mkdir -p  ${JAVA_INSTALL_HOME};"
    ssh root@$insName 'mkdir /home/test;
        cd /home/test;
        rpm -qa | grep java   > java.tmp;
        for rpm_pak in $(cat  java.tmp);do
            echo "删除原先系统java rpm 软件包: ${rpm_pak}"  |  tee  -a  $LOG_FILE;
            rpm -e --nodeps ${rpm_pak};
        done
    '
    echo "jdk 分发中,请稍候......"  | tee -a $LOG_FILE
    rsync -rvl $JDK_SOURCE_DIR/jdk $insName:${JAVA_INSTALL_HOME}   > /dev/null
    ssh root@${insName} "chmod -R 755 ${JAVA_HOME}"  
    ssh root@${insName}  "echo '#JAVA_HOME'>>/etc/profile ;echo export JAVA_HOME=$JAVA_HOME >> /etc/profile"
    ssh root@${insName} 'echo export PATH=\$JAVA_HOME/bin:\$PATH  >> /etc/profile; echo "">> /etc/profile' 
    echo "最终的java 版本如下:"    | tee -a $LOG_FILE
    ssh root@${insName}  'source /etc/profile; java -version'     | tee -a $LOG_FILE
done

set +x	
