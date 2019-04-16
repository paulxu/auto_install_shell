#!/bin/bash

#########################确认安装时所在目录为scripts##########################
STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)

source $STORM_PACKAGE_PATH/env/env.sh

#####################公用区###################

# uninstall storm
echo -e "\033[31m uninstall Storm  \033[0m "

# STORM_DATA_DIR
STORM_DATA_DIR=$(cat $STORM_PACKAGE_PATH/config | grep STORM_DATA_DIR | awk -F "=" '{print$2}')
SUPERVISOR=$(cat $STORM_PACKAGE_PATH/config | grep SUPERVISOR | awk -F "=" '{print$2}')

####停止storm

/bin/sh $STORM_PACKAGE_PATH/run.sh autostop


# 清理 zookeeper
ZOOKEEPER_HOME=$(cat $STORM_PACKAGE_PATH/config | grep ZOOKEEPER_HOME | awk -F "=" '{print$2}')
ZOOKEEPER_DATA_FOR_STORM=$(cat $STORM_PACKAGE_PATH/config | grep ZOOKEEPER_DATA_FOR_STORM | awk -F "=" '{print$2}')


echo -e "\033[31m  delete  zookeeper data to   $ZOOKEEPER_DATA_FOR_STORM  \033[0m"

/bin/sh $ZOOKEEPER_HOME/bin/zkCli.sh deleteall $ZOOKEEPER_DATA_FOR_STORM

echo -e "\033[1m  delete all $STORM_DATA_DIR \033[0m"

# 缺少一个判断（可以考虑在run 里面配置判断情况）

OLD_IFS="$IFS"
IFS=","
arrs=($SUPERVISOR)
IFS="$OLD_IFS"
for s2 in "${!arrs[@]}"; do
    echo -e "\033[1m ${arrs[$s2]} rm -rf  $STORM_DATA_DIR  \033[0m "
    ssh "${arrs[$s2]}" "rm -rf  $STORM_DATA_DIR"
done

echo -e "\033[1m Success uninstall storm \033[0m"

