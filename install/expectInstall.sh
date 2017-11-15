#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expectInstall.sh
## Description: 安装 expect 工具，安装后可以用expect命令减少人与linux之间的交互
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
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/expectInstall.log
## expect rpm 软件目录
EXPECT_RPM_DIR=${ROOT_HOME}/component/expectRpm
## 基础工具安装路径
INSTALL_HOME_BASIC=$(sed -n '2p' ${CONF_DIR}/install_home.properties)
## expect rpm 软件最终目录
EXPECT_RPM_INSTALL_HOME=${INSTALL_HOME_BASIC}/expectRpm

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "intall expect in  ${name}...... "  | tee -a $LOG_FILE
    ssh $name "mkdir -p  ${EXPECT_RPM_INSTALL_HOME}" 
    scp -r  ${EXPECT_RPM_DIR}/* $name:${EXPECT_RPM_INSTALL_HOME}  > /dev/null
    if [ $? == 0 ];then
        echo "scp expect to the ${EXPECT_RPM_INSTALL_HOME} done !!!"  | tee -a $LOG_FILE
    else 
        echo "scp expect to the ${EXPECT_RPM_INSTALL_HOME} failed !!!"  | tee -a $LOG_FILE
    fi
    ssh root@$name "rpm -ivh ${EXPECT_RPM_INSTALL_HOME}/tcl-8.5.7-6.el6.x86_64.rpm; rpm -ivh ${EXPECT_RPM_INSTALL_HOME}/expect-5.44.1.15-5.el6_4.x86_64.rpm; which expect; rm -rf ${INSTALL_HOME_BASIC}"  
done




set +x
