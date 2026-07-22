#!/usr/bin/env bash
set -euo pipefail

# rofi picker for the default PulseAudio sink. Each sink's Description
# gets a short, human label; the full Name is kept alongside so we can
# pass it to `pactl set-default-sink`.

mapfile -t rows < <(
  pactl list sinks | awk '
    /^Sink #/          { name=""; desc="" }
    /^\tName: /        { name=$2 }
    /^\tDescription: / {
      sub(/^\tDescription: /, ""); desc=$0
      if (name != "" && name != "combined") print name "\t" desc
    }
  '
)

[[ ${#rows[@]} -eq 0 ]] && exit 0

prettify() {
  local d="$1"
  d="${d// Digital Stereo/}"
  d="${d// Analog Stereo/}"
  d="${d// Analog Mono/}"
  d="${d// Stereo/}"
  d="${d/USB-C to 3.5mm Headphone Jack Adapter/Apple Jack Adapter}"
  d="${d/Built-in Audio Pro/Speakers}"
  if [[ "$d" == *"(HDMI)"* ]]; then d="HDMI"; fi
  d="$(printf '%s' "$d" | tr -s ' ')"
  d="${d# }"; d="${d% }"
  printf '%s' "$d"
}

names=()
labels=()
for row in "${rows[@]}"; do
  IFS=$'\t' read -r n d <<<"$row"
  names+=("$n")
  labels+=("$(prettify "$d")")
done

idx="$(printf '%s\n' "${labels[@]}" | rofi -dmenu -i -p "Audio sink" -format 'i')"
[[ -z "${idx:-}" ]] && exit 0

pactl set-default-sink "${names[$idx]}"
