#!/usr/bin/env bash

output=$(sxcs --one-shot) || exit 1

hex=$(echo "$output" | grep -oP '(?<=hex:\t)#?[0-9A-Fa-f]{6}')
rgb=$(echo "$output" | grep -oP '(?<=rgb:\t)[0-9 ]+')
hsl=$(echo "$output" | grep -oP '(?<=hsl:\t)[0-9 ]+')

choice=$(
printf "HEX\t%s\nRGB\trgb(%s)\nHSL\thsl(%s)\n" \
    "$hex" \
    "$(echo "$rgb" | xargs | sed 's/ /, /g')" \
    "$(echo "$hsl" | xargs | sed 's/ /, /g;s/$/%)/;s/, /, /2;s/, /%, /3')" |
rofi -dmenu -display-columns 1,2 -p "Copy color"
)

[ -z "$choice" ] && exit 1

cut -f2 <<< "$choice" | xclip -selection clipboard
