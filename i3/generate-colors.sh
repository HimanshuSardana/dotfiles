#!/bin/bash

# Source pywal colors
source ~/.cache/wal/colors.sh

# Export colors as environment variables
export background foreground color0 color1 color2 color3 color4 color5 color6 color7

# Use envsubst to replace variables in template and write final config
envsubst < ~/.config/i3/config.template >> ~/.config/i3/config

# Reload i3 config
i3-msg reload
