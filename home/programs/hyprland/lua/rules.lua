local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

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

    no_focus = true,
})

-- Telegram in workspace 1
hl.window_rule({
	name = "telegram-workspace1",
	match = { class = "org.telegram.desktop"  },
	workspace = 1,
})

-- Librewolf browser in workspace 2
hl.window_rule({
	name = "librewolf-workspace2",
	match = { class = "librewolf"  },
	workspace = 2,
})
