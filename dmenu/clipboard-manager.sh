#!/bin/bash

export DISPLAY=:0
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Load Pywal colors
. "${HOME}/.cache/wal/colors.sh"

# Use cliphist to show clipboard history in dmenu
SELECTION=$(cliphist list | dmenu \
  -nb "$color0" \
  -nf "$color7" \
  -sb "$color1" \
  -sf "$color0" \
  -fn "JetBrainsMono Nerd Font Mono:size=15" \
  -i -l 20 -p "Clipboard")

# If something was selected, copy it again
[ -n "$SELECTION" ] && echo -n "$SELECTION" | xclip -selection clipboard

