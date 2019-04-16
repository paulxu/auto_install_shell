#!/bin/bash

source HADOOP_PACKAGE_PATH/env/env.sh

source ~/.bash_profile

$HADOOP_HOME/bin/hdfs namenode -bootstrapStandby