#!/usr/bin/env bash

source setExampleEnv.sh

export GS_LOOKUP_GROUPS="US"

export GS_MANAGER_SERVERS="$US_MANAGER"

ORIGINAL_GS_GSC_OPTIONS="$GS_GSC_OPTIONS"

export GS_GSC_OPTIONS="$ORIGINAL_GS_GSC_OPTIONS -Dcom.gs.zones=US-space"

nohup $GS_HOME/bin/gs.sh host run-agent --manager --gsc=4 > /tmp/space-us.log 2>&1 &

export GS_GSC_OPTIONS="$ORIGINAL_GS_GSC_OPTIONS -Dcom.sun.jini.reggie.initialUnicastDiscoveryPort=44174 \
  -Dcom.gs.transport_protocol.lrmi.bind-port=48200 \
  -Dcom.gs.zones=US-gateway"


nohup $GS_HOME/bin/gs.sh host run-agent --gsc=1 > /tmp/gateway-us.log 2>&1 &
