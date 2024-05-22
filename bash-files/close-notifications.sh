#!/bin/bash

# Try to close all notifications using dunstctl
if command -v dunstctl &> /dev/null; then
    echo "dunstctl is available. Attempting to close all notifications..."
    dunstctl close-all
    if [ $? -eq 0 ]; then
        echo "Successfully closed all notifications."
    else
        echo "Failed to close notifications using dunstctl."
    fi
else
    echo "dunstctl is not installed. Falling back to sending SIGUSR1..."
    # Kill dunst notifications by sending SIGUSR1
    pkill -SIGUSR1 dunst
    if [ $? -eq 0 ]; then
        echo "Successfully sent SIGUSR1 to Dunst."
    else
        echo "Failed to send SIGUSR1. Dunst may not be running."
    fi
fi
