#!/usr/bin/env bash

# Define menu options
lock="Lock"
logout="Logout"
reboot="Restart"
shutdown="Shutdown"

# Concatenate options using plain line breaks
options="${lock}\n${logout}\n${reboot}\n${shutdown}"

# Launch dmenu
selected=$(echo -e "$options" | dmenu -i -p "Power:" -fn "monospace-10" -nb "#222222" -nf "#bbbbbb" -sb "#005577" -sf "#eeeeee")

# Exit cleanly if no option was selected
[[ -z "$selected" ]] && exit 0

# Process selection
case "$selected" in
    "$lock")
        i3lock-color \
          --clock \
          --indicator \
          --color=000000 \
          --time-color=ffffffff \
          --date-color=ffffffff \
          --verif-color=ffffffff \
          --wrong-color=ffffffff
        ;;
    "$logout")
        i3-msg exit
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac