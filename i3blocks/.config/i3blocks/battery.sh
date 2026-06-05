#!/usr/bin/env bash

# 1. Pfade zu den Systemdateien (Standard bei den meisten Laptops ist BAT0 oder BAT1)
BAT_DIR="/sys/class/power_supply/BAT0"

# Fallback, falls dein Laptop BAT1 nutzt
if [ ! -d "$BAT_DIR" ]; then
    BAT_DIR="/sys/class/power_supply/BAT1"
fi

# Falls gar keine Batterie gefunden wird (z.B. am Desktop-PC)
if [ ! -d "$BAT_DIR" ]; then
    echo "<span color='#ff5555'>󰂭 No Bat</span>"
    exit 0
fi

# 2. Daten auslesen
CAPACITY=$(cat "$BAT_DIR/capacity")
STATUS=$(cat "$BAT_DIR/status")

# 3. Logik für Icons und Farben
if [[ "$STATUS" == "Charging" ]]; then
    # Wenn der Akku lädt (Blitz-Icons passend zum Ladestand)
    if [ "$CAPACITY" -le 20 ]; then ICON="󰢜";
    elif [ "$CAPACITY" -le 50 ]; then ICON="󰂇";
    elif [ "$CAPACITY" -le 80 ]; then ICON="󰂉";
    else ICON="󰂅"; fi

    COLOR="#f1fa8c" # Gelb für "Lädt"
    TEXT="$ICON $CAPACITY%"

elif [[ "$STATUS" == "Full" ]]; then
    # Akku komplett voll
    ICON="󰁹"
    COLOR="#50fa7b" # Grün für "Voll"
    TEXT="$ICON $CAPACITY%"

else
    # Akku entlädt (Normale Nutzung)
    if [ "$CAPACITY" -le 10 ]; then
        ICON="󰂎"
        COLOR="#ff5555" # Kritisches Rot
        TEXT="$ICON $CAPACITY% LOW!"
    elif [ "$CAPACITY" -le 20 ]; then
        ICON="󰁺"
        COLOR="#ff5555" # Warn-Rot
        TEXT="$ICON $CAPACITY%"
    elif [ "$CAPACITY" -le 30 ]; then
        ICON="󰁻"
        COLOR="#f8f8f2" # Normales Weiß
        TEXT="$ICON $CAPACITY%"
    elif [ "$CAPACITY" -le 50 ]; then
        ICON="󰁽"
        COLOR="#f8f8f2"
        TEXT="$ICON $CAPACITY%"
    elif [ "$CAPACITY" -le 80 ]; then
        ICON="󰁿"
        COLOR="#f8f8f2"
        TEXT="$ICON $CAPACITY%"
    else
        ICON="󰁹"
        COLOR="#f8f8f2"
        TEXT="$ICON $CAPACITY%"
    fi
fi

# 4. Ausgabe für i3blocks
echo "<span color='$COLOR'>$TEXT</span>"
