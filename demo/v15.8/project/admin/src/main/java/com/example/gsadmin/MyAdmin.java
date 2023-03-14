package com.example.gsadmin;

import org.openspaces.admin.Admin;
import org.openspaces.admin.AdminFactory;


import java.nio.file.Files;
import java.nio.file.Paths;


public class MyAdmin {
    protected String locator;
    // lookup group can be null, we don't actually need it to connect to Gigaspaces
    protected String lookupGroup;
    protected Admin admin;
    protected String username;
    protected String password;

    public MyAdmin() {}

    protected void initAdmin() {
        AdminFactory af = new AdminFactory();
        af.addLocator(locator);

        if (lookupGroup != null && !"".equals(lookupGroup)) {
            af.addGroup(lookupGroup);
        }

        if( username != null && password != null ) {
            af.credentials(username, password);
        }
        admin = af.createAdmin();
    }

    protected void readPasswordFile(String filename) throws java.io.IOException {
        try {
            password = new String(Files.readAllBytes(Paths.get(filename))).trim();
        } catch( java.io.IOException ex) {
            ex.printStackTrace();
            throw(ex);
        }
    }

/*
    protected String username;
    protected String password;
    protected boolean securityEnabled;

    public MyAdmin() {}

    public MyAdmin(String username, String password) {
        this.username = username;
        this.password = password;
        this.securityEnabled = true;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean isSecurityEnabled() {
        return securityEnabled;
    }

    public void setSecurityEnabled(boolean securityEnabled) {
        this.securityEnabled = securityEnabled;
    }
 */


}

