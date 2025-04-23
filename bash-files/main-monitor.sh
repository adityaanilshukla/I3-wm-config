#!/bin/bash

# Path to images dir
images_path="$HOME/.config/i3/images"

# Detect internal display
INTERNAL_DISPLAY=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | cut -d' ' -f1)

# Detect external display that supports 3440x1440
EXTERNAL_DISPLAY=$(xrandr | grep " connected" | grep -vE "eDP|LVDS" | cut -d' ' -f1)

if [ -n "$EXTERNAL_DISPLAY" ]; then
    # First, set the external display to 3440x1440 explicitly
    xrandr --output "$EXTERNAL_DISPLAY" --mode 3440x1440 --rate 60 --primary

    # Then, turn off the internal laptop display
    if [ -n "$INTERNAL_DISPLAY" ]; then
        xrandr --output "$INTERNAL_DISPLAY" --off
    fi

    #set wallpaper fitting ultrawide resolution
    feh --bg-scale "$images_path/mountain.png"

else
    echo "No external display detected!"
    feh --bg-scale "$images_path/new-york-city-aerial-view-night-buildings.jpg"
    exit 1
fi
