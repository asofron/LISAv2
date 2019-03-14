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
net_interface2="eth2"
# Verify the new NIC received an IP v4 address
LogMsg "Verify the new NIC has an IPv4 address"
ip addr show ${net_interface} | grep "inet\b" > /dev/null
check_exit_status "${net_interface} is up"  "exit"
LogMsg "The network interface is ${net_interface}"

# Get the information of the link

LogMsg "Getting ksettings $net_interface.."
ksettings=$(ethtool $net_interface )
LogMsg "The link settings of $net_interface:"
LogMsg "$ksettings"

# TODO: Change the link settings with the below command when the diver supports the option in future. 
# ethtool --change eth0 speed xxx duplex yyy
# where xxx = N and yyy = half or full.
LogMsg "setting mtu 1505 on  $net_interface"
sudo ip link set dev $net_interface mtu 1505
if [ $? -ne 0 ]; then
    LogErr "Failed to change MTU !"
    SetTestStateFailed
    exit 0
fi
LogMsg "setting mtu 2048 on $net_interface"
sudo ip link set dev $net_interface mtu 2048
if [ $? -ne 0 ]; then
    LogErr "Failed to change MTU !"
    SetTestStateFailed
    exit 0
fi
LogMsg "setting mtu 4096 on $net_interface"
sudo ip link set dev $net_interface mtu 4096
if [ $? -ne 0 ]; then
    LogErr "Failed to change MTU !"
    SetTestStateFailed
    exit 0
fi

LogMsg "setting promisc on to $net_interface"
sudo ip link set dev $net_interface promisc on
if [ $? -ne 0 ]; then
    LogErr "Failed to to set promisc on !"
    SetTestStateFailed
    exit 0
fi

LogMsg "Getting statistics with ethtool"
stats=$(ethtool -S $net_interface)
if [ $? -ne 0 ]; then
    LogErr "Failed getting statistics with ethtool !"
    SetTestStateFailed
    exit 0
else
    LogMsg "Stats : $stats"
fi
LogMsg "Changing mac to 02:01:02:03:04:08"
before=$(sudo ip a show $net_interface2)
LogMsg "Before mac change : $before"
sudo ip link set $net_interface2 down && ip link set $net_interface2 address 02:01:02:03:04:08 && ip link set $net_interface2 up
if [ $? -ne 0 ]; then
    LogErr "unable to change mac"
    SetTestStateFailed
    exit 0
fi
after=$(sudo ip a show $net_interface2)
LogMsg "After mac change : $after"
SetTestStateCompleted
exit 0