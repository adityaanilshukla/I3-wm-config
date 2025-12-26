#!/usr/bin/env bash
set -euo pipefail

menu="$(
  pactl list sinks | awk '
    /^Sink #/ {
      if (name != "" && !skip) {
        print idx "\t" name "\t" desc
      }
      idx=$2; name=""; desc=""; skip=0
    }
    /^\tName: / {
      name=$2
      if (name == "combined") skip=1
    }
    /^\tDescription: / {
      sub(/^\tDescription: /,"")
      desc=$0
    }
    END {
      if (name != "" && !skip) {
        print idx "\t" name "\t" desc
      }
    }
  '
)"



choice="$(
  printf '%s\n' "$menu" | rofi -dmenu -i -p "Audio sink" -format 'i'
)"
[[ -z "${choice:-}" ]] && exit 0

selected_line="$(printf '%s\n' "$menu" | sed -n "$((choice+1))p")"
sink_name="$(printf '%s\n' "$selected_line" | awk -F'\t' '{print $2}')"

pactl set-default-sink "$sink_name"
