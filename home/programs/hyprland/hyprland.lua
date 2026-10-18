local mod = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))

for i = 1, 9 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({workspace = i}))
end
