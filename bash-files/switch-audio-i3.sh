#!/bin/bash

# Get the list of connected sinks
sinks=$(pactl list short sinks | awk '{print $2}')

# Define your audio devices by searching for known patterns
SPEAKER=$(echo "$sinks" | grep 'pci-0000_00_1f.3.analog-stereo')
HEADPHONES=$(echo "$sinks" | grep 'usb-Google_Realtek_USB2.0_Audio_201405280001-00.analog-stereo')

# Function to send a notification with the sound output device icon
send_notification() {
    local current_sink=$1
    local icon

    if [ "$current_sink" == "$SPEAKER" ]; then
        icon="$HOME/.config/i3/icons/computer-laptop.svg"
        dunstify -i "$icon" -t 1000 -r 2593 -u normal "Audio output switched to: Laptop Speaker"
    elif [ "$current_sink" == "$HEADPHONES" ]; then
        icon="$HOME/.config/i3/icons/audio-headphones.svg"
        dunstify -i "$icon" -t 1000 -r 2593 -u normal "Audio output switched to: Headphones"
    else
        dunstify -t 1000 -r 2593 -u normal "Audio Output" "No other sinks found to switch to."
    fi
}

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
        send_notification "$next_sink"
    else
        send_notification
    fi
}

# Get the current default sink
CURRENT_SINK=$(pactl get-default-sink)

# Switch to the next sink
switch_sink "$CURRENT_SINK"
