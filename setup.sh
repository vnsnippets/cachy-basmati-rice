#!/bin/bash

TARGET_DIR="$HOME/.config"
CURRENT_DATE=$(date +"%Y%m%d%H%M")
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

PROCESSING_ROOT=false

# Ensure ~/.config exists
mkdir -p "$TARGET_DIR"

for param in "$@"; do
    # 1. Flag Check
    if [[ "$param" == "--include-root" ]]; then
        PROCESSING_ROOT=true
        echo "󱀵  Mode Switch: Inlining files directly to $TARGET_DIR"
        continue
    fi

    # 2. Folder Existence Check
    if [ ! -d "$CURRENT_DIR/$param" ]; then
        echo "  Skipping: '$param' folder not found in current directory."
        continue
    fi

    if [ "$PROCESSING_ROOT" = false ]; then
        # --- MODE A: FOLDER PRESERVATION ---
        DEST_PATH="$TARGET_DIR/$param"

        # Check if a real directory (not a symlink) exists
        if [ -d "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
            # Construct the full absolute path for the backup
            BACKUP_FULL_PATH="${DEST_PATH}.${CURRENT_DATE}.bak"
            
            echo "󰆓  Backing up: $DEST_PATH > $BACKUP_FULL_PATH"
            
            # Move the entire folder
            mv "$DEST_PATH" "$BACKUP_FULL_PATH"
        fi

        # If it's a symlink already, refresh it
        if [ -L "$DEST_PATH" ]; then
            rm "$DEST_PATH"
        fi

        # Create the fresh symlink
        ln -s "$CURRENT_DIR/$param" "$DEST_PATH"
        echo "  Folder Linked: $param > $DEST_PATH"

    else
        # --- MODE B: INLINE FILES ---
        echo "󱂬  Inlining files from '$param'..."
        
        find "$CURRENT_DIR/$param" -maxdepth 1 -not -path "$CURRENT_DIR/$param" | while read -r filepath; do
            filename=$(basename "$filepath")
            if [[ "$filename" == "$SCRIPT_NAME" ]]; then continue; fi

            dest_file_path="$TARGET_DIR/$filename"

            # Backup real files/folders at the root if they exist
            if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                BACKUP_FILE_PATH="${dest_file_path}.${CURRENT_DATE}.bak"
                echo "󰆓  Backing up root item: $dest_file_path"
                echo "    󱔘  Destination: $BACKUP_FILE_PATH"
                mv "$dest_file_path" "$BACKUP_FILE_PATH"
            fi

            ln -sf "$filepath" "$dest_file_path"
            echo "   File Linked: $filename > $dest_file_path"
        done
    fi
done

echo "  Setup complete."