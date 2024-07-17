#!/bin/bash

# Activate the laptop screen and set it as primary
xrandr --output eDP1 --auto --primary

# List all connected monitors except for eDP1 and disable them
xrandr | grep ' connected' | cut -d' ' -f1 | grep -v eDP1 | while read MONITOR
do
    xrandr --output $MONITOR --off
done
