local mainMod = "SUPER"

local terminal = "kitty"
local fileManager = "nautilus"
local mainMenu = "pkill rofi || $HOME/my-dotfiles/scripts/menu.sh"
local appMenu = "pkill rofi || rofi -show drun -i -matching fuzzy"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ "fullscreen", "toggle" }))

-- Enter the passthrough submap
hl.bind("SUPER + F12", hl.dsp.submap("vm"))

-- Nothing is bound here except the exit key,
-- so everything else goes to the focused VM window
hl.define_submap("vm", function()
    hl.bind("SUPER + F12", hl.dsp.submap("reset"))
end)

-- Daily note
-- hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("$HOME/dots/s/daily_note.sh"))

-- Menu
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(mainMenu))
hl.bind("ALT + Space", hl.dsp.exec_cmd(appMenu))

-- Notifications
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dunstctl history-pop"))  -- Pop latest notification
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("dunstctl set-paused toggle"))  -- Toggle do not disturb
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dunstctl close-all"))  -- Close all visible notifications
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd("dunstctl context"))  -- Open the actions menu

-- Move focus with mainMod + vim keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Swap focus with mainMod + shift + vim keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Resize windows with mainMod + ctrl + vim keys
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- Scripts
-- hl.bind("ALT + O", hl.dsp.exec_cmd("$HOME/dots/s/speech_to_text.sh")) -- Speech to text

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && $HOME/my-dotfiles/scripts/volume-notif.sh"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && $HOME/my-dotfiles/scripts/volume-notif.sh"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && $HOME/my-dotfiles/scripts/brightness-notif.sh"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && $HOME/my-dotfiles/scripts/brightness-notif.sh"), { locked = true, repeating = true })
