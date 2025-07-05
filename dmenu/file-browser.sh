#!/bin/bash

export DISPLAY=:0
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Load Pywal colors
. "${HOME}/.cache/wal/colors.sh"

# Directories to search in
DIRS=(
    "$HOME/docs"
    "$HOME/projects"
    "$HOME/Downloads"
)

SEARCH_PATHS=$(printf '%s\n' "${DIRS[@]}")

# Find all directories
DIR_LIST=$(fd --type d --exclude .git --exclude node_modules --exclude venv --exclude __pycache__ --exclude .cache . $SEARCH_PATHS)

# Show in dmenu
SELECTED=$(echo "$DIR_LIST" | dmenu \
    -nb "$color0" \
    -nf "$color7" \
    -sb "$color1" \
    -sf "$color0" \
    -fn "JetBrainsMono Nerd Font Mono:size=15" \
    -i -l 20)

# Open selected dir in kitty with nvim
[ -n "$SELECTED" ] && kitty --working-directory "$SELECTED"

