#!/bin/bash

#Launch telegram in workspace 1
exec --no-startup-id i3-msg 'workspace 1:Chat; exec /usr/bin/telegram-desktop'

# #Launch Firefox in workspace 2
# exec --no-startup-id i3-msg 'workspace 2:Web; exec /usr/bin/firefox'
#
# #Launch Kitty in workspace 3
# exec --no-startup-id i3-msg 'workspace 3:Terminal; exec /usr/bin/kitty'
#
# #Launch Nautilus in workspace 4
# exec --no-startup-id i3-msg 'workspace 4:Files; exec /usr/bin/nautilus'
