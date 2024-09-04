local awful = require("awful")
local beautiful = require("beautiful")

awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },
    -- Floating clients.
    {
        rule_any = {
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "pop-up",
            }
        },
        properties = {
            floating = true
        }
    },
    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = {
                "normal",
                "dialog"
            }
        },
        properties = {
            titlebars_enabled = true
        }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    {
        rule = {
            class = "Firefox"
        },
        properties = {
            screen = 1,
            tag = "3"
        }
    },
    -- Set VS Code to always map on the tag named "1" on screen 1.
    {
        rule = {
            class = "Code"
        },
        properties = {
            screen = 1,
            tag = "1"
        }
    },
    -- Set Nautilus to always map on the tag named "4" on screen 1.
    {
        rule = {
            class = "Nautilus"
        },
        properties = {
            screen = 1,
            tag = "4"
        }
    },
}