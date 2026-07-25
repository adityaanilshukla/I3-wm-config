#!/bin/bash

# Shared on-screen display, so volume and both brightness paths render the same
# way on every machine. See hud.sh.
source "$(dirname "$0")/hud.sh"

# Current volume of the default sink, as a bare integer.
#
# This used to run `pactl info` to find the default sink name, then
# `pactl list sinks` -- which prints every property of every sink -- and pick one
# line out of the flood with awk. get_volume and is_muted did that separately, so
# a single volume keypress spawned four pactl processes and two full property
# dumps. `pactl get-sink-volume` asks the server for exactly this one value and
# understands the @DEFAULT_SINK@ alias, so no lookup is needed either.
get_volume() {
  local volume
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk 'NR==1 {print $5+0; exit}')
  echo "${volume:-0}"
}

# Exit 0 when the default sink is muted, matching the old awk-exit-code contract.
is_muted() {
  [[ $(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}') == yes ]]
}

send_notification() {
  local volume muted=""
  volume=$(get_volume)
  is_muted && muted=muted
  hud_volume "$volume" "$muted"
}

# Adjust the volume based on the command argument
case $1 in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    # Keep the 100% ceiling. This used to live inside get_volume, so a function
    # that reads the volume also wrote to the sink; it belongs on the only path
    # that can exceed the ceiling.
    (( $(get_volume) > 100 )) && pactl set-sink-volume @DEFAULT_SINK@ 100%
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
