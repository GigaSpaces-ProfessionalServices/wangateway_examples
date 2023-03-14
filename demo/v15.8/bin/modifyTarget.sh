#!/usr/bin/env bash

################################################################################
# This script is used to call the Java Admin API to add or remove an outbound
# gateway target.
################################################################################

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"


source "$BIN_DIR/setEnv.sh"

ADMIN_LIB_DIR="$GS_HOME/lib/platform/service-grid/*"

ZK_LIB_DIR="$GS_HOME/lib/platform/zookeeper/*"

WANGW_LIB_DIR="$GS_HOME/lib/optional/wan-gateway/*"

PROJ_DIR="$BIN_DIR/../project"
PROJ_DIR="`( cd \"$PROJ_DIR\" && pwd )`"


CLASSES_DIR="$PROJ_DIR/admin/target/classes"
if [ ! -d "$CLASSES_DIR" ]; then
  echo "The class directory \"$CLASSES_DIR\" does not exist.";
  exit -1
fi


CLASSPATH="$GS_HOME/lib/required/*:$ADMIN_LIB_DIR:$ZK_LIB_DIR:$WANGW_LIB_DIR"

CLASSPATH="$CLASSPATH:$CLASSES_DIR"

OUTFILE="$AGENT_LOG_DIR/modifytarget-$$.log"
echo "The output file is located at: $OUTFILE"

CREDENTIALS=" "
if [ "true" = "$SECURITY_ENABLED" ]; then
  CREDENTIALS="--username=$USERNAME --passwordFilename=$PASSWORD_FILE ";
fi

nohup $JAVA_HOME/bin/java -Xms1g -Xmx1g -classpath "$CLASSPATH" com.example.gsadmin.wangateway.ModifyTarget $CREDENTIALS "$@" > $OUTFILE 2>&1 &

