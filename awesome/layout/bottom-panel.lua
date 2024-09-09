local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi

local batteryWidget = require('widget.battery')
local timeWidget = require('widget.time')
local dateWidget = require('widget.date')
local cpuWidget = require('widget.cpu-meter')
local gpuWidget = require('widget.gpu-meter')
local ramWidget = require('widget.ram-meter')
local clickable_container = require('widget.clickable-container')

-- Wrap each widget with a background and margin container
local function wrap_widget(widget)
    return wibox.widget {
        {
            widget,
            widget = wibox.container.margin,
            margins = dpi(8),  -- Adjust the margins as needed
            left = dpi(8),
            right = dpi(8)
        },
        bg = beautiful.system_black_light,  -- Change this to your preferred color
        widget = wibox.container.background,
        --shape = gears.shape.rounded_rect  -- Add this if you want rounded corners
    }
end

local BottomPanel = function(s)
    local panel = wibox({
        ontop = false,
        visible = true,
        screen = s,
        height = dpi(32),
        width = "750",
        x = s.geometry.x + beautiful.useless_gap * 2,
        y = s.geometry.y + s.geometry.height - dpi(32) - beautiful.useless_gap * 2,
        stretch = true,
        bg = beautiful.bg_normal .. "00",
        fg = beautiful.fg_normal
    })

    panel:struts({
        bottom = dpi(32) + beautiful.useless_gap * 2
    })

    -- Cleaned up resourcesInfo
    local resourcesInfo = wibox.widget {
        {
            dateWidget(beautiful.system_magenta_dark),
            timeWidget(beautiful.system_blue_dark),
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(18)
        },
        {
            cpuWidget(beautiful.system_green_dark),
            ramWidget(beautiful.system_yellow_dark),
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(18)
        },
        {
            gpuWidget(beautiful.system_red_dark),
            batteryWidget(beautiful.system_cyan_dark),
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(18)
        },
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(18)
    }

    -- Dashboard button widget
    local widget_dashboard_button = wibox.widget {
        {
            markup = "<span color='" .. beautiful.system_white_dark .. "'> </span>",
            align = 'center',
            valign = 'center',
            font = beautiful.font .. ' 16',
            widget = wibox.widget.textbox
        },
        widget = clickable_container
    }

    -- Main distribution with proper alignment
    local distribution = wibox.widget {
        widget_dashboard_button,
        nil,  -- Middle part is nil to push the resourcesInfo to the right
        {
            resourcesInfo,
            right = 0,
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
    }

    -- MainLayer with some margin adjustments
    local mainLayer = wibox.widget {
        {
            distribution,
            left = 10,
            right = 10,
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

return BottomPanel
