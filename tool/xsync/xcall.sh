#!/bin/bash

#判断参数是否为空
pcount=$#
if(($pcount<1)) ; then
  echo no args
  exit
fi
#执行本地命令
echo ---------- localhost ----------
  $@
#远程登录节点执行命令
for((host=106;host<108;host=host+1)); do
  echo ---------- s$host ----------
  ssh s$host $@
done
