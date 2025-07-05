#!/bin/bash

export DISPLAY=:0
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Load Pywal colors
. "${HOME}/.cache/wal/colors.sh"

# Power menu options
OPTIONS="Shutdown\nLogout\nReboot\nLock"

# Show menu
CHOICE=$(echo -e "$OPTIONS" | dmenu \
    -nb "$color0" \
    -nf "$color7" \
    -sb "$color1" \
    -sf "$color0" \
    -fn "JetBrainsMono Nerd Font Mono:size=15" \
    -i -p "Power Menu")

# Take action based on selection
case "$CHOICE" in
	Shutdown)
		systemctl poweroff ;;
	Lock)
		i3lock -c 000000 ;;  # or `betterlockscreen -l` or `slock` based on what you use
	Logout)
		pkill -KILL -u "$USER" ;;
	Reboot)
		systemctl reboot ;;
esac

