#!/bin/bash
#判断参数是否为空
pcount=$#
if(($pcount<1)) ; then
  echo no args
  exit
fi
#获取文件名
p1=$1
fname=`basename $p1`
#获取绝对路径
pdir=`dirname $p1`
pdir=`cd $pdir;pwd`
cuser=`whoami`
#分发文件
for((host=106;host<109;host=host+1)); do
echo ---------- s$host ----------
rsync -rvl $pdir/$fname $cuser@s$host:$pdir
done
