#!/bin/bash

echo -e "启动Spark集群 \n"
/usr/local/spark-*/sbin/start-all.sh
	if [ $? -eq 0 ];then
	    echo -e 'dkhstartsuccess \n'
	else 
	    echo -e 'dkhstartfailed \n'
	fi
ssh root@$2 '/usr/local/spark*/sbin/start-master.sh '
	if [ $? -eq 0 ];then
	    echo -e 'dkhstartsuccess \n'
	else 
	    echo -e 'dkhstartfailed \n'
	fi

/usr/local/spark*/sbin/start-thriftserver.sh --hiveconf hive.server2.thrift.port=10001  --hiveconf hive.server2.thrift.bind.host=localhost --master yarn-client
	if [ $? -eq 0 ];then
	    echo -e 'dkhstartsuccess \n'
	else 
	    echo -e 'dkhstartfailed \n'
	fi
