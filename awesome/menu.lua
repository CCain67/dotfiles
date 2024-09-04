local awful = require("awful")
local hotkeys_popup = awful.hotkeys_popup
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local profile = require("user.profile")
local editor_cmd = profile.terminal .. " -e " .. profile.editor

local myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "edit config", editor_cmd .. " .config/awesome"},
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu }
local menu_terminal = { "open terminal", profile.terminal }

main_menu = awful.menu({
    items = {
        menu_awesome,
        menu_terminal
    }
})