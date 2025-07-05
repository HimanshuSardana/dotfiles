#!/usr/bin/env bash

# Kill existing polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

# Source pywal colors
source "$HOME/.cache/wal/colors.sh"

# Export colors as env variables so polybar can access them
export PRIMARY=$color1       # example: use color1 as primary color
export BACKGROUND=$background
export FOREGROUND=$foreground
export DISABLED=$color8      # dim color, e.g.

# Launch polybar
polybar mybar &

