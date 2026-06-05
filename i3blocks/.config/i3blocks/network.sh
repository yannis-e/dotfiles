#!/usr/bin/env bash

# 1. Handle click events (Zuerst ausführen!)
if [ "${BLOCK_BUTTON:-0}" -eq 1 ]; then
    # Links-Klick: Öffne impala im Hintergrund
    foot -a "floating-window" --title="floating-window" -e impala &
elif [ "${BLOCK_BUTTON:-0}" -eq 3 ]; then
    # Rechts-Klick: Prüfen, ob WLAN per rfkill blockiert ist
    # (0 bedeutet unblockiert, 1 bedeutet blockiert/aus)
    WIFI_BLOCKED=$(rfkill list wifi | grep -i "Soft blocked: yes")

    if [[ -z "$WIFI_BLOCKED" ]]; then
        rfkill block wifi
        # Zeige SOFORT das "Aus"-Icon an
        echo "<span color='#ff5555'>󰤮  Off</span>"
    else
        rfkill unblock wifi
        # Zeige SOFORT "Connecting...", während die Hardware hochfährt
        echo "<span color='#f1fa8c'>󰤩  ...</span>"
    fi

    # Im Hintergrund verzögert die Bar aktualisieren, wenn die Verbindung steht
    (sleep 1.0 && pkill -SIGRTMIN+12 i3blocks) &
    exit 0
fi

# 2. Prüfen, ob Wi-Fi per rfkill komplett ausgeschaltet ist
if rfkill list wifi | grep -i "Soft blocked: yes" >/dev/null 2>&1; then
    echo "<span color='#ff5555'>󰤮  Off</span>"
    exit 0
fi

# 3. Find any active wireless interface directly from device list
INTERFACE=$(awk -F: '/^[ \t]*w/ {print $1; exit}' /proc/net/dev | tr -d ' ')

# 4. Output logic
if [[ -n "$INTERFACE" ]]; then
    # Grab the SSID from iwctl using regex cut
    SSID=$(iwctl station "$INTERFACE" show | grep "Connected network" | sed 's/^.*Connected network[[:space:]]*//' | tr -d ' ')

    if [[ -n "$SSID" ]]; then
        # Extract the RSSI dBm signal strength value (e.g., -55)
        RSSI=$(iwctl station "$INTERFACE" show | grep "RSSI" | awk '{print $2}' | tr -d '[:space:]dBm-')

        # If the RSSI lookup fails for a second, default to a safe medium value
        [[ -z "$RSSI" ]] && RSSI=60

        # Dynamically pick the right icon depending on signal decay
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
        echo "<span color='#f1fa8c'>󰤩  ...</span>"
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
