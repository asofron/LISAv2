#!/bin/bash
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the Apache License.
#############################################################################
ChangeMTU(){
    # save the maximum capable mtu
    change_mtu_increment $test_iface $iface_ignore
    if [ $? -ne 0 ]; then
        LogErr "Failed to change MTU on $test_iface"
        SetTestStateFailed
        exit 0
    fi
}

# Source constants file and initialize most common variables
UtilsInit
# Check if ethtool exist and install it if not
VerifyIsEthtool
# Retrieve synthetic network interfaces
GetSynthNetInterfaces
if [ 0 -ne $? ]; then
    LogErr "No synthetic network interfaces found"
    SetTestStateFailed
    exit 0
fi

net_interface=${SYNTH_NET_INTERFACES[0]}
# Verify the new NIC received an IP v4 address
LogMsg "Verify the new NIC has an IPv4 address"
ip addr show ${net_interface} | grep "inet\b" > /dev/null
check_exit_status "${net_interface} is up"  "exit"
LogMsg "The network interface is ${net_interface}"


# Get NIC statistics using ethtool
LogMsg "Getting NIC statistics with ethtool"
stats=$(ethtool -S $net_interface)
if [ $? -ne 0 ]; then
    LogErr "Failed get NIC statistics with ethtool !"
    SetTestStateFailed
    exit 0
else
    LogMsg "$stats"
fi
LogMsg "Getting NIC statistics with ethtool"
$statspcup=$(ethtool -S $net_interface | grep )
if [ $? -ne 0 ]; then
    LogErr "Failed get NIC statistics with ethtool !"
    SetTestStateFailed
    exit 0
else
    LogMsg "$statspcup"
fi
SetTestStateCompleted
exit 0