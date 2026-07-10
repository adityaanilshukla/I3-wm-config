#!/bin/bash
# -o/--noopengl: this system's GLX setup can't give slop (maim -s's region
# selector) a context, so plain `maim -s` crashes instantly instead of
# showing the selection crosshair. Software-rendering the overlay avoids it.
maim -s -o | xclip -selection clipboard -t image/png
