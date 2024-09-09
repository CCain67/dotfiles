local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--Custom Modules
local browser = require("user.profile").browser
local user_theme = require("user.profile").theme
local icon_path = os.getenv("HOME") .. '/.config/awesome/theme/'.. user_theme .. '/icons/web_icons/'

local create_button = function(icon, command)
  local image = wibox.widget {
    image = icon,
    widget = wibox.widget.imagebox,
    resize = true,
    forced_height = dpi(60),
    forced_width = dpi(60),
    halign = 'center'
  }

  local button = wibox.widget {
    {
      {
        image,
        widget = wibox.container.place
      },
      widget = wibox.container.margin,
      margins = dpi(6)
    },
    widget = wibox.container.background,
    bg = beautiful.bg_normal,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, 10)
    end,
  }

  button:connect_signal("mouse::enter", function()
    button.bg = beautiful.bg_normal
  end)

  button:connect_signal("mouse::leave", function()
    button.bg = beautiful.bg_normal
  end)

  button:connect_signal("button::press", function()
    button.bg = beautiful.system_black_dark
  end)

  button:connect_signal("button::release", function()
    button.bg = beautiful.bg_normal
    awful.spawn(browser.. " " .. command)
  end)


  return button
end


local arxiv = create_button(icon_path .. 'arxiv.svg', 'https://arxiv.org/archive/math')
local github = create_button(icon_path .. 'github.svg', 'https://github.com/')
local nlab = create_button(icon_path .. 'nlab.svg', 'https://ncatlab.org/nlab/show/HomePage')
local mo = create_button(icon_path .. 'mo.svg', 'https://mathoverflow.net/')

---------------------------
--Main widget--------------
---------------------------

local web_launch = wibox.widget {
  {
    {
      {
        {
          {
            arxiv,
            widget = wibox.container.margin,
            top    = dpi(12),
            bottom = dpi(12),
            left   = dpi(12),
            right  = dpi(6)
          },
          {
            github,
            widget = wibox.container.margin,
            top    = dpi(12),
            bottom = dpi(12),
            left   = dpi(6),
            right  = dpi(12)
          },
          layout = wibox.layout.fixed.horizontal
        },
        {
          {
            mo,
            widget = wibox.container.margin,
            top    = dpi(12),
            bottom = dpi(12),
            left   = dpi(12),
            right  = dpi(6)
          },
          {
            nlab,
            widget = wibox.container.margin,
            top    = dpi(12),
            bottom = dpi(12),
            left   = dpi(6),
            right  = dpi(12)
          },
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.place
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
  margins = dpi(12),
  forced_width = dpi(220),
  forced_height = dpi(215),
}

-------------------------
--Sys_info---------------
-------------------------

---Ram-----------------
local text1 = '<span color="' ..
    beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. '1.58 GiB' .. '</span>'
local icon1 = '<span color="' .. beautiful.green .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'RAM' .. '</span>'

local ram_usage = wibox.widget {
  markup = icon1 .. text1,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
}

local ram_text = wibox.widget {
  ram_usage,
  widget = wibox.container.margin,
  top = dpi(6),
  bottom = dpi(6),
  right = dpi(6),
  left = dpi(25),
  -- forced_height = dpi(40)
}

-- Fetch ram_usage info
awful.spawn.easy_async_with_shell([[ free -m | awk 'NR==2 {print $3}'
]], function(out)
  local str = string.gsub(out, "%s+", "")
  local val = tonumber(str) / 1000
  ram_usage.markup = icon1 .. '<span color="' ..
      beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. val .. ' GiB' .. '</span>'
end)

--Update ram_usage every time
local update_ram = function()
  awful.spawn.easy_async_with_shell([[ free -m | awk 'NR==2 {print $3}'
]], function(out)
    local str = string.gsub(out, "%s+", "")
    local val = tonumber(str) / 1000
    ram_usage.markup = icon1 .. '<span color="' ..
        beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. val .. ' GiB' .. '</span>'
  end)
end

local update_ram_timer = gears.timer({
  timeout = 30,
  call_now = true,
  autostart = true,
  callback = update_ram
})


---Cpu----------------------
local text2 = '<span color="' ..
    beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. '1%' .. '</span>'
local icon2 = '<span color="' .. beautiful.cyan .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'CPU' .. '</span>'

local cpu_usage = wibox.widget {
  -- text = user.name,
  markup = icon2 .. text2,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
  -- forced_width = dpi(300),
}

local cpu_text = wibox.widget {
  cpu_usage,
  widget = wibox.container.margin,
  top = dpi(6),
  bottom = dpi(6),
  right = dpi(9),
  left = dpi(25),
  -- forced_height = dpi(40)
}

-- Fetch cpu_usage info
awful.spawn.easy_async_with_shell([[ echo ""$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"%"
]], function(out)
  local str = string.gsub(out, "%s+", "")

  cpu_usage.markup = icon2 .. '<span color="' ..
      beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. str .. '</span>'
end)

--Update cpu_usage every time
local update_cpu = function()
  awful.spawn.easy_async_with_shell([[ echo ""$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"%"
]], function(out)
    local str = string.gsub(out, "%s+", "")

    cpu_usage.markup = icon2 .. '<span color="' ..
        beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. str .. '</span>'
  end)
end

local update_cpu_timer = gears.timer({
  timeout = 10,
  call_now = true,
  autostart = true,
  callback = update_cpu
})


---Storage----------------------
local text3 = '<span color="' ..
    beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. '69/334 GiB' .. '</span>'
local icon3 = '<span color="' .. beautiful.blue .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'SSD' .. '</span>'

local storage_usage = wibox.widget {
  markup = icon3 .. text3,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
}

local storage_text = wibox.widget {
  storage_usage,
  widget = wibox.container.margin,
  top = dpi(6),
  bottom = dpi(6),
  right = dpi(9),
  left = dpi(25),
}

-- Fetch storage_usage info
awful.spawn.easy_async_with_shell([[ df -h --total | tail -n 1 | awk '{print $3 "/" $4}'
]], function(out)
  local str = string.gsub(out, "%s+", "")

  storage_usage.markup = icon3 .. '<span color="' ..
      beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. str .. '</span>'
end)

--Update storage_usage every time
local update_storage = function()
  awful.spawn.easy_async_with_shell([[df -h --total | tail -n 1 | awk '{print $3 "/" $4}'
]], function(out)
    local str = string.gsub(out, "%s+", "")

    storage_usage.markup = icon3 .. '<span color="' ..
        beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. str .. '</span>'
  end)
end

local update_storage_timer = gears.timer({
  timeout = 7200,
  call_now = true,
  autostart = true,
  callback = update_storage
})

---Package----------------------
local text4 = '<span color="' ..
    beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. '2634' .. '</span>'
local icon4 = '<span color="' .. beautiful.purple .. '" font="' .. beautiful.font_bold .. ' 16">' .. 'PKG' .. '</span>'

local package_count = wibox.widget {
  markup = icon4 .. text4,
  font = beautiful.font_bold .. " 14",
  widget = wibox.widget.textbox,
}

local packages_text = wibox.widget {
  package_count,
  widget = wibox.container.margin,
  top = dpi(6),
  bottom = dpi(6),
  right = dpi(9),
  left = dpi(25),
  -- forced_height = dpi(40)
}

awful.spawn.easy_async_with_shell([[apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l]], function(out)
  local str = string.gsub(out, "%s+", "")

  package_count.markup = icon4 .. '<span color="' ..
      beautiful.fg_normal .. '" font="' .. beautiful.font_bold .. ' 14">' .. ': ' .. str .. '</span>'
end)



local Sys_info = wibox.widget {
    {
        {
        {
            ram_text,
            cpu_text,
            storage_text,
            packages_text,
            layout = wibox.layout.fixed.vertical
        },
        widget = wibox.container.place,
        halign = 'left'
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
    top = dpi(12),
    bottom = dpi(12),
    left = dpi(0),
    right = dpi(12),
    forced_width = dpi(250)
}

local main = wibox.widget {
  web_launch,
  Sys_info,
  layout = wibox.layout.fixed.horizontal
}

return main
