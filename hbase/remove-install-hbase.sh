#!/bin/bash

########################配置hbase#############
HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
source $HBASE_PACKAGE_PATH/env/env.sh

#####################公用区###################

# 创建防止误删操作

flag=1
while [ $ln_i -ne '0' ]; do
	echo -n -e "\033[31m \n是否要继续执行? 继续执行输入Y 退出安装输入 N   \033[0m"
	read ANSWER
	if [[ $ANSWER == Y* || $ANSWER == y* ]]; then
		echo -e "\033[32m \n你的选择是 $ANSWER 继续清理 \n\033[0m"
		sleep 1
		flag=0
	elif [[ $ANSWER == N* ]] || [[ $ANSWER == 'n' ]]; then
		echo -e "\033[31m \n你的选择是 $ANSWER 退出清理\n\033[0m"
		sleep 1
		flag=0
		exit 1
	else
		echo -e "\033[31m \n输入错误，请重新 \033[0m"
		sleep 1
	fi
done

# 获取HBASE_REGION 数量
HBASE_REGION=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_REGION | awk -F "=" '{print$2}')
# 获取HBASE_MASTER 数量
HBASE_MASTER=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_MASTER | awk -F "=" '{print$2}')
# 获取 HBASE_TMP_DIR 路径
HBASE_TMP_DIR=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_TMP_DIR | awk -F "=" '{print$2}')
# ZOOKEEPER_HOME ENV
ZOOKEEPER_HOME=$(cat $HBASE_PACKAGE_PATH/config | grep ZOOKEEPER_HOME | awk -F "=" '{print$2}')

# 清理zookeeper
ZOOKEEPER_DATA_FOR_HBASE=$(cat $HBASE_PACKAGE_PATH/config | grep ZOOKEEPER_DATA_FOR_HBASE | awk -F "=" '{print$2}')
# 清理 hdfs
HDFS_DATA_FOR_HBASE=$(cat $HBASE_PACKAGE_PATH/config | grep HDFS_DATA_FOR_HBASE | awk -F "=" '{print$2}')

# 关闭 HMaster
# 关闭 HRegionserver
/bin/sh run.sh stop
# 清除 HDFS 数据文件
source $HBASE_PACKAGE_PATH/env/env.sh
echo "Delete hdfs > $HDFS_DATA_FOR_HBASE"
/bin/sh $HADOOP_HOME/bin/hadoop fs -rmr $HDFS_DATA_FOR_HBASE
# 清除 HBASE_TMP 文件夹
source $HBASE_PACKAGE_PATH/env/env.sh

echo "Delete Dir $HBASE_TMP_DIR "
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" rm -rf $HBASE_TMP_DIR
done
# 清除 zookeeper http 数据
echo "清除 Delete zoo  $ZOOKEEPER_DATA_FOR_HBASE 数据"
/bin/sh $ZOOKEEPER_HOME/bin/zkCli.sh deleteall $ZOOKEEPER_DATA_FOR_HBASE

# 清除 Hbase安装目录
source $HBASE_PACKAGE_PATH/env/env.sh
echo " 清除 Hbase 文件夹 $$HBASE_HOME "
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" rm -rf $HBASE_HOME
done

# 清除 安装包
echo " 清除 Hbase Install 文件夹 $HBASE_PACKAGE_PATH "
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" rm -rf $HBASE_PACKAGE_PATH/*
done

echo "Hbase清理工作已经完成请检查！"
