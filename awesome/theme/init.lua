local beautiful = require('beautiful')
beautiful.useless_gap = 10

local user_theme = require('user.profile').theme
local theme = require('theme.' .. user_theme)

return theme.theme
