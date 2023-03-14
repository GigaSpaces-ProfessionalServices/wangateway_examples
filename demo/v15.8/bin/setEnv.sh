#!/usr/bin/env bash

################################################################################
# this file contains environment variable configurations shared between multiple
# xap clusters.
################################################################################

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

export GS_HOME="/home/ubuntu/gigaspaces-insightedge-enterprise-15.8.1"
#export GS_HOME="/home/ubuntu/gigaspaces-insightedge-enterprise-16.0.0-m14-sun-39"

export GS_LOOKUP_GROUPS="xap-15.8.1"

IP_ADDRESS="$(hostname -i)"

export GS_NIC_ADDRESS="$IP_ADDRESS"

#echo "IP ADDRESS=$IP_ADDRESS";
#echo "GS_NIC_ADDRESS=$GS_NIC_ADDRESS"


export GS_GSA_OPTIONS="-Xms512m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=1000"
export GS_MANAGER_OPTIONS="-Xms1g -Xmx1g -XX:+UseG1GC -XX:MaxGCPauseMillis=1000" 
export GS_CLI_OPTIONS="-Xms256m -Xmx256m -XX:+UseG1GC -XX:MaxGCPauseMillis=1000"
export GS_GSC_OPTIONS="-XX:+UseG1GC -XX:MaxGCPauseMillis=1000 -XX:+UseCompressedOops -Dgs.gc.collectionTimeThresholdWarning=8000 "

export GS_LICENSE="tryme"


export AGENT_LOG_DIR="/tmp"

#UNICAST_PORT set along with GS_MANAGER_SERVER

LRMI="-Djava.rmi.server.hostname=${GS_NIC_ADDRESS} \
  -Dcom.gs.multicast.enabled=false \
  -Dcom.gs.multicast.discoveryPort=${UNICAST_PORT} \
  -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=${UNICAST_PORT}"

################################################################################
# find config directory relative to bin directory
BIN_DIR="`dirname \"$0\"`"
BIN_DIR="`( cd \"$BIN_DIR\" && pwd )`"

################################################################################

# -Dcom.gs.security.fs.file-service.file-path=${BIN_DIR}/config/gs-directory.fsm"

export SECURITY_ENABLED="true"
if [ "true" = "$SECURITY_ENABLED" ]; then
  export USERNAME="giga_user";
  export PASSWORD="giga_user";
  export REST_PASSWORD_FILE="$BIN_DIR/config/rest-password-file"
  export PASSWORD_FILE="$BIN_DIR/config/password-file"
fi

SECURITY="-Dcom.gs.security.enabled=true \
  -Dcom.gs.manager.rest.ssl.enabled=false \
  -Dcom.gs.security.properties-file=${BIN_DIR}/config/security.properties"


if [ "true" = "$SECURITY_ENABLED" ]; then
  export GS_OPTIONS_EXT="${LRMI} -Dcom.gs.work=${GS_HOME}/work -Dcom.gs.deploy=${GS_HOME}/deploy ${SECURITY} -Dspring.profiles.active=prod,default"
else
  export GS_OPTIONS_EXT="${LRMI} -Dcom.gs.work=${GS_HOME}/work -Dcom.gs.deploy=${GS_HOME}/deploy -Dspring.profiles.active=dev,default"
fi

export GS_CLI_VERBOSE="true"
