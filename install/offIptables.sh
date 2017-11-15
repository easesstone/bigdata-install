#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    offIptables.sh
## Description: 关闭防火墙，防火墙对大数据有影响。
##              实现自动化的脚本
## Version:     1.0
## Author:      lidiliang
## Created:     2017-10-23
################################################################################

#set -x

cd `dirname $0`
## bin 目录
BIN_DIR=`pwd`
cd ..
## 安装根目录
ROOT_HOME=`pwd`
## conf 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 关闭防火墙日记 
LOG_FILE=${LOG_DIR}/offIpTable.log

mkdir -p  ${LOG_DIR}

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE
for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    echo ""  | tee  -a  $LOG_FILE
    echo "**************************************************"  | tee  -a  $LOG_FILE
    echo "准备关闭节点$name的防火墙"    | tee -a $LOG_FILE
    ssh root@$name "sed -i \"s;enforcing;disabled;g\" /etc/selinux/config "
    ssh root@$name 'service iptables stop'
    ssh root@$name 'chkconfig iptables off'
    echo "关闭防火 $name 的防火墙成功。"  | tee -a $LOG_FILE 
done


set +x
