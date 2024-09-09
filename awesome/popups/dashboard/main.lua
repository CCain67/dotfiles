--Standard Modules
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--Custom Modules
local header = require("popups.dashboard.headers")

--Home Widgets
local profile = require("popups.dashboard.widgets.profile")
local calender = require("popups.dashboard.widgets.calendar")
local weather = require("popups.dashboard.widgets.weather")
local launch = require("popups.dashboard.widgets.quick_launch")

--Todo Widgets
local timer = require("popups.dashboard.todo_widgets.stopwatch")
local todo = require("popups.dashboard.todo_widgets.todo")

--Separator/Background
local Separator = wibox.widget.textbox("    ")
Separator.forced_height = 950
Separator.forced_width = 440

--Sidebar
local sidebar = require("popups.dashboard.sidebar")

--Main Wibox
local dashboard_home = awful.popup {
	screen = s,
	widget = wibox.container.background,
	ontop = true,
	bg = beautiful.bg_normal,
	visible = false,
	forced_width = 450,
	maximum_height = 1025,
	placement = function(c)
		awful.placement.top_left(c,
			{ margins = { top = dpi(62), bottom = dpi(8), left = dpi(8), right = dpi(8) } })
	end,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 0)
	end,
	opacity = 1
}

local home_widget = wibox.widget {
	header.home,
	profile,
	calender,
	weather,
	launch,
	layout = wibox.layout.fixed.vertical,
}

local todo_widget = wibox.widget {
	header.todo,
	timer,
	todo,
	layout = wibox.layout.fixed.vertical,
	visible = false
}

dashboard_home:setup {
	{
		{
			home_widget,
			todo_widget,
			Separator,
			layout = wibox.layout.stack
		},
		sidebar,
		layout = wibox.layout.fixed.horizontal
	},
	widget = wibox.container.background,
	bg = beautiful.system_black_dark,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 10)
	end,
}

--Signals
awesome.connect_signal("dashboard::home", function()
	home_widget.visible = true
	todo_widget.visible = false
end
)

awesome.connect_signal("dashboard::todo", function()
	home_widget.visible = false
	todo_widget.visible = true
end)

return dashboard_home
