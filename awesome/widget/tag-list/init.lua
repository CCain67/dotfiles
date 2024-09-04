local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local theme = require('theme')


local icon_font = "VictorMono Nerd Font 16"  -- Use your specific icon font here
local tag_icons = {
    "󰎤",
    "󰎧",
    "󰎪",
    "󰎭",
    "󰎱",
    "󰎳",
    "󰎶",
    "󰎹",
    "󰎼"
}
local color_focus = theme.fg_focus
local color_empty = theme.system_black_light
local color_normal = theme.fg_normal

local function set_icon_markup(tag, icon_widget)
    -- Handle color based on the state of the tag
    if tag.selected then
        icon_widget:set_markup("<span foreground='" .. color_focus .. "'>" .. icon_widget.text .. "</span>")
    elseif #tag:clients() > 0 then
        icon_widget:set_markup("<span foreground='" .. color_normal .. "'>" .. icon_widget.text .. "</span>")
    else
        icon_widget:set_markup("<span foreground='" .. color_empty .. "'>" .. icon_widget.text .. "</span>")
    end
end

local function taglist_template()
    return {
        {
            {
                id = "icon_role",
                widget = wibox.widget.textbox,
                font = icon_font,
                align = "left",
                forced_width = dpi(16)
            },
            left = 5,
            right = 5,
            widget = wibox.container.margin
        },
        id = "background_role",
        widget = wibox.container.background,
        create_callback = function(self, tag, index, objects)
            local icon_widget = self:get_children_by_id("icon_role")[1]
            icon_widget.text = tag_icons[index] or "?"
            set_icon_markup(tag, icon_widget)
        end,
        update_callback = function(self, tag, index, objects)
            local icon_widget = self:get_children_by_id("icon_role")[1]
            icon_widget.text = tag_icons[index] or "?"
            set_icon_markup(tag, icon_widget)
        end,
        bg = theme.bg_normal
    }
end


local tag_list = function(s)
	return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style = {
            font = icon_font,
        },
        layout = {
            spacing = 5,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = taglist_template(),
        buttons = awful.util.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end)
        )
    }
end

return tag_list
