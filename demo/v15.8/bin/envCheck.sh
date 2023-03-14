#!/usr/bin/env bash

################################################################################
# This script contains various helper functions to source the desired
# environment variables.
# It also contains helper functions to extract parameters and store for later
# use.
################################################################################

# helper function to check if the environment was passed to the script
# also sources the correct manager
function env_check() {
  DC=$1
  CLUSTER=$2
  ORIG_SCRIPT=$3

  if [ -z "$DC" ] || [ -z "$CLUSTER" ]; then
    echo "Please specify a data center and a cluster as arguments.";
    exit -1;
  else
    echo "$ORIG_SCRIPT called with $DC and $CLUSTER";
  fi

  CONFIG_DIR="`dirname \"$0\"`/config/$DC/$CLUSTER"
  CONFIG_DIR="`( cd \"$CONFIG_DIR\" && pwd )`"

  if [ -z "$CONFIG_DIR" ]; then
    echo "The config directory could not be found";
    exit -1
  fi

  MANAGER_CONFIG="$CONFIG_DIR/manager.sh"
  echo "MANAGER_CONFIG is: $MANAGER_CONFIG";

  if [ -f "$MANAGER_CONFIG" ]; then
    source "$MANAGER_CONFIG"
  else
    echo "The file \"$MANAGER_CONFIG\" does not exist";
    exit -1;
  fi
}


# helper function to check if the space was passed to the script
# also sources the settings for the space
function space_check() {
  DC=$1
  CLUSTER=$2
  SPACE=$3
  ORIG_SCRIPT=$4

  if [ -z "$SPACE" ]; then
    echo "Please specify a space as an argument.";
    exit -1;
  else
    echo "$ORIG_SCRIPT called with space: $SPACE";
  fi

  SPACE_CONFIG="`dirname \"$0\"`/config/$DC/$CLUSTER/$SPACE.sh";

  echo "SPACE_CONFIG file is: $SPACE_CONFIG";

  if [ -f "$SPACE_CONFIG" ]; then
    source "$SPACE_CONFIG";
  else
    echo "The file $SPACE_CONFIG does not exist";
    exit -1;
  fi
}

# function to extract bootstrap arguments from arguments
function extract_bootstrap_args() {
  for i in "$@"; do

    if [[ "$i" == '--requiresBootstrap='* ]]; then
      VAL=$(echo "$i" | awk -F= '{print $2}')
      if [ "true" = "$VAL" ]; then
        export PARAM_REQUIRES_BOOTSTRAP="true"
      fi
      continue
    elif [[ "$i" == '--locator='* ]]; then
      export PARAM_LOCATOR=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--sourceGateway='* ]]; then
      export PARAM_SOURCE_GATEWAY=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--localGateway='* ]]; then
      export PARAM_LOCAL_GATEWAY=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--timeout='* ]]; then
      export PARAM_TIMEOUT=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--enableIncomingReplication='* ]]; then
      export PARAM_ENABLE_INCOMING_REPLICATION=$(echo "$i" | awk -F= '{print $2}')
      continue
    fi

    ARGS[${#ARGS[@]}]="$i"
  done
}

# function to extract modifytarget arguments from arguments
function extract_modifytarget_args() {
  for i in "$@"; do

    if [[ "$i" == '--action='* ]]; then
      export PARAM_ACTION=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--locator='* ]]; then
      export PARAM_LOCATOR=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--spaceName='* ]]; then
      export PARAM_SPACENAME=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--gatewayName='* ]]; then
      export PARAM_GATEWAYNAME=$(echo "$i" | awk -F= '{print $2}')
      continue
    elif [[ "$i" == '--timeout='* ]]; then
      export PARAM_TIMEOUT=$(echo "$i" | awk -F= '{print $2}')
      continue
    fi

    ARGS[${#ARGS[@]}]="$i"
  done
}

