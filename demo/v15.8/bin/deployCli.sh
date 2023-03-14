#!/usr/bin/env bash

################################################################################
# This script contains deploy functionality using gs.sh cli.
# This script can handle non-secured XAP clusters.
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

DEPLOY_BASE_DIR="$BIN_DIR/../deploy"
DEPLOY_BASE_DIR="`( cd \"$DEPLOY_BASE_DIR\" && pwd )`"

echo "DEPLOY_BASE_DIR is: $DEPLOY_BASE_DIR"

#$GS_HOME/bin/gs.sh space deploy --partitions=2 --ha=true mySpace 

# create separate copies of the original pu jar
cp $DEPLOY_BASE_DIR/space/$DC/space-1.0-SNAPSHOT.jar     $DEPLOY_BASE_DIR/space/$DC/$SPACE-space-$DC.jar
cp $DEPLOY_BASE_DIR/gateway/$DC/gateway-1.0-SNAPSHOT.jar $DEPLOY_BASE_DIR/gateway/$DC/$SPACE-gateway-$DC.jar

GS_CMD="$GS_HOME/bin/gs.sh "

if [ "true" = "$SECURITY_ENABLED" ]; then
  GS_CMD="$GS_HOME/bin/gs.sh --username=$USERNAME --password=$PASSWORD ";
fi 

PU_NAME="$SPACE-$DC"
GREP_VAL=$($GS_CMD pu list | grep "\b$PU_NAME\b")

if [ -z "$GREP_VAL" ]; then
  $GS_CMD pu deploy \
    --partitions=2 --ha=true --zones=$PU_NAME-zone \
    -p securityEnabled=$SECURITY_ENABLED \
    -p localSpaceName=$SPACE \
    -p local-gateway-name="${local_gateway_name}" \
    -p remote-gateway-name-a="${remote_gateway_name_a}" \
    -p remote-gateway-name-b="${remote_gateway_name_b}" \
    $PU_NAME  $DEPLOY_BASE_DIR/space/$DC/$SPACE-space-$DC.jar 
  
else
  echo "Space $SPACE-$DC is already deployed."
fi

sleep 3

PU_NAME="$SPACE-gw-$DC"
GREP_VAL=$($GS_CMD pu list | grep "\b$PU_NAME\b")

REQUIRES_BOOTSTRAP="false"
if [ ! -z "$PARAM_REQUIRES_BOOTSTRAP" ] && [ "true" = "$PARAM_REQUIRES_BOOTSTRAP" ]; then
  REQUIRES_BOOTSTRAP="true"
  echo "REQUIRES_BOOTSTRAP is: $REQUIRES_BOOTSTRAP";
fi

if [ -z "$GREP_VAL" ]; then
#set -x
#env

  $GS_CMD pu deploy \
    --zones=$PU_NAME-zone \
    -p lookup-port="$GW_LUS_PORT" \
    -p communication-port="$GW_COMMUNICATION_PORT" \
    -p local-space-name="$SPACE" \
    -p local-gateway-name="${local_gateway_name}" \
    -p username="${USERNAME}" \
    -p password="${PASSWORD}" \
    -p requires-bootstrap="${REQUIRES_BOOTSTRAP}" \
    -p local-lookup-host-1="${local_lookup_host_1}" \
    -p local-lookup-host-2="${local_lookup_host_2}" \
    -p local-lookup-host-3="${local_lookup_host_3}" \
    -p remote-gateway-name-a="${remote_gateway_name_a}" \
    -p remote-lookup-host-a-1="${remote_lookup_host_a_1}" \
    -p remote-lookup-host-a-2="${remote_lookup_host_a_2}" \
    -p remote-lookup-host-a-3="${remote_lookup_host_a_3}" \
    -p remote-gateway-name-b="${remote_gateway_name_b}" \
    -p remote-lookup-host-b-1="${remote_lookup_host_b_1}" \
    -p remote-lookup-host-b-2="${remote_lookup_host_b_2}" \
    -p remote-lookup-host-b-3="${remote_lookup_host_b_3}" \
    $PU_NAME  $DEPLOY_BASE_DIR/gateway/$DC/$SPACE-gateway-$DC.jar  

else
  echo "Gateway $PU_NAME is already deployed."
fi

echo "End of $0"
