#!/usr/bin/env bash

source setExampleEnv.sh
echo "GS_HOME is: $GS_HOME"


export GS_MANAGER_SERVERS="$DE_MANAGER"

$GS_HOME/bin/gs-ui.sh
