#!/bin/bash

# Change "BAT0" to your battery name if it is different
BAT="BAT0"
SYS_PATH="/sys/class/power_supply/$BAT"

# Fallback check if the path doesn't exist
if [ ! -d "$SYS_PATH" ]; then
    echo "No Batt"
    exit 0
fi

# Read percentage and charging status directly from kernel space
PERCENT=$(cat "$SYS_PATH/capacity")
STATUS=$(cat "$SYS_PATH/status")

# Choose an icon based on status
if [ "$STATUS" = "Charging" ]; then
    ICON=""
else
    ICON="󰁿"
fi

# 1. Output text for the status bar
echo "$ICON $PERCENT%"

# 2. Left-click logic to trigger a modern notification box
if [ "$BLOCK_BUTTON" -eq 1 ]; then
    # Gather clean hardware stats for the popup
    MODEL=$(cat "$SYS_PATH/model_name" 2>/dev/null || echo "Generic")
    HEALTH=$(cat "$SYS_PATH/capacity_level" 2>/dev/null || echo "Unknown")

    DETAILED_INFO="Model: $MODEL\nStatus: $STATUS\nCharge Level: $PERCENT%\nHealth Level: $HEALTH"

    notify-send -t 4000 "Battery Status Details" "$DETAILED_INFO"
fi

# 3. Dynamic color output for low battery warning
if [ "$PERCENT" -le 15 ] && [ "$STATUS" != "Charging" ]; then
    echo "#FF0000" # Red text if low
elif [ "$STATUS" = "Charging" ]; then
    echo "#00FF00" # Green text if charging
fi
