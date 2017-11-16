#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    dubbos
## Description: to start or stop or restart dubbo
## Version:     1.0
## Author:      caodabao
## Created:     2017-11-16
################################################################################
#下面两行注释解决“服务不支持 chkconfig”：
#chkconfig: 2345 80 90
#description:auto_run

#set -x

LOG_FILE=/opt/RealTimeCompare/logs/dubbo_start.log              ## log 日记文件
BIN_DIR=/opt/RealTimeCompare/bin                                ## bin 目录
source /etc/profile
stop_dubbo=1                                                      ## 判断dubbo是否关闭成功 1->失败 0->成功 默认失败
start_dubbo=1                                                     ## 判断dubbo是否关闭成功 1->失败 0->成功 默认失败

stop() {
    echo ""  | tee -a $LOG_FILE
    echo "****************************************************"  | tee -a $LOG_FILE
    echo "dubbo procceding......................." | tee  -a $LOG_FILE
    dubbo_pid=$(netstat -anp|grep 20881|awk '{printf $7}'|cut -d/ -f1)
    echo "dubbo's pid is: ${dubbo_pid}"  | tee -a $LOG_FILE
    if [ -n "${dubbo_pid}" ];then
        echo "dubbo process is exit,exit with 0,kill dubbo now " | tee -a $LOG_FILE  
        kill -9 ${dubbo_pid}
        sleep 5s
        dubbo_pid=$(netstat -anp|grep 20881|awk '{printf $7}'|cut -d/ -f1)
        if [ -n "${dubbo_pid}" ];then
            stop_dubbo=1
            echo "stop dubbo failure, retry it again."  | tee -a  $LOG_FILE
        else
            stop_dubbo=0
            echo "stop dubbo sucessed, just to restart dubbo."  | tee -a  $LOG_FILE
        fi
    else 
        echo "dubbo process is not exit, just to restart dubbo."   | tee -a $LOG_FILE
        stop_dubbo=0
    fi
}
start() {
    sh ${BIN_DIR}/start-dubbo.sh
    echo "starting, please wait........" | tee -a $LOG_FILE
    sleep 3s
    dubbo_pid_restart=$(netstat -anp|grep 20881|awk '{printf $7}'|cut -d/ -f1)
    echo -e "${dubbo_pid_restart}"
    if [ -z "${dubbo_pid_restart}" ];then
        start_dubbo=1
        echo "start dubbo failed.....,retrying to start it second time"  | tee -a $LOG_FILE
    else
        echo "start dubbo sucessed. exit with 0."  | tee -a  $LOG_FILE
        start_dubbo=0
    fi
}
restart(){
    stop
    if [ ${stop_dubbo} -eq 0 ];then
        echo "stop dubbo sucessed" | tee -a  $LOG_FILE  
    else
        stop
        if [ ${stop_dubbo} -eq 1 ];then
            echo "retry stop dubbo failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
    start
    if [ ${start_dubbo} -eq 0 ];then
        echo "start dubbo sucessed" | tee -a  $LOG_FILE  
    else
        start
        if [ ${start_dubbo} -eq 1 ];then
            echo "retry start dubbo failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
}


# Possible parameters
case "$1" in
    start)
        start
        if [ ${start_dubbo} -eq 0 ];then
            echo "start dubbo sucessed" | tee -a  $LOG_FILE  
        else
            start
            if [ ${start_dubbo} -eq 1 ];then
                echo "retry start dubbo failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    stop)
        stop
        if [ ${stop_dubbo} -eq 0 ];then
            echo "stop dubbo sucessed" | tee -a  $LOG_FILE  
        else
            stop
            if [ ${stop_dubbo} -eq 1 ];then
                echo "retry stop dubbo failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    restart)
        restart
    ;;
  *)
    echo "Usage: dubbo {start|stop|restart}"
    exit 1
esac
exit $? 
