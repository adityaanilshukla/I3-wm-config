#!/bin/bash

# Define UUIDs for drives
uuids=("4C6E97526E973424")

# Function to mount a drive
mount_drive() {
    local uuid=$1

    # Check if the drive is already mounted
    if udisksctl info --block-device "/dev/disk/by-uuid/$uuid" &>/dev/null; then
        # Attempt to mount the drive
        local mount_output=$(udisksctl mount --block-device "/dev/disk/by-uuid/$uuid" --no-user-interaction 2>&1)
        if [[ $mount_output == *"mounted at"* ]]; then
            local mount_point=$(echo $mount_output | sed -n 's/.*mounted at \(.*\)\./\1/p')
            echo "Mounted UUID=$uuid at $mount_point"
            notify-send "Drive Mounted" "Successfully mounted UUID=$uuid at $mount_point"
        else
            echo "Failed to mount UUID=$uuid"
            notify-send "Mount Failed" "Failed to mount UUID=$uuid"
        fi
    else
        echo "No drive with UUID=$uuid found"
        notify-send "Drive Not Found" "No drive with UUID=$uuid found"
    fi
}

# Iterate over UUIDs and mount each drive
for uuid in "${uuids[@]}"; do
    mount_drive "$uuid"
done
