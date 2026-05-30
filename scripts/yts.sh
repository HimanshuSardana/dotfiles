#!/usr/bin/env bash

query=$(rofi -dmenu -p "YouTube")
[ -z "$query" ] && exit

selection=$(
yt-dlp \
  --flat-playlist \
  "ytsearch20:$query" \
  --print "%(title)s\t%(id)s" |
  sed $'s/\\\\t/\t/g' |
    rofi -dmenu -i -p "Results"
)

id=$(printf "%s" "$selection" | awk -F'\t' '{print $2}')

[ -n "$id" ] && zen-browser "https://youtube.com/watch?v=$id"
# [ -n "$id" ] && mpv "https://youtube.com/watch?v=$id"
