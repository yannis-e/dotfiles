#!/usr/bin/env bash

# 1. Handle the click event to open bluetui in floating mode
if [ "${BLOCK_BUTTON:-0}" -eq 1 ]; then
    kitty --class "floating-window" bluetui
fi

# 2. Check if Bluetooth controller/hardware is powered on
POWER_STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

# 3. Output logic
if [[ "$POWER_STATUS" == "yes" ]]; then
    # Hole alle verbundenen MAC-Adressen in ein Array
    mapfile -t CONNECTED_MACS < <(bluetoothctl devices Connected | awk '{print $2}')
    TOTAL_DEVICES=${#CONNECTED_MACS[@]}

    if [ "$TOTAL_DEVICES" -gt 0 ]; then
        # Nimm die erste MAC-Adresse aus der Liste
        FIRST_MAC="${CONNECTED_MACS[0]}"

        # Name des ersten Geräts auslesen
        FIRST_NAME=$(bluetoothctl info "$FIRST_MAC" | grep "Name:" | sed 's/^.*Name:[[:space:]]*//')

        # Name kürzen, falls er zu lang ist
        [[ ${#FIRST_NAME} -gt 16 ]] && FIRST_NAME="${FIRST_NAME:0:16}.."

        # Prüfen, ob noch weitere Geräte verbunden sind
        if [ "$TOTAL_DEVICES" -gt 1 ]; then
            # Berechne wie viele Geräte noch übrig sind
            REMAINING_COUNT=$((TOTAL_DEVICES - 1))
            OUTPUT_TEXT="$FIRST_NAME (+${REMAINING_COUNT})"
        else
            OUTPUT_TEXT="$FIRST_NAME"
        fi

        # Ausgabe (z.B. 󰂱 Sony WH-10.. (+2) oder einfach 󰂱 Sony WH-10..)
        echo "<span color='#8be9fd'>󰂱 $OUTPUT_TEXT</span>"
    else
        # Bluetooth ist an, aber kein Gerät ist verbunden
        echo "<span color='#f1fa8c'>󰂯 Idle</span>"
    fi
else
    # Bluetooth ist komplett ausgeschaltet
    echo "<span color='#ff5555'>󰂲 Off</span>"
fi
