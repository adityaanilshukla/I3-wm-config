#!/bin/bash

# Activate the laptop screen and set it as primary
# xrandr --output eDP1 --auto --primary
#
# # List all connected monitors except for eDP1 and disable them
# xrandr | grep ' connected' | cut -d' ' -f1 | grep -v eDP1 | while read MONITOR
# do
#     xrandr --output $MONITOR --off
# done
#

# Dynamically detect the laptop's internal display (usually named eDP-1, eDP1, LVDS-1, etc.)
INTERNAL_DISPLAY=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | cut -d' ' -f1)

# If no internal display was found, just exit safely
if [ -z "$INTERNAL_DISPLAY" ]; then
    echo "No internal display detected!"
    exit 1
fi

# Activate the laptop screen and set it as primary
xrandr --output "$INTERNAL_DISPLAY" --auto --primary

# List all connected monitors except the internal one and disable them
xrandr | grep ' connected' | cut -d' ' -f1 | grep -v "^$INTERNAL_DISPLAY\$" | while read MONITOR
do
    xrandr --output "$MONITOR" --off
done
