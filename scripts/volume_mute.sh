#!/bin/bash
# Toggle mute and notify

export PATH=$PATH:/usr/bin:/bin

pactl set-sink-mute @DEFAULT_SINK@ toggle

MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [[ "$MUTE" == "yes" ]]; then
    dunstify -a "volume" -u low -h string:x-dunst-stack-tag:volume "Muted"
else
    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1 | tr -d "%")
    dunstify -a "volume" -u low -h int:value:$VOLUME -h string:x-dunst-stack-tag:volume \
        "Volume: ${VOLUME}%"
fi
