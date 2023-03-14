#!/usr/bin/env bash


set -x

source setExampleEnv.sh

export GS_LOOKUP_LOCATORS="$US_MANAGER,$DE_MANAGER"
export GS_LOOKUP_GROUPS="US,DE"

unset GS_MANAGER_SERVERS;

nohup $GS_HOME/bin/gs-ui.sh > /tmp/thick-ui.log 2>&1 &

