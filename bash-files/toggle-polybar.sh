#!/bin/bash

# Get the PID of Polybar
POLYBAR_PID=$(pgrep -x polybar)

# If Polybar is running, kill it
if [ ! -z "$POLYBAR_PID" ]; then
    killall -q polybar
else
    # Otherwise, launch Polybar
    polybar bar &
fi

