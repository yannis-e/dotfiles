#!/usr/bin/env bash

# Handle mouse clicks from i3blocks
# 1 = Left Click, 2 = Middle Click, 3 = Right Click
case $BLOCK_BUTTON in
    1) playerctl play-pause ;;
    2) playerctl previous ;;
    3) playerctl next ;;
esac

# Check if any supported player is running
if ! playerctl status >/dev/null 2>&1; then
    echo "" # Print nothing if no player is active
    exit 0
fi

# Get current metadata
STATUS=$(playerctl status)
ARTIST=$(playerctl metadata artist 2>/dev/null)
TITLE=$(playerctl metadata title 2>/dev/null)

# Set an icon based on playback state
if [ "$STATUS" = "Playing" ]; then
    ICON=" " # FontAwesome Play icon (or use standard text like "▶")
elif [ "$STATUS" = "Paused" ]; then
    ICON=" " # FontAwesome Pause icon (or use standard text like "⏸")
else
    ICON=" " # Stopped
fi

# Format output (Trims long titles to 40 characters so it doesn't break your bar layout)
OUTPUT=""
if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    OUTPUT="$ARTIST - $TITLE"
elif [ -n "$TITLE" ]; then
    OUTPUT="$TITLE"
else
    OUTPUT="Unknown Track"
fi

# Print final text (Truncate to 40 chars max)
echo "${ICON}${OUTPUT}" | cut -c1-40
