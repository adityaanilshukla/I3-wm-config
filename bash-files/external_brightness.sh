#!/bin/bash

# Get the name of the focused display
display_name=$(
    swaymsg -t get_outputs |
    jq '.[] | select(.focused) | .name' --raw-output)

echo "Focused Display: $display_name"

# Use ddcutil to adjust brightness by I2C bus or display name
# Replace "--sn" with "--bus" or use "--display" if you are identifying by name
ddcutil --display "$display_name" setvcp 10 $@
