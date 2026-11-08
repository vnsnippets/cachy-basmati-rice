# Autostart Mango on TTY1
# Not needed if a Display Manager (like SDDM) is setup
if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec mango
fi

# GNOME Keyring
eval $(gnome-keyring-daemon --start)