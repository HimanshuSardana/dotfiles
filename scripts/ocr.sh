#!/bin/bash

tmpfile="/tmp/screenshot_$(date +%Y%m%d_%H%M%S).png"

FLAMESHOT_CMD="flameshot"

$FLAMESHOT_CMD gui -r -p "$tmpfile"

if [[ ! -f "$tmpfile" ]]; then
    notify-send "Screenshot canceled or failed"
    exit 1
fi

tesseract "$tmpfile" stdout -l eng --oem 3 --psm 6 | xclip -selection clipboard
rm "$tmpfile"
notify-send "Screenshot copied to clipboard"

