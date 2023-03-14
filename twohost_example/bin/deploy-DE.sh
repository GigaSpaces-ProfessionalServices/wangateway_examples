#!/usr/bin/env bash

source setExampleEnv.sh
echo "GS_HOME is: $GS_HOME"


export GS_MANAGER_SERVERS="$DE_MANAGER"


$GS_HOME/bin/gs.sh service deploy \
  --zones=DE-space \
  -p localSpaceName=mySpace \
  -p localGatewayName=DE \
  -p remoteGatewayName=US \
                                             DE-space $DEPLOY_DIR/wan-space


$GS_HOME/bin/gs.sh service deploy \
  --zones=DE-gateway \
  -p localGatewayName=DE \
  -p remoteGatewayName=US \
  -p localSpaceUrl=jini://*/*/mySpace \
  -p localLookupHost=$DE_MANAGER \
  -p localLookupPort=44174 \
  -p localCommunicationPort=48200 \
  -p remoteLookupHost=$US_MANAGER \
  -p remoteLookupPort=44174 \
  -p remoteCommunicationPort=48200 \
                                             DE-gateway $DEPLOY_DIR/wan-gateway

