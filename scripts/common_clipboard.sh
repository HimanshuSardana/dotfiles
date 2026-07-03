#!/usr/bin/env bash

CSV_FILE="/home/himanshu/dotfiles/scripts/clipboard.csv"

selection=$(
    cut -d',' -f1 "$CSV_FILE" |
    rofi -dmenu -p "Select"
)

# Exit if cancelled
[ -z "$selection" ] && exit 0

# Find corresponding value (second column)
value=$(
    awk -F',' -v key="$selection" '$1 == key {print $2; exit}' "$CSV_FILE"
)

[ -z "$value" ] && exit 1

printf "%s" "$value" | xclip -selection clipboard

notify-send "Copied" "$selection copied to clipboard"
