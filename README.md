# wangateway_examples
wangateway_examples

There are two examples available in this repository.
1. demo
 * Contains a wan gateway example with 3 data centers.
 * Implements a multi master topology (each Gigaspaces cluster can receive and send replication information).
 * The managers are configured with high availability, meaning 3 managers are to be run.
 * There is Gigaspaces Java Admin API code and scripts to control adding and removing a gateway target.
 * There is Gigaspaces Java Admin API code and scripts to bootstrap a Gigaspaces cluster. bootstrap along with adding and removing targets is useful when one of the of data centers may be available for an extended amount of time. In this scenario it would make sense to copy all the data using the bootstrap method instead of relying on accumulation of redo log data.
 * A script that can be run to provide detailed information about the state of wan gateway in each of the Gigaspaces cluster. See: `wangatewayinfo.sh`
 * For more information on getting started, please refer to `demo/v15.8/bin/README.md`
 
2. twohost_example
 * This is a wan gateway example that is a more typical example scenario, with wan gateway running on two separate hosts, each representing a separate Gigaspaces cluster.
 
