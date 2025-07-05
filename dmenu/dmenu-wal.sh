#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Launch nsxiv in thumbnail mode and capture the selected file
SELECTED=$(nsxiv -t "$WALLPAPER_DIR" | head -n 1)

# If user selected an image and didn't cancel
[ -n "$SELECTED" ] && wal -i "$SELECTED"

