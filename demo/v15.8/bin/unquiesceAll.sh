#!/usr/bin/env bash

################################################################################
# This script is now using curl with REST Manager to unquiesce.
# This script assumes the XAP cluster is secured.
################################################################################


declare -a SPACES

DC=$1
CLUSTER=$2

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"

echo "DC is: $DC"
echo "CLUSTER is: $CLUSTER"

# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"

source "$BIN_DIR/setEnv.sh"

# source the REST functions
source "$BIN_DIR/restFunc.sh"

SPACE_CONFIG_DIR="`dirname \"$0\"`/config/$DC/$CLUSTER"
SPACE_CONFIG_DIR="`( cd \"$SPACE_CONFIG_DIR\" && pwd )`"

SPACES_FILE="$SPACE_CONFIG_DIR/spaces.txt"


if [ -z "$SPACES_FILE" ]; then
  echo "The file $SPACES_FILE does not exist";
  exit -1;
fi

echo
echo "Running unquiesce for all spaces..."
echo "SPACE_CONFIG_DIR is: $SPACE_CONFIG_DIR"
echo "SPACES_FILE is: $SPACES_FILE";

while read SPACE; do
  if [[ "$SPACE" == "#"* ]]; then
    # skip if commented out
    continue; 
  fi

  # save to array for processing
  # otherwise the read in the helper script gets clobbered
  SPACES[${#SPACES[@]}]="$SPACE"

done < "$SPACES_FILE"

#GS_CMD="$GS_HOME/bin/gs.sh "

#if [ "true" = "$SECURITY_ENABLED" ]; then
#  GS_CMD="$GS_HOME/bin/gs.sh --username=$USERNAME --password=$PASSWORD ";
#fi


for SPACE in "${SPACES[@]}"; do
  SERVICE_NAME="$SPACE-$DC"
  echo
  echo "Unquiescing $SERVICE_NAME..."
  echo "Press Y/ENTER to unquiesce: "
  read INPUT_VAR;
  if [ -z "$INPUT_VAR" ] || [ "Y" = "$INPUT_VAR"  ]; then
    #$GS_CMD service unquiesce "$SERVICE_NAME"
    REQUEST_ID=$(unquiesce_pu "$REST_HOST" "$REST_PASSWORD_FILE" "$SERVICE_NAME")
    echo "Request ID: $REQUEST_ID was created."
  else
    echo "Skipping unquiesce for $SERVICE_NAME";
  fi
done

echo "End of $0."
