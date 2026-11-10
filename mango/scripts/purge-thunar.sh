#!/usr/bin/env bash
#
# Complete purge script for Thunar and associated artifacts
#
# Package (11)                               New Version  Net Change  Download Size

# cachyos-extra-znver4/exo                   4.20.0-2.1     2.26 MiB       0.34 MiB
# cachyos-extra-znver4/libexif               0.6.26-1.1     3.15 MiB       0.53 MiB
# cachyos-extra-znver4/libgtop               2.41.3-2.1     1.26 MiB       0.19 MiB
# cachyos-extra-znver4/libnotify             0.8.9-1.1      0.17 MiB       0.04 MiB
# cachyos-extra-znver4/libxfce4ui            4.20.2-1.1     2.23 MiB       0.39 MiB
# cachyos-extra-znver4/libxfce4util          4.20.1-1.1     1.07 MiB       0.14 MiB
# cachyos-extra-znver4/startup-notification  0.12-9.1       0.06 MiB       0.02 MiB
# cachyos-extra-znver4/xfconf                4.20.0-2.1     1.10 MiB       0.18 MiB
# extra/gvfs                                 1.62.0-3       5.05 MiB       0.90 MiB
# cachyos-extra-znver4/thunar                4.20.10-1.1    9.71 MiB       1.61 MiB
# cachyos-extra-znver4/thunar-volman         4.20.0-2.1     0.66 MiB       0.13 MiB

# Total Download Size:    4.47 MiB
# Total Installed Size:  26.73 MiB

set -euo pipefail

echo "==> Starting complete purge of Thunar..."

# 1. Check and remove system packages via pacman
PACKAGES_TO_REMOVE=("thunar" "thunar-volman")
INSTALLED_PKGS=()

for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    if pacman -Qq "$pkg" &>/dev/null; then
        INSTALLED_PKGS+=("$pkg")
    fi
done

if [ ${#INSTALLED_PKGS[@]} -gt 0 ]; then
    echo "==> Removing pacman packages and strict orphans: ${INSTALLED_PKGS[*]}"
    sudo pacman -Rns --noconfirm "${INSTALLED_PKGS[@]}"
else
    echo "==> Thunar system packages are already uninstalled."
fi

# 2. Purge user-specific configuration and cache directories
echo "==> Removing user configuration and state files..."
rm -rf ~/.config/Thunar
rm -rf ~/.cache/Thunar
rm -rf ~/.local/share/Thunar

# 3. Refresh desktop database to clear menu entries
if command -v update-desktop-database &>/dev/null; then
    echo "==> Updating desktop database..."
    update-desktop-database -q
fi

# 4. Optional: Check for any remaining system-wide orphaned packages
if pacman -Qdtq &>/dev/null; then
    echo "----------------------------------------------------------------"
    echo "Notice: Additional unlinked orphaned packages exist on the system."
    read -rp "Would you like to review and remove them? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -Rns "$(pacman -Qdtq)"
    fi
    echo "----------------------------------------------------------------"
fi

echo "==> Purge complete. Thunar has been completely wiped from the system."