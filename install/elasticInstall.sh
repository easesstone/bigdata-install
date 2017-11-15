#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    elasticInstall.sh
## Delasticcription: 安装配置elastic
##              实现自动化的脚本
## Version:     1.0
## Author:      mashencai
## Created:     2017-11-09
################################################################################

#set -x

## 进入当前目录
cd `dirname $0`
## 脚本所在目录：/home/hzgc/bigdata_hzgc/install_script
BIN_DIR=`pwd`
cd ..
## 安装包根目录：/home/hzgc/bigdata_hzgc
ROOT_HOME=`pwd`
## 配置文件目录：/home/hzgc/bigdata_hzgc/conf
CONF_DIR=${ROOT_HOME}/conf
## 日记目录：/home/hzgc/bigdata_hzgc/logs
LOG_DIR=${ROOT_HOME}/logs
## elastic 安装日记
LOG_FILE=${LOG_DIR}/elasticInstall.log
##  elastic 安装包目录：/home/hzgc/bigdata_hzgc/component/bigdata
ELASTIC_SOURCE_DIR=${ROOT_HOME}/component/bigdata

## 最终安装的根目录，所有bigdata 相关的根目录：/opt/hzgc/bigdata
INSTALL_HOME=$(sed -n '4p' ${CONF_DIR}/install_home.properties)
## ELASTIC_INSTALL_HOME elastic 安装目录：/opt/hzgc/bigdata/Elastic
ELASTIC_INSTALL_HOME=${INSTALL_HOME}/Elastic
## ELASTIC_HOME  elastic 根目录：/opt/hzgc/bigdata/Elastic/elastic
ELASTIC_HOME=${ELASTIC_INSTALL_HOME}/elastic
## JAVA_HOME
JAVA_HOME=${INSTALL_HOME}/JDK/jdk


## 创建ELASTIC的安装目录
mkdir -p ${ELASTIC_HOME}

## 打印时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

#####################################################################
#
# 在本机上解压 elastic 安装包
#
#####################################################################
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "please waitinng, elastic jar 包解压中........"  | tee -a $LOG_FILE
cd ${ELASTIC_SOURCE_DIR}  ## 进入 elastic 安装包目录
tar -xf elastic.tar.gz  ## 解压 elastic 安装包
if [ $? == 0 ];then  ## 判断返回值
    echo "解压elastic jar 包成功." | tee -a $LOG_FILE
else
   echo "解压elastic jar 包失败，请检查包是否完整。" | tee -a $LOG_FILE  
fi
cd - 


#####################################################################
# 
# 将elasticsearch.yml中的discovery.zen.ping.unicast.hosts: [host_name_list]
# 配置为 ["s1xx", "s1xx","s1xx"]
# tmp拼接后是：“s101”,"s102","s103",需要删除最右边的一个逗号“,”，
# ${tmp%?}中的%号表示截取，以删除右边字符（,），保留左边字符（“s101”,"s102","s103"）
# 
#####################################################################
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "please waitinng, 修改elasticsearch.yml的配置........"  | tee -a $LOG_FILE
echo ""  | tee -a $LOG_FILE

tmp=""
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
	tmp="$tmp\"${hostname}\","  # 拼接字符串
done
tmp=${tmp%?}

sed -i "s#host_name_list#${tmp}#g" ${ELASTIC_SOURCE_DIR}/elastic/config/elasticsearch.yml

echo "修改discovery.zen.ping.unicast.hosts:[${tmp}]成功"  | tee -a $LOG_FILE
echo ""  | tee -a $LOG_FILE
	
cd -



#####################################################################
#
# 把解压后的安装包分发到集群不同节点的安装目录下
#
#####################################################################
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "please waitinng, 解压后安装文件夹分发中........"  | tee -a $LOG_FILE
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
	ssh root@${hostname}  "mkdir -p ${ELASTIC_INSTALL_HOME}"  
    rsync -rvl ${ELASTIC_SOURCE_DIR}/elastic   root@${hostname}:${ELASTIC_INSTALL_HOME}  >/dev/null
    ssh root@${hostname}  "chmod -R 755   ${ELASTIC_INSTALL_HOME}"  ## 修改拷过去的文件夹权限为可执行
done
cd -
echo "分发elastic 解压后的 tar包done..."  | tee -a $LOG_FILE  
echo "**********************************************" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE


#####################################################################
#
# 在每个节点上配置安装目录elasticsearch.yml中的:
# node.name: host_name
# network.host：对应节点的IP
#
#####################################################################
echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "每个节点上配置elasticsearch.yml中的node.name........"  | tee -a $LOG_FILE
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
	
	## 配置elasticsearch.yml中的node.name: host_name改为当前节点的主机名
	ssh root@${hostname} "sed -i 's#host_name#${hostname}#g' ${ELASTIC_HOME}/config/elasticsearch.yml"
	echo "修改node.name:${hostname}成功"  | tee -a $LOG_FILE
	
	###################################################################
	## 创建ELASTIC的临时存放目录（获取节点IP的脚本getIp.sh和存储elasticsearch.yml安装目录路径的文件espath.sh）
	## 按照该目录分发获取本机ip地址的脚本
	## 修改拷过去的文件权限为可执行
	## 配置elasticsearch.yml中的network.host: ip_adress
	###################################################################
	ssh root@${hostname}  "mkdir -p ${BIN_DIR}" 
	rsync -rvl ${BIN_DIR}/getIp.sh   root@${hostname}:${BIN_DIR}  >/dev/null
    ssh root@${hostname}  "chmod -R 755   ${BIN_DIR}/getIp.sh"  ## 修改拷过去的文件权限为可执行
	
	## 创建临时文件夹
	ssh root@${hostname}  "mkdir -p /home/hzgc/bigdata_hzgc/install_script/tmp" 
	## 把 获取节点IP的脚本语句 保存到一个临时文件夹中
	ssh root@${hostname} 'echo "ifconfig eth0 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}'" > /home/hzgc/bigdata_hzgc/install_script/tmp/getIp.sh'
	## 把 elasticsearch.yml文件的相对目录路径 保存到一个临时文件夹中
	ssh root@${hostname} "echo "${ELASTIC_HOME}/config/elasticsearch.yml" > /home/hzgc/bigdata_hzgc/install_script/tmp/espath.sh"
	
	## 获取该临时文件中存储的相对目录地址，并配置elasticsearch.yml中的network.host: ip_adress
	ssh root@${hostname} 'espath=$(sed -n '1p' /home/hzgc/bigdata_hzgc/install_script/espath.sh);arg=`sh /home/hzgc/bigdata_hzgc/install_script/getIp.sh`;sed -i "s#ip_adress#${arg}#g" ${espath}'

	## 删除该临时文件夹
	rm -rf /home/hzgc/bigdata_hzgc/install_script/tmp
	
	echo "修改${hostname}的network.host成功"  | tee -a $LOG_FILE
done
cd -

echo "**********************************************" | tee -a $LOG_FILE
echo ""  | tee -a $LOG_FILE



#####################################################################
#
# 每个节点上移动3个文件到相应目录
#
#####################################################################

echo ""  | tee -a $LOG_FILE
echo "**********************************************" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "在每个节点上移动es的3个文件到相应目录下......"    | tee -a $LOG_FILE

echo "移动etc_security_limits.conf 到 目录/etc/security/limits.conf下......"    | tee -a $LOG_FILE
echo "移动etc_security_limits.d_90-nproc.conf 到 目录/etc/security/limits.d/90-nproc.conf下......"    | tee -a $LOG_FILE
echo "移动etc_sysctl.conf 到 目录/etc/sysctl.conf下......"    | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
for hostname in $(cat ${CONF_DIR}/hostnamelists.properties);do
	ssh root@${hostname} "mv ${ELASTIC_HOME}/config/etc_security_limits.conf   /etc/security/limits.conf"
	ssh root@${hostname} "mv ${ELASTIC_HOME}/config/etc_security_limits.d_90-nproc.conf   /etc/security/limits.d/90-nproc.conf"
	ssh root@${hostname} "mv ${ELASTIC_HOME}/config/etc_sysctl.conf   /etc/sysctl.conf"
	echo "${hostname}节点上移动完成."    | tee -a $LOG_FILE
	echo "动态地修改${hostname}内核的运行参数.."    | tee -a $LOG_FILE
	ssh root@${hostname} "sysctl -p"
	echo ""    | tee -a $LOG_FILE
done
cd -

set +x
