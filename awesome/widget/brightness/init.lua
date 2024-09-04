-- Brightness Widget
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi

local clickable_container = require('widget.clickable-container')

local icon = wibox.widget {
    id = "icon",
    markup = "<span color='".. beautiful.bg_normal .."'> </span>",
    font = 'VictorMono Nerd Font 10',
    align = 'center',
    valign = 'vcenter',
    widget = wibox.widget.textbox,
}

local text = wibox.widget {
    id = "icon",
    markup = "<span color='".. beautiful.bg_normal .."'>-</span>",
    font = 'VictorMono Nerd Font Bold 9',
    align = 'center',
    valign = 'vcenter',
    widget = wibox.widget.textbox,
}

local Brightness = function(color)
    local brightness_icon = wibox.widget{
        {
            icon,
            widget = wibox.container.margin,
            left = dpi(8),   -- Add padding to the left
            right = dpi(4),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }
    local brightness_level = wibox.widget{
        {
            text,
            widget = wibox.container.margin,
            left = dpi(7),   -- Add padding to the left
            right = dpi(7),  -- Add padding to the right (optional)
        },
        bg = beautiful.fg_normal,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local brightness = wibox.widget {
        brightness_icon,
        brightness_level,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local brightness_widget = wibox.widget {
        brightness,
        widget = wibox.container.margin
    }

    local action_level = wibox.widget {
        {
            brightness_widget,
            widget = clickable_container,
        },
        bg = beautiful.transparent,
        widget = wibox.container.background
    }
    action_level:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                nil,
                function()
                    awful.util.spawn("brightnessctl set 50%")
                    awesome.emit_signal('widget::brightness')
                end
            ),
            awful.button(
                {},
                4,
                nil,
                function()
                    awful.spawn("brightnessctl set 10%+")
                    awesome.emit_signal('widget::brightness')
                end
            ),
            awful.button(
                {},
                5,
                nil,
                function()
                    awful.spawn("brightnessctl set 10%-")
                    awesome.emit_signal('widget::brightness')
                end
            )
        )
    )

    return action_level
end

-- Function to update the brightness slider
local function update_slider()
    awful.spawn.easy_async_with_shell("brightnessctl g", function(stdout)
        local brightness = tonumber(stdout)
        if brightness then
            text:set_markup_silently("<span color='".. beautiful.bg_normal .."'>" .. brightness .. "</span>")
        end
    end)
end

-- Update on startup
update_slider()

-- The emit will come from the global keybind
awesome.connect_signal(
    'widget::brightness',
    function()
        update_slider()
    end
)

return Brightness
