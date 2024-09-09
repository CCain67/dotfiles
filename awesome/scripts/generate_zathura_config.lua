local theme = require("beautiful").get()
local naughty = require("naughty")

local config_string = [[
set font "]] .. theme.font_bold .. [[" 10
set recolor true 
set recolor-darkcolor "]] .. theme.fg_normal .. [[" 
set recolor-lightcolor "]] .. theme.bg_normal .. [[" 
set inputbar-fg "]] .. theme.fg_normal .. [[" 
set inputbar-bg "]] .. theme.bg_normal .. [[" 
set default-fg "]] .. theme.fg_normal .. [[" 
set default-bg "]] .. theme.bg_normal .. [[" 
set statusbar-fg "]] .. theme.fg_normal .. [[" 
set statusbar-bg "]] .. theme.bg_normal .. [[" 
]]

local function generate_zathura_config()
    local zathura_config = io.open(os.getenv("HOME") .. "/.config/zathura/zathurarc", "w")

    naughty.notify({
        preset = naughty.config.presets.normal,
        title = "zathura",
        text = "generating zathura config..."
    })

    zathura_config:write(config_string)
    zathura_config:close()
end

generate_zathura_config()