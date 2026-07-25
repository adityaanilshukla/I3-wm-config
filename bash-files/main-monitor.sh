#!/usr/bin/env bash
# Put the display into its preferred layout and set a matching wallpaper.
#
# Policy: if any external monitor is connected, drive the externals and switch
# the laptop panel off; otherwise use the laptop panel. That is the docked-desk
# behaviour this setup has always had.
#
# Rewritten because the previous version had two failure modes:
#
#   1. It collected output names with `cut`, which yields a MULTI-LINE string
#      when more than one external is connected. `xrandr --output "$EXTERNAL"`
#      then received a name with an embedded newline and failed outright, so
#      plugging in a second monitor broke the whole script.
#
#   2. It hardcoded `--mode 3440x1440 --rate 60`. That is brovo's ultrawide and
#      nothing else, so on a laptop docked to any other monitor xrandr failed
#      with "cannot find mode". --auto picks each output's preferred (native)
#      mode, which is what 3440x1440 was on brovo anyway.
#
# It is also idempotent now: i3 runs this via exec_always, so it fires on every
# config reload. It used to re-run xrandr and re-set the wallpaper every time,
# causing a visible flicker for a layout that only changes on hotplug.
#
# Usage:
#   main-monitor.sh              # apply
#   DRY_RUN=1 main-monitor.sh    # print the xrandr commands, change nothing

set -uo pipefail

IMAGES="${IMAGES:-$HOME/.config/i3/images}"
WALLPAPER_EXTERNAL="${WALLPAPER_EXTERNAL:-$IMAGES/mountain.png}"
WALLPAPER_INTERNAL="${WALLPAPER_INTERNAL:-$IMAGES/new-york-city-aerial-view-night-buildings.jpg}"
DRY_RUN="${DRY_RUN:-0}"

log() { printf '  %s\n' "$*"; }
run() { if [[ $DRY_RUN == 1 ]]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

command -v xrandr >/dev/null 2>&1 || { echo "xrandr not found" >&2; exit 1; }

# Read connected outputs into arrays -- one element per output, so a second
# monitor cannot smuggle a newline into an xrandr argument.
mapfile -t CONNECTED < <(xrandr | awk '/ connected/ {print $1}')
INTERNAL=(); EXTERNAL=()
for o in "${CONNECTED[@]}"; do
  case "$o" in
    eDP*|LVDS*|DSI*) INTERNAL+=("$o") ;;
    *)               EXTERNAL+=("$o") ;;
  esac
done

# Outputs currently driving a CRTC, i.e. actually on. Used to decide whether
# there is anything to do.
mapfile -t ACTIVE < <(xrandr | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}')
is_active() { local n=$1 a; for a in "${ACTIVE[@]}"; do [[ $a == "$n" ]] && return 0; done; return 1; }

set_wallpaper() {
  local img=$1
  command -v feh >/dev/null 2>&1 || { log "feh not installed, skipping wallpaper"; return; }
  [[ -f $img ]] || { log "wallpaper missing: $img"; return; }
  run feh --bg-scale "$img"
}

if (( ${#EXTERNAL[@]} > 0 )); then
  log "external: ${EXTERNAL[*]}"
  (( ${#INTERNAL[@]} > 0 )) && log "internal: ${INTERNAL[*]} (will be switched off)"

  # Already in the desired state? Every external on, every internal off.
  desired=1
  for o in "${EXTERNAL[@]}";  do is_active "$o" || desired=0; done
  for o in "${INTERNAL[@]}"; do is_active "$o" && desired=0; done
  if (( desired == 1 )) && [[ $DRY_RUN != 1 ]]; then
    log "already in the desired layout, leaving xrandr alone"
  else
    # Build one xrandr call so the change is atomic: a sequence of separate
    # calls can leave no output enabled part-way through, which blanks the screen.
    args=(); prev=""
    for o in "${EXTERNAL[@]}"; do
      args+=(--output "$o" --auto)
      if [[ -z $prev ]]; then args+=(--primary); else args+=(--right-of "$prev"); fi
      prev="$o"
    done
    for o in "${INTERNAL[@]}"; do args+=(--output "$o" --off); done
    run xrandr "${args[@]}"
  fi
  set_wallpaper "$WALLPAPER_EXTERNAL"
else
  # No external monitor. This is the normal state of a laptop, not an error --
  # the old script exited 1 here, which made it look like a failure in logs.
  log "no external monitor; using ${INTERNAL[*]:-the current output}"
  for o in "${INTERNAL[@]}"; do is_active "$o" || run xrandr --output "$o" --auto --primary; done
  set_wallpaper "$WALLPAPER_INTERNAL"
fi
