#!/usr/bin/env bash

# Define default settings
MODE="region"
SAVE_DIRECTLY=false

# Parse arguments
PARSED_ARGS=$(getopt -o rfs --long region,full,save -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    echo "Usage: $0 [--region|-r] [--full|-f] [--save|-s]"
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
        -s|--save)
            SAVE_DIRECTLY=true
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

# Define directories
TEMP_DIR="/tmp/screenshots"
SAVE_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$TEMP_DIR" "$SAVE_DIR"

# Dynamic filename using date and time format
FILENAME="Screenshot-$(date '+%Y%m%d-%H%M%S-%3N').png"

if [ "$SAVE_DIRECTLY" = true ]; then
    TARGET_PATH="$SAVE_DIR/$FILENAME"
else
    TARGET_PATH="$TEMP_DIR/$FILENAME"
fi

# Determine capture geometry/mode
if [ "$MODE" = "region" ]; then
    GEOMETRY=$(slurp -d)
    # Exit gracefully if user cancels selection (hits Escape)
    if [ -z "$GEOMETRY" ]; then
        exit 0
    fi
    grim -g "$GEOMETRY" -t png "$TARGET_PATH"
else
    # Capture full screen
    grim -t png "$TARGET_PATH"
fi

# Instantly copy the captured file to clipboard
if [ -f "$TARGET_PATH" ]; then
    wl-copy < "$TARGET_PATH"
fi

SAVE_PATH="$SAVE_DIR/$FILENAME"
satty --filename "$TARGET_PATH" --output-filename "$SAVE_PATH" &