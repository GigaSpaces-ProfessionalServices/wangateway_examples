#!/usr/bin/env bash

#export GS_LICENSE="Product=XAP;Version=16.1;Type=ENTERPRISE;Customer=GigaSpaces_Technologies_-_Internal_Piper_Sandler_DEV;Expiration=2022-Sep-30;Hash=NtPcNKVDhYOfCnbARErP"
export GS_LICENSE="tryme"

export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.332.b09-2.el8_6.x86_64"
#export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

export PATH="$JAVA_HOME/bin:$PATH"

export GS_HOME="/home/ec2-user/gigaspaces-xap-enterprise-16.1.1"

BIN_DIR="`dirname \"$0\"`"
export DEPLOY_DIR="`( cd \"$BIN_DIR/../deploy\" && pwd )`"


# Replace below with actual hostnames
#export US_MANAGER="ip-172-31-4-198.ca-central-1.compute.internal"
#export US_MANAGER="ip-172-31-4-198"
export US_MANAGER="172.31.4.198"
#export DE_MANAGER="ip-172-31-9-193.ca-central-1.compute.internal"
#export DE_MANAGER="ip-172-31-9-193"
export DE_MANAGER="172.31.9.193"

export GS_NIC_ADDRESS="$(hostname -i)"

HOSTNAME_SHORT="$(hostname --short)"

export GS_OPTIONS_EXT="-Dcom.gs.multicast.enabled=false \
 -Dcom.gs.smart-externalizable.enabled=false"
#-Djava.rmi.server.hostname=$HOSTNAME_SHORT
