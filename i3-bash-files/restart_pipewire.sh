#!/bin/sh

# Restart pipewire user service
systemctl --user restart pipewire.service

# Optional: Exit script with success code (0)
exit 0
