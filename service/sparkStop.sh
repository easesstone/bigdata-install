#!/bin/bash

echo -e "关闭Spark集群 \n"
/usr/local/spark-*/sbin/stop-all.sh
	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi
	
ssh root@$2 '/usr/local/spark*/sbin/stop-master.sh '
	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi

/usr/local/spark*/sbin/stop-thriftserver.sh --hiveconf hive.server2.thrift.port=10001  --hiveconf hive.server2.thrift.bind.host=localhost --master yarn-client
	if [ $? -eq 0 ];then
	    echo -e "dkhstopsuccess\n"
	else 
	    echo -e "dkhstopfailed\n"
	fi
