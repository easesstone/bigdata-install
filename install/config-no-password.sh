#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    conf-no-need-password.sh
## Description: 配置ssh 免密码登录
##              实现自动化的脚本
## Version:     1.0
## Author:      lidiliang
## Created:     2017-11-25
################################################################################

#set -x

#---------------------------------------------------------------------#
#                              定义变量                               #
#---------------------------------------------------------------------#
cd `dirname $0`
## 脚本所在目录
export BIN_DIR=`pwd`
cd ..
## 安装包根目录
export ROOT_HOME=`pwd`
## 配置文件目录
export CONF_DIR=${ROOT_HOME}/conf
## 安装日记目录
export LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
export LOG_FILE=${LOG_DIR}/donot-need-to-enter-password-conf.log
## 系统root 用密码
export PASSWORD=123456
## authorized_keys 内容所在文件
export AUTHORIZED_KEYS=${BIN_DIR}/authorized_keys.log


#####################################################################
# 函数名: ssh_keygen
# 描述:  单节点下生成sshkey
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
ssh_keygen(){
    expect << EOF
    set timeout 2
    spawn ssh root@$1 "ssh-keygen  -t rsa -C root@$1"
    while 1 {
        expect {
            "*assword:" {send "${PASSWORD}\n"}
            "yes/no*" {send "yes\n"}
            "Enter file in which to save the key*" {send "\n"}
            "Enter passphrase*" {send "\n"}
            "Enter same passphrase again:" {send "\n"}
            "Overwrite (y/n)" {send "y\n"}
            eof {exit}
        }
    }
EOF
}



#####################################################################
# 函数名: get_id_rsa
# 描述:  取得单个节点的id_rsa.pub 的内容
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
get_id_rsa(){
    expect <<EOF
    set timeout 1
    spawn ssh root@$1
    expect {
        "password" {send "${PASSWORD}\r";}
        "yes/no" {send "yes\r";exp_continue}
    }
    expect "*#"
    send "cat /root/.ssh/id_rsa.pub;\n"  
    expect eof
    exit
EOF
}  

#####################################################################
# 函数名: ssh_conf_first_yes
# 描述:  配置ssh 服务，让其第一次登录免输入yes
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
ssh_conf_first_yes(){
    expect <<EOF
    set timeout 1
    spawn ssh root@$1
    expect {
        "password" {send "${PASSWORD}\r";}
        "yes/no" {send "yes\r";exp_continue}
    }
    expect "*#"
    send "echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config;\n" 
    expect eof 
    exit 
EOF
}


#####################################################################
# 函数名: deliver_authorizedkesy_to_other_node
# 描述:  分发authorized_keys
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
deliver_authorizedkesy_to_other_node(){
    expect <<EOF
    set timeout 1
    spawn scp /root/.ssh/authorized_keys root@$1:/root/.ssh
    expect {
        "*assword" {send "${PASSWORD}\r";}
        "yes/no" {send "yes\r";exp_continue}
    }
    expect eof
    exit
EOF
}



#####################################################################
# 函数名: get_authorized_keys_log
# 描述:  登录扫所有节点执行ssh-kegen -t rsa -C root@hostname 操作
#        ，并收集所有的id_rsa.pub 的内容到authorized_keys.log 文件中
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
get_authorized_keys_log(){
    for host in $(cat ${CONF_DIR}/hostnamelists.properties);do
        ssh_keygen ${host}
        get_id_rsa ${host}  | tee -a ${AUTHORIZED_KEYS}
    done
}

#####################################################################
# 函数名: get_authorized_keys_log
# 描述: 生成所有节点的authorized_keys
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
get_authorized_keys(){
    cat  ${AUTHORIZED_KEYS}  | grep ssh-rsa  > /root/.ssh/authorized_keys
    rm -rf ${AUTHORIZED_KEYS}
}



#####################################################################
# 函数名: deliver_authorizedkesy_to_other_nodes
# 描述: 分发authorized_keys 到每个节点
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
deliver_authorizedkesy_to_other_nodes(){
    for host in $(cat ${CONF_DIR}/hostnamelists.properties);do
        deliver_authorizedkesy_to_other_node ${host}
    done
}



#####################################################################
# 函数名: config_no_password
# 描述: 给每个节点配置ssh服务，让其在第一次连接其他节点的时候不用输入yes
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
config_no_password(){
    i=0
    for host in $(cat ${CONF_DIR}/hostnamelists.properties);do
        let i++
        echo  $i
        ssh_conf_first_yes ${host}
    done        
}

#####################################################################
# 函数名: main
# 描述:  
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
main(){
    echo >  ${AUTHORIZED_KEYS}


    if [ ! -d $LOG_DIR ];then
        mkdir -p $LOG_DIR;
    fi

    echo ""  | tee  -a  $LOG_FILE
    echo ""  | tee  -a  $LOG_FILE
    echo "==================================================="  | tee -a $LOG_FILE
    echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

    get_authorized_keys_log
    get_authorized_keys
    deliver_authorizedkesy_to_other_nodes
    config_no_password
}




## main 入口

main
if [ $? == 0 ];then
    echo "config ssh to other node without password success..."
else
    echo "config ssh to other node without password failed...."
fi

