local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty') 
local dpi = require('beautiful').xresources.apply_dpi
local clickable_container = require('widget.clickable-container')

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/network/icons/'

-- Configuration
local interfaces = {
	wlan_interface = 'wlp0s20f3',
	lan_interface = 'enp0s25'
}

local network_mode = nil

local network_icon = wibox.widget {
    id = 'icon',
    markup = "<span color='".. beautiful.bg_normal .."'>󰖪 </span>",
    font = beautiful.font .. ' 10',
    widget = wibox.widget.textbox,
    align = 'center',
    valign = 'vcenter'
}

local essid_textbox = wibox.widget {
    id = 'text',
    markup = "<span color='".. beautiful.bg_normal .."'>?</span>",
    font = beautiful.font_bold .. ' 9',
    widget = wibox.widget.textbox,
    align = 'center',
    valign = 'vcenter'
}

local return_button = function(color)

	local update_notify_no_access = false
	local notify_no_access_quota = 0

	local startup = true
	local reconnect_startup = true
	local notify_new_wifi_conn = false

    local network_icon_box = wibox.widget{
        {
            network_icon,
            widget = wibox.container.margin,
            left = dpi(8),
            right = dpi(6),
        },
        bg = color,
        widget = wibox.container.background,
    }
    local essid_textbox_box = wibox.widget{
        {
            essid_textbox,
            widget = wibox.container.margin,
            left = dpi(7),
            right = dpi(7),
        },
        bg = beautiful.fg_normal,
        widget = wibox.container.background,
    }

    local network = wibox.widget {
        network_icon_box,
        essid_textbox_box,
        layout = wibox.layout.fixed.horizontal,
    }

    local network_widget = wibox.widget {
        network,
        widget = wibox.container.margin
    }

    local update_essid = function()
        awful.spawn.easy_async_with_shell(
            [[
            essid=$(iwconfig ]] .. interfaces.wlan_interface .. [[ | grep -oE 'ESSID:"[^"]+"' | cut -d'"' -f2)
            echo "$essid"
            ]],
            function(stdout)
                local essid = stdout:gsub('%\n', '')
                essid_textbox:set_markup_silently("<span color='".. beautiful.bg_normal .."'>".. essid .."</span>")
            end
        )
    end

	local widget_button = wibox.widget {
		{
			network_widget,
			widget = clickable_container
		},
		bg = beautiful.transparent,
        widget = wibox.container.background
	}
	widget_button:buttons(
		gears.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					awful.spawn("nm-connection-editor", false)
				end
			)
		)
	)

	local network_tooltip = awful.tooltip {
		text = 'Loading...',
        font = beautiful.font .. ' 10',
		objects = {widget_button},
		mode = 'outside',
		align = 'right',
		shape = gears.shape.rectangle,
        fg = beautiful.fg_normal,
		border_width = dpi(2),
		border_color = beautiful.bg_normal,
		preferred_positions = {'left', 'right', 'top', 'bottom'},
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8)
	}

	local check_internet_health = [=[
	status_ping=0

	packets="$(ping -q -w2 -c2 1.1.1.1 | grep -o "100% packet loss")"
	if [ ! -z "${packets}" ];
	then
		status_ping=0
	else
		status_ping=1
	fi

	if [ $status_ping -eq 0 ];
	then
		echo 'Connected but no internet'
	fi
	]=]

	-- Awesome/System startup
	local update_startup = function()
		if startup then
			startup = false
		end
	end

	-- Consider reconnecting a startup
	local update_reconnect_startup = function(status)
		reconnect_startup = status
	end

	-- Update tooltip
	local update_tooltip = function(message)
		network_tooltip:set_markup(message)
	end

	local network_notify = function(message, title, app_name, icon)
		naughty.notification({ 
			message = message,
			title = title,
			app_name = app_name,
			icon = icon
		})
	end

	-- Wireless mode / Update
	local update_wireless = function()

		network_mode = 'wireless'

		-- Create wireless connection notification
		local notify_connected = function(essid)
			local message = 'You are now connected to <b>\"' .. essid .. '\"</b>'
			local title = 'Connection Established'
			local app_name = 'System Notification'
			local icon = widget_icon_dir .. 'wifi.svg'
			network_notify(message, title, app_name, icon)
		end

        -- Get wifi essid and bitrate
        local update_wireless_data = function(strength, healthy)
            awful.spawn.easy_async_with_shell(
                [[
                essid=$(iwconfig ]] .. interfaces.wlan_interface .. [[ | grep -oE 'ESSID:"[^"]+"' | cut -d'"' -f2)
                bitrate=$(iwconfig ]] .. interfaces.wlan_interface .. [[ | grep -oE 'Bit Rate=[^ ]+ Mb/s' | cut -d'=' -f2)
                echo "$essid|$bitrate"
                ]],
                function(stdout)
                    local essid, bitrate = stdout:match('([^|]+)|([^|]+)')
                    essid = essid and essid:gsub('%\n', '') or 'N/A'
                    bitrate = bitrate and bitrate:gsub('%\n', '') or 'N/A'
                    local message = 'Connected to: <b>' .. (essid or 'Loading...*') ..
                        '</b>\nWireless Interface: <b>' .. interfaces.wlan_interface ..
                        '</b>\nWiFi-Strength: <b>' .. tostring(wifi_strength) .. '%' ..
                        '</b>\nBit rate: <b>' .. tostring(bitrate) .. '</b>'
                    
                    if healthy then
                        update_tooltip(message)
                    else
                        update_tooltip('<b>Connected but no internet!</b>\n' .. message)
                    end

                    if reconnect_startup or startup then
                        if notify_new_wifi_conn	then notify_connected(essid) end
                        update_reconnect_startup(false)
                    end
                end
            )
        end


		-- Update wifi icon based on wifi strength and health
		local update_wireless_icon = function(strength)
			awful.spawn.easy_async_with_shell(
				check_internet_health,
				function(stdout)
					local widget_icon_name = 'wifi-strength'
					if not stdout:match('Connected but no internet') then
						if startup or reconnect_startup then
							awesome.emit_signal('system::network_connected')
						end
						widget_icon_name = widget_icon_name .. '-' .. tostring(strength)
						update_wireless_data(wifi_strength_rounded, true)
					else
						widget_icon_name = widget_icon_name .. '-' .. tostring(strength) .. '-alert'
						update_wireless_data(wifi_strength_rounded, false)
					end
					network_icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'>󰖩 </span>")
                    update_essid()
				end
			)
		end

		-- Get wifi strength
		local update_wireless_strength = function()
			awful.spawn.easy_async_with_shell(
				[[
				awk 'NR==3 {printf "%3.0f" ,($3/70)*100}' /proc/net/wireless
				]],
				function(stdout)
					if not tonumber(stdout) then
						return
					end
					wifi_strength = tonumber(stdout)
					local wifi_strength_rounded = math.floor(wifi_strength / 25 + 0.5)
					update_wireless_icon(wifi_strength_rounded)
				end
			)
		end

		update_wireless_strength()
		update_startup()
	end

	local update_wired = function()

		network_mode = 'wired'

		local notify_connected = function()
			local message = 'Connected to internet with <b>\"' .. interfaces.lan_interface .. '\"</b>'
			local title = 'Connection Established'
			local app_name = 'System Notification'
			local icon = widget_icon_dir .. 'wired.svg'
			network_notify(message, title, app_name, icon)
		end

		awful.spawn.easy_async_with_shell(
			check_internet_health,
			function(stdout)

				local widget_icon_name = 'wired'
				
				if stdout:match('Connected but no internet') then
					widget_icon_name = widget_icon_name .. '-alert'
					update_tooltip(
						'<b>Connected but no internet!</b>' ..
						'\nEthernet Interface: <b>' .. interfaces.lan_interface .. '</b>'
					)
				else
					update_tooltip('Ethernet Interface: <b>' .. interfaces.lan_interface .. '</b>')
					if startup or reconnect_startup then
						awesome.emit_signal('system::network_connected')
						notify_connected()
						update_startup(false)
					end
					update_reconnect_startup(false)
				end
				network_icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'> </span>")
                update_essid()
			end
		)
	end

	local update_disconnected = function()

		local notify_wireless_disconnected = function(essid)
			local message = 'Wi-Fi network has been disconnected'
			local title = 'Connection Disconnected'
			local app_name = 'System Notification'
			local icon = widget_icon_dir .. 'wifi-strength-off.svg'
			network_notify(message, title, app_name, icon)
		end

		local notify_wired_disconnected = function(essid)
			local message = 'Ethernet network has been disconnected'
			local title = 'Connection Disconnected'
			local app_name = 'System Notification'
			local icon = widget_icon_dir .. 'wired-off.svg'
			network_notify(message, title, app_name, icon)
		end

		local widget_icon_name = 'wifi-strength-off'

		if network_mode == 'wireless' then
			widget_icon_name = 'wifi-strength-off'
			if not reconnect_startup then
				update_reconnect_startup(true)
				notify_wireless_disconnected()
			end
		elseif network_mode == 'wired' then
			widget_icon_name = 'wired-off'
			if not reconnect_startup then
				update_reconnect_startup(true)
				notify_wired_disconnected()
			end
		end
		update_tooltip('Network is currently disconnected')
		network_icon:set_markup_silently("<span color='".. beautiful.bg_normal .."'>󰖪 </span>")
        update_essid()
	end

	local check_network_mode = function()
		awful.spawn.easy_async_with_shell(
			[=[
			wireless="]=] .. tostring(interfaces.wlan_interface) .. [=["
			wired="]=] .. tostring(interfaces.lan_interface) .. [=["
			net="/sys/class/net/"

			wired_state="down"
			wireless_state="down"
			network_mode=""

			# Check network state based on interface's operstate value
			function check_network_state() {
				# Check what interface is up
				if [[ "${wireless_state}" == "up" ]];
				then
					network_mode='wireless'
				elif [[ "${wired_state}" == "up" ]];
				then
					network_mode='wired'
				else
					network_mode='No internet connection'
				fi
			}

			# Check if network directory exist
			function check_network_directory() {
				if [[ -n "${wireless}" && -d "${net}${wireless}" ]];
				then
					wireless_state="$(cat "${net}${wireless}/operstate")"
				fi
				if [[ -n "${wired}" && -d "${net}${wired}" ]]; then
					wired_state="$(cat "${net}${wired}/operstate")"
				fi
				check_network_state
			}

			# Start script
			function print_network_mode() {
				# Call to check network dir
				check_network_directory
				# Print network mode
				printf "${network_mode}"
			}

			print_network_mode

			]=],
			function(stdout)
				local mode = stdout:gsub('%\n', '')
				if stdout:match('No internet connection') then
					update_disconnected()
				elseif stdout:match('wireless') then
					update_wireless()
				elseif stdout:match('wired') then
					update_wired()
				end
			end
		)
	end

	local network_updater = gears.timer {
		timeout = 5,
		autostart = true,
		call_now = true,
		callback = function()
			check_network_mode()
		end
	}

	return widget_button
end

return return_button
