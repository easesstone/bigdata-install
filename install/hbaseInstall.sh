#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    hadoopInstall.sh
## Description: 安装配置hadoop集群
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
## 安装日记
LOG_FILE=${LOG_DIR}/hbaseInstall.log
##  安装包目录
HBASE_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## 安装目录
HBASE_INSTALL_HOME=${INSTALL_HOME}/HBase
##组件的根目录
HBASE_HOME=${HBASE_INSTALL_HOME}/hbase
## JAVA_HOME
JAVA_HOME=${INSTALL_HOME}/JDK/jdk
## HADOOP_HOME
HADOOP_HOME=${INSTALL_HOME}/Hadoop/hadoop


## 设置和获取HBase 集群的配置
mkdir -p ${HBASE_HOME}
ZK_LISTS=""
HBASE_TMP_DIR=${HBASE_HOME}/tmp
HBASE_ZK_DATADIR=${HBASE_HOME}/hbase_zk_datadir

hostname_num=0
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
    let hostname_num++
    if [ $hostname_num == 1 ];then
        ZK_LISTS="${hostname}:2181"
    else
        ZK_LISTS="${hostname}:2181,${ZK_LISTS}"
    fi
done

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 解压hbase jar 包
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE

cd  ${HBASE_SOURCE_DIR}
echo "解压hbase 中，please waiting...."   | tee  -a  $LOG_FILE
tar -xf hbase.tar.gz
rm -rf ${HBASE_HOME}
cp -r hbase ${HBASE_INSTALL_HOME} 
echo "解压hbase done......"  | tee  -a  $LOG_FILE
cd -

## 设置hbase-env.sh java home
cd ${HBASE_HOME}/conf
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
sed -i "s#java_home#${JAVA_HOME}#g" hbase-env.sh 
echo "设置jdk 路径........." | tee -a $LOG_FILE


## 设置regionserver
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
cat ${CONF_DIR}/hostnamelists.properties  > ${HBASE_HOME}/conf/regionservers
echo "设置regionservers done"  | tee -a $LOG_FIL

## 设置hbase-site.xml
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
cd ${HBASE_HOME}/conf
mkdir -p ${HBASE_TMP_DIR}
mkdir -p ${HBASE_ZK_DATADIR}
sed -i "s#zkaddress#${ZK_LISTS}#g" hbase-site.xml
sed -i "s#hbase_tmp_dir#${HBASE_TMP_DIR}#g" hbase-site.xml
sed -i "s#hbase_zookeeper_dataDir#${HBASE_ZK_DATADIR}#g" hbase-site.xml
echo  “配置Hbase-site.xml done ......”  | tee -a $LOG_FILE


## 拷贝Hadoop 的两个文件到hbas conf 目录下，拷贝前先确认是否安装配置了HADOOP
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
if [ -d ${HADOOP_HOME}/etc/hadoop ];then
    cp ${HADOOP_HOME}/etc/hadoop/core-site.xml ${HBASE_HOME}/conf
    cp ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml ${HBASE_HOME}/conf
    echo "拷贝 core-site.xml, hdfs.xml"  | tee  -a  $LOG_FILE
else
    echo "hadoop 没有安装正确，请检查hadoop 的安装配置。"  | tee  -a  $LOG_FILE
fi


## 分发hbase 配置文件。
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "文件分发中，please waiting....."  | tee -a $LOG_FILE
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
    ssh $hostname "mkdir   -p ${HBASE_INSTALL_HOME}"
    rsync -rvl ${HBASE_HOME} root@${hostname}:${HBASE_INSTALL_HOME}  > /dev/null
    ssh $hostname "chmod -R 755 ${HBASE_HOME}"
done
echo "hbase 文件分发完成，安装完成......"  | tee  -a  $LOG_FILE

set +x
