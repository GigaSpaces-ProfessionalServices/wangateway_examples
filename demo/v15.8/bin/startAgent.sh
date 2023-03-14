#!/usr/bin/env bash

################################################################################
# This script starts the components used by XAP also known as the service grid.
# The main components of the service grid are the manager and GSCs.
################################################################################

DC=$1
CLUSTER=$2

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"


# check the dc has been passed; source the dc config
env_check "$DC" "$CLUSTER" "$0"

echo; 
echo "Starting Manager...";
$BIN_DIR/startManager.sh $DC $CLUSTER

SPACE_CONFIG_DIR="`dirname \"$0\"`/config/$DC/$CLUSTER"
SPACE_CONFIG_DIR="`( cd \"$SPACE_CONFIG_DIR\" && pwd )`"

SPACES_FILE="$SPACE_CONFIG_DIR/spaces.txt"


if [ -z "$SPACES_FILE" ]; then
  echo "The file $SPACES_FILE does not exist";
  exit -1;
fi

echo
echo "Starting space GSCs..."
echo "SPACE_CONFIG_DIR is: $SPACE_CONFIG_DIR"
echo "SPACES_FILE is: $SPACES_FILE";

while read SPACE; do
  if [[ "$SPACE" == "#"* ]]; then
    # skip if commented out
    continue; 
  fi
  echo
  echo "Starting grid components for $SPACE"

  $BIN_DIR/startSpaceGsc.sh "$DC" "$CLUSTER" "$SPACE"

  $BIN_DIR/startWangwGsc.sh "$DC" "$CLUSTER" "$SPACE"

done < "$SPACES_FILE"

echo "End of $0."
