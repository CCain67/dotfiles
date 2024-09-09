local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--Custom Modules
local user_theme = require("user.profile").theme
local iconpath = os.getenv("HOME") .. '/.config/awesome/theme/'.. user_theme .. '/icons/weather_icons/'


-- Location & weather
local city_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. " Earth (probably)" .. '</span>',
	widget = wibox.widget.textbox,
	forced_height = dpi(20),
}

local country_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. "  ,US" .. '</span>',
	widget = wibox.widget.textbox,
	forced_height = dpi(20),
}

local weather_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. "Loading... " .. '</span>',
	widget = wibox.widget.textbox,
	forced_height = dpi(20),
}

----------------------------
--temparature_text----------
----------------------------
local temparature_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.cyan .. '" font="' .. beautiful.font_bold .. ' 30">' .. " " .. '°C' .. '</span>',
	widget = wibox.widget.textbox,
	align = 'center',
}

----------------------------
--Third row-----------------
----------------------------
local humidity_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. "N/A" .. '</span>',
	widget = wibox.widget.textbox,
}

local humidity_icon = wibox.widget {
	markup = '<span color="' ..
		beautiful.purple .. '" font="' .. beautiful.font_bold .. ' 16">' .. "󱪅 " .. '</span>',
	widget = wibox.widget.textbox,
}


local wind_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. "N/A" .. '</span>',
	widget = wibox.widget.textbox,
}

local wind_icon = wibox.widget {
	markup = '<span color="' ..
		beautiful.green .. '" font="' .. beautiful.font_bold .. ' 16">' .. " " .. '</span>',
	widget = wibox.widget.textbox,
}


local feels_like_text = wibox.widget {
	markup = '<span color="' ..
		beautiful.fg_normal .. '" font="' .. beautiful.font .. '  12">' .. "N/A" .. '</span>',
	widget = wibox.widget.textbox,
}

local feels_like_icon = wibox.widget {
	markup = '<span color="' ..
		beautiful.yellow .. '" font="' .. beautiful.font_bold .. ' 16">' .. "󱤋 " .. '</span>',
	widget = wibox.widget.textbox,
}
-----------------------
--Bottom Widget--------
-----------------------
local humidity = {
	{
		{
			humidity_icon,
			nil,
			humidity_text,
			layout = wibox.layout.align.horizontal
		},
		widget = wibox.container.margin,
		-- margins = dpi(9),
		top = dpi(9),
		bottom = dpi(9),
		right = dpi(15),
		left = dpi(15)
	},
	widget = wibox.container.background,
	bg = beautiful.bg_normal,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 20)
	end,
    shape_border_width = dpi(2),
    shape_border_color = "#000000" .. "33",
	forced_width = dpi(110),
}

local temp_feels_like = {
	{
		{
			feels_like_icon,
			nil,
			feels_like_text,
			layout = wibox.layout.align.horizontal
		},
		widget = wibox.container.margin,
		-- margins = dpi(9),
		top = dpi(9),
		bottom = dpi(9),
		right = dpi(15),
		left = dpi(15)
	},
	widget = wibox.container.background,
	bg = beautiful.bg_normal,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 20)
	end,
    shape_border_width = dpi(2),
    shape_border_color = "#000000" .. "33",
	forced_width = dpi(110),
}

local wind = {
	{
		{
			wind_icon,
			nil,
			wind_text,
			layout = wibox.layout.align.horizontal
		},
		widget = wibox.container.margin,
		-- margins = dpi(9),
		top = dpi(9),
		bottom = dpi(9),
		right = dpi(15),
		left = dpi(15)
	},
	widget = wibox.container.background,
	bg = beautiful.bg_normal,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 20)
	end,
    shape_border_width = dpi(2),
    shape_border_color = "#000000" .. "33",
	forced_width = dpi(110),
}

--------------------------------
--Image Icon--------------------
--------------------------------
local weath_image = wibox.widget {
	image = iconpath .. 'weather-error.svg',
	widget = wibox.widget.imagebox,
	resize = true,
	forced_height = dpi(90),
	forced_width = dpi(90),
}

----------------------------
--Setting values-----------
----------------------------
local get_weather_data = "source ~/.zshrc && bash /home/chase/.config/awesome/scripts/weather.sh"

local update_weather = function()
    awful.spawn.easy_async_with_shell(get_weather_data, function(out)
        local data = {}
        for word in string.gmatch(out, "%S+") do
            table.insert(data, word)
        end

        -- Assign the relevant data to each variable
        local icon = data[1] or "N/A"
        local feelslike = tonumber(data[2]) and math.floor(tonumber(data[2]) + 0.5) or "N/A"  -- Round feels_like
        local temp = tonumber(data[3]) and math.floor(tonumber(data[3]) + 0.5) or "N/A"      -- Round temp
        local city = data[4] or "N/A"
        local humidity_val = data[6] or "N/A"
        local wind_speed = tonumber(data[7]) and math.floor(tonumber(data[7]) + 0.5) or "N/A"      -- Round wind speed
        local weather = data[8] or "N/A"

        local temp_color = beautiful.cyan
        if temp >= 90 then
            temp_color = beautiful.red
        elseif temp >= 80 and temp < 90 then
            temp_color = beautiful.orange
        elseif temp >= 70 and temp < 80 then
            temp_color = beautiful.yellow
        elseif temp >= 60 and temp < 70 then
            temp_color = beautiful.green
        elseif temp >= 50 and temp < 60 then
            temp_color = beautiful.cyan
        elseif temp >= 32 and temp < 50 then
            temp_color = beautiful.blue
        elseif temp < 32 then
            temp_color = beautiful.purple
        end

        -- Update the widget's text and image fields
        city_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">' .. city .. '</span>'
        country_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">, OH</span>'
        weather_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">' .. weather .. '</span>'
        temparature_text.markup = '<span color="' .. temp_color .. '" font="' .. beautiful.font_bold .. ' 35">' .. temp .. '°F</span>'
        humidity_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">' .. humidity_val .. '%</span>'
        feels_like_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">' .. feelslike .. '°F</span>'
        wind_text.markup = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 12">' .. wind_speed .. ' mph</span>'

        -- Update the weather icon based on the icon code
        local weather_image = iconpath .. 'weather-error.svg'
        if icon == '50d' then
            weather_image = iconpath .. 'dmist.svg'
        elseif icon == '01d' then
            weather_image = iconpath .. 'sun_icon.svg'
        elseif icon == '01n' then
            weather_image = iconpath .. 'moon_icon.svg'
        elseif icon == '02d' then
            weather_image = iconpath .. 'dfew_clouds.svg'
        elseif icon == '02n' then
            weather_image = iconpath .. 'nfew_clouds.svg'
        elseif icon == '03d' then
            weather_image = iconpath .. 'dscattered_clouds.svg'
        elseif icon == '03n' then
            weather_image = iconpath .. 'nscattered_clouds.svg'
        elseif icon == '04d' then
            weather_image = iconpath .. 'dbroken_clouds.svg'
        elseif icon == '04n' then
            weather_image = iconpath .. 'nbroken_clouds.svg'
        elseif icon == '09d' then
            weather_image = iconpath .. 'dshower_rain.svg'
        elseif icon == '09n' then
            weather_image = iconpath .. 'nshower_rain.svg'
        elseif icon == '010d' then
            weather_image = iconpath .. 'd_rain.svg'
        elseif icon == '010n' then
            weather_image = iconpath .. 'n_rain.svg'
        elseif icon == '011d' then
            weather_image = iconpath .. 'dthunderstorm.svg'
        elseif icon == '011n' then
            weather_image = iconpath .. 'nthunderstorm.svg'
        elseif icon == '013d' then
            weather_image = iconpath .. 'snow.svg'
        elseif icon == '013n' then
            weather_image = iconpath .. 'snow.svg'
        elseif icon == '50n' then
            weather_image = iconpath .. 'nmist.svg'
        elseif icon == '...' then
            weather_image = iconpath .. 'weather-error.svg'
        end
        weath_image.image = weather_image
    end)
end

update_weather()

local update_weather_data = gears.timer({
	timeout = 600, -- 10 minutes
	call_now = true,
	autostart = true,
	callback = update_weather,
})



-----------------------------
--Main Widget ---------------
-----------------------------

local weatherbox = wibox.widget {
	{
		{
			{
				{
					{
						city_text,
						country_text,
						layout = wibox.layout.fixed.horizontal
					},
					nil,
					weather_text,
					layout = wibox.layout.align.horizontal
				},
				widget = wibox.container.margin,
				-- margins = dpi(20),
				top = dpi(20),
				bottom = dpi(10),
				left = dpi(22),
				right = dpi(24)
			},
			{
				{
					temparature_text,
					nil,
					weath_image,
					layout = wibox.layout.align.horizontal
				},
				widget = wibox.container.margin,
				top = dpi(0),
				bottom = dpi(10),
				left = dpi(20),
				right = dpi(20),
			},
			{
				{
					humidity,
					{
						temp_feels_like,
						widget = wibox.container.margin,
						left = dpi(20),
						right = dpi(20)
					},
					wind,
					layout = wibox.layout.fixed.horizontal
				},
				widget = wibox.container.margin,
				top = dpi(0),
				bottom = dpi(20),
				left = dpi(36)
			},
			layout = wibox.layout.fixed.vertical
		},
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 10)
		end,
        shape_border_width = dpi(2),
        shape_border_color = "#000000" .. "33"
	},
	widget = wibox.container.margin,
	top = dpi(0),
	bottom = dpi(0),
	left = dpi(12),
	right = dpi(12),

}


return weatherbox
