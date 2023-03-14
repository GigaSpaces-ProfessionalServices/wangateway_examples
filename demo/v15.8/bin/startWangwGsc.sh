#!/usr/bin/env bash

################################################################################
# This script starts the GSCs that are dedicated to a specific WAN Gateway PU by
# using zones.
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

echo "GS_MANAGER_SERVERS is: $GS_MANAGER_SERVERS";


echo "Starting WAN GW GSC...";
export GS_GSC_OPTIONS="$GS_GSC_OPTIONS -Xms1g -Xmx1g -Dcom.gs.zones=$SPACE-gw-$DC-zone \
  -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=$GW_LUS_PORT \
  -Dcom.gs.transport_protocol.lrmi.bind-port=$GW_COMMUNICATION_PORT"

nohup $GS_HOME/bin/gs.sh host run-agent --gsc=1 > $AGENT_LOG_DIR/$SPACE-wangw-console.log 2>&1 &

echo "End of $0."
