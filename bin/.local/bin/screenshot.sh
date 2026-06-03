#!/usr/bin/env bash

# Create the default screenshots folder if it doesn't exist
DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$DIR"

# Filename template using timestamp
FILE="${DIR}/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Capture a region, feed it to swappy for editing, and save/copy the output
slurp | grim -g - - | swappy -f - -o "$FILE"

# Copy the final saved file path to the clipboard if it exists
if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
fi
