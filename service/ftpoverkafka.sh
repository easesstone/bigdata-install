#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    ftpoverkafka
## Description: to start or stop or restart ftp
## Version:     1.0
## Author:      caodabao
## Created:     2017-11-15
################################################################################
#下面两行注释解决“服务不支持 chkconfig”：
#chkconfig: 2345 80 90
#description:auto_run

#set -x

LOG_FILE=/opt/RealTimeCompare/logs/ftpserver_start.log          ## log 日记文件
BIN_DIR=/opt/RealTimeCompare/bin                                ## bin 目录
source /etc/profile
stop_ftp=1                                                      ## 判断ftp是否关闭成功 1->失败 0->成功 默认失败
start_ftp=1                                                     ## 判断ftp是否关闭成功 1->失败 0->成功 默认失败

stop() {
    echo ""  | tee -a $LOG_FILE
    echo "****************************************************"  | tee -a $LOG_FILE
    echo "ftp procceding......................." | tee  -a $LOG_FILE
    ftp_pid=$(jps | grep LocalOverFtpServer | awk '{print $1}')
    echo "ftp's pid is: ${ftp_pid}"  | tee -a $LOG_FILE
    if [ -n "${ftp_pid}" ];then
        echo "ftp process is exit,exit with 0,kill ftp now " | tee -a $LOG_FILE  
        kill -9 ${ftp_pid}
        sleep 5s
        ftp_pid=$(jps | grep LocalOverFtpServer | awk '{print $1}')
        if [ -n "${ftp_pid}" ];then
            stop_ftp=1
            echo "stop ftp failure, retry it again."  | tee -a  $LOG_FILE
        else
            stop_ftp=0
            echo "stop ftp sucessed, just to restart ftp."  | tee -a  $LOG_FILE
        fi
    else 
        echo "ftp process is not exit, just to restart ftp."   | tee -a $LOG_FILE
        stop_ftp=0
    fi
}
start() {
    sh ${BIN_DIR}/start-ftpserver.sh
    echo "starting, please wait........" | tee -a $LOG_FILE
    sleep 3s
    ftp_pid_restart=$(jps | grep LocalOverFtpServer | awk '{print $1}')
    echo -e "${ftp_pid_restart}"
    if [ -z "${ftp_pid_restart}" ];then
        start_ftp=1
        echo "start ftp failed.....,retrying to start it second time"  | tee -a $LOG_FILE
    else
        echo "start ftp sucessed. exit with 0."  | tee -a  $LOG_FILE
        start_ftp=0
    fi
}
restart(){
    stop
    if [ ${stop_ftp} -eq 0 ];then
        echo "stop ftp sucessed" | tee -a  $LOG_FILE  
    else
        stop
        if [ ${stop_ftp} -eq 1 ];then
            echo "retry stop ftp failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
    start
    if [ ${start_ftp} -eq 0 ];then
        echo "start ftp sucessed" | tee -a  $LOG_FILE  
    else
        start
        if [ ${start_ftp} -eq 1 ];then
            echo "retry start ftp failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
}


# Possible parameters
case "$1" in
    start)
        start
        if [ ${start_ftp} -eq 0 ];then
            echo "start ftp sucessed" | tee -a  $LOG_FILE  
        else
            start
            if [ ${start_ftp} -eq 1 ];then
                echo "retry start ftp failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    stop)
        stop
        if [ ${stop_ftp} -eq 0 ];then
            echo "stop ftp sucessed" | tee -a  $LOG_FILE  
        else
            stop
            if [ ${stop_ftp} -eq 1 ];then
                echo "retry stop ftp failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    restart)
        restart
    ;;
  *)
    echo "Usage: ftp {start|stop|restart}"
    exit 1
esac
exit $? 
