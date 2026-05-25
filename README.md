## Ricing Arch
This is not your everyday rice - this is **Basmati** rice 🍚

### Quickshell
**Network Widget** requires the [NetworkMonitorPlugin](https://github.com/vnsnippets/qt-plugin-network-monitor) which was developed by yours truly.

You will need to set the `QML_IMPORT_PATH` environment variable to point to where you drop the plugin (after build). You can set that through your `hyprland.conf` - see my own version in this repository itself.

> One of these days, I will get some sleep.   
> Then I will package the plugin as a GitHub Release.

In all transparency, I make no claims on the plugin's quality.   
Use at your own risk.

### Custom Scripts
Waking from sleep, Network Manager would hang - so I created a script:
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