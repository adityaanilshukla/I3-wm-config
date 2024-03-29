#!/bin/bash

# Check if any media is currently playing
if playerctl status | grep -q "Playing"; then
    # If playing, pause the media
    playerctl pause
else
    # If paused or stopped, resume playback
    playerctl play
fi
