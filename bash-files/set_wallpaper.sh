#!/bin/bash

# Path to your images
images_path="$HOME/.config/i3/images"

# Get the resolution of the connected monitor(s)
resolution=$(xrandr --query | grep '*' | awk '{print $1}' | head -n 1)

# Set wallpaper based on resolution
if [ "$resolution" = "3440x1440" ]; then
    feh --bg-scale "$images_path/beach-side.png"
    # feh --bg-scale "$images_path/mdwvu944s6j61.png"
else
    feh --bg-scale "$images_path/new-york-city-aerial-view-night-buildings.jpg"
fi
