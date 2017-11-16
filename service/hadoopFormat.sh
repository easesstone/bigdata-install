#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    zookeeperStart.sh
## Description: 启动zookeeper集群的脚本.
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
LOG_FILE=${LOG_DIR}/hadoopFormat.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)

if [ -f formated ];then
   echo "已经执行过一次format, 一般不允许二次format...."
   exit 0
fi

for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    ssh root@$name "source /etc/profile;${INSTALL_HOME}/Zookeeper/zookeeper/bin/zkServer.sh start"
done



sleep 5s

${INSTALL_HOME}/Hadoop/hadoop/bin/hdfs zkfc -formatZK  -force
if [ $? -ne 0 ];then
    echo "hdfs zkfc -formatZK 失败."
    exit 1;
fi

sleep 2s
cd  ${INSTALL_HOME}/Hadoop/hadoop/sbin
./hadoop-daemon.sh start zkfc 
sleep 2s

source /etc/profile;
xcall jps

for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    ssh root@$name "${INSTALL_HOME}/Hadoop/hadoop/sbin/hadoop-daemon.sh start journalnode"
    if [ $? -ne 0 ];then
        echo  "start journalnode in $name failed"
        exit 1 
    fi
done

sleep 2s
# 格式化namenode
${INSTALL_HOME}/Hadoop/hadoop/bin/hadoop namenode -format -force
## 
if [ $? -ne 0 ];then
    echo "hdfs namenode -formate -force 失败."
    exit 1;
fi

sleep 2s

## 第一次启动
${INSTALL_HOME}/Hadoop/hadoop/sbin/start-dfs.sh
ssh root@$(sed -n '2p' ${CONF_DIR}/hostnamelists.properties) "
${INSTALL_HOME}/Hadoop/hadoop/bin/hdfs namenode -bootstrapStandby;
${INSTALL_HOME}/Hadoop/hadoop/sbin/hadoop-daemon.sh start namenode
"
cd  ${ROOT_HOME}
echo formate  >> formated  
sleep 5s 
for name in $(cat ${CONF_DIR}/hostnamelists.properties)
do
    ssh root@$name "source /etc/profile;killall -9 java"
done





