--Standard Modules
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local Separator = wibox.widget.textbox("    ")
Separator.forced_height = 30
Separator.forced_width = 80


---------------------------
--Calendar ----------------
---------------------------

local calendar_wdgt = wibox.widget {
	widget       = wibox.widget.calendar.month,
	date         = os.date("*t"),
	font         = '' .. beautiful.font_bold .. ' 12',
	flex_height  = true,
	start_sunday = true,
	fn_embed     = function(widget, flag, date)
		local focus_widget = wibox.widget {
			text   = date.day,
			align  = "center",
			widget = wibox.widget.textbox,
			font   = '' .. beautiful.font_bold .. ' 12'
		}
		local torender = flag == 'focus' and focus_widget or widget
		if flag == 'header' then
			torender.font = '' .. beautiful.font_bold .. ' 14'
		end
		if flag == 'weekday' then
			torender.font = '' .. beautiful.font_bold .. ' 14'
		end

		local colors = {
			header  = beautiful.blue,
			focus   = beautiful.red,
			normal  = beautiful.fg_normal,
			weekday = beautiful.green,
		}
		local color = colors[flag] or beautiful.fg_normal
		return wibox.widget {

			{
				{
					torender,
					align  = "left",
					widget = wibox.container.place
				},
				margins = dpi(3),
				widget  = wibox.container.margin,

			},
			fg     = color,
			bg     = beautiful.bg_normal,
			-- shape  = helpers.mkroundedrect(),
			-- forced_hight = dpi(300),
			widget = wibox.container.background
		}
	end
}

------------------
--Clock-----------
------------------

local sep = wibox.widget {
	markup       = '<span color="' ..
			beautiful.green .. '" font="' .. beautiful.font_bold .. ' 10">' .. '  ' .. '</span>',
	font         = "' .. beautiful.font .. '  14",
	widget       = wibox.widget.textbox,
	fg           = beautiful.fg_normal,
	forced_width = dpi(80),
	align        = 'center',
}

local hour_clock = wibox.widget.textclock(
	'<span color="' .. beautiful.yellow .. '" font="' .. beautiful.font_bold .. ' 36"> %I </span>', 10)

local minute_clock = wibox.widget.textclock(
	'<span color="' .. beautiful.yellow .. '" font="' .. beautiful.font_bold .. ' 36"> %M </span>', 10)

---------------------------------
--Main widget--------------------
---------------------------------

local calendar = wibox.widget {
	{
		{
			{
                calendar_wdgt,
                widget = wibox.container.margin,
                margins = dpi(18),
                layout = wibox.layout.fixed.center,
                forced_width = dpi(300),
			},
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 10)
			end,
            shape_border_width = dpi(2),
            shape_border_color = "#000000" .. "22"
		},
		widget = wibox.container.margin,
		margins = dpi(12)
	},
	{
		{
			{
				{
					{
						-- hour_text,
						hour_clock,
						sep,
						minute_clock,
						--Separator,
						layout = wibox.layout.fixed.vertical
					},
					widget = wibox.container.place,
				},
				widget = wibox.container.margin,
				margins = 12,
			},
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 10)
			end,
            shape_border_width = dpi(2),
            shape_border_color = "#000000" .. "22"
		},
		widget = wibox.container.margin,
		top = dpi(12),
		bottom = dpi(12),
		left = 0,
		right = dpi(12),
	},
	layout = wibox.layout.fixed.horizontal,
    forced_height = dpi(325),
}

return calendar
