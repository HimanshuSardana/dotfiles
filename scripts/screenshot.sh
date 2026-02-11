#!/bin/bash
# screenshot.sh - Rofi-powered screenshot utility (fixed)

mode=$(echo -e "Full Screen\nSelect Area" | rofi -dmenu -i -p "Screenshot mode:")
[[ -z "$mode" ]] && exit 0

tmpfile="/tmp/screenshot_$(date +%Y%m%d_%H%M%S).png"

FLAMESHOT_CMD="flameshot"

if [[ "$mode" == "Full Screen" ]]; then
    $FLAMESHOT_CMD full -p "$tmpfile"
else
    $FLAMESHOT_CMD gui -r -p "$tmpfile"
fi

if [[ ! -f "$tmpfile" ]]; then
    notify-send "Screenshot canceled or failed"
    exit 1
fi

action=$(echo -e "Save to Disk\nCopy to Clipboard" | rofi -dmenu -i -p "Action:")
[[ -z "$action" ]] && { rm "$tmpfile"; exit 0; }

if [[ "$action" == "Save to Disk" ]]; then
    save_path="$HOME/personal/pix/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"
    mv "$tmpfile" "$save_path"
    notify-send "Screenshot saved" "$save_path"
else
    xclip -selection clipboard -t image/png < "$tmpfile"
    rm "$tmpfile"
    notify-send "Screenshot copied to clipboard"
fi

