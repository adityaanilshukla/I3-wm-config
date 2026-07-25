#!/bin/sh
# Restart the whole PipeWire stack ($mod+Shift+p).
#
# This used to restart pipewire.service alone, which is not enough: pipewire-pulse
# and wireplumber keep running and stay attached to a server that just went away,
# so the shortcut could leave audio in a worse state than before it was pressed.
#
# Order matters. wireplumber (session manager) and pipewire-pulse (the PulseAudio
# compatibility layer) are clients of pipewire, so they are listed first and come
# back up against a freshly started server.
#
# Expect side effects: every sink is destroyed and re-created, so Bluetooth
# outputs disconnect and reconnect, the default sink may change, and each sink
# comes back at whatever volume wireplumber had stored for it. A restart taking
# the volume from 36% to 95% is that restore, not a bug.
systemctl --user restart wireplumber.service pipewire-pulse.service pipewire.service

# Confirm rather than assume; a silent failure here is indistinguishable from a
# silent success, and this shortcut only gets pressed when audio is already odd.
sleep 1
failed=$(systemctl --user is-active wireplumber.service pipewire-pulse.service pipewire.service \
         | grep -vc '^active$')

if [ "$failed" -eq 0 ]; then
  notify-send -t 2000 "PipeWire" "Audio stack restarted"
else
  notify-send -t 4000 -u critical "PipeWire" "$failed service(s) failed to restart"
fi
