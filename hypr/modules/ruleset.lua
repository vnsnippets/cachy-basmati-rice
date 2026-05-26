-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignore maximize requests from all apps. You'll probably like this.
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize"
})
-- suppressMaximizeRule:set_enabled(false)

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true
})

-- File Manager
hl.window_rule({
    name  = "open-nautilus-floating",
    match = { class = "^(org.gnome.Nautilus)$" },

    float = true,
    size = "920 600",
    center = true,
    max_size = "1000 800"
})

hl.window_rule({
    name  = "open-dolphin-floating",
    match = { class = "^(org.kde.dolphin)$" },

    float = true,
    size = "920 600",
    center = true,
    max_size = "1000 800"
})

-- Firefox
hl.window_rule({
    name = "firefox-disable-opacity",
    match = { class = "^(firefox)$" },
    opacity = "1 override",
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.layer_rule({
    name = "quickshell-basmati-disable-animation",
    match = { namespace = "qs-basmati-canvas" },
    no_anim = true
})
