package com.example.gsadmin.wangateway;

import com.example.gsadmin.MyAdmin;
import com.gigaspaces.cluster.activeelection.SpaceMode;
import com.j_spaces.core.filters.ReplicationStatistics;
import org.openspaces.admin.Admin;
import org.openspaces.admin.AdminFactory;
import org.openspaces.admin.gateway.Gateway;
import org.openspaces.admin.gateway.GatewayProcessingUnit;
import org.openspaces.admin.gateway.GatewaySinkSource;
import org.openspaces.admin.gateway.Gateways;
import org.openspaces.admin.space.Space;
import org.openspaces.admin.space.SpaceInstance;
import org.openspaces.admin.space.SpacePartition;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

public class WanGatewayInfo extends MyAdmin {

    private static Logger log = Logger.getLogger(WanGatewayInfo.class.getName());
    

    private static String[] locators;
    private static String spaceName = "Products";
    private static String sUsername;
    private static String sPassword;
    private static String sPasswordFilename;


    public WanGatewayInfo(String username, String password, String passwordFilename, String locator) {
        this.username = username;
        if( passwordFilename != null ) {
            try {
                readPasswordFile(passwordFilename);
            } catch( IOException e) {
                e.printStackTrace();
            }
        }
        if( password != null ) {
            this.password = password;
        }
        this.locator = locator;
        initAdmin();
    }

    private void showRedoLogStatistics() {
        System.out.println("Gathering redolog counts...");

        // add appropriate waitFor call
        Space s = admin.getSpaces().waitFor(spaceName, 10, TimeUnit.SECONDS);
        if( s != null ) {
            s.waitFor(s.getNumberOfInstances(), SpaceMode.PRIMARY, 10, TimeUnit.SECONDS);
        }

        int spaceCount = 1;
        for (Space space : admin.getSpaces()) {
            SpacePartition partitions[] = space.getPartitions();
            System.out.println(String.format("Space (%d), [%s] :", spaceCount++, space.getName()));
            for (int i = 0; i < partitions.length; i++) {
                SpacePartition partition = partitions[i];
                long redologSize = partition.getPrimary().getStatistics().
                        getReplicationStatistics().getOutgoingReplication().getRedoLogSize();

                System.out.println(String.format("   -> Redo log size for partition [%d] is: %d", partition.getPartitionId(), redologSize));
            }
        }
        System.out.println("*** End redolog counts ***");
        System.out.println();
    }

    public void showNumberOfEntries() {
        System.out.println("Gathering object counts...");

        // add appropriate waitFor call
        Space s = admin.getSpaces().waitFor(spaceName, 10, TimeUnit.SECONDS);
        if( s != null ) {
            s.waitFor(s.getNumberOfInstances(), SpaceMode.PRIMARY, 10, TimeUnit.SECONDS);
        }
        int spaceCount = 1;
        for (Space space : admin.getSpaces()) {
            System.out.println(String.format("Space (%d), [%s], numberOfInstances [%d], numberOfBackups [%d]:",
                    spaceCount++, space.getUid(), space.getNumberOfInstances(), space.getNumberOfBackups()));
            System.out.println(String.format("   Stats: Write [ %d (write count), %s (write per second)]",
                    space.getStatistics().getWriteCount(),
                    space.getStatistics().getWritePerSecond()
            ));
            System.out.println("   Instance information...");
            for (SpaceInstance spaceInstance : space) {
                Map<String, Integer> map = spaceInstance.getRuntimeDetails().getCountPerClassName();
                Iterator<String> iter = map.keySet().iterator();
                System.out.println(String.format("   -> SpaceInstance [%s], instanceId [%d], backupId [%d], Mode [%s]",
                        spaceInstance.getUid(), spaceInstance.getInstanceId(), spaceInstance.getBackupId(), spaceInstance.getMode()));

                int classCount = 1;
                while( iter.hasNext()) {
                    String key = iter.next();
                    if( ! "java.lang.Object".equals(key) ) {
                        System.out.println(String.format("      -> Class (%d) : %s, count: %d", classCount++, key, map.get(key)));
                    }
                }
                System.out.println("      -> Host: "
                        + spaceInstance.getMachine().getHostAddress());
                System.out.println(String.format("      -> Stats: Write [ %d (write count), %s (write per second)]"
                        , spaceInstance.getStatistics().getWriteCount()
                        , spaceInstance.getStatistics().getWritePerSecond()
                ));
                System.out.println("      -> GSC: "
                        // gsc.getId() <= added after 10.2.1
                        + spaceInstance.getVirtualMachine().getGridServiceContainer().getId());

            }
        }
        System.out.println("*** End object counts ***");
        System.out.println();
    }



    public void showTargets() {
        System.out.println("Gathering gateway information...");
        System.out.println("Inbound details : ");
        Gateways gateways = admin.getGateways();

        int gatewayCount = 1;
        for(Gateway gateway : gateways) {
            System.out.println(String.format("Gateway (%d), [%s] :", gatewayCount++, gateway.getName()));
            System.out.println("   Gateway details...");
            Map<String, GatewayProcessingUnit> map = gateway.getNames();
            Iterator<String> iter = map.keySet().iterator();
            while(iter.hasNext()) {
                String key = iter.next();
                System.out.println("   -> PU name : " + key);
                GatewaySinkSource[] arrGatewaySinkSource = map.get(key).getSink().getSources();
                if( arrGatewaySinkSource != null) {
                    int gatewaySinkSourceCount = 1;
                    for(GatewaySinkSource gatewaySinkSource: arrGatewaySinkSource) {
                        System.out.println(String.format("   -> Sink gateway (%d), name : %s", gatewaySinkSourceCount++, gatewaySinkSource.getSourceGatewayName()));
                    }
                }
                System.out.println("   -> Discovery port : " + map.get(key).getDiscoveryPort());
                System.out.println("   -> Communication port : " + map.get(key).getCommunicationPort());
            }
        }
        System.out.println();
        System.out.println("Outbound details : ");
        int spaceCount = 1;
        for (Space space : admin.getSpaces()) {
            System.out.println(String.format("Space (%d), [%s] :", spaceCount++, space.getName()));
            SpacePartition partitions[] = space.getPartitions();

            for (int i = 0; i < partitions.length; i++) {
                SpacePartition partition = partitions[i];
                int partitionId = partition.getPartitionId();
                System.out.println(String.format("   -> Space partition id [%s] :", partitionId));

                long redologSize = partition.getPrimary().getStatistics().
                        getReplicationStatistics().getOutgoingReplication().getRedoLogSize();


                System.out.println(String.format("      -> Redo log size for partition [%d] is: %d", partitionId, redologSize));

                int channelCount = 1;
                for (ReplicationStatistics.OutgoingChannel channel : partition.getPrimary().
                        getStatistics().
                        getReplicationStatistics().
                        getOutgoingReplication().
                        getChannels(ReplicationStatistics.ReplicationMode.GATEWAY)) {
                    if(channel.getReplicationMode().name().equals("BACKUP_SPACE")){ continue;}
                    String targetShortName = channel.getTargetMemberName().split(":")[1];
                    System.out.println(String.format("      -> Channel (%d), [%s] :", channelCount++, targetShortName));


                    String remoteHostname = "Not available";
                    String processId = "Not available";
                    String version = "Not available";
                    if(channel.getTargetDetails() != null ) {
                        remoteHostname = channel.getTargetDetails().getHostName();
                        version = channel.getTargetDetails().getVersion().toString();
                        processId = "" + channel.getTargetDetails().getProcessId();
                    }
                    System.out.println("         -> Remote host : "+ remoteHostname);
                    System.out.println("         -> Version : " + version);
                    System.out.println("         -> PID : "+ processId);

                    System.out.println("         -> Channel state : "+channel.getChannelState().name());
                    System.out.println("         -> receivedBytesPerSecond : "+channel.getReceiveBytesPerSecond());
                    System.out.println("         -> sendBytesPerSecond : "+channel.getSendBytesPerSecond());
                    System.out.println("         -> SendPacketsPerSecond : "+channel.getSendPacketsPerSecond());
                }
            }
        }
        System.out.println("*** End gateway information ***");
    }

    public static void printUsage() {
        System.out.println("This program is used to check the status of the WAN gateway.");
        System.out.println("Available arguments: are -locators x -spaceName x -username x -password x -passwordFilename x");
        System.out.println("Or -help to print this help.");
        System.out.println("  -locators,      lookup locators. Typically you will specify 3, one for each data center, separated with commas.");
        System.out.println("       Example: -locators server1:4174,server2:4174,server3:4174");
        System.out.println("  -spaceName,     space name. A space name to wait for.");
        System.out.println("       Default: \"Products\"");
        System.out.println("  -username,      username. Include if the XAP cluster is secured.");
        System.out.println("  -password,      password. Include if the XAP cluster is secured.");
        System.out.println("  -passwordFilename, </path/to/password/file>.");
        System.out.println("       Filename of file containing password. Use this if you want the program to read the password from a file.");
        System.exit(0);
    }

    private static void processArgs(String[] args) {
        int index = args.length;

        if (index >= 2) {
            while (index >= 2) {
                String property = args[index - 2];
                String value = args[index - 1];

                if (property.equalsIgnoreCase("-locators")) {
                    locators = value.split(",");
                } else if (property.equalsIgnoreCase("-spaceName")) {
                    spaceName = value;
                } else if (property.equalsIgnoreCase("-username")) {
                    sUsername = value;
                } else if (property.equalsIgnoreCase("-passwordFilename")) {
                    sPasswordFilename = value;
                } else if (property.equalsIgnoreCase("-password")) {
                    sPassword = value;
                } else {
                    System.out.println("Please enter valid arguments.");
                    printUsage();
                    System.exit(0);
                }

                index -= 2;
            }
        }
    }
    public static void main(String[] args) {
        if (args[0].equalsIgnoreCase("-help")) {
            printUsage();
            System.exit(0);
        }

        processArgs(args);

        int locatorCount=1;
        for (String locator : locators) {
            System.out.println(String.format("Starting for locator (%d), %s\n", locatorCount++, locator));
            WanGatewayInfo info = new WanGatewayInfo(sUsername, sPassword, sPasswordFilename, locator);
            info.showNumberOfEntries();
            //info.showRedoLogStatistics();
            info.showTargets();
            System.out.println("------------------------------------------------------------\n\n");
        }
        System.out.println("Done with statistics.");
        System.exit(0);
    }
}

