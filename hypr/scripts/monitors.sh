#!/usr/bin/env bash

sleep 0.5
# Get currently connected monitors
monitors=$(hyprctl monitors -j | jq -r '.[].name')

# Replace with your monitor names (get them with `hyprctl monitors`)
LAPTOP="eDP-1"
EXTERNAL="HDMI-A-2"

# If external monitor is connected, disable laptop display
if echo "$monitors" | grep -q "$EXTERNAL"; then
    hyprctl keyword monitor "$LAPTOP, disable"
else
    hyprctl keyword monitor "$LAPTOP, preferred, auto, 1"
fi

