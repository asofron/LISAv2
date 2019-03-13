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

if ! GetSynthNetInterfaces; then
    LogErr "No synthetic network interfaces found"
    SetTestStateFailed
    exit 0
fi

net_interface=eth1
LogMsg "The network interface is $net_interface"

# Get the information of the link

LogMsg "Getting ksettings $net_interface.."
ksettings=$(ethtool $net_interface )
LogMsg "The link settings of $net_interface:"
LogMsg "$ksettings"

# TODO: Change the link settings with the below command when the diver supports the option in future. 
# ethtool --change eth0 speed xxx duplex yyy
# where xxx = N and yyy = half or full.
#LogMsg "setting mtu 1505 on  $net_interface"
#m1505=$(ip link set dev $net_interface mtu 1505)
#if [ ! $m1505 ]; then
#    LogErr "Failed to change MTU !"
#    SetTestStateFailed
#    exit 0
#fi
#LogMsg "setting mtu 2048 on  $net_interface"
#m2048=$(ip link set dev $net_interface mtu 2048)
#if [ ! $m2048 ]; then
#    LogErr "Failed to change MTU !"
#    SetTestStateFailed
#    exit 0
#fi
#LogMsg "setting mtu 4096 on  $net_interface"
#m4096=$(ip link set dev $net_interface mtu 4096)
#if [ ! $m4096 ]; then
#    LogErr "Failed to change MTU !"
#    SetTestStateFailed
#    exit 0
#fi

LogMsg "setting set to $netinterface"
prom=$(ip link set dev $netinterface promisc on)
if [ ! $prom ]; then
    LogErr "Failed to change MTU !"
    SetTestStateFailed
    exit 0
fi

LogMsg "Getting statistics with ethtool"
stats=$(ethtool -S $netinterface)
if [ ! $stats ]; then
    LogErr "Failed to change MTU !"
    SetTestStateFailed
    exit 0
else
    LogMsg "Stats : $stats"
fi
LogMsg "Changing mac to 02:01:02:03:04:08"
ip a show $netinterface
changemac=$(ip link set $netinterface down && ip link set $netinterface address 02:01:02:03:04:08 && ip link set $netinterface up)
if [ ! $change ]; then
    LogErr "unable to change mac"
    SetTestStateFailed
    exit 0
fi
ip a show $netinterface
SetTestStateCompleted
exit 0