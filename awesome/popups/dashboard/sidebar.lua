local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local create_button = function(text, signal)
	local textbox = wibox.widget {
		markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 18">' .. text .. '</span>',
		widget = wibox.widget.textbox,
		fg = beautiful.fg_normal
	}

	local button = wibox.widget {
		{
			textbox,
			widget = wibox.container.margin,
			top = dpi(9),
			bottom = dpi(9),
			right = dpi(8),
			left = dpi(11),
		},
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		forced_width = dpi(45),
		-- forced_height = dpi(45),
		shape = function(cr, width, height)
			gears.shape.partially_rounded_rect(cr, width, height, true, true, true, true, 5)
		end,
	}

	button:connect_signal("button::press", function()
		button.bg = beautiful.system_black_light
	end)

	button:connect_signal("button::release", function()
		button.bg = beautiful.bg_normal
		awesome.emit_signal(signal)
	end)

	return button
end

-- May use this later
-- 
-- local docker_imagebox = wibox.widget {
--     wibox.widget {
--         image = os.getenv("HOME") .. "/.config/awesome/docker.svg",
--         resize = false,
--         align = "center",
--         widget = wibox.widget.imagebox
--     },
--     widget = wibox.container.place,
--     halign = "center", -- or "left", "right"
--     valign = "center"  -- or "top", "bottom"
-- }

-- local create_image_button = function(imagebox, signal)
-- 	local button = wibox.widget {
-- 		{
-- 			imagebox,
-- 			widget = wibox.container.margin,
-- 			top = dpi(9),
-- 			bottom = dpi(9),
-- 			right = dpi(8),
-- 			left = dpi(11),
-- 		},
-- 		widget = wibox.container.background,
-- 		bg = beautiful.bg_normal,
-- 		forced_width = dpi(45),
-- 		-- forced_height = dpi(45),
-- 		shape = function(cr, width, height)
-- 			gears.shape.partially_rounded_rect(cr, width, height, true, true, true, true, 5)
-- 		end,
-- 	}

-- 	button:connect_signal("button::press", function()
-- 		button.bg = beautiful.system_black_light
-- 	end)

-- 	button:connect_signal("button::release", function()
-- 		button.bg = beautiful.bg_normal
-- 		awesome.emit_signal(signal)
-- 	end)

-- 	return button
-- end

local home = create_button('', "dashboard::home")
local todo = create_button('', "dashboard::todo")


local change_button_color = function(button, other1)
	button:connect_signal("button::release", function()
		button.bg = beautiful.bg_normal
		other1.bg = beautiful.bg_normal
	end)
end

change_button_color(home, todo)

local main = wibox.widget {
	{
		{
			{
				home,
				widget = wibox.container.margin,
				top = dpi(4),
				bottom = dpi(4)
			},
			{
				todo,
				widget = wibox.container.margin,
				top = dpi(4),
				bottom = dpi(4)
			},
			layout = wibox.layout.fixed.vertical
		},
		widget = wibox.container.margin,
		left = dpi(7),
		right = dpi(7),
		top = dpi(10)
	},
	widget = wibox.container.background,
	bg = beautiful.bg_normal,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 0)
    end,
    shape_border_width = dpi(2),
    shape_border_color = "#000000" .. "33",
	forced_height = dpi(950),
}

return main
