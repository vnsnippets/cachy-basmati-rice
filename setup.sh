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
        # Objective: Link folder currentDir/hypr/ to ~/.config/hypr/
        
        DEST_PATH="$TARGET_DIR/$param"

        # Backup logic: Only backup if it's a real directory and NOT a symlink
        if [ -d "$DEST_PATH" ] && [ ! -L "$DEST_PATH" ]; then
            BACKUP_FOLDER="$DEST_PATH/$CURRENT_DATE.bak"
            echo "󰆓  Backing up existing $param folder to $BACKUP_FOLDER"
            mkdir -p "$BACKUP_FOLDER"
            find "$DEST_PATH" -maxdepth 1 -not -path "$DEST_PATH" -not -name "*.bak" -exec mv {} "$BACKUP_FOLDER" \;
        fi

        # The Fix: Manually symlink the folder if it doesn't exist as a link
        # This bypasses Stow's "flattening" behavior entirely.
        if [ ! -L "$DEST_PATH" ]; then
            ln -s "$CURRENT_DIR/$param" "$DEST_PATH"
            echo "  Folder Linked: $param -> $DEST_PATH"
        else
            echo "󱈸  $param is already linked, skipping."
        fi

    else
        # --- MODE B: INLINE FILES ---
        # Objective: Take contents of currentDir/param/* and link to ~/.config/*
        
        echo "󱂬  Inlining files from '$param'..."
        
        find "$CURRENT_DIR/$param" -maxdepth 1 -not -path "$CURRENT_DIR/$param" | while read -r filepath; do
            filename=$(basename "$filepath")
            if [[ "$filename" == "$SCRIPT_NAME" ]]; then continue; fi

            dest_file_path="$TARGET_DIR/$filename"

            # Backup real files
            if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                echo "󰆓  Backing up root file: $filename"
                mv "$dest_file_path" "$dest_file_path.$CURRENT_DATE.bak"
            fi

            ln -sf "$filepath" "$dest_file_path"
            echo "   File Linked: $filename -> .config/$filename"
        done
    fi
done

echo "  Setup complete."