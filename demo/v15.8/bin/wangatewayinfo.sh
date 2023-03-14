#!/usr/bin/env bash

################################################################################
# The script will gather statistics about WAN Gateway across data centers.
################################################################################

DC="$1"
CLUSTER="$2"

echo "Running $0..."


BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"


# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"


source "$BIN_DIR/setEnv.sh"

PROJ_DIR="$BIN_DIR/../project"
PROJ_DIR="`( cd \"$PROJ_DIR\" && pwd )`"

ADMIN_LIB_DIR="$GS_HOME/lib/platform/service-grid/*"

ZK_LIB_DIR="$GS_HOME/lib/platform/zookeeper/*"

export CLASSES_DIR="$PROJ_DIR/admin/target/classes"
if [ ! -d "$CLASSES_DIR" ]; then
  echo "The class directory \"$CLASSES_DIR\" does not exist.";
  exit -1
fi

CLASSPATH="$GS_HOME/lib/required/*:$ADMIN_LIB_DIR:$ZK_LIB_DIR"

CLASSPATH="$CLASSPATH:$CLASSES_DIR"

STDERRFILE="$AGENT_LOG_DIR/$0-err.log"

CREDENTIALS=" "
if [ "true" = "$SECURITY_ENABLED" ]; then
  CREDENTIALS="-username $USERNAME -passwordFilename $PASSWORD_FILE ";
fi

# output stderr to err.log to remove ZK log messages
$JAVA_HOME/bin/java -Xms1g -Xmx1g -classpath "$CLASSPATH" com.example.gsadmin.wangateway.WanGatewayInfo \
  -locators $MULTI_DC_LOCATORS \
  $CREDENTIALS \
  -spaceName Product 2> $STDERRFILE
