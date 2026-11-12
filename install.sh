#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Environment & Configuration Setup
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
LOG_FILE="${SCRIPT_DIR}/${TIMESTAMP}.log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Script variables
PLYMOUTH_THEME='cross-hud'
XCURSOR_THEME='BibataModernIce'
GRUB_THEME='catppuccin'
GTK_THEME='catppuccin-mocha-mauve'
GTK_MODE='prefer-dark'
MICRO_THEME='catppuccin'

# Logging function (outputs to stdout with colors and appends plain text to log)
log() {
    local message="$1"
    local plain_message
    plain_message="$(echo -e "$message" | sed -r "s/\x1b\[[0-9;]*m//g")"
    echo -e "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $plain_message" >> "$LOG_FILE"
}

log "${BLUE}Starting Installation Script${NC}"

# ==============================================================================
# Sudo Authentication & Keep-Alive Management
# ==============================================================================
log "${YELLOW}:: Requesting sudo privileges...${NC}"
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
BACKUP_DATE="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="$HOME/.config/.backup/$BACKUP_DATE"

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
        log "${YELLOW}:: Backup: $target → $backup_path${NC}"
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
        log "${YELLOW}:: Backup: $target → $backup_path${NC}"
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
        log "${RED}:: Error: Source path '$src' does not exist!${NC}"
        exit 1
    fi

    # Automatically create parent directories if missing
    mkdir -p "$(dirname "$dest")"

    # Idempotency check: Skip if already correctly linked
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        log "${CYAN}:: Already Linked: $rel_src → $dest${NC}"
        return
    fi

    # Handle conflicts if a different file/symlink already occupies destination
    handle_conflict "$dest"

    ln -s "$src" "$dest"
    log "${GREEN}:: Linked: $rel_src → $dest${NC}"
}

copy_item_sudo() {
    local rel_src="$1"
    local dest="$2"
    local src="$SCRIPT_DIR/$rel_src"

    if [ ! -e "$src" ]; then
        log "${RED}:: Error: Source path '$src' does not exist!${NC}"
        exit 1
    fi

    # Ensure parent directory exists with root permissions
    sudo mkdir -p "$(dirname "$dest")"

    # Handle conflicts at destination
    handle_conflict_sudo "$dest"

    sudo cp -r "$src" "$dest"
    log "${GREEN}:: Copied: $rel_src → $dest${NC}"
}

install_pacman() {
    local -a to_install=()
    local pkg

    # Step 1: Check which packages are already installed vs. missing
    for pkg in "$@"; do
        if pacman -Q "$pkg" &>/dev/null; then
            log "${CYAN}:: Already installed: $pkg${NC}"
        else
            to_install+=("$pkg")
        fi
    done

    # If everything requested is already present, exit early
    if [[ ${#to_install[@]} -eq 0 ]]; then
        return 0
    fi

    # Step 2: Run pacman silently on the terminal, but log its output to $LOG_FILE
    sudo pacman -S --needed --noconfirm "${to_install[@]}" >> "$LOG_FILE" 2>&1

    # Step 3 & 4: Verify installation status post-execution and log accordingly
    for pkg in "${to_install[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            log "${GREEN}:: Installed: $pkg${NC}"
        else
            log "${RED}:: Installation Failed: $pkg${NC}"
        fi
    done
}

confirm() {
    local prompt="${1}"
    local reply

    echo ""
    read -rp "$(echo -e "${BLUE}$prompt [y/N]: ${NC}")" reply

    # Check if the response matches strictly 'Y' or 'y'
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}:: [Yes]${NC}"
        return 0
    else
        echo -e "${RED}:: [No]${NC}"
        return 1
    fi
}

# ==============================================================================
# Execution: System update
# ==============================================================================
if confirm ":: Do you want to update your system now?"; then
    sudo pacman -Syyu >> "$LOG_FILE" 2>&1
    log "${GREEN}:: Done.${NC}"
fi

# ==============================================================================
# Execution: Pacman Packages Installation
# ==============================================================================
echo ""
log "${BLUE}Installing Pacman Packages${NC}"
log "${BLUE}-------------------------------------------${NC}"

install_pacman \
    "mangowm" \
    "xorg-xwayland" \
    "xdg-desktop-portal" \
    "xdg-desktop-portal-wlr" \
    "xdg-desktop-portal-gtk" \
    "wl-clipboard" \
    "grim" \
    "slurp" \
    "satty" \
    "zsh" \
    "zsh-history-substring-search" \
    "zsh-syntax-highlighting" \
    "foot" \
    "starship" \
    "swaybg" \
    "swayidle" \
    "wlr-randr" \
    "brightnessctl" \
    "gnome-keyring" \
    "libsecret" \
    "mpv" \
    "ttf-jetbrains-mono-nerd" \
    "quickshell"

# ==============================================================================
# Execution: Symlinks Deployment
# ==============================================================================
echo ""
log "${BLUE}Configuring system assets (Privileged)${NC}"
log "${BLUE}-------------------------------------------${NC}"
create_symlink "fastfetch" "$HOME/.config/fastfetch"
create_symlink "foot" "$HOME/.config/foot"
create_symlink "mango" "$HOME/.config/mango"
create_symlink "mpv" "$HOME/.config/mpv"
create_symlink "shell" "$HOME/.config/quickshell"
create_symlink "zsh" "$HOME/.config/zsh"
create_symlink "zsh/.zprofile" "$HOME/.zprofile"
create_symlink "themes/starship/starship.toml" "$HOME/.config/starship.toml"
create_symlink "themes/gtk/${GTK_THEME}" "$HOME/.local/share/themes/${GTK_THEME}"
create_symlink "themes/gtk/${GTK_THEME}/gtk-3.0" "$HOME/.config/gtk-3.0"
create_symlink "themes/gtk/${GTK_THEME}/gtk-4.0" "$HOME/.config/gtk-4.0"
create_symlink "themes/micro/${MICRO_THEME}.micro" "$HOME/.config/micro/colorschemes/${MICRO_THEME}.micro"
create_symlink "themes/micro/settings.json" "$HOME/.config/micro/settings.json"

# ==============================================================================
# Execution: System-wide Assets Copying (Sudo)
# ==============================================================================
echo ""
log "${BLUE}Installing System-Wide Assets (Privileged)${NC}"
log "${BLUE}-------------------------------------------${NC}"

copy_item_sudo "themes/xcursor/${XCURSOR_THEME}" "/usr/share/icons/${XCURSOR_THEME}"
copy_item_sudo "themes/grub/${GRUB_THEME}" "/usr/share/grub/themes/${GRUB_THEME}"
copy_item_sudo "themes/grub/grub" "/etc/default/grub"
copy_item_sudo "themes/plymouth/${PLYMOUTH_THEME}" "/usr/share/plymouth/themes/${PLYMOUTH_THEME}"

# ==============================================================================
# Execution: System configurations (Sometimes sudo)
# ==============================================================================
echo ""
log "${BLUE}Configuring system assets (Privileged)${NC}"
log "${BLUE}-------------------------------------------${NC}"

sudo chsh -s "$(which zsh)" "$USER" >> "$LOG_FILE" 2>&1
log "${GREEN}:: Default shell set to [$(which zsh)]${NC}"

gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
gsettings set org.gnome.desktop.interface color-scheme "${GTK_MODE}"

log "${GREEN}:: GTK theme set to [${GTK_THEME}][${GTK_MODE}]${NC}"
log "${GRAY}:: Skipped GTK setup...${NC}"

# ==============================================================================
# Execution: System configurations (Sometimes sudo)
# ==============================================================================
echo ""
log "${BLUE}Configuring GRUB and Plymouth (Privileged)${NC}"
log "${BLUE}-------------------------------------------${NC}"
log "${GRAY}This may take a few minutes (at most).${NC}"

sudo grub-mkconfig -o /boot/grub/grub.cfg >> "$LOG_FILE" 2>&1
sudo plymouth-set-default-theme -R cross-hud >> "$LOG_FILE" 2>&1
sudo mkinitcpio -P >> "$LOG_FILE" 2>&1
log "${GREEN}:: Grub theme set to [${GRUB_THEME}]${NC}"
log "${GREEN}:: Plymouth theme set to [${PLYMOUTH_THEME}]${NC}"

echo ""
log "${BLUE}Installation Completed Successfully${NC}"

if confirm ":: Do you want to clean up redundant bash files?"; then
	log "${YELLOW}:: Deleting all files starting with [.bash] from [${HOME}]${NC}"
	rm $HOME/.bash*
	log "${GREEN}Done.${NC}"
fi

if confirm ":: Do you want to setup Docker?"; then
    log "${YELLOW}:: Configuring Docker and Docker Compose...${NC}"
    install_pacman "docker" "docker-compose"
    getent group docker &>/dev/null || sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable --now docker.service >> "$LOG_FILE" 2>&1
    log "${GREEN}:: Done. You will need to reboot (or log out and back in).${NC}"
fi

if confirm ":: Do you want to install Thunar (file manager)?"; then
    log "${YELLOW}:: Installing Thunar, Thunar Volume Manager and GVFS...${NC}"
    install_pacman "thunar" "thunar-volman" "gvfs"
    log "${GREEN}:: Done.${NC}"
fi
 
echo ""
log "${GRAY}Logs saved to ${LOG_FILE}.${NC}"
log "${GRAY}Backups saved to ${BACKUP_DIR}.${NC}"

if confirm ":: Do you want to reboot now?"; then
    echo ""
    sudo reboot
else
    log "${BLUE}===========================================${NC}"
fi
