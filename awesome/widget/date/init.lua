local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local wibox = require('wibox')

local date = function(color)
    local date_icon = wibox.widget{
        {
            {
                id = "icon",
                markup = "<span color='" .. beautiful.bg_normal .. "' font='13'>󰃭 </span>",
                font = beautiful.font .. ' 10',
                align = 'center',
                valign = 'vcenter',
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.margin,
            left = dpi(8),   -- Add padding to the left
            right = dpi(4),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local date_text = wibox.widget{
        {
            awful.widget.watch('bash -c "date \'+%h %d\'"' ,10, function(widget, stdout)
				for line in stdout:gmatch("[^\r\n]+") do
					-- line = string.format("%02d", tonumber(line))
					widget.font = (beautiful.font_bold .. ' 9')
					widget.markup = ('<span color=\'' .. beautiful.bg_normal .. '\'> ' .. line .. '</span>')
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
    

    local date = wibox.widget {
        date_icon,
        date_text,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local date_widget = wibox.widget {
        date,
        widget = wibox.container.margin
    }

    return date_widget
end

return date
