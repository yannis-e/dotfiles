#!/usr/bin/env bash

# 1. Handle click events (Zuerst ausführen!)
if [ "${BLOCK_BUTTON:-0}" -eq 1 ]; then
    # Links-Klick: Öffne bluetui im Hintergrund
    foot -a "floating-window" --title="floating-window" -e bluetui &
elif [ "${BLOCK_BUTTON:-0}" -eq 3 ]; then
    # Aktuellen Status NUR beim Klick prüfen
    CURRENT_POWER=$(bluetoothctl show | awk '/Powered:/ {print $2}')

    if [[ "$CURRENT_POWER" == "yes" ]]; then
        bluetoothctl power off >/dev/null 2>&1
        # Zeige SOFORT "Off" an, ohne auf die Hardware zu warten
        echo "<span color='#ff5555'>󰂲 Off</span>"
    else
        bluetoothctl power on >/dev/null 2>&1
        # Zeige SOFORT "Idle" an, während die Hardware hochfährt
        echo "<span color='#f1fa8c'>󰂯 Idle</span>"
    fi

    # Im Hintergrund verzögert die Bar updaten, falls Geräte sich direkt verbinden
    (sleep 1.5 && pkill -SIGRTMIN+11 i3blocks) &
    exit 0
fi

# 2. Regulärer Check für das i3blocks-Intervall
POWER_STATUS=$(bluetoothctl show | awk '/Powered:/ {print $2}')

# 3. Output logic
if [[ "$POWER_STATUS" == "yes" ]]; then
    # Hole alle verbundenen MAC-Adressen in ein Array
    mapfile -t CONNECTED_MACS < <(bluetoothctl devices Connected | awk '{print $2}')
    TOTAL_DEVICES=${#CONNECTED_MACS[@]}

    if [ "$TOTAL_DEVICES" -gt 0 ]; then
        # Nimm die erste MAC-Adresse aus der Liste
        FIRST_MAC="${CONNECTED_MACS[0]}"

        # Name des ersten Geräts auslesen
        FIRST_NAME=$(bluetoothctl info "$FIRST_MAC" | awk -F': ' '/Name:/ {print $2}' | head -n1)
        [ -z "$FIRST_NAME" ] && FIRST_NAME="Unknown"

        # Name kürzen, falls er zu lang ist
        [[ ${#FIRST_NAME} -gt 16 ]] && FIRST_NAME="${FIRST_NAME:0:16}.."

        # Prüfen, ob noch weitere Geräte verbunden sind
        if [ "$TOTAL_DEVICES" -gt 1 ]; then
            REMAINING_COUNT=$((TOTAL_DEVICES - 1))
            OUTPUT_TEXT="$FIRST_NAME (+${REMAINING_COUNT})"
        else
            OUTPUT_TEXT="$FIRST_NAME"
        fi

        # Ausgabe bei aktiver Verbindung
        echo "<span color='#8be9fd'>󰂱 $OUTPUT_TEXT</span>"
    else
        # Bluetooth ist an, aber kein Gerät ist verbunden
        echo "<span color='#f1fa8c'>󰂯 Idle</span>"
    fi
else
    # Bluetooth ist komplett ausgeschaltet
    echo "<span color='#ff5555'>󰂲 Off</span>"
fi
