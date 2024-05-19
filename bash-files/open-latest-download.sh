#!/bin/bash

# Specify the Downloads directory path
DOWNLOAD_DIR="$HOME/Downloads"

# Find the most recently modified file and open it
latest_file=$(find "$DOWNLOAD_DIR" -type f -printf '%T+ %p\n' | sort -r | head -n1 | cut -d' ' -f2-)
xdg-open "$latest_file"
