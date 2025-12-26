#!/bin/bash

SCRIPTS_DIR=~/Scripts

selected=$(ls "$SCRIPTS_DIR" | rofi -dmenu -i -p "Run")
[ -n "$selected" ] && bash "$SCRIPTS_DIR/$selected"
