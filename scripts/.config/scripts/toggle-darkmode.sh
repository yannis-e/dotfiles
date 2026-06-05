#!/bin/bash

# Get the current setting (strips away quotes)
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

if [ "$CURRENT_THEME" = "prefer-dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    echo "Switched to Light Mode"
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    echo "Switched to Dark Mode"
fi
