#!/usr/bin/env bash

################################################################################
# This script starts the manager. The manager is responsible for the lookup
# service, grid service manager, REST manager, Ops-ui, and Zookeeper.
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

# if configured with actual hostnames and not ip addresses, replace $(hostname -i) with $(hostname) below
HOST_NAME="$(hostname -i)"

if [[ $GS_MANAGER_SERVERS == *"$HOST_NAME"* ]]; then

  echo "Starting a Manager server...";

  nohup $GS_HOME/bin/gs.sh host run-agent --manager > $AGENT_LOG_DIR/agent-manager.log 2>&1 &
else
  echo "This server $HOSTNAME is not configured to run a manager";
  exit -1;
fi

echo "End of $0"
