#!/usr/bin/env bash

#set -x
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"


GS_HOME="/home/ubuntu/gigaspaces-insightedge-enterprise-15.8.1"

PROJ_DIR="/home/ubuntu/demo/v15.8/project"

ADMIN_LIB_DIR="$GS_HOME/lib/platform/service-grid/*"

ZK_LIB_DIR="$GS_HOME/lib/platform/zookeeper/*"

WANGW_LIB_DIR="$GS_HOME/lib/optional/wan-gateway/*"

CLASSES_DIR="$PROJ_DIR/admin/target/classes"
if [ ! -d "$CLASSES_DIR" ]; then
  echo "The class directory \"$CLASSES_DIR\" does not exist.";
  exit -1
fi

CLASSPATH="$GS_HOME/lib/required/*:$ADMIN_LIB_DIR:$ZK_LIB_DIR:$WANGW_LIB_DIR"

CLASSPATH="$CLASSPATH:$CLASSES_DIR"


$JAVA_HOME/bin/java -Xms1g -Xmx1g -classpath "$CLASSPATH" com.example.gsadmin.wangateway.ModifyTarget --help

