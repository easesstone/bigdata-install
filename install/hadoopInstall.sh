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
## hadoop 安装日记
LOG_FILE=${LOG_DIR}/hadoopInstall.log
##  hadoop 安装包目录
HADOOP_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## HADOOP_INSTALL_HOME hadoop 安装目录
HADOOP_INSTALL_HOME=${INSTALL_HOME}/Hadoop
## HADOOP_HOME  hadoop 根目录
HADOOP_HOME=${HADOOP_INSTALL_HOME}/hadoop
## JAVA_HOME
JAVA_HOME=${INSTALL_HOME}/JDK/jdk



mkdir -p ${HADOOP_HOME}

ZK_LISTS=""
MASTER1=""
MASTER2=""
HADOOP_TMP_DIR=$HADOOP_HOME/tmp
DK_SLAVES=""
DFS_JOURNALNODE_EDITS_DIR=${HADOOP_HOME}/dfs_journalnode_edits_dir

hostname_num=0
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
    let hostname_num++
    if [ $hostname_num == 1 ];then
        MASTER1=${hostname}
        ZK_LISTS="${hostname}:2181"
        DK_SLAVES="${hostname}:8485"
    else
        ZK_LISTS="${hostname}:2181,${ZK_LISTS}"
        DK_SLAVES="${hostname}:8485;${DK_SLAVES}"
    fi
    if [ $hostname_num == 2 ];then
        MASTER2=${hostname}
    fi
done

#####################################################################
# 函数名: compression_the_tar
# 描述: 获取开源hadoop 安装包，并解压。
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function compression_the_tar()
{   
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "please waitinng, hadoop jar 包解压中........"  | tee -a $LOG_FILE
    cd $HADOOP_SOURCE_DIR
    tar -xf hadoop.tar.gz
    if [ $? == 0 ];then
        echo "解压hadoop jar 包成功." | tee -a $LOG_FILE
    else
       echo "解压hadoop jar 包失败，请检查包是否完整。" | tee -a $LOG_FILE  
    fi
    rm -rf ${HADOOP_HOME}
    cp -r hadoop  ${HADOOP_INSTALL_HOME}
    cd -  
}



#####################################################################
# 函数名: config_jdk_and_slaves
# 描述: 配置hadoop-env.sh 和yarn-env.sh 中jdk 的路径。
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_jdk_and_slaves()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    cd $HADOOP_HOME/etc/hadoop
    sed -i "s#java_home#${JAVA_HOME}#g" yarn-env.sh
    flag1=$?
    sed -i "s#java_home#${JAVA_HOME}#g" hadoop-env.sh
    flag2=$?
    if [[ ($flag1 == 0)  && ($flag2 == 0) ]];then
        echo " 配置jdk 路径成功." | tee -a $LOG_FILE
    else
        echo "配置jdk路径成功." | tee -a $LOG_FILE
    fi
    cat ${CONF_DIR}/hostnamelists.properties  >  ${HADOOP_HOME}/etc/hadoop/slaves
    cd -
}


#####################################################################
# 函数名: config_core_site 的
# 描述: 配置core-site.xml 
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_core_site()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    cd $HADOOP_HOME/etc/hadoop
    mkdir -p ${HADOOP_TMP_DIR}
    sed -i "s#hadoop_tmp_dir#${HADOOP_TMP_DIR}#g" core-site.xml
    sed -i "s#ha_zookeeper_quorum#${ZK_LISTS}#g" core-site.xml    
    echo “配置core-site.xml 的配置done”  | tee -a $LOG_FILE
    cd -
}


#####################################################################
# 函数名: config_hdfs_site 的
# 描述: 配置hdfs-site.xml 
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_hdfs_site()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    cd $HADOOP_HOME/etc/hadoop
    sed -i "s#master1#${MASTER1}#g" hdfs-site.xml
    sed -i "s#master2#${MASTER2}#g" hdfs-site.xml
    sed -i "s#DKslave#${DK_SLAVES}#g" hdfs-site.xml 
    mkdir -p $DFS_JOURNALNODE_EDITS_DIR
    sed -i "s#dfs_journalnode_edits_dir#${DFS_JOURNALNODE_EDITS_DIR}#g" hdfs-site.xml 
    echo “配置hdfs-site.xml 的配置done”  | tee -a $LOG_FILE
    cd -
}

#####################################################################
# 函数名: config_yarn_site 的
# 描述: 配置yarn-site.xml 
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_yarn_site()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    cd $HADOOP_HOME/etc/hadoop
    sed -i "s#master1#${MASTER1}#g"  yarn-site.xml
    sed -i "s#master2#${MASTER2}#g"  yarn-site.xml
    sed -i "s#ha_zookeeper_quorum#${ZK_LISTS}#g"  yarn-site.xml
    echo “配置yarn-site.xml 的配置done”  | tee -a $LOG_FILE
    cd -
}



#####################################################################
# 函数名: xync_hadoop_config
# 描述: hadoop 配置文件分发
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function xync_hadoop_config()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "hadoop 配置文件分发中，please waiting......"    | tee -a $LOG_FILE
    for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
        ssh root@${hostname}  "mkdir -p ${HADOOP_INSTALL_HOME}"  
        rsync -rvl ${HADOOP_HOME}   root@${hostname}:${HADOOP_INSTALL_HOME}  >/dev/null
        ssh root@${hostname}  "chmod -R 755   ${HADOOP_HOME}"
    done 
    echo “分发haoop 安装配置done...”  | tee -a $LOG_FILE  
}


#####################################################################
# 函数名: main
# 描述:  修改hadoop HA模式下所需要修改的配置
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    compression_the_tar
    config_jdk_and_slaves
    config_core_site
    config_hdfs_site
    config_yarn_site  
    xync_hadoop_config 
}


echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE
main


set +x
