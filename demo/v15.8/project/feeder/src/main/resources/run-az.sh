#!/usr/bin/env bash

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"


GS_HOME="/home/ubuntu/gigaspaces-insightedge-enterprise-15.8.1"

PROJ_DIR="/home/ubuntu/demo/v15.8/project"

export CLASSES_DIR="$PROJ_DIR/feeder/target/classes"

CLASSPATH="$GS_HOME/lib/required/*"

CLASSPATH="$CLASSPATH:$CLASSES_DIR"

export GS_LOOKUP_LOCATORS="172.31.14.28:4174"
export GS_LOOKUP_GROUPS="xap-15.8.1"

$JAVA_HOME/bin/java -Xms1g -Xmx1g -classpath "$CLASSPATH" com.gigaspaces.demo.feeder.Main --username=giga_user --password=giga_user --spaceName=Product --numObjects=$1
