#!/bin/bash

echo -e "关闭HiveServer服务："

	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi



for name in $@
	do
		ssh root@$name "ps -ef | grep RunJar | grep -v grep | awk '{print $name}' | xargs kill -9"
	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi

done



		#ssh root@dk42 'ps -ef | grep RunJar | grep -v grep | awk \'{print $2}\' | xargs kill -9'
