hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- Laptop
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = "1.2",
})

-- External (horizontal)
hl.monitor({
	output = "HDMI-A-2",
	mode = "2560x1440@60",
	position = "auto-center-up",
	scale = "1.25",
})

-- External (vertical)
hl.monitor({
	output = "DP-1",
	-- mode = "3840x1440@60",
	mode = "2560x1440@60",
	position = "auto-left",
	scale = "1.0",
	transform = 3,
})

-- Workspaces rules
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-2" })
