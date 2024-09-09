local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local wibox = require('wibox')


local time = function(color)
    local time_icon = wibox.widget{
        {
            {
                id = "icon",
                markup = "<span color='".. beautiful.bg_normal .. "' font='10'> </span>",
                font = beautiful.font .. ' 10',
                align = 'center',
                valign = 'vcenter',
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.margin,
            left = dpi(8),   -- Add padding to the left
            right = dpi(8),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local time_text = wibox.widget{
        {
            awful.widget.watch('bash -c "date \'+%I:%M %p\'"' ,10, function(widget, stdout)
				for line in stdout:gmatch("[^\r\n]+") do
					-- line = string.format("%02d", tonumber(line))
					widget.font = (beautiful.font_bold .. ' 9')
					widget.markup = ('<span color=\'' .. beautiful.bg_normal .. '\'> ' .. line .. '</span>')
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

    local time = wibox.widget {
        time_icon,
        time_text,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local time_widget = wibox.widget {
        time,
        widget = wibox.container.margin
    }

    return time_widget
end

return time
