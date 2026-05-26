hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 1,

        col = {
            -- active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            active_border = active_border,
            inactive_border = inactive_border
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle"
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.96,
        inactive_opacity = 0.96,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 2,
            vibrancy  = 0.1696,
            new_optimizations = true
        },
    },

    animations = {
        enabled = true
    },
})
