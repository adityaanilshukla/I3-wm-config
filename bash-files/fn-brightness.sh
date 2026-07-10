#!/bin/bash

# Unified brightness control for the F1/F2 (and XF86MonBrightness*) keys.
#
# Controls the laptop's own backlight when one is present (via xbacklight,
# through brightness.sh); otherwise falls back to the external monitor over
# DDC/CI (via external-brightness.sh). This lets the same keybinding work
# unmodified on a laptop and on a desktop driving an external display.
#
# The routing decision (laptop panel vs external monitor) is cached after the
# first run so key-repeat bursts don't each pay for an xrandr round-trip to
# the X server. Delete the cache (or reboot) to re-detect, e.g. after
# docking/undocking a laptop.

SCRIPT_DIR="$(dirname "$0")"
ROUTE_CACHE="/tmp/fn-brightness.route"

if [[ ! -s $ROUTE_CACHE ]]; then
  INTERNAL_DISPLAY=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | cut -d' ' -f1)
  if [[ -n "$INTERNAL_DISPLAY" ]] && command -v xbacklight >/dev/null 2>&1; then
    echo internal > "$ROUTE_CACHE"
  else
    echo external > "$ROUTE_CACHE"
  fi
fi

if [[ "$(<"$ROUTE_CACHE")" == internal ]]; then
  exec "$SCRIPT_DIR/brightness.sh" "$1"
else
  exec "$SCRIPT_DIR/external-brightness.sh" "$1"
fi
