#!/usr/bin/env bash

# 1. Handle the click event to open impala in floating mode
if [ "${BLOCK_BUTTON:-0}" -eq 1 ]; then
    kitty --class "floating-window" impala
fi

# 2. Find any active wireless interface directly from device list
INTERFACE=$(awk -F: '/^[ \t]*w/ {print $1; exit}' /proc/net/dev | tr -d ' ')

# 3. Output logic
if [[ -n "$INTERFACE" ]]; then
    # Grab the SSID from iwctl using regex cut
    SSID=$(iwctl station "$INTERFACE" show | grep "Connected network" | sed 's/^.*Connected network[[:space:]]*//' | tr -d ' ')

    if [[ -n "$SSID" ]]; then
        # 4. Extract the RSSI dBm signal strength value (e.g., -55)
        RSSI=$(iwctl station "$INTERFACE" show | grep "RSSI" | awk '{print $2}' | tr -d '[:space:]dBm-')

        # If the RSSI lookup fails for a second, default to a safe medium value
        [[ -z "$RSSI" ]] && RSSI=60

        # 5. Dynamically pick the right icon depending on signal decay
        # Lower dBm values mean a cleaner, stronger signal
        if [ "$RSSI" -le 55 ]; then
            ICON="󰤨"  # Strong / Excellent (< 55 dBm)
        elif [ "$RSSI" -le 68 ]; then
            ICON="󰤥"  # Good (56 - 68 dBm)
        elif [ "$RSSI" -le 78 ]; then
            ICON="󰤢"  # Fair / Moving away (69 - 78 dBm)
        else
            ICON="󰤟"  # Weak / Barely holding on (> 78 dBm)
        fi

        echo "<span color='#50fa7b'>$ICON $SSID</span>"
    else
        # Wi-Fi interface exists but isn't tied to an access point network name yet
        echo "<span color='#f1fa8c'>󰤩 Connecting...</span>"
    fi
else
    # Check for wired ethernet backup interface names starting with 'e'
    ETHERNET=$(awk -F: '/^[ \t]*e/ {print $1; exit}' /proc/net/dev | tr -d ' ')
    if [[ -n "$ETHERNET" ]]; then
        echo "<span color='#50fa7b'>󰌗 Wired</span>"
    else
        echo "<span color='#ff5555'>󰤮 Offline</span>"
    fi
fi
