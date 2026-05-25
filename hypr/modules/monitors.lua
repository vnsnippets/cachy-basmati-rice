-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- USB-C Port Screen
hl.monitor({
    output = "DP-2",
    mode = "highres",
    position = "auto-up",
    scale = 1,
})

-- Laptop screen
hl.monitor({
    output = "eDP-1",
    mode = "highres",
    position = "auto",
    scale = 1,
})

-- Fallback rule for all other ports (unnamed output)
hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = 1,
})