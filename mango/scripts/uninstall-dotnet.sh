#!/usr/bin/env bash

set -e

echo "=== Starting Complete .NET Cleanup on CachyOS ==="

# 1. Remove Pacman / AUR .NET packages if any are installed
echo "[1/4] Checking for Pacman / AUR .NET packages..."
DOTNET_PKGS=$(pacman -Qq | grep -E '^(dotnet-|aspnet-)' || true)

if [ -n "$DOTNET_PKGS" ]; then
    echo "Found system packages: $DOTNET_PKGS"
    sudo pacman -Rns --noconfirm $DOTNET_PKGS
else
    echo "No Pacman / AUR .NET packages found."
fi

# 2. Remove leftover system-wide directories (just in case)
echo "[2/4] Cleaning up any leftover system directories..."
if [ -d "/usr/share/dotnet" ]; then
    sudo rm -rf /usr/share/dotnet
fi
if [ -L "/usr/bin/dotnet" ] || [ -f "/usr/bin/dotnet" ]; then
    sudo rm -f /usr/bin/dotnet
fi
if [ -d "/etc/dotnet" ]; then
    sudo rm -rf /etc/dotnet
fi

# 3. Remove user-level .NET installations, tools, and NuGet caches
echo "[3/4] Removing user-level .NET folders and caches..."
rm -rf "$HOME/.dotnet"
rm -rf "$HOME/.nuget"
rm -rf "$HOME/.local/share/NuGet"
rm -rf "$HOME/.templateengine"
rm -rf "$HOME/.aspnet"

# 4. Remind user to clean shell configuration
echo "[4/4] Checking shell configuration files for DOTNET_ROOT..."
SHELL_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.config/fish/config.fish")

for file in "${SHELL_FILES[@]}"; do
    if [ -f "$file" ] && grep -q "DOTNET_ROOT" "$file"; then
        echo "  -> Found DOTNET_ROOT reference in: $file (please remove those lines manually)"
    fi
done

echo "=== .NET Cleanup Complete! ==="
