#!/usr/bin/env bash

WALL_DIR="/home/himanshu/personal/pix/walls"

find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) |
while read -r img; do
    printf "%s\x00icon\x1f%s\n" "$(basename "$img")" "$img"
done | rofi -dmenu -i -show-icons -p "Wallpapers" | while read -r choice; do
    xwallpaper --zoom "$WALL_DIR/$choice"
done
