#!/bin/bash

#########################确认安装时所在目录为scripts##########################
STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)
export STORM_PACKAGE_PATH=$(cd `dirname $0`; pwd)
source $STORM_PACKAGE_PATH/env/env.sh

#####################公用区###################
#SUPERVISOR
SUPERVISOR=$(cat $STORM_PACKAGE_PATH/config | grep SUPERVISOR | awk -F "=" '{print$2}')
# NIMBUS
NIMBUS=$(cat $STORM_PACKAGE_PATH/config | grep NIMBUS | awk -F "=" '{print$2}')

function autostart(){
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
}


function autostop(){
OLD_IFS="$IFS"
IFS=","
arrs=($SUPERVISOR)
IFS="$OLD_IFS"
for s2 in "${!arrs[@]}"; do
    echo -e "\033[1m stop storm all \033[0m "
    ssh "${arrs[$s2]}" "$STORM_PACKAGE_PATH/systemctls/bin/storm-all.service.stop"
done
}


case $1 in
"autostart")
	autostart
	;;
"autostop")
	autostop
	;;
*)
	echo -e "\033[1m usage-esay: \n \t  [autostop] \n \t  [autostart] \033[0m" 
	exit 2 # Command to come out of the program with status 1
	;;
esac
exit 0