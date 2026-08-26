#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Input Validation
# ------------------------------------------------------------------------------
if [ "$#" -ne 1 ]; tide 2>/dev/null || [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/theme-folder"
    exit 1
fi

SOURCE_PATH="$1"

if [ ! -d "$SOURCE_PATH" ]; then
    echo "Error: Directory '$SOURCE_PATH' does not exist."
    exit 1
fi

THEME_NAME=$(basename "$SOURCE_PATH")
DEST_DIR="$HOME/.local/share/themes"
DEST_PATH="$DEST_DIR/$THEME_NAME"

# ------------------------------------------------------------------------------
# 2. Copy Theme
# ------------------------------------------------------------------------------
echo "Installing theme '$THEME_NAME' to $DEST_DIR..."
mkdir -p "$DEST_DIR"

# Remove existing installation if present, then copy fresh
rm -rf "$DEST_PATH"
cp -r "$SOURCE_PATH" "$DEST_PATH"

echo "Theme files installed successfully."

# ------------------------------------------------------------------------------
# 3. Apply GTK Theme Across Environment
# ------------------------------------------------------------------------------
echo "Applying theme '$THEME_NAME' system-wide..."

# GSettings (GTK 3 / GTK 4)
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true
fi

# GTK 3 Configuration (~/.config/gtk-3.0/settings.ini)
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$HOME/.config/gtk-3.0"
if [ -f "$GTK3_FILE" ]; then
    if grep -q "^gtk-theme-name=" "$GTK3_FILE"; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$THEME_NAME/" "$GTK3_FILE"
    else
        echo "gtk-theme-name=$THEME_NAME" >> "$GTK3_FILE"
    fi
else
    cat <<EOF > "$GTK3_FILE"
[Settings]
gtk-theme-name=$THEME_NAME
EOF
fi

# GTK 4 Configuration (~/.config/gtk-4.0/settings.ini)
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"
mkdir -p "$HOME/.config/gtk-4.0"
if [ -f "$GTK4_FILE" ]; then
    if grep -q "^gtk-theme-name=" "$GTK4_FILE"; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$THEME_NAME/" "$GTK4_FILE"
    else
        echo "gtk-theme-name=$THEME_NAME" >> "$GTK4_FILE"
    fi
else
    cat <<EOF > "$GTK4_FILE"
[Settings]
gtk-theme-name=$THEME_NAME
EOF
fi

# GTK 2 Configuration (~/.gtkrc-2.0)
GTK2_FILE="$HOME/.gtkrc-2.0"
if [ -f "$GTK2_FILE" ]; then
    if grep -q 'gtk-theme-name' "$GTK2_FILE"; then
        sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$THEME_NAME\"/" "$GTK2_FILE"
    else
        echo "gtk-theme-name=\"$THEME_NAME\"" >> "$GTK2_FILE"
    fi
else
    echo "gtk-theme-name=\"$THEME_NAME\"" > "$GTK2_FILE"
fi

# xsettingsd (~/.config/xsettingsd/xsettingsd.conf)
XSETTINGS_FILE="$HOME/.config/xsettingsd/xsettingsd.conf"
if [ -f "$XSETTINGS_FILE" ]; then
    if grep -q 'Net/ThemeName' "$XSETTINGS_FILE"; then
        sed -i "s|Net/ThemeName .*|Net/ThemeName \"$THEME_NAME\"|" "$XSETTINGS_FILE"
    else
        echo "Net/ThemeName \"$THEME_NAME\"" >> "$XSETTINGS_FILE"
    fi
    # Reload xsettingsd without killing it
    pkill -HUP xsettingsd 2>/dev/null || true
fi

# GTK4 CSS Symlink fallback (copies gtk.css directly for Libadwaita apps)
if [ -d "$DEST_PATH/gtk-4.0" ]; then
    mkdir -p "$HOME/.config/gtk-4.0"
    ln -sf "$DEST_PATH/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true
    ln -sf "$DEST_PATH/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css" 2>/dev/null || true
    ln -sf "$DEST_PATH/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets" 2>/dev/null || true
fi

echo "Done! Theme '$THEME_NAME' is active."
