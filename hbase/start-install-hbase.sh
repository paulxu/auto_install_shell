#!/bin/bash


########################配置hbase###################################
HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export HBASE_PACKAGE_PATH=$(cd `dirname $0`; pwd)
source $HBASE_PACKAGE_PATH/env/env.sh

#####################公用区###################

#解压
echo "解压 hbase"
tar -zxvf $HBASE_PACKAGE_PATH/bin/hbase.tar.gz -C $TD_BASE

# 获取HBASE_REGION 数量
HBASE_REGION=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_REGION | awk -F "=" '{print$2}')
# 获取HBASE_MASTER 数量
HBASE_MASTER=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_MASTER | awk -F "=" '{print$2}')
# 获取 HBASE_ZOOKEEPER_DIR 路径
HBASE_ZOOKEEPER_DIR=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_ZOOKEEPER_DIR | awk -F "=" '{print$2}')
# 获取 HBASE_TMP_DIR 路径
HBASE_TMP_DIR=$(cat $HBASE_PACKAGE_PATH/config | grep HBASE_TMP_DIR | awk -F "=" '{print$2}')

    source $HBASE_PACKAGE_PATH/env/env.sh
    HBASE_ZOOKEEPER_DIR_STR=$(echo $HBASE_ZOOKEEPER_DIR | sed 's#\/#\\\/#g')
    HBASE_TMP_DIR_STR=$(echo $HBASE_TMP_DIR | sed 's#\/#\\\/#g')
    HBASE_PACKAGE_PATH_STR=$(echo $HBASE_PACKAGE_PATH | sed 's#\/#\\\/#g')
 	echo -e "\033[31m \n 初始化配置文件 at Hbase\033[0m"
	# 替换run脚本里面的环境变量为真实地址
    sed -i "s/HBASE_PACKAGE_PATH/$HBASE_PACKAGE_PATH_STR/g" `grep HBASE_PACKAGE_PATH -rl $HBASE_PACKAGE_PATH/systemctls/bin/`
    # 修改Hbase存储文件的路径
    sed -i "s/HBASE_TMP_DIR/$HBASE_TMP_DIR_STR/" $HBASE_HOME/conf/hbase-site.xml
    sed -i "s/HBASE_ZOOKEEPER_DIR/$HBASE_ZOOKEEPER_DIR_STR/" $HBASE_HOME/conf/hbase-site.xml
	echo "SCRIPT_INIT_HBASE=true">/var/log/install-hbase-logs/scripts-status.log

#清空配置
echo "清空配置"

echo "" > $HBASE_HOME/conf/regionservers
echo "" > $HBASE_HOME/conf/backup-masters



#######################配置regionservers####################################
source $HBASE_PACKAGE_PATH/env/env.sh

OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
    echo "$s" >>$HBASE_HOME/conf/regionservers
done

#######################masters#############################################
source $HBASE_PACKAGE_PATH/env/env.sh

OLD_IFS="$IFS"
IFS=","
arr=($HBASE_MASTER)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
    echo "$s">>$HBASE_HOME/conf/backup-masters
done

# echo "scp bash_profile"
# OLD_IFS="$IFS"
# IFS=","
# arr=($HBASE_REGION)
# IFS="$OLD_IFS"
# for s in ${arr[@]}
# do
# 	scp ~/.bash_profile "$s":~/.bash_profile
# done

# echo "source bash_profile"
# OLD_IFS="$IFS"
# IFS=","
# arr=($HBASE_REGION)
# IFS="$OLD_IFS"
# for s in ${arr[@]}
# do
# 	ssh "$s" source ~/.bash_profile
# done


source $HBASE_PACKAGE_PATH/env/env.sh
echo "分发 Hbase"
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
	scp -r $HBASE_HOME "$s":$TD_BASE
done

source $HBASE_PACKAGE_PATH/env/env.sh

echo "检查文件目录是否存在 $HBASE_PACKAGE_PATH"
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
	ssh "$s" "[ -d  $HBASE_PACKAGE_PATH  ] && echo mkdir HBASE_PACKAGE_PATH  ok || mkdir -p $HBASE_PACKAGE_PATH"
done


source $HBASE_PACKAGE_PATH/env/env.sh

echo "检查文件目录是否存在 ZNODE_FILE"
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
	ssh "$s" "[ -d  $TD_DATA/pids/http/  ] && echo mkdir $TD_DATA/pids/http/  ok || mkdir -p $TD_DATA/pids/http/"
done


source $HBASE_PACKAGE_PATH/env/env.sh

echo "分发 http install  all script"
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
	 scp -r $HBASE_PACKAGE_PATH "$s":$TD_BASE
done


#######################################开始启动Hbase####################################
source $HBASE_PACKAGE_PATH/env/env.sh

####启动master###########
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_MASTER)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
   ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-master.service.run
done

source $HBASE_PACKAGE_PATH/env/env.sh

####启动多个节点的regionserver
OLD_IFS="$IFS"
IFS=","
arr=($HBASE_REGION)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
   ssh "$s" $HBASE_PACKAGE_PATH/systemctls/bin/hbase-regionserver.service.run
done





