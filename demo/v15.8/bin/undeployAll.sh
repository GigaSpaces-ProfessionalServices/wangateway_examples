#!/usr/bin/env bash

################################################################################
# This script checks which spaces are available and calls another script to
# undeploy the space PU and the WAN gateway PU.
################################################################################

DC="$1"
CLUSTER="$2"

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


SPACE_CONFIG_DIR="`dirname \"$0\"`/config/$DC/$CLUSTER"
SPACE_CONFIG_DIR="`( cd \"$SPACE_CONFIG_DIR\" && pwd )`"

SPACES_FILE="$SPACE_CONFIG_DIR/spaces.txt"


if [ -z "$SPACES_FILE" ]; then
  echo "The file $SPACES_FILE does not exist";
  exit -1;
fi

echo
echo "Undeploying all spaces and WAN gateways..."
echo "SPACE_CONFIG_DIR is: $SPACE_CONFIG_DIR"
echo "SPACES_FILE is: $SPACES_FILE";

while read SPACE; do
  if [[ "$SPACE" == "#"* ]]; then
    # skip if commented out
    continue; 
  fi
  echo
  echo "Undeploying PUs for $SPACE"

  $BIN_DIR/undeploy.sh "$DC" "$CLUSTER" "$SPACE"

done < "$SPACES_FILE"

echo "End of $0."
