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
## BIN目录，脚本所在的目录
BIN_DIR=`pwd`
cd ..
## 安装包根目录
ROOT_HOME=`pwd`
## mysql rpm 软件包所在目录
MYSQL_RPM_DIR=${ROOT_HOME}/component/mysqlRpm
## 日记目录
LOG_DIR=${ROOT_HOME}/logs
## mysql 安装日记
LOG_FILE=${LOG_DIR}/mysqlInstall.log

mkdir -p ${LOG_DIR}

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 首先检查本机上是否安装有mysql 如果有，则删除本机的mysql 
rpm -qa | grep mysql   > mysql.tmp
for rpm_pak in $(cat  mysql.tmp);do
    echo "删除原先系统mysql rpm 软件包: ${rpm_pak}"  |  tee  -a  $LOG_FILE
    rpm -e --nodeps ${rpm_pak}
done
rm -rf mysql.tmp

## 重新安装mysql
rpm -ivh ${MYSQL_RPM_DIR}/mysql-community-common-5.7.19-1.el6.x86_64.rpm
rpm -ivh ${MYSQL_RPM_DIR}/mysql-community-libs-5.7.19-1.el6.x86_64.rpm
rpm -ivh ${MYSQL_RPM_DIR}/mysql-community-client-5.7.19-1.el6.x86_64.rpm
rpm -ivh ${MYSQL_RPM_DIR}/mysql-community-server-5.7.19-1.el6.x86_64.rpm

## 启动mysql 服务
service mysqld start

## 显示初始时候的临时密码
password=$(cat /var/log/mysqld.log|grep 'temporary password'  | awk -F ": " '{print $NF}')
if [ -n "${password}" ];then
    echo "the password is:  ${password}"  | tee  -a  $LOG_FILE
    echo  "install mysql done ！！！"  | tee  -a  $LOG_FILE
else 
    echo "install mysql failed !!! please check the error and fixed it..."  | tee  -a  $LOG_FILE
fi 

