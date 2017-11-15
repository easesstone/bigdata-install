#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    hbaseStart.sh
## Description: 启动hbase集群的脚本.
## Version:     1.0
## Author:      qiaokaifeng
## Created:     2017-10-24
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
LOG_FILE=${LOG_DIR}/hbaseStart.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)

echo -e "启动HBase集群 \n"
${INSTALL_HOME}/HBase/hbase/bin/start-hbase.sh
	if [ $? -eq 0 ];then
	    echo  -e 'HBase start success \n'
	else 
	    echo  -e 'HBase start failed \n'
	fi

sleep 5s

ssh root@$(sed -n '2p' ${CONF_DIR}/hostnamelists.properties) "${INSTALL_HOME}/HBase/hbase/bin/hbase-daemon.sh start master"
        if [ $? -eq 0 ];then
            echo -e 'ha hmaster success \n'
        else
            echo -e 'ha hmaster failed \n'
        fi



