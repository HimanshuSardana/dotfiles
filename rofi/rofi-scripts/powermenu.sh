#!/bin/bash

# Define the power options
options="  Shutdown\n  Reboot\n  Lock\n  Night Light"

# Use rofi to display the options and get the selected option
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Execute the action based on the selection
case $selected_option in
    "  Shutdown")
        systemctl poweroff
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Lock")
        # Replace with your preferred lock command
        hyprlock 
        ;;
    "  Night Light")
        # Replace with your preferred lock command
        hyprshade toggle blue-light-filter
        ;;
    *)
        ;;
esac

