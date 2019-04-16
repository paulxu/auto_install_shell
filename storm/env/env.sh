#!/bin/bash
export JAVA_HOME=/usr/java/default
export JRE_HOME=/usr/java/default
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
PATH=$JAVA_HOME/bin:$PATH
# storm install package 

#export STORM_PACKAGE_PATH=$(pwd)

# storm env
export TD_BASE=/home/temp
export TD_DATA=$TD_BASE/data
export STORM_HOME=$TD_BASE/storm
PATH=$STORM_HOME/bin:$PATH