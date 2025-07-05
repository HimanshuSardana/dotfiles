#!/bin/bash

# Ensure X display and PATH are set (especially useful in startup scripts)
export DISPLAY=:0
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Load Pywal colors
. "${HOME}/.cache/wal/colors.sh"

# Run dmenu with pywal colors to launch applications
cmd=$(dmenu_path | dmenu \
    -nb "$color0" \
    -nf "$color7" \
    -sb "$color1" \
    -sf "$color0" \
    -fn "JetBrainsMono Nerd Font Mono:size=15" \
    -p "Run:")

# If a command was selected, run it
[ -n "$cmd" ] && setsid "$cmd" &>/dev/null &

