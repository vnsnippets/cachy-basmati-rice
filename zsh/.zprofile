# .NET SDK
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

# Autostart Mango on TTY1
# Not needed if a Display Manager (like SDDM) is set up
if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec mango
fi

# GNOME Keyring
eval $(gnome-keyring-daemon --start)
