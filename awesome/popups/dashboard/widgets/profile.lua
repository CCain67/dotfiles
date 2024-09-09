local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- distro
local distro = 3

local distro_text = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ':   ' .. distro .. '</span>'
local distro_icon = '<span color="' .. beautiful.red .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'DISTRO' .. '</span>'

local distro_textbox = wibox.widget {
  markup = distro_icon .. distro_text,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
  fg = beautiful.fg_normal,
}

local distro_text_widget = wibox.widget {
  distro_textbox,
  widget = wibox.container.margin,
  top = dpi(5),
  bottom = dpi(5),
  right = dpi(5),
  left = dpi(25),
  forced_height = dpi(40)
}

awful.spawn.easy_async_with_shell("lsb_release -d | cut -f2-", function(out)
    distro_textbox.markup = distro_icon .. '<span color="' ..
    beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out .. '</span>'
end)

local update_distro = function()
    awful.spawn.easy_async_with_shell("lsb_release -d | cut -f2-", function(out)
        distro_textbox.markup = distro_icon .. '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out .. '</span>'
    end)
end


local update_distro_timer = gears.timer({
  timeout = 3600,
  call_now = true,
  autostart = true,
  callback = update_distro,
})

-- Kernel
local kernel = 3

local kernel_text = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ':   ' .. kernel .. '</span>'
local kernel_icon = '<span color="' .. beautiful.orange .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'KERNEL' .. '</span>'

local kernel_textbox = wibox.widget {
  markup = kernel_icon .. kernel_text,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
  fg = beautiful.fg_normal,
}

local kernel_text_widget = wibox.widget {
  kernel_textbox,
  widget = wibox.container.margin,
  top = dpi(5),
  bottom = dpi(5),
  right = dpi(5),
  left = dpi(25),
  forced_height = dpi(40)
}

awful.spawn.easy_async("uname -r", function(out)
  kernel_textbox.markup = kernel_icon .. '<span color="' ..
  beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out:gsub("up ", "") .. '</span>'
end)

local update_kernel = function()
  awful.spawn.easy_async("uname -r", function(out)
    kernel_textbox.markup = kernel_icon .. '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out .. '</span>'
  end)
end

local update_kernel_timer = gears.timer({
  timeout = 3600,
  call_now = true,
  autostart = true,
  callback = update_kernel,
})

-- Uptime
local uptime = 3

local text3 = '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ':   ' .. uptime .. '</span>'
local icon3 = '<span color="' .. beautiful.yellow .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'UPTIME' .. '</span>'

local uptime_textbox = wibox.widget {
  markup = icon3 .. text3,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
  fg = beautiful.fg_normal,
}

local uptime_text_widget = wibox.widget {
  uptime_textbox,
  widget = wibox.container.margin,
  top = dpi(5),
  bottom = dpi(5),
  right = dpi(5),
  left = dpi(25),
  forced_height = dpi(40)
}

awful.spawn.easy_async("uptime -p", function(out)
  uptime_textbox.markup = icon3 .. '<span color="' ..
  beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out:gsub("up ", "") .. '</span>'
end)

local update_uptime = function()
  awful.spawn.easy_async("uptime -p", function(out)
    uptime_textbox.markup = icon3 .. '<span color="' .. beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. out:gsub("up ", "") .. '</span>'
  end)
end

local update_uptime_timer = gears.timer({
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = update_uptime,
})


-- Main Widget
local profile = wibox.widget {
    {
        nil,
        {
            {
                {
                    {
                        distro_text_widget,
                        kernel_text_widget,
                        uptime_text_widget,
                        layout = wibox.layout.fixed.vertical
                    },
                    widget = wibox.container.margin,
                    top = dpi(4),
                    bottom = dpi(4),
                    forced_width = dpi(450)
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
        },
        layout = wibox.layout.fixed.horizontal
    },
    widget = wibox.container.margin,
    top = dpi(12),
    bottom = dpi(0),
    left = dpi(12),
    right = dpi(12),
    forced_width = dpi(430),
}

return profile
