#!/bin/bash

# Define UUIDs for drives
uuids=("4C6E97526E973424") # Add your drive UUIDs here

mount_drive() {
   local uuid=$1
   local password=$2

   # Define mount point
   local mount_point="/mnt/Sanctuary"

   # Check if the drive is already mounted
   if ! findmnt -U "$uuid" &>/dev/null; then
       # Attempt to mount the drive using echo to pass the password to sudo
       echo $password | sudo -S mount -U "$uuid" "$mount_point" 2>/dev/null
       if [ $? -eq 0 ]; then
           echo "Mounted UUID=$uuid at $mount_point"
           notify-send "Drive Mounted" "Successfully mounted UUID=$uuid at $mount_point"
       else
           echo "Failed to mount UUID=$uuid"
           notify-send "Mount Failed" "Failed to mount UUID=$uuid"
       fi
   else
       echo "Drive UUID=$uuid is already mounted."
       notify-send "Drive Already Mounted" "Drive UUID=$uuid is already mounted at $(findmnt -U "$uuid" -n -o TARGET)"
   fi
}

# Set GTK theme to Adwaita:dark
export GTK_THEME="Adwaita:dark"

# Prompt for the sudo password
PASSWORD=$(zenity --password --title="Authentication Required")

# Check if password was entered
if [ -n "$PASSWORD" ]; then
   # Iterate over UUIDs and mount each drive
   for uuid in "${uuids[@]}"; do
       mount_drive "$uuid" "$PASSWORD"
   done
else
   notify-send "No Password Entered" "Operation cancelled by user."
fi
