hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- Laptop
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = "1.2",
})

-- External (big)
hl.monitor({
	output = "HDMI-A-2",
	mode = "highres",
	position = "auto-center-up",
	scale = "1.0",
})

-- Workspaces rules
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-2" })
