#!/bin/sh

# Start the desktop portal for screensharing/compatibility
/usr/lib/xdg-desktop-portal-wlr &

# Set the wallpaper using swaybg
swaybg -i "$HOME/Pictures/Wallpapers/robot-wallpaper-3840x2160-abandoned-untamed-26625.jpg" -m fill &

# Launch Elephant and Walker service
# elephant &
# walker --gapplication-service &

quickshell -p ~/.config/quickshell/Shell.qml &
