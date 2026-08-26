#!/bin/bash

# Ensure a path was provided as an argument
if [ -z "$1" ]; then
    echo "Error: Please provide the path to your cursor theme folder."
    echo "Usage: $0 /path/to/cursor-theme"
    exit 1
fi

THEME_SOURCE_PATH="$1"
THEME_NAME=$(basename "$THEME_SOURCE_PATH")
CURSOR_SIZE=24
TODAY=$(date +"%Y-%m-%d")

# Validate that the provided path exists and is a directory
if [ ! -d "$THEME_SOURCE_PATH" ]; then
    echo "Error: The path '$THEME_SOURCE_PATH' does not exist or is not a directory."
    exit 1
fi

echo "Setting cursor theme to '$THEME_NAME'..."

# 1. Request sudo access up front to copy the folder to /usr/share/icons
echo "Requesting sudo privileges to install the theme globally..."
sudo cp -r "$THEME_SOURCE_PATH" "/usr/share/icons/"

if [ $? -eq 0 ]; then
    echo "Successfully copied theme to /usr/share/icons/$THEME_NAME"
else
    echo "Error: Failed to copy theme to /usr/share/icons/"
    exit 1
fi

# 2. Update ~/.config/mango/modules/cursor.conf
MANGO_CONF_DIR="$HOME/.config/mango/modules"
MANGO_CONF_FILE="$MANGO_CONF_DIR/cursor.conf"

echo "Updating MangoWM configuration at $MANGO_CONF_FILE..."
mkdir -p "$MANGO_CONF_DIR"

cat << EOF > "$MANGO_CONF_FILE"
# Last Changed: $TODAY

cursor_theme = $THEME_NAME
cursor_size = $CURSOR_SIZE

env = XCURSOR_THEME,$THEME_NAME
env = XCURSOR_SIZE,$CURSOR_SIZE
EOF

# 3. Run GSettings updates (What nwg-look/GTK environments listen to)
echo "Updating desktop GSettings..."
gsettings set org.gnome.desktop.interface cursor-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"

# 4. Directly update GTK 3.0 and GTK 4.0 configuration files (Mirroring nwg-look action)
update_gtk_ini() {
    local ini_file="$1"
    if [ -f "$ini_file" ]; then
        # Remove existing cursor keys to avoid duplicates, then append under [Settings]
        sed -i '/gtk-cursor-theme-name/d' "$ini_file"
        sed -i '/gtk-cursor-theme-size/d' "$ini_file"
        
        # Ensure [Settings] header exists, then insert values right under it
        if grep -q "\[Settings\]" "$ini_file"; then
            sed -i '/\[Settings\]/a gtk-cursor-theme-size='"$CURSOR_SIZE"'\ngtk-cursor-theme-name='"$THEME_NAME"'' "$ini_file"
        else
            echo -e "[Settings]\ngtk-cursor-theme-name=$THEME_NAME\ngtk-cursor-theme-size=$CURSOR_SIZE" >> "$ini_file"
        fi
    else
        mkdir -p "$(dirname "$ini_file")"
        echo -e "[Settings]\ngtk-cursor-theme-name=$THEME_NAME\ngtk-cursor-theme-size=$CURSOR_SIZE" > "$ini_file"
    fi
}

echo "Syncing GTK-3.0 and GTK-4.0 settings files..."
update_gtk_ini "$HOME/.config/gtk-3.0/settings.ini"
update_gtk_ini "$HOME/.config/gtk-4.0/settings.ini"

# 5. Create local X11/Xcursor fallback configuration
echo "Setting up local Xcursor backup fallback..."
mkdir -p "$HOME/.icons/default"
cat << EOF > "$HOME/.icons/default/index.theme"
[Icon Theme]
Inherits=$THEME_NAME
EOF

echo "All tasks completed! Please restart your MangoWM session to see the cursor update everywhere."