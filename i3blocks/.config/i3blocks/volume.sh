#!/usr/bin/env bash

# 1. Handle mouse click and scroll events
case "${BLOCK_BUTTON:-0}" in
    1) foot -a "floating-window" --title="floating-window" -e wiremix & ;; # Links-Klick: Mixer (im Hintergrund)
    3) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;                       # Rechts-Klick: Mute toggle
    4) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;                        # Scroll hoch: +5%
    5) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;                        # Scroll runter: -5%
esac

# Wenn gescrollt oder geklickt wurde, i3blocks sofort anweisen sich neu zu zeichnen (Signal 10)
if [ "${BLOCK_BUTTON:-0}" -gt 0 ]; then
    pkill -SIGRTMIN+10 i3blocks
fi

# 2. Get volume data from PipeWire (via wpctl)
VOLUME_DATA=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check if the output is muted
IS_MUTED=$(echo "$VOLUME_DATA" | grep -o "\[MUTED\]")

if [[ -n "$IS_MUTED" ]]; then
    # 3. Muted Logic
    echo "<span color='#ff5555'>󰝟 Muted</span>"
else
    # 4. Clean up the volume percentage integer
    # awk nutzt printf, um Rundungsfehler bei Floats (z.B. 0.55 * 100 = 55.00001) sauber zu blocken
    VOLUME_NUM=$(echo "$VOLUME_DATA" | awk '{printf "%.0f", $2 * 100}')

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
