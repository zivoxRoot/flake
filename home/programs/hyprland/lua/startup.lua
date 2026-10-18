hl.on("hyprland.start", function ()
	-- Startup apps
	hl.exec_cmd("Telegram")
	hl.exec_cmd("librewolf")
	hl.exec_cmd("kitty", { workspace = 3 })
	hl.exec_cmd("claude-desktop", { workspace = 4 })

	-- Desktop components
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("dunst")
	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprsunset")

	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)
