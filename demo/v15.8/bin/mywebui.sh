#!/usr/bin/env bash

################################################################################
# This starts the webui.
################################################################################

DC=$1
CLUSTER=$2

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"


# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"


echo "GS_MANAGER_SERVERS is: $GS_MANAGER_SERVERS";

source "$BIN_DIR/setEnv.sh"



nohup $GS_HOME/bin/gs-webui.sh > $AGENT_LOG_DIR/webui.log 2>&1 &

echo "End of $0."
