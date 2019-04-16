#!/bin/bash

########################配置hbase###################################
HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
source $HBASE_PACKAGE_PATH/env/env.sh

# 获取HBASE_REGION 数量
HBASE_REGION=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_REGION | awk -F "=" '{print$2}')
# 获取HBASE_MASTER 数量
HBASE_MASTER=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_MASTER | awk -F "=" '{print$2}')

function stop() {
	source $HBASE_PACKAGE_PATH/env/env.sh

	####启动master###########
	OLD_IFS="$IFS"
	IFS=","
	arr=($HBASE_MASTER)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-master.service.stop
	done

	source $HBASE_PACKAGE_PATH/env/env.sh

	####启动多个节点的regionserver
	OLD_IFS="$IFS"
	IFS=","
	arr=($HBASE_REGION)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-regionserver.service.stop
	done
}

function start() {
	source $HBASE_PACKAGE_PATH/env/env.sh

	####启动master###########
	OLD_IFS="$IFS"
	IFS=","
	arr=($HBASE_MASTER)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-master.service.run
	done

	source $HBASE_PACKAGE_PATH/env/env.sh

	####启动多个节点的regionserver
	OLD_IFS="$IFS"
	IFS=","
	arr=($HBASE_REGION)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-regionserver.service.run
	done
}

case $1 in

"start")
	start
	;;
"stop")
	stop
	;;
*)
	echo -e "\033[1m usage: \n \t  [stop]  \n \t  [start] \033[0m"
	exit 1 # Command to come out of the program with status 1
	;;
esac
exit 0
