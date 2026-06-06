#!/usr/bin/env bash

# Define your preferred screenshot saving location
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

# Dynamic filename using date and time format
FILENAME="Screenshot-$(date '+%Y%m%d-%H%M%S-%3N').png"

# Interactively select region with slurp, capture with grim, pipe into satty
# -t ppm speeds up the data transfer pipe to Satty
GEOMETRY=$(slurp -d)

# Exit gracefully if user cancels selection (hits Escape)
if [ -z "$GEOMETRY" ]; then
    exit 0
fi

grim -g "$GEOMETRY" -t ppm - | satty --filename - --output-filename "$SAVE_DIR/$FILENAME"
