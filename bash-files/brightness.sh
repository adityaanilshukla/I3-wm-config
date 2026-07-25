#!/bin/bash

# Shared on-screen display, so the laptop backlight path renders identically to
# the external-monitor path and to volume.sh. See hud.sh. Before this, the
# dunstify call was inlined here and still used the pre-f6013a6 design.
source "$(dirname "$0")/hud.sh"

# Function to get the current brightness level
get_brightness() {

  # Get brightness using xbacklight and store it in the brightness variable
  brightness=$(xbacklight -get)

  #convert the brightness to an integer
  brightness=${brightness%.*}

  # Print out the brightness level to the console
  echo "$brightness"
}

send_notification() {
  hud_brightness "$(get_brightness)"
}

# Adjust the brightness based on the command argument
case $1 in
  up)
    xbacklight -inc 10
    # enforce minimum brightness of 5%
    curr=$(get_brightness)
    if [ "$curr" -lt 5 ]; then
      xbacklight -set 5
    fi
    send_notification
    ;;
  down)
    xbacklight -dec 10
    # enforce minimum brightness of 1%
    curr=$(get_brightness)
    if [ "$curr" -lt 1 ]; then
      xbacklight -set 1
    fi
    send_notification
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac

exit 0
