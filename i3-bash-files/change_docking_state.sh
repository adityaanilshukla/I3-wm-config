#!/bin/bash

# Get the number of connected monitors
connected_monitors=$(xrandr | grep " connected" | wc -l)

# Define the autorandr profile names
docked_profile="docked"
undocked_profile="undocked"

# Apply the appropriate profile based on the number of connected monitors
if [ "$connected_monitors" -eq 1 ]; then
    autorandr --load $undocked_profile
elif [ "$connected_monitors" -gt 1 ]; then
    autorandr --load $docked_profile
else
    echo "No display configuration could be determined."
fi
