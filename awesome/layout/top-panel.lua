--  Bottom Right Panel
local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local wibox = require('wibox')

local BrightnessWidget = require('widget.brightness')
local BatteryWidget = require('widget.battery')
local TimeWidget = require('widget.time')
local DateWidget = require('widget.date')
local TagList = require('widget.tag-list')
local MicrophoneWidget = require('widget.microphone')
local NetworkWidget = require('widget.network')
local VolumeWidget = require('widget.volume')
local clickable_container = require('widget.clickable-container')

local dashboard = require("popups.dashboard.main")

local TopPanel = function(s)
    local panel = wibox({
        ontop = false,
        visible = true,
        screen = s,
        height = dpi(32),
        width = s.geometry.width - beautiful.useless_gap * 2 - dpi(8),
        x = s.geometry.x + (s.geometry.width - (s.geometry.width - beautiful.useless_gap * 2)) / 2,
        y = s.geometry.y + beautiful.useless_gap,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        border_color = beautiful.bg_normal,
        border_width = dpi(4)
    })

    panel:struts({
        top = dpi(32) + beautiful.useless_gap * 2 + dpi(4)
    })

    local layoutbox = awful.widget.layoutbox(s)

    local system_widgets = wibox.widget {
        {
            {
                NetworkWidget(beautiful.red),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                BrightnessWidget(beautiful.orange),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                VolumeWidget(beautiful.yellow),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                MicrophoneWidget(beautiful.green),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                BatteryWidget(beautiful.cyan),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                DateWidget(beautiful.blue),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            {
                TimeWidget(beautiful.purple),
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.place,
        halign = "right"
    }

    -- Dashboard button widget
    local widget_dashboard_button = wibox.widget {
        {
            markup = "<span color='" .. beautiful.system_white_dark .. "'> </span>",
            align = 'center',
            valign = 'center',
            font = beautiful.font .. ' 14',
            widget = wibox.widget.textbox
        },
        widget = clickable_container
    }

    widget_dashboard_button:connect_signal("button::release", function()
        dashboard.visible = not dashboard.visible
    end)

    local distribution = wibox.widget {
        {
            widget_dashboard_button,
            right = 10,
            left = 10,
            widget = wibox.container.margin
        },
        {
            layoutbox,
            right = 10,
            left = 10,
            widget = wibox.container.margin
        },
        {
            TagList(s),
            left = 10,
            right = 10,
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
    }

    panel:setup {
        layout = wibox.layout.align.horizontal,
        expand="none",
        distribution,
        nil,
        system_widgets
    }

    return panel
end

return TopPanel
