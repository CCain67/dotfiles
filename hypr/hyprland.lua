-- Hyprland config — Lua migration draft.
-- Drafted 2026-08-17, updated same day against the real wiki docs:
--   https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
--   https://wiki.hypr.land/Configuring/Basics/Dispatchers/
--   https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- while this system is still on Hyprland 56.2 (Lua config ships in 57).
--
-- All dispatcher/window-rule calls below are now confirmed against the
-- wiki's Dispatchers and Window Rules pages — no more guessed syntax.


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "DP-2",
    mode     = "2560x1440@199.90",
    position = "0x0",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "konsole"
local browser      = "firefox"
local fileManager = "dolphin"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,pkcs11,ssh")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("quickshell -p ~/.config/quickshell")
    hl.exec_cmd('hyprctl setcursor "Capitaine Cursors (Gruvbox)" 32')
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Capitaine Cursors (Gruvbox)")
hl.env("XCURSOR_SIZE", "32")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 8,
        gaps_out = 16,

        border_size = 2,

        col = {
            active_border   = "rgba(504945ff)",
            inactive_border = "rgba(252524ff)",
        },

        resize_on_border = true,

        layout = "dwindle",
    },

    decoration = {
        rounding = 12,

        blur = {
            enabled            = true,
            size               = 6,
            passes             = 2,
            new_optimizations  = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOut", { type = "bezier", points = { {0.0, 0.0}, {0.2, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "easeOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOut", style = "slide" })

-- Layouts
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- hl.config({
--     dwindle = {
--         pseudotile     = true,
--         preserve_split = true,
--     },
-- })


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Confirmed via wiki: `workspace` is a string effect on the rule table,
-- can be suffixed with " silent" — same as classic syntax.
hl.window_rule({
    name  = "firefox-workspace",
    match = { class = "^(firefox)$" },
    workspace = "3 silent",
})

hl.window_rule({
    name  = "dolphin-workspace",
    match = { class = "^(dolphin)$" },
    workspace = "4 silent",
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Shell (quickshell IPC)
-- Confirmed via wiki: `global` is its own dispatcher — hl.dsp.global(string) —
-- "activate a dbus global shortcut" (Binds > Global Shortcuts), not a bind flag
-- like the old `bind = mod, D, global, target` syntax.
hl.bind(mainMod .. " + D", hl.dsp.global("quickshell:launcher"))
hl.bind(mainMod .. " + P", hl.dsp.global("quickshell:session"))
hl.bind(mainMod .. " + SPACE", hl.dsp.global("quickshell:dashboard"))

-- Core
hl.bind(mainMod .. " + Return",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + F",    hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + V",    hl.dsp.exec_cmd("code --ozone-platform=x11"))

-- Confirmed via wiki: window.close({window?}) = classic killactive.
-- exit() = classic exit, though the wiki now recommends `hyprshutdown`
-- instead (and warns uwsm users specifically to avoid this dispatcher) —
-- keeping plain exit() here since the current .conf doesn't use
-- hyprshutdown either; worth reconsidering when we actually cut over.
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
-- Confirmed: window.fullscreen({ mode?, action?, layout_aware?, window? });
-- action can be toggle/set/unset.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Focus
-- Confirmed via wiki: Direction is one of l / r / u / d (not full words).
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move windows
-- Confirmed: window.move({ direction, group_aware?, window? }) moves a
-- window in a direction (separate overload from window.move({ workspace }) below).
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window control
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
