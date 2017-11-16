#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    ftp_dubbo_install
## Description: 将ftp、dubbo服务添加到开机启动
## Version:     1.0
## Author:      caodabao
## Created:     2017-11-16
################################################################################

## 脚本所在目录
BIN_DIR=`pwd`
cd ..
## 安装包根目录
ROOT_HOME=`pwd`
## 日记目录
LOG_DIR=${ROOT_HOME}/logs
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## haproxy 安装日记
LOG_FILE=${LOG_DIR}/ftp_dubbo_install.log
## FTP_INIT 开机启动脚本
FTP_INIT=/etc/rc.d/init.d/dubbos
## Dubbo_INIT 开机启动脚本
Dubbo_INIT=/etc/rc.d/init.d/dubbos
#####################################################################
# 函数名:install_ftp_init 
# 描述: 将ftp服务添加到开机启动
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function install_ftp_init ()
{
    if [ ! -e "$FTP_INIT" ]; then
        echo "*******************************************************************"  | tee  -a  ${LOG_FILE}
        for hostname in $(cat ${CONF_DIR}/hostnamelists.properties)
        echo "Add the ftp service to the system startup in ${hostname}"  | tee  -a  ${LOG_FILE}
        do
            scp -r ${ROOT_HOME}/service/ftpoverkafka.sh   root@${hostname}:/etc/rc.d/init.d/ftpoverkafka  >/dev/null
            chmod +x /etc/rc.d/init.d/ftpoverkafka
            chkconfig --add ftpoverkafka
            chkconfig ftpoverkafka on
        done
    else
        echo "File ftpoverkafka already there !" | tee -a ${LOG_FILE}
    fi
}


#####################################################################
# 函数名:install_dubbo_init 
# 描述: 将dubbo服务添加到开机启动
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function install_dubbo_init ()
{
    if [ ! -e "$Dubbo_INIT" ]; then
        echo "*******************************************************************"  | tee  -a  ${LOG_FILE}
        for hostname in $(cat ${CONF_DIR}/hostnamelists.properties)
        echo "Add the dubbos service to the system startup in ${hostname}"  | tee  -a  ${LOG_FILE}
        do
            scp -r ${ROOT_HOME}/service/dubbos.sh   root@${hostname}:/etc/rc.d/init.d/dubbos  >/dev/null
            chmod +x /etc/rc.d/init.d/dubbos
            chkconfig --add dubbos
            chkconfig dubbos on
        done
    else
        echo "File dubbos already there !" | tee -a ${LOG_FILE}
    fi
}


#####################################################################
# 函数名: main
# 描述: 模块功能main 入口，即程序入口, 用来将ftp、dubbo服务添加到开机启动。
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    install_ftp_init
    install_dubbo_init
}

# 主程序入口
main

set +x