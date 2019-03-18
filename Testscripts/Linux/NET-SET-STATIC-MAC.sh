#!/bin/bash
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the Apache License.

#############################################################################
#
# Description:
#    This script will first check the existence of ethtool on vm and will
#    get the link settings and then reset it from ethtool.
#
#############################################################################
# Source utils.sh
. utils.sh || {
    echo "Error: unable to source utils.sh!"
    echo "TestAborted" > state.txt
    exit 0
}

# Source constants file and initialize most common variables
UtilsInit
#######################################################################
# Main script body
#######################################################################
# Check if ethtool exist and install it if not
VerifyIsEthtool
net_interface="eth1"
# Verify the new NIC received an IP v4 address
LogMsg "Verify the new NIC has an IPv4 address"
ip addr show ${net_interface} | grep "inet\b" > /dev/null
check_exit_status "${net_interface} is up"  "exit"
LogMsg "The network interface is ${net_interface}"
# Change MAC
LogMsg "Changing mac to 02:01:02:03:04:08"
before=$(sudo ip a show $net_interface)
LogMsg "Before mac change : $before"
sudo ip link set $net_interface down && ip link set $net_interface address 02:01:02:03:04:08 && ip link set $net_interface up
if [ $? -ne 0 ]; then
    LogErr "unable to change mac"
    SetTestStateFailed
    exit 0
fi
after=$(sudo ip a show $net_interface)
LogMsg "After mac change : $after"
SetTestStateCompleted
exit 0