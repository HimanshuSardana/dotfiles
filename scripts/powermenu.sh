#!/usr/bin/env bash

# Rofi power menu with Nerd Font icons

options="  Power Off
  Reboot
  Suspend
  Logout
  Lock"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme-str '
window { width: 300px; }
listview { lines: 5; }
element-text { font: "Iosevka Nerd Font 14"; }
')

case "$chosen" in
    "  Power Off") systemctl poweroff ;;
    "  Reboot") systemctl reboot ;;
    "  Suspend") systemctl suspend ;;
    "  Logout")
        # change this to match your WM
        i3-msg exit || bspc quit || pkill -KILL -u "$USER"
        ;;
    "  Lock")
	    slock
        ;;
esac

