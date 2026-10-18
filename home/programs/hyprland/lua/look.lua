hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

		-- border_size = 2,
        border_size = 0,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
        },

        blur = {
            enabled   = false,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },
})
