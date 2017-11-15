#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    esStart.sh
## Description: 启动es集群的脚本.
## Version:     1.0
## Author:      mashencai
## Created:     2017-11-10
################################################################################

#set -x

cd `dirname $0`
## 脚本所在目录：/home/hzgc/bigdata_hzgc/service
BIN_DIR=`pwd`
cd ..
## 安装包根目录：/home/hzgc/bigdata_hzgc
ROOT_HOME=`pwd`
## 配置文件目录：/home/hzgc/bigdata_hzgc/conf
CONF_DIR=${ROOT_HOME}/conf
## 安装日记目录：/home/hzgc/bigdata_hzgc/logs
LOG_DIR=${ROOT_HOME}/logs
## 安装日记：/home/hzgc/bigdata_hzgc/esStart.log
LOG_FILE=${LOG_DIR}/esStart.log
## 最终安装的根目录，所有bigdata 相关的根目录：/opt/hzgc/bigdata
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## ELASTIC_INSTALL_HOME elastic 安装目录：/opt/hzgc/bigdata/Elastic
ELASTIC_INSTALL_HOME=${INSTALL_HOME}/Elastic
## ELASTIC_HOME  elastic 根目录：/opt/hzgc/bigdata/Elastic/elastic
ELASTIC_HOME=${ELASTIC_INSTALL_HOME}/elastic

# 打印系统时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                        | tee  -a  $LOG_FILE

# 启动ES服务
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "开始启动ES服务......"    | tee -a $LOG_FILE

# 创建elsearch用户
echo -e "在每个节点上创建elsearch用户："              | tee -a $LOG_FILE
for name in $(cat ${CONF_DIR}/hostnamelists.properties);do
	ssh root@$name "groupadd elsearch;useradd elsearch -g elsearch -p elastic;chown -R elsearch:elsearch ${ELASTIC_HOME}"
done
echo "" | tee -a $LOG_FILE
echo "创建elsearch用户完毕......"    | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

# 启动ES
echo -e "在每个节点上启动ES："                    | tee -a $LOG_FILE
for name in $(cat ${CONF_DIR}/hostnamelists.properties);do
	ssh root@$name "source /etc/profile;su -c '${ELASTIC_HOME}/bin/elasticsearch -d' elsearch" # 切换为elsearch用户
done
echo "" | tee -a $LOG_FILE
echo "启动ES完毕......"    | tee -a $LOG_FILE
