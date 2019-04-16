#!/bin/bash

####### 配置环境变量#######

BASH_PATH=$(cd `dirname $0`; pwd)

# install storm
echo -e "\033[31m Install start  \033[0m "

# 获取Mongo Config
ROUTE_SERVER=$(cat $BASH_PATH/config | grep BASH_NODE | awk -F "=" '{print$2}')

BASH_PATH_STR=$(echo $BASH_PATH | sed 's#\/#\\\/#g')
#替换 sh下的脚本
sed -i "s/BASH_PATH/$BASH_PATH_STR/g" $(grep BASH_PATH -rl $BASH_PATH/bin/)


####开始配置
OLD_IFS="$IFS"
IFS=","
arrs=($ROUTE_SERVER)
IFS="$OLD_IFS"
for s1 in "${!arrs[@]}"; do
	echo -e "\033[1m 检查文件目录是否存在 ${arrs[$s1]} $BASH_PATH \033[0m "
	ssh "${arrs[$s1]}" "[ -d  $BASH_PATH  ] && echo mkdir $BASH_PATH   ok || mkdir -p $BASH_PATH"
done


source $BASH_PATH/env.sh

OLD_IFS="$IFS"
IFS=","
arr=($ROUTE_SERVER)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
	 echo -e  "\033[1m 分发 bash_ Install  all script at $s \033[0m"
	 scp -r $BASH_PATH "$s":$TD_BASE
done


source $BASH_PATH/env.sh
OLD_IFS="$IFS"
IFS=","
arrs=($ROUTE_SERVER)
IFS="$OLD_IFS"
for s1 in "${!arrs[@]}"; do
	echo -e "\033[1m 开始配置  ${arrs[$s1]}  \033[0m "
	ssh "${arrs[$s1]}" "$BASH_PATH/bin/deploy.sh"
done

