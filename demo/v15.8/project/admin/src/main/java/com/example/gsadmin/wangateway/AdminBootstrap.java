package com.example.gsadmin.wangateway;

import java.util.concurrent.TimeUnit;

import com.example.gsadmin.MyAdmin;
import org.openspaces.admin.Admin;
import org.openspaces.admin.AdminFactory;
import org.openspaces.admin.gateway.BootstrapResult;
import org.openspaces.admin.gateway.Gateway;
import org.openspaces.admin.gateway.GatewaySink;
import org.openspaces.admin.gateway.GatewaySinkSource;

public class AdminBootstrap extends MyAdmin {


    Gateway bootstrapGateway;

    private String sourceGatewayName;
    private String localGatewayName;
    private static boolean enableIncomingReplication = false;
    private long timeout = 3600L;


    public void processArgs(String[] args) {

        try {
            int i = 0;
            while (i < args.length) {
                String s = args[i];
                String sUpper = s.toUpperCase();

                if (sUpper.startsWith("--help".toUpperCase())) {
                    printUsage();
                    System.exit(0);
                }
                else if (sUpper.startsWith("--locator".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    locator = sArray[1];
                }
                else if (sUpper.startsWith("--sourceGateway".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    sourceGatewayName = sArray[1];
                }
                else if (sUpper.startsWith("--localGateway".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    localGatewayName = sArray[1];
                }
                else if (sUpper.startsWith("--timeout".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String value = sArray[1];
                    timeout = Long.parseLong(value);
                }
                else if (sUpper.startsWith("--enableIncomingReplication".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String value = sArray[1];
                    enableIncomingReplication = java.lang.Boolean.parseBoolean(value);
                }
                else if (sUpper.startsWith("--username".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    username = sArray[1];
                }
                else if (sUpper.startsWith("--passwordFilename".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String passwordFilename = sArray[1];
                    readPasswordFile(passwordFilename);
                }
                else if (sUpper.startsWith("--password".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    password = sArray[1];
                }
                else {
                    System.out.println("Please enter valid arguments.");
                    printUsage();
                    System.exit(0);
                }
                i++;
            }
        } catch (Exception e) {
            e.printStackTrace();
            printUsage();
            System.exit(-1);
        }

        if (locator == null || sourceGatewayName == null || localGatewayName == null) {
            printUsage();
            System.exit(-1);
        }

    }
    public void displayArgs() {
        if( enableIncomingReplication == false ) {
            System.out.println("You have chosen to bootstrap this site.");
            System.out.println("locator is: " + locator);
            System.out.println("sourceGateway is: " + sourceGatewayName);
            System.out.println("localGateway is: " + localGatewayName);
            System.out.println("timeout is: " + timeout);
        }
        else {
            System.out.println("You have chosen to skip the bootstrap.");
            System.out.println("locator is: " + locator);
            System.out.println("sourceGateway is: " + sourceGatewayName);
            System.out.println("localGateway is: " + localGatewayName);
            System.out.println("enableIncomingReplication is: " + enableIncomingReplication);
        }
        if( username != null && password != null ) {
            System.out.println("username is: " + username);
        }
    }

    public static void printUsage() {
        System.out.println("This program uses the Gigaspaces Admin API to initiate the bootstrap of WAN Gateway.");
        System.out.println("The following arguments are used:");
        System.out.println("  --locator=<hostname:port num>");
        System.out.println("    The lookup locator to connect to the grid (i.e., the local grid; the grid that is going to receive data.)");
        System.out.println("  --sourceGateway=<source gateway name>");
        System.out.println("    The gateway name of the source where we will read the information");
        System.out.println("  --localGateway=<local gateway name>");
        System.out.println("    The local gateway name; the gateway that will receive the information");
        System.out.println("  --timeout=<timeout>");
        System.out.println("    The amount of time to keep trying the bootstrap and allow it to complete. Default is 3600 seconds. Optional.");
        System.out.println("  --enableIncomingReplication='true'/'false'");
        System.out.println("    boolean value. If set to true will skip the bootstrap and just enable incoming replication. Default is false. Optional.");
        System.out.println("    Used with --locator, --sourceGateway, --localGateway");
        System.out.println("  --username=<username>");
        System.out.println("    The username. Use if XAP cluster is secured.");
        System.out.println("  --password=<password>");
        System.out.println("    The password. Use if XAP cluster is secured.");
        System.out.println("  --passwordFilename=</path/to/password/file>.");
        System.out.println("    Filename of file containing password. Use this if you want the program to read the password from a file.");
        System.out.println("  --help");
        System.out.println("    Display this help message.");
    }

    void initGateway() {
        System.out.println(String.format("Waiting for %s local gateway...", localGatewayName));
        bootstrapGateway = admin.getGateways().waitFor(localGatewayName);
    }

    void bootstrap() {
        System.out.println("Starting bootstrap...");
        try {
            System.out.println(String.format("Waiting for %s to connect to %s sink...", localGatewayName, sourceGatewayName));

            GatewaySinkSource sinkSource = bootstrapGateway.waitForSinkSource(sourceGatewayName);

            BootstrapResult bootstrapResult = sinkSource.bootstrapFromGatewayAndWait(timeout, TimeUnit.SECONDS);

            boolean isSucceeded = bootstrapResult.isSucceeded();

            System.out.println("bootstrap result success: " + isSucceeded);

            if (!isSucceeded) {
                Throwable result = bootstrapResult.getFailureCause();
                result.printStackTrace();

                Throwable cause = null;

                while (null != (cause = result.getCause()) && (result != cause)) {
                    result = cause;
                    result.printStackTrace();
                }
            }
        } catch(Throwable t) {
            t.printStackTrace();
        }
        System.out.println("Bootstrap process finished.");
    }

    void enableIncomingReplication() {
        System.out.println("Enabling incoming replication...");
        System.out.println(String.format("Waiting for %s to connect to %s sink...", localGatewayName, sourceGatewayName));
        try {
            GatewaySink sink = bootstrapGateway.waitForSink(sourceGatewayName);
            sink.enableIncomingReplication();
        } catch(Throwable t) {
            t.printStackTrace();
        }
        System.out.println("Finished enabling incoming replication.");
    }

    public static void main(String[] args) {
        AdminBootstrap bootstrap = new AdminBootstrap();
        bootstrap.processArgs(args);
        bootstrap.displayArgs();

        System.out.println("Creating admin object...");
        bootstrap.initAdmin();
        bootstrap.initGateway();

        if (!enableIncomingReplication) {
            bootstrap.bootstrap();
        } else {
            bootstrap.enableIncomingReplication();
        }
        System.exit(0);
    }
}

