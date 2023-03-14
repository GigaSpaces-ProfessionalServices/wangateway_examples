#!/usr/bin/env bash

################################################################################
# This script is now using curl with REST Manager to deploy.
# This script assumes the XAP cluster is secured.
# A deployment is done for a pair of Processing Units: space and its gateway.
################################################################################

declare -a ARGS

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"

extract_bootstrap_args "$@"

DC=${ARGS[0]}
CLUSTER=${ARGS[1]}
SPACE=${ARGS[2]}

# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"

echo "GS_MANAGER_SERVERS is: $GS_MANAGER_SERVERS";

source "$BIN_DIR/setEnv.sh"

space_check "$DC" "$CLUSTER" "$SPACE" "$0"

# source the REST deploy functions
source "$BIN_DIR/restFunc.sh"

DEPLOY_BASE_DIR="$BIN_DIR/../deploy"
DEPLOY_BASE_DIR="`( cd \"$DEPLOY_BASE_DIR\" && pwd )`"

echo "DEPLOY_BASE_DIR is: $DEPLOY_BASE_DIR"

# create separate copies of the original pu jar;
# XAP won't let you re-use the jar file, must make a copy
cp $DEPLOY_BASE_DIR/space/$DC/space-1.0-SNAPSHOT.jar     $DEPLOY_BASE_DIR/space/$DC/$SPACE-space-$DC.jar
cp $DEPLOY_BASE_DIR/gateway/$DC/gateway-1.0-SNAPSHOT.jar $DEPLOY_BASE_DIR/gateway/$DC/$SPACE-gateway-$DC.jar


function my_deploy() {
  PU_NAME="$1"
  PU_JAR_PATH="$2"
  PU_JAR_NAME="$3"
  DEPLOYMENT_JSON_FILE="$4"
  REST_HOST="$5"
  MY_PASSWORD_FILE="$6"

  RET_VAL=$(check_for_pu_deployment "$REST_HOST" "$MY_PASSWORD_FILE" "$PU_NAME")

  IS_DEPLOYED="true"
  if [ "The requested processing unit does not exist" = "$RET_VAL" ]; then
    IS_DEPLOYED="false"
  fi


  if [ "false" = "$IS_DEPLOYED" ]; then
    # upload pu jar resource
    RESOURCE_PATH=$(upload_processing_unit "$REST_HOST" "$MY_PASSWORD_FILE" "$PU_JAR_PATH")
    # check if it has been uploaded
    UPLOAD_RET_VAL=$(verify_upload "$REST_HOST" "$MY_PASSWORD_FILE" "$PU_JAR_NAME")
    if [ "false" = "$UPLOAD_RET_VAL" ]; then
      echo "PU jar $PU_JAR_NAME was not successfully uploaded. Skipping deployment."
    else
      echo "About to deploy $PU_NAME..."

      REQUEST_ID=$(deploy_processing_unit "$REST_HOST" "$MY_PASSWORD_FILE" "$DEPLOYMENT_JSON_FILE")

    fi
  else
    echo "Processing Unit $PU_NAME is already deployed."
  fi
}

# begin space deployment
PU_NAME="$SPACE-$DC"
PU_JAR_PATH="$DEPLOY_BASE_DIR/space/$DC/$SPACE-space-$DC.jar"
PU_JAR_NAME="$SPACE-space-$DC.jar"
DEPLOYMENT_JSON_FILE="deployment.json"

# use here doc to write deployment parameters to a file
cat > "$DEPLOYMENT_JSON_FILE" << EOF
{
  "name": "$PU_NAME",
  "resource": "$PU_JAR_NAME",
  "topology": {
    "schema": "partitioned",
    "partitions": 2,
    "backupsPerPartition": 1
  },
  "sla": {
    "zones": [
      "$PU_NAME-zone"
    ]
  },
  "contextProperties": {
    "securityEnabled": "${SECURITY_ENABLED}",
    "localSpaceName": "$SPACE",
    "local-gateway-name": "${local_gateway_name}",
    "remote-gateway-name-a": "${remote_gateway_name_a}",
    "remote-gateway-name-b": "${remote_gateway_name_b}"
  }
}
EOF

my_deploy "$PU_NAME" "$PU_JAR_PATH" "$PU_JAR_NAME" "$DEPLOYMENT_JSON_FILE" "$REST_HOST" "$REST_PASSWORD_FILE"

sleep 3

# begin gateway deployment
PU_NAME="$SPACE-gw-$DC"
PU_JAR_PATH="$DEPLOY_BASE_DIR/gateway/$DC/$SPACE-gateway-$DC.jar"
PU_JAR_NAME="$SPACE-gateway-$DC.jar"
DEPLOYMENT_JSON_FILE="deployment.json"

REQUIRES_BOOTSTRAP="false"
if [ ! -z "$PARAM_REQUIRES_BOOTSTRAP" ] && [ "true" = "$PARAM_REQUIRES_BOOTSTRAP" ]; then
  REQUIRES_BOOTSTRAP="true"
  echo "REQUIRES_BOOTSTRAP is: $REQUIRES_BOOTSTRAP";
fi


# use here doc to write deployment parameters to a file
cat > $DEPLOYMENT_JSON_FILE << EOF
{
  "name": "$PU_NAME",
  "resource": "$PU_JAR_NAME",
  "topology": {
    "instances": 1
  },
  "sla": {
    "zones": [
      "$PU_NAME-zone"
    ]
  },
  "contextProperties": {
    "lookup-port": "$GW_LUS_PORT",
    "communication-port": "$GW_COMMUNICATION_PORT",
    "local-space-name": "$SPACE",
    "local-gateway-name": "${local_gateway_name}",
    "username": "${USERNAME}",
    "password": "${PASSWORD}",
    "requires-bootstrap": "${REQUIRES_BOOTSTRAP}",
    "local-lookup-host-1": "${local_lookup_host_1}",
    "local-lookup-host-2": "${local_lookup_host_2}",
    "local-lookup-host-3": "${local_lookup_host_3}",
    "remote-gateway-name-a": "${remote_gateway_name_a}",
    "remote-lookup-host-a-1": "${remote_lookup_host_a_1}",
    "remote-lookup-host-a-2": "${remote_lookup_host_a_2}",
    "remote-lookup-host-a-3": "${remote_lookup_host_a_3}",
    "remote-gateway-name-b": "${remote_gateway_name_b}",
    "remote-lookup-host-b-1": "${remote_lookup_host_b_1}",
    "remote-lookup-host-b-2": "${remote_lookup_host_b_2}",
    "remote-lookup-host-b-3": "${remote_lookup_host_b_3}"
  }
}
EOF

my_deploy "$PU_NAME" "$PU_JAR_PATH" "$PU_JAR_NAME" "$DEPLOYMENT_JSON_FILE" "$REST_HOST" "$REST_PASSWORD_FILE"


echo "End of $0"
