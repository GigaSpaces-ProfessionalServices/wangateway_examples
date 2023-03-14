package com.gigaspaces.demo.feeder;

import com.gigaspaces.client.WriteModifiers;
import org.openspaces.core.GigaSpace;
import org.openspaces.core.GigaSpaceConfigurer;
import org.openspaces.core.space.SpaceProxyConfigurer;

import java.util.logging.Logger;

public class Main {

    private static Logger logger = Logger.getLogger(Main.class.getName());

    public static final String GS_LOOKUP_GROUPS = "GS_LOOKUP_GROUPS";
    public static final String GS_LOOKUP_LOCATORS = "GS_LOOKUP_LOCATORS";

    private String spaceName;
    private int numObjects = 50000;

    private String username;
    private String password;

    private GigaSpace gigaSpace;

    static {
        // for debug purposes
        // 1. set from environment variable, XAP checks this for lookup settings
        System.out.println("lookup locators env variable: " + System.getenv(GS_LOOKUP_LOCATORS));
        System.out.println("lookup groups   env variable: " + System.getenv(GS_LOOKUP_GROUPS));
        // 2. set from System.property, XAP also checks this for lookup settings
        System.out.println("lookup locators System property: " + System.getProperty("com.gs.jini_lus.locators"));
        System.out.println("lookup groups   System property: " + System.getProperty("com.gs.jini_lus.groups"));
        // System.setProperty("com.gs.jini_lus.locators", System.getenv(GS_LOOKUP_LOCATORS));
        // System.setProperty("com.gs.jini_lus.groups", System.getenv(GS_LOOKUP_GROUPS));
    }

    private void initialize() {
        SpaceProxyConfigurer spaceProxyConfigurer = new SpaceProxyConfigurer(spaceName);
        if (username != null && password != null) {
            spaceProxyConfigurer.credentials(username, password);
        }
        gigaSpace = new GigaSpaceConfigurer(spaceProxyConfigurer).gigaSpace();
    }

    public void feeder() {
        for( int i=0; i < numObjects; i++ ) {
            Data data = new Data();
            data.setId(i);
            data.setMessage("msg - " + i);
            data.setProcessed(Boolean.FALSE);
            gigaSpace.write(data);
        }
    }

    public static void printUsage() {
        System.out.println("This program is a feeder used to write objects to Gigaspaces.");
        System.out.println("The following arguments are used:");
        System.out.println("  --spaceName=<name of the space>");
        System.out.println("  --numObjects=<number of objects to write>");
        System.out.println("  --username=<username>. Include if XAP cluster is secured.");
        System.out.println("  --password=<password>. Include if XAP cluster is secured.");
        System.out.println("  --help. Displays this help message");
    }

    private void processArgs(String[] args) {

        int i = 0;
        while (i < args.length) {
            String s = args[i];
            String sUpper = s.toUpperCase();

            if (sUpper.startsWith("--help".toUpperCase())) {
                printUsage();
                System.exit(0);
            } else if (sUpper.startsWith("--spaceName".toUpperCase())) {
                String[] sArray = s.split("=", 2);
                spaceName = sArray[1];
            } else if (sUpper.startsWith("--numObjects".toUpperCase())) {
                String[] sArray = s.split("=", 2);
                String value = sArray[1];
                numObjects = Integer.parseInt(value);
            } else if (sUpper.startsWith("--username".toUpperCase())) {
                String[] sArray = s.split("=", 2);
                username = sArray[1];
            } else if (sUpper.startsWith("--password".toUpperCase())) {
                String[] sArray = s.split("=", 2);
                password = sArray[1];
            }
            else {
                System.out.println("Please enter valid arguments.");
                printUsage();
                System.exit(-1);
            }
            i++;
        }

        if (spaceName == null) {
            printUsage();
            System.exit(-1);
        }
        System.out.println("Space name is: " + spaceName);
        System.out.println("Number of objects to write is: " + numObjects);
        if( username != null && password != null ) {
            System.out.println("Username is: " + username);
        }
    }
    public static void main(String[] args) {
        try {
            Main feeder = new Main();
            feeder.processArgs(args);
            feeder.initialize();
            feeder.feeder();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

