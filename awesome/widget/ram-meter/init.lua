local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local wibox = require('wibox')

local RamMeter = function(color)
    local ram_icon = wibox.widget{
        {
            {
                id = "icon",
                markup = "<span color='".. beautiful.bg_normal .. "' font='10'>  </span>",
                font = beautiful.font .. ' 10',
                align = 'center',
                valign = 'vcenter',
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.margin,
            left = dpi(8),   -- Add padding to the left
            right = dpi(2),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local ram_usage = wibox.widget{
        {
            awful.widget.watch('bash -c "free | grep Mem | awk \'{print int($3/$2 * 100.0)}\'"' ,30, function(widget, stdout)
				for line in stdout:gmatch("[^\r\n]+") do
					line = string.format("%02d", tonumber(line))
					widget.font = (beautiful.font_bold .. ' 9')
					widget.markup = ('<span color=\'' .. beautiful.bg_normal .. '\'> ' .. line .. '%</span>')
					widget.align = 'center'
					widget.valign = 'center'
					return
				end
			end),
            widget = wibox.container.margin,
            left = dpi(2),   -- Add padding to the left
            right = dpi(8),  -- Add padding to the right (optional)
        },
        bg = beautiful.fg_normal,  -- Replace with your preferred background color for the text
        widget = wibox.container.background,
    } 

    local ram = wibox.widget {
        ram_icon,
        ram_usage,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local ram_widget = wibox.widget {
        ram,
        widget = wibox.container.margin
    }

    return ram_widget
end

return RamMeter
