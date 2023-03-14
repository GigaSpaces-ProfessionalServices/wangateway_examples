This is an example project that demonstrates WAN Gateway in a bi-directional topology.

### Instructions ###

1. Select or provision 2 hosts that have connectivity. In my setup, the hosts are actually in the same subnet. This is for demonstration purposes.
2. In the `bin/setExampleEnv.sh` file, designate one of the hosts as the US_MANAGER. The other host will be the DE_MANAGER. Update these environment variables.
3. You may need to update JAVA_HOME, GS_HOME and GS_LICENSE in the `bin/setExampleEnv.sh` script.
4. Push the scripts to both hosts.
5. In the server that is designated as US_MANAGER, run `./startGrid-US.sh`, then `./deploy-US.sh`
6. In the server that is designated as DE_MANAGER, run `./startGrid-DE.sh`, then `./deploy-DE.sh`
7. There are helper scripts for starting the webui and gs-ui.

Suggestion: Make the modifications and push the same set of code two both servers. Environment specific configurations should be limited to the settings found in `bin/setExampleEnv.sh`.
