#!/usr/bin/env bash

################################################################################
# This script uses curl with REST Manager to undeploy.
# This script assumes the XAP cluster is secured.
# An undeployment is done for a pair of Processing Units: space and its gateway.
################################################################################

DC="$1"
CLUSTER="$2"
SPACE="$3"

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

# source the REST deploy functions
source "$BIN_DIR/restFunc.sh"



# undeploy space processing unit
PU_NAME="$SPACE-$DC"

REQUEST_ID=$(undeploy_processing_unit "$REST_HOST" "$REST_PASSWORD_FILE" "$PU_NAME")

sleep 3

# undeploy gateway processing unit
PU_NAME="$SPACE-gw-$DC"

REQUEST_ID=$(undeploy_processing_unit "$REST_HOST" "$REST_PASSWORD_FILE" "$PU_NAME")

echo "End of $0"
