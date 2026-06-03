#!/usr/bin/env bash

# 1. Handle the click event to open wiremix in floating mode
# (Change '1' to '3' if you want it to trigger on Right-click instead of Left-click)
if [ "${BLOCK_BUTTON:-0}" -eq 1 ]; then
    kitty --class "floating-window" wiremix
fi

# 2. Get volume data from PipeWire (via wpctl)
# This extracts the default audio output source data
VOLUME_DATA=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check if the output is muted
IS_MUTED=$(echo "$VOLUME_DATA" | grep -o "\[MUTED\]")

if [[ -n "$IS_MUTED" ]]; then
    # 3. Muted Logic
    echo "<span color='#ff5555'>󰝟 Muted</span>"
else
    # 4. Clean up the volume percentage integer
    # wpctl outputs volume as a decimal (e.g., "Volume: 0.55"), so we convert it to 55%
    VOLUME_NUM=$(echo "$VOLUME_DATA" | awk '{print $2 * 100}' | cut -d. -f1)

    # 5. Dynamically pick the right icon depending on volume level
    if [ "$VOLUME_NUM" -eq 0 ]; then
        ICON="󰕿"  # No sound / Zero
        COLOR="#f1fa8c" # Yellow warning
    elif [ "$VOLUME_NUM" -le 30 ]; then
        ICON="󰕿"  # Low volume
        COLOR="#f8f8f2" # White
    elif [ "$VOLUME_NUM" -le 70 ]; then
        ICON="󰖀"  # Medium volume
        COLOR="#f8f8f2" # White
    else
        ICON="󰕾"  # High volume
        COLOR="#ffb86c" # Orange caution for high volume
    fi

    # Output formatted text (e.g., 󰖀 55%)
    echo "<span color='$COLOR'>$ICON $VOLUME_NUM%</span>"
fi
