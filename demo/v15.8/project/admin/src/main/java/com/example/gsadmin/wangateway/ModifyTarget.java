package com.example.gsadmin.wangateway;

import com.example.gsadmin.MyAdmin;
import org.openspaces.admin.Admin;
import org.openspaces.admin.AdminFactory;
import org.openspaces.admin.space.Space;
import org.openspaces.core.gateway.GatewayTarget;

import java.util.concurrent.TimeUnit;

public class ModifyTarget extends MyAdmin {

    String spaceName = null;
    String gatewayTargetName = null;

    private static final String REMOVE = "remove";
    private static final String ADD = "add";

    private static final long DEFAULT_WAIT_TIMEOUT = 10;
    static long waitTimeout = DEFAULT_WAIT_TIMEOUT;

    private static final String DEFAULT_ACTION = REMOVE;
    static String action = DEFAULT_ACTION; // default action

    public static void main(String[] args) {
        ModifyTarget modifyTarget = new ModifyTarget();
        if (args.length > 0) {
            modifyTarget.processArgs(args);
        } else {
            System.out.println("No arguments passed.");
            printUsage();
            System.exit(-1);
        }

        modifyTarget.checkParameter();
        modifyTarget.printParameter();

        if (action.equals(ADD)) {
            modifyTarget.addTarget();
        } else {
            modifyTarget.removeTarget();
        }
        System.exit(0);
    }

    public void processArgs(String[] args) {

        try {
            int i = 0;
            while (i < args.length) {
                String s = args[i];
                String sUpper = s.toUpperCase();
                if (sUpper.startsWith("--help".toUpperCase())) {
                    printUsage();
                    System.exit(0);
                } else if (sUpper.startsWith("--locator".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    locator = sArray[1];
                } else if (sUpper.startsWith("--lookupGroup".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    lookupGroup = sArray[1];
                } else if (sUpper.startsWith("--spaceName".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    spaceName = sArray[1];
                } else if (sUpper.startsWith("--gatewayName".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    gatewayTargetName = sArray[1];
                } else if (sUpper.startsWith("--action".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    action = sArray[1];
                } else if (sUpper.startsWith("--timeout".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String value = sArray[1];
                    waitTimeout = Long.parseLong(value);
                } else if (sUpper.startsWith("--username".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    username = sArray[1];
                } else if (sUpper.startsWith("--passwordFilename".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String passwordFilename = sArray[1];
                    readPasswordFile(passwordFilename);
                } else if (sUpper.startsWith("--password".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    password = sArray[1];
                } else {
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
    }

    public static void printUsage() {
        System.out.println("This program uses the Gigaspaces Admin API to add or remove outbound Gateway Targets used in WAN Gateway.");
        System.out.println("The following arguments are used:");
        System.out.println("  --action=<add or remove gateway target>");
        System.out.println("    Select the operation to perform from two appropriate valid values 'add' or 'remove'.");
        System.out.println("    Default : " + DEFAULT_ACTION);
        System.out.println("  --locator=<hostname:port num>");
        System.out.println("    The lookup locator to connect to the grid (i.e., the local grid; the grid that is going to receive data). Required.");
        System.out.println("  --lookupGroup=<name of lookup group>");
        System.out.println("  --spaceName=<space name>");
        System.out.println("    Space name in which to change gateway. Required.");
        System.out.println("  --gatewayName=<gateway name>");
        System.out.println("    Target gateway name to add or remove from the space defined. Required.");
        System.out.println("  --timeout=<timeout>");
        System.out.println("    Wait timeout for space to be discovered by Gigaspaces Admin. Default : " + DEFAULT_WAIT_TIMEOUT + " seconds.");
        System.out.println("  --username=<username>");
        System.out.println("    Username. Include if the XAP cluster is secured.");
        System.out.println("  --password=<password>");
        System.out.println("    Password. Include if the XAP cluster is secured.");
        System.out.println("  --passwordFilename=</path/to/password/file>.");
        System.out.println("    Filename of file containing password. Use this if you want the program to read the password from a file.");
    }

    void checkParameter() {
        if (locator == null || spaceName == null || gatewayTargetName == null) {
            printUsage();
            System.exit(-1);
        }
    }
    void printParameter() {
        System.out.println("locator is: " + locator);

        if( username != null && password != null ) {
            System.out.println("username is: " + username);
        }

        // lookup group can be null, not needed to connect. In this case it is ignored.
        if ( lookupGroup != null ) {
            System.out.println("lookUpGroup is: " + lookupGroup);
        }
        System.out.println("spaceName is: " + spaceName);
        System.out.println("gatewayName is: " + gatewayTargetName);
        System.out.println("action is: " + action);
        System.out.println("timeout is: " + waitTimeout);
    }


    void removeTarget() {
        // Removing a gateway target
        try {
            initAdmin();
            Space space = admin.getSpaces().waitFor(spaceName, waitTimeout, TimeUnit.SECONDS);

            if (space == null ) {
                System.out.println("space is null. Could not find space: " + spaceName);
                return;
            }
            System.out.println("removing gateway target...");

            space.getReplicationManager().removeGatewayTarget(gatewayTargetName);
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            System.out.println("Finished remove gateway target:  " + gatewayTargetName);
        }
    }

    void addTarget() {
        try {
            initAdmin();
            GatewayTarget gatewayTarget = new GatewayTarget(gatewayTargetName);
            // gatewayTarget.setBulkSize(500);
            Space space = admin.getSpaces().waitFor(spaceName, waitTimeout, TimeUnit.SECONDS);

            if (space == null ) {
                System.out.println("space is null. Could not find space: " + spaceName);
                return;
            }
            // Adding a gateway target
            System.out.println("adding gateway target...");
            // GS-14480 Reset target state when using addGatewayTarget
            // New in version 15.8.1
            // New boolean parameter to reset target.
            // Added to relax constraints when adding gateway target.
            // Original behavior is to check sequential numbering of packets to ensure consistency.
            // BofA is ok with this because leases on objects only last for 15 minutes and they prefer
            // to not re-deploy to avoid original behavior.
            space.getReplicationManager().addGatewayTarget(gatewayTarget, true);
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            System.out.println("Finished add gateway target: " + gatewayTargetName);
        }
    }

}

