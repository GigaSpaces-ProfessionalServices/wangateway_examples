#!/usr/bin/env bash

#set -x
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"


GS_HOME="/home/ubuntu/gigaspaces-insightedge-enterprise-15.8.1"

PROJ_DIR="/home/ubuntu/demo/v15.8/project"

ADMIN_LIB_DIR="$GS_HOME/lib/platform/service-grid/*"

ZK_LIB_DIR="$GS_HOME/lib/platform/zookeeper/*"

export CLASSES_DIR="$PROJ_DIR/admin/target/classes"

CLASSPATH="$GS_HOME/lib/required/*:$ADMIN_LIB_DIR:$ZK_LIB_DIR"

CLASSPATH="$CLASSPATH:$CLASSES_DIR"

THIS_DIR="`dirname \"$0\"`"
THIS_DIR="`( cd \"$BIN_DIR\" && pwd )`"

# output stderr to err.txt to remove ZK log messages
$JAVA_HOME/bin/java -Xms1g -Xmx1g -classpath "$CLASSPATH" com.example.gsadmin.wangateway.WanGatewayInfo \
  -username giga_user -password giga_user \
  -locators 172.31.14.28:4174,172.31.10.72:4174,172.31.13.223:4174 \
  -spaceName Product  \
  -username giga_user \
  -passwordFilename $THIS_DIR/password_file 2> err.log
