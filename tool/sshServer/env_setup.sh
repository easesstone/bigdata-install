#!/bin/bash

#configuration
USER=root
BASEDIR=~/.ssh
PASSWORD=123456

#function

#generate rsa
keygen()
{
  expect << EOF
  spawn ssh ${USER}@$1 ssh-keygen
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

#get id_rsa.put from cluster ip

Get_pub()
{
expect << EOF
spawn scp ${USER}@$1:~/.ssh/id_rsa.pub ${BASEDIR}/
  expect {
    "*assword:" {send "${PASSWORD}\n";exp_continue}
    "yes/no*" {send "yes\n";exp_continue}
    eof {exit}
  }
EOF
}

#put the id_rsa.put into authorized_keys
Put_pub()
{
src_pub="$(cat ${BASEDIR}/id_rsa.pub)"
expect << EOF
spawn ssh ${USER}@$1 "mkdir -p ~/.ssh;echo $src_pub >> ~/.ssh/authorized_keys;chmod 600 ~/.ssh/authorized_keys"
  expect {
    "*assword:" {send "${PASSWORD}\n";exp_continue}
    "yes/no*" {send "yes\n";exp_continue}
    eof {exit}
  }
EOF
}

#delete authorized_keys
Delete_authorized_keys()
{
expect << EOF
spawn ssh ${USER}@$1 "rm -rf ~/.ssh/authorized_keys"
  expect {
    "*assword:" {send "${PASSWORD}\n";exp_continue}
    "yes/no*" {send "yes\n";exp_continue}
    eof {exit}
  }
EOF
}

#delete known_hosts
Delete_known_hosts()
{
expect << EOF 
spawn ssh ${USER}@$1 "rm -rf ~/.ssh/known_hosts"
  expect {
    "*assword:" {send "${PASSWORD}\n";exp_continue}
    "yes/no*" {send "yes\n";exp_continue}
    eof {exit}
  }
EOF
}

#start configer ssh
cluster_ip=`cat ssh_ip_list`
for ip in ${cluster_ip}
do
  echo
  echo "delete wuathorized_keys of $ip"
  Delete_authorized_keys $ip
  Delete_known_hosts $ip
done

for local_ip in ${cluster_ip}
do
  keygen $local_ip
  Get_pub $local_ip
  for remote_ip in ${cluster_ip}
    do
      echo
      echo "create credible connection from $local_ip to $remote_ip"
      Put_pub $remote_ip
    done
done

#add known hosts
Add_known_hosts()
{
expect << EOF
spawn ssh ${USER}@$1 "hostname"
  expect {
    "*assword:" {send "${PASSWORD}\n";exp_continue}
    "yes/no*" {send "yes\n";exp_continue}
    eof {exit}
  }
EOF
}

for ip in ${cluster_ip}
do
  echo
  echo "add $ip to known_hosts"
  Add_known_hosts $ip
done



#Copying ssh_ip_list to host $host ...
for host in ${cluster_ip}
    do
        echo ''
        echo "############################################################################"
        echo "Copying ssh_ip_list to host $host ..."
        echo "############################################################################"
        echo ''
        expect -c "
        set timeout 1
        spawn scp -r /root/ssh_ip_list "$USER@$host:/root"
        expect \"password:\"
        send -- $PASSWORD\r
        expect eof
        "
    done
#Copying ssh4slaves.sh to host $host ...
for host in ${cluster_ip}
    do
        echo ''
        echo "############################################################################"
        echo "Copying ssh4slaves.sh to host $host ..."
        echo "############################################################################"
        echo ''
        expect -c "
        set timeout 1
        spawn scp -r /root/ssh4slaves.sh "$USER@$host:/root"
        expect \"password:\"
        send -- $PASSWORD\r
        expect eof
        "
    done
#do /root/ssh4slaves.sh on host $host...	
for host in ${cluster_ip}
    do
        echo ''
        echo "############################################################################"
        echo "do /root/ssh4slaves.sh on host $host..."
        echo "############################################################################"
        echo ''
        expect -c "
        set timeout 10
        spawn ssh -q ${USER}@$host "/root/ssh4slaves.sh"
        expect \"password:\"
        send -- $PASSWORD\r
        expect eof
        "
    done






