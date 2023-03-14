#!/usr/bin/env bash

source setExampleEnv.sh
echo "GS_HOME is: $GS_HOME"


export GS_MANAGER_SERVERS="$US_MANAGER"


$GS_HOME/bin/gs.sh service deploy \
  --zones=US-space \
  -p localSpaceName=mySpace \
  -p localGatewayName=US \
  -p remoteGatewayName=DE \
                                             US-space $DEPLOY_DIR/wan-space


$GS_HOME/bin/gs.sh service deploy \
  --zones=US-gateway \
  -p localGatewayName=US \
  -p remoteGatewayName=DE \
  -p localSpaceUrl=jini://*/*/mySpace \
  -p localLookupHost=$US_MANAGER \
  -p localLookupPort=44174 \
  -p localCommunicationPort=48200 \
  -p remoteLookupHost=$DE_MANAGER \
  -p remoteLookupPort=44174 \
  -p remoteCommunicationPort=48200 \
                                             US-gateway $DEPLOY_DIR/wan-gateway

