#!/bin/sh

# Start the desktop portal for screensharing/compatibility
/usr/lib/xdg-desktop-portal-wlr &

# Set the wallpaper using swaybg
swaybg -i "$HOME/.config/mango/wallpaper.jpg" -m fill &

# Launch Elephant and Walker service
# elephant &
# walker --gapplication-service &

quickshell -p ~/.config/quickshell/Shell.qml &
