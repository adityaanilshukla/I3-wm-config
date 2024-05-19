#!/bin/bash

# Path to the i3-restore script
I3_SAVE_SCRIPT=~/i3-restore/i3-save

# Save the session
$I3_SAVE_SCRIPT

# Send a notification
dunstify -i ~/.config/i3/icons/session-save.svg -t 1000 -r 2593 -u normal "Session Saved" "Your i3 session has been saved."
