#!/bin/bash
# Grab first, select second: the capture happens BEFORE any selection overlay
# exists, so the overlay can never end up in the saved image.
#
# Why not maim -s (or slop-then-maim): this system's GLX can't give slop a GL
# context, so slop runs software-rendered, and its selection overlay is a plain
# X window that shades the screen. maim grabbing after slop still catches that
# shade (picom hasn't repainted the area yet), so the PNG comes out dim.
#
# Instead: maim takes a clean full-screen shot, THEN slop asks for a region, then
# we crop the clean shot to that region. Bonus: the frame is frozen at the moment
# you press the key, so nothing shifts under you while you drag the selection.
set -o pipefail
tmp=$(mktemp --suffix=.png) || exit 1
trap 'rm -f "$tmp"' EXIT

maim "$tmp" || exit 1                       # clean full-screen grab, no overlay
geometry=$(slop -o -f '%g') || exit 1       # select region; non-zero = cancelled
magick "$tmp" -crop "$geometry" +repage png:- | xclip -selection clipboard -t image/png
