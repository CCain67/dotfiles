--Standard Modules
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-----------------------
--Header text----------
-----------------------
local create_header = function(text)
	local textbox = wibox.widget {
		markup = '<span color="' .. beautiful.fg_normal .. '">' .. text .. '</span>',
		font = beautiful.font_bold .. " 14",
		widget = wibox.widget.textbox,
		fg = beautiful.fg_normal
	}

	local header = wibox.widget {
		{
			{
				textbox,
				widget = wibox.container.margin,
				top = dpi(7),
				bottom = dpi(5),
				right = dpi(5),
				left = dpi(8),
			},
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			shape = function(cr, width, height)
				gears.shape.rounded_rect(cr, width, height, 7)
			end,
            shape_border_width = dpi(2),
            shape_border_color = "#000000" .. "33"
		},
		widget = wibox.container.margin,
		top = dpi(14),
		left = dpi(12),
		right = dpi(12),
		forced_height = dpi(61),
	}

	return header
end

local headers = {
	home = create_header("   System Dashboard"),
	todo = create_header("   Todo and Timer"),
}

return headers
