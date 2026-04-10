#!/bin/bash

# Function to list Bluetooth devices and connect/disconnect
bluetooth_menu() {
    # Get list of available Bluetooth devices
    devices=$(bluetoothctl devices | awk '{for (i=3; i<=NF; i++) printf "%s ", $i; print "(" $2 ")"}')
    
    if [[ -z "$devices" ]]; then
        echo "No Bluetooth devices found" | rofi -dmenu -p "Bluetooth"
        exit 1
    fi
    
    # Show available devices in rofi
    selected_device=$(echo -e "$devices" | rofi -dmenu -i -p "Select Bluetooth Device")
    
    if [[ -z "$selected_device" ]]; then
        exit 1
    fi
    
    # Extract the MAC address of the selected device
    device_mac=$(echo "$selected_device" | awk -F '[()]' '{print $2}')
    
    # Check if the device is already connected
    connected=$(bluetoothctl info "$device_mac" | grep "Connected: yes")
    
    if [[ -n "$connected" ]]; then
        # Disconnect if already connected
        if bluetoothctl disconnect "$device_mac"; then
            notify-send "Bluetooth" "Disconnected from $selected_device"
        else
            notify-send "Bluetooth" "Failed to disconnect from $selected_device"
        fi
    else
        # Connect if not connected
        if bluetoothctl connect "$device_mac"; then
            notify-send "Bluetooth" "Connected to $selected_device"
        else
            notify-send "Bluetooth" "Failed to connect to $selected_device"
        fi
    fi
}

# Call the Bluetooth menu function
bluetooth_menu

