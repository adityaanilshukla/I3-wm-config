#!/bin/bash
# Script to determine if the active network connection is via Ethernet or WiFi

# Get the default route's interface
interface=$(ip route show default | awk '{print $5}' | head -n 1)

# Determine the type of connection based on the interface name
if [[ "$interface" == "enp"* ]]; then
    echo "Connected via Ethernet."
elif [[ "$interface" == "wlan"* ]]; then
    echo "Connected via WiFi."
else
    echo "Active connection interface: $interface"
fi
