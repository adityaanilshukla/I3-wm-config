#!/bin/bash

# Function to get the current brightness level
get_brightness() {

  # Get brightness using xbacklight and store it in the brightness variable
  brightness=$(xbacklight -get)

  #convert the brightness to an integer
  brightness=${brightness%.*}

  # Print out the brightness level to the console
  echo "$brightness"
}

# Function to send a notification with brightness level
send_notification() {
  local brightness=$(get_brightness)
  local icon="/usr/share/icons/breeze/actions/22/high-brightness.svg"

  # create a horizontal bar to represent the brightness level
  local bar=$(seq -s "─" $(($brightness / 5)) | sed 's/[0-9]//g')
  #add a space after the bar
  bar="$bar "

  #notification params
  dunstify -i "$icon" -t 1000 -r 2593 -u normal "Brighness: $bar$brightness%"
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
