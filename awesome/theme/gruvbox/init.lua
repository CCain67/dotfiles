local gears = require('gears')
local beautiful = require('beautiful')
local filesystem = require('gears.filesystem')

local dpi = beautiful.xresources.apply_dpi

local theme_name = 'gruvbox'
local theme_dir = filesystem.get_configuration_dir() .. '/theme/' .. theme_name
local titlebar_icon_path = theme_dir .. '/icons/titlebar/'
local tip = titlebar_icon_path

local theme = {}

theme.icons = theme_dir .. '/icons/'
theme.font = 'VictorMono Nerd Font'
theme.font_bold = 'VictorMono Nerd Font Bold'

-- Colorscheme
theme.system_black_dark = '#32302f'
theme.system_black_light = '#665c54'

theme.system_white_dark = '#d4be98'
theme.system_white_light = '#ddc7a1'

theme.red = '#ea6962'
theme.orange = '#e78a4e'
theme.yellow = '#d8a657'
theme.green = '#a9b665'
theme.cyan = '#89b482'
theme.blue = '#7daea3'
theme.purple = '#d3869b'

-- Accent color
theme.accent = theme.blue

-- Background
theme.background = '#282828'
theme.bg_normal = theme.background
theme.bg_focus = theme.background
theme.bg_urgent = theme.background

-- Foreground
theme.foreground = '#d4be98'
theme.fg_normal = theme.foreground
theme.fg_focus = theme.cyan
theme.fg_urgent = theme.orange

-- Transparent
theme.transparent = theme.background .. '99'

-- Awesome icon
theme.awesome_icon = theme.icons .. 'awesome.svg'

-- Titlebar
theme.titlebar_size = dpi(34)
theme.titlebar_bg_focus = theme.system_black_dark
theme.titlebar_bg_normal = theme.system_black_dark
theme.titlebar_fg_focus = theme.foreground
theme.titlebar_fg_normal = theme.foreground

-- Client Snap Theme
theme.snap_bg = theme.background
theme.snap_shape = gears.shape.rectangle
theme.snap_border_width = dpi(15)

-- Hotkey popup
theme.hotkeys_font = theme.font_bold
theme.hotkeys_description_font = theme.font
theme.hotkeys_bg = theme.background .. "ee"
theme.hotkeys_group_margin = dpi(20)

-- Taglist
theme.taglist_bg_empty = theme.background -- .. '99'
theme.taglist_bg_occupied =  theme.background
theme.taglist_bg_occupied = theme.background
theme.taglist_bg_urgent = theme.background
theme.taglist_bg_focus = theme.background
theme.taglist_spacing = dpi(4)

-- System tray
theme.bg_systray = theme.bg_normal
theme.systray_icon_spacing = dpi(16)

-- Borders
theme.border_focus = theme.background
theme.border_normal = theme.background
theme.border_marked = theme.yellow
theme.border_width = dpi(3)
theme.border_radius = dpi(0)

-- Decorations
theme.useless_gap = dpi(7)
theme.client_shape_rectangle = gears.shape.rectangle
theme.client_shape_rounded = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(9))
end

-- Tooltips
theme.tooltip_bg = theme.background
theme.tooltip_border_color = theme.transparent
theme.tooltip_border_width = 0
theme.tooltip_gaps = dpi(5)
theme.tooltip_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
end

-- Separators
theme.separator_color = theme.system_white_dark .. '#44'

-- Tasklist
theme.tasklist_font = theme.font

theme.tasklist_bg_normal = theme.background
theme.tasklist_bg_focus = theme.background
theme.tasklist_bg_urgent = theme.background

theme.tasklist_fg_normal = theme.foreground
theme.tasklist_fg_focus = theme.cyan
theme.tasklist_fg_urgent = theme.orange

-- Notification
theme.notification_position = 'bottom_right'
theme.notification_bg = theme.transparent
theme.notification_margin = dpi(7)
theme.notification_border_width = dpi(4)
theme.notification_border_color = theme.green
theme.notification_spacing = dpi(14)
theme.notification_icon_resize_strategy = 'center'
theme.notification_icon_size = dpi(32)

-- Layoutbox icons
theme.layout_max = theme.icons .. 'layouts/max.svg'
theme.layout_tile = theme.icons .. 'layouts/tile.svg'
theme.layout_dwindle = theme.icons .. 'layouts/dwindle.svg'
theme.layout_floating = theme.icons .. 'layouts/floating.svg'

-- Close Button
theme.titlebar_close_button_normal = tip .. 'close_normal.svg'
theme.titlebar_close_button_focus = tip .. 'close_focus.svg'

-- Minimize Button
theme.titlebar_minimize_button_normal = tip .. 'minimize_normal.svg'
theme.titlebar_minimize_button_focus = tip .. 'minimize_focus.svg'

-- Ontop Button
theme.titlebar_ontop_button_normal_inactive = tip .. 'ontop_normal_inactive.svg'
theme.titlebar_ontop_button_focus_inactive = tip .. 'ontop_focus_inactive.svg'
theme.titlebar_ontop_button_normal_active = tip .. 'ontop_normal_active.svg'
theme.titlebar_ontop_button_focus_active = tip .. 'ontop_focus_active.svg'

-- Sticky Button
theme.titlebar_sticky_button_normal_inactive = tip .. 'sticky_normal_inactive.svg'
theme.titlebar_sticky_button_focus_inactive = tip .. 'sticky_focus_inactive.svg'
theme.titlebar_sticky_button_normal_active = tip .. 'sticky_normal_active.svg'
theme.titlebar_sticky_button_focus_active = tip .. 'sticky_focus_active.svg'

-- Floating Button
theme.titlebar_floating_button_normal_inactive = tip .. 'floating_normal_inactive.svg'
theme.titlebar_floating_button_focus_inactive = tip .. 'floating_focus_inactive.svg'
theme.titlebar_floating_button_normal_active = tip .. 'floating_normal_active.svg'
theme.titlebar_floating_button_focus_active = tip .. 'floating_focus_active.svg'

-- Maximized Button
theme.titlebar_maximized_button_normal_inactive = tip .. 'maximized_normal_inactive.svg'
theme.titlebar_maximized_button_focus_inactive = tip .. 'maximized_focus_inactive.svg'
theme.titlebar_maximized_button_normal_active = tip .. 'maximized_normal_active.svg'
theme.titlebar_maximized_button_focus_active = tip .. 'maximized_focus_active.svg'

-- Hovered Close Button
theme.titlebar_close_button_normal_hover = tip .. 'close_normal_hover.svg'
theme.titlebar_close_button_focus_hover = tip .. 'close_focus_hover.svg'

-- Hovered Minimize Buttin
theme.titlebar_minimize_button_normal_hover = tip .. 'minimize_normal_hover.svg'
theme.titlebar_minimize_button_focus_hover = tip .. 'minimize_focus_hover.svg'

-- Hovered Ontop Button
theme.titlebar_ontop_button_normal_inactive_hover = tip .. 'ontop_normal_inactive_hover.svg'
theme.titlebar_ontop_button_focus_inactive_hover = tip .. 'ontop_focus_inactive_hover.svg'
theme.titlebar_ontop_button_normal_active_hover = tip .. 'ontop_normal_active_hover.svg'
theme.titlebar_ontop_button_focus_active_hover = tip .. 'ontop_focus_active_hover.svg'

-- Hovered Sticky Button
theme.titlebar_sticky_button_normal_inactive_hover = tip .. 'sticky_normal_inactive_hover.svg'
theme.titlebar_sticky_button_focus_inactive_hover = tip .. 'sticky_focus_inactive_hover.svg'
theme.titlebar_sticky_button_normal_active_hover = tip .. 'sticky_normal_active_hover.svg'
theme.titlebar_sticky_button_focus_active_hover = tip .. 'sticky_focus_active_hover.svg'

-- Hovered Floating Button
theme.titlebar_floating_button_normal_inactive_hover = tip .. 'floating_normal_inactive_hover.svg'
theme.titlebar_floating_button_focus_inactive_hover = tip .. 'floating_focus_inactive_hover.svg'
theme.titlebar_floating_button_normal_active_hover = tip .. 'floating_normal_active_hover.svg'
theme.titlebar_floating_button_focus_active_hover = tip .. 'floating_focus_active_hover.svg'

-- Hovered Maximized Button
theme.titlebar_maximized_button_normal_inactive_hover = tip .. 'maximized_normal_inactive_hover.svg'
theme.titlebar_maximized_button_focus_inactive_hover = tip .. 'maximized_focus_inactive_hover.svg'
theme.titlebar_maximized_button_normal_active_hover = tip .. 'maximized_normal_active_hover.svg'
theme.titlebar_maximized_button_focus_active_hover = tip .. 'maximized_focus_active_hover.svg'

local awesome_overrides = function(theme) end

return {
	theme = theme,
 	awesome_overrides = awesome_overrides
}
