#!/bin/sh
# Check if Obsidian is installed and launch it
if command -v obsidian >/dev/null 2>&1; then
    obsidian
else
    echo "Obsidian is not installed. Please install it first."
fi
