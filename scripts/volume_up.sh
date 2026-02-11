#!/bin/bash
# Lower volume by 5% and notify

# Ensure PATH is set
export PATH=$PATH:/usr/bin:/bin

pactl set-sink-volume @DEFAULT_SINK@ +5%

VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1 | tr -d "%")
dunstify -a "volume" -u low -h int:value:$VOLUME -h string:x-dunst-stack-tag:volume \
    "Volume: ${VOLUME}%"

