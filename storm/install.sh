#!/bin/bash

#########################确认安装时所在目录为scripts##########################
STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)

source $STORM_PACKAGE_PATH/env/env.sh

#####################公用区###################

#解压
echo "解压 storm"
STORM_PACKAGE_PATH=$(pwd)
source $STORM_PACKAGE_PATH/env/env.sh
tar -zxvf $STORM_PACKAGE_PATH/bin/storm.tar.gz -C $TD_BASE

# install storm
echo -e "\033[31m Install Storm  \033[0m "

# NIMBUS
NIMBUS=$(cat $STORM_PACKAGE_PATH/config | grep NIMBUS | awk -F "=" '{print$2}')
# SUPERVISOR
SUPERVISOR=$(cat $STORM_PACKAGE_PATH/config | grep SUPERVISOR | awk -F "=" '{print$2}')
# STORM_DATA_DIR
STORM_DATA_DIR=$(cat $STORM_PACKAGE_PATH/config | grep STORM_DATA_DIR | awk -F "=" '{print$2}')
# SUPERSLOT
SUPERSLOT=$(cat $STORM_PACKAGE_PATH/config | grep SUPERSLOT | awk -F "=" '{print$2}')
# UI_PORT
UI_PORT=$(cat $STORM_PACKAGE_PATH/config | grep UI_PORT | awk -F "=" '{print$2}')
#ZOOKEEPER_SERVERS
ZOOKEEPER_SERVERS=$(cat $STORM_PACKAGE_PATH/config | grep ZOOKEEPER_SERVERS | awk -F "=" '{print$2}')

# 转译
STORM_DATA_DIR_STR=$(echo $STORM_DATA_DIR | sed 's#\/#\\\/#g')

# 修改文件 修改存储空间地址
sed -i "s/STORM_DATA_DIR/\"$STORM_DATA_DIR_STR\"/" $STORM_HOME/conf/storm-template.yaml

# 批量替换文件
STORM_PACKAGE_PATH_STR=$(echo $STORM_PACKAGE_PATH | sed 's#\/#\\\/#g')
sed -i "s/STORM_PACKAGE_PATH/$STORM_PACKAGE_PATH_STR/g" `grep STORM_PACKAGE_PATH -rl $STORM_PACKAGE_PATH/systemctls/bin/`

# 替换Master
sed -i "s/NIMBUS/\"$NIMBUS\"/" $STORM_HOME/conf/storm-template.yaml
# UI_PORT
sed -i "s/UI_PORT/$UI_PORT/" $STORM_HOME/conf/storm-template.yaml
for i in $( seq 1 $SUPERSLOT)
do
    if (("$i" >= 10));then
       export SUPER_PORT_"$i"="- 67$i"
        elif (("$i" <= 10)) ;then
       export SUPER_PORT_"$i"="- 670$i"
    fi
done

# 替换数据
source $STORM_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arrs_ZOOKEEPER_SERVERS=($ZOOKEEPER_SERVERS)
IFS="$OLD_IFS"
for s2 in "${!arrs_ZOOKEEPER_SERVERS[@]}"; do
       export  ZK_IP_"$s2"="${arrs_ZOOKEEPER_SERVERS[$s2]}"
done

# 环境变量填充
cat  $STORM_HOME/conf/storm-template.yaml |
awk '$0 !~ /^\s*#.*$/' |
sed 's/[ "]/\\&/g' |
while read -r line;do
    eval echo ${line}
done > $STORM_HOME/conf/storm.yaml

#####清理数据
sed -i '-e /""/d' $STORM_HOME/conf/storm.yaml

sed -i '/^[[:space:]]*$/d' $STORM_HOME/conf/storm.yaml

#sed -n '-e /${SUPER_PORT/d' $STORM_HOME/conf/storm.yaml


OLD_IFS="$IFS"
IFS=","
arrs=($SUPERVISOR)
IFS="$OLD_IFS"
for s2 in "${!arrs[@]}"; do
	printf "%s\t%s\n" "$s2" "${arrs[$s2]}"
    echo -e "\033[1m 检查文件目录是否存在 $s1  $STORM_DATA_DIR \033[0m "
    ssh "$s1" "[ -d  $STORM_DATA_DIR  ] && echo mkdir $STORM_DATA_DIR  ok || mkdir -p $STORM_DATA_DIR"
done


################################scp################################
source $STORM_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arrs_SUPERVISOR=($SUPERVISOR)
IFS="$OLD_IFS"
for s3 in ${arrs_SUPERVISOR[@]}
do
    echo  -e  "\033[1m  $s3 scp  storm  \033[0m "
    scp -r $STORM_HOME "$s3":$TD_BASE
done

################################scp################################
source $STORM_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arr_SUPERVISOR=($SUPERVISOR)
IFS="$OLD_IFS"
for s4 in ${arr_SUPERVISOR[@]}
do
    echo -e  "\033[1m  $s4 scp  storm install package  \033[0m "
    scp -r $STORM_PACKAGE_PATH "$s4":$TD_BASE
done


#####################开始启动#######################
source $STORM_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arrs_SUPERVISOR=($SUPERVISOR)
IFS="$OLD_IFS"
for s5 in ${arrs_SUPERVISOR[@]}; do
    echo -e  "\033[1m start storm  $s5 supervisor  \033[0m "
    ssh "$s5" $STORM_PACKAGE_PATH/systemctls/bin/storm-supervisor.service.run
done

source $STORM_PACKAGE_PATH/env/env.sh
OLD_IFS="$IFS"
IFS=","
arrs_NIMBUS=($NIMBUS)
IFS="$OLD_IFS"
for s6 in ${arrs_NIMBUS[@]}; do
    echo -e  "\033[1m start storm  $s6 [nimbus] [ui]  [supervisor]  \033[0m "
    ssh "$s6"  $STORM_PACKAGE_PATH/systemctls/bin/storm-nimbus.service.run
    ssh "$s6"  $STORM_PACKAGE_PATH/systemctls/bin/storm-ui.service.run
    ssh "$s6"  $STORM_PACKAGE_PATH/systemctls/bin/storm-supervisor.service.run
done

rm -rf $STORM_PACKAGE_PATH/install.sh

echo -e "\033[1m rm -rf $STORM_PACKAGE_PATH/install.sh \033[0m"

echo -e "\033[1m Success install storm \033[0m"

