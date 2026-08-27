-- MONITORS
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1.07,
})

-- INPUT
hl.config({
    input = {
        kb_layout  = "us, kh",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            disable_while_typing = true,
            natural_scroll       = true,
            tap_to_click         = true,
        },
    },
})

-- LOOK AND FEEL
hl.config({
    general = {
        layout     = "dwindle",
        gaps_in    = 4,
        gaps_out   = 8,
        border_size = 2,
        col = {
            active_border   = "rgba(47474877)",
            inactive_border = "rgba(1b1c1d33)",
        },
    },
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
        disable_hyprland_logo = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

-- LAYOUTS
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
})

-- GESTURES
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.config({
    gestures = {
        workspace_swipe_distance = 300,
        workspace_swipe_invert   = true,
    },
})

-- ANIMATIONS
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

-- WINDOW RULES
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^pavucontrol$" },
    float = true,
    size  = {"900", "650"},
})

hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "^nm-connection-editor$" },
    float = true,
})
