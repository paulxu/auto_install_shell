#!/bin/bash

# set ulimit
ulimit -n 655360

export JAVA_HOME=/usr/java/default
export JRE_HOME=/usr/java/default
PATH=$JAVA_HOME/bin:$PATH

# http install  package
#export HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)

export TD_BASE=/home/temp
export TD_DATA=$TD_BASE/data


# http environment
export HBASE_HOME=$TD_BASE/hbase
export HBASE_LOG_DIR=$TD_DATA/logs/hbase
export HBASE_PID_DIR=$TD_DATA/pids/hbase
export HBASE_IDENT_STRING=dscs
export HBASE_MANAGES_ZK=false
export HBASE_CLASSPATH=$TD_BASE/hadoop/etc/hadoop
export HBASE_CLASSPATH=$TD_BASE/hadoop/etc/hadoop
PATH=$HBASE_HOME/bin:$PATH


# hadoop environment
export HADOOP_HOME=$TD_BASE/hadoop
export HADOOP_LOG_DIR=$TD_DATA/logs/hadoop
export HADOOP_PID_DIR=$TD_DATA/pids/hadoop
export HADOOP_IDENT_STRING=dscs
export YARN_LOG_DIR=$TD_DATA/logs/
export YARN_IDENT_STRING=dscs
export YARN_PID_DIR=$TD_DATA/pids/
PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH