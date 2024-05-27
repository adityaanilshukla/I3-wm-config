#!/bin/bash

# Get the number of connected monitors
connected_monitors=$(xrandr | grep " connected" | wc -l)

# Define the autorandr profile names
main_monitor_profile="Mainmonitor_only"

# Apply the main monitor profile only if more than one monitor is connected
if [ "$connected_monitors" -gt 1 ]; then
    autorandr --load $main_monitor_profile
else
    echo "Only one or no monitor detected, no action taken."
fi
