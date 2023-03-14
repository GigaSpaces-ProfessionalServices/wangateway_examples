

This the sequence setup a cluster.

1. build.sh
  * Maven is required.
  * This will build the jar files for the space and the WAN Gateway. Since there are 2 processing units and 3 data centers a total of 6 jars will be created.

2. startAgent.sh <data center> <cluster> 
  * The data center can be either az, pa, or tx.
  * The cluster points to the cluster config directory location at config/<data center>/<cluster>

  * The cluster config directory sets the GS_MANAGER_SERVERS environment variable in the manager.sh.
  * The cluster config directory contains a file spaces.txt that contains the names of spaces to be deployed.
  * The cluster config directory also contains <space name>.sh files which will set environment variables specific to that space.

  * setEnv.sh is used to set environment variables shared by all the clusters.

  * This script calls startManager.sh, startSpaceGsc.sh and startWangwGsc.sh

  * startManager.sh  <data center> <cluster> will start a manager.
  * startSpaceGsc.sh <data center> <cluster> <space> will will start the GSCs that will host the space PU.
  * startWangwGsc.sh <data center> will start the GSCs that will host the WAN Gateway PU.
 

3. deployAll.sh <data center> <cluster>
   Calls deploy.sh for all the spaces in the cluster.

4. deploy.sh  <data center> <cluster> <space>
  * This deploys the processing unit for the space and the WAN Gateway.


5. mywebui.sh <data center> <cluster>
  * This will start the classic webui.

6. stopAgent.sh <data center> <cluster>
  * This script will stop the GigaSpaces processes on a host.

Bootstrap. There are 2 parts: deployment and a bootstrap done through the Admin API.
Deployment
1. deployAll.sh <data center> <cluster> --requiresBootstrap=true. This will call deploy.sh for all the spaces in the cluster.
2. deploy.sh <data center> <cluster> <space> --requiresBootstrap=true <= if calling individually for each space.
   If it has been called from deployAll.sh, you don't need to reset --requiresBootstrap=true

Admin bootstrap
There are 2 scenarios. 1. Bootstrap 2. Skip bootstrap, but enable the local gateway for incoming replication.
Scenario 1: Bootstrap
1. ./bootstrapAll.sh <data center> <cluster>. This will read from the list of spaces and call bootstrapHelper.sh
2. ./bootstrapHelper.sh <data center> <cluster> <space>. This will call the bootstrap.
   This script is interactive and gives you a chance to override default configurations.
3. ./bootstrap.sh --locator=$LOCATOR --sourceGateway=$SOURCE_GATEWAY --localGateway=$LOCAL_GATEWAY --timeout=$TIMEOUT
   The locator is the lookup locator to connect to the Admin object.
   The sourceGateway is the source gateway to read the information from.
   The localGateway is the gateway we are writing the information to.
   The timeout is the maximum amount of time it should wait for the bootstrap to complete.

Scenario 2: Enable the local gateway for incoming replicaion.
Note: Similar to the bootstrap, the deployment: "deploy.sh <data> <center> <cluster> <space> --requiresBootstrap=true" should have been done.
1. ./bootstrapAll.sh <data center> <cluster>. This will read from the list of spaces and call bootstrapHelper.sh. Same as above.
   Or:
   ./bootstrapAll.sh <data center> <cluster> --enableIncomingReplication=true, to pass the parameter to called scripts.
   If you choose not to pass 'enableIncomingReplication' you will get a chance to modify in the bootstrapHelper script.
2. ./bootstrapHelper.sh <data center> <cluster> <space>. This will call the bootstrap.
   This script is interactive and gives you a chance to override default configurations. When prompted to modify 'enableIncomingReplication', make sure this is set to 'true'.
3. ./bootstrap.sh --locator=$LOCATOR --localGateway=$LOCAL_GATEWAY --enableIncomingReplication=true
   The locator is the lookup locator to connect to the Admin object.
   The sourceGateway is used to help enable incoming replication.
   The localGateway is the gateway we are writing the information to.
   EnableIncomingReplication is used to instruct the Java program to enable incoming replication and skip the bootstrap.

Modify target
It's called modify target because you can add or remove targets.
Targets are the outbound targets a space is writing to via WAN Gateway.
1. ./modifyTargetAll.sh <data center> <cluster>. This will read from the list of spaces and call modifyTargetHelper.sh
2. ./modifyTargetHelper.sh <data center> <cluster> <space>. This will call the modifyTarget script.
   This script is interactive and gives you a chance to override default configurations.
3. ./modifyTarget.sh --action=$ACTION --locator=$LOCATOR --spaceName=$SPACENAME --gatewayName=$GATEWAYNAME --timeout=$TIMEOUT
   The action is either add or remove (an outbound gateway target).
   The locator is the lookup locator to connect to the Admin object.
   The spaceName is the name of the space the outbound targets are associated with.
   The gatewayName is the outbound gateway target that the space writes to.
   The timeout is the maximum amount of time the Gigaspaces Admin API should wait to discover cluster components.

Space statistics
Get the space statistics of all spaces in a cluster.
1. ./spaceStats.sh <data center> <cluster>

WAN Gateway Information
Get WAN Gateway information for each cluster.
1. ./wangatewayinfo.sh <data center> <clustera> 
