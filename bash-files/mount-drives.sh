#!/bin/bash

# Define UUIDs and mountpoints
declare -A drives=(
  ["4C6E97526E973424"]="/mnt/Sanctuary"
  ["19FA-1B58"]="/home/aditya/Media/echoSD"
)

mount_drive() {
  local uuid=$1
  local mount_point=$2
  local password=$3

  # ensure mountpoint exists
  mkdir -p "$mount_point"

  # don't try to mount if already mounted
  if ! findmnt -U "$uuid" &>/dev/null; then
    # compute uid/gid of the invoking user (not root)
    local user_uid user_gid
    user_uid=$(id -u)
    user_gid=$(id -g)

    # mount with explicit ownership options; pass password to sudo
    echo "$password" | sudo -S mount -U "$uuid" -o "uid=${user_uid},gid=${user_gid},umask=0022" "$mount_point" 2>/tmp/mount-err.txt
    if [ $? -eq 0 ]; then
      # fallback: try to chown the mountpoint (no harm if FS doesn't support it)
      echo "$password" | sudo -S chown -R "${user_uid}:${user_gid}" "$mount_point" &>/dev/null || true

      echo "Mounted UUID=$uuid at $mount_point"
      notify-send "Drive Mounted" "Mounted UUID=$uuid at $mount_point"
    else
      # capture error message and show notification
      local err
      err=$(</tmp/mount-err.txt)
      rm -f /tmp/mount-err.txt
      echo "Failed to mount UUID=$uuid: $err"
      notify-send "Mount Failed" "Failed to mount UUID=$uuid"
    fi
  else
    echo "Drive UUID=$uuid is already mounted."
    notify-send "Drive Already Mounted" "UUID=$uuid already mounted at $(findmnt -U "$uuid" -n -o TARGET)"
  fi
}

# Get sudo password (graphical)
PASSWORD=$(zenity --password --title="Authentication Required")

if [ -n "$PASSWORD" ]; then
  for uuid in "${!drives[@]}"; do
    mount_drive "$uuid" "${drives[$uuid]}" "$PASSWORD"
  done
else
  notify-send "No Password Entered" "Operation cancelled."
fi
