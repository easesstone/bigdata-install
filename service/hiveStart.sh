#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    hiveStart.sh
## Description: 启动hive集群的脚本.
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
LOG_FILE=${LOG_DIR}/hiveStart.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)

echo -e "启动HiveServer服务："
echo -e "启动Hivemetastore服务："
for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
	ssh root@$name "nohup ${INSTALL_HOME}/Hive/hive/bin/hive --service hiveserver2 >/dev/null 2>&1 &"
	if [ $? -eq 0 ];then
	    echo -e 'HiveServer startsuccess \n'
	else 
	    echo -e 'HiveServer startfailed \n'
	fi

done
echo -e "启动Hivemetastore服务："
for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
        ssh root@$name "nohup ${INSTALL_HOME}/Hive/hive/bin/hive --service metastore >/dev/null 2>&1 &"
        if [ $? -eq 0 ];then
            echo -e 'Hive metastore startsuccess \n'
        else
            echo -e 'Hive metastore startfailed \n'
        fi

done



