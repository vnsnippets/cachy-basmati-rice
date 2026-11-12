#!/bin/sh

# Start the desktop portal for screensharing/compatibility
/usr/lib/xdg-desktop-portal-wlr &

# Set the wallpaper using swaybg
# swaybg -i "$HOME/Pictures/Wallpapers/wallhaven-4d38m0.jpg" -m fill &
swaybg -i "$HOME/.config/mango/assets/gardens-interactive-statues.jpg" -m fill &

quickshell -p $HOME/.config/quickshell/Shell.qml &
