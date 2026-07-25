#!/bin/bash
# Single source of truth for the volume/brightness on-screen display.
#
# Sourced (not executed) by volume.sh, brightness.sh and external-brightness.sh
# so all three render identically on every machine. Each script used to carry
# its own copy of the dunstify call, which is how brightness.sh silently kept
# the pre-f6013a6 design after the other two were updated -- the laptop
# brightness popup drifted away from the desktop one and nobody noticed until
# the two were compared side by side.
#
# Requires:
#   - a Nerd Font for the glyphs (dunstrc asks for HackNerdFont-Regular)
#   - dunst >= 1.7 and progress_bar=true in dunstrc, for -h int:value:

HUD_TIMEOUT=1000

# dunst replace-ids. Distinct per category, so a brightness popup never replaces
# an in-flight volume popup. Identical within a category, so holding a key
# updates one popup in place instead of stacking a queue of them.
HUD_ID_VOLUME=2593
HUD_ID_BRIGHTNESS=2594

# Normalise to an integer in 0..100.
#
# dunstify rejects an empty or non-numeric progress value outright --
#   Malformed hint. Expected "type:name:value", got "int"
# -- and drops the whole notification. Since hud.sh is shared, a single failed
# upstream read (xbacklight missing, a pactl hiccup) would otherwise take out
# the on-screen display for every caller, not just the broken one.
hud__pct() {
  local v=$1
  # Drop any fractional part first. `xbacklight -get` prints "50.000000", and
  # merely stripping non-digits would turn that into 50000000.
  v=${v%%.*}
  v=${v//[^0-9-]/}
  [[ $v =~ ^-?[0-9]+$ ]] || v=0
  (( v < 0 )) && v=0
  (( v > 100 )) && v=100
  printf '%s' "$v"
}

# hud_volume <0-100> [muted]
hud_volume() {
  local v glyph
  v=$(hud__pct "$1")
  if   [[ ${2:-} == muted ]]; then glyph="󰝟"
  elif (( v < 34 ));         then glyph="󰕿"
  elif (( v < 67 ));         then glyph="󰖀"
  else                            glyph="󰕾"
  fi
  dunstify -t "$HUD_TIMEOUT" -r "$HUD_ID_VOLUME" -u normal \
           -h int:value:"$v" "$glyph  $v%"
}

# hud_brightness <0-100>
hud_brightness() {
  local v glyph
  v=$(hud__pct "$1")
  if   (( v < 34 )); then glyph="󰃞"
  elif (( v < 67 )); then glyph="󰃟"
  else                    glyph="󰃠"
  fi
  dunstify -t "$HUD_TIMEOUT" -r "$HUD_ID_BRIGHTNESS" -u normal \
           -h int:value:"$v" "$glyph  $v%"
}

# hud_error <title> <body> -- for the ddcutil failure paths.
hud_error() {
  dunstify -t 1500 -r "$HUD_ID_BRIGHTNESS" -u critical "$1" "$2"
}
