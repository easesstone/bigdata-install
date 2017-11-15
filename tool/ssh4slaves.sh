#!/bin/bash

export FILELOC="/root"
export SLAVES=`cat $FILELOC/ssh_ip_list`
export USER=root
export PASSWD=123456

for host in $SLAVES
do
    echo ''
    echo "Ensure ssh passwordless works among all slave nodes..."
    echo ''
    expect -c "
        set timeout 1
        spawn ssh $USER@$host
        expect \"yes/no\"
        send -- \"yes\r\"
        expect eof
     "
 done
