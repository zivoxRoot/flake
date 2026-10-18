hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "compose:ralt",

        touchpad = {
            natural_scroll = true,
			disable_while_typing = false;
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
