#!/bin/bash

SAVE_DIR="/home/himanshu/personal/vids"
mkdir -p "$SAVE_DIR"

# Check if recording is already running
if pgrep -x ffmpeg > /dev/null; then
    OPTIONS="Stop Recording"
else
    OPTIONS="Start (With Audio)\nStart (Without Audio)"
fi

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Screen Recorder")

[ -z "$CHOICE" ] && exit 0

# Stop Recording
if [ "$CHOICE" = "Stop Recording" ]; then
    pkill -INT ffmpeg
    notify-send "Screen Recorder" "Recording stopped"
    exit 0
fi

# Generate filename
FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
OUTPUT="$SAVE_DIR/$FILENAME"

RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')
AUDIO_SOURCE="$(pactl get-default-sink).monitor"

# Start recording in background
if [ "$CHOICE" = "Start (With Audio)" ]; then
    ffmpeg -video_size "$RESOLUTION" \
           -framerate 60 \
           -f x11grab -i $DISPLAY \
           -f pulse -i "$AUDIO_SOURCE" \
           -c:v libx264 -preset veryfast -crf 23 \
           -pix_fmt yuv420p \
           -c:a aac -b:a 128k \
           "$OUTPUT" &
else
    ffmpeg -video_size "$RESOLUTION" \
           -framerate 60 \
           -f x11grab -i $DISPLAY \
           -c:v libx264 -preset veryfast -crf 23 \
           -pix_fmt yuv420p \
           "$OUTPUT" &
fi

notify-send "Screen Recorder" "Recording started"

