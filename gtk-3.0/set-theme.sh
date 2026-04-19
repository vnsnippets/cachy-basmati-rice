#!/bin/bash

# Check if all 3 arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <themeName> <iconName> <colorScheme>"
    echo "Example: $0 Adwaita-dark Adwaita prefer-dark"
    exit 1
fi

THEME=$1
ICONS=$2
SCHEME=$3

# 1. Update Live Settings (GSettings)
echo "Applying live settings..."
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"

# 2. Update persistent GTK3 config
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"

# Ensure the directory exists
mkdir -p "$(dirname "$GTK3_FILE")"

echo "Updating $GTK3_FILE..."
echo "[Settings]
gtk-theme-name=$THEME
gtk-icon-theme-name=$ICONS" > "$GTK3_FILE"

echo "Done! Theme set to $THEME."