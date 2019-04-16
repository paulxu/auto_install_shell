#!/bin/bash

########################配置hbase###################################
#HADOOP_PACKAGE_PATH=$(pwd)
HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)

source $HADOOP_PACKAGE_PATH/env/env.sh
#######################创建安装日志、备份目录##########################
[ -d /var/log/install-hadoop-logs ] || mkdir /var/log/install-hadoop-logs
[ -d /opt/install-hadoop-backup ] || mkdir /opt/install-hadoop-backup
#######################判断脚本执行状态，防止重复执行脚本#############
touch /var/log/install-hadoop-logs/scripts-status.log
sh_status_all=$(cat /var/log/install-hadoop-logs/scripts-status.log | grep SCRIPT_INIT | awk -F "=" '{print$2}')
if [ "$sh_status_all" == "true" ];then
    echo -e "\033[31m \n 已经成功初始化配置文件，继续执行\033[0m"

elif [ ! -n "$sh_status_all"]; then
 	echo -e "\033[31m \n 初始化配置文件\033[0m"
	# 批量修改run stop 脚本
	HADOOP_PACKAGE_PATH_STR=$(echo $HADOOP_PACKAGE_PATH | sed 's#\/#\\\/#g')
	sed -i "s/HADOOP_PACKAGE_PATH/$HADOOP_PACKAGE_PATH_STR/g" `grep HADOOP_PACKAGE_PATH -rl $HADOOP_PACKAGE_PATH/systemctls/bin/`
	echo "SCRIPT_INIT=true">/var/log/install-hadoop-logs/scripts-status.log
	#echo "init script date : `date`">>/var/log/install-hadoop-logs/scripts-status.log
	exit 1
fi
# 获取DATANODE dscn1,dscn2....
HADOOP_DATA_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_DATA_NODE | awk -F "=" '{print$2}')
# 获取NAMENODE dscn1,dscn2....
HADOOP_NAME_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_NAME_NODE | awk -F "=" '{print$2}')
# history server 
YARN_HISTORYSERVER=$(cat $HADOOP_PACKAGE_PATH/config | grep YARN_HISTORYSERVER | awk -F "=" '{print$2}')

#--------------------------------------------------------------------------------------
function start_journalnode() {
	########################启动journalnode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "starting journalnode at $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-journalnode.service.run
	done
}

function start_namenode() {
	########################启动namenode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "starting namenode at $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-namenode.service.run
	done
}

function start_datanode() {
	########################启动datanode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "starting datanode at  $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-datanode.service.run
	done
}

function start_zkfc() {
	########################启动_zkfc##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "启动NameNode上的Zkfc $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-zkfc.service.run
	done
}

function start_yarn_nameserver() {
	########################启动__yarn_nameserver##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "启动NameNode上的Yarn-resourcemanager  $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-resourcemanager.service.run
	done
}


function start_yarn_dataserver(){
	########################启动__yarn_dataserver##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "启动yarn-nodemanager $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-nodemanager.service.run
	done
}

function start_history_server(){
	#########################启动yarn-historyserver #################################
	echo "starting yarn-historyserver as $YARN_HISTORYSERVER"
	ssh $YARN_HISTORYSERVER $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-historyserver.service.run
}

########自动有序列的启动Hadoop
function autostart(){

	echo "auto start script date : `date`">>/var/log/install-hadoop-logs/scripts-status.log
	start_journalnode
	start_zkfc
	start_namenode
	start_datanode
	start_yarn_nameserver
	start_yarn_dataserver
	start_history_server
}
#---------------------------------------------------------------------------------------------
function stop_journalnode() {
	########################stop journalnode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping journalnode at $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-journalnode.service.stop
	done
}

function stop_namenode() {
	########################stop namenode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping namenode at $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-namenode.service.stop
	done
}

function stop_datanode() {
	########################stop datanode##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping datanode at  $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-datanode.service.stop
	done
}

function stop_zkfc() {
	########################stop _zkfc##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping NameNode上的Zkfc $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-zkfc.service.stop
	done
}

function stop_yarn_nameserver() {
	########################stop __yarn_nameserver##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_NAME_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping NameNode上的Yarn-resourcemanager  $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-resourcemanager.service.stop
	done
}


function stop_yarn_dataserver(){
	########################stop __yarn_dataserver##########################################
	source $HADOOP_PACKAGE_PATH/env/env.sh
	OLD_IFS="$IFS"
	IFS=","
	arr=($HADOOP_DATA_NODE)
	IFS="$OLD_IFS"
	for s in ${arr[@]}; do
		echo "stoping yarn-nodemanager $s"
		ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-nodemanager.service.stop
	done
}

function stop_history_server(){
	#########################启动yarn-historyserver #################################
	echo "stoping yarn-historyserver as $YARN_HISTORYSERVER"
	ssh $YARN_HISTORYSERVER $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-historyserver.service.stop
}

########自动有序列的关闭Hadoop
function autostop(){
	echo "auto stop script date : `date`">>/var/log/install-hadoop-logs/scripts-status.log
	stop_history_server
	stop_yarn_dataserver
	stop_yarn_nameserver
	stop_datanode
	stop_namenode
	stop_zkfc
	stop_journalnode
}

case $1 in

"start_journalnode")
	start_journalnode
	;;
"start_namenode")
	start_namenode
	;;
"start_datanode")
	start_datanode
	;;
"start_zkfc")
	start_zkfc
	;;
"start_history_server")
	start_history_server
	;;
"start_yarn_dataserver")
	start_yarn_dataserver
	;;
"start_yarn_nameserver")
	start_yarn_nameserver
	;;
 "autostart")
	autostart
	;;
"stop_journalnode")
	stop_journalnode
	;;
"stop_namenode")
	stop_namenode
	;;
"stop_datanode")
	stop_datanode
	;;
"stop_zkfc")
	stop_zkfc
	;;
"stop_history_server")
	stop_history_server
	;;
"stop_yarn_dataserver")
	stop_yarn_dataserver
	;;
"stop_yarn_nameserver")
	stop_yarn_nameserver
	;;
"autostop")
	autostop
	;;
*)
	echo -e "\033[1m usage: \n \t  [start | stop]  \n \t  [++++++++++] \n \t  [_history_server] \n \t  [_yarn_dataserver] \n \t  [_yarn_nameserver] \n \t  [_zkfc] \n \t  [_namenode] \n \t  [_datanode] \n \t  [_journalnode] \033[0m"
	echo -e "\033[1m usage-esay: \n \t  [autostop] \n \t  [autostart] \033[0m" 
	exit 2 # Command to come out of the program with status 1
	;;
esac
exit 0
