#!/bin/bash

TARGET_DIR="$HOME/.config"
CURRENT_DATE=$(date +"%Y%m%d%H%M")
CURRENT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")

# Specific folder paths
SDDM_SOURCE="$CURRENT_DIR/sddm"
SDDM_TARGET="/usr/share/sddm/themes/basmati-rice"
STARSHIP_SOURCE="$CURRENT_DIR/starship"

# Mode tracking: "none", "modules", or "sddm"
MODE="none"

symlink_module() {
    local folder="$1"
    
    # Folder Existence Check
    if [ ! -d "$CURRENT_DIR/$folder" ]; then
        echo "  Skipping: '$folder' folder not found."
        return 1
    fi

    local dest_path="$TARGET_DIR/$folder"
    local link_existed=false

    # Folder preservation logic (Backup real directories)
    if [ -d "$dest_path" ] && [ ! -L "$dest_path" ]; then
        local backup_path="${dest_path}.${CURRENT_DATE}.bak"
        echo "󰆓  Backing up: $dest_path > $backup_path"
        mv "$dest_path" "$backup_path"
    fi

    # Refresh symlink if it exists
    if [ -L "$dest_path" ]; then
        link_existed=true
        rm "$dest_path"
    fi

    # Create the fresh symlink
    ln -s "$CURRENT_DIR/$folder" "$dest_path"
    # Conditional success message
    if [ "$link_existed" = true ]; then
        echo "  Updated Link: $folder > $dest_path"
    else
        echo "  Folder Linked: $folder > $dest_path"
    fi
}

# --- HELP MESSAGE ---
show_help() {
    echo "Usage: ./$SCRIPT_NAME [FLAGS] [FOLDERS...]"
    echo ""
    echo "Flags:"
    echo "  --modules   Symlink specified folder(s) into $TARGET_DIR."
    echo "  --starship  Symlink files from ./starship/ directly into $TARGET_DIR."
    echo "  --rofi      Symlink folder ./rofi as a module and customize launcher applications"
    echo "  --sddm      Install SDDM theme to system directory (requires sudo)."
    echo ""
    echo "Example: ./$SCRIPT_NAME --modules hypr kitty --starship --rofi --sddm"
    exit 0
}

if [ $# -eq 0 ]; then
    show_help
fi

mkdir -p "$TARGET_DIR"

for param in "$@"; do
    case "$param" in
        --rofi)
            echo ""
            echo "󰀻  Setting up rofi (System access will be required)"
            symlink_module "rofi"

            echo ""
            echo "󰀻  Scanning applications in /usr/share/applications..."
            sudo -v
            echo "Skipping the prompt (y/n) will keep the current application setup unchanged."
                
            for file in /usr/share/applications/*.desktop; do
                [ -e "$file" ] || continue
                
                # Extract details
                app_filename=$(basename "$file")
                app_name=$(grep "^Name=" "$file" | head -1 | cut -d'=' -f2)
                app_desc=$(grep "^Comment=" "$file" | head -1 | cut -d'=' -f2)
                
                # Check current NoDisplay status
                if grep -q "NoDisplay=true" "$file"; then
                    current_status="󰈈  Hidden"
                else
                    current_status="󰈈  Visible"
                fi

                echo "------------------------------------------------"
                echo "  File:   $app_filename"
                echo "󱓞  Name:   $app_name"
                echo "󰛨  Desc:   ${app_desc:-No description available}"
                echo "󰂵  Status: $current_status"
                
                while true; do
                    read -p "󰗚  Show in application list? (y/n): " choice
                    
                    # If the user just presses Enter, choice is empty
                    if [[ -z "$choice" ]]; then
                        echo "  󰒲  No changes made."
                        break
                    fi
                    
                    case "${choice,,}" in
                        y)
                            echo "   Setting to visible..."
                            sudo sed -i '/^NoDisplay=/d' "$file"
                            break
                            ;;
                        n)
                            echo "  󰈈  Setting to hidden..."
                            # Remove existing and append to ensure it exists
                            sudo sed -i '/^NoDisplay=/d' "$file"
                            echo "NoDisplay=true" | sudo tee -a "$file" > /dev/null
                            break
                            ;;
                        *)
                            echo "    Invalid input. Please enter y or n or nothing"
                            echo "        (yes) y: Show in Launcher"
                            echo "        (no)  n: Hide in Launcher"
                            echo "        (enter): Leave unchanged"
                            ;;
                    esac
                done
            done
            sudo -k
            echo "  Rofi setup complete."
            continue
            ;;
        --sddm)
            # Logic strictly targeting the ./sddm folder
            echo ""
            if [ ! -d "$SDDM_SOURCE" ]; then
                echo "  Error: SDDM source folder '$SDDM_SOURCE' not found."
            else
                echo "󰑨  Setting up SDDM Theme (System access required)..."
                sudo -v
                if [ -d "$SDDM_TARGET" ]; then
                    BACKUP_SDDM="${SDDM_TARGET}.${CURRENT_DATE}"
                    echo "󰆓  Backing up existing SDDM theme: $SDDM_TARGET > $BACKUP_SDDM"
                    sudo mv "$SDDM_TARGET" "$BACKUP_SDDM"
                fi
                sudo mkdir -p "$SDDM_TARGET"
                sudo cp -r "$SDDM_SOURCE/." "$SDDM_TARGET/"
                sudo -k
                echo "  SDDM Theme installed to: $SDDM_TARGET"
            fi
            MODE="none" # Reset to prevent eating subsequent params
            continue
            ;;
        --starship)
            echo ""
            # Logic strictly targeting the ./starship folder
            if [ ! -d "$STARSHIP_SOURCE" ]; then
                echo "  Error: Starship source folder '$STARSHIP_SOURCE' not found."
            else
                echo "󱀵  Processing Starship configuration..."
                find "$STARSHIP_SOURCE" -maxdepth 1 -not -path "$STARSHIP_SOURCE" | while read -r filepath; do
                    filename=$(basename "$filepath")
                    [[ "$filename" == "$SCRIPT_NAME" ]] && continue

                    dest_file_path="$TARGET_DIR/$filename"
                    
                    # Backup real files if they exist
                    if [ -e "$dest_file_path" ] && [ ! -L "$dest_file_path" ]; then
                        BACKUP_FILE_PATH="${dest_file_path}.${CURRENT_DATE}.bak"
                        echo "󰆓  Backing up: $dest_file_path"
                        mv "$dest_file_path" "$BACKUP_FILE_PATH"
                    fi

                    ln -sf "$filepath" "$dest_file_path"
                    echo "   File Linked: $filename > $dest_file_path"
                done
            fi
            MODE="none" # Reset to prevent eating subsequent params
            continue
            ;;
        --modules)
            MODE="modules"
            echo ""
            echo "󱂬  Symlinking folders to $TARGET_DIR"
            continue
            ;;
        -h|--help)
            show_help
            ;;
    esac

    # Logic execution based on active MODE
    if [[ "$MODE" == "modules" ]]; then
        symlink_module "$param"
    fi
done

echo "  Setup complete."