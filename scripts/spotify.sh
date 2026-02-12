#!/usr/bin/env bash

PLAYER="spotify"

# Get current track info
CURRENT=$(playerctl -p "$PLAYER" metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)

# If nothing is playing
if [ -z "$CURRENT" ]; then
    CURRENT="Nothing playing"
fi

# Rofi menu options
OPTIONS="▶ Play/Pause
⏭ Next
⏮ Previous
  Shuffle
󰑖  Loop
󰎇  Now Playing: $CURRENT"

# Show rofi menu
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Spotify")

case "$CHOICE" in
    "▶ Play/Pause")
        playerctl -p "$PLAYER" play-pause
        ;;
    "⏭ Next")
        playerctl -p "$PLAYER" next
        ;;
    "⏮ Previous")
        playerctl -p "$PLAYER" previous
        ;;
    "🔁 Shuffle")
        playerctl -p "$PLAYER" shuffle Toggle
        ;;
    "🔂 Loop")
        playerctl -p "$PLAYER" loop Toggle
        ;;
esac
