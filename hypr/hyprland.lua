terminal    = "kitty"
fileManager = "nautilus"
menu        = "hyprlauncher"

home = os.getenv("HOME")
current_path = os.getenv("PATH")
quickshell = "quickshell -p " .. home .. "/.config/quickshell/Shell.qml"

require("modules.colors")

hl.permission({ 
    binary = "/usr/(bin|local/bin)/grim", 
    type = "screencopy", 
    mode = "allow" 
})

hl.permission({ 
    binary = "/usr/(bin|local/bin)/hyprlock", 
    type = "screencopy", 
    mode = "allow" 
})

hl.permission({ 
    binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", 
    type = "screencopy", 
    mode = "allow" 
})

hl.env("ZDOTDIR", home .. "/.config/zsh")

hl.env("HYPRCURSOR_THEME", "Future-Cyan")
hl.env("HYPRCURSOR_SIZE", "48")

-- Fallback XCURSOR
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")

-- hl.env("LC_TIME", "en_GB.UTF-8")

hl.env("DOTNET_ROOT", "/usr/bin/dotnet")
hl.env("PATH", current_path .. ":/usr/bin/dotnet:/usr/bin/dotnet/tools")

-- hl.env("QML_IMPORT_PATH", home .. "/.config/quickshell/Plugins")
hl.env("EDITOR", "micro")
-- hl.env("HYPRSHOT_DIR", home .. "/Pictures/Screenshots")
-- hl.env("GTK_USE_PORTAL", "1")

-- Core environment parameters
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Toolkit Backend Overrides
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering = true
    },
    ecosystem = {
        enforce_permissions = true,
        no_donation_nag = true,
        no_update_news = true,
    }
})

require("modules.autostart")
require("modules.monitors")
require("modules.theme")
require("modules.animations")
require("modules.devices")
require("modules.keybinds")
require("modules.ruleset")
