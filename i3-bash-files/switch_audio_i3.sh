#!/bin/bash

# Get the list of connected sinks
sinks=$(pactl list short sinks | awk '{print $2}')

# Define your audio devices by searching for known patterns
SPEAKER=$(echo "$sinks" | grep 'pci-0000_00_1f.3.analog-stereo')
HEADPHONES=$(echo "$sinks" | grep 'usb-Google_Realtek_USB2.0_Audio_201405280001-00.analog-stereo')

# Get the current default sink
CURRENT_SINK=$(pactl get-default-sink)

# Function to switch to the next audio sink
switch_sink() {
    local current=$1
    local next_sink=""
    for sink in $sinks; do
        if [ "$sink" != "$current" ]; then
            next_sink=$sink
            break
        fi
    done
    if [ -n "$next_sink" ]; then
        pactl set-default-sink "$next_sink"
        notify-send "Audio Output" "Switched to $next_sink"
    else
        notify-send "Audio Output" "No other sinks found to switch to."
    fi
}

# Switch to the next sink
switch_sink "$CURRENT_SINK"
