--  Bottom Right Panel
local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')

local BrightnessWidget = require('widget.brightness')
local TagList = require('widget.tag-list')
local MicrophoneWidget = require('widget.microphone')
local NetworkWidget = require('widget.network')
local VolumeWidget = require('widget.volume')

local BottomPanelSecondary = function(s)
    local panel = wibox({
        ontop = false,
        visible = true,
        screen = s,
        height = dpi(32),
        width = "750",
        x = s.geometry.width - (-s.geometry.x + beautiful.useless_gap * 2 + 750),
        y = s.geometry.y + s.geometry.height - dpi(32) - beautiful.useless_gap * 2,
        stretch = true,
        bg = beautiful.bg_normal .. "00",
        fg = beautiful.fg_normal
    })

    panel:struts({
        bottom = dpi(32) + beautiful.useless_gap * 2
    })

    local layoutbox = awful.widget.layoutbox(s)

    local distribution = wibox.widget {
        {
            {
                NetworkWidget(beautiful.system_cyan_dark),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                BrightnessWidget(beautiful.system_yellow_dark),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                VolumeWidget(beautiful.system_blue_dark),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                MicrophoneWidget(beautiful.system_red_dark),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                layoutbox,
                right = 10,
                left = 20,
                top = 5,
                bottom = 5,
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal
        },
        nil,
        {
            TagList(s),
            left = 5,
            right = 5,
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
    }

    local mainLayer = wibox.widget {
        wibox.widget {
            distribution,
            left = 0,
            right = 0,
            top = 2,
            bottom = 2,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        forced_width = 750,
        forced_height = dpi(32),
        widget = wibox.container.background

    }

    panel:setup {
        layout = wibox.layout.align.horizontal,
        mainLayer
    }

    return panel
end

return BottomPanelSecondary
