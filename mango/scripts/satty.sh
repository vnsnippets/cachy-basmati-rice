#!/usr/bin/env bash

# Define default settings
MODE="region"
SAVE_DIRECTLY=false
USE_CLIPBOARD=false

# Parse arguments
PARSED_ARGS=$(getopt -o rfsc --long region,full,save,clipboard -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    echo "Usage: $0 [--region|-r] [--full|-f] [--save|-s] [--clipboard|-c]"
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
        -c|--clipboard)
            USE_CLIPBOARD=true
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

if [ "$USE_CLIPBOARD" = true ]; then
    # Verify image data exists in the clipboard before attempting to write
    if ! wl-paste --list-types | grep -q "^image/"; then
        echo "Error: No image found in clipboard." >&2
        exit 1
    fi
    wl-paste --type image/png > "$TARGET_PATH"
else
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
fi

SAVE_PATH="$SAVE_DIR/$FILENAME"
satty --filename "$TARGET_PATH" --output-filename "$SAVE_PATH" &