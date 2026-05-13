#!/bin/bash

#Version: 0.0.3

TEMP_FILE="/tmp/pre_idle_brightness"
LOCK_FILE="/tmp/hypridle_script.lock" # Prevents overlapping loops
TARGET_DIM=10
STEP=5
DELAY=0.01

RestoreScreenBrightness() {
    if [ -f "$TEMP_FILE" ]; then
        # Simple lock to prevent multiple instances from fighting over brightnessctl
        exec 200>$LOCK_FILE
        flock -n 200 || exit 1

        local SAVED=$(cat "$TEMP_FILE")
        local CUR=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

        for i in $(seq "$CUR" "$STEP" "$SAVED"); do
            brightnessctl set "${i}%"
            sleep "$DELAY"
        done
        
        brightnessctl set "${SAVED}%"
        rm "$TEMP_FILE"
    fi
}

ReduceScreenBrightness() {
    # Save current brightness percentage to temp file
    brightnessctl -m | cut -d, -f4 | tr -d '%' > "$TEMP_FILE"
    
    local CUR=$(cat "$TEMP_FILE")

    if [ "$CUR" -gt "$TARGET_DIM" ]; then
        for i in $(seq "$CUR" -"$STEP" "$TARGET_DIM"); do
            brightnessctl set "${i}%"
            sleep "$DELAY"
        done
    fi
}

case "$1" in
    --state-idle)
        ReduceScreenBrightness
        ;;
    --state-restore)
        RestoreScreenBrightness
        ;;
esac