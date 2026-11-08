This is not your everyday rice - this is **Basmati** rice 🍚

---

#### Installation

Limit Snapper (BTRFS) frequency
```conf
# Edit /etc/snapper/configs/root

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"

# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="20"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots
TIMELINE_CREATE="no"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
```

Symlink the following with "./*" paths being relative from the script's pwd:​‌
- `./fastfetch` → `$HOME/.config/fastfetch`
- `./foot` → `$HOME/.config/foot`
- `./mako` → `$HOME/.config/mako`
- `./mango` → `$HOME/.config/mango`
- `./mpv` → `$HOME/.config/mpv`
- `./shell` → `$HOME/.config/quickshell`
- `./zsh` → `$HOME/.config/zsh`
- `./themes/starship/starship.toml` → `$HOME/.config/starship.toml`
- `./themes/gtk/catppuccin-mocha-mauve` → `$HOME/.local/share/themes/catppuccin-mocha-mauve`
- `./themes/gtk/catppuccin-mocha-mauve/gtk-3.0` → `$HOME/.config/gtk-3.0`
- `./themes/gtk/catppuccin-mocha-mauve/gtk-4.0` → `$HOME/.config/gtk-4.0`
- `./themes/micro/catppuccin.micro` → `$HOME/.config/micro/colorschemes/catppuccin.micro`
- `./themes/micro/settings.json` → `$HOME/.config/micro/settings.json`

Copy the following:
- `./themes/xcursor/BibataModernIce` → `/usr/share/icons/BibataModernIce`
- `./themes/xcursor/GoogleDotBlue` → `/usr/share/icons/GoogleDotBlue`
- `./themes/sddm` → `/usr/share/sddm/themes/material`
- `./themes/grub/catppuccin` → `/usr/share/grub/themes/catppuccin`
- `./themes/plymouth/cross-hud` → `/usr/share/plymouth/themes/cross-hud`

**Plymouth (Splash Screen)**
```bash
# Prerequisites:
# Plymouth theme folder has been copied to your system

# Command: sudo plymouth-set-default-theme -R <theme-folder-name>
sudo plymouth-set-default-theme -R cross-hud
sudo mkinitcpio -P
```

**GRUB**
```bash
# Prerequisites:
# 1. GRUB theme folder has been copied to your system
# 2. Content of ./themes/grub/grub file is copied to /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**SDDM**
```conf
# Edit file at /etc/sddm.conf

[Theme]
# Configuration: Current=<theme-name>
Current=material
```

---

#### Test Scripts
```bash
# Launch in DEBUG mode
DEBUG=1 quickshell -p ~/.config/shell/Shell.qml

# Screen utilities
wlr-randr --output eDP-1 --off
wlr-randr --output eDP-1 --on --pos 0,0 --mode 1920x1080 --output HDMI-A-1 --on --pos 0,0 --mode 1920x1080

# Idling and wake
swayidle -w \                                                          
  timeout 5 'brightnessctl --save --exponent=4 set 10%' \
    resume 'brightnessctl --restore' \
  timeout 10 '$HOME/.config/mango/scripts/screen-ctl.sh --sleep' \
    resume '$HOME/.config/mango/scripts/screen-ctl.sh --wake'

# Symbolic Linking
ln -sf <source-path> <target-path>
ln -sf $HOME/.local/apps/obsidian.desktop ./.local/share/applications/obsidian.desktop

# Simulate notifications
notify-send -i discord -a "Discord" "Jane Doe" "Hey\n Are we still jumping on that raid tonight?"; sleep 2; notify-send -u critical -i dialog-warning -a "System Monitor" "Thermal Warning" "CPU temperature has exceeded 85°C"; sleep 2; notify-send -h string:transient:true -i Security "YubiKey" "Touch your security key..."; sleep 2; notify-send -h string:x-canonical-private-synchronous:volume -h int:value:40 -i audio-volume-medium "Volume" "40%"; sleep 2; notify-send -h string:x-canonical-private-synchronous:volume -h int:value:65 -i audio-volume-high "Volume" "65%"

# Simulate privilege
pkexec bash
```
---

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

---

### Manual Configurations
Fixing some quirks or personalizing some stuff.

#### Controlling Laptop Lid Events
| Event             | Condition                           | Sleep/Wake | Screen         |
| :---------------- | : --------------------------------- | :--------- | :------------- | 
| Laptop Lid Closed | Default                             | Sleep      | Turn off EDP-1 |
|                   | Connected to external power or dock | Ignore     | Turn off EDP-1 |
| Laptop Lid Opened | -                                   | Wake       | Turn on EDP-1  |

Edit **systemd-logind**
```bash
sudoedit /etc/systemd/logind.conf
```

  Ensure the following configurations are set.
  ```toml
  [Login]
  # Sets default behaviour on lid close/open as suspend/wake
  HandleLidSwitch=suspend
  
  # Overrides default lid behaviour to not suspend when
  # External Power or Dock detected
  HandleLidSwitchExternalPower=ignore
  HandleLidSwitchDocked=ignore
  ```

Edit Mango configurations to enable/disable laptop screen
```bash
micro ~/.config/mango/config.conf
```

  Set the following commands.
  ```toml
  # Disable screen when lid is closed
  switchbind=fold,spawn,wlr-randr --output eDP-1 --off
  
  # Enable screen when lid is opened
  switchbind=unfold,spawn,wlr-randr --output eDP-1 --on
  ```


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

#### Desktop Files (Custom)
Antigravity
```toml
[Desktop Entry]
Name=Antigravity
Comment=Google Antigravity
Exec=/home/[user]/.local/apps/antigravity/2.29.0/antigravity %U
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=Antigravity
Icon=/home/[user]/.local/apps/antigravity/icon.png
```

Obsidian
```toml
[Desktop Entry]
Name=Obsidian (1.14.5)
Comment=A private and flexible writing and knowledge base
Exec="/home/[user]/.local/apps/obsidian/1.14.5/AppRun" %u
Terminal=false
Type=Application
Icon=/home/[user]/.local/apps/obsidian/1.14.5/obsidian.png
Categories=Office;Utility;TextEditor;
StartupWMClass=obsidian
MimeType=x-scheme-handler/obsidian;
```

Visual Studio Code
```toml
[Desktop Entry]
Name=Visual Studio Code (1.145.2)
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/home/[user]/.local/apps/vscode/1.145.2/bin/code
Icon=/home/[user]/.local/apps/vscode/1.145.2/resources/app/resources/linux/code.png
Type=Application
StartupNotify=true
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
```