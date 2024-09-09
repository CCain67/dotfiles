local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi

local clickable_container = require('widget.clickable-container')

local icon = wibox.widget {
    id = "icon",
    markup = "<span color='".. beautiful.bg_normal .."'> </span>",
    font = beautiful.font .. ' 10',
    align = 'center',
    valign = 'vcenter',
    widget = wibox.widget.textbox,
}

local text = wibox.widget {
    id = "icon",
    markup = "<span color='".. beautiful.bg_normal .."'>-</span>",
    font = beautiful.font_bold .. ' 9',
    align = 'center',
    valign = 'vcenter',
    widget = wibox.widget.textbox,
}

local MicrophoneWidget = function(color)
    local volume_icon = wibox.widget{
        {
            icon,
            widget = wibox.container.margin,
            left = dpi(8),   -- Add padding to the left
            right = dpi(4),  -- Add padding to the right (optional)
        },
        bg = color,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }
    local volume_level = wibox.widget{
        {
            text,
            widget = wibox.container.margin,
            left = dpi(7),   -- Add padding to the left
            right = dpi(7),  -- Add padding to the right (optional)
        },
        bg = beautiful.fg_normal,  -- Replace with your preferred background color
        widget = wibox.container.background,
    }

    local volume = wibox.widget {
        volume_icon,
        volume_level,
        layout = wibox.layout.fixed.horizontal,  -- Use fixed horizontal layout to place them side by side
    }

    local volume_widget = wibox.widget {
        volume,
        widget = wibox.container.margin
    }

    local action_level = wibox.widget {
        {
            volume_widget,
            widget = clickable_container,
        },
        bg = beautiful.transparent,
        widget = wibox.container.background
    }
    action_level:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                nil,
                function()
                    awful.util.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
                    awesome.emit_signal('widget::mic')
                end
            ),
            awful.button(
                {},
                4,
                nil,
                function()
                    awful.spawn("pactl set-source-volume @DEFAULT_SOURCE@ +5%")
                    awesome.emit_signal('widget::mic')
                end
            ),
            awful.button(
                {},
                5,
                nil,
                function()
                    awful.spawn("pactl set-source-volume @DEFAULT_SOURCE@ -5%")
                    awesome.emit_signal('widget::mic')
                end
            )
        )
    )

    return action_level
end

local update_slider = function()
    awful.spawn.easy_async_with_shell(
        [[bash -c "pactl get-source-volume @DEFAULT_SOURCE@; pactl get-source-mute @DEFAULT_SOURCE@" ]],
        function(stdout)
            -- Split the output into volume and mute status
            local volume_stdout, mute_stdout = stdout:match("^(.-)\n(.-)\n*$")

            -- Extract the volume info
            local volume = volume_stdout:match('(%d?%d?%d)%%')
            local volumeNumber = tonumber(volume)
            local isMuted = mute_stdout:match("Mute: yes")

            if isMuted then
                icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'> </span>")
                text:set_markup_silently("<span color='".. beautiful.bg_normal .."'>muted</span>")
            elseif volumeNumber then
                icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'> </span>")
                text:set_markup_silently("<span color='".. beautiful.bg_normal .."'>" .. volumeNumber .. "</span>")
            else
                icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'> </span>")
                text:set_markup_silently("<span color='".. beautiful.bg_normal .."'>null</span>")
            end
        end
    )
end

-- Update on startup
update_slider()

-- The emit will come from the global keybind
awesome.connect_signal(
    'widget::mic',
    function()
        update_slider()
    end
)

return MicrophoneWidget