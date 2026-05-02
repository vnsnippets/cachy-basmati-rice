#!/bin/bash

# V0.0.2
TEMP_FILE="/tmp/pre_idle_brightness"
TARGET_DIM=10
STEP=5
DELAY=0.01

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

RestoreScreenBrightness() {
    if [ -f "$TEMP_FILE" ]; then
        local SAVED=$(cat "$TEMP_FILE")
        local CUR=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

        # Fade up from current (10%) to the saved value
        for i in $(seq "$CUR" "$STEP" "$SAVED"); do
            brightnessctl set "${i}%"
            sleep "$DELAY"
        done
        
        # Ensure we hit the exact original value at the end
        brightnessctl set "${SAVED}%"
        rm "$TEMP_FILE"
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