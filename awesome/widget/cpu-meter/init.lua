local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local wibox = require('wibox')

local total_prev = 0
local idle_prev = 0


local CPUMeter = function(color)
    local cpu_icon = wibox.widget{
        {
            {
                id = "icon",
                markup = "<span color='" .. beautiful.bg_normal .. "' font='10'> </span>",
                font = 'VictorMono Nerd Font 10',
                align = 'center',
                valign = 'vcenter',
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.margin,
            left = dpi(7),   -- Add padding to the left
            right = dpi(7),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local cpu_usage = wibox.widget{
        {
            awful.widget.watch('bash -c "cat /proc/stat | grep \'^cpu \'"' ,10, function(widget, stdout)
				local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')
				local total = user + nice + system + idle + iowait + irq + softirq + steal

				local diff_idle = idle - idle_prev
				local diff_total = total - total_prev
				local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
				total_prev = total
				idle_prev = idle
				collectgarbage('collect')

				line = string.format("%02d", math.floor(diff_usage))
				widget.font = ('VictorMono Nerd Font Bold 9')
				widget.markup = ('<span color="' .. beautiful.bg_normal .. '"> ' .. line .. '%</span>')
				widget.align = 'center'
				widget.valign = 'center'
			end),
            widget = wibox.container.margin,
            left = dpi(2),   -- Add padding to the left
            right = dpi(8),  -- Add padding to the right (optional)
        },
        bg = beautiful.fg_normal,  -- Replace with your preferred background color for the text
        widget = wibox.container.background,
    }


    local cpu = wibox.widget {
        cpu_icon,
        cpu_usage,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local cpu_widget = wibox.widget {
        cpu,
        widget = wibox.container.margin
    }

    return cpu_widget
end

return CPUMeter
