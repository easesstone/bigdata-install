#!/bin/bash

echo -e "关闭Elasticsearch \n"
for name in $@
do

	ssh root@$name '/usr/local/elasticsearch*/bin/elasticsearch stop'
	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi

done