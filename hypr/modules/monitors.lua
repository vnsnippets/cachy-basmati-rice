-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- USB-C Port Screen
hl.monitor({
    output = "DP-2",
    mode = "highres",
    position = "0x0",
    scale = 1,
})

-- Laptop screen
hl.monitor({
    output = "eDP-1",
    mode = "highres",
    position = "760x1440",
    scale = 1,
})

-- Fallback rule for all other ports (unnamed output)
hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = 1,
})