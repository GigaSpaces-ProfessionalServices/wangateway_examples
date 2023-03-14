#!/usr/bin/env bash

################################################################################
# This script is now using curl with REST Manager to report space stats.
# This script assumes the XAP cluster is secured.
################################################################################

declare -a SPACES

echo "Running $0..."

BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

echo "BIN_DIR is: $BIN_DIR"

# source the env_check function
source "$BIN_DIR/envCheck.sh"

DC=$1
CLUSTER=$2

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
echo "Getting object counts for all spaces..."
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


for i in "${SPACES[@]}"; do
  echo
  echo "Getting type counts for $i..."
  #$GS_CMD space info --type-stats $i 
  space_type_counts "$REST_HOST" "$REST_PASSWORD_FILE" "$i"
done

echo
echo "End of $0."

