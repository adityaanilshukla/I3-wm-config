#!/bin/bash

# Define UUIDs and mountpoints
declare -A drives=(
  ["4C6E97526E973424"]="/mnt/Sanctuary"
  ["4C98-5E21"]="/home/aditya/Media/echoSD"
)

mount_drive() {
   local uuid=$1
   local mount_point=$2
   local password=$3

   if ! findmnt -U "$uuid" &>/dev/null; then
       echo $password | sudo -S mount -U "$uuid" "$mount_point" 2>/dev/null
       if [ $? -eq 0 ]; then
           echo "Mounted UUID=$uuid at $mount_point"
           notify-send "Drive Mounted" "Mounted UUID=$uuid at $mount_point"
       else
           echo "Failed to mount UUID=$uuid"
           notify-send "Mount Failed" "Failed to mount UUID=$uuid"
       fi
   else
       echo "Drive UUID=$uuid is already mounted."
       notify-send "Drive Already Mounted" "UUID=$uuid already mounted at $(findmnt -U "$uuid" -n -o TARGET)"
   fi
}

# Get sudo password
PASSWORD=$(zenity --password --title="Authentication Required")

if [ -n "$PASSWORD" ]; then
   for uuid in "${!drives[@]}"; do
       mount_drive "$uuid" "${drives[$uuid]}" "$PASSWORD"
   done
else
   notify-send "No Password Entered" "Operation cancelled."
fi
