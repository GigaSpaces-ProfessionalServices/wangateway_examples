#!/usr/bin/env bash

################################################################################
# This script allows the user to review the parameters used by the bootstrap
# before calling it.
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

source "$BIN_DIR/setEnv.sh"

space_check "$DC" "$CLUSTER" "$SPACE" "$0"

#--locator=host:4174 --sourceGateway=Product-gw-tx --localGateway=Product-gw-az --timeout=3601 --requiresBootstrap=true

LOCATOR="";
if [ ! -z "$BOOTSTRAP_LOCATOR" ]; then
  LOCATOR="$BOOTSTRAP_LOCATOR";
fi
if [ ! -z "$PARAM_LOCATOR" ]; then
  LOCATOR="$PARAM_LOCATOR";
fi

echo ""
echo "The locator is: $LOCATOR. Enter a new locator or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    LOCATOR="$INPUT_VAR";
fi

SOURCE_GATEWAY="";
if [ ! -z "${remote_gateway_name_a}" ]; then
  SOURCE_GATEWAY="${remote_gateway_name_a}";
fi
if [ ! -z "$PARAM_SOURCE_GATEWAY" ]; then
  SOURCE_GATEWAY="$PARAM_SOURCE_GATEWAY";
fi

echo "The source gateway is where we will read the information from.";
echo "Source gateway (1) is: ${remote_gateway_name_a}";
echo "Source gateway (2) is: ${remote_gateway_name_b}";
echo "The selected source gateway is: $SOURCE_GATEWAY.";
echo "Enter a new source gateway or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    SOURCE_GATEWAY="$INPUT_VAR";
fi

LOCAL_GATEWAY="";
if [ ! -z "${local_gateway_name}" ]; then
  LOCAL_GATEWAY="${local_gateway_name}";
fi
if [ ! -z "$PARAM_LOCAL_GATEWAY" ]; then
  LOCAL_GATEWAY="$PARAM_LOCAL_GATEWAY";
fi

echo "The local gateway is where we will receive the information.";
echo "The local gateway is: $LOCAL_GATEWAY.";
echo "Enter a new local gateway or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    LOCAL_GATEWAY="$INPUT_VAR";
fi

TIMEOUT="3600";
if [ ! -z "${BOOTSTRAP_TIMEOUT}" ]; then
  TIMEOUT="${BOOTSTRAP_TIMEOUT}";
fi
if [ ! -z "$PARAM_TIMEOUT" ]; then
  TIMEOUT="$PARAM_TIMEOUT";
fi

echo "The bootstrap timeout is: $TIMEOUT. Enter a new timeout or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    TIMEOUT="$INPUT_VAR";
fi

ENABLE_INCOMING_REPLICATION="false";
if [ ! -z "$PARAM_ENABLE_INCOMING_REPLICATION" ]; then
  ENABLE_INCOMING_REPLICATION="$PARAM_ENABLE_INCOMING_REPLICATION";
fi

echo "The enable incoming replication value is: $ENABLE_INCOMING_REPLICATION. Entering 'true' will skip the bootstrap and enable the local gateway for communication."
echo "Enter 'true'/'false' or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
  if [ "$INPUT_VAR" = "true" ]; then
    ENABLE_INCOMING_REPLICATION="true";
  else
    ENABLE_INCOMING_REPLICATION="false";
  fi  
fi

echo "You have entered:";
echo "--locator=$LOCATOR --sourceGateway=$SOURCE_GATEWAY --localGateway=$LOCAL_GATEWAY --timeout=$TIMEOUT --enableIncomingReplication=$ENABLE_INCOMING_REPLICATION";
echo "Press Y or ENTER to proceed:";
read INPUT_VAR;

if [ -z "$INPUT_VAR" ] || [ "Y" = "$INPUT_VAR"  ]; then
  if [ "$ENABLE_INCOMING_REPLICATION" = "false" ]; then
    echo "You haven chosen to bootstrap."
    $BIN_DIR/bootstrap.sh --locator=$LOCATOR --sourceGateway=$SOURCE_GATEWAY --localGateway=$LOCAL_GATEWAY --timeout=$TIMEOUT
  else
    echo "You have chosen to enable incoming replication and skip the bootstrap."
    $BIN_DIR/bootstrap.sh --locator=$LOCATOR --sourceGateway=$SOURCE_GATEWAY --localGateway=$LOCAL_GATEWAY --enableIncomingReplication=$ENABLE_INCOMING_REPLICATION 
  fi
else
  echo "You have chosen not to run the bootstrap.";
fi

echo "End of $0"
