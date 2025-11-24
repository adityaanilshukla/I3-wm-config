#!/bin/bash

# Function to get the current volume level of the default sink
get_volume() {
  # Get the name of the default sink
  local default_sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')
  # Extract the volume level of the default sink from the pactl output
  local volume=$(pactl list sinks | awk -v sink="$default_sink" '/Name: /{sink_found = ($2 == sink)} sink_found && /Volume: / {print $5; exit}')
  # Remove the percentage sign from the volume level
  volume="${volume%\%}"

  # Check if volume exceeds 100% and limit it to 100% if necessary
  if ((volume > 100)); then
    volume=100
    # Set the sink volume to 100% to ensure it remains capped
    pactl set-sink-volume "$default_sink" 100%
  fi

  echo "$volume"
}

# Function to check if the audio is muted
is_muted() {
  # Get the name of the default sink
  local default_sink=$(pactl info | grep 'Default Sink' | awk '{print $3}')
  # Check if the default sink is muted using pactl
  pactl list sinks | awk -v sink="$default_sink" '/Name: /{sink_found = ($2 == sink)} sink_found && /Mute: / {if ($2 == "yes") exit 0; else exit 1}'
}

# Modify send_notification function to include a horizontal bar that represents the volume level
send_notification() {
  local volume=$(get_volume)
  local icon

  if is_muted; then
    icon="$HOME/.config/i3/icons/audio-volume-muted.svg"
  else
    icon="$HOME/.config/i3/icons/audio-volume-high.svg"
  fi

  # Create a horizontal bar that represents the volume level
  local bar=$(seq -s "─" 0 $((volume / 5)) | sed 's/[0-9]//g')
  # Add a space after the bar to separate it from the volume percentage
  bar+=" "

  dunstify -i "$icon" -t 1000 -r 2593 -u normal "Volume: $bar$volume%"

}

# Adjust the volume based on the command argument
case $1 in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    send_notification
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    send_notification
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification
    ;;
  *)
    echo "Usage: $0 {up|down|mute}"
    exit 1
    ;;
esac

exit 0
