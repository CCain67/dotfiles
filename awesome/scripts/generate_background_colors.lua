local theme = require("beautiful").get()
local theme_name = require("user.profile").theme

local config_string = [[
"""Global colors used in the generation of assets for the theme."""

# Theme name
THEME_NAME = "]] .. theme_name .. [["
# Hex color for the border
BORDER_COLOR = "]] .. theme.system_black_dark .. [["
# Hex color for the default background
BACKGROUND_COLOR = "]] .. theme.background .. [["
# Pool of random colors to pick from
COLOR_POOL = {
    "foreground": "]] .. theme.foreground .. [[",
    "red": "]] .. theme.red .. [[",
    "orange": "]] .. theme.orange .. [[",
    "yellow": "]] .. theme.yellow .. [[",
    "green": "]] .. theme.green .. [[",
    "cyan": "]] .. theme.cyan .. [[",
    "blue": "]] .. theme.blue .. [[",
    "purple": "]] .. theme.purple .. [[",
}
]]

local function generate_zathura_config()
    local background_colors = io.open("/home/chase/.config/awesome/scripts/asset_generation/colors.py", "w")

    background_colors:write(config_string)
    background_colors:close()
end

generate_zathura_config()