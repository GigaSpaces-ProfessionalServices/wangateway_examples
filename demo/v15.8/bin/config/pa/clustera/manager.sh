#!/usr/bin/env bash

# XAP cluster specific configurations

export UNICAST_PORT="4174"

export GS_MANAGER_SERVERS="172.31.10.72;lus=$UNICAST_PORT,172.31.2.212;lus=$UNICAST_PORT,172.31.12.240;lus=$UNICAST_PORT"

export REST_HOST="172.31.10.72:8090"

# for admin WAN GW bootstrap and modifyTarget
export BOOTSTRAP_LOCATOR="172.31.10.72:$UNICAST_PORT"

# locators representing each of the data centers in the cluster
export MULTI_DC_LOCATORS="172.31.14.28:4174,172.31.10.72:4174,172.31.13.223:4174"
