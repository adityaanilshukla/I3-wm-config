#!/bin/bash

# Define UUIDs for drives
uuids=("4C6E97526E973424")

# Function to check and display drive status
check_drive() {
  local uuid=$1

  # Check if the drive is present using blkid
  if sudo blkid /dev/disk/by-uuid/"$uuid" &>/dev/null; then
    # Check if the drive is mounted using mount command
    local mount_point=$(sudo mount | grep -E "/dev/disk/by-uuid/$uuid\s+on\s+(\w+)" | awk '{print $3}')
    if [[ -n "$mount_point" ]]; then
      echo "Mounted UUID=$uuid at $mount_point"
      notify-send "Drive Mounted" "Successfully mounted UUID=$uuid at $mount_point"
    else
      echo "Drive with UUID=$uuid found, but not mounted."
      notify-send "Drive Not Mounted" "Drive with UUID=$uuid found, but not mounted. Requires sudo to mount."
    fi
  else
    echo "No drive with UUID=$uuid found"
    notify-send "Drive Not Found" "No drive with UUID=$uuid found"
  fi
}

# Iterate over UUIDs and check each drive
for uuid in "${uuids[@]}"; do
  check_drive "$uuid"
done

