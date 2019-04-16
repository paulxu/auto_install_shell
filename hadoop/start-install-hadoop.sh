#!/bin/bash

#########################确认安装时所在目录为scripts##########################
HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HADOOP_PACKAGE_PATH=$(cd `dirname $0`; pwd)

source $HADOOP_PACKAGE_PATH/env/env.sh

# 获取NAMENODE 路径
NAME_NODE_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep NAME_NODE_PATH | awk -F "=" '{print$2}')
# 获取DATANODE 路径
DATA_NODE_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep DATA_NODE_PATH | awk -F "=" '{print$2}')
# 获取 JOURNAL NODE 路径
JOURNAL_DATA_PATH=$(cat $HADOOP_PACKAGE_PATH/config | grep JOURNAL_DATA_PATH | awk -F "=" '{print$2}')
# 获取DATANODE dscn1,dscn2....
HADOOP_DATA_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_DATA_NODE | awk -F "=" '{print$2}')
# 获取NAMENODE dscn1,dscn2....
HADOOP_NAME_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_NAME_NODE | awk -F "=" '{print$2}')
# HADOOP formatZK
HADOOP_FORMATZK=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_FORMATZK | awk -F "=" '{print$2}')
# HADOOP_ACTIVE_NODE
HADOOP_ACTIVE_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_ACTIVE_NODE | awk -F "=" '{print$2}')
# HADOOP_STANDY_NODE
HADOOP_STANDY_NODE=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_STANDY_NODE | awk -F "=" '{print$2}')
# HADOOP_TMP 临时文件存储
HADOOP_TMP=$(cat $HADOOP_PACKAGE_PATH/config | grep HADOOP_TMP | awk -F "=" '{print$2}')
# yarn history 启动在那个节点
YARN_HISTORYSERVER=$(cat $HADOOP_PACKAGE_PATH/config | grep YARN_HISTORYSERVER | awk -F "=" '{print$2}')

echo "SED 转译"

HADOOP_PACKAGE_PATH_STR=$(echo $HADOOP_PACKAGE_PATH | sed 's#\/#\\\/#g')

JOURNAL_DATA_PATH_STR=$(echo $JOURNAL_DATA_PATH | sed 's#\/#\\\/#g')

HADOOP_TMP_STR=$(echo $HADOOP_TMP | sed 's#\/#\\\/#g')

DATA_NODE_PATH_STR=$(echo $DATA_NODE_PATH | sed 's#\/#\\\/#g')

NAME_NODE_PATH_STR=$(echo $NAME_NODE_PATH | sed 's#\/#\\\/#g')

echo "解压hadoop"

tar -zxvf $HADOOP_PACKAGE_PATH/bin/hadoop.tar.gz -C $TD_BASE

####################### sed setting config xml##################################
echo "开始修改文件......"
# 批量修改run stop 脚本
sed -i "s/HADOOP_PACKAGE_PATH/$HADOOP_PACKAGE_PATH_STR/g" $(grep HADOOP_PACKAGE_PATH -rl $HADOOP_PACKAGE_PATH/systemctls/bin/)
# 修改hdfs-Name配置
sed -i "s/NAME_NODE_PATH/$NAME_NODE_PATH_STR/" $HADOOP_HOME/etc/hadoop/hdfs-site.xml
# 修改hdfs-Data配置
sed -i "s/DATA_NODE_PATH/$DATA_NODE_PATH_STR/" $HADOOP_HOME/etc/hadoop/hdfs-site.xml

sed -i "s/JOURNAL_DATA_PATH/$JOURNAL_DATA_PATH_STR/" $HADOOP_HOME/etc/hadoop/core-site.xml

sed -i "s/HADOOP_TMP/$HADOOP_TMP_STR/" $HADOOP_HOME/etc/hadoop/core-site.xml
#清空配置
source $HADOOP_PACKAGE_PATH/env/env.sh
echo "清空配置  $HADOOP_HOME/etc/hadoop/masters "
echo "" >$HADOOP_HOME/etc/hadoop/masters
echo "清空配置  $HADOOP_HOME/etc/hadoop/slaves "
echo "" >$HADOOP_HOME/etc/hadoop/slaves
echo "文件修改完成......"

echo "配置  $HADOOP_HOME/etc/hadoop/slaves "
source $HADOOP_PACKAGE_PATH/env/env.sh

OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "$s" >>$HADOOP_HOME/etc/hadoop/slaves
done

echo "配置  $HADOOP_HOME/etc/hadoop/masters "
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_NAME_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "$s" >>$HADOOP_HOME/etc/hadoop/masters
done

echo "Check Data Dir $HADOOP_HOME "
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" "[ -d $HADOOP_HOME ] && echo mkdir ok || mkdir -p $HADOOP_HOME"
done

echo "SCP Hadoop $HADOOP_HOME"
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	scp -r $HADOOP_HOME "$s":$TD_BASE
done

echo "分发 hosts"
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	scp /etc/hosts "$s":/etc/hosts
done

echo "Check Dir $HADOOP_PACKAGE_PATH"
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" "[ -d  $HADOOP_PACKAGE_PATH  ] && echo mkdir ok || mkdir -p $HADOOP_PACKAGE_PATH"
done

echo "分发 hadoop install  $HADOOP_PACKAGE_PATH"

OLD_IFS="$IFS"
source $HADOOP_PACKAGE_PATH/env/env.sh
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	scp -r $HADOOP_PACKAGE_PATH "$s":$TD_BASE
done

#######################其中一个namenode上初始化zkfc################################
source $HADOOP_PACKAGE_PATH/env/env.sh
echo "starting fotmatZK "
/usr/bin/expect <<EOF
spawn ssh $HADOOP_FORMATZK
expect "*# "
send -- "$HADOOP_HOME/bin/hdfs zkfc -formatZK\r"
	expect "*(Y or N)" {
	send -- "y\r"
	} "*# "
	send -- "exit\r"
EOF

echo "start journalnode "

########################启动journalnode##########################################
source $HADOOP_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-journalnode.service.run
done

echo "格式化NameNODE"

########################格式化NameNODE###########################################

ssh $HADOOP_ACTIVE_NODE $HADOOP_HOME/bin/hdfs namenode -format

########################启动NameNODE#############################################
echo "启动NameNODE"

ssh $HADOOP_ACTIVE_NODE $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-namenode.service.run

###############starting Standby ################################################

echo "starting Standby "
#ssh $HADOOP_STANDY_NODE sh $HADOOP_PACKAGE_PATH/env/hadoop-format-standby.sh
/usr/bin/expect <<EOF
spawn ssh $HADOOP_STANDY_NODE
expect "*# "
send -- "$HADOOP_HOME/bin/hdfs namenode -bootstrapStandby\r"
	expect "*(Y or N)" {
	send -- "y\r"
	} "*# "
	send -- "exit\r"
EOF
###################Standby 后需要重启Standby的NameNode############################

sleep 5s
ssh $HADOOP_STANDY_NODE $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-namenode.service.run
sleep 5s
ssh $HADOOP_STANDY_NODE $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-namenode.service.run

########################启动DataNODE#############################################

echo "启动DataNODE"

OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "启动DataNODE $s"
	ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-datanode.service.run
done

#########################启动Z KFC###############################################

OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_NAME_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "启动NameNode上的Zkfc $s"
	ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/hadoop-zkfc.service.run
done

echo "启动yarn-resourcemanager"

#########################启动yarn-resourcemanager ###############################

OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_NAME_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "启动NameNode上的Yarn-resourcemanager  $s"
	ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-resourcemanager.service.run
done

#########################启动yarn-nodemanager ###################################
OLD_IFS="$IFS"
IFS=","
arr=($HADOOP_DATA_NODE)
IFS="$OLD_IFS"
for s in ${arr[@]}; do
	echo "启动yarn-nodemanager $s"
	ssh "$s" $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-nodemanager.service.run
done

#########################启动yarn-historyserver #################################

echo "启动yarn-historyserver $YARN_HISTORYSERVER"
ssh $YARN_HISTORYSERVER $HADOOP_PACKAGE_PATH/systemctls/bin/yarn-historyserver.service.run
#### 关闭服务
#/bin/sh $HADOOP_PACKAGE_PATH/run.sh autostop
