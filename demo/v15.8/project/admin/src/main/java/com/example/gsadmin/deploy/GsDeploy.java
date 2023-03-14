package com.example.gsadmin.deploy;

import com.example.gsadmin.MyAdmin;
import org.openspaces.admin.Admin;
import org.openspaces.admin.AdminFactory;
import org.openspaces.admin.gsm.GridServiceManager;
import org.openspaces.admin.pu.ProcessingUnit;
import org.openspaces.admin.pu.ProcessingUnitDeployment;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class GsDeploy extends MyAdmin {
    String puName;
    String puJarFilename;
    String zone;

    boolean isStateful = false;
    int numberOfPartitions = 1;
    int numberOfBackups = 0;

    HashMap<String, String> hmProperties = new HashMap<>();

    GridServiceManager gsm;
    int managerCount = 1;

    public GsDeploy() {
    }

    public void initGsm() {
        admin.getGridServiceManagers().waitFor(managerCount,20, TimeUnit.SECONDS);
        gsm = admin.getGridServiceManagers().waitForActiveManager(10,TimeUnit.SECONDS);
    }
    public void deploy() {
        File puArchive = new File(puJarFilename);
        ProcessingUnitDeployment puDeployment = new ProcessingUnitDeployment(puArchive);
        puDeployment.name(puName);
        if (zone != null) {
            puDeployment.addZone(zone);
        }

        if( isStateful ) {
            puDeployment.partitioned(numberOfPartitions, numberOfBackups);
        }

        Iterator<Map.Entry<String,String>> iter = hmProperties.entrySet().iterator();
        while(iter.hasNext()) {
            Map.Entry<String,String> entry = iter.next();
            String key = entry.getKey();
            String value = entry.getValue();

            puDeployment.setContextProperty(key, value);
        }
        ProcessingUnit pu = gsm.deploy(puDeployment);
    }

    // calculates the manager count based on the settings for GS_MANAGER_SERVERS
    private int getManagerCount(String s) {
        int count = 1;
        int startIndex = 0;
        while( startIndex > -1 ) {
            int index = s.indexOf(",", startIndex);
            if (index == -1 ) {
                break;
            }
            startIndex = index + 1;
            count ++;
        }
        return count;
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
                } else if (sUpper.startsWith("--name".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    puName = sArray[1];
                } else if (sUpper.startsWith("--puJarFile".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    puJarFilename = sArray[1];
                } else if (sUpper.startsWith("--zone".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    zone = sArray[1];
                } else if (sUpper.startsWith("--numberOfPartitions".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    numberOfPartitions = Integer.parseInt(sArray[1]);
                    isStateful = true;
                } else if (sUpper.startsWith("--numberOfBackups".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    numberOfBackups = Integer.parseInt(sArray[1]);
                    isStateful = true;
                } else if (sUpper.startsWith("--prop".toUpperCase())) {
                    String[] sArray = s.split("=", 3);
                    hmProperties.put(sArray[1], sArray[2]);
                } else if (sUpper.startsWith("--managerServers".toUpperCase())) {
                    String[] sArray = s.split("=", 2);
                    String sValue = sArray[1];
                    managerCount = getManagerCount(sValue);
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
                }
                else {
                    System.out.println("Please enter valid arguments.");
                    printUsage();
                    System.exit(0);
                }
                i++;
            }

        } catch(Exception e) {
            e.printStackTrace();
            printUsage();
            System.exit(-1);
        }
        if (locator == null || puName == null || puJarFilename == null) {
            printUsage();
            System.exit(-1);
        }
    }

    public void printUsage() {
        System.out.println("This program uses the Admin API to deploy a processing unit.");
        System.out.println("The following arguments are used.");
        System.out.println("  --help.");
        System.out.println("    Print this help message.");
        System.out.println("  --locator=<locator>.");
        System.out.println("    The lookup locator used to connect to the XAP cluster.");
        System.out.println("    Required.");
        System.out.println("  --name=<name>.");
        System.out.println("    The name given to the processing unit.");
        System.out.println("    Required.");
        System.out.println("  --puJarFile=</path/to/pu.jar>.");
        System.out.println("    The location of the PU.jar for deployment.");
        System.out.println("    Required.");
        System.out.println("  --zone=<zone>.");
        System.out.println(     "The zone the PU should be deployed to.");
        System.out.println("  --numberOfPartitions=<n>.");
        System.out.println("    The number of partitions to deploy for a stateful PU.");
        System.out.println("  --numberOfBackups=1.");
        System.out.println("    1 means deploy 1 backup apiece for each partition.");
        System.out.println("    Setting either numberOfPartitions or numberOfBackups indicates a deployment of a stateful PU.");
        System.out.println("  --prop=<key>=<value>.");
        System.out.println("    Define a property that will be overridden during PU deployment.");
        System.out.println("  --managerServers=$GS_MANAGER_SERVERS.");
        System.out.println("    The value of GS_MANAGER_SERVERS. This program will then use this to calculate the number of managers for detection of managers");
        System.out.println("  --username=<username>.");
        System.out.println("    Username. Include if the XAP cluster is secured.");
        System.out.println("  --password=<password>.");
        System.out.println("    Password. Include if the XAP cluster is secured.");
        System.out.println("  --passwordFilename=</path/to/password/file.");
        System.out.println("    Filename of file containing password. Use this if you want the program to read the password from a file.");
    }

    public void displayArgs() {
        System.out.println("locator is: " + locator);
        if( username != null && password != null ) {
            System.out.println("username is: " + username);
        }
        System.out.println("name is: " + puName);
        System.out.println("pu jar file is: " + puJarFilename);
        System.out.println("zone is: " + zone);
        if (isStateful) {
            System.out.println("number of partitions is: " + numberOfPartitions);
            System.out.println("number of backups is: " + numberOfBackups);
        }

        System.out.println("deployment properties:");
        Iterator<Map.Entry<String,String>> iter = hmProperties.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry<String,String> entry = iter.next();
            String key = entry.getKey();
            String value = entry.getValue();
            System.out.println(String.format("    prop: %s = %s", key, value));
        }
    }
    public static void main(String[] args) {

        GsDeploy deploy = new GsDeploy();

        deploy.processArgs(args);
        deploy.displayArgs();
        deploy.initAdmin();
        deploy.initGsm();
        deploy.deploy();
    }
}
