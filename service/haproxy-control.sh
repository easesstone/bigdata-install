#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    ftpoverkafka
## Description: to start or stop or restart haproxy
## Version:     1.0
## Author:      caodabao
## Created:     2017-11-15
################################################################################
# haproxy     Startup script for the haproxy
#下面两行注释解决“服务不支持 chkconfig”：
#chkconfig: 2345 80 90
#description:auto_run

#set -x

HAPROXY_DIR=""                                   ##haproxy根目录
HAPROXY_LOG=""                                   ##日志目录
LOG_FILE=${HAPPROXY_DIR}/haproxy_start.log       ##日志文件
HAPROXY_SBIN=${HAPROXY_DIR}/sbin                 ##haproxy的sbin目录
source /etc/profile
stop_haproxy=1                                   ## 判断ftp是否关闭成功 1->失败 0->成功 默认失败
start_haproxy=1                                  ## 判断ftp是否关闭成功 1->失败 0->成功 默认失败

[ -f ${HAPROXY_DIR}/haproxy.cfg ] || exit 0

stop() {
    echo ""  | tee -a $LOG_FILE
    echo "****************************************************"  | tee -a $LOG_FILE
    echo "haproxy procceding......................." | tee  -a $LOG_FILE
    haproxy_pid=$(ps -C haproxy --no-header | awk '{print $1}')
    echo "haproxy's pid is: ${haproxy_pid}"  | tee -a $LOG_FILE
    if [ -n "${haproxy_pid}" ];then
	echo "haproxy process is exit,exit with 0,kill haproxy now " | tee -a $LOG_FILE  
        kill -9 ${haproxy_pid}
        sleep 5s
        haproxy_pid=$(ps -C haproxy --no-header | awk '{print $1}')
        if [ -n "${haproxy_pid}" ];then
            stop_haproxy=1
            echo "stop haproxy failure, retry it again."  | tee -a  $LOG_FILE
        else
            stop_haproxy=0
            echo "stop haproxy sucessed."  | tee -a  $LOG_FILE
        fi
    else 
        echo "haproxy process is not exit."   | tee -a $LOG_FILE
        stop_haproxy=0
    fi
}

start() {
    ${HAPROXY_SBIN}/haproxy -f  ${HAPROXY_DIR}/haproxy.cfg
    echo "starting, please wait........" | tee -a $LOG_FILE
    sleep 3s
    haproxy_pid=$(ps -C haproxy --no-header | awk '{print $1}')
    echo -e "${haproxy_pid}"
    if [ -z "${haproxy_pid}" ];then
        start_haproxy=1
        echo "start haproxy failed.....,retrying to start it second time"  | tee -a $LOG_FILE
    else
        echo "start haproxy sucessed. exit with 0."  | tee -a  $LOG_FILE
        start_haproxy=0
    fi
}

restart() {
   stop
    if [ ${stop_haproxy} -eq 0 ];then
        echo "stop haproxy sucessed" | tee -a  $LOG_FILE  
    else
        stop
        if [ ${stop_haproxy} -eq 1 ];then
            echo "retry stop haproxy failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
    start
    if [ ${start_haproxy} -eq 0 ];then
        echo "start haproxy sucessed" | tee -a  $LOG_FILE  
    else
        start
        if [ ${start_haproxy} -eq 1 ];then
            echo "retry start haproxy failed please check the config......exit with 1" | tee -a  $LOG_FILE
        fi
    fi
}


status() {
    if [ $num -ne 0 ]; then
        ps -e | grep haproxy
    else
        echo -e "no haproxy started"
    fi
}


# Possible parameters
case "$1" in
    start)
        start
        if [ ${start_haproxy} -eq 0 ];then
            echo "start haproxy sucessed" | tee -a  $LOG_FILE  
        else
            start
            if [ ${start_haproxy} -eq 1 ];then
                echo "retry start haproxy failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    stop)
        stop
        if [ ${stop_haproxy} -eq 0 ];then
            echo "stop haproxy sucessed" | tee -a  $LOG_FILE  
        else
            stop
            if [ ${stop_haproxy} -eq 1 ];then
                echo "retry stop haproxy failed please check the config......exit with 1" | tee -a  $LOG_FILE
            fi
        fi
    ;;
    restart)
        restart
    ;;
    status)
        status
    ;;
  *)
echo "Usage: haproxy {start|stop|restart|status}"
exit 1
esac

