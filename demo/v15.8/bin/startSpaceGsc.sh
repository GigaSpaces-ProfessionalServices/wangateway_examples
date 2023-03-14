#!/usr/bin/env bash

################################################################################
# This script starts the GSCs that are dedicated to a specific space PU by using
# zones.
################################################################################

DC=$1
CLUSTER=$2
SPACE=$3

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

space_check "$DC" "$CLUSTER" "$SPACE" "$0"


export GS_GSC_OPTIONS="$GS_GSC_OPTIONS -Xms$HEAP_SIZE -Xmx$HEAP_SIZE -Dcom.gs.zones=$SPACE-$DC-zone"

echo "Starting GSCs for space: $SPACE";
nohup $GS_HOME/bin/gs.sh host run-agent --gsc=2 > $AGENT_LOG_DIR/agent-$SPACE.log 2>&1 &

echo "End of $0."
