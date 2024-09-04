local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')

local BatteryMeter = function(color)
    -- local full_battery = "<span color='" .. beautiful.bg_normal .. "'>󰁹</span>"
    -- local semi_full_battery = "<span color='" .. beautiful.bg_normal .. "'>󰂀</span>"
    -- local half_battery = "<span color='" .. beautiful.bg_normal .. "'>󰁾</span>"
    -- local semi_half_battery = "<span color='" .. beautiful.bg_normal .. "'>󰁽</span>"
    -- local low_battery = "<span color='" .. beautiful.bg_normal .. "'>󰁻</span>"
    -- local extreme_low_battery = "<span color='" .. beautiful.bg_normal .. "'>󰁺</span>"

    local battery_markup = "<span color='" .. beautiful.bg_normal .. "'>󰄌 </span>"

    local battery_icon = wibox.widget {
        {
            awful.widget.watch('bash -c "upower -i $(upower -e | grep BAT) | grep percentage | sed \'s/%//\' | awk \'{print $2}\'"', 30, function(
                widget, stdout)
                for line in stdout:gmatch("[^\r\n]+") do
                    local battery_percentage = tonumber(line)

                    local markup_battery = battery_markup
                    if battery_percentage < 10 then
                        naughty.notify({
                            preset = naughty.config.presets.critical,
                            title = 'Battery Notification',
                            text = 'Battery is running extremely low!',
                            timeout = 5,
                            position = 'top_right',
                            fg = beautiful.fg_normal,
                            bg = beautiful.bg_normal
                        })
                    elseif battery_percentage < 25 then
                        naughty.notify({
                            preset = naughty.config.presets.critical,
                            title = 'Battery Notification',
                            text = 'Battery is running low!',
                            timeout = 5,
                            position = 'top_right',
                            fg = beautiful.fg_normal,
                            bg = beautiful.bg_normal
                        })
                    end
                    widget.font = ('VictorMono Nerd Font 13')
                    widget.markup = (markup_battery)
                    widget.align = 'center'
                    widget.valign = 'center'
                    return
                end
            end),
            widget = wibox.container.margin,
            left = dpi(10), -- Add padding to the left
            right = dpi(8), -- Add padding to the right (optional)
        },
        bg = color,         -- Replace with your preferred background color for the text
        widget = wibox.container.background,
    }

    local battery_percentage = wibox.widget {
        {
            awful.widget.watch('bash -c "upower -i $(upower -e | grep BAT) | grep percentage | sed \'s/%//\' | awk \'{print $2}\'"', 30, function(
                widget, stdout)
                for line in stdout:gmatch("[^\r\n]+") do
                    widget.font = ('VictorMono Nerd Font Bold 9')
                    widget.markup = ('<span color=\'' .. beautiful.bg_normal .. '\'> ' .. line .. '%</span>')
                    widget.align = 'center'
                    widget.valign = 'center'
                    return
                end
            end),
            widget = wibox.container.margin,
            left = dpi(2),        -- Add padding to the left
            right = dpi(8),       -- Add padding to the right (optional)
        },
        bg = beautiful.fg_normal, -- Replace with your preferred background color for the text
        widget = wibox.container.background,
    }

    local battery_widget = wibox.widget {
        {
            battery_icon,
            battery_percentage,
            layout = wibox.layout.align.horizontal,
        },
        right = 0,
        widget = wibox.container.margin
    }

    return battery_widget
end

return BatteryMeter
