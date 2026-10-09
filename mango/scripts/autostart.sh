#!/bin/sh

# Start the desktop portal for screensharing/compatibility
/usr/lib/xdg-desktop-portal-wlr &

# Set the wallpaper using swaybg
swaybg -i "$HOME/Pictures/Wallpapers/wallhaven-4d38m0.jpg" -m fill &

# Launch Elephant and Walker service
# elephant &
# walker --gapplication-service &

quickshell -p ~/.config/shell/Shell.qml &
