#!/usr/bin/env bash

################################################################################
# Maven is required.
# This will build the jar files for the space and the WAN Gateway. Since there 
# are 2 processing units and 3 data centers a total of 6 jars will be created.
################################################################################

# list of data centers
DATA_CENTERS="az pa tx"

# location of maven project
BUILD_DIR="`dirname \"$0\"`/../project"
BUILD_DIR="`( cd \"$BUILD_DIR\" && pwd )`"

echo "BUILD_DIR is: $BUILD_DIR"

# base destination to copy build artifacts to
#DEPLOY_BASE_DIR="/home/ubuntu/demo/v15.8/deploy"

DEPLOY_BASE_DIR="`dirname \"$0\"`/../deploy"
DEPLOY_BASE_DIR="`( cd \"$DEPLOY_BASE_DIR\" && pwd )`"

echo "DEPLOY_BASE_DIR is: $DEPLOY_BASE_DIR"

for i in $DATA_CENTERS; do
  if [ ! -d "$DEPLOY_BASE_DIR/space/$i/" ]; then
    mkdir -p $DEPLOY_BASE_DIR/space/$i
  fi
  if [ ! -d "$DEPLOY_BASE_DIR/gateway/$i/" ]; then
    mkdir -p $DEPLOY_BASE_DIR/gateway/$i
  fi
done

CWD=$(pwd)

cd "$BUILD_DIR"

mvn clean package

for val in $DATA_CENTERS; do
  echo "Processing $val artifacts...";
  echo "...";
  # copy jar files for easier access during deployment 
  cp $BUILD_DIR/space/target/space-1.0-SNAPSHOT.jar      $DEPLOY_BASE_DIR/space/$val/
  cp $BUILD_DIR/gateway/target/gateway-1.0-SNAPSHOT.jar  $DEPLOY_BASE_DIR/gateway/$val/
done


cd "$CWD"
