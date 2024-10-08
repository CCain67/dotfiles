local awful = require('awful')
local beautiful = require("beautiful")
local gears = require("gears")

local top_panel = require('layout.top-panel')
-- local bottom_panel = require('layout.bottom-panel')
-- local bottom_secondary_panel = require('layout.bottom-secondary-panel')
-- local dashboard = require('layout.dashboard')

require('layout.titlebar')

awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.max,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral
}

local profile = require("user.profile")
beautiful.wallpaper = profile.wallpaper

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
    function(s)
        set_wallpaper(s)
        awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])
        s.top_panel = top_panel(s)
        -- s.bottom_panel = bottom_panel(s)
        -- s.bottom_secondary_panel = bottom_secondary_panel(s)
        -- s.dashboard_panel = dashboard(s)
    end
)
