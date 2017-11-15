#!/bin/bash
set -x

#cd `dirname $0`
#:pwd
INSTALL_HOME=/opt/hzgc/bigdata

#zookeeper home
export ZOOKEEPER_HOME=${INSTALL_HOME}/Zookeeper/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin

#hadoop home 
export HADOOP_HOME=${INSTALL_HOME}/Hadoop/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

#hbase home 
export HBASE_HOME=${INSTALL_HOME}/HBase/hbase
export PATH=$PATH:$HBASE_HOME/bin

#spark home
export SPARK_HOME=${INSTALL_HOME}/Spark/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

#kafka home
export KAFKA_HOME=${INSTALL_HOME}/Kafka/kafka
export PATH=$PATH:$KAFKA_HOME/bin

#hive home
export HIVE_HOME=${INSTALL_HOME}/Hive/hive
export PATH=$PATH:$HIVE_HOME/bin

#java home
export JAVA_HOME=${INSTALL_HOME}/JDK/jdk
export PATH=$PATH:$JAVA_HOME/bin

#haproxy home
export HAPOXY_HOME=${INSTALL_HOME}/HAPrxoy/haproxy
export PATH=$PATH:$HAPOXY_HOME/sbin

#es home
export ES_HOME=${INSTALL_HOME}/Elastic/elastic
export PATH=$PATH:$ES_HOME/bin

#rocketmq home
export ROCKETMQ_HOME=${INSTALL_HOME}/RocketMQ/rocketmq
export PATH=$PATH:$ROCKETMQ_HOME/bin

set +x
