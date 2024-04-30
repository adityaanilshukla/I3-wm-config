#!/bin/bash

# Define associative arrays for UUIDs and their corresponding mount points
declare -A uuids=( ["4C6E97526E973424"]="/mnt/Sanctuary")

# Function to mount a drive
mount_drive() {
    local uuid=$1
    local mount_point=$2

    # Ensure the mount point exists
    mkdir -p "$mount_point"

    # Use udisksctl to mount the drive
    if udisksctl info --block-device "/dev/disk/by-uuid/$uuid" &>/dev/null; then
        if mount | grep -q "on ${mount_point} type"; then
            echo "Drive already mounted on ${mount_point}"
            notify-send "Drive Mounted" "Drive with UUID=$uuid is already mounted at $mount_point"
        else
            if udisksctl mount --block-device "/dev/disk/by-uuid/$uuid" --no-user-interaction; then
                echo "Mounted UUID=$uuid at $mount_point"
                notify-send "Drive Mounted" "Successfully mounted UUID=$uuid at $mount_point"
            else
                echo "Failed to mount UUID=$uuid at $mount_point"
                notify-send "Mount Failed" "Failed to mount UUID=$uuid at $mount_point"
            fi
        fi
    else
        echo "No drive with UUID=$uuid found"
        notify-send "Drive Not Found" "No drive with UUID=$uuid found"
    fi
}

# Iterate over UUIDs and mount each drive
for uuid in "${!uuids[@]}"; do
    mount_drive "$uuid" "${uuids[$uuid]}"
done
