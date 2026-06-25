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

# Interactively select region with slurp
GEOMETRY=$(slurp -d)

# Exit gracefully if user cancels selection (hits Escape)
if [ -z "$GEOMETRY" ]; then
    exit 0
fi

# 1. Capture with grim and save directly to /tmp
grim -g "$GEOMETRY" -t png "$TEMP_PATH"

# 2. Instantly copy the /tmp file to your clipboard (No waiting!)
if [ -f "$TEMP_PATH" ]; then
    wl-copy < "$TEMP_PATH"
fi

# 3. Launch Satty in the background using the static /tmp file.
# If you hit "Save" in Satty, it writes to your permanent folder.
satty --filename "$TEMP_PATH" --output-filename "$SAVE_PATH" &