-- Author: CCain67

local gears = require("gears")         -- Utilities such as color parsing and objects
local awful = require("awful")         -- Standard awesome library

local beautiful = require("beautiful") -- Theme handling library
beautiful.init(require("theme"))

local naughty = require("naughty")     -- Notification library

-- on startup
awful.spawn.with_shell("~/.config/awesome/scripts/autorandr.sh")
awful.spawn.with_shell("picom --experimental-backends")
awful.spawn.with_shell("pactl set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink")
awful.spawn.with_shell("pactl set-default-source alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__source")

-- Load the profile configuration file
local profile = require("user.profile")

modkey = profile.modkey
terminal = profile.terminal
editor = profile.editor
editor_cmd = profile.editor_cmd


-- must be called after beautiful.init
if profile.generate_background then
    require("scripts.generate_background_colors")
    awful.spawn.with_shell("python3 ~/.config/awesome/scripts/asset_generation/generate_wallpaper.py")
end
if profile.generate_rofi_config then
    require("scripts.generate_rofi_config")
end
if profile.generate_zathura_config then
    require("scripts.generate_zathura_config")
end
beautiful.icon_theme = 'Gruvbox-Material-Dark'

require("awful.autofocus")
require("layout")
require("menu")
require("user")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Startup failed successfully!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error",
        function(err)
            -- Make sure we don't go into an endless error loop
            if in_error then return end
            in_error = true
            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Startup failed successfully!",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end