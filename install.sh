#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Environment & Configuration Setup
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M)"
LOG_FILE="${SCRIPT_DIR}/${TIMESTAMP}.log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function (outputs to stdout with colors and appends plain text to log)
log() {
    local message="$1"
    local plain_message
    plain_message="$(echo -e "$message" | sed -r "s/\x1b\[[0-9;]*m//g")"
    echo -e "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $plain_message" >> "$LOG_FILE"
}

log "${BLUE}=== Starting Installation Script ===${NC}"

# ==============================================================================
# Sudo Authentication & Keep-Alive Management
# ==============================================================================
log "${YELLOW}󰑨 Requesting sudo privileges...${NC}"
sudo -v

# Keep sudo ticket alive in the background for the duration of execution
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# ==============================================================================
# Backup Infrastructure Setup
# ==============================================================================
BACKUP_DATE="$(date +%Y%m%d)"
BACKUP_DIR="$HOME/.config/backup/$BACKUP_DATE"

handle_conflict() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local target_name
        target_name="$(basename "$target")"
        local backup_path="$BACKUP_DIR/$target_name"
        
        # Handle naming collisions inside the daily backup folder
        if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
            backup_path="$BACKUP_DIR/${target_name}_$(date +%H%M%S)"
        fi
        
        mv "$target" "$backup_path"
        log "${YELLOW}󰆓  Backup: $target → $backup_path${NC}"
    fi
}

handle_conflict_sudo() {
    local target="$1"
    if sudo [ -e "$target" ] || sudo [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local target_name
        target_name="$(basename "$target")"
        local backup_path="$BACKUP_DIR/$target_name"
        
        if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
            backup_path="$BACKUP_DIR/${target_name}_$(date +%H%M%S)"
        fi
        
        sudo mv "$target" "$backup_path"
        log "${YELLOW}󰆓  Backup: $target → $backup_path${NC}"
    fi
}

# ==============================================================================
# Action Functions
# ==============================================================================
create_symlink() {
    local rel_src="$1"
    local dest="$2"
    local src="$SCRIPT_DIR/$rel_src"

    if [ ! -e "$src" ]; then
        log "${RED}  Error: Source path '$src' does not exist!${NC}"
        exit 1
    fi

    # Automatically create parent directories if missing
    mkdir -p "$(dirname "$dest")"

    # Idempotency check: Skip if already correctly linked
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        log "${CYAN}  Already Linked: $rel_src → $dest${NC}"
        return
    fi

    # Handle conflicts if a different file/symlink already occupies destination
    handle_conflict "$dest"

    ln -s "$src" "$dest"
    log "${GREEN}  Linked: $rel_src → $dest${NC}"
}

copy_item_sudo() {
    local rel_src="$1"
    local dest="$2"
    local src="$SCRIPT_DIR/$rel_src"

    if [ ! -e "$src" ]; then
        log "${RED}  Error: Source path '$src' does not exist!${NC}"
        exit 1
    fi

    # Ensure parent directory exists with root permissions
    sudo mkdir -p "$(dirname "$dest")"

    # Handle conflicts at destination
    handle_conflict_sudo "$dest"

    sudo cp -r "$src" "$dest"
    log "${GREEN}  Copied: $rel_src → $dest${NC}"
}

install_pacman() {
    local pkg="$1"

    if pacman -Q "$pkg" &>/dev/null; then
        log "${CYAN}  Already installed: $pkg${NC}"
    else
        sudo pacman -S --needed --noconfirm "$pkg"
        log "${GREEN}  Installed: $pkg${NC}"
    fi
}

# ==============================================================================
# Execution: Pacman Packages Installation
# ==============================================================================
echo ""
log "${BLUE}--- Installing Pacman Packages ---${NC}"
install_pacman "mangowm"
install_pacman "foot"
install_pacman "swaybg"
install_pacman "swayidle"
install_pacman "wl-clipboard"
install_pacman "xorg-xwayland"
install_pacman "xdg-desktop-portal-wlr"
install_pacman "xdg-desktop-portal-gtk"
install_pacman "zsh"
install_pacman "zsh-history-substring-search"
install_pacman "zsh-syntax-highlighting"

# ==============================================================================
# Execution: Symlinks Deployment
# ==============================================================================
echo ""
log "${BLUE}--- Creating Symbolic Links ---${NC}"
create_symlink "fastfetch" "$HOME/.config/fastfetch"
create_symlink "foot" "$HOME/.config/foot"
create_symlink "mako" "$HOME/.config/mako"
create_symlink "mango" "$HOME/.config/mango"
create_symlink "mpv" "$HOME/.config/mpv"
create_symlink "shell" "$HOME/.config/quickshell"
create_symlink "zsh" "$HOME/.config/zsh"
create_symlink "themes/starship/starship.toml" "$HOME/.config/starship.toml"
create_symlink "themes/gtk/catppuccin-mocha-mauve" "$HOME/.local/share/themes/catppuccin-mocha-mauve"
create_symlink "themes/gtk/catppuccin-mocha-mauve/gtk-3.0" "$HOME/.config/gtk-3.0"
create_symlink "themes/gtk/catppuccin-mocha-mauve/gtk-4.0" "$HOME/.config/gtk-4.0"
create_symlink "themes/micro/catppuccin.micro" "$HOME/.config/micro/colorschemes/catppuccin.micro"
create_symlink "themes/micro/settings.json" "$HOME/.config/micro/settings.json"

# ==============================================================================
# Execution: System-wide Assets Copying (Sudo)
# ==============================================================================
echo ""
log "${BLUE}--- Installing System-Wide Assets (Privileged) ---${NC}"
copy_item_sudo "themes/xcursor/BibataModernIce" "/usr/share/icons/BibataModernIce"
copy_item_sudo "themes/xcursor/GoogleDotBlue" "/usr/share/icons/GoogleDotBlue"
copy_item_sudo "themes/sddm" "/usr/share/sddm/themes/material"
copy_item_sudo "themes/grub/catppuccin" "/usr/share/grub/themes/catppuccin"
copy_item_sudo "themes/plymouth/cross-hud" "/usr/share/plymouth/themes/cross-hud"

echo ""
log "${BLUE}=== Installation Completed Successfully ===${NC}"