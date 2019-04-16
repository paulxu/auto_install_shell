#!/bin/bash

#########################确认安装时所在目录为scripts##########################
HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)
source $HADOOP_PACKAGE_PATH/env/env.sh

# 关闭Hadoop 所有组件
echo -e "\033[31m stop hadoop all plugin \033[0m "

/bin/sh $HADOOP_PACKAGE_PATH/run.sh autostop

# 获取DATANODE dscn1,dscn2....
HADOOP_DATA_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_DATA_NODE | awk -F "=" '{print$2}')
# 获取NAMENODE dscn1,dscn2....
HADOOP_NAME_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_NAME_NODE | awk -F "=" '{print$2}')

# 清理 zookeeper
ZOOKEEPER_HOME=$(cat $HADOOP_PACKAGE_PATH/config | grep ZOOKEEPER_HOME | awk -F "=" '{print$2}')
ZOOKEEPER_DATA_FOR_HADOOP=$(cat $HADOOP_PACKAGE_PATH/config | grep ZOOKEEPER_DATA_FOR_HADOOP | awk -F "=" '{print$2}')


echo -e "\033[31m  delete from zookeeper  $ZOOKEEPER_DATA_FOR_HADOOP  \033[0m"
/bin/sh $ZOOKEEPER_HOME/bin/zkCli.sh deleteall $ZOOKEEPER_DATA_FOR_HADOOP
# 清理 hdfs 目录
# 获得需要删除的路径
HADOOP_TMP=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_TMP | awk -F "=" '{print$2}')
if [ ! -n "$HADOOP_TMP" ]; then
   echo -e "\033[31m HADOOP_TMP IS NULL \033[0m "
   exit 1 
else
    source $HADOOP_PACKAGE_PATH/env/env.sh
    OLD_IFS="$IFS"
    IFS=","
    arr=($HADOOP_DATA_NODE)
    IFS="$OLD_IFS"
    for s in ${arr[@]}; do
        echo -e "\033[33m delete from $s path $HADOOP_TMP \033[0m "
        ssh "$s" "[ -d  $HADOOP_TMP ] && rm -rf $HADOOP_TMP  || echo Is not Path ok "
    done
    
fi 
DATA_NODE_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep DATA_NODE_PATH | awk -F "=" '{print$2}')
if [ ! -n "$DATA_NODE_PATH" ]; then
   echo -e "\033[31m DATA_NODE_PATH IS NULL \033[0m "
   exit 1 
else
        source $HADOOP_PACKAGE_PATH/env/env.sh
        OLD_IFS="$IFS"
        IFS=","
        arr=($DATA_NODE_PATH)
        IFS="$OLD_IFS"
        for s in ${arr[@]}; do
           # remove file://
            DATA_NODE_PATH_REP=$( echo  $s | grep file: | awk -F "//" '{print$2}')
            OLD_IFS="$IFS"
            IFS=","
            arr=($HADOOP_DATA_NODE)
            IFS="$OLD_IFS"
            for s in ${arr[@]}; do
                echo -e "\033[33m delete from $s path $DATA_NODE_PATH_REP \033[0m "
                ssh "$s" "[ -d  $DATA_NODE_PATH_REP ] && rm -rf $DATA_NODE_PATH_REP  || echo Is not Path ok "
            done
        done
fi 
JOURNAL_DATA_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep JOURNAL_DATA_PATH | awk -F "=" '{print$2}')
if [ ! -n "$JOURNAL_DATA_PATH" ]; then
   echo -e "\033[31m JOURNAL_DATA_PATH IS NULL \033[0m "
   exit 1 
else
        source $HADOOP_PACKAGE_PATH/env/env.sh
        OLD_IFS="$IFS"
        IFS=","
        arr=($HADOOP_DATA_NODE)
        IFS="$OLD_IFS"
        for s in ${arr[@]}; do
            echo -e "\033[33m delete from $s path $JOURNAL_DATA_PATH \033[0m "
            ssh "$s" "[ -d  $JOURNAL_DATA_PATH ] && rm -rf $JOURNAL_DATA_PATH  || echo Is not Path ok "
        done
fi 
NAME_NODE_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep NAME_NODE_PATH | awk -F "=" '{print$2}')
# remove file://
NAME_NODE_PATH_REP=$( echo  $NAME_NODE_PATH | grep file: | awk -F "//" '{print$2}')
if [ ! -n "$NAME_NODE_PATH" ]; then
   echo -e "\033[31m NAME_NODE_PATH IS NULL \033[0m "
   exit 1 
else
        source $HADOOP_PACKAGE_PATH/env/env.sh
        OLD_IFS="$IFS"
        IFS=","
        arr=($HADOOP_DATA_NODE)
        IFS="$OLD_IFS"
        for s in ${arr[@]}; do
            echo -e "\033[33m delete from $s path $NAME_NODE_PATH_REP \033[0m "
            ssh "$s" "[ -d  $NAME_NODE_PATH_REP ] && rm -rf $NAME_NODE_PATH_REP  || echo Is not Path ok "
        done
fi 

# 清理 Hadoop 目录

if [ ! -n "$HADOOP_HOME" ]; then
   echo -e "\033[31m HADOOP_HOME IS NULL \033[0m "
   exit 1 
else
        source $HADOOP_PACKAGE_PATH/env/env.sh
        OLD_IFS="$IFS"
        IFS=","
        arr=($HADOOP_DATA_NODE)
        IFS="$OLD_IFS"
        for s in ${arr[@]}; do
           echo -e "\033[33m delete from $s path $HADOOP_HOME \033[0m "
            ssh "$s" "[ -d  $HADOOP_HOME ] && rm -rf $HADOOP_HOME  || echo Is not Path ok "
        done
fi 

# 清理临时文件目录

if [ ! -n "$HADOOP_PACKAGE_PATH" ]; then
   echo -e "\033[31m HADOOP_PACKAGE_PATH IS NULL \033[0m "
   exit 1 
else
       source $HADOOP_PACKAGE_PATH/env/env.sh
        OLD_IFS="$IFS"
        IFS=","
        arr=($HADOOP_DATA_NODE)
        IFS="$OLD_IFS"
        for s in ${arr[@]}; do
            echo -e "\033[33m delete from $s path $HADOOP_PACKAGE_PATH \033[0m "
            ssh "$s" "[ -d  $HADOOP_PACKAGE_PATH ] && rm -rf $HADOOP_PACKAGE_PATH  || echo Is not Path ok "
        done
fi 

 echo -e "\033[33m Clear Hadoop Success \033[0m "