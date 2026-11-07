hl.config({
    general = {
        gaps_in  = 8,
        gaps_out = 16,

		-- border_size = 2,
        border_size = 0,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,

        active_opacity   = 0.95,
        inactive_opacity = 0.85,

        shadow = {
            enabled      = true,
        },

        blur = {
            enabled   = false,
	    size = 6,
	    passes = 2,
	    variant = "frost",
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
