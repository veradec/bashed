#!/bin/bash

# Hardcoded path to image(s)
IMAGE_PATH="/home/san/pix/wal/"

# Create a named pipe
PIPE=$(mktemp -u)
mkfifo "$PIPE"

if [[ "$1" == "r" || "$1" == "--r" || "$1" == "--random" || "$1" == '-r' || "$1" == "rand" ]]; then
	SELECTED_PIC="$(ls "$IMAGE_PATH" | sort -R | head -n 1)"
	wal -i "$IMAGE_PATH/$SELECTED_PIC"
	swww img "$IMAGE_PATH/$SELECTED_PIC"
else


# Launch imv and redirect output
imv "$IMAGE_PATH" >"$PIPE" 2>/dev/null &
IMV_PID=$!

# Read one line from imv output
if IFS= read -r line < "$PIPE"; then
    if [[ -f "$line" ]]; then
        echo "Resultant Path: $line"

        # Kill imv
        kill "$IMV_PID" 2>/dev/null

        # Run pywal on the selected image
        wal -i "$line"

        # Set wallpaper with swww (Hyprland compatible)
        swww img "$line"
    fi
fi

# Clean up pipe
rm -f "$PIPE"

fi

pkill waybar
nohup waybar >/dev/null 2>&1 &

