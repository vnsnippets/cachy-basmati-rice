#!/usr/bin/env bash

# Define default mode
MODE="region"

# Parse arguments
PARSED_ARGS=$(getopt -o rf --long region,full -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    echo "Usage: $0 [--region|-r] [--full|-f]"
    exit 1
fi

eval set -- "$PARSED_ARGS"

while true; do
    case "$1" in
        -r|--region)
            MODE="region"
            shift
            ;;
        -f|--full)
            MODE="full"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

# Define the temporary folder as the saving location (cleared on reboot)
TEMP_DIR="/tmp/screenshots"
mkdir -p "$TEMP_DIR"

# Define persistent screenshot saving location
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

# Dynamic filename using date and time format
FILENAME="Screenshot-$(date '+%Y%m%d-%H%M%S-%3N').png"
TEMP_PATH="$TEMP_DIR/$FILENAME"
SAVE_PATH="$SAVE_DIR/$FILENAME"

# Determine capture geometry/mode
if [ "$MODE" = "region" ]; then
    GEOMETRY=$(slurp -d)
    # Exit gracefully if user cancels selection (hits Escape)
    if [ -z "$GEOMETRY" ]; then
        exit 0
    fi
    grim -g "$GEOMETRY" -t png "$TEMP_PATH"
else
    # Capture full screen
    grim -t png "$TEMP_PATH"
fi

# Instantly copy the /tmp file to clipboard
if [ -f "$TEMP_PATH" ]; then
    wl-copy < "$TEMP_PATH"
fi

# Launch Satty in the background using the temporary file
satty --filename "$TEMP_PATH" --output-filename "$SAVE_PATH" &