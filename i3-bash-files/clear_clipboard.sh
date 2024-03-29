#!/bin/bash

# Terminate greenclip if it's running
pkill greenclip

# Clear the clipboard history
greenclip clear

# Restart greenclip daemon
greenclip daemon &
