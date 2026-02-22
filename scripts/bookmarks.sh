#!/bin/bash

FILE="$HOME/dotfiles/scripts/bookmarks.csv"

if [[ ! -f "$FILE" ]]; then
    echo "Bookmarks file not found: $FILE"
    exit 1
fi

selection=$(tail -n +2 "$FILE" | cut -d',' -f1 | rofi -dmenu -i -p "Bookmarks")

[[ -z "$selection" ]] && exit 0

url=$(awk -F',' -v name="$selection" '$1 == name {print $2}' "$FILE")

[[ -n "$url" ]] && xdg-open "$url"
