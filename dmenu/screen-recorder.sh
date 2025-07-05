#!/bin/bash

# Set DISPLAY explicitly in case it's not inherited
export DISPLAY=${DISPLAY:-:0}

# Choose recording mode
mode=$(printf "Full Screen\nSelect Region\nCancel" | dmenu -p "Record Mode:")
[ "$mode" = "Cancel" ] || [ -z "$mode" ] && exit

# Choose audio
audio=$(printf "With Audio\nNo Audio\nCancel" | dmenu -p "Audio:")
[ "$audio" = "Cancel" ] || [ -z "$audio" ] && exit

# Choose output filename
filename=$(dmenu -p "Filename:" < /dev/null)
[ -z "$filename" ] && exit
filename="${filename}.mp4"

# Set audio options
if [ "$audio" = "With Audio" ]; then
    AUDIO="-f pulse -i default"
else
    AUDIO=""
fi

# Set video input
if [ "$mode" = "Full Screen" ]; then
    RES=$(xdpyinfo | grep dimensions | awk '{print $2}')
    VIDEO="-video_size $RES -f x11grab -i $DISPLAY"
elif [ "$mode" = "Select Region" ]; then
    notify-send "Select a region using your mouse"
    REGION=$(slop -f "-video_size %wx%h -i :0.0+%x,%y")
    VIDEO="-f x11grab $REGION"
else
    exit
fi

# Combine and run
ffmpeg $VIDEO $AUDIO -c:v libx264 -preset ultrafast -crf 23 -pix_fmt yuv420p "$filename"
notify-send "Recording saved as $filename"

