#!/usr/bin/env bash

################################################################################
# This script allows a user to review the setings before calling the Java Admin 
# API program to add or remove outbound gateway targets.
################################################################################

declare -a ARGS


echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"

extract_modifytarget_args "$@"

DC=${ARGS[0]}
CLUSTER=${ARGS[1]}
SPACE=${ARGS[2]}

# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"

source "$BIN_DIR/setEnv.sh"

space_check "$DC" "$CLUSTER" "$SPACE" "$0"

#--action=remove --locator=host:4174 --spaceName=Product --gatewayName=Product-tx --timeout=10

ACTION="";
if [ ! -z "$PARAM_ACTION" ]; then
  ACTION="$PARAM_ACTION";
else
  ACTION="remove"
fi
echo "The action is: $ACTION. Enter a new action ('add' or 'remove') or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    ACTION="$INPUT_VAR";
fi

LOCATOR="";
if [ ! -z "$BOOTSTRAP_LOCATOR" ]; then
  LOCATOR="$BOOTSTRAP_LOCATOR";
fi
if [ ! -z "$PARAM_LOCATOR" ]; then
  LOCATOR="$PARAM_LOCATOR";
fi

echo "The locator is: $LOCATOR. Enter a new locator or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
  LOCATOR="$INPUT_VAR";
fi

SPACENAME="$SPACE";
if [ ! -z "$PARAM_SPACENAME" ]; then
  SPACENAME="$PARAM_SPACENAME";
fi

echo "The space in which to change the target gateway is: $SPACENAME.";
echo "Enter a new space name or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    SPACENAME="$INPUT_VAR";
fi


GATEWAYNAME="";
if [ ! -z "${remote_gateway_name_a}" ]; then
  GATEWAYNAME="${remote_gateway_name_a}";
fi
if [ ! -z "$PARAM_GATEWAYNAME" ]; then
  GATEWAYNAME="$PARAM_GATEWAYNAME";
fi

echo "The target gateway is the gateway where we want to send or receive the information.";
echo "Target gateway (1) is: ${remote_gateway_name_a}";
echo "Target gateway (2) is: ${remote_gateway_name_b}";
echo "The selected target gateway is: $GATEWAYNAME."
echo "Enter a new target gateway or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
  GATEWAYNAME="$INPUT_VAR";
fi

TIMEOUT="10";
if [ ! -z "$PARAM_TIMEOUT" ]; then
  TIMEOUT="$PARAM_TIMEOUT";
fi

echo "The timeout is: $TIMEOUT. This is the timeout used to discover the spaces in seconds."
echo "Enter a new timeout or press ENTER to accept.";
read INPUT_VAR
if [ ! -z "$INPUT_VAR" ]; then
    TIMEOUT="$INPUT_VAR";
fi

echo "You have entered:";
echo "--action=$ACTION --locator=$LOCATOR --spaceName=$SPACENAME --gatewayName=$GATEWAYNAME --timeout=$TIMEOUT";
echo "Press Y or ENTER to proceed";
read INPUT_VAR;

if [ -z "$INPUT_VAR" ] || [ "Y" = "$INPUT_VAR"  ]; then
  #$BIN_DIR/modifyTarget.sh --action=$ACTION --locator=$LOCATOR --spaceName=$SPACENAME --gatewayName=$GATEWAYNAME --timeout=$TIMEOUT
  $BIN_DIR/modifyTarget.sh --action=$ACTION --locator=$LOCATOR --spaceName=$SPACENAME --gatewayName=$GATEWAYNAME --timeout=$TIMEOUT
else
  echo "You have chosen not to run the modifyTarget.";
fi

echo "End of $0"
