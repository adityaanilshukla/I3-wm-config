#!/bin/bash

# External monitor brightness via DDC/CI (ddcutil), with a dunst HUD that
# mirrors volume.sh: Nerd Font glyph + native progress bar.
#
# Designed for low perceived latency:
#   - Tracks brightness in a cache file; only reads from the monitor once per
#     boot to seed it.
#   - Caches the i2c bus number so ddcutil can skip display detection on every
#     invocation (the dominant startup cost), addressing the bus directly via
#     --bus instead of --display.
#   - Shows the HUD immediately, dispatches ddcutil in the background.
#   - Uses --noverify and a tightened --sleep-multiplier; serializes concurrent
#     ddcutil invocations with flock so rapid keypresses don't collide on i2c.
#
# Targets ddcutil's first detected display by default. Override by exporting
# DDC_DISPLAY=N before invoking. To force a re-seed (e.g. after using the
# monitor's physical buttons), delete the cache file in /tmp.

STEP=10
DISPLAY_NUM=${DDC_DISPLAY:-1}
CACHE="/tmp/external-brightness-${DISPLAY_NUM}.value"
BUS_CACHE="/tmp/external-brightness-${DISPLAY_NUM}.bus"
LOCK="/tmp/external-brightness-${DISPLAY_NUM}.lock"

clamp() {
  local v=$1
  (( v < 0 )) && v=0
  (( v > 100 )) && v=100
  echo "$v"
}

send_notification() {
  local brightness=$1
  local glyph

  if   (( brightness < 34 )); then glyph="󰃞"
  elif (( brightness < 67 )); then glyph="󰃟"
  else                             glyph="󰃠"
  fi

  dunstify -t 1000 -r 2594 -u normal -h int:value:"$brightness" "$glyph  $brightness%"
}

# Seed the i2c bus number for the target display. Parses `ddcutil detect`
# output, finding the "Display N" block and extracting its "I2C bus" line.
seed_bus() {
  ddcutil detect --terse 2>/dev/null \
    | awk -v d="Display $DISPLAY_NUM" '
        $0 ~ "^"d"$" { in_block=1; next }
        in_block && /^Display / { in_block=0 }
        in_block && /I2C bus/ {
          # Line looks like:   I2C bus:  /dev/i2c-7
          n = $NF
          sub(/.*-/, "", n)
          print n
          exit
        }'
}

# Seed the cached current brightness via one synchronous read. Uses --bus once
# we have it; falls back to --display on the very first run.
seed_brightness() {
  local args=()
  if [[ -s $BUS_CACHE ]]; then
    args=(--bus "$(<"$BUS_CACHE")")
  else
    args=(--display "$DISPLAY_NUM")
  fi
  ddcutil "${args[@]}" --noverify --sleep-multiplier=0.1 \
    getvcp 10 --terse 2>/dev/null \
    | awk '/^VCP 10/ {print $4; exit}'
}

# Seed bus number once per boot.
if [[ ! -s $BUS_CACHE ]]; then
  bus=$(seed_bus)
  if [[ -z $bus ]]; then
    dunstify -t 1500 -r 2594 -u critical "Brightness" "ddcutil: no display $DISPLAY_NUM"
    exit 1
  fi
  echo "$bus" > "$BUS_CACHE"
fi
BUS=$(<"$BUS_CACHE")

# Seed brightness once per boot.
if [[ ! -s $CACHE ]]; then
  seed=$(seed_brightness)
  if [[ -z $seed ]]; then
    dunstify -t 1500 -r 2594 -u critical "Brightness" "ddcutil: read failed on bus $BUS"
    exit 1
  fi
  echo "$seed" > "$CACHE"
fi

current=$(<"$CACHE")

case $1 in
  up)   new=$(clamp $(( current + STEP ))) ;;
  down) new=$(clamp $(( current - STEP ))) ;;
  *)    echo "Usage: $0 {up|down}"; exit 1 ;;
esac

# Update cache and HUD immediately. ddcutil runs in the background so the user
# never waits on i2c.
echo "$new" > "$CACHE"
send_notification "$new"

if (( new != current )); then
  (
    flock 9
    ddcutil --bus "$BUS" --noverify --sleep-multiplier=0.1 \
      setvcp 10 "$new" >/dev/null 2>&1
  ) 9>"$LOCK" &
  disown
fi
