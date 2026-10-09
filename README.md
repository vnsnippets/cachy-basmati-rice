## Ricing Arch
This is not your everyday rice - this is **Basmati** rice 🍚

### Quickshell
**Network Widget** requires the [NetworkMonitorPlugin](https://github.com/vnsnippets/qt-plugin-network-monitor) which was developed by yours truly.

You will need to set the `QML_IMPORT_PATH` environment variable to point to where you drop the plugin (after build). You can set that through your `hyprland.conf` - see my own version in this repository itself.

> One of these days, I will get some sleep.   
> Then I will package the plugin as a GitHub Release.

In all transparency, I make no claims on the plugin's quality.   
Use at your own risk.

#### Test Scripts
```bash
# Launch in DEBUG mode
DEBUG=1 quickshell -p ~/.config/shell/Shell.qml

# Screen utilities
wlr-randr --output eDP-1 --off
wlr-randr --output eDP-1 --on --pos 0,0 --mode 1920x1080 --output HDMI-A-1 --on --pos 0,0 --mode 1920x1080

# Idling and wake
swayidle -w \\
  timeout 15 'brightnessctl --save --exponent=4 set 10%' \\
    resume 'brightnessctl --restore --exponent=2' \\
  timeout 30 '~/.config/mango/scripts/sleep.sh --sleep' \\
    resume '~/.config/mango/scripts/sleep.sh --wake'\

# Symbolic Linking
ln -sf <source-path> <target-path>
ln -sf $HOME/.local/apps/obsidian.desktop ./.local/share/applications/obsidian.desktop

# Simulate notifications
notify-send -i discord -a "Discord" "Jane Doe" "Hey\n Are we still jumping on that raid tonight?"; sleep 2; notify-send -u critical -i dialog-warning -a "System Monitor" "Thermal Warning" "CPU temperature has exceeded 85°C"; sleep 2; notify-send -h string:transient:true -i Security "YubiKey" "Touch your security key..."; sleep 2; notify-send -h string:x-canonical-private-synchronous:volume -h int:value:40 -i audio-volume-medium "Volume" "40%"; sleep 2; notify-send -h string:x-canonical-private-synchronous:volume -h int:value:65 -i audio-volume-high "Volume" "65%"

# Simulate privilege
pkexec bash
```

### Additional Packages
For some of my utilities, additional packages were required:
| Utility | Packages |
| :------ | :------- |
| ZSH | `zsh-history-substring-search` `zsh-syntax-highlighting` |
| .NET Development | `dotnet-sdk` `aspnet-runtime` `dotnet-targeting-pack` `aspnet-targeting-pack` `netstandard-targeting-pack` |
| Docker | `docker` `docker-compose` |
| GTK Theme | `nwg-look` `catppuccin-gtk-theme-mocha` |
| Fonts | `ttf-jetbrains-mono-nerd` |
| Keyring | `gnome-keyring` |
| File Manager | `nautilus` |
| Telegram | `telegram-desktop` with themes from https://github.com/catppuccin/telegram |

### Manual Configurations
Fixing some quirks or personalizing some stuff.

#### ZSH
The `setup.sh` script here configures everything I need for ZSH and configurations point ZSH to use my configurations - but cleanup of default files is still required manually:   
```bash
rm ~/.zshrc ~/.zcompdump ~/.zsh_history
```

#### Network Manager
- Waking from sleep, Network Manager would hang - so I created a script to restart it clean on wake:
  ```bash
  # /usr/lib/systemd/system-sleep/ath11k-resume
  #!/bin/sh
  case "$1" in
    post)
      /usr/bin/modprobe -r ath11k_pci 2>/dev/null
      /usr/bin/modprobe ath11k_pci
      /usr/bin/systemctl restart NetworkManager
      ;;
  esac
  ```

#### File Manager (Nautilus/Dolphin)
- Dedicated storage partition (in BTRFS) would not appear in File Manager, requiring a manual fix.
  ```
  # /etc/fstab
  ...
  UUID=<Storage-UUID> /mnt/storage   btrfs   defaults,noatime,compress=zstd:1,x-gvfs-show 0 0
  ...
  ```

- Setting up default folders (Documents, Pictures etc.) required a shell command:
  ```bash
  xdg-user-dirs-update
  ```

#### Firefox
Importing passwords and bookmarks.

#### Visual Studio Code
- Setting custom font (with Nerd Symbols) required changing the preset font family.
  - `Ctrl + ,` to open settings
  - Navigate to **Text Editor** > **Font** > **Font Family**
  - Set desired font (e.g. `'JetBrainsMono Nerd Font', monospace`)

- Extensions installed:
  - `Container Tools` for Docker utilities
  - `C# Dev Kit` for .NET (C#) Development
  - `Catppuccin for VSCode` and `Catppuccin Icons for VSCode` as primary themes
  - `Dracula Theme Official` and `GitHub Theme` as alternate themes
  - `Qt Extension Pack` for QT / Quickshell development

#### GitHub SSH
Did you really think I will lay out my GitHub SSH credentials here?